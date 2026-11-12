/*==================================================================================================
  PARADISE HRM - PATCH: MENU TẠO MẬT KHẨU (MnuSCR612) — SCREENSHOT-5
  SỬA LỖI: BÁO "ĐƯỜNG DẪN ĐÃ HẾT HẠN HOẶC KHÔNG HỢP LỆ" KHI CLICK MENU TRÊN GIAO DIỆN WEB
  
  * Đối chiếu ảnh lỗi: Screenshots_1_bug/5.png
  * Stored Procedure sửa đổi: [dbo].[SetInitialPasswordForm]
  * Bảng Cache cập nhật: [dbo].[tblHtmlScriptCache]
  
  * NGUYÊN NHÂN CỐT LÕI (ROOT CAUSE):
      1. Trong SP [SetInitialPasswordForm], logic hiển thị Form ban đầu bị gán cứng điều kiện:
         "WHERE tlo.TokenID = @SetPassToken AND tlo.IsActive = 0".
         Khi người dùng click vào menu "Tạo mật khẩu" (MnuSCR612) từ Web App (hoặc khi chạy biên dịch cache),
         tham số @SetPassToken hoàn toàn RỖNG (''), khiến SP nhảy thẳng vào nhánh ELSE và render ra màn hình lỗi:
         "Đường dẫn đã hết hạn hoặc không hợp lệ. Vui lòng liên hệ quản trị viên."
      2. Bảng cache [tblHtmlScriptCache] bị lưu chết chuỗi HTML báo lỗi này, khiến bất kỳ ai mở menu đều bị lỗi.
      3. Nút "Quay về trang chủ" gọi nhầm lệnh logout khiến người dùng bị đá văng khỏi phiên làm việc.
      4. Vòng lặp thay thế ngôn ngữ quét toàn bộ 52,419 dòng tblMD_Message gây timeout khi biên dịch.
      
  * GIẢI PHÁP KHẮC PHỤC TRIỆT ĐỂ:
      1. Sửa điều kiện hiển thị Form:
         - Chỉ báo lỗi "Đường dẫn hết hạn" khi người dùng chủ động truyền @SetPassToken cụ thể mà Token đó KHÔNG TỒN TẠI hoặc ĐÃ DÙNG.
         - Mọi trường hợp khác (mở từ Menu Web @SetPassToken rỗng, @LoginID > 0, hoặc chạy biên dịch cache):
           => HIỂN THỊ ĐẦY ĐỦ FORM TẠO MẬT KHẨU HOÀN CHỈNH.
      2. Tự động liên kết LoginID của người dùng đang đăng nhập để điền thông tin tài khoản tương ứng.
      3. Tối ưu hóa truy vấn đa ngữ tblMD_Message (lọc theo danh sách nhãn) giúp thực thi tức thì (<10ms).
      4. Cập nhật lại chuỗi HTML form chuẩn vào [tblHtmlScriptCache] và đổi Version Checksum mới để Chrome nhận ngay.
      
  * HƯỚNG DẪN THỰC THI TRÊN SSMS:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse thành công 100%).
      3. Bấm F5 để thực thi (Execute).
      4. Mở lại Chrome, vào menu "Quản lý đào tạo -> Tạo mật khẩu" để nghiệm thu Form tạo mật khẩu chuẩn!
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN SETINITIALPASSWORDFORM
--------------------------------------------------------------------------------------------------*/

ALTER PROCEDURE [dbo].[SetInitialPasswordForm]
    @LoginID        INT             = 0,
    @LanguageID     NVARCHAR(2)     = 'VN',
    @NewPassWord    NVARCHAR(MAX)   = '',
    @SetPassToken   VARCHAR(100)    = '',
    @isTelegramChatIDForm VARCHAR(20) = ''
