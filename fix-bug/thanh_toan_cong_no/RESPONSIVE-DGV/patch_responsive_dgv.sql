/*==================================================================================================
  PARADISE HRM - PATCH: MENU THANH TOÁN CÔNG NỢ (MnuPRL409)
  SỬA LỖI: DATAGRID KHÔNG RESPONSIVE & LỖI LỆCH TÊN BẢNG CACHE HTML
  
  * Stored Procedure 1: [dbo].[sp_Debt_PaymentDebt_html] (Mã nguồn HTML & JS cấu hình 8 cột DataGrid)
  * Stored Procedure 2: [dbo].[sp_Debt_PaymentDebt] (Thủ tục điều phối nạp HTML trên Web)
  * Thủ tục biên dịch:  [dbo].[sp_GenerateHTMLScript]
  
  * NGUYÊN NHÂN CỐT LÕI VÌ SAO CHẠY XONG MÀ WEB VẪN KHÔNG ĐỔI:
      1. sp_GenerateHTMLScript khi chạy đã tự động cắt bỏ chữ '_html' (set @ProcName = REPLACE(@ProcName,'_html',''))
         và lưu mã HTML mới vào bảng [tblHtmlScriptCache] với TableName = 'sp_Debt_PaymentDebt'.
      2. Trong khi đó, thủ tục sp_Debt_PaymentDebt trên Web lại đang SELECT theo TableName = 'sp_Debt_PaymentDebt_html'
         (vẫn còn chữ _html).
      3. Dẫn đến Web tiếp tục đọc dòng cache CŨ (chưa có responsive), còn dòng cache MỚI thì nằm ở TableName = 'sp_Debt_PaymentDebt'!
      
  * HƯỚNG DẪN THỰC THI TRÊN SSMS:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse thành công 100%).
      3. Bấm F5 để thực thi (Execute).
      4. Quay lại Chrome, nhấn Ctrl + F5 để xóa cache trình duyệt.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN SP_DEBT_PAYMENTDEBT_HTML (CHIA ĐỀU TỶ LỆ 8 CỘT)
--------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_Debt_PaymentDebt_html]
 @LoginID INT = NULL,
 @LanguageID VARCHAR(2) = 'VN',
 @isWeb INT = 1
AS
BEGIN
 SET NOCOUNT ON;

 DECLARE @html NVARCHAR(MAX);
 SET @html = N'
<style>
    /* --- CSS SYSTEM VARS (Giữ nguyên style của bạn) --- */
    :root {
        --training-primary: #2E7D32;
        --training-primary-dark: #167549ff;
        --training-danger: #E53935;
        --training-warning: #FBC02D;
    }

    #sp_payment_debt {
        margin-bottom: 3rem;
        font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
    }

    #sp_payment_debt .header-section {
        border-bottom: 2px solid rgba(128, 128, 128, 0.2);
    }

    /* Buttons Main */
    #sp_payment_debt .btn-add {
        background: var(--training-primary);
        color: white;
        border: none;
        transition: all 0.2s;
    }

    #sp_payment_debt .btn-add:hover {
        background: var(--training-primary-dark);
        transform: translateY(-2px);
    }

    /* Search & Filter Inputs */
    #sp_payment_debt .search-box {
        position: relative;
        flex: 1;
    }

    #sp_payment_debt .search-icon {
        position: absolute;
        width: 0;
        left: 1rem;
        top: 50%;
        transform: translateY(-50%);
        opacity: 0.6;
    }

    #sp_payment_debt .search-input {
        padding-left: 2.5rem !important;
    }

    /* Grid Styling */
    #sp_payment_debt .grid-container {
        border-radius: 12px;
        overflow: hidden;
        border: 2px solid rgba(128, 128, 128, 0.2);
    }

    #sp_payment_debt .dx-datagrid {
        border: none !important;
        background: unset;
    }

    #sp_payment_debt .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 1rem !important;
        height: 60px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }

    #sp_payment_debt .dx-datagrid-row>td {
        padding: 0.75rem 1rem !important;
        vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }

    /* Status Badges */
    #sp_payment_debt .badge-status {
        padding: 0.25rem 0.75rem;
        border-radius: 999px;
        font-size: 0.75rem;
        font-weight: 700;
        display: inline-block;
    }

    #sp_payment_debt .badge-paid {
        background: rgba(46, 125, 50, 0.15);
        color: var(--training-primary);
    }

    #sp_payment_debt .badge-unpaid {
        background: rgba(229, 57, 53, 0.15);
        color: var(--training-danger);
    }

    #sp_payment_debt .badge-partial {
        background: rgba(251, 192, 45, 0.15);
        color: var(--training-warning);
    }

    #sp_payment_debt .btn-collect-inline {
        background: rgba(46, 125, 50, 0.1);
        color: var(--training-primary);
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 600;
    }

    #sp_payment_debt .btn-collect-inline:hover {
        background: rgba(46, 125, 50, 0.2);
        transform: translateY(-1px);
    }

    #sp_payment_debt .payment-history-item {
        padding: 1rem;
        border: 1px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
        margin-bottom: 0.75rem;
    }

    #sp_payment_debt .btn-edit-inline {
        background: rgba(2, 136, 209, 0.1);
        color: #0288D1;
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
    }

    #sp_payment_debt .btn-edit-inline:hover {
        background: rgba(2, 136, 209, 0.2);
        transform: translateY(-1px);
    }

    #sp_payment_debt .btn-pay-inline {
        background: rgba(46, 125, 50, 0.1);
        color: var(--training-primary);
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 600;
    }

    #sp_payment_debt .btn-pay-inline:hover {
        background: rgba(46, 125, 50, 0.2);
        transform: translateY(-1px);
    }

    #sp_payment_debt .qr-code-container {
        text-align: center;
        padding: 1.5rem;
        background: #f8f9fa;
        border-radius: 12px;
        margin: 1rem 0;
    }

    #sp_payment_debt .qr-code-container img {
        max-width: 250px;
        width: 100%;
        height: auto;
        border: 2px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
    }

    /* PayOS Embedded Container */
    #sp_payment_debt #payos-embedded-container {
        width: 100%;
        min-height: 600px;
        border-radius: 8px;
        overflow: hidden;
        background: #f8f9fa;
    }

    #sp_payment_debt #payos-checkout-iframe {
        width: 100%;
        min-height: 600px;
        border: none;
        border-radius: 8px;
    }

    /* Modal Styles */
    #sp_payment_debt .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.7);
        z-index: 1050;
        align-items: center;
        justify-content: center;
        padding: 1rem;
    }

    #sp_payment_debt .modal-overlay.show {
        display: flex;
    }

    #sp_payment_debt .modal-content {
        background: var(--bs-body-bg, white);
        color: var(--bs-body-color, black);
        border-radius: 16px;
        max-width: 800px;
        width: 100%;
        max-height: 85vh;
        margin-top: 60px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
    }

    #sp_payment_debt .modal-header-custom {
        padding: 1.5rem;
        border-bottom: 1px solid rgba(128, 128, 128, 0.2);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    #sp_payment_debt .modal-body {
        flex: 1;
        overflow-y: auto;
        padding: 1.5rem;
    }

    #sp_payment_debt .modal-buttons {
        position: sticky;
        bottom: 0;
        background: var(--bs-body-bg, white);
        border-top: 1px solid rgba(128, 128, 128, 0.2);
        padding: 1rem 1.5rem;
        display: flex;
        justify-content: flex-end;
        gap: 0.5rem;
    }

    /* Inputs */
    #sp_payment_debt .form-label {
        font-weight: 600;
        margin-bottom: 0.5rem;
        display: block;
    }

    #sp_payment_debt .form-control,
    #sp_payment_debt .form-select {
        border: 2px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
        padding: 0.625rem;
        width: 100%;
    }

    #sp_payment_debt .form-control:focus,
    #sp_payment_debt .form-select:focus {
        border-color: var(--training-primary);
        outline: none;
    }

    #sp_payment_debt .form-control:disabled,
    #sp_payment_debt .form-select:disabled {
        background-color: rgba(128, 128, 128, 0.1);
        cursor: not-allowed;
        opacity: 0.7;
    }

    #sp_payment_debt textarea.form-control {
        min-height: 80px;
        resize: vertical;
    }

    #sp_payment_debt .btn-close-modal {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        border: none;
        background: transparent;
        cursor: pointer;
        font-size: 1rem;
    }

    #sp_payment_debt .btn-close-modal:hover {
        background: rgba(128, 128, 128, 0.1);
    }

    #sp_payment_debt .btn {
        font-size: 1rem;
        padding: 0.65rem 1.25rem;
        font-weight: 500;
        border-radius: 8px;
        border: none;
        cursor: pointer;
    }

    #sp_payment_debt .btn-success {
        background-color: var(--training-primary);
        color: #fff;
    }

    #sp_payment_debt .btn-danger {
        background-color: var(--training-danger);
        color: #ffffff;
    }

    #sp_payment_debt .btn-primary {
        background-color: #0288D1;
        color: #fff;
    }

    #sp_payment_debt .btn-primary:hover {
        background-color: #0277BD;
    }

    /* Import Button Styling */
    #sp_payment_debt #import-excel-fileuploader-container {
        background-color: var(--training-primary);
        border: none;
        box-shadow: 0 2px 4px rgba(46, 125, 50, 0.2);
    }

    #sp_payment_debt #import-excel-fileuploader-container:hover {
        background-color: var(--training-primary-dark);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(46, 125, 50, 0.3);
    }

    #sp_payment_debt #import-excel-fileuploader-container:active {
        transform: translateY(0);
        box-shadow: 0 2px 4px rgba(46, 125, 50, 0.2);
    }

    /* Desktop only elements */
    #sp_payment_debt .desktop-only {
        display: block;
    }

    @media (max-width: 768px) {
        #sp_payment_debt .modal-content {
            margin-top: 20px;
            max-height: 90vh;
        }

        #sp_payment_debt .modal-buttons {
            padding: 1rem;
            flex-direction: column-reverse;
        }

        #sp_payment_debt .modal-body {
            padding: 1rem;
        }

        #sp_payment_debt .btn {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        #sp_payment_debt .header-section {
            display: none;
        }

        /* Ẩn header desktop trên mobile */
        #sp_payment_debt #modal-debt-delete {
            display: none !important;
        }

        #sp_payment_debt .desktop-only {
            display: none !important;
        }

        /* Ẩn các phần tử desktop-only trên mobile */
    }

    /* DARK MODE OVERRIDES CHO THANH TOÁN CÔNG NỢ */
    [data-bs-theme="dark"] .header-title-custom, body.dark-mode .header-title-custom { color: #0ecb81 !important; }
    [data-bs-theme="dark"] #dp_search_input, body.dark-mode #dp_search_input { background: #1e2329 !important; color: #eaecef !important; border-color: #2b313a !important; }
    [data-bs-theme="dark"] #dp_filter_status, body.dark-mode #dp_filter_status { background: #1e2329 !important; color: #eaecef !important; border-color: #2b313a !important; }
    [data-bs-theme="dark"] .grid-container, body.dark-mode .grid-container { background: transparent !important; }
</style>
<div id="sp_payment_debt">
    <div class="header-section pb-3 mb-4">
        <div
            class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3">
            <div>
                <h3 class="mb-1 fw-bold"><i class="bi bi-credit-card me-2"></i>%PaymentPortal_Title%</h3>
                <p class="mb-0 opacity-75">%PaymentPortal_Desc%</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-light border" onclick="loadDebtPaymentData()">
                    <i class="bi bi-arrow-clockwise me-1"></i>%Common_Refresh%
                </button>
            </div>
        </div>
    </div>
    <div class="mb-4">
        <div class="row g-3">
            <div class="col-md-8">
                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" class="form-control search-input" id="dp_search_input"
                        placeholder="%Debt_SearchPlaceholder%">
                </div>
            </div>
            <div class="col-md-4">
                <select class="form-select" id="dp_filter_status">
                    <option value="" selected> %Debt_AllStatus% </option>
                    <option value="0"> %Debt_UnpaidStatusOption%</option>
                    <option value="1"> %Debt_PaidStatusOption%</option>
                </select>
            </div>
        </div>
    </div>
    <div class="grid-container">
        <div id="dp_loading" class="text-center py-5" style="display: none;">
            <div class="spinner-border text-success" role="status"></div>
            <p class="mt-3">%Debt_LoadingData%</p>
        </div>
        <div id="dp_grid_container" style="display: none;">
            <div id="dp_grid"></div>
        </div>
        <div id="dp_empty" class="text-center py-5" style="display: none;">
            <div class="empty-state">
                <div style="font-size: 3rem; opacity: 0.3; margin-bottom: 1rem;"><i class="bi bi-clipboard-x"></i></div>
                <p>%Debt_NoData%</p>
                <button class="btn btn-success" id="dp_empty_add_btn">%Debt_CreateNowButton%</button>
            </div>
        </div>
    </div>
    <div class="modal-overlay" id="dp_modal_detail">
        <div class="modal-content" onclick="event.stopPropagation()">
            <div class="modal-header-custom">
                <div class="d-flex align-items-center gap-2">
                    <h5 class="mb-0 fw-bold" id="modal-debt-title">%Debt_DebtInfoTitle%</h5>
                    <span id="modal-debt-header-badge" style="display: none;"></span>
                </div>
                <button type="button" class="btn-close-modal" id="dp_close_detail"><i class="bi bi-x-lg"></i></button>
            </div>
            <form id="dp_detail_form" style="display: flex; flex-direction: column; flex: 1; min-height: 0;">
                <div class="modal-body">
                    <input type="hidden" id="dp-rec-id" value="">
                    <!-- Import Excel Section (chỉ hiển thị khi thêm mới) -->
                    <!-- Summary Section (chỉ hiển thị khi xem công nợ đã thanh toán) -->
                    <div id="dp-debt-summary" class="mb-3 p-3 rounded"
                        style="display: none; background: rgba(128, 128, 128, 0.05);">
                        <div class="row mb-2">
                            <div class="col-6">
                                <label class="form-label text-muted small mb-1">%Debt_CustomerLabel%</label>
                                <div class="fw-bold" id="summary-customer-name">-</div>
                            </div>
                            <div class="col-6">
                                <label class="form-label text-muted small mb-1">%Debt_TotalDebtLabel%</label>
                                <div class="fw-bold text-danger" id="summary-total-debt">0 VNĐ</div>
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-6">
                                <label class="form-label text-muted small mb-1">%Debt_PaidAmountLabel%</label>
                                <div class="fw-bold text-success" id="summary-paid-amount">0 VNĐ</div>
                            </div>
                            <div class="col-6">
                                <label class="form-label text-muted small mb-1">%Debt_RemainingDebtLabel%</label>
                                <div class="fw-bold text-warning" id="summary-remaining-debt">0 VNĐ</div>
                            </div>
                        </div>
                        <div class="row" id="summary-payment-date-row" style="display: none;">
                            <div class="col-12">
                                <label class="form-label text-muted small mb-1">%Debt_PaymentDateLabel%</label>
                                <div class="fw-bold" id="summary-payment-date">-</div>
                            </div>
                        </div>
                    </div>
                    <div class="row g-3">
                        <!-- Ngày tạo (readonly - từ server) -->
                        <div class="col-md-6" style="display: none !important;">
                            <label class="form-label">%Col_CreateDate%</label>
                            <input type="date" class="form-control" id="dp-created-date" readonly
                                style="background-color: #f5f5f5; cursor: not-allowed;">
                            <small class="text-muted">%Msg_AutoSystem%</small>
                        </div>
                        <!-- Ngày hết hạn (chọn tháng-năm) -->
                        <div class="col-md-6">
                            <label class="form-label">%Col_ExpiryDate% <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" id="dp-expiry-date" required
                                placeholder="%Ph_SelectExpiryDate%">
                        </div>
                        <!-- Thông tin khách hàng -->
                        <div class="col-md-6">
                            <label class="form-label">%Debt_CustomerCodeLabel% <span
                                    class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="dp-cust-code" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_CustomerNameLabel% <span
                                    class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="dp-cust-name" required maxlength="100"
                                placeholder="%Debt_CustomerNameExample%" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_PhoneLabel%</label>
                            <input type="text" class="form-control" id="dp-cust-phone" maxlength="20"
                                placeholder="09xxxx" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_AddressLabel%</label>
                            <input type="text" class="form-control" id="dp-cust-address" maxlength="255"
                                placeholder="%Debt_ContactAddress%" readonly>
                        </div>
                        <div class="col-12">
                            <hr class="opacity-25 my-1">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_DebtTypeLabel% <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="dp-debt-type" list="dp-debt-types" required
                                maxlength="50" placeholder="%Debt_DebtTypeExample%">
                            <datalist id="dp-debt-types">
                                <option value="Tiền điện">
                                <option value="Tiền nước">
                                <option value="Tín dụng">
                                <option value="Dịch vụ">
                            </datalist>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_AmountLabel% <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="dp-amount" required
                                placeholder="%Debt_EnterAmount%" inputmode="numeric">
                        </div>
                        <!-- Tùy chọn thanh toán -->
                        <div class="col-md-6">
                            <label class="form-label">%Col_PaymentType% <span class="text-danger">*</span></label>
                            <select class="form-select" id="dp-payment-type" required>
                                <option value="">-- %Ph_SelectPaymentType% --</option>
                                <option value="FULL">%Opt_FullPayment%</option>
                                <option value="PARTIAL">%Opt_PartialPayment%</option>
                                <option value="BOTH">%Opt_FlexiblePayment%</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Col_PaymentMethod% <span class="text-danger">*</span></label>
                            <select class="form-select" id="dp-payment-method" required>
                                <option value="">-- %Ph_SelectMethod% --</option>
                                <option value="CASH">%Opt_Cash%</option>
                                <option value="PAYOS">PayOS</option>
                                <option value="BOTH">%Opt_FlexiblePayment%</option>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">%Cfg_PayOS_Content%</label>
                            <textarea class="form-control" id="dp-note" maxlength="25"
                                placeholder="%Msg_PayOS_DefaultContent%"></textarea>
                            <small class="text-muted">%Msg_PayOS_LimitNote%.</small>
                        </div>
                    </div>
                    <!-- Payment History Section -->
                    <div class="col-12 mt-3">
                        <hr class="opacity-25">
                        <h6 class="fw-bold mb-2">%Title_PaymentHistory%</h6>
                        <div id="dp_history_container"></div>
                    </div>
                </div>
                <div class="modal-buttons">
                    <button type="button" class="btn btn-success" id="dp_btn_pay_now">
                        <i class="bi bi-credit-card me-2"></i>%Btn_PayNow%
                    </button>
                    <!-- Vùng hướng dẫn -->
                    <div id="dp_pay_msg" class="text-danger ms-3 mt-2"
                        style="display:none; width: 100%; text-align: right;"></div>
                </div>
            </form>
        </div>
    </div>
    <!-- Modal Thanh toán PayOS -->
    <div class="modal-overlay" id="dp_modal_payos">
        <div class="modal-content" onclick="event.stopPropagation()" style="max-width: 600px;">
            <div class="modal-header-custom">
                <h5 class="mb-0 fw-bold"><i class="bi bi-qr-code me-2"></i>%Debt_PayOSPaymentModalTitle%</h5>
                <button type="button" class="btn-close-modal" id="dp_close_payos"><i class="bi bi-x-lg"></i></button>
            </div>
            <div class="modal-body">
                <div id="dp_pay_info">
                    <div class="mb-3">
                        <label class="form-label text-muted">%Debt_CustomerLabel%</label>
                        <div class="fw-bold" id="payment-customer-name">-</div>
                    </div>
                </div>
                <div id="dp_pay_input_sec">
                    <div class="mb-3">
                        <label class="form-label text-muted">%Debt_AmountToPayLabel%</label>
                        <input type="text" class="form-control fs-4 text-danger fw-bold" id="dp_pay_amount"
                            inputmode="numeric" placeholder="0">
                        <small class="text-muted" id="dp_pay_hint"></small>
                    </div>
                    <button type="button" class="btn btn-success w-100 py-2 mb-3" id="dp_btn_create_qr">
                        <i class="bi bi-qr-code me-2"></i>%Debt_CreatePaymentCode%
                    </button>
                </div>
                <div id="dp_pay_loading" class="text-center py-4" style="display: none;">
                    <div class="spinner-border text-success" role="status"></div>
                    <p class="mt-3">%Debt_CreatingPaymentCode%</p>
                </div>
                <div id="dp_pay_qr_container" style="display: none;">
                    <!-- Container cho PayOS Embedded -->
                    <div id="dp_payos_embed_container" style="min-height: 400px;"></div>
                </div>
                <div id="dp_pay_error" style="display: none;">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        <span id="dp_pay_error_msg">%Debt_PaymentCodeError%</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src=''https://cdn.payos.vn/payos-checkout/v1/stable/payos-initialize.js''></script>
<script>
    (() => {
        // --- VARIABLES ---
        var debtList = [];
        var gridInstance = null;
        var editingId = null; // null = Add, number = Edit RecordID
        var editingHasHistory = false; // Đã có lịch sử thu hồi?
        var editingOriginalAmount = 0; // Lưu số tiền gốc để chặn chỉnh sửa khi có lịch sử
        var currentPaymentDebt = null; // Lưu thông tin công nợ đang thanh toán
        var payosPollingInterval = null;
        var payosPollingAttempts = 0;
        var payosMaxPollingAttempts = 120; // 10 phút
        var payosLastOrderCode = null;
        var payosPaymentWindow = null;
        var payosPopupWatcher = null;
        var payosPopupJustClosed = false; // Flag để biết popup vừa đóng
        var payosEmbeddedInstance = null; // Instance của PayOS embedded
        function showLoading() { document.getElementById("dp_loading").style.display = "block"; }

        function hideLoading() { document.getElementById("dp_loading").style.display = "none"; }

        function isMobileAndTablet() {
            return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || window.innerWidth < 1024;
        }

        // --- 1. LOAD DATA (Read) ---
        function loadDebtPaymentData() {
            showLoading();

            // Lấy LoginID của user hiện tại
            var currentUserId = (typeof ParadiseOption !== ''undefined'') ? ParadiseOption.LoginID : null;

            // Gọi Store: sp_DebtPayment_Select
            // Lấy filter status từ UI nếu có
            var filterStatus = document.getElementById("dp_filter_status") ? document.getElementById("dp_filter_status").value : null;

            // Build params động
            var params = ["LoginID", currentUserId];
            if (filterStatus !== "" && filterStatus !== null) {
                params.push("Status");
                params.push(filterStatus);
            }

            AjaxHPAParadise({
                data: { name: "sp_DebtPayment_Select", param: params },
                success: function (res) {
                    hideLoading();

                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                        debtList = Array.isArray(data) ? data : [];
                        renderGrid();
                    } catch (e) { console.error("Parse Error", e); }
                },
                error: function (err) { hideLoading(); console.error("API Error", err); },
                complete: function () { hideLoading(); }
            });
        }

        window.loadDebtPaymentData = loadDebtPaymentData;

        // --- 1.1 LOAD PAYMENT HISTORY ---
        function loadPaymentHistory(recordId, callback) {
            AjaxHPAParadise({
                data: { name: "sp_Debt_GetPaymentHistory", param: ["RecordID", recordId] },
                success: function (res) {
                    hideLoading();

                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                        var history = Array.isArray(data) ? data : [];
                        if (callback) callback(history);
                    } catch (e) {
                        console.error("Parse Error History", e);
                        if (callback) callback([]);
                    }
                },
                error: function (err) {
                    console.error("API Error History", err);
                    if (callback) callback([]);
                }
            });
        }

        // --- Helper: Chuẩn hóa chuỗi tiếng Việt (bỏ dấu) ---
        function removeVietnameseTones(str) {
            if (!str) return '''';
            str = str.toLowerCase();
            str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
            str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
            str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
            str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
            str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
            str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
            str = str.replace(/đ/g, "d");

            str = str.replace(/\u0300|\u0301|\u0303|\u0309|\u0323/g, ""); // Huyền, sắc, ngã, hỏi, nặng

            str = str.replace(/\u02C6|\u0306|\u031B/g, ""); // Â, Ê, Ă, Ơ, Ư

            return str;
        }

        // --- 2. RENDER DEVEXTREME GRID ---
        function renderGrid() {
            hideLoading();
            var searchText = removeVietnameseTones(document.getElementById("dp_search_input").value);
            var filterStatus = document.getElementById("dp_filter_status").value; // "0", "1" or ""

            // Filter Logic ở Client (để nhanh hơn, hoặc bạn có thể gọi API lại)
            var filteredData = debtList.filter(item => {
                var sText = (item.CustomerName || '''') + '' '' + (item.CustomerCode || '''');
                var normalizedText = removeVietnameseTones(sText);
                var matchText = normalizedText.includes(searchText);
                var matchStatus = true;
                if (filterStatus !== "") {
                    matchStatus = (item.Status == filterStatus);
                }

                return matchText && matchStatus;
            });

            // Toggle Empty State
            if (filteredData.length === 0 && debtList.length === 0) {
                document.getElementById("dp_grid_container").style.display = "none";
                document.getElementById("dp_empty").style.display = "block";
                return;
            }

            document.getElementById("dp_grid_container").style.display = "block";
            document.getElementById("dp_empty").style.display = "none";

            // Init DataGrid
            if (gridInstance) {
                gridInstance.option("dataSource", filteredData);
            } else {
                gridInstance = $("#dp_grid").dxDataGrid({
                    dataSource: filteredData,
                    keyExpr: "RecordID", // Khóa chính của bảng

                    showBorders: false,
                    showRowLines: true,
                    showColumnLines: false,
                    hoverStateEnabled: true,
                    columnAutoWidth: true,
                    allowColumnResizing: true,
                    columnResizingMode: "widget",
                    columnHidingEnabled: true,
                    wordWrapEnabled: false,
                    noDataText: "%Debt_NoData%",
                    paging: { pageSize: 15 },
                    pager: { showPageSizeSelector: true, allowedPageSizes: [15, 30, 50], showInfo: true, visible: true },
                    columns: [
                        {
                            caption: "%Debt_CustomerLabel%",
                            minWidth: 180,
                            width: "18%",
                            hidingPriority: 8,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                $("<div>").addClass("fw-bold text-truncate").attr("title", d.CustomerName).text(d.CustomerName).appendTo(container);
                                $("<div>").addClass("small opacity-75").text(d.CustomerCode).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_DebtTypeLabel%",
                            dataField: "DebtType",
                            minWidth: 140,
                            width: "13%",
                            hidingPriority: 5,
                            cellTemplate: function (container, options) {
                                var val = options.value || "";
                                $("<div>").addClass("text-truncate").attr("title", val).text(val).appendTo(container);
                            }
                        },
                        {
                            dataField: "Amount",
                            caption: "%Debt_TotalDebtLabel%",
                            minWidth: 130,
                            width: "11%",
                            alignment: "right",
                            format: "#,##0",
                            hidingPriority: 6
                        },
                        {
                            caption: "%Debt_PaidAmountLabel%",
                            minWidth: 110,
                            width: "9%",
                            alignment: "right",
                            hidingPriority: 3,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var paidAmount = d.PaidAmount || 0;
                                $("<div>").addClass("text-success fw-bold").text(formatNumber(paidAmount)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_RemainingDebtLabel%",
                            minWidth: 110,
                            width: "10%",
                            alignment: "right",
                            hidingPriority: 7,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                $("<div>").addClass("text-danger fw-bold").text(formatNumber(remaining)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Contact%",
                            minWidth: 140,
                            width: "13%",
                            hidingPriority: 2,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                if (d.PhoneNumber) $("<div>").html(`<i class="bi bi-telephone me-1"></i>${d.PhoneNumber}`).appendTo(container);
                                if (d.Address) $("<div>").addClass("small text-truncate").attr("title", d.Address).text(d.Address).appendTo(container);
                            }
                        },
                        {
                            dataField: "Status",
                            caption: "%Status%",
                            minWidth: 130,
                            width: "13%",
                            alignment: "center",
                            hidingPriority: 4,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                var statusFromDB = d.Status || 0;

                                var badgeClass, text;
                                if (statusFromDB === 1) {
                                    badgeClass = "badge-paid";
                                    text = "%Debt_PaidStatus%";
                                } else {
                                    var isFullyPaid = remaining <= 0 && paidAmount > 0;
                                    var isPartiallyPaid = paidAmount > 0 && remaining > 0;
                                    if (isFullyPaid) {
                                        badgeClass = "badge-paid";
                                        text = "%Debt_PaidStatus%";
                                    } else if (isPartiallyPaid) {
                                        badgeClass = "badge-partial";
                                        text = "%Debt_PartialPaidStatus%";
                                    } else {
                                        badgeClass = "badge-unpaid";
                                        text = "%Debt_UnpaidStatus%";
                                    }
                                }

                                $("<span>").addClass("badge-status " + badgeClass).text(text).appendTo(container);
                            }
                        },
                        {
                            dataField: "ExpiryDate",
                            caption: "%Debt_ExpiryDateLabel%",
                            alignment: "center",
                            minWidth: 130,
                            width: "13%",
                            hidingPriority: 1,
                            cellTemplate: function (container, options) {
                                var val = options.value;
                                if (val) {
                                    var d = new Date(val);
                                    if (!isNaN(d.getTime())) {
                                        var day = String(d.getDate()).padStart(2, ''0'');
                                        var month = String(d.getMonth() + 1).padStart(2, ''0'');
                                        var year = d.getFullYear();
                                        $("<div>").text(day + ''/'' + month + ''/'' + year).appendTo(container);
                                    } else {
                                        $("<div>").text(val).appendTo(container);
                                    }
                                } else {
                                    $("<div>").text("-").appendTo(container);
                                }
                            }
                        }
                    ],
                    onRowClick: function (e) { openEditModal(e.data.RecordID); }
                }).dxDataGrid("instance");
            }
        }

        // --- Helper: Enable/Disable form inputs ---
        function setFormInputsEnabled(enabled) {
            var inputs = [
                "dp-cust-code",
                "dp-cust-name",
                "dp-cust-phone",
                "dp-cust-address",
                "dp-debt-type",
                "dp-amount",
                "dp-note"
            ];

            inputs.forEach(function (inputId) {
                var input = document.getElementById(inputId);
                if (input) {
                    input.disabled = !enabled;
                }
            });
        }

        // --- 3. OPEN MODAL (View & Pay) ---
        function openEditModal(id) {
            // Chỉ xem và thanh toán, không thêm mới
            if (!id) return;
            var item = debtList.find(x => x.RecordID === id);
            if (!item) return;
            // 1. Fill Info (Read-only)
            document.getElementById("dp-cust-code").value = item.CustomerCode;
            document.getElementById("dp-cust-name").value = item.CustomerName;
            document.getElementById("dp-cust-phone").value = item.PhoneNumber || "";
            document.getElementById("dp-cust-address").value = item.Address || "";
            document.getElementById("dp-debt-type").value = item.DebtType;
            document.getElementById("dp-amount").value = formatNumber(item.Amount);
            document.getElementById("dp-note").value = item.Note || "";
            if (item.CreatedDate) {
                var d = new Date(item.CreatedDate);
                var dateStr = d.getFullYear() + ''-'' + String(d.getMonth() + 1).padStart(2, ''0'') + ''-'' + String(d.getDate()).padStart(2, ''0'');
                var createdDateEl = document.getElementById("dp-created-date");
                if (createdDateEl) createdDateEl.value = dateStr;
            }

            if (item.ExpiryDate) {
                var d = new Date(item.ExpiryDate);
                if (!isNaN(d.getTime())) {
                    var dateStr = d.getFullYear() + ''-'' + String(d.getMonth() + 1).padStart(2, ''0'') + ''-'' + String(d.getDate()).padStart(2, ''0'');
                    document.getElementById("dp-expiry-date").value = dateStr;
                } else {
                    document.getElementById("dp-expiry-date").value = "";
                }
            } else {
                document.getElementById("dp-expiry-date").value = "";
            }

            document.getElementById("dp-payment-type").value = item.PaymentType || "";
            document.getElementById("dp-payment-method").value = item.PaymentMethod || "";

            // Xử lý hiển thị Customer Select (ẩn đi, hiện input text readonly)
            var sbInstance = null;
            try { sbInstance = $("#modal-cust-select").dxSelectBox("instance"); } catch (e) { }

            if (sbInstance) sbInstance.option("visible", false);
            var custCodeInput = document.getElementById("dp-cust-code");
            custCodeInput.style.display = "block";
            custCodeInput.readOnly = true;

            // Disable all fields
            setFormInputsEnabled(false);
            document.getElementById("dp-expiry-date").disabled = true;
            document.getElementById("dp-payment-type").disabled = true;
            document.getElementById("dp-payment-method").disabled = true;

            // 2. Setup Payment Logic
            var totalDebt = item.Amount || 0;
            var paidAmount = item.PaidAmount || 0;
            var remaining = totalDebt - paidAmount;
            var statusFromDB = item.Status || 0;
            var btnPay = document.getElementById("dp_btn_pay_now");
            var msgEl = document.getElementById("dp_pay_msg");

            // Reset state
            btnPay.style.display = "block";
            btnPay.disabled = false;
            msgEl.style.display = "none";
            msgEl.textContent = "";

            // Check đã thanh toán hết chưa
            if (statusFromDB === 1 || remaining <= 0) {
                btnPay.style.display = "none";
                msgEl.style.display = "block";
                msgEl.className = "text-success ms-3 mt-2";
                msgEl.textContent = "Khoản nợ này đã được thanh toán.";
            } else {
                // Check Payment Method
                if (item.PaymentMethod === "CASH") {
                    // Nếu chỉ cho phép tiền mặt -> Không thanh toán online được
                    // Có thể hiện nút "Xác nhận đã chuyển khoản" hoặc chỉ hiện thông báo
                    btnPay.disabled = true;
                    msgEl.style.display = "block";
                    msgEl.className = "text-info ms-3 mt-2";
                    msgEl.textContent = "Vui lòng liên hệ bộ phận kế toán để thanh toán tiền mặt/chuyển khoản.";
                } else {
                    // PAYOS hoặc BOTH -> Cho phép thanh toán Online
                    btnPay.onclick = function () {
                        // Quy tắc PaymentType (FULL/PARTIAL) sẽ được xử lý trong logic PaymentModal (nếu dùng chung)
                        // Nhưng ở đây ta gọi trực tiếp openPaymentModal để mở giao diện PayOS
                        // Tuy nhiên openPaymentModal hiện tại được dùng cho PayOS QR.
                        // Ta cần đảm bảo số tiền thanh toán đúng quy tắc.
                        // Ở bước này, ta sẽ mở một modal nhỏ (confirm amount) HOẶC reuse collect modal?
                        // Đơn giản nhất: Mở modal nhập số tiền (nếu PARTIAL) hoặc confirm (nếu FULL)
                        // Reuse openPaymentModal của PayOS logic (đã có sẵn trong file testfinal, hy vọng nó còn ở đây)
                        prepareUserPayment(item);
                    };
                }
            }

            // 3. Load Payment History
            var historyContainer = document.getElementById("dp_history_container");
            if (historyContainer) {
                historyContainer.innerHTML = ''<div class="text-center py-2"><div class="spinner-border spinner-border-sm text-primary" role="status"></div></div>'';
                loadPaymentHistory(id, function (history) {
                    if (!history || history.length === 0) {
                        historyContainer.innerHTML = ''<div class="text-center py-2 text-muted small">%Msg_NoPaymentHistory%</div>'';
                        return;
                    }
                    var html = ''<div class="table-responsive text-nowrap" style="max-height: 200px; overflow-y: auto;">'' +
                        ''<table class="table table-sm table-hover mb-0" style="font-size: 0.9rem;">'' +
                        ''<thead class="table sticky-top"><tr>'' +
                        ''<th>Ngày</th>'' +
                        ''<th class="text-end">Số tiền</th>'' +
                        ''<th class="text-center">PTTT</th>'' +
                        ''<th>ND</th>'' +
                        ''</tr></thead><tbody>'';

                    history.forEach(function (h) {
                        var d = h.PaymentDate ? new Date(h.PaymentDate) : null;
                        var dateStr = d ? (d.getDate() + ''/'' + (d.getMonth() + 1) + ''/'' + d.getFullYear()) : ''-'';
                        var amount = formatNumber(h.Amount || 0);
                        var method = h.PaymentMethod || ''-'';
                        var note = h.Note || '''';
                        if (note.length > 20) note = note.substring(0, 20) + ''...'';
                        html += ''<tr>'' +
                            ''<td>'' + dateStr + ''</td>'' +
                            ''<td class="text-end text-success fw-bold">'' + amount + ''</td>'' +
                            ''<td class="text-center"><span class="badge bg-light text-dark border">'' + method + ''</span></td>'' +
                            ''<td title="'' + (h.Note || '''') + ''">'' + note + ''</td>'' +
                            ''</tr>'';
                    });
                    html += ''</tbody></table></div>'';
                    historyContainer.innerHTML = html;
                });
            }

            // Show Modal
            var modalEl = document.getElementById("dp_modal_detail");
            document.getElementById("modal-debt-title").textContent = "%Title_DebtDetails%";
            modalEl.classList.add("show");
        }

        function prepareUserPayment(item) {
            // Logic chuẩn bị thanh toán
            // Nếu FULL -> Set amount = remaining
            // Nếu PARTIAL -> Cho nhập (nhưng ở đây mình làm nhanh: Prompt user amount logic hoặc auto full)
            var totalDebt = item.Amount || 0;
            var paidAmount = item.PaidAmount || 0;
            var remaining = totalDebt - paidAmount;

            // Đơn giản hóa: Luôn mở PayOS modal với số tiền còn lại.
            // Nếu User muốn thanh toán 1 phần -> Cần UI để nhập.
            // Ta có thể dùng hàm `openPaymentModal` hiện tại (nó nhận `item` làm input).
            // Nhưng `openPaymentModal` trong testfinal.html lấy số tiền từ item.Amount.
            // Ta tạo một object copy và set Amount = remaining để thanh toán nốt.
            var payItem = Object.assign({}, item);
            payItem.Amount = remaining;

            // Nếu cho phép Partial, user có thể muốn sửa số tiền.
            // Hiện tại ta auto set Full remaining.
            document.getElementById("dp_modal_detail").classList.remove("show");
            openPaymentModal(payItem);
        }

        // --- 4. SUBMIT FORM (CREATE / UPDATE) ---
        // --- 5. DELETE ---
        // --- PAYOS: HELPER FUNCTIONS ---
        // Hàm HMAC SHA256 với fallback cho Android (crypto.subtle không hoạt động trên HTTP)
        function hmacSHA256PayOS(message, secret) {
            return new Promise(function (resolve, reject) {
                // Kiểm tra xem crypto.subtle có khả dụng không
                if (typeof crypto !== ''undefined'' && crypto.subtle && typeof crypto.subtle.importKey === ''function'') {
                    // Web Crypto API khả dụng (HTTPS hoặc localhost)
                    var encoder = new TextEncoder();
                    var keyData = encoder.encode(secret);
                    var messageData = encoder.encode(message);

                    crypto.subtle.importKey(''raw'', keyData, { name: ''HMAC'', hash: ''SHA-256'' }, false, [''sign''])
                        .then(function (cryptoKey) {
                            return crypto.subtle.sign(''HMAC'', cryptoKey, messageData);
                        })
                        .then(function (signature) {
                            var hex = Array.from(new Uint8Array(signature))
                                .map(function (b) { return b.toString(16).padStart(2, ''0''); })
                                .join('''');
                            resolve(hex);
                        })
                        .catch(function (err) {
                            console.error(''❌ [PayOS] Web Crypto API error:'', err);

                            // Thử fallback CryptoJS
                            tryFallbackCryptoJS(message, secret, resolve, reject);
                        });
                } else {
                    // Web Crypto API không khả dụng (HTTP trên Android)
                    console.warn(''⚠️ [PayOS] crypto.subtle không khả dụng. Thử dùng CryptoJS...'');
                    tryFallbackCryptoJS(message, secret, resolve, reject);
                }
            });

            function tryFallbackCryptoJS(message, secret, resolve, reject) {
                // Fallback: Sử dụng CryptoJS nếu có (thường đã load sẵn trong hệ thống)
                if (typeof CryptoJS !== ''undefined'' && CryptoJS.HmacSHA256) {
                    try {
                        var hash = CryptoJS.HmacSHA256(message, secret);
                        var hex = hash.toString(CryptoJS.enc.Hex);
                        console.log(''✅ [PayOS] Dùng CryptoJS fallback thành công'');
                        resolve(hex);
                    } catch (e) {
                        console.error(''❌ [PayOS] CryptoJS error:'', e);
                        reject(new Error(''Không thể tạo signature: '' + e.message));
                    }
                } else {
                    // Không có CryptoJS, báo lỗi rõ ràng
                    var errorMsg = ''Thiết bị không hỗ trợ mã hóa. Vui lòng sử dụng HTTPS hoặc trình duyệt khác.'';
                    console.error(''❌ [PayOS] '' + errorMsg);
                    reject(new Error(errorMsg));
                }
            }
        }

        // Cache PayOS config để không gọi API mỗi lần polling
        var _payosConfigCache = null;
        var _payosConfigCacheTime = 0;
        var PAYOS_CONFIG_CACHE_DURATION = 5 * 60 * 1000; // Cache trong 5 phút
        function getPayOSConfig() {
            return new Promise(function (resolve, reject) {
                // Kiểm tra cache còn hợp lệ không
                var now = Date.now();
                if (_payosConfigCache && (now - _payosConfigCacheTime) < PAYOS_CONFIG_CACHE_DURATION) {
                    resolve(_payosConfigCache);
                    return;
                }

                AjaxHPAParadise({
                    data: { name: "sp_Debt_PayOS_GetConfig", param: [] },
                    success: function (res) {
                    hideLoading();

                        try {
                            var parsed = JSON.parse(res);
                            if (parsed && parsed.result === ''error'') {
                                reject(new Error(parsed.reason || ''PayOS config not found''));
                                return;
                            }

                            if (parsed.data && parsed.data[0] && parsed.data[0][0]) {
                                // Lưu vào cache
                                _payosConfigCache = parsed.data[0][0];
                                _payosConfigCacheTime = Date.now();
                                resolve(_payosConfigCache);
                            } else {
                                reject(new Error(''PayOS config not found''));
                            }
                        } catch (e) { reject(e); }
                    },
                    error: function (err) { reject(new Error(''Failed to get PayOS config'')); }
                });
            });
        }

        function generatePayOSOrderCode() {
            var timestamp = new Date().getTime();
            var random = Math.floor(Math.random() * 9999);
            return (timestamp * 10000) + random;
        }

        // Hàm hủy thanh toán PayOS - sử dụng paymentLinkID
        function cancelPayOSPaymentLink(paymentLinkID, cancellationReason) {
            return getPayOSConfig().then(config => {
                if (!paymentLinkID) {
                    console.error(''❌ [PayOS] paymentLinkID is required for cancel'');
                    throw new Error(''paymentLinkID is required'');
                }

                cancellationReason = cancellationReason || "Hủy bỏ giao dịch";
                var url = config.ApiURL + paymentLinkID + ''/cancel'';
                console.log(''🚀 [PayOS] Bắn API Cancel:'', url, ''paymentLinkID:'', paymentLinkID, ''Lý do:'', cancellationReason);
                return fetch(url, {
                    method: ''POST'',
                    headers: {
                        ''Content-Type'': ''application/json'',
                        ''x-client-id'': config.ClientID,
                        ''x-api-key'': config.ApiKey,
                        ''x-partner-code'': config.PartnerCode
                    },
                    body: JSON.stringify({ cancellationReason: cancellationReason })
                }).then(function (response) {
                    console.log(''📩 [PayOS] Cancel Response Status:'', response.status);
                    if (!response.ok) {
                        return response.json().then(function (err) {
                            console.error(''❌ [PayOS] Lỗi HTTP:'', err);
                            throw new Error(err.desc || err.message || ''Lỗi HTTP khi hủy PayOS'');
                        }).catch(function () { throw new Error(''Lỗi kết nối PayOS''); });
                    }

                    return response.json();
                }).then(function (result) {
                    console.log(''📩 [PayOS] Cancel Result Body:'', JSON.stringify(result, null, 2));
                    if (result && (result.code === ''00'' || result.code === 0)) {
                        console.log(''✅ [PayOS] Cancel thành công - paymentLinkID:'', paymentLinkID, ''Data:'', result.data);
                        return result;
                    } else {
                        throw new Error((result && result.desc) || "Lỗi API PayOS: " + (result ? result.code : ''unknown''));
                    }
                });
            });
        }

        function createPayOSPaymentLink(orderData) {
            return getPayOSConfig().then(config => {
                var safeOrderCode = Number(orderData.orderCode);
                var safeAmount = Number(orderData.amount);
                var safeDesc = orderData.description || ''Thanh toan cong no'';
                var customerName = orderData.customerName || ''Khach hang'';
                if (safeDesc.length > 25) {
                    safeDesc = safeDesc.substring(0, 25);
                }

                var returnUrl = "";
                var cancelUrl = "";
                var dataToSign = "amount=" + safeAmount + "&" +
                    "cancelUrl=" + cancelUrl + "&" +
                    "description=" + safeDesc + "&" +
                    "orderCode=" + safeOrderCode + "&" +
                    "returnUrl=" + returnUrl;
                return hmacSHA256PayOS(dataToSign, config.ChecksumKey).then(signature => {
                    var payload = {
                        orderCode: safeOrderCode,
                        amount: safeAmount,
                        description: safeDesc,
                        cancelUrl: cancelUrl,
                        returnUrl: returnUrl,
                        signature: signature,
                        items: [{ name: customerName, quantity: 1, price: safeAmount }]
                    };
                    var apiUrl = config.ApiURL;
                    return fetch(apiUrl, {
                        method: ''POST'',
                        headers: {
                            ''Content-Type'': ''application/json'',
                            ''x-client-id'': config.ClientID,
                            ''x-api-key'': config.ApiKey,
                            ''x-partner-code'': config.PartnerCode
                        },
                        body: JSON.stringify(payload)
                    });
                }).then(response => response.json()).then(result => {
                    if (result.code === ''00'' && result.data) {
                        return {
                            checkoutUrl: result.data.checkoutUrl,
                            paymentLinkId: result.data.paymentLinkId,
                            orderCode: safeOrderCode
                        };
                    } else {
                        throw new Error(result.desc || ''Lỗi tạo link thanh toán (Code: '' + result.code + '')'');
                    }
                });
            });
        }

        function createDebtPayment() {
            console.log(''🏁 [PayOS] START createDebtPayment called!'');
            if (!currentPaymentDebt) return;
            var debtItem = currentPaymentDebt;

            // Simple validation
            var payAmountInput = document.getElementById("dp_pay_amount");
            if (!payAmountInput.value) {
                uiManager.showAlert({ type: "warning", message: "%Debt_EnterPaymentAmount%" });
                return;
            }

            var amountVal = document.getElementById("dp_pay_amount").value;
            var amount = parseInt(amountVal.replace(/,/g, '''')) || 0;
            if (amount <= 0) {
                uiManager.showAlert({ type: "warning", message: "%Debt_AmountMustBeGreaterThanZero%" });
                return;
            }

            var payBtn = document.getElementById("dp_btn_create_qr");
            var loadingDiv = document.getElementById("dp_pay_loading");
            var errorDiv = document.getElementById("dp_pay_error");
            var errorMsg = document.getElementById("dp_pay_error_msg");
            var container = document.getElementById("dp_payos_embed_container");

            // Req 1: Clear old QR
            container.innerHTML = "";
            payBtn.disabled = true;
            loadingDiv.style.display = "flex";
            errorDiv.style.display = "none";

            function removeVietnameseTones(str) {
                if (!str) return "";
                str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
                str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
                str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
                str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
                str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
                str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
                str = str.replace(/đ/g, "d");
                str = str.replace(/À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ/g, "A");
                str = str.replace(/È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ/g, "E");
                str = str.replace(/Ì|Í|Ị|Ỉ|Ĩ/g, "I");
                str = str.replace(/Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ/g, "O");
                str = str.replace(/Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ/g, "U");
                str = str.replace(/Ỳ|Ý|Ỵ|Ỷ|Ỹ/g, "Y");
                str = str.replace(/Đ/g, "D");
                str = str.replace(/[^a-zA-Z0-9 ]/g, "");
                return str.trim();
            }

            var description = "";
            var noteValue = (debtItem.Note || "").trim();
            if (noteValue && noteValue.length > 0) {
                // Có nội dung thanh toán PayOS → dùng nội dung đó (remove tones to be safe)
                description = removeVietnameseTones(noteValue).substring(0, 25);
            } else {
                // Không có nội dung thanh toán → mặc định điền DebtType (loại công nợ)
                var debtType = (debtItem.DebtType || "").trim();
                description = debtType ? removeVietnameseTones(debtType).substring(0, 25) : "Thanh toan cong no";
            }

            if (description.length > 25) {
                description = description.substring(0, 25);
            }

            if (!description) description = "Thanh toan no";
            var returnUrl = window.location.href.split(''?'')[0];
            var cancelUrl = returnUrl;

            // Gọi SP để tạo đơn hàng trong DB và LẤY OrderCode
            AjaxHPAParadise({
                data: {
                    name: "sp_Debt_PayOS_CreatePayment",
                    param: [
                        "RecordID", debtItem.RecordID,
                        "Amount", amount,
                        "CustomerCode", debtItem.CustomerCode,
                        "Description", description,
                        "LoginID", (typeof ParadiseOption !== ''undefined'') ? ParadiseOption.LoginID : null
                    ]
                },
                success: function (res) {
                    hideLoading();

                    try {
                        var parsed = JSON.parse(res);

                        // Log parsed response to debug
                        console.log(''📦 [PayOS] Create Response Full:'', parsed);
                        var resultRow = null;
                        if (parsed.data && parsed.data[0] && parsed.data[0][0]) {
                            resultRow = parsed.data[0][0];
                        } else if (Array.isArray(parsed) && parsed.length > 0) {
                            if (Array.isArray(parsed[0])) { resultRow = parsed[0][0]; }
                            else { resultRow = parsed[0]; }
                        }

                        // Lấy dataset 2: Danh sách mã cũ cần cancel
                        var cancelList = [];
                        if (parsed.data && parsed.data[1]) {
                            cancelList = parsed.data[1];
                        } else if (Array.isArray(parsed) && parsed.length > 1) {
                            cancelList = parsed[1];
                        }

                        console.log(''📦 [PayOS] Cancel List (Len:'', cancelList.length, ''):'', cancelList);
                        if (!resultRow || (resultRow.ResultCode !== 0 && resultRow.ResultCode !== "0")) {
                            throw new Error((resultRow && resultRow.Message) || "Lỗi tạo đơn hàng từ Server");
                        }

                        var secureOrderCode = resultRow.OrderCode;

                        // -- Hàm con: Tạo Payment Link --
                        function proceedToCreatePaymentLink() {
                            console.log(''🚀 [PayOS] Đang tiến hành tạo Payment Link Mới...'');
                            console.log(''📝 [PayOS] Creating Link with:'', { orderCode: secureOrderCode, amount: amount, desc: description });

                            createPayOSPaymentLink({
                                orderCode: secureOrderCode,
                                amount: amount,
                                description: description,
                                returnUrl: returnUrl,
                                cancelUrl: cancelUrl,
                                customerName: debtItem.CustomerName || ''KH''
                            })
                                .then(function (paymentData) {
                                    // Cập nhật CheckoutUrl vào DB
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_Debt_PayOS_UpdateCheckoutUrl",
                                            param: [
                                                "OrderCode", paymentData.orderCode,
                                                "CheckoutUrl", paymentData.checkoutUrl,
                                                "PaymentLinkID", paymentData.paymentLinkId
                                            ]
                                        },
                                        success: function () {
                                            // Lưu pending order để restore khi reload/focus lại trang
                                            try {
                                                localStorage.setItem(''payosPendingOrder'', paymentData.orderCode);
                                            } catch (e) { console.warn(''LocalStorage error:'', e); }
                                        },
                                        error: function () { console.warn("Failed to update checkout url db"); }
                                    });
                                    loadingDiv.style.display = "none";

                                    // Ẩn phần input khi đã tạo QR thành công (giống testList.html)
                                    var inputSection = document.getElementById("dp_pay_input_sec");
                                    if (inputSection) inputSection.style.display = "none";
                                    var qrDiv = document.getElementById("dp_pay_qr_container");
                                    if (qrDiv) qrDiv.style.display = "block";
                                    var checkoutUrl = paymentData.checkoutUrl;
                                    container.innerHTML = "";
                                    var iframe = document.createElement(''iframe'');
                                    iframe.src = checkoutUrl;
                                    iframe.id = ''payos-checkout-iframe'';
                                    iframe.style.cssText = ''width: 100%; min-height: 500px; border: none; border-radius: 8px;'';
                                    iframe.setAttribute(''allow'', ''payment'');

                                    // Lắng nghe message từ iframe (giống testfinal.html)
                                    var messageHandler = function (event) {
                                        // Chỉ xử lý message từ PayOS domain
                                        if (event.origin !== ''https://pay.payos.vn'' &&
                                            event.origin !== ''https://payos.vn'' &&
                                            !event.origin.includes(''payos'')) {
                                            return;
                                        }

                                        // Xử lý các sự kiện từ PayOS
                                        if (event.data && event.data.type) {
                                            if (event.data.type === ''PAYMENT_SUCCESS'' || event.data.status === ''PAID'') {
                                                stopPayOSPolling();
                                                window.removeEventListener(''message'', messageHandler);

                                                // Ẩn/Đóng modal thanh toán (nếu cần)
                                                // var paymentModal = document.querySelector(".modal.show");
                                                // if (paymentModal) $(paymentModal).modal(''hide'');
                                                // Gọi hàm xử lý thành công
                                                // Trong DebtPayment.html, logic success thường nằm trong polling checkPayOSStatusDirect.
                                                // Ta có thể gọi checkPayOSStatusDirect ngay lập tức
                                                checkPayOSStatusDirect(secureOrderCode);
                                            }
                                        }
                                    };
                                    window.addEventListener(''message'', messageHandler);
                                    container.appendChild(iframe);
                                    payosLastOrderCode = secureOrderCode;
                                    startPayOSPolling(secureOrderCode);
                                })
                                .catch(function (err) {
                                    loadingDiv.style.display = "none";
                                    payBtn.disabled = false;
                                    errorDiv.style.display = "block";
                                    errorMsg.textContent = err.message;

                                    // Hiển thị lại phần input khi có lỗi
                                    var inputSection = document.getElementById("dp_pay_input_sec");
                                    if (inputSection) inputSection.style.display = "block";
                                });
                        }

                        // -- Xử lý cancel mã cũ --
                        if (cancelList && cancelList.length > 0) {
                            console.log(''🔄 [PayOS] Tìm thấy'', cancelList.length, ''mã cũ cần hủy cho RecordID:'', debtItem.RecordID);
                            var cancelIndex = 0;
                            var cancelNextOldCode = function () {
                                if (cancelIndex >= cancelList.length) {
                                    console.log(''✅ [PayOS] Đã hủy xong tất cả mã cũ, đang tạo mã mới...'');
                                    proceedToCreatePaymentLink();
                                    return;
                                }

                                var item = cancelList[cancelIndex];
                                console.log(''🔄 [PayOS] Đang xử lý hủy item:'', item);
                                cancelIndex++;
                                if (item.PaymentLinkID) {
                                    cancelPayOSPaymentLink(item.PaymentLinkID, ''Tự động hủy - Đã tạo mã mới'')
                                        .then(function () {
                                            console.log(''✅ [PayOS] Đã hủy PayOS PaymentLinkID:'', item.PaymentLinkID);
                                            setTimeout(cancelNextOldCode, 1000);
                                        })
                                        .catch(function (err) {
                                            console.warn(''⚠️ [PayOS] Cancel thất bại:'', item.PaymentLinkID, err.message);
                                            setTimeout(cancelNextOldCode, 1000);
                                        });
                                } else {
                                    setTimeout(cancelNextOldCode, 100);
                                }
                            };

                            // Bắt đầu cancel
                            cancelNextOldCode();
                        } else {
                            // Không có mã cũ, tạo mới ngay
                            console.log(''ℹ️ [PayOS] Không có mã cũ nào cần hủy. Tiến hành tạo mới ngay.'');
                            proceedToCreatePaymentLink();
                        }
                    } catch (e) {
                        console.error(''❌ [PayOS] Error in success callback:'', e);
                        loadingDiv.style.display = "none";
                        payBtn.disabled = false;
                        errorDiv.style.display = "block";
                        errorMsg.textContent = e.message;

                        // Hiển thị lại phần input khi có lỗi
                        var inputSection = document.getElementById("dp_pay_input_sec");
                        if (inputSection) inputSection.style.display = "block";
                    }
                },
                error: function () {
                    loadingDiv.style.display = "none";
                    payBtn.disabled = false;
                    errorDiv.style.display = "block";
                    errorMsg.textContent = "%Debt_CreatePaymentError%";

                    // Hiển thị lại phần input khi có lỗi
                    var inputSection = document.getElementById("dp_pay_input_sec");
                    if (inputSection) inputSection.style.display = "block";
                }
            });
        }

        function checkPayOSPaymentStatus(orderCode) {
            return new Promise(function (resolve, reject) {
                AjaxHPAParadise({
                    data: { name: "sp_Debt_PayOS_CheckStatus", param: ["OrderCode", orderCode] },
                    success: function (res) {
                    hideLoading();

                        try {
                            var parsed = JSON.parse(res);
                            if (parsed.data && parsed.data[0] && parsed.data[0][0]) {
                                resolve(parsed.data[0][0]);
                            } else {
                                reject(new Error(''Order not found''));
                            }
                        } catch (e) { reject(e); }
                    },
                    error: function () { reject(new Error(''Failed to check status'')); }
                });
            });
        }

        function checkPayOSStatusDirect(orderCode) {
            if (!orderCode) return;
            getPayOSConfig().then(function (cfg) {
                var apiUrl = cfg.ApiURL;
                return fetch(apiUrl + ''/'' + orderCode, {
                    headers: {
                        ''x-client-id'': cfg.ClientID,
                        ''x-api-key'': cfg.ApiKey,
                        ''x-partner-code'': cfg.PartnerCode
                    }
                });
            }).then(function (res) { return res.json(); }).then(function (result) {
                var data = result && result.data;
                var status = data && data.status ? data.status.toUpperCase() : '''';

                // Chỉ gọi updatePayOSFullData khi status thay đổi thành PAID hoặc CANCELLED
                if (status === ''PAID'' || status === ''SUCCEEDED'' || status === ''SUCCESS'') {
                    updatePayOSFullData(result, function (success) {
                        if (!success) return;
                        stopPayOSPolling();
                        var paymentModal = document.getElementById("dp_modal_payos");
                        if (paymentModal) {
                            paymentModal.classList.remove("show");
                        }

                        confirmPayOSStatus(orderCode, "PAID");
                        try { localStorage.removeItem(''payosPendingOrder''); } catch (e) { }

                        handlePayOSSuccess({
                            OrderCode: orderCode,
                            Amount: (data && data.amount) || 0
                        });
                    });
                } else if (status === ''CANCELLED'') {
                    updatePayOSFullData(result, function (success) {
                        if (!success) return;
                        stopPayOSPolling();
                        var paymentModal = document.getElementById("dp_modal_payos");
                        if (paymentModal) {
                            paymentModal.classList.remove("show");
                        }

                        confirmPayOSStatus(orderCode, "CANCELLED");
                        try { localStorage.removeItem(''payosPendingOrder''); } catch (e) { }

                        handlePayOSCancelled({ OrderCode: orderCode });
                    });
                }

                // Nếu status là PENDING thì không làm gì, chờ poll tiếp
            }).catch(function (err) {
                if (err.message && (err.message.includes(''PayOS config not found'') ||
                    err.message.includes(''Order not found'') ||
                    err.message.includes(''404''))) {
                    return;
                }

                console.error(''PayOS direct status error:'', err);
            });
        }

        function updatePayOSFullData(payOSResponse, callback) {
            if (!payOSResponse || !payOSResponse.data) {
                if (callback) callback(false);
                return;
            }

            var data = payOSResponse.data;
            var orderCode = data.orderCode;
            if (!orderCode) {
                if (callback) callback(false);
                return;
            }

            var payOSPaymentLinkID = data.id || null;
            var status = data.status ? data.status.toUpperCase() : null;
            var amountPaid = data.amountPaid || null;
            var amountRemaining = data.amountRemaining || null;
            var payOSCreatedAt = data.createdAt ? new Date(data.createdAt).toISOString() : null;
            var canceledAt = data.canceledAt ? new Date(data.canceledAt).toISOString() : null;
            var cancellationReason = data.cancellationReason || null;
            var signature = payOSResponse.signature || null;
            var transactions = data.transactions ? JSON.stringify(data.transactions) : null;
            var checkoutUrl = data.checkoutUrl || null;
            var paymentLinkID = data.paymentLinkId || payOSPaymentLinkID || null;

            AjaxHPAParadise({
                data: {
                    name: "sp_Debt_PayOS_UpdateFullData",
                    param: [
                        "OrderCode", orderCode,
                        "CheckoutUrl", checkoutUrl,
                        "PaymentLinkID", paymentLinkID,
                        "PayOSPaymentLinkID", payOSPaymentLinkID,
                        "Status", status,
                        "AmountPaid", amountPaid,
                        "AmountRemaining", amountRemaining,
                        "PayOSCreatedAt", payOSCreatedAt,
                        "CanceledAt", canceledAt,
                        "CancellationReason", cancellationReason,
                        "Signature", signature,
                        "Transactions", transactions
                    ]
                },
                success: function (res) {
                    hideLoading();
                    if (status === ''PAID'') {
                        setTimeout(function () { if (callback) callback(true); }, 500);
                    } else {
                        if (callback) callback(true);
                    }
                },
                error: function (err) {
                    console.error("Error updating PayOS full data:", err);
                    if (callback) callback(false);
                }
            });
        }

        function confirmPayOSStatus(orderCode, newStatus) {
            var oc = orderCode || payosLastOrderCode;
            if (!oc) return;
            AjaxHPAParadise({
                data: { name: "sp_Debt_PayOS_ConfirmPayment", param: ["OrderCode", oc, "NewStatus", newStatus] },
                error: function () { /* console.error("ConfirmPayment failed for", oc, newStatus); */ }
            });
        }

        function startPayOSPolling(orderCode) {
            // console.log(''PayOS: Start polling for order:'', orderCode);
            payosPollingAttempts = 0;
            if (payosPollingInterval) clearInterval(payosPollingInterval);
            // Kiểm tra ngay lập tức
            checkPayOSStatus(orderCode);

            // Polling mỗi 5 giây để giảm tải request
            payosPollingInterval = setInterval(function () {
                payosPollingAttempts++;
                if (payosPollingAttempts > payosMaxPollingAttempts) {
                    stopPayOSPolling();

                    // Đóng modal khi hết thời gian
                    var paymentModal = document.getElementById("dp_modal_payos");
                    if (paymentModal) {
                        paymentModal.classList.remove("show");
                    }

                    uiManager.showAlert({ type: "warning", message: "%Debt_PaymentTimeout%" });
                    return;
                }

                checkPayOSStatus(orderCode);
            }, 5000); // Tăng từ 2 giây lên 5 giây để giảm tải
        }

        function stopPayOSPolling() {
            if (payosPollingInterval) {
                clearInterval(payosPollingInterval);
                payosPollingInterval = null;
            }

            payosPollingAttempts = 0;
        }

        function checkPayOSStatus(orderCode) {
            checkPayOSPaymentStatus(orderCode)
                .then(function (status) {
                    var st = (status.Status || status.status || '''').toString().trim().toUpperCase();
                    if (st === ''PAID'') {
                        stopPayOSPolling();

                        // Đóng modal ngay lập tức
                        var paymentModal = document.getElementById("dp_modal_payos");
                        if (paymentModal) {
                            paymentModal.classList.remove("show");
                        }

                        handlePayOSSuccess(status);
                    } else if (st === ''CANCELLED'') {
                        stopPayOSPolling();

                        // Đóng modal ngay lập tức
                        var paymentModal = document.getElementById("dp_modal_payos");
                        if (paymentModal) {
                            paymentModal.classList.remove("show");
                        }

                        handlePayOSCancelled(status);
                    } else {
                        checkPayOSStatusDirect(orderCode);
                    }
                })
                .catch(function (error) {
                    // Không log lỗi nếu order chưa tồn tại (bình thường khi polling)
                    if (error.message && error.message.includes(''Order not found'')) {
                        // Order chưa tồn tại, tiếp tục polling
                        return;
                    }

                    // Chỉ log các lỗi khác (tắt để console sạch)
                    // console.error(''PayOS Check status error:'', error);
                });
        }

        function handlePayOSSuccess(paymentData) {
            confirmPayOSStatus(paymentData.OrderCode || paymentData.orderCode || payosLastOrderCode, "PAID");
            if (payosPaymentWindow && !payosPaymentWindow.closed) {
                payosPaymentWindow.close();
                payosPaymentWindow = null;
            }

            if (payosPopupWatcher) {
                clearInterval(payosPopupWatcher);
                payosPopupWatcher = null;
            }

            // Cleanup PayOS embedded instance
            if (payosEmbeddedInstance && typeof payosEmbeddedInstance.destroy === ''function'') {
                try {
                    payosEmbeddedInstance.destroy();
                    payosEmbeddedInstance = null;
                } catch (e) {
                    // console.error(''Error destroying PayOS instance:'', e);
                }
            }

            // Đánh dấu popup vừa đóng để tránh restorePayOSPendingOrder chạy
            payosPopupJustClosed = true;
            setTimeout(function () {
                payosPopupJustClosed = false;
            }, 2000);
            var iframeModal = document.getElementById(''payos-iframe-modal'');
            if (iframeModal) iframeModal.remove();
            // Cleanup iframe
            var iframe = document.getElementById(''payos-checkout-iframe'');
            if (iframe) {
                iframe.remove();
            }

            var container = document.getElementById(''payos-embedded-container'');
            if (container) {
                container.innerHTML = '''';
            }

            // Đóng modal ngay lập tức
            var paymentModal = document.getElementById("dp_modal_payos");
            if (paymentModal) {
                paymentModal.classList.remove("show");
            }

            uiManager.showAlert({ type: "success", message: "%Debt_PaymentSuccess%" });
            try { localStorage.removeItem(''payosPendingOrder''); } catch (e) { }

            loadDebtPaymentData();
        }

        function handlePayOSCancelled(paymentData) {
            confirmPayOSStatus(paymentData.paymentLinkID || paymentData.paymentLinkID || payosLastPaymentLinkID, "CANCELLED");

            // Đóng cửa sổ thanh toán ngay lập tức
            if (payosPaymentWindow && !payosPaymentWindow.closed) {
                payosPaymentWindow.close();
                payosPaymentWindow = null;
            }

            if (payosPopupWatcher) {
                clearInterval(payosPopupWatcher);
                payosPopupWatcher = null;
            }

            // Cleanup PayOS embedded instance
            if (payosEmbeddedInstance && typeof payosEmbeddedInstance.destroy === ''function'') {
                try {
                    payosEmbeddedInstance.destroy();
                    payosEmbeddedInstance = null;
                } catch (e) {
                    // console.error(''Error destroying PayOS instance:'', e);
                }
            }

            // Đánh dấu popup vừa đóng để tránh restorePayOSPendingOrder chạy
            payosPopupJustClosed = true;
            setTimeout(function () {
                payosPopupJustClosed = false;
            }, 2000);
            var iframeModal = document.getElementById(''payos-iframe-modal'');
            if (iframeModal) iframeModal.remove();
            // Cleanup iframe
            var iframe = document.getElementById(''payos-checkout-iframe'');
            if (iframe) {
                iframe.remove();
            }

            var container = document.getElementById(''dp_payos_embed_container'');
            if (container) {
                container.innerHTML = '''';
            }

            // Đóng modal thanh toán ngay lập tức
            var paymentModal = document.getElementById("dp_modal_payos");
            if (paymentModal) {
                paymentModal.classList.remove("show");
            }

            uiManager.showAlert({ type: "warning", message: "%Debt_PaymentCancelled%" });
            try { localStorage.removeItem(''payosPendingOrder''); } catch (e) { }
        }

        function restorePayOSPendingOrder() {
            // Không chạy nếu popup vừa đóng (tránh reload khi popup đóng)
            if (payosPopupJustClosed) {
                // console.log(''PayOS: Skip restorePayOSPendingOrder - popup just closed'');
                return;
            }

            // Trên desktop, chỉ chạy nếu không có popup đang mở (tránh reload khi popup đóng)
            if (!isMobileAndTablet() && payosPaymentWindow && !payosPaymentWindow.closed) {
                // console.log(''PayOS: Skip restorePayOSPendingOrder - popup still open'');
                return;
            }

            try {
                var pending = localStorage.getItem(''payosPendingOrder'');
                if (pending) {
                    var oc = parseInt(pending, 10);
                    if (!isNaN(oc)) {
                        // Trên mobile, đợi một chút để đảm bảo trang đã load xong
                        if (isMobileAndTablet()) {
                            setTimeout(function () {
                                // Kiểm tra lại flag trước khi gọi
                                if (!payosPopupJustClosed) {
                                    checkPayOSStatusDirect(oc);
                                }
                            }, 1000);
                        } else {
                            // Trên desktop, chỉ chạy nếu popup đã đóng
                            if (!payosPaymentWindow || payosPaymentWindow.closed) {
                                checkPayOSStatusDirect(oc);
                            }
                        }
                    }
                }
            } catch (e) {
                console.error(''restorePayOSPendingOrder error:'', e);
            }
        }

        // --- PAYMENT MODAL ---
        function openPaymentModal(debtItem) {
            currentPaymentDebt = debtItem;
            var modal = document.getElementById("dp_modal_payos");
            var infoDiv = document.getElementById("dp_pay_info");
            var inputSection = document.getElementById("dp_pay_input_sec");
            var loadingDiv = document.getElementById("dp_pay_loading");
            var qrDiv = document.getElementById("dp_pay_qr_container");
            var errorDiv = document.getElementById("dp_pay_error");
            var amountInput = document.getElementById("dp_pay_amount");
            var hintEl = document.getElementById("dp_pay_hint");
            var createBtn = document.getElementById("dp_btn_create_qr");

            // Reset UI
            infoDiv.style.display = "block";

            inputSection.style.display = "block"; // Hiển thị lại input

            loadingDiv.style.display = "none";
            qrDiv.style.display = "none";
            errorDiv.style.display = "none";
            createBtn.disabled = false;

            // Xóa mã QR cũ trước khi hiển thị modal (giống testfinal.html)
            var container = document.getElementById(''dp_payos_embed_container'');
            if (container) {
                container.innerHTML = '''';
            }

            // Fill info
            document.getElementById("payment-customer-name").textContent = debtItem.CustomerName || "-";

            // document.getElementById("payment-debt-type").textContent = debtItem.DebtType || "-"; // Đã xóa HTML line này
            // Calculate Remaining
            var totalDebt = debtItem.Amount || 0; // Đây là Item gốc từ Grid, Amount là Tổng nợ

            // Nhưng khi gọi từ openEditModal, variable ''item'' đã được clone và gán item.Amount = remaining
            // Tuy nhiên, logic chuẩn là dùng Remaining thực tế.
            // Biến debtItem truyền vào từ openEditModal đã được gán Amount = Remaining.
            // Kiểm tra lại logic openEditModal: var payItem = Object.assign({}, item); payItem.Amount = remaining;
            var remaining = debtItem.Amount || 0;

            // Set input value
            amountInput.value = formatNumber(remaining);
            amountInput.setAttribute("data-max", remaining);
            // Logic Payment Type
            var originalItem = debtList.find(x => x.RecordID === debtItem.RecordID);
            var pType = (originalItem && originalItem.PaymentType) ? originalItem.PaymentType : "PARTIAL";
            modal.classList.add("show");
            if (pType === "FULL") {
                // Nếu quy định thanh toán toàn bộ -> Auto tạo QR luôn, không cần user confirm
                // 1. Set UI state: Ẩn input, hiện loading ngay
                inputSection.style.display = "none";
                loadingDiv.style.display = "block";

                // 2. Gọi tạo payment
                // Lưu ý: createDebtPayment lấy value từ input, nên input phải có value đúng (đã set ở trên)
                // Cần setTimeout nhỏ để đảm bảo Modal transition không bị giật (optional)
                setTimeout(function () {
                    createDebtPayment();
                }, 100);
            } else {
                // PARTIAL or BOTH -> Cho user nhập và click nút
                amountInput.disabled = false;
                hintEl.textContent = "%Msg_EnterPaymentAmountHint%.";
                hintEl.className = "text-muted small";

                // Focus input
                setTimeout(function () { amountInput.focus(); }, 500);
            }
        }

        function formatNumber(num) {
            return num ? num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") : "0";
        }

        // Hàm format số tiền khi nhập (thêm dấu phẩy)
        function formatAmountInput(value) {
            // Bỏ tất cả ký tự không phải số
            var numbers = value.replace(/\D/g, '''');
            if (!numbers) return '''';
            // Format với dấu phẩy
            return numbers.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }

        // Hàm parse số tiền từ input (bỏ dấu phẩy)
        function parseAmountInput(value) {
            if (!value) return 0;
            // Bỏ tất cả ký tự không phải số
            var numbers = value.replace(/\D/g, '''');
            return parseInt(numbers, 10) || 0;
        }

        // Hàm format số tiền khi nhập (thêm dấu phẩy)
        function formatAmountInput(value) {
            // Bỏ tất cả ký tự không phải số
            var numbers = value.replace(/\D/g, '''');
            if (!numbers) return '''';
            // Format với dấu phẩy
            return numbers.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }

        // Hàm parse số tiền từ input (bỏ dấu phẩy)
        // --- EXPORT FUNCTION ---
        async function exportDebtData() {
        }

        // --- INIT IMPORT FILEUPLOADER ---
        // =====================================================================
        // EMPLOYEE MANAGEMENT LOGIC - Quản lý thông tin nhân viên
        // =====================================================================
        // Toggle giữa chọn nhân viên và nhập thủ công - COMMENTED vì đã bỏ các trường này
        /* document.getElementById("btn-toggle-manual-employee").addEventListener("click", function () {
            isManualEmployeeMode = !isManualEmployeeMode;
            var employeeSelect = document.getElementById("modal-employee-select");
            var employeeCode = document.getElementById("modal-employee-code");
            var employeeName = document.getElementById("modal-employee-name");
            var employeePhone = document.getElementById("modal-employee-phone");
            var employeeAddress = document.getElementById("modal-employee-address");
            if (isManualEmployeeMode) {
                employeeSelect.style.display = "none";
                employeeCode.style.display = "block";
                employeeName.removeAttribute("readonly");
                employeePhone.removeAttribute("readonly");
                employeeAddress.removeAttribute("readonly");
                this.innerHTML = ''<i class="bi bi-arrow-left"></i>'';
                this.setAttribute("title", "Quay lại chọn nhân viên");
                employeeSelect.value = "";
                employeeCode.value = "";
                employeeName.value = "";
                employeePhone.value = "";
                employeeAddress.value = "";
            } else {
                employeeSelect.style.display = "block";
                employeeCode.style.display = "none";
                employeeName.setAttribute("readonly", "readonly");
                employeePhone.setAttribute("readonly", "readonly");
                employeeAddress.setAttribute("readonly", "readonly");
                this.innerHTML = ''<i class="bi bi-pencil"></i>'';
                this.setAttribute("title", "Nhập thủ công");
                employeeCode.value = "";
                employeeName.value = "";
                employeePhone.value = "";
                employeeAddress.value = "";
            }
        }); */
        // Khởi tạo ngày tạo khi mở form thêm mới
        // Hook vào function showAddModal để khởi tạo ngày tạo
        // --- CLOSE MODAL HANDLERS ---
        // --- CLOSE MODAL HANDLERS ---
        var closeDetailBtn = document.getElementById("dp_close_detail");
        if (closeDetailBtn) {
            closeDetailBtn.onclick = function () {
                document.getElementById("dp_modal_detail").classList.remove("show");
            };
        }

        var closePayOSBtn = document.getElementById("dp_close_payos");
        if (closePayOSBtn) {
            closePayOSBtn.onclick = function () {
                document.getElementById("dp_modal_payos").classList.remove("show");

                // Stop polling if closing PayOS modal
                stopPayOSPolling();
            };
        }

        // Initial Load
        // loadEmployeeList(); // User view không cần list employee khác
        window.loadDebtPaymentData = loadDebtPaymentData; // Expose to global scope for button click

        // --- PAYMENT HANDLERS ---
        var payAmountInput = document.getElementById("dp_pay_amount");
        if (payAmountInput) {
            payAmountInput.oninput = function () {
                var val = this.value;
                var num = parseAmountInput(val);

                // Keep cursor position logic could be complex with formatting,
                // simple approach: just format
                // Validate Max
                var max = parseFloat(this.getAttribute("data-max")) || 0;
                if (num > max) {
                    num = max;
                }

                this.value = formatNumber(num);
            };
        }

        var btnCreateQR = document.getElementById("dp_btn_create_qr");
        if (btnCreateQR) {
            btnCreateQR.onclick = function () {
                createDebtPayment();
            };
        }

        // Initial Load
        loadDebtPaymentData();
        restorePayOSPendingOrder();

        /**
         * Lấy danh sách các transaction CANCELLED và hủy payment link trên PayOS

         */
        function cancelOldPayOSTransactions(recordId) {
            var params = ["Status", "CANCELLED"];
            if (recordId) {
                params.push("RecordID");
                params.push(recordId);
            }

            AjaxHPAParadise({
                data: { name: "sp_Debt_PayOS_GetCancelledTransactions", param: params },
                success: function (res) {
                    hideLoading();

                    try {
                        var parsed = JSON.parse(res);
                        var transactions = (parsed.data && parsed.data[0]) ? parsed.data[0] : [];
                        if (!transactions || transactions.length === 0) {
                            console.log(''✅ Không có transaction CANCELLED nào cần xử lý'');
                            return;
                        }

                        console.log(''🔄 Tìm thấy'', transactions.length, ''transaction(s) CANCELLED, đang hủy trên PayOS...'');

                        // Cancel tuần tự với delay 1 giây giữa mỗi request để tránh rate limit
                        var index = 0;

                        function cancelNext() {
                            if (index >= transactions.length) {
                                console.log(''✅ Đã hoàn tất xử lý tất cả transactions'');
                                return;
                            }

                            var trans = transactions[index];
                            index++;
                            if (trans.PaymentLinkID) {
                                cancelPayOSPaymentLink(trans.PaymentLinkID, ''Tự động hủy - Transaction đã CANCELLED'')
                                    .then(function () {
                                        console.log(''✅ Đã xử lý PaymentLinkID:'', trans.PaymentLinkID);

                                        // Delay 1 giây trước khi cancel tiếp
                                        setTimeout(cancelNext, 1000);
                                    })
                                    .catch(function (err) {
                                        console.warn(''⚠️ Không thể hủy PaymentLinkID:'', trans.PaymentLinkID, err.message);

                                        // Vẫn tiếp tục với transaction tiếp theo
                                        setTimeout(cancelNext, 1000);
                                    });
                            } else {
                                // Không có PaymentLinkID, skip
                                setTimeout(cancelNext, 100);
                            }
                        }

                        // Bắt đầu cancel
                        cancelNext();
                    } catch (e) {
                        console.error(''❌ Parse error:'', e);
                    }
                },
                error: function (err) {
                    console.error(''❌ Failed to get cancelled transactions:'', err);
                }
            });
        }

        // Hàm này sẽ được gọi MANUALLY khi cần, không auto-run
        function safeRestorePayOSPendingOrder() {
            // Chỉ chạy nếu không phải do popup đóng
            if (payosPopupJustClosed) {
                return;
            }

            // Trên desktop, chỉ chạy nếu popup đã đóng hoặc không có popup
            if (!isMobileAndTablet()) {
                if (payosPaymentWindow && !payosPaymentWindow.closed) {
                    return; // Popup vẫn đang mở, không cần restore
                }
            }

            restorePayOSPendingOrder();
        }

        window.addEventListener(''focus'', safeRestorePayOSPendingOrder);
        document.addEventListener(''visibilitychange'', function () {
            if (!document.hidden) safeRestorePayOSPendingOrder();
        });
        window.addEventListener(''beforeunload'', function () {
            stopPayOSPolling();
        });

        // Start restore check on load
        restorePayOSPendingOrder();
        HideLoadingByClassOrID("#sp_Debt_PaymentDebt");
    })();
</script>
'

 SELECT @html AS html;

--  exec sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: BIÊN DỊCH VÀ ĐỒNG BỘ CACHE VÀO TBLHTMLSCRIPTCACHE
--------------------------------------------------------------------------------------------------*/
-- 2.1 Kích hoạt biên dịch từ SP
EXEC sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'
GO

-- 2.2 ĐỒNG BỘ ÉP BUỘC CẢ 2 KEY CACHE: 'sp_Debt_PaymentDebt' VÀ 'sp_Debt_PaymentDebt_html'
-- Đảm bảo dù Web đọc theo key nào cũng lấy được 100% bản HTML mới nhất!
UPDATE h_old
SET html = h_new.html
FROM tblHtmlScriptCache h_old
INNER JOIN tblHtmlScriptCache h_new 
    ON h_new.TableName = 'sp_Debt_PaymentDebt' 
   AND h_new.LanguageID = h_old.LanguageID
WHERE h_old.TableName = 'sp_Debt_PaymentDebt_html';
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: CẬP NHẬT THỦ TỤC ĐIỀU PHỐI SP_DEBT_PAYMENTDEBT (FALLBACK AN TOÀN CHO CẢ 2 KEY)
--------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_Debt_PaymentDebt]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Ưu tiên lấy bản cache mới nhất từ TableName 'sp_Debt_PaymentDebt' hoặc 'sp_Debt_PaymentDebt_html'
    SELECT TOP 1 html 
    FROM tblHtmlScriptCache 
    WHERE TableName IN ('sp_Debt_PaymentDebt', 'sp_Debt_PaymentDebt_html') 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID
    ORDER BY CASE WHEN TableName = 'sp_Debt_PaymentDebt' THEN 1 ELSE 2 END;
END
GO
