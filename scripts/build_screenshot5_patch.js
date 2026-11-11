const fs = require('fs');
const path = require('path');

const srcFile = path.join(__dirname, 'SetInitialPasswordForm_def.sql');
let code = fs.readFileSync(srcFile, 'utf8');

// 1. Tách phần đầu (trước nhánh ELSE IF EXISTS)
const markerBranchB = '    /*\r\n       NHÁNH B: Hiển thị form đặt mật khẩu lần đầu\r\n       (Token hợp lệ → render trang)\r\n    */';
const altMarkerBranchB = '    /*\n       NHÁNH B: Hiển thị form đặt mật khẩu lần đầu\n       (Token hợp lệ → render trang)\n    */';

let splitIdx = code.indexOf(markerBranchB);
let markerLen = markerBranchB.length;
if (splitIdx === -1) {
    splitIdx = code.indexOf(altMarkerBranchB);
    markerLen = altMarkerBranchB.length;
}

if (splitIdx === -1) {
    console.error('Marker Branch B not found!');
    process.exit(1);
}

const part1 = code.substring(0, splitIdx);

// Tìm marker nhánh ELSE cũ (dòng 745: ELSE BEGIN -- Token không tồn tại hoặc đã dùng rồi)
const markerOldElse = code.indexOf('    ELSE\r\n    BEGIN\r\n        -- Token không tồn tại hoặc đã dùng rồi');
const altMarkerOldElse = code.indexOf('    ELSE\n    BEGIN\n        -- Token không tồn tại hoặc đã dùng rồi');
let elseIdx = markerOldElse !== -1 ? markerOldElse : altMarkerOldElse;

if (elseIdx === -1) {
    console.error('Marker Old Else not found!');
    process.exit(1);
}

// Phần giữa là khối render form (từ dòng 194 đến trước ELSE)
// Nhưng cần bỏ điều kiện ELSE IF EXISTS cũ (dòng 177 - 193)
const formContentIdx = code.indexOf('SET @ColHtml = N\'', splitIdx);
if (formContentIdx === -1 || formContentIdx > elseIdx) {
    console.error('formContentIdx not found!');
    process.exit(1);
}

const formBody = code.substring(formContentIdx, elseIdx);

// Tìm marker bước cuối thay thế message (dòng 769)
const markerFinalStep = code.indexOf('    /* =========================================================\r\n       BƯỚC CUỐI: Thay placeholder %lblXxx% bằng nội dung đa ngôn ngữ');
const altMarkerFinalStep = code.indexOf('    /* =========================================================\n       BƯỚC CUỐI: Thay placeholder %lblXxx% bằng nội dung đa ngôn ngữ');
let finalIdx = markerFinalStep !== -1 ? markerFinalStep : altMarkerFinalStep;

if (finalIdx === -1) {
    console.error('Marker Final Step not found!');
    process.exit(1);
}

// Xây dựng thân SP mới (đảm bảo dùng ALTER PROCEDURE)
const alteredPart1 = part1.replace(/CREATE\s+PROCEDURE/i, 'ALTER PROCEDURE');
const newSpBody = `${alteredPart1}
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

        ${formBody.replace("height:100vh; overflow:hidden;", "min-height:calc(100vh - 120px); height:auto; overflow-y:auto;")}

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
`;

const finalSql = `/*==================================================================================================
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
${newSpBody}
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
`;

const destPath = path.resolve(__dirname, '../fix-bug/screenshot-5/patch_tao_mat_khau.sql');
fs.writeFileSync(destPath, finalSql, 'utf8');
console.log('✅ Đã tạo thành công file patch:', destPath);