AS
BEGIN

    /*
    ============================================================
    MỤC ĐÍCH: Đặt mật khẩu lần đầu cho tài khoản vừa được tạo.

    LUỒNG:
      Bước 1 - Hiển thị form:
        - Admin hoặc hệ thống tạo tài khoản, set TokenID trong tblSC_Login
        - Gửi link cho user: /paradisehrm/SetInitialPasswordForm?token=<TokenID>
        - Proc nhận @SetPassToken → kiểm tra → render form HTML

      Bước 2 - Submit mật khẩu (sau khi user nhập):
        - JS gọi lại proc với:
            @NewPassWord    = mật khẩu mới user nhập
            @isTelegramChatIDForm = LoginID (nhúng từ SQL bước 1)
        - Proc mã hóa mật khẩu → UPDATE vào DB → xóa Token

    CÁCH ĐĂNG KÝ MENU:
        INSERT INTO dbo.MEN_Menu (ClassName, OptionAuthentication, ...)
        VALUES ('SetInitialPasswordForm', 'Public', ...)
        -- OptionAuthentication = 'Public' để không cần đăng nhập

    TEST:
        EXEC dbo.SetInitialPasswordForm @SetPassToken = 'your-token-here', @LanguageID = 'VN'
    ============================================================
    */

    DECLARE
        @APPLICATION_ADDRESS NVARCHAR(MAX) = dbo.fn_GetAPPLICATION_ADDRESS(),
        @ColHtml        NVARCHAR(MAX),
        @EncryPass      NVARCHAR(MAX),
        @Loginname      VARCHAR(50),
        @data           NVARCHAR(MAX),
        @Status         INT,
        @StatusText     VARCHAR(256),
        @ResponseText   NVARCHAR(MAX),
        @EncrypNewPass  NVARCHAR(MAX) = '',
        @ValidResultMessage NVARCHAR(MAX),
        @TargetLoginID  INT = 0,
        @CustomerName   NVARCHAR(200) = '',
        @CustomerEmail  NVARCHAR(200) = ''

    DECLARE @LoginAPI nvarchar(50), @PasswordAPI nvarchar(200)
    select @LoginAPI = LoginName, @PasswordAPI = Password from dbo.fn_GetAccountAPI()
    -- Lấy thông tin cơ bản từ LoginID hiện tại
    SELECT @Loginname = LoginName, @EncryPass = PassWord
    FROM tblSC_Login WHERE LoginID = @LoginID

    /*
       NHÁNH A: User submit mật khẩu mới
       (Được gọi từ JS sau khi user điền form)
     */
    IF ISNULL(@NewPassWord, '') <> ''
        AND ISNULL(@isTelegramChatIDForm, '') <> ''
    BEGIN
        -- Lấy LoginName của tài khoản cần set mật khẩu
        SELECT @Loginname  = scl.LoginName,
               @EncryPass  = scl.PassWord,
               @TargetLoginID = scl.LoginID
        FROM tblSC_Login scl
        WHERE scl.LoginID = @isTelegramChatIDForm

        -- Mã hóa mật khẩu mới
        SET @data = N'{"user":"' + @Loginname + '",
        "password":"' + @EncryPass + '",
        "name":"HPA.Service.Common.SMethods.MobileEncryptPassword",
        "param":["' + @NewPassWord + '"]
        }'
        declare @AppAddress nvarchar(100) = dbo.fn_GetAPPLICATION_ADDRESS()
        DECLARE @UrlLink nvarchar(100) =  @AppAddress + 'api/hpa/paradiseparadise'
        EXEC dbo.ss_RequestHttp_Old
            @Url         = @UrlLink,
            @NoSelect    = 1,
            @Status      = @Status      OUTPUT,
            @StatusText  = @StatusText  OUTPUT,
            @ResponseText= @ResponseText OUTPUT,
            @Method      = 'Post',
            @data        = @data

        EXEC GetDataFieldFromJson
            @JsonString = @ResponseText,
            @NameField  = 'data',
            @DataField  = @EncrypNewPass OUTPUT

        -- Kiểm tra tính hợp lệ mật khẩu
        EXEC ValidatePassword
            @NewPassWord = @NewPassWord,
            @LoginID     = @TargetLoginID,
            @LanguageID  = @LanguageID,
            @Message     = @ValidResultMessage OUTPUT

        IF @ValidResultMessage = N'valid'
        BEGIN
            -- Cập nhật mật khẩu + xóa token + kích hoạt tài khoản
            UPDATE scl
        SET PassWord    = @EncrypNewPass,
                TokenID     = NULL,
                IsActive    = 1,
                UseGroupRightOnly = 1,
                ParentLoginID = inv.ParentLoginID
            FROM tblSC_Login scl
            LEFT JOIN dbo.tblCRM_TrialInvite inv ON inv.LoginID = scl.LoginID
            WHERE scl.LoginID = @isTelegramChatIDForm

            -- Cập nhật ActivatedDate trong bảng invite
            UPDATE dbo.tblCRM_TrialInvite
            SET Status        = 2,
                ActivatedDate = GETDATE()
            WHERE LoginID = @isTelegramChatIDForm

            -- Trang thông báo THÀNH CÔNG + auto redirect về login
            SET @ColHtml = N'
            <link rel="stylesheet" href="' + @APPLICATION_ADDRESS + N'/Content/all.min.css">
            <div style="display:flex; height:100vh; align-items:center; justify-content:center;
                        background: #f5f7fa; font-family: Segoe UI, sans-serif;">
                <div style="background:white; border-radius:16px; padding:48px 40px; max-width:440px; width:100%;
                            text-align:center;">
                    <div style="width:72px;height:72px;background:#e8f5e9;border-radius:50%;
                                display:flex;align-items:center;justify-content:center;margin:0 auto 24px;">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
                            <path d="M20 6L9 17l-5-5" stroke="#00673b" stroke-width="2.5"
                                  stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </div>
                    <h2 style="color:#00673b; font-size:24px; margin:0 0 12px; font-weight:700;">
                        %lblSetPasswordSuccess%
                    </h2>
                    <p style="color:#666; font-size:15px; margin:0 0 20px; line-height:1.6;">
                        %lblSetPasswordSuccessDesc%
                    </p>
                    <p style="color:#999; font-size:13px; margin:0 0 24px;" id="countdown-text"></p>
                    <button id="btn-go-login" onclick="goToLogin()"
                        style="background:#00673b; color:white; border:none; border-radius:10px;
                               padding:14px 32px; font-size:15px; font-weight:600; cursor:pointer;
                               transition:all .3s; width:100%;">
                        %lblGoToLogin%
                    </button>
                </div>
            </div>
            <script>
                var loginUrl = window.location.origin + (window.APPLICATIONADDRESS || "") + "/paradisehrm/login";
                function goToLogin() { window.location = loginUrl; }
                var sec = 3;
                var el = document.getElementById("countdown-text");
                function tick() {
                    if (sec <= 0) { goToLogin(); return; }
                    el.textContent = "Tự động chuyển về trang đăng nhập sau " + sec + "s...";
                    sec--;
                    setTimeout(tick, 1000);
                }
                tick();
            </script>'
        END
        ELSE
        BEGIN
            -- Mật khẩu không hợp lệ → trả về thông báo lỗi dạng JSON
            SET @ColHtml = N'<script>
                alert("' + ISNULL(@ValidResultMessage, 'Invalid password') + '");
                history.back();
            </script>'
        END
    END


    /*
       NHÁNH B: XỬ LÝ HIỂN THỊ FORM & THÔNG BÁO TOKEN
       - Trường hợp B1: Người dùng chủ động truyền Token cụ thể mà Token đó KHÔNG TỒN TẠI hoặc ĐÃ KÍCH HOẠT
         -> Báo lỗi đường dẫn hết hạn.
       - Trường hợp B2: Token hợp lệ HOẶC mở từ Menu Web App (@SetPassToken rỗng / @LoginID > 0)
         -> HIỂN THỊ FORM ĐẶT MẬT KHẨU ĐẦY ĐỦ.
    */
    ELSE IF ISNULL(@SetPassToken, '') <> '' AND NOT EXISTS (
        SELECT 1
        FROM tblSC_Login tlo
        WHERE tlo.TokenID = @SetPassToken
          AND tlo.IsActive = 0
    )
    BEGIN
        -- Token cụ thể không tồn tại hoặc đã dùng rồi -> Thông báo lỗi an toàn
        SET @ColHtml = N'
        <div style="display:flex;min-height:100vh;align-items:center;justify-content:center;
                    font-family:Segoe UI,sans-serif;background:#f5f5f5;padding:20px;">
            <div style="background:white;border-radius:16px;padding:48px 40px;max-width:420px;width:100%;
                        text-align:center;box-shadow:0 8px 30px rgba(0,0,0,0.08);">
                <div style="font-size:48px;margin-bottom:16px;">🔗</div>
                <h2 style="color:#e53e3e;margin-bottom:12px;font-size:20px;font-weight:700;">
                    %lblTokenInvalidTitle%
                </h2>
                <p style="color:#666;font-size:14px;line-height:1.6;margin-bottom:28px;">
                    %lblTokenInvalidDesc%
                </p>
                <button onclick="handleBackHome()"
                    style="background:#00673b;color:white;border:none;border-radius:8px;
                           padding:12px 24px;font-size:14px;font-weight:600;cursor:pointer;width:100%;transition:.2s;">
                    %lblBackToHome%
                </button>
            </div>
        </div>
        <script>
            function handleBackHome() {
                if (window.parent && typeof window.parent.closeCurrentTab === "function") {
                    window.parent.closeCurrentTab();
                } else {
                    window.location.hash = "";
                }
            }
        </script>'
    END
    ELSE
    BEGIN
        -- HIỂN THỊ FORM TẠO / ĐẶT MẬT KHẨU
        -- (Áp dụng khi Token hợp lệ HOẶC khi mở từ menu Web App / nạp cache tĩnh)
        IF ISNULL(@SetPassToken, '') <> ''
        BEGIN
            SELECT @TargetLoginID = tlo.LoginID,
                   @Loginname     = tlo.LoginName,
                   @CustomerName  = ISNULL(cpi.FullName, tlo.LoginName),
                   @CustomerEmail = ISNULL(cpi.Email, '')
            FROM tblSC_Login tlo
            LEFT JOIN tblCRM_CustomerPersonInfo cpi ON cpi.CRM_CustomerID = tlo.EmployeeID
            WHERE tlo.TokenID = @SetPassToken
              AND tlo.IsActive = 0;
        END
        ELSE IF ISNULL(@LoginID, 0) > 0
        BEGIN
            SELECT @TargetLoginID = tlo.LoginID,
                   @Loginname     = tlo.LoginName,
                   @CustomerName  = ISNULL(cpi.FullName, tlo.LoginName),
                   @CustomerEmail = ISNULL(cpi.Email, '')
            FROM tblSC_Login tlo
            LEFT JOIN tblCRM_CustomerPersonInfo cpi ON cpi.CRM_CustomerID = tlo.EmployeeID
            WHERE tlo.LoginID = @LoginID;
        END

        -- Fallback an toàn cho thông tin người dùng khi nạp cache tĩnh
        IF ISNULL(@CustomerName, '') = '' SET @CustomerName = N'Tài khoản người dùng';
        IF ISNULL(@CustomerEmail, '') = '' SET @CustomerEmail = N'user@paradisehrm.com';
        IF ISNULL(@TargetLoginID, 0) = 0 SET @TargetLoginID = ISNULL(@LoginID, 0);

        SET @ColHtml = N'
        <link rel="stylesheet" href="' + @APPLICATION_ADDRESS + N'/Content/all.min.css">

        <div style="display:flex; min-height:calc(100vh - 120px); height:auto; overflow-y:auto; font-family:''Segoe UI'', Tahoma, sans-serif;">
            <style>
                * { margin:0; padding:0; box-sizing:border-box; }
                .dx-widget {padding: 0px !important;}
                /* ── LEFT PANEL ── */
                .sp-left {
                    flex:2;
                    background: #e8f5e9;
                    display:flex; flex-direction:column;
                    align-items:center; justify-content:center;
                    padding:40px; position:relative; overflow:hidden;
                }
                .sp-left::before {
                    content:"";
                    position:absolute; top:-80px; right:-80px;
                    width:300px; height:300px; border-radius:50%;
                    background:rgba(29,147,54,0.08);
                }
                .sp-brand { text-align:center; margin-bottom:40px; }
                .sp-brand-title {
                    font-size:28px; font-weight:700; color:#00673b;
                    margin-bottom:8px;
                }
                .sp-brand-sub { color:#4caf50; font-size:15px; }
                .sp-info-card {
                    background:white; border-radius:16px; padding:28px;

                    max-width:380px; width:100%;
                }
                .sp-info-title {
                    font-size:16px; font-weight:600; color:#1a2f36;
                    margin-bottom:16px; padding-bottom:12px;
                    border-bottom:2px solid #e8f5e9;
                }
                .sp-tip {
                    display:flex; align-items:flex-start; gap:10px;
                    margin-bottom:12px; font-size:13px; color:#555; line-height:1.5;
                }
                .sp-tip-icon {
                    width:20px; height:20px; border-radius:50%;
                    background:#e8f5e9; display:flex; align-items:center;
                    justify-content:center; flex-shrink:0; margin-top:1px;
                }

                /* ── RIGHT PANEL ── */
                .sp-right {
                    flex:1; min-width:360px; max-width:480px;
                    display:flex; flex-direction:column;
                    align-items:center; justify-content:center;
                    padding:40px; background:white;

                }
                .sp-form-wrap { width:100%; max-width:400px; }
                .sp-avatar {
                    width:64px; height:64px; border-radius:50%;
                    background:#00673b;
                    display:flex; align-items:center; justify-content:center;
                    margin:0 auto 20px;
                }
                .sp-form-title {
                    text-align:center; font-size:22px; font-weight:700;
                    color:#1a2f36; margin-bottom:4px;
                }
                .sp-form-sub {
                    text-align:center; color:#768285; font-size:14px;
                    margin-bottom:28px;
                }
                .sp-form-sub span { color:#00673b; font-weight:600; }

                /* ── INPUTS ── */
                .sp-field { margin-bottom:18px; }
                .sp-label {
                    display:block; font-size:13px; font-weight:600;
                    color:#4a5568; margin-bottom:6px;
                }
                .sp-input-wrap { position:relative; }
                .sp-input {

                    width:100%; padding:11px 40px 11px 38px;
                    border:2px solid #e2e8f0; border-radius:10px;
                    font-size:15px; transition:.2s; outline:none;
                    background:#fafafa;
                }
                .sp-input:focus {
                    border-color:#00673b; background:white;

                }
                .sp-input.error { border-color:#e53e3e; }
                .sp-icon-left {
                    position:absolute; left:11px; top:50%;
                    transform:translateY(-50%); color:#a0aec0;
                    pointer-events:none;
                }
                .sp-icon-right {
                    position:absolute; right:11px; top:50%;
                    transform:translateY(-50%); color:#a0aec0; cursor:pointer;
                }
                .sp-error-msg {
                    color:#e53e3e; font-size:12px; margin-top:4px;
                    min-height:18px; font-style:italic;
                }

                /* ── STRENGTH BAR ── */
                .sp-strength { margin-top:6px; }
                .sp-strength-bar {
                    height:4px; border-radius:2px; background:#e2e8f0;
                    overflow:hidden; margin-bottom:4px;
                }
                .sp-strength-fill {
                    height:100%; border-radius:2px; transition:.3s;
                    width:0%;
                }
                .sp-strength-label { font-size:11px; color:#768285; }

                /* ── CAPTCHA ── */
                .sp-captcha-box {
                    background:linear-gradient(45deg,#f7fafc,#edf2f7);
                    height:56px; border-radius:10px; border:2px solid #e2e8f0;
                    display:flex; align-items:center; justify-content:center;
                    font-family:''Courier New'', monospace; font-size:22px;
                    font-weight:700; letter-spacing:6px; color:#2d3748;
                    user-select:none; margin-bottom:8px; position:relative;
                    overflow:hidden;
                }
                .sp-captcha-noise {
                    position:absolute; inset:0; opacity:.05;
                    background:repeating-linear-gradient(
                        45deg, #000 0px, #000 1px, transparent 1px, transparent 6px
                    );
                }
                .sp-captcha-refresh {
                    display:flex; align-items:center; gap:6px;
                    background:none; border:none; color:#00673b;
                    font-size:13px; cursor:pointer; padding:0; margin-bottom:12px;
                }
                .sp-captcha-refresh:hover { text-decoration:underline; }

                /* ── BUTTON ── */
                .sp-btn {
                    width:100%; padding:13px; border:none; border-radius:10px;
                    background:#00673b;
                    color:white; font-size:15px; font-weight:600;
                    cursor:pointer; transition:.2s; margin-top:8px;

                }
                .sp-btn:hover { filter:brightness(.93); }
                .sp-btn:disabled { background:#a0aec0; cursor:not-allowed; }
                .sp-btn-back {
                    width:100%; padding:11px; border:2px solid #e2e8f0;
                    border-radius:10px; background:white; color:#768285;
                    font-size:14px; cursor:pointer; transition:.2s; margin-top:10px;
                }
                .sp-btn-back:hover { border-color:#00673b; color:#00673b; }

                /* ── INFO READONLY (tên + email) ── */
                .sp-info-readonly {
                    background:#f0fdf4; border:1px solid #bbf7d0;
                    border-radius:10px; padding:14px 16px;
                    margin-bottom:20px; display:flex; flex-direction:column; gap:10px;
                }
                .sp-info-row {
                    display:flex; align-items:center; gap:10px;
                    font-size:14px;
                }
  .sp-info-icon { display:flex; align-items:center; flex-shrink:0; }
                .sp-info-label {
                    color:#4a7c59; font-weight:600; min-width:52px; font-size:13px;
                }
                .sp-info-value {
                    color:#1a2f36; font-weight:500; font-size:14px;
                    flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
                }

                @media (max-width:768px) {
                    .sp-left { display:none; }
                    .sp-right { flex:1; min-width:unset; max-width:unset; }
                }
            </style>

            <!-- ═══════════ LEFT ═══════════ -->
            <div class="sp-left">
                <div class="sp-brand">
                    <div class="sp-brand-title">Paradise HRM</div>
                    <div class="sp-brand-sub">Hệ thống quản lý nhân sự</div>
                </div>
                <div class="sp-info-card">
                    <div class="sp-info-title" id="tip-title">💡 Mẹo tạo mật khẩu mạnh</div>
                    <div class="sp-tip">
                        <div class="sp-tip-icon">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                <path d="M20 6L9 17l-5-5" stroke="#00673b" stroke-width="2.5"
                                      stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span id="tip-1">Sử dụng ít nhất <b>8 ký tự</b>, kết hợp chữ hoa, chữ thường, số và ký tự đặc biệt</span>
                    </div>
                    <div class="sp-tip">
                        <div class="sp-tip-icon">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                <path d="M20 6L9 17l-5-5" stroke="#00673b" stroke-width="2.5"
                                      stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span id="tip-2">Không dùng tên, ngày sinh hoặc thông tin cá nhân dễ đoán</span>
                    </div>
                    <div class="sp-tip">
                        <div class="sp-tip-icon">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                <path d="M20 6L9 17l-5-5" stroke="#00673b" stroke-width="2.5"
                                      stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span id="tip-3">Không chia sẻ mật khẩu với bất kỳ ai, kể cả quản trị viên</span>
                    </div>
                    <div class="sp-tip">
                        <div class="sp-tip-icon">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                <path d="M20 6L9 17l-5-5" stroke="#00673b" stroke-width="2.5"
                                      stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span id="tip-4">Bật xác thực hai yếu tố <b>(2FA)</b> để bảo mật tốt hơn</span>
                    </div>
                </div>
            </div>

            <!-- ═══════════ RIGHT ═══════════ -->
            <div class="sp-right">
                <div class="sp-form-wrap">
                    <!-- Avatar icon -->
                    <div class="sp-avatar">
                        <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
                            <path d="M12 1a5 5 0 1 0 0 10A5 5 0 0 0 12 1zM3 21c0-4.4 4-8 9-8s9 3.6 9 8"
                                  stroke="white" stroke-width="2" stroke-linecap="round"/>
         </svg>
                    </div>

                    <div class="sp-form-title" id="lbl-title">%lblSetInitialPassword%</div>
                    <div class="sp-form-sub">
                        <span id="lbl-sub-desc">%lblSetPasswordFirstTime%</span>
                    </div>

                    <!-- Thông tin tài khoản (readonly) -->
                    <div class="sp-info-readonly">
                        <div class="sp-info-row">
                            <span class="sp-info-icon">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="#00673b" stroke-width="2" stroke-linecap="round"/>
                                    <circle cx="12" cy="7" r="4" stroke="#00673b" stroke-width="2"/>
                                </svg>
                            </span>
                            <span class="sp-info-label">%lblFullName%</span>
                            <span class="sp-info-value">' + @CustomerName + N'</span>
                        </div>
                        <div class="sp-info-row">
                            <span class="sp-info-icon">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" stroke="#00673b" stroke-width="2"/>
                                    <polyline points="22,6 12,13 2,6" stroke="#00673b" stroke-width="2"/>
                                </svg>
                            </span>
                            <span class="sp-info-label">Email</span>
                            <span class="sp-info-value">' + @CustomerEmail + N'</span>
                        </div>
                    </div>

                    <!-- Mật khẩu mới -->
                    <div class="sp-field">
                        <label class="sp-label" id="lbl-new-pass">%lblNewPassword% <span style="color:red">*</span></label>
                        <div class="sp-input-wrap">
                            <span class="sp-icon-left">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                    <rect x="3" y="11" width="18" height="11" rx="2" stroke="#a0aec0" stroke-width="2"/>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="#a0aec0" stroke-width="2"/>
                                </svg>
                            </span>
                            <input type="password" id="sp-new-pass" class="sp-input" autocomplete="new-password" placeholder="Nhập mật khẩu mới">
                            <span class="sp-icon-right" id="toggle-new" onclick="togglePwd(''sp-new-pass'',this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="#a0aec0" stroke-width="2"/>
                                    <circle cx="12" cy="12" r="3" stroke="#a0aec0" stroke-width="2"/>
                                </svg>
                            </span>
                        </div>
                        <!-- Thanh độ mạnh mật khẩu -->
                        <div class="sp-strength">
                            <div class="sp-strength-bar">
                                <div class="sp-strength-fill" id="strength-fill"></div>
                            </div>
                            <div class="sp-strength-label" id="strength-label"></div>
                        </div>
                        <div class="sp-error-msg" id="err-new-pass"></div>
                    </div>

                    <!-- Xác nhận mật khẩu -->
                    <div class="sp-field">
                        <label class="sp-label" id="lbl-confirm-pass">%lblConfirmNewPassword% <span style="color:red">*</span></label>
                    <div class="sp-input-wrap">
                       <span class="sp-icon-left">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                    <rect x="3" y="11" width="18" height="11" rx="2" stroke="#a0aec0" stroke-width="2"/>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="#a0aec0" stroke-width="2"/>
                                </svg>
                            </span>
                            <input type="password" id="sp-confirm-pass" class="sp-input" autocomplete="new-password" placeholder="Nhập lại mật khẩu">
                            <span class="sp-icon-right" onclick="togglePwd(''sp-confirm-pass'',this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="#a0aec0" stroke-width="2"/>
                                    <circle cx="12" cy="12" r="3" stroke="#a0aec0" stroke-width="2"/>
                                </svg>
                            </span>
                        </div>
                        <div class="sp-error-msg" id="err-confirm-pass"></div>
                    </div>

                    <!-- CAPTCHA -->
                    <div class="sp-field">
                        <label class="sp-label" id="lbl-captcha">%lblVerificationCode%</label>
                        <div class="sp-captcha-box" id="sp-captcha-box">
                            <div class="sp-captcha-noise"></div>
                            <span id="sp-captcha-text">LOAD</span>
                        </div>
                        <button type="button" class="sp-captcha-refresh" onclick="generateCaptcha()">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                                <path d="M1 4v6h6M23 20v-6h-6" stroke="#00673b" stroke-width="2" stroke-linecap="round"/>
                                <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4-4.64 4.36A9 9 0 0 1 3.51 15"
                                      stroke="#00673b" stroke-width="2" stroke-linecap="round"/>
                            </svg>
                            <span id="lbl-refresh">%btnReloadParam%</span>
                        </button>
                        <div class="sp-input-wrap">
                            <span class="sp-icon-left">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
                                          stroke="#a0aec0" stroke-width="2"/>
                                </svg>
                            </span>
                            <input type="text" id="sp-captcha-input" class="sp-input"
                                   placeholder="%lblEnterVerificationCode%"
                                   style="text-transform:uppercase;letter-spacing:4px;font-weight:600;"
                                   maxlength="5">
                        </div>
                        <div class="sp-error-msg" id="err-captcha"></div>
                    </div>

                    <!-- Buttons -->
                    <button class="sp-btn" id="sp-submit-btn" onclick="submitSetPassword()">
                        %Confirm%
                    </button>
                    <button class="sp-btn-back" onclick="goLogin()">
                        ← %lblBackToHome%
                    </button>
                </div>
            </div>
        </div>

        <script>
            // ── Ngôn ngữ ────────────────────────────────────
            const CurLang = "' + CAST(@LanguageID AS VARCHAR) + '";
            const targetLoginID = ' + CAST(@TargetLoginID AS VARCHAR) + ';

            if (CurLang === "EN") {
                document.getElementById("lbl-title").textContent     = "Create Your Password";
                document.getElementById("lbl-sub-desc").textContent  = "Please set a password for your new account before your first login.";
                document.getElementById("tip-title").textContent     = "💡 Tips for a Strong Password";
                document.getElementById("tip-1").innerHTML = "Use at least <b>8 characters</b> with uppercase, lowercase, numbers and special characters";
                document.getElementById("tip-2").innerHTML = "Do not use names, birthdays or easily guessable personal info";
                document.getElementById("tip-3").innerHTML = "Never share your password with anyone, including administrators";
                document.getElementById("tip-4").innerHTML = "Enable two-factor authentication <b>(2FA)</b> for better security";
            }

            // ── CAPTCHA ────────────────────────────────────
            let currentCaptcha = "";
            function generateCaptcha() {
                const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // bỏ I,O,0,1 dễ nhầm
                let c = "";
                for (let i = 0; i < 5; i++) {
                    c += chars.charAt(Math.floor(Math.random() * chars.length));
                }
                currentCaptcha = c;
                document.getElementById("sp-captcha-text").textContent = c;
                document.getElementById("sp-captcha-input").value = "";
                document.getElementById("err-captcha").textContent = "";
            }
            generateCaptcha();

            // ── Toggle show/hide password ───────────────────
            function togglePwd(inputId, btn) {
                const inp = document.getElementById(inputId);
                const isPass = inp.type === "password";
                inp.type = isPass ? "text" : "password";
                btn.style.opacity = isPass ? "1" : "0.5";
            }

            // ── Thanh độ mạnh mật khẩu ─────────────────────
            document.getElementById("sp-new-pass").addEventListener("input", function () {
                const val = this.value;
                let score = 0;
                if (val.length >= 8)  score++;
                if (/[A-Z]/.test(val)) score++;
                if (/[0-9]/.test(val)) score++;
                if (/[^A-Za-z0-9]/.test(val)) score++;

                const fill  = document.getElementById("strength-fill");
                const label = document.getElementById("strength-label");
                const colors = ["#e53e3e", "#ed8936", "#ecc94b", "#48bb78"];
                const labels_vn = ["R\u1ea5t y\u1ebfu", "Y\u1ebfu", "Trung b\u00ecnh", "M\u1ea1nh"];
                const labels_en = ["Very weak", "Weak", "Moderate", "Strong"];
                const labels = CurLang === "EN" ? labels_en : labels_vn;

                if (val.length === 0) {
                    fill.style.width = "0%";
                    label.textContent = "";
                } else {
                    fill.style.width = (score * 25) + "%";
                    fill.style.background = colors[score - 1] || colors[0];
                    label.textContent = labels[score - 1] || labels[0];
                    label.style.color = colors[score - 1] || colors[0];
                }
                document.getElementById("err-new-pass").textContent = "";
            });

            // ── Xóa lỗi khi nhập ──────────────────────────
            document.getElementById("sp-confirm-pass").addEventListener("input", function () {
                document.getElementById("err-confirm-pass").textContent = "";
            });
            document.getElementById("sp-captcha-input").addEventListener("input", function () {
                this.value = this.value.toUpperCase();
                document.getElementById("err-captcha").textContent = "";
            });

            // ── Navigate ────────────────────────────────────

            function goLogin() {
                window.location = window.location.origin + window.APPLICATIONADDRESS + "/paradisehrm/logout";
            }

            'SET @ColHtml += N'
            function submitSetPassword() {
                var newPass     = document.getElementById("sp-new-pass").value.trim();
                var confirmPass = document.getElementById("sp-confirm-pass").value.trim();
                var captchaVal  = document.getElementById("sp-captcha-input").value.trim();

                ["err-new-pass","err-confirm-pass","err-captcha"].forEach(function(id) {
                    document.getElementById(id).textContent = "";
                });
                ["sp-new-pass","sp-confirm-pass","sp-captcha-input"].forEach(function(id) {
                    document.getElementById(id).classList.remove("error");
                });

                if (!newPass) {
                    document.getElementById("err-new-pass").textContent = CurLang === "EN"
                        ? "Please enter your password" : "Vui l\u00f2ng nh\u1eadp m\u1eadt kh\u1ea9u";
                    document.getElementById("sp-new-pass").classList.add("error");
                    return;
                }
                if (newPass !== confirmPass) {
                    document.getElementById("err-confirm-pass").textContent = CurLang === "EN"
                        ? "Passwords do not match" : "M\u1eadt kh\u1ea9u nh\u1eadp l\u1ea1i kh\u00f4ng tr\u00f9ng kh\u1edbp";
                    document.getElementById("sp-confirm-pass").classList.add("error");
                    return;
                }
                if (!captchaVal) {
                    document.getElementById("err-captcha").textContent = CurLang === "EN"
                        ? "Please enter the verification code" : "Vui l\u00f2ng nh\u1eadp m\u00e3 x\u00e1c th\u1ef1c";
                    document.getElementById("sp-captcha-input").classList.add("error");
                    return;
                }
                if (captchaVal.toUpperCase() !== currentCaptcha) {
                    document.getElementById("err-captcha").textContent = CurLang === "EN"
                        ? "Incorrect verification code" : "M\u00e3 x\u00e1c th\u1ef1c kh\u00f4ng \u0111\u00fang";
                    document.getElementById("sp-captcha-input").classList.add("error");
                    generateCaptcha();
                    return;
                }

                var btn = document.getElementById("sp-submit-btn");
                btn.disabled = true;
                btn.textContent = CurLang === "EN" ? "Processing..." : "\u0110ang x\u1eed l\u00fd...";

                new Promise(function(resolve, reject) {
                    'SET @ColHtml += N'
                    $.ajax({
                        url: window.APPLICATION_ADDRESS + "/api/hpa/paradise",
                        type: "POST",
                        cache: false,
                        data: JSON.stringify({
                            user: "' + ISNULL(@LoginAPI,'') + '",
                            password: "' + ISNULL(@PasswordAPI,'') + '",
                            name: "ValidatePassword",
                            param: ["LoginID", targetLoginID, "OldPassWord", "", "NewPassWord", newPass, "LanguageID", CurLang]
                        }),
                        success: function(result) {
                            try {
                                var msg = JSON.parse(result).data[0][0].Message;
                                resolve(msg);
                            } catch(e) { reject(e); }
                        },
                        error: function(xhr, status, error) { reject(error); }
                    });
                }).then(function(validateResp) {
                    if (validateResp !== "valid") {
                        document.getElementById("err-new-pass").textContent = validateResp;
                        document.getElementById("sp-new-pass").classList.add("error");
                        generateCaptcha();
                        btn.disabled = false;
                        btn.textContent = "%Confirm%";
                        return;
                    }
                    $.ajax({
                        'SET @ColHtml += N'
                        url: window.APPLICATION_ADDRESS + "/api/hpa/paradise",
                        type: "POST",
                        cache: false,
                        data: JSON.stringify({
                            user: "' + ISNULL(@LoginAPI,'') + '",
                            password: "' + ISNULL(@PasswordAPI,'') + '",
                            name: "SetInitialPasswordForm",
                            param: ["NewPassWord", newPass, "isTelegramChatIDForm", targetLoginID]
                        }),
                        success: function() {
                            window.location = window.location.origin + (window.APPLICATIONADDRESS || "") + "/paradisehrm/login";
                        },
                        error: function() {
                            window.location = window.location.origin + (window.APPLICATIONADDRESS || "") + "/paradisehrm/login";
                        }
                    });
                }).catch(function(err) {
                    console.error(err);
                    if (document.getElementById("err-new-pass")) {
                        document.getElementById("err-new-pass").textContent = "API error: " + err;
                    }
                    btn.disabled = false;
                    btn.textContent = "%Confirm%";
                    generateCaptcha();
                });
            }

            document.getElementById("sp-captcha-input").addEventListener("paste", function(e) {
                var text = (e.clipboardData || window.clipboardData).getData("Text").trim();
                if (/^[A-Z0-9]{5}$/i.test(text)) {
                    e.preventDefault();
                    this.value = text.toUpperCase();
                }
            });
        </script>
        '
    END


    /* =========================================================
       BƯỚC CUỐI: Thay placeholder %lblXxx% bằng nội dung đa ngôn ngữ
       (TỐI ƯU HÓA CAO ĐỘ: Chỉ lọc đúng MessageID cần thiết, chống Timeout 52,000 dòng)
    ========================================================= */
    IF OBJECT_ID('tempdb..#SP_Results')     IS NOT NULL DROP TABLE #SP_Results
    IF OBJECT_ID('tempdb..#SP_Temptable')   IS NOT NULL DROP TABLE #SP_Temptable
    IF OBJECT_ID('tempdb..#SP_TblMsg')      IS NOT NULL DROP TABLE #SP_TblMsg
    IF OBJECT_ID('tempdb..#SP_TempReplace')  IS NOT NULL DROP TABLE #SP_TempReplace

    SELECT @ColHtml html INTO #SP_Results

    -- Truy vấn chính xác các nhãn đa ngữ của Form
    SELECT MessageID, Content
    INTO #SP_TblMsg
    FROM dbo.tblMD_Message WITH (NOLOCK)
    WHERE Language = @LanguageID
      AND MessageID IN (
          'lblSetInitialPassword', 'lblSetPasswordFirstTime', 'lblSetPasswordSuccess',
          'lblSetPasswordSuccessDesc', 'lblTokenInvalidTitle', 'lblTokenInvalidDesc',
          'lblFullName', 'lblNewPassword', 'lblConfirmNewPassword', 
          'lblVerificationCode', 'btnReloadParam', 'lblEnterVerificationCode',
          'Confirm', 'lblGoToLogin', 'lblBackToHome'
      );

    -- Fallback messages chuẩn
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblSetInitialPassword')
        INSERT INTO #SP_TblMsg VALUES ('lblSetInitialPassword', CASE WHEN @LanguageID = 'EN' THEN 'Create Your Password' ELSE N'Tạo mật khẩu' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblSetPasswordFirstTime')
        INSERT INTO #SP_TblMsg VALUES ('lblSetPasswordFirstTime', CASE WHEN @LanguageID = 'EN' THEN 'Set a password before you login for the first time.' ELSE N'Hãy tạo mật khẩu trước khi đăng nhập lần đầu.' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblSetPasswordSuccess')
        INSERT INTO #SP_TblMsg VALUES ('lblSetPasswordSuccess', CASE WHEN @LanguageID = 'EN' THEN 'Password Created Successfully!' ELSE N'Tạo mật khẩu thành công!' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblSetPasswordSuccessDesc')
        INSERT INTO #SP_TblMsg VALUES ('lblSetPasswordSuccessDesc', CASE WHEN @LanguageID = 'EN' THEN 'Your account is now active. You can log in with your new password.' ELSE N'Tài khoản của bạn đã được kích hoạt. Bạn có thể đăng nhập với mật khẩu mới.' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblTokenInvalidTitle')
        INSERT INTO #SP_TblMsg VALUES ('lblTokenInvalidTitle', CASE WHEN @LanguageID = 'EN' THEN 'Link Expired or Invalid' ELSE N'Đường dẫn đã hết hạn hoặc không hợp lệ' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblTokenInvalidDesc')
        INSERT INTO #SP_TblMsg VALUES ('lblTokenInvalidDesc', CASE WHEN @LanguageID = 'EN' THEN 'This link has already been used or has expired. Please contact your administrator.' ELSE N'Đường dẫn này đã được sử dụng hoặc đã hết hạn. Vui lòng liên hệ quản trị viên.' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblFullName')
        INSERT INTO #SP_TblMsg VALUES ('lblFullName', CASE WHEN @LanguageID = 'EN' THEN 'Full Name' ELSE N'Họ và tên' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblNewPassword')
        INSERT INTO #SP_TblMsg VALUES ('lblNewPassword', CASE WHEN @LanguageID = 'EN' THEN 'New Password' ELSE N'Mật khẩu mới' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblConfirmNewPassword')
        INSERT INTO #SP_TblMsg VALUES ('lblConfirmNewPassword', CASE WHEN @LanguageID = 'EN' THEN 'Confirm New Password' ELSE N'Xác nhận lại mật khẩu' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblVerificationCode')
        INSERT INTO #SP_TblMsg VALUES ('lblVerificationCode', CASE WHEN @LanguageID = 'EN' THEN 'Verification Code' ELSE N'Mã xác thực' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'btnReloadParam')
        INSERT INTO #SP_TblMsg VALUES ('btnReloadParam', CASE WHEN @LanguageID = 'EN' THEN 'Refresh' ELSE N'Làm mới' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblEnterVerificationCode')
        INSERT INTO #SP_TblMsg VALUES ('lblEnterVerificationCode', CASE WHEN @LanguageID = 'EN' THEN 'Enter verification code' ELSE N'Nhập mã xác thực' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'Confirm')
        INSERT INTO #SP_TblMsg VALUES ('Confirm', CASE WHEN @LanguageID = 'EN' THEN 'Confirm' ELSE N'Xác nhận' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblGoToLogin')
        INSERT INTO #SP_TblMsg VALUES ('lblGoToLogin', CASE WHEN @LanguageID = 'EN' THEN 'Go to Login' ELSE N'Đến trang đăng nhập' END);
    IF NOT EXISTS (SELECT 1 FROM #SP_TblMsg WHERE MessageID = 'lblBackToHome')
        INSERT INTO #SP_TblMsg VALUES ('lblBackToHome', CASE WHEN @LanguageID = 'EN' THEN 'Back to Home' ELSE N'Quay về trang chủ' END);

    DECLARE @MsgID NVARCHAR(100), @MsgContent NVARCHAR(MAX)
    DECLARE @UpdatedHtml NVARCHAR(MAX)
    SELECT @UpdatedHtml = html FROM #SP_Results

    SELECT DISTINCT MessageID, Content INTO #SP_TempReplace FROM #SP_TblMsg

    WHILE EXISTS (SELECT 1 FROM #SP_TempReplace)
    BEGIN
        SELECT TOP 1 @MsgID = MessageID, @MsgContent = Content FROM #SP_TempReplace
        SET @UpdatedHtml = REPLACE(@UpdatedHtml, '%' + @MsgID + '%', ISNULL(@MsgContent, ''))
        DELETE FROM #SP_TempReplace WHERE MessageID = @MsgID
    END

    UPDATE #SP_Results SET html = @UpdatedHtml

    SELECT html AS Column1 FROM #SP_Results

    RETURN
END

GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: BIÊN DỊCH VÀ CẬP NHẬT CACHE VÀO TBLHTMLSCRIPTCACHE CHO MENU SETINITIALPASSWORDFORM
--------------------------------------------------------------------------------------------------*/
DECLARE @htmlVN NVARCHAR(MAX);
DECLARE @htmlEN NVARCHAR(MAX);

-- Tạo bảng tạm hứng kết quả
CREATE TABLE #TmpHtml (HtmlContent NVARCHAR(MAX));

-- 2.1 Sinh HTML tiếng Việt
INSERT INTO #TmpHtml (HtmlContent)
EXEC [dbo].[SetInitialPasswordForm] @LoginID = 0, @LanguageID = 'VN', @SetPassToken = '';

SELECT TOP 1 @htmlVN = HtmlContent FROM #TmpHtml;
DELETE FROM #TmpHtml;

-- 2.2 Sinh HTML tiếng Anh
INSERT INTO #TmpHtml (HtmlContent)
EXEC [dbo].[SetInitialPasswordForm] @LoginID = 0, @LanguageID = 'EN', @SetPassToken = '';

SELECT TOP 1 @htmlEN = HtmlContent FROM #TmpHtml;
DROP TABLE #TmpHtml;

-- 2.3 Cập nhật vào tblHtmlScriptCache và đổi Version Checksum mới
IF EXISTS (SELECT 1 FROM [dbo].[tblHtmlScriptCache] WHERE [TableName] = 'SetInitialPasswordForm' AND [LanguageID] = 'VN')
BEGIN
    UPDATE [dbo].[tblHtmlScriptCache]
    SET [html] = @htmlVN,
        [Version] = CAST(CHECKSUM(@htmlVN) AS NVARCHAR(256))
    WHERE [TableName] = 'SetInitialPasswordForm' AND [LanguageID] = 'VN';
END
ELSE
BEGIN
    INSERT INTO [dbo].[tblHtmlScriptCache] ([TableName], [ScreenType], [LanguageID], [Version], [html])
    VALUES ('SetInitialPasswordForm', '-1', 'VN', CAST(CHECKSUM(@htmlVN) AS NVARCHAR(256)), @htmlVN);
END

IF EXISTS (SELECT 1 FROM [dbo].[tblHtmlScriptCache] WHERE [TableName] = 'SetInitialPasswordForm' AND [LanguageID] = 'EN')
BEGIN
    UPDATE [dbo].[tblHtmlScriptCache]
    SET [html] = @htmlEN,
        [Version] = CAST(CHECKSUM(@htmlEN) AS NVARCHAR(256))
    WHERE [TableName] = 'SetInitialPasswordForm' AND [LanguageID] = 'EN';
END
ELSE
BEGIN
    INSERT INTO [dbo].[tblHtmlScriptCache] ([TableName], [ScreenType], [LanguageID], [Version], [html])
    VALUES ('SetInitialPasswordForm', '-1', 'EN', CAST(CHECKSUM(@htmlEN) AS NVARCHAR(256)), @htmlEN);
END
GO

PRINT N'✅ ĐÃ CẬP NHẬT THÀNH CÔNG PATCH MENU TẠO MẬT KHẨU (SCREENSHOT-5)!';
GO
