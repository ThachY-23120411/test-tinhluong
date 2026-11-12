/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-13
  MÀN HÌNH / MENU    : Công nợ -> Danh sách công nợ khách hàng (MnuPRL410)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[sp_Debt_ListCustomerDebt_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_Debt_ListCustomerDebt_html]
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

    #sp_debt_list {
        margin-bottom: 3rem;
        font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
    }

    #sp_debt_list .header-section {
        border-bottom: 2px solid rgba(128, 128, 128, 0.2);
    }

    /* Buttons Main */
    #sp_debt_list .btn-add {
        background: var(--training-primary);
        color: white;
        border: none;
        transition: all 0.2s;
    }

    #sp_debt_list .btn-add:hover {
        background: var(--training-primary-dark);
        transform: translateY(-2px);
    }

    /* Search & Filter Inputs */
    #sp_debt_list .search-box {
        position: relative;
        flex: 1;
    }

    #sp_debt_list .search-icon {
        position: absolute;
        width: 0;
        left: 1rem;
        top: 50%;
        transform: translateY(-50%);
        opacity: 0.6;
    }

    #sp_debt_list .search-input {
        padding-left: 2.5rem !important;
    }

    /* Grid Styling */
    #sp_debt_list .grid-container {
        border-radius: 12px;
        overflow: hidden;
        border: 2px solid rgba(128, 128, 128, 0.2);
    }

    #sp_debt_list .dx-datagrid {
        border: none !important;
        background: unset;
    }

    #sp_debt_list .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 1rem !important;
        height: 60px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }

    #sp_debt_list .dx-datagrid-row>td {
        padding: 0.75rem 1rem !important;
        vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }

    /* Status Badges */
    #sp_debt_list .badge-status {
        padding: 0.25rem 0.75rem;
        border-radius: 999px;
        font-size: 0.75rem;
        font-weight: 700;
        display: inline-block;
    }

    #sp_debt_list .badge-paid {
        background: rgba(46, 125, 50, 0.15);
        color: var(--training-primary);
    }

    #sp_debt_list .badge-unpaid {
        background: rgba(229, 57, 53, 0.15);
        color: var(--training-danger);
    }

    #sp_debt_list .badge-partial {
        background: rgba(251, 192, 45, 0.15);
        color: var(--training-warning);
    }

    #sp_debt_list .btn-collect-inline {
        background: rgba(46, 125, 50, 0.1);
        color: var(--training-primary);
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 600;
    }

    #sp_debt_list .btn-collect-inline:hover {
        background: rgba(46, 125, 50, 0.2);
        transform: translateY(-1px);
    }

    #sp_debt_list .payment-history-item {
        padding: 1rem;
        border: 1px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
        margin-bottom: 0.75rem;
    }

    #sp_debt_list .btn-edit-inline {
        background: rgba(2, 136, 209, 0.1);
        color: #0288D1;
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
    }

    #sp_debt_list .btn-edit-inline:hover {
        background: rgba(2, 136, 209, 0.2);
        transform: translateY(-1px);
    }

    #sp_debt_list .btn-pay-inline {
        background: rgba(46, 125, 50, 0.1);
        color: var(--training-primary);
        border: none;
        padding: 0.375rem 0.75rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 600;
    }

    #sp_debt_list .btn-pay-inline:hover {
        background: rgba(46, 125, 50, 0.2);
        transform: translateY(-1px);
    }

    #sp_debt_list .qr-code-container {
        text-align: center;
        padding: 1.5rem;
        background: #f8f9fa;
        border-radius: 12px;
        margin: 1rem 0;
    }

    #sp_debt_list .qr-code-container img {
        max-width: 250px;
        width: 100%;
        height: auto;
        border: 2px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
    }

    /* PayOS Embedded Container */
    #sp_debt_list #payos-embedded-container {
        width: 100%;
        min-height: 600px;
        border-radius: 8px;
        overflow: hidden;
        background: #f8f9fa;
    }

    #sp_debt_list #payos-checkout-iframe {
        width: 100%;
        min-height: 600px;
        border: none;
        border-radius: 8px;
    }

    /* Modal Styles */
    #sp_debt_list .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.7);
        z-index: 1050;
        align-items: center;
        justify-content: center;
        padding: 1rem;
    }

    #sp_debt_list .modal-overlay.show {
        display: flex;
    }

    #sp_debt_list .modal-content {
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

    #sp_debt_list .modal-header-custom {
        padding: 1.5rem;
        border-bottom: 1px solid rgba(128, 128, 128, 0.2);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    #sp_debt_list .modal-body {
        flex: 1;
        overflow-y: auto;
        padding: 1.5rem;
    }

    #sp_debt_list .modal-buttons {
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
    #sp_debt_list .form-label {
        font-weight: 600;
        margin-bottom: 0.5rem;
        display: block;
    }

    #sp_debt_list .form-control,
    #sp_debt_list .form-select {
        border: 2px solid rgba(128, 128, 128, 0.2);
        border-radius: 8px;
        padding: 0.625rem;
        width: 100%;
    }

    #sp_debt_list .form-control:focus,
    #sp_debt_list .form-select:focus {
        border-color: var(--training-primary);
        outline: none;
    }

    #sp_debt_list .form-control:disabled,
    #sp_debt_list .form-select:disabled {
        background-color: rgba(128, 128, 128, 0.1);
        cursor: not-allowed;
        opacity: 0.7;
    }

    #sp_debt_list textarea.form-control {
        min-height: 80px;
        resize: vertical;
    }

    #sp_debt_list .btn-close-modal {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        border: none;
        background: transparent;
        cursor: pointer;
        font-size: 1rem;
    }

    #sp_debt_list .btn-close-modal:hover {
        background: rgba(128, 128, 128, 0.1);
    }

    #sp_debt_list .btn {
        font-size: 1rem;
        padding: 0.65rem 1.25rem;
        font-weight: 500;
        border-radius: 8px;
        border: none;
        cursor: pointer;
    }

    #sp_debt_list .btn-success {
        background-color: var(--training-primary);
        color: #fff;
    }

    #sp_debt_list .btn-danger {
        background-color: var(--training-danger);
        color: #ffffff;
    }

    #sp_debt_list .btn-primary {
        background-color: #0288D1;
        color: #fff;
    }

    #sp_debt_list .btn-primary:hover {
        background-color: #0277BD;
    }

    /* Import Button Styling */
    #sp_debt_list #import-excel-fileuploader-container {
        background-color: var(--training-primary);
        border: none;
        box-shadow: 0 2px 4px rgba(46, 125, 50, 0.2);
    }

    #sp_debt_list #import-excel-fileuploader-container:hover {
        background-color: var(--training-primary-dark);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(46, 125, 50, 0.3);
    }

    #sp_debt_list #import-excel-fileuploader-container:active {
        transform: translateY(0);
        box-shadow: 0 2px 4px rgba(46, 125, 50, 0.2);
    }

    /* Desktop only elements */
    #sp_debt_list .desktop-only {
        display: block;
    }

    @media (max-width: 768px) {
        #sp_debt_list .modal-content {
            margin-top: 20px;
            max-height: 90vh;
        }

        #sp_debt_list .modal-buttons {
            padding: 1rem;
            flex-direction: column-reverse;
        }

        #sp_debt_list .modal-body {
            padding: 1rem;
        }

        #sp_debt_list .btn {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        #sp_debt_list .header-section {
            display: none;
        }

        /* Ẩn header desktop trên mobile */
        #sp_debt_list #modal-debt-delete {
            display: none !important;
        }

        #sp_debt_list .desktop-only {
            display: none !important;
        }

        /* Ẩn các phần tử desktop-only trên mobile */
    }
</style>

<div id="sp_debt_list">
    <div class="header-section pb-3 mb-4">
        <div
            class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3">
            <div>
                <h3 class="mb-1 fw-bold"><i class="bi bi-cash-stack me-2"></i>%Debt_PageTitle%</h3>
                <p class="mb-0 opacity-75">%Debt_PageDescription%</p>
            </div>
            <div class="d-flex gap-2 desktop-only">
                <button class="btn btn-primary px-4 py-2 rounded-3" id="btn-export-debt">
                    <i class="bi bi-download me-2"></i>%Debt_ExportButton%
                </button>
                <button class="btn btn-add px-4 py-2 rounded-3" id="show-add-debt">
                    <i class="bi bi-plus-lg me-2"></i>%Debt_AddNewDebtButton%
                </button>
            </div>
        </div>
    </div>

    <div class="mb-4">
        <div class="row g-3">
            <div class="col-md-8">
                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" class="form-control search-input" id="search-debt"
                        placeholder="%Debt_SearchPlaceholder%">
                </div>
            </div>
            <div class="col-md-4">
                <select class="form-select" id="filter-status">
                    <option value=""> %Debt_AllStatus% </option>
                    <option value="0"> %Debt_UnpaidStatusOption%</option>
                    <option value="1"> %Debt_PaidStatusOption%</option>
                </select>
            </div>
        </div>
    </div>

    <div class="grid-container">
        <div id="debt_loadingState" class="text-center py-5" style="display: none;">
            <div class="spinner-border text-success" role="status"></div>
            <p class="mt-3">%Debt_LoadingData%</p>
        </div>
        <div id="debt_gridContent" style="display: none;">
            <div id="debt_grid"></div>
        </div>
        <div id="debt_emptyState" class="text-center py-5" style="display: none;">
            <div class="empty-state">
                <div style="font-size: 3rem; opacity: 0.3; margin-bottom: 1rem;"><i class="bi bi-clipboard-x"></i></div>
                <p>%Debt_NoData%</p>
                <button class="btn btn-success" id="debt_empty_add_btn">%Debt_CreateNowButton%</button>
            </div>
        </div>
    </div>

    <div class="modal-overlay" id="modal-debt">
        <div class="modal-content" onclick="event.stopPropagation()">
            <div class="modal-header-custom">
                <div class="d-flex align-items-center gap-2">
                    <h5 class="mb-0 fw-bold" id="modal-debt-title">%Debt_DebtInfoTitle%</h5>
                    <span id="modal-debt-header-badge" style="display: none;"></span>
                </div>
                <button type="button" class="btn-close-modal" id="close-modal-debt"><i class="bi bi-x-lg"></i></button>
            </div>

            <form id="modal-debt-form" style="display: flex; flex-direction: column; flex: 1; min-height: 0;">
                <div class="modal-body">
                    <input type="hidden" id="modal-rec-id" value="">

                    <!-- Import Excel Section (chỉ hiển thị khi thêm mới) -->
                    <div id="modal-debt-import" class="mb-3 p-3 rounded desktop-only"
                        style="display: none; background: rgba(46, 125, 50, 0.05); border: 2px dashed rgba(46, 125, 50, 0.3);">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-file-earmark-excel text-success" style="font-size: 1.5rem;"></i>
                            <label class="form-label mb-0 fw-bold">%Debt_ImportExcelLabel%</label>
                        </div>
                        <button type="button"
                            class="btn btn-success w-100 d-flex align-items-center justify-content-center gap-2 py-2"
                            id="import-excel-fileuploader-container"
                            style="font-weight: 600; border-radius: 8px; transition: all 0.2s;">
                            <i class="bi bi-upload" style="font-size: 1.1rem;"></i>
                            <span>%Debt_ImportButton%</span>
                        </button>
                        <small class="text-muted d-block mt-2 text-center">%Debt_ImportExcelHint%</small>
                    </div>

                    <!-- Summary Section (chỉ hiển thị khi xem công nợ đã thanh toán) -->
                    <div id="modal-debt-summary" class="mb-3 p-3 rounded"
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
                            <input type="date" class="form-control" id="modal-created-date" readonly
                                style="background-color: #f5f5f5; cursor: not-allowed;">
                            <small class="text-muted">%Msg_AutoSystem%</small>
                        </div>

                        <!-- Ngày hết hạn (chọn tháng-năm) -->
                        <div class="col-md-6">
                            <label class="form-label">%Col_ExpiryDate% <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" id="modal-expiry-date" required
                                placeholder="%Ph_SelectExpiryDate%">
                        </div>

                        <!-- Thông tin khách hàng -->
                        <!-- Thông tin khách hàng -->
                        <div class="col-md-6">
                            <label class="form-label">%Debt_CustomerCodeLabel% <span
                                    class="text-danger">*</span></label>
                            <div class="input-group">
                                <div id="modal-cust-select" class="flex-grow-1"></div>
                                <button type="button" class="btn btn-outline-secondary" id="btn-toggle-manual-cust"
                                    title="Nhập thủ công">
                                    <i class="bi bi-pencil"></i>
                                </button>
                            </div>
                            <input type="text" class="form-control mt-2" id="modal-cust-code" style="display: none;"
                                maxlength="50" placeholder="VD: KH001">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_CustomerNameLabel% <span
                                    class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="modal-cust-name" required maxlength="100"
                                placeholder="%Debt_CustomerNameExample%" readonly>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">%Debt_PhoneLabel%</label>
                            <input type="text" class="form-control" id="modal-cust-phone" maxlength="20"
                                placeholder="09xxxx" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">%Debt_AddressLabel%</label>
                            <input type="text" class="form-control" id="modal-cust-address" maxlength="255"
                                placeholder="%Debt_ContactAddress%" readonly>
                        </div>

                        <div class="col-12">
                            <hr class="opacity-25 my-1">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">%Debt_DebtTypeLabel% <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="modal-debt-type" list="debt-types" required
                                maxlength="50" placeholder="%Debt_DebtTypeExample%">
                            <datalist id="debt-types">
                                <option value="Tiền điện">
                                <option value="Tiền nước">
                                <option value="Tín dụng">
                                <option value="Dịch vụ">
                            </datalist>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">%Debt_AmountLabel% <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="modal-amount" required
                                placeholder="%Debt_EnterAmount%" inputmode="numeric">
                        </div>

                        <!-- Tùy chọn thanh toán -->
                        <div class="col-md-6">
                            <label class="form-label">%Col_PaymentType% <span class="text-danger">*</span></label>
                            <select class="form-select" id="modal-payment-type" required>
                                <option value="">-- %Ph_SelectPaymentType% --</option>
                                <option value="FULL">%Opt_FullPayment%</option>
                                <option value="PARTIAL">%Opt_PartialPayment%</option>
                                <option value="BOTH">%Opt_FlexiblePayment%</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">%Col_PaymentMethod% <span class="text-danger">*</span></label>
                            <select class="form-select" id="modal-payment-method-select" required>
                                <option value="">-- %Ph_SelectMethod% --</option>
                                <option value="CASH">%Opt_Cash%</option>
                                <option value="PAYOS">PayOS</option>
                                <option value="BOTH">%Opt_FlexiblePayment%</option>
                            </select>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">%Cfg_PayOS_Content%</label>
                            <textarea class="form-control" id="modal-note" maxlength="25"
                                placeholder="%Msg_PayOS_DefaultContent%"></textarea>
                            <small class="text-muted">%Msg_PayOS_LimitNote%.</small>
                        </div>
                    </div>
                </div>

                <div class="modal-buttons">
                    <button type="submit" class="btn btn-success" id="modal-debt-submit">
                        <i class="bi bi-check-lg me-2"></i>%Debt_SaveButton%
                    </button>
                    <button type="button" class="btn btn-success" id="modal-debt-collect-btn" style="display: none;">
                        <i class="bi bi-cash-coin me-2"></i>%Debt_CollectDebtButton%
                    </button>
                    <button type="button" class="btn btn-primary" id="modal-debt-pay" style="display: none;">
                        <i class="bi bi-credit-card me-2"></i>%Debt_PayWithPayOSButton%
                    </button>
                    <button type="button" class="btn btn-danger" id="modal-debt-delete" style="display: none;">
                        <i class="bi bi-trash me-2"></i>%Debt_DeleteButton%
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Thu hồi Công Nợ -->
    <div class="modal-overlay" id="modal-debt-collect">
        <div class="modal-content" onclick="event.stopPropagation()" style="max-width: 600px;">
            <div class="modal-header-custom">
                <h5 class="mb-0 fw-bold"><i class="bi bi-cash-coin me-2"></i>%Debt_CollectDebtModalTitle%</h5>
                <button type="button" class="btn-close-modal" id="close-modal-collect"><i
                        class="bi bi-x-lg"></i></button>
            </div>
            <form id="modal-collect-form">
                <div class="modal-body">
                    <div class="mb-3 p-3 rounded">
                        <div class="row">
                            <div class="col-6">
                                <label class="form-label text-muted small">%Debt_CustomerLabel%</label>
                                <div class="fw-bold" id="collect-customer-name">-</div>
                            </div>
                            <div class="col-6">
                                <label class="form-label text-muted small">%Debt_TotalDebtLabel%</label>
                                <div class="fw-bold text-danger" id="collect-total-debt">0 VNĐ</div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-6">
                                <label class="form-label text-muted small">%Debt_PaidAmountLabel%</label>
                                <div class="fw-bold text-success" id="collect-paid-amount">0 VNĐ</div>
                            </div>
                            <div class="col-6">
                                <label class="form-label text-muted small">%Debt_RemainingDebtLabel%</label>
                                <div class="fw-bold text-warning fs-5" id="collect-remaining-debt">0 VNĐ</div>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">%Debt_CollectionAmountLabel% <span
                                class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="collect-amount" required
                                placeholder="%Debt_EnterAmount%" inputmode="numeric">
                            <button type="button" class="btn btn-outline-primary" id="collect-pay-full">
                                <i class="bi bi-cash-stack me-1"></i>%Debt_PayFullButton%
                            </button>
                        </div>
                        <small class="text-muted">%Debt_MaxAmountLabel% <span id="collect-max-amount" class="fw-bold">0
                                VNĐ</span></small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">%Debt_PaymentMethodLabel% <span class="text-danger">*</span></label>
                        <select class="form-select" id="collect-payment-method" required>
                            <option value="">%Debt_SelectPaymentMethodPlaceholder%</option>
                            <option value="CASH">%Debt_CashPayment%</option>
                            <option value="PAYOS">%Debt_PayOSPayment%</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">%Debt_NoteLabel%</label>
                        <textarea class="form-control" id="collect-note" maxlength="500" rows="3"
                            placeholder="%Debt_CollectionNotePlaceholder%"></textarea>
                    </div>
                </div>

                <div class="modal-buttons">
                    <button type="button" class="btn btn-primary" id="collect-view-history">
                        <i class="bi bi-clock-history me-2"></i>%Debt_ViewHistoryButton%
                    </button>
                    <button type="submit" class="btn btn-success">
                        <i class="bi bi-check-lg me-2"></i>%Debt_ConfirmCollectButton%
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Lịch sử Thu hồi -->
    <div class="modal-overlay" id="modal-payment-history">
        <div class="modal-content" onclick="event.stopPropagation()" style="max-width: 800px;">
            <div class="modal-header-custom">
                <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2"></i>%Debt_PaymentHistoryModalTitle%</h5>
                <button type="button" class="btn-close-modal" id="close-modal-history"><i
                        class="bi bi-x-lg"></i></button>
            </div>
            <div class="modal-body">
                <div class="mb-3 p-3 rounded">
                    <div class="row">
                        <div class="col-md-6">
                            <label class="form-label text-muted small">%Debt_CustomerLabel%</label>
                            <div class="fw-bold" id="history-customer-name">-</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small">%Debt_TotalDebtLabel%</label>
                            <div class="fw-bold text-danger" id="history-total-debt">0 VNĐ</div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4">
                            <label class="form-label text-muted small">%Debt_TotalPaidLabel%</label>
                            <div class="fw-bold text-success" id="history-total-paid">0 VNĐ</div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label text-muted small">%Debt_RemainingDebtLabel%</label>
                            <div class="fw-bold text-warning" id="history-remaining">0 VNĐ</div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label text-muted small">%Debt_StatusLabel%</label>
                            <div id="history-status-badge"></div>
                        </div>
                    </div>
                </div>
                <div id="payment-history-list">
                    <div class="text-center py-4">
                        <div class="spinner-border text-success" role="status"></div>
                        <p class="mt-3">%Debt_LoadingHistory%</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Thanh toán PayOS -->
    <div class="modal-overlay" id="modal-debt-payment">
        <div class="modal-content" onclick="event.stopPropagation()" style="max-width: 600px;">
            <div class="modal-header-custom">
                <h5 class="mb-0 fw-bold"><i class="bi bi-qr-code me-2"></i>%Debt_PayOSPaymentModalTitle%</h5>
                <button type="button" class="btn-close-modal" id="close-modal-payment"><i
                        class="bi bi-x-lg"></i></button>
            </div>
            <div class="modal-body">
                <div id="payment-info">
                    <div class="mb-3">
                        <label class="form-label text-muted">%Debt_CustomerLabel%</label>
                        <div class="fw-bold" id="payment-customer-name">-</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted">%Debt_AmountToPayLabel%</label>
                        <div class="fw-bold text-danger fs-4" id="payment-amount">0 VNĐ</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted">%Debt_DebtTypeLabelShort%</label>
                        <div class="fw-bold" id="payment-debt-type">-</div>
                    </div>
                </div>
                <div id="payment-loading" class="text-center py-4" style="display: none;">
                    <div class="spinner-border text-success" role="status"></div>
                    <p class="mt-3">%Debt_CreatingPaymentCode%</p>
                </div>
                <div id="payment-qr-container" style="display: none;">
                    <!-- Container cho PayOS Embedded -->
                    <div id="payos-embedded-container" style="min-height: 400px;"></div>
                </div>
                <div id="payment-error" style="display: none;">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        <span id="payment-error-msg">%Debt_PaymentCodeError%</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src=''https://cdn.payos.vn/payos-checkout/v1/stable/payos-initialize.js''></script>
<script>
    (function () {
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

        function showLoading() { document.getElementById("debt_loadingState").style.display = "block"; }
        function hideLoading() { document.getElementById("debt_loadingState").style.display = "none"; }

        function isMobileAndTablet() {
            return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || window.innerWidth < 1024;
        }

        // --- 1. LOAD DATA (Read) ---
        function loadData() {
            showLoading();

            // Gọi Store: sp_Debt_Select
            // Param: CustomerCode = null (lấy hết), Status = null (lấy hết)
            AjaxHPAParadise({
                data: { name: "sp_Debt_Select", param: ["CustomerCode", null, "Status", null] },
                success: function (res) {
                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        // Xử lý dữ liệu trả về từ SP (thường bọc trong mảng)
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                        debtList = Array.isArray(data) ? data : [];
                        renderGrid();
                    } catch (e) { console.error("Parse Error", e); }
                },
                error: function (err) { console.error("API Error", err); },
                complete: function () { hideLoading(); }
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
            var searchText = removeVietnameseTones(document.getElementById("search-debt").value);
            var filterStatus = document.getElementById("filter-status").value; // "0", "1" or ""

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
                document.getElementById("debt_gridContent").style.display = "none";
                document.getElementById("debt_emptyState").style.display = "block";
                return;
            }

            document.getElementById("debt_gridContent").style.display = "block";
            document.getElementById("debt_emptyState").style.display = "none";

            // Init DataGrid
            if (gridInstance) {
                gridInstance.option("dataSource", filteredData);
            } else {
                gridInstance = $("#debt_grid").dxDataGrid({
                    dataSource: filteredData,
                    keyExpr: "RecordID", // Khóa chính của bảng
                    showBorders: false,
                    hoverStateEnabled: true,
                    columnAutoWidth: true,
                    paging: { pageSize: 15 },
                    pager: { showPageSizeSelector: true, allowedPageSizes: [15, 30, 50], showInfo: true, visible: true },
                    columns: [
                        {
                            caption: "%Debt_CustomerLabel%",
                            minWidth: 150,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                $("<div>").addClass("fw-bold").text(d.CustomerName).appendTo(container);
                                $("<div>").addClass("small opacity-75").text(d.CustomerCode).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_DebtTypeLabel%",
                            dataField: "DebtType",
                            width: 120
                        },
                        {
                            dataField: "Amount",
                            caption: "%Debt_TotalDebtLabel%",
                            width: 120,

                            alignment: "right",
                            format: "#,##0" // Định dạng tiền
                        },
                        {
                            caption: "%Debt_PaidAmountLabel%",
                            width: 110,
                            alignment: "right",
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var paidAmount = d.PaidAmount || 0;
                                $("<div>").addClass("text-success fw-bold").text(formatNumber(paidAmount)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_RemainingDebtLabel%",
                            width: 110,
                            alignment: "right",
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
                            width: 150,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                if (d.PhoneNumber) $("<div>").html(`<i class="bi bi-telephone me-1"></i>${d.PhoneNumber}`).appendTo(container);
                                if (d.Address) $("<div>").addClass("small text-truncate").attr("title", d.Address).text(d.Address).appendTo(container);
                            }
                        },
                        {
                            dataField: "Status",
                            caption: "%Status%",
                            width: 140,
                            alignment: "center",
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                var statusFromDB = d.Status || 0; // Status từ DB: 0 = chưa thanh toán, 1 = đã thanh toán

                                // Ưu tiên Status từ DB, nếu Status = 1 thì hiển thị "Đã thanh toán"
                                // Nếu Status = 0, thì mới kiểm tra số tiền thực tế
                                var badgeClass, text;
                                if (statusFromDB === 1) {
                                    // Status = 1: Đã thanh toán (từ DB hoặc Excel import)
                                    badgeClass = "badge-paid";
                                    text = "%Debt_PaidStatus%";
                                } else {
                                    // Status = 0: Kiểm tra số tiền thực tế
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

                    ],
                    onRowClick: function (e) { openEditModal(e.data.RecordID); }
                }).dxDataGrid("instance");
            }
        }

        // --- Helper: Enable/Disable form inputs ---
        function setFormInputsEnabled(enabled) {
            var inputs = [
                "modal-cust-code",
                "modal-cust-name",
                "modal-cust-phone",
                "modal-cust-address",
                "modal-debt-type",
                "modal-amount",
                "modal-note",
                "modal-expiry-date",
                "modal-payment-type",
                "modal-payment-method-select"
            ];

            inputs.forEach(function (inputId) {
                var input = document.getElementById(inputId);
                if (input) {
                    input.disabled = !enabled;
                }
            });

            // Disable dxSelectBox
            try {
                var sb = $("#modal-cust-select").dxSelectBox("instance");
                if (sb) {
                    sb.option("disabled", !enabled);
                }
            } catch (e) { }

            // Disable toggle button
            var btnToggle = document.getElementById("btn-toggle-manual-cust");
            if (btnToggle) btnToggle.disabled = !enabled;
        }

        // --- 3. OPEN MODAL (Add/Edit) ---
        function openEditModal(id) {
            editingId = id;
            editingHasHistory = false;
            editingOriginalAmount = 0;
            var form = document.getElementById("modal-debt-form");
            form.reset();

            // Mặc định enable tất cả inputs (cho trường hợp Add hoặc Edit chưa thanh toán)
            setFormInputsEnabled(true);
            var amountInput = document.getElementById("modal-amount");
            if (amountInput) {
                amountInput.disabled = false;
                amountInput.removeAttribute("title");
            }

            var deleteBtn = document.getElementById("modal-debt-delete");
            var payBtn = document.getElementById("modal-debt-pay");
            var collectBtn = document.getElementById("modal-debt-collect-btn");
            var submitBtn = document.getElementById("modal-debt-submit");
            var modalTitle = document.getElementById("modal-debt-title");

            if (id) {
                // EDIT MODE
                var item = debtList.find(x => x.RecordID === id);
                if (item) {
                    var totalAmount = item.Amount || 0;
                    editingOriginalAmount = totalAmount;
                    editingHasHistory = (item.PaidAmount || 0) > 0; // Nếu đã thu lần nào thì xem như có lịch sử
                    var paidAmount = item.PaidAmount || 0;
                    var remaining = totalAmount - paidAmount;
                    var statusFromDB = item.Status || 0;
                    // Ưu tiên Status từ DB, nếu Status = 1 thì coi như đã thanh toán
                    var isFullyPaid = (statusFromDB === 1) || (remaining <= 0 && paidAmount > 0);

                    // Xác định trạng thái và hiển thị badge ở header
                    var headerBadge = document.getElementById("modal-debt-header-badge");
                    var isPartiallyPaid = paidAmount > 0 && remaining > 0;

                    if (isFullyPaid) {
                        // ĐÃ THANH TOÁN ĐỦ: Chỉ xem, không cho chỉnh sửa
                        modalTitle.textContent = "%Debt_ViewDebt%";
                        setFormInputsEnabled(false);
                        submitBtn.style.display = "none";
                        deleteBtn.style.display = "none";
                        payBtn.style.display = "none";
                        collectBtn.style.display = "none";

                        // Hiển thị badge ở header
                        if (headerBadge) {
                            headerBadge.innerHTML = ''<span class="badge-status badge-paid">%Debt_PaidStatus%</span>'';
                            headerBadge.style.display = "inline-block";
                        }

                        // Hiển thị phần tóm tắt giống modal thu hồi
                        var summaryDiv = document.getElementById("modal-debt-summary");
                        if (summaryDiv) {
                            summaryDiv.style.display = "block";
                            document.getElementById("summary-customer-name").textContent = item.CustomerName || "-";
                            document.getElementById("summary-total-debt").textContent = formatNumber(totalAmount) + " VNĐ";
                            document.getElementById("summary-paid-amount").textContent = formatNumber(paidAmount) + " VNĐ";
                            document.getElementById("summary-remaining-debt").textContent = formatNumber(remaining) + " VNĐ";

                            // Ngày thanh toán
                            var paymentDateRow = document.getElementById("summary-payment-date-row");
                            var paymentDateDiv = document.getElementById("summary-payment-date");
                            if (item.PaymentDate) {
                                var paymentDate = new Date(item.PaymentDate);
                                paymentDateDiv.textContent = paymentDate.toLocaleString(''vi-VN'', {
                                    day: ''2-digit'',
                                    month: ''2-digit'',
                                    year: ''numeric'',
                                    hour: ''2-digit'',
                                    minute: ''2-digit''
                                });
                                paymentDateRow.style.display = "block";
                            } else {
                                paymentDateRow.style.display = "none";
                            }
                        }
                    } else {
                        // CHƯA THANH TOÁN ĐỦ: Cho phép chỉnh sửa và thu hồi
                        modalTitle.textContent = "%Debt_UpdateDebt%";
                        if (isPartiallyPaid) {
                            // Đã thanh toán 1 phần -> Không cho sửa thông tin
                            setFormInputsEnabled(false);
                            submitBtn.style.display = "none";
                            deleteBtn.style.display = "none";
                        } else {
                            // Chưa thanh toán gì -> Cho sửa
                            setFormInputsEnabled(true);
                            submitBtn.style.display = "block";
                            deleteBtn.style.display = "block";
                        }

                        // Hiển thị badge ở header theo trạng thái
                        if (headerBadge) {
                            if (isPartiallyPaid) {
                                headerBadge.innerHTML = ''<span class="badge-status badge-partial">%Debt_PartialPaidStatus%</span>'';
                            } else {
                                headerBadge.innerHTML = ''<span class="badge-status badge-unpaid">%Debt_UnpaidStatus%</span>'';
                            }
                            headerBadge.style.display = "inline-block";
                        }

                        // Ẩn phần tóm tắt khi không ở chế độ xem
                        var summaryDiv = document.getElementById("modal-debt-summary");
                        if (summaryDiv) {
                            summaryDiv.style.display = "none";
                        }

                        // Hiển thị nút Thu hồi công nợ (chỉ có thu hồi, không có PayOS)
                        collectBtn.style.display = "block";
                        collectBtn.onclick = function () {
                            document.getElementById("modal-debt").classList.remove("show");
                            openCollectModal(id);
                        };

                        // Ẩn nút Thanh toán PayOS (chỉ dùng thu hồi)
                        payBtn.style.display = "none";
                    }

                    // Nếu đã có lịch sử thu hồi, không cho sửa số tiền gốc
                    if (editingHasHistory && amountInput) {
                        amountInput.disabled = true;
                        amountInput.title = "%Debt_CannotChangeAmountWithHistory%";
                    }

                    document.getElementById("modal-cust-name").value = item.CustomerName;
                    document.getElementById("modal-cust-phone").value = item.PhoneNumber || "";
                    document.getElementById("modal-cust-address").value = item.Address || "";
                    document.getElementById("modal-debt-type").value = item.DebtType;
                    document.getElementById("modal-amount").value = formatNumber(item.Amount);
                    document.getElementById("modal-note").value = item.Note || "";

                    // Fill New Fields
                    if (item.CreatedDate) {
                        var d = new Date(item.CreatedDate);
                        var dateStr = d.getFullYear() + ''-'' + String(d.getMonth() + 1).padStart(2, ''0'') + ''-'' + String(d.getDate()).padStart(2, ''0'');
                        document.getElementById("modal-created-date").value = dateStr;
                    }
                    if (item.ExpiryDate) {
                        var d = new Date(item.ExpiryDate);
                        var expStr = d.getFullYear() + ''-'' + String(d.getMonth() + 1).padStart(2, ''0'') + ''-'' + String(d.getDate()).padStart(2, ''0'');
                        document.getElementById("modal-expiry-date").value = expStr;
                    } else {
                        document.getElementById("modal-expiry-date").value = "";
                    }
                    document.getElementById("modal-payment-type").value = item.PaymentType || "";
                    document.getElementById("modal-payment-method-select").value = item.PaymentMethod || "";

                    // Handle Customer Mode (Select vs Manual)
                    var isEmployee = false;

                    // Kiểm tra xem CustomerCode có phải là EmployeeID trong list không
                    if (typeof employeeList !== ''undefined'') {
                        // So sánh string để an toàn
                        isEmployee = employeeList.some(emp => String(emp.EmployeeID) === String(item.CustomerCode));
                    }

                    var custCodeInput = document.getElementById("modal-cust-code");
                    if (custCodeInput) custCodeInput.value = item.CustomerCode || ""; // Force set value from DB
                    var btnToggle = document.getElementById("btn-toggle-manual-cust");

                    // Get dxSelectBox instance
                    var sbInstance = null;
                    try { sbInstance = $("#modal-cust-select").dxSelectBox("instance"); } catch (e) { }

                    if (isEmployee) {
                        // Chế độ chọn từ danh sách
                        isManualCustomerMode = false;
                        if (sbInstance) {
                            sbInstance.option("visible", true);
                            var matched = employeeList.find(e => String(e.EmployeeID) === String(item.CustomerCode));
                            var val = matched ? matched.EmployeeID : (Number(item.CustomerCode) || item.CustomerCode);
                            sbInstance.option("value", val);

                            // Đảm bảo input hidden cũng có giá trị (phòng trường hợp onValueChanged không chạy kịp)
                            if (matched) custCodeInput.value = matched.EmployeeID;
                        }
                        custCodeInput.style.display = "none";

                        document.getElementById("modal-cust-name").setAttribute("readonly", "readonly");
                        document.getElementById("modal-cust-phone").setAttribute("readonly", "readonly");
                        document.getElementById("modal-cust-address").setAttribute("readonly", "readonly");
                        if (btnToggle) {
                            btnToggle.innerHTML = ''<i class="bi bi-pencil"></i>'';
                            btnToggle.setAttribute("title", "Nhập thủ công");
                        }
                    } else {
                        // Chế độ nhập tay
                        isManualCustomerMode = true;
                        if (sbInstance) sbInstance.option("visible", false);
                        custCodeInput.style.display = "block";
                        custCodeInput.value = item.CustomerCode;

                        document.getElementById("modal-cust-name").removeAttribute("readonly");
                        document.getElementById("modal-cust-phone").removeAttribute("readonly");
                        document.getElementById("modal-cust-address").removeAttribute("readonly");
                        if (btnToggle) {
                            btnToggle.innerHTML = ''<i class="bi bi-arrow-left"></i>'';
                            btnToggle.setAttribute("title", "Quay lại chọn từ danh sách");
                        }
                    }
                }
            } else {
                // ADD MODE
                modalTitle.textContent = "%Debt_AddNewDebt%";
                setFormInputsEnabled(true);
                submitBtn.style.display = "block";
                deleteBtn.style.display = "none";
                payBtn.style.display = "none"; // Không hiển thị nút thanh toán khi thêm mới
                collectBtn.style.display = "none"; // Không hiển thị nút thu hồi khi thêm mới

                // Ẩn badge ở header khi thêm mới
                var headerBadge = document.getElementById("modal-debt-header-badge");
                if (headerBadge) {
                    headerBadge.style.display = "none";
                }

                // Ẩn phần tóm tắt khi thêm mới
                var summaryDiv = document.getElementById("modal-debt-summary");
                if (summaryDiv) {
                    summaryDiv.style.display = "none";
                }

                // Hiển thị phần import Excel khi thêm mới (chỉ desktop)
                var importDiv = document.getElementById("modal-debt-import");
                if (importDiv) {
                    importDiv.style.display = "block";
                }
            }

            // Ẩn phần import Excel khi Edit mode
            if (id) {
                var importDiv = document.getElementById("modal-debt-import");
                if (importDiv) {
                    importDiv.style.display = "none";
                }
            }

            document.getElementById("modal-debt").classList.add("show");
        }

        // --- 4. SUBMIT FORM (CREATE / UPDATE) ---
        var formElement = document.getElementById("modal-debt-form");
        if (formElement) {
            formElement.onsubmit = function (e) {
                e.preventDefault();
                e.stopPropagation();

                // Get Values
                var code = document.getElementById("modal-cust-code").value.trim();
                var name = document.getElementById("modal-cust-name").value.trim();
                var phone = document.getElementById("modal-cust-phone").value.trim();
                var addr = document.getElementById("modal-cust-address").value.trim();
                var type = document.getElementById("modal-debt-type").value.trim();
                var amt = parseAmountInput(document.getElementById("modal-amount").value);
                var note = document.getElementById("modal-note").value.trim();

                // New Fields
                var expiryInput = document.getElementById("modal-expiry-date").value;
                var expiry = expiryInput; // Keep YYYY-MM-DD for SQL Server safety
                var paymentType = document.getElementById("modal-payment-type").value;
                var paymentMethod = document.getElementById("modal-payment-method-select").value;

                // Client-side validation
                if (!code || code.length === 0 || code.length > 50) {
                    uiManager.showAlert({ type: "error", message: "%Debt_InvalidCustomerCode%" });
                    return false;
                }
                if (!name || name.length === 0 || name.length > 100) {
                    uiManager.showAlert({ type: "error", message: "%Debt_InvalidCustomerName%" });
                    return false;
                }
                if (!type || type.length === 0 || type.length > 50) {
                    uiManager.showAlert({ type: "error", message: "%Debt_InvalidDebtType%" });
                    return false;
                }
                if (isNaN(amt) || amt <= 0 || amt > 999999999) {
                    uiManager.showAlert({ type: "error", message: "%Debt_InvalidAmount%" });
                    return false;
                }
                if (!expiry) {
                    uiManager.showAlert({ type: "error", message: "Vui lòng chọn ngày hết hạn" });
                    return false;
                }
                if (!paymentType) {
                    uiManager.showAlert({ type: "error", message: "Vui lòng chọn loại thanh toán" });
                    return false;
                }
                if (!paymentMethod) {
                    uiManager.showAlert({ type: "error", message: "Vui lòng chọn phương thức thanh toán" });
                    return false;
                }

                if (phone.length > 20) {
                    uiManager.showAlert({ type: "error", message: "%Debt_PhoneTooLong%" });
                    return false;
                }
                if (addr.length > 255) {
                    uiManager.showAlert({ type: "error", message: "%Debt_AddressTooLong%" });
                    return false;
                }
                if (note.length > 1000) {
                    uiManager.showAlert({ type: "error", message: "%Debt_NoteTooLong%" });
                    return false;
                }

                // Define Store Name & Params
                var spName = editingId ? "sp_Debt_Update" : "sp_Debt_Insert";

                var params = [
                    "CustomerCode", code,
                    "CustomerName", name,
                    "PhoneNumber", phone,
                    "Address", addr,
                    "DebtType", type,
                    "Amount", amt,
                    "Note", note,
                    "ExpiryDate", expiry,
                    "AssignedEmployeeID", null, // Gửi null vì đã xóa trường này
                    "PaymentType", paymentType,
                    "PaymentMethod", paymentMethod
                ];

                // Nếu là Update, thêm ID, Status và PaymentDate (giữ nguyên giá trị hiện tại)
                if (editingId) {
                    // Lấy thông tin item hiện tại để giữ nguyên Status và PaymentDate
                    var currentItem = debtList.find(x => x.RecordID === editingId);
                    // Status và PaymentDate không được truyền lên để update vì SP đã chặn, logic đó để cho SP handle hoặc chỉ truyền RecordID
                    // Tuy nhiên theo logic SP_Update thì không có tham số Status và PaymentDate trong danh sách param truyền vào
                    // Kiểm tra lại SP_Update: Không nhận Status và PaymentDate.

                    params = [
                        "RecordID", editingId,
                        ...params
                    ];
                }

                showLoading();
                AjaxHPAParadise({
                    data: { name: spName, param: params },
                    success: function (res) {
                        hideLoading();
                        try {
                            // Parse kết quả trả về (có thể là JSON string)
                            var parsed = (typeof res === ''string'') ? JSON.parse(res) : res;

                            // Kiểm tra nếu có lỗi từ SP (ví dụ format: [{"result":"error", "reason":"..."}]) hoặc object trực tiếp
                            // Chuẩn hóa data: Đôi khi API trả về mảng lồng nhau
                            var data = parsed;
                            if (Array.isArray(parsed) && parsed.length > 0) {
                                data = parsed[0];
                                if (Array.isArray(data) && data.length > 0) {
                                    data = data[0];
                                }
                            }

                            // Check kết quả
                            if (data && (data.result === ''error'' || data.Result === ''error'')) {
                                uiManager.showAlert({ type: "error", message: data.reason || data.Reason || "%Debt_SystemError%" });
                                return; // Không đóng modal
                            }

                            document.getElementById("modal-debt").classList.remove("show");
                            uiManager.showAlert({ type: "success", message: "%Debt_SaveSuccess%" });
                            loadData(); // Reload grid

                        } catch (e) {
                            console.error("Parse Error:", e, res);
                            // Fallback nếu parse lỗi nhưng thực ra là success string thuần (ít gặp)
                            document.getElementById("modal-debt").classList.remove("show");
                            uiManager.showAlert({ type: "success", message: "%Debt_SaveSuccess%" });
                            loadData();
                        }
                    },
                    error: function (err) {
                        hideLoading();
                        console.error("Submit error:", err);
                        uiManager.showAlert({ type: "error", message: "%Debt_SystemError%" });
                    }
                });

                return false;
            };
        }

        // --- 5. DELETE ---
        document.getElementById("modal-debt-delete").onclick = function () {
            if (!editingId) return;

            // Lấy thông tin item để hiển thị trong confirm
            var item = debtList.find(x => x.RecordID === editingId);
            var itemInfo = item ? `${item.CustomerName} (${item.CustomerCode}) - ${formatNumber(item.Amount)} VNĐ` : '''';

            showConfirmPopup({
                title: "%Debt_ConfirmDeleteTitle%",
                message: `%Debt_ConfirmDeleteMessage%<br><small><strong>${itemInfo}</strong></small><br><small class="text-danger">%Debt_DeleteActionIrreversible%</small>`,
                icon: "bi bi-exclamation-triangle",
                YesText: "%Confirm%",
                NoText: "%Cancel%",
                onYes: function () {
                    showLoading();
                    AjaxHPAParadise({
                        data: { name: "sp_Debt_Delete", param: ["RecordID", editingId] },
                        success: function (res) {
                            console.log(editingId);
                            hideLoading();
                            document.getElementById("modal-debt").classList.remove("show");
                            uiManager.showAlert({ type: "success", message: "%Debt_DeleteSuccess%" });
                            loadData(); // Reload grid
                        },
                        error: function (err) {
                            hideLoading();
                            console.error("Delete error:", err);
                            uiManager.showAlert({ type: "error", message: "%Debt_DeleteError%" });
                        }
                    });
                }
            });
        };

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

        function createPayOSPaymentLink(orderData) {
            return getPayOSConfig().then(config => {
                var safeOrderCode = Number(orderData.orderCode);
                var safeAmount = Number(orderData.amount);
                var safeDesc = orderData.description || ''Thanh toan cong no'';
                // Đảm bảo description không vượt quá 25 ký tự (yêu cầu PayOS)
                if (safeDesc.length > 25) {
                    safeDesc = safeDesc.substring(0, 25);
                }
                // Sử dụng URL trống hoặc URL không tồn tại để tránh redirect về trang hiện tại
                // Vì đang dùng iframe embedded, không cần returnUrl/cancelUrl
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
                        items: [{ name: "Thanh toan cong no", quantity: 1, price: safeAmount }]
                    };

                    var apiUrl = config.ApiURL;
                    return fetch(apiUrl, {
                        method: ''POST'',
                        headers: {
                            ''Content-Type'': ''application/json'',
                            ''x-client-id'': config.ClientID,
                            ''x-api-key'': config.ApiKey
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

        function checkPayOSPaymentStatus(orderCode) {
            return new Promise(function (resolve, reject) {
                AjaxHPAParadise({
                    data: { name: "sp_Debt_PayOS_CheckStatus", param: ["OrderCode", orderCode] },
                    success: function (res) {
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
                        ''x-api-key'': cfg.ApiKey
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
                        var paymentModal = document.getElementById("modal-debt-payment");
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
                        var paymentModal = document.getElementById("modal-debt-payment");
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
                // Không log lỗi nếu config không tìm thấy hoặc order không tồn tại (bình thường khi polling)
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
                    var paymentModal = document.getElementById("modal-debt-payment");

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
                        var paymentModal = document.getElementById("modal-debt-payment");
                        if (paymentModal) {
                            paymentModal.classList.remove("show");
                        }
                        handlePayOSSuccess(status);
                    } else if (st === ''CANCELLED'') {
                        stopPayOSPolling();
                        // Đóng modal ngay lập tức
                        var paymentModal = document.getElementById("modal-debt-payment");
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
            var paymentModal = document.getElementById("modal-debt-payment");
            if (paymentModal) {
                paymentModal.classList.remove("show");
            }

            uiManager.showAlert({ type: "success", message: "%Debt_PaymentSuccess%" });
            try { localStorage.removeItem(''payosPendingOrder''); } catch (e) { }
            loadData();
        }

        function handlePayOSCancelled(paymentData) {
            confirmPayOSStatus(paymentData.OrderCode || paymentData.orderCode || payosLastOrderCode, "CANCELLED");

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
            var container = document.getElementById(''payos-embedded-container'');
            if (container) {
                container.innerHTML = '''';
            }

            // Đóng modal thanh toán ngay lập tức
            var paymentModal = document.getElementById("modal-debt-payment");
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
            var modal = document.getElementById("modal-debt-payment");
            var infoDiv = document.getElementById("payment-info");
            var loadingDiv = document.getElementById("payment-loading");
            var qrDiv = document.getElementById("payment-qr-container");
            var errorDiv = document.getElementById("payment-error");

            // Reset UI
            infoDiv.style.display = "block";
            loadingDiv.style.display = "none";
            qrDiv.style.display = "none";
            errorDiv.style.display = "none";

            // Fill info
            document.getElementById("payment-customer-name").textContent = debtItem.CustomerName || "-";
            document.getElementById("payment-amount").textContent = formatNumber(debtItem.Amount) + " VNĐ";
            document.getElementById("payment-debt-type").textContent = debtItem.DebtType || "-";

            modal.classList.add("show");

            // Create payment
            createDebtPayment(debtItem);
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
        function parseAmountInput(value) {
            if (!value) return 0;
            // Bỏ tất cả ký tự không phải số
            var numbers = value.replace(/\D/g, '''');
            return parseInt(numbers, 10) || 0;
        }

        function createDebtPayment(debtItem) {
            var infoDiv = document.getElementById("payment-info");
            var loadingDiv = document.getElementById("payment-loading");
            var qrDiv = document.getElementById("payment-qr-container");
            var errorDiv = document.getElementById("payment-error");

            infoDiv.style.display = "none";
            loadingDiv.style.display = "block";
            qrDiv.style.display = "none";
            errorDiv.style.display = "none";

            var amount = parseInt(debtItem.Amount) || 0;
            if (amount <= 0) {
                loadingDiv.style.display = "none";
                errorDiv.style.display = "block";
                document.getElementById("payment-error-msg").textContent = "%Debt_InvalidAmount%";
                return;
            }

            // Step 1: Create payment record
            // Tạo description tối đa 25 ký tự (yêu cầu của PayOS)
            // Ưu tiên: Nếu có ghi chú (nội dung thanh toán PayOS) → dùng ghi chú, không có → dùng DebtType (loại công nợ)
            var description = "";
            var noteValue = (debtItem.Note || "").trim();

            if (noteValue && noteValue.length > 0) {
                // Có nội dung thanh toán PayOS → dùng nội dung đó
                description = noteValue.substring(0, 25);
            } else {
                // Không có nội dung thanh toán → mặc định điền DebtType (loại công nợ)
                var debtType = (debtItem.DebtType || "").trim();
                description = debtType ? debtType.substring(0, 25) : "Thanh toan cong no";
            }
            // Đảm bảo không vượt quá 25 ký tự
            if (description.length > 25) {
                description = description.substring(0, 25);
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_Debt_PayOS_CreatePayment",
                    param: [
                        "RecordID", debtItem.RecordID,
                        "CustomerCode", debtItem.CustomerCode || "",
                        "Amount", amount,
                        "Description", description
                    ]
                },
                success: function (res) {
                    try {
                        var parsed = JSON.parse(res);
                        if (parsed && parsed.result === ''error'') {
                            loadingDiv.style.display = "none";
                            errorDiv.style.display = "block";
                            document.getElementById("payment-error-msg").textContent = parsed.reason || ''%Debt_CreatePaymentError%'';
                            return;
                        }

                        var data = (parsed.data && parsed.data[0] && parsed.data[0][0]) ? parsed.data[0][0] : parsed;

                        // ✅ Lấy dataset 2: Danh sách mã cũ cần cancel
                        var cancelList = (parsed.data && parsed.data[1]) ? parsed.data[1] : [];

                        if (data.ResultCode === -1) {
                            loadingDiv.style.display = "none";
                            errorDiv.style.display = "block";
                            document.getElementById("payment-error-msg").textContent = data.Message || ''%Debt_CreatePaymentError%'';
                            return;
                        }

                        // console.log(''PayOS Order created:'', data);

                        // ✅ Hàm xử lý tạo payment link (sẽ gọi sau khi cancel xong)
                        function proceedToCreatePaymentLink() {
                            // Step 2: Create payment link
                            createPayOSPaymentLink({
                                orderCode: data.OrderCode,
                                amount: amount,
                                description: data.Description
                            }).then(function (paymentResult) {
                                payosLastOrderCode = paymentResult.orderCode;

                                // Step 3: Update checkout URL
                                return new Promise(function (resolve, reject) {
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_Debt_PayOS_UpdateCheckoutUrl",
                                            param: [
                                                "OrderCode", paymentResult.orderCode,
                                                "CheckoutUrl", paymentResult.checkoutUrl,
                                                "PaymentLinkID", paymentResult.paymentLinkId
                                            ]
                                        },
                                        success: function () { resolve(paymentResult); },
                                        error: reject
                                    });
                                });
                            }).then(function (paymentResult) {
                                payosLastOrderCode = paymentResult.orderCode;

                                // Lưu orderCode để có thể kiểm tra trạng thái sau
                                try { localStorage.setItem(''payosPendingOrder'', String(paymentResult.orderCode)); } catch (e) { }

                                // Sử dụng iframe để hiển thị PayOS checkout (đơn giản và đáng tin cậy hơn)
                                loadingDiv.style.display = "none";
                                qrDiv.style.display = "block";

                                var container = document.getElementById(''payos-embedded-container'');
                                if (container) {
                                    // Tạo iframe để hiển thị PayOS checkout
                                    var iframe = document.createElement(''iframe'');
                                    iframe.id = ''payos-checkout-iframe'';
                                    iframe.src = paymentResult.checkoutUrl;
                                    iframe.style.cssText = ''width: 100%; min-height: 600px; border: none; border-radius: 8px;'';
                                    iframe.setAttribute(''allow'', ''payment'');

                                    // Lắng nghe message từ iframe (nếu PayOS gửi)
                                    var messageHandler = function (event) {
                                        // Chỉ xử lý message từ PayOS domain
                                        if (event.origin !== ''https://pay.payos.vn'' &&
                                            event.origin !== ''https://payos.vn'' &&
                                            !event.origin.includes(''payos'')) {
                                            return;
                                        }

                                        // console.log(''PayOS message received:'', event.data);

                                        // Xử lý các sự kiện từ PayOS
                                        if (event.data && event.data.type) {
                                            if (event.data.type === ''PAYMENT_SUCCESS'' || event.data.status === ''PAID'') {
                                                stopPayOSPolling();
                                                window.removeEventListener(''message'', messageHandler);
                                                // Đóng modal ngay lập tức
                                                var paymentModal = document.getElementById("modal-debt-payment");
                                                if (paymentModal) {
                                                    paymentModal.classList.remove("show");
                                                }
                                                handlePayOSSuccess({
                                                    OrderCode: paymentResult.orderCode,
                                                    Amount: amount
                                                });
                                            } else if (event.data.type === ''PAYMENT_CANCELLED'' || event.data.status === ''CANCELLED'') {
                                                stopPayOSPolling();
                                                window.removeEventListener(''message'', messageHandler);
                                                // Đóng modal ngay lập tức
                                                var paymentModal = document.getElementById("modal-debt-payment");
                                                if (paymentModal) {
                                                    paymentModal.classList.remove("show");
                                                }
                                                handlePayOSCancelled({ OrderCode: paymentResult.orderCode });
                                            }
                                        }
                                    };

                                    container.appendChild(iframe);
                                    window.addEventListener(''message'', messageHandler);

                                    // Bắt đầu polling để kiểm tra trạng thái (chính)
                                    startPayOSPolling(paymentResult.orderCode);
                                }
                            }).catch(function (error) {
                                loadingDiv.style.display = "none";
                                errorDiv.style.display = "block";
                                document.getElementById("payment-error-msg").textContent = error.message || "%Debt_ErrorOccurred%";
                            });
                        }

                        // ✅ XỬ LÝ CANCEL MÃ CŨ TRƯỚC KHI TẠO MÃ MỚI
                        if (cancelList && cancelList.length > 0) {
                            console.log(''🔄 Tìm thấy'', cancelList.length, ''mã cũ cần hủy cho RecordID:'', debtItem.RecordID);

                            var cancelIndex = 0;
                            function cancelNextOldCode() {
                                if (cancelIndex >= cancelList.length) {
                                    console.log(''✅ Đã hủy xong tất cả mã cũ, đang tạo mã mới...'');
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
                                            setTimeout(cancelNextOldCode, 1000); // Delay 1 giây
                                        })
                                        .catch(function (err) {
                                            console.warn(''⚠️ [PayOS] Cancel thất bại:'', item.PaymentLinkID, err.message);
                                            setTimeout(cancelNextOldCode, 1000); // Tiếp tục dù lỗi
                                        });
                                } else {
                                    setTimeout(cancelNextOldCode, 100);
                                }
                            }

                            // Bắt đầu cancel
                            cancelNextOldCode();
                        } else {
                            // Không có mã cũ cần cancel, tạo mã mới luôn
                            proceedToCreatePaymentLink();
                        }

                    } catch (e) {
                        loadingDiv.style.display = "none";
                        errorDiv.style.display = "block";
                        document.getElementById("payment-error-msg").textContent = "%Debt_DataProcessingError%";
                    }
                },
                error: function () {
                    loadingDiv.style.display = "none";
                    errorDiv.style.display = "block";
                    document.getElementById("payment-error-msg").textContent = "%Debt_ServerConnectionError%";
                }
            });
        }

        // --- DEBT COLLECTION (Thu hồi công nợ) ---
        var currentCollectDebtId = null;

        function openCollectModal(recordId) {
            currentCollectDebtId = recordId;
            var item = debtList.find(x => x.RecordID === recordId);
            if (!item) return;

            // Load payment summary
            loadPaymentSummary(recordId, function (summary) {
                var totalDebt = item.Amount || 0;
                var paidAmount = summary ? (summary.PaidAmount || 0) : 0;
                var remaining = totalDebt - paidAmount;

                // Fill info
                document.getElementById("collect-customer-name").textContent = item.CustomerName || "-";
                document.getElementById("collect-total-debt").textContent = formatNumber(totalDebt) + " VNĐ";
                document.getElementById("collect-paid-amount").textContent = formatNumber(paidAmount) + " VNĐ";
                document.getElementById("collect-remaining-debt").textContent = formatNumber(remaining) + " VNĐ";
                document.getElementById("collect-max-amount").textContent = formatNumber(remaining) + " VNĐ";

                // Reset form
                // Reset form & Apply Constraints
                var amountInput = document.getElementById("collect-amount");
                var methodSelect = document.getElementById("collect-payment-method");
                var payFullBtn = document.getElementById("collect-pay-full");

                // Default State
                amountInput.value = "";
                amountInput.disabled = false;
                methodSelect.value = "";
                methodSelect.disabled = false;
                document.getElementById("collect-note").value = "";

                if (payFullBtn) payFullBtn.style.display = "block";

                // 1. Ràng buộc theo Payment Type (FULL vs PARTIAL/BOTH)
                if (item.PaymentType === "FULL") {
                    // Nếu bắt buộc thanh toán hết -> Điền full số tiền còn lại và khóa input
                    amountInput.value = formatNumber(remaining);
                    amountInput.disabled = true;
                    if (payFullBtn) payFullBtn.style.display = "none"; // Ẩn nút "Trả hết" vì đã auto-fill
                }
                // PARTIAL / BOTH: Cho phép nhập số tiền -> Giữ nguyên default state

                // 2. Ràng buộc theo Payment Method (CASH/PAYOS vs BOTH)
                if (item.PaymentMethod === "BOTH" || !item.PaymentMethod) {
                    // Cho phép chọn "Linh hoạt" -> Enable dropdown
                    methodSelect.disabled = false;
                } else {
                    // Nếu chỉ định cụ thể (CASH hoặc PAYOS) -> Chọn và khóa dropdown
                    // Đảm bảo value khớp với option trong dropdown (CASH, PAYOS, BANK_TRANSFER...)
                    methodSelect.value = item.PaymentMethod;
                    methodSelect.disabled = true;
                }

                // Set max amount
                amountInput.max = remaining;

                // Lưu remaining amount để dùng cho nút "Thanh toán hết"
                document.getElementById("collect-amount").setAttribute("data-remaining", remaining);

                document.getElementById("modal-debt-collect").classList.add("show");
            });
        }

        function loadPaymentSummary(recordId, callback) {
            AjaxHPAParadise({
                data: { name: "sp_Debt_GetPaymentSummary", param: ["RecordID", recordId] },
                success: function (res) {
                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                        var summary = (Array.isArray(data) && data.length > 0) ? data[0] : null;
                        if (callback) callback(summary);
                    } catch (e) {
                        console.error("Parse Error", e);
                        if (callback) callback(null);
                    }
                },
                error: function (err) {
                    console.error("API Error", err);
                    if (callback) callback(null);
                }
            });
        }

        function loadPaymentHistory(recordId, callback) {
            AjaxHPAParadise({
                data: { name: "sp_Debt_GetPaymentHistory", param: ["RecordID", recordId] },
                success: function (res) {
                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                        var history = Array.isArray(data) ? data : [];
                        if (callback) callback(history);
                    } catch (e) {
                        console.error("Parse Error", e);
                        if (callback) callback([]);
                    }
                },
                error: function (err) {
                    console.error("API Error", err);
                    if (callback) callback([]);
                }
            });
        }

        // Handle collect form submit
        var collectForm = document.getElementById("modal-collect-form");
        if (collectForm) {
            collectForm.onsubmit = function (e) {
                e.preventDefault();
                e.stopPropagation();

                if (!currentCollectDebtId) return false;

                var amount = parseAmountInput(document.getElementById("collect-amount").value);
                var paymentMethod = document.getElementById("collect-payment-method").value;
                var note = document.getElementById("collect-note").value.trim();

                // Validation
                if (amount <= 0) {
                    uiManager.showAlert({ type: "error", message: "%Debt_AmountMustBeGreaterThanZero%" });
                    return false;
                }

                if (!paymentMethod) {
                    uiManager.showAlert({ type: "error", message: "%Debt_PleaseSelectPaymentMethod%" });
                    return false;
                }

                var item = debtList.find(x => x.RecordID === currentCollectDebtId);
                if (!item) return false;

                // Get current payment summary to validate
                loadPaymentSummary(currentCollectDebtId, function (summary) {
                    var totalDebt = item.Amount || 0;
                    var paidAmount = summary ? (summary.PaidAmount || 0) : 0;
                    var remaining = totalDebt - paidAmount;

                    if (amount > remaining) {
                        uiManager.showAlert({ type: "error", message: "%Debt_AmountExceedsRemaining%" });
                        return;
                    }

                    // If PayOS method, open PayOS modal instead
                    if (paymentMethod === "PAYOS") {
                        document.getElementById("modal-debt-collect").classList.remove("show");
                        // Create a temporary item with the collection amount
                        var tempItem = Object.assign({}, item);
                        tempItem.Amount = amount; // Set amount to collect amount for PayOS
                        openPaymentModal(tempItem);
                        return;
                    }

                    // Submit collection
                    showLoading();
                    var params = [
                        "RecordID", currentCollectDebtId,
                        "Amount", amount,
                        "PaymentMethod", paymentMethod,
                        "Note", note
                    ];

                    AjaxHPAParadise({
                        data: { name: "sp_Debt_CollectPayment", param: params },
                        success: function (res) {
                            hideLoading();
                            try {
                                var parsed = JSON.parse(res);
                                if (parsed && parsed.result === ''error'') {
                                    uiManager.showAlert({ type: "error", message: parsed.reason || "%Debt_CollectError%" });
                                    return;
                                }
                                document.getElementById("modal-debt-collect").classList.remove("show");
                                uiManager.showAlert({ type: "success", message: "%Debt_CollectSuccess%" });
                                loadData(); // Reload grid
                            } catch (e) {
                                console.error("Parse Error", e);
                                uiManager.showAlert({ type: "error", message: "%Debt_DataProcessingError%" });
                            }
                        },
                        error: function (err) {
                            hideLoading();
                            console.error("Submit error:", err);
                            uiManager.showAlert({ type: "error", message: "%Debt_SystemError%" });
                        }
                    });
                });
                return false;
            };
        }

        // Handle "Thanh toán hết" button
        var payFullBtn = document.getElementById("collect-pay-full");
        if (payFullBtn) {
            payFullBtn.onclick = function () {
                var amountInput = document.getElementById("collect-amount");
                var remaining = parseFloat(amountInput.getAttribute("data-remaining")) || 0;
                if (remaining > 0) {
                    amountInput.value = formatNumber(remaining);
                }
            };
        }

        // Handle view history button
        var viewHistoryBtn = document.getElementById("collect-view-history");
        if (viewHistoryBtn) {
            viewHistoryBtn.onclick = function () {
                if (!currentCollectDebtId) return;
                openPaymentHistoryModal(currentCollectDebtId);
            };
        }

        function openPaymentHistoryModal(recordId) {
            var item = debtList.find(x => x.RecordID === recordId);
            if (!item) return;

            // Close collect modal
            document.getElementById("modal-debt-collect").classList.remove("show");

            // Fill summary info
            loadPaymentSummary(recordId, function (summary) {
                var totalDebt = item.Amount || 0;
                var paidAmount = summary ? (summary.PaidAmount || 0) : 0;
                var remaining = totalDebt - paidAmount;

                document.getElementById("history-customer-name").textContent = item.CustomerName || "-";
                document.getElementById("history-total-debt").textContent = formatNumber(totalDebt) + " VNĐ";
                document.getElementById("history-total-paid").textContent = formatNumber(paidAmount) + " VNĐ";
                document.getElementById("history-remaining").textContent = formatNumber(remaining) + " VNĐ";

                var statusBadge = document.getElementById("history-status-badge");
                var badgeClass, text;
                if (remaining <= 0) {
                    badgeClass = "badge-status badge-paid";
                    text = "%Debt_PaidStatus%";
                } else if (paidAmount > 0) {
                    badgeClass = "badge-status badge-partial";
                    text = "%Debt_PartialPaidStatus%";
                } else {
                    badgeClass = "badge-status badge-unpaid";
                    text = "%Debt_UnpaidStatus%";
                }
                statusBadge.innerHTML = ''<span class="'' + badgeClass + ''">'' + text + ''</span>'';
            });

            // Load history
            var historyContainer = document.getElementById("payment-history-list");
            historyContainer.innerHTML = ''<div class="text-center py-4"><div class="spinner-border text-success" role="status"></div><p class="mt-3">%Debt_LoadingHistory%</p></div>'';

            loadPaymentHistory(recordId, function (history) {
                if (!history || history.length === 0) {
                    historyContainer.innerHTML = ''<div class="text-center py-4"><p class="text-muted">%Debt_NoHistory%</p></div>'';
                    return;
                }

                var html = '''';
                history.forEach(function (payment) {
                    var methodText = '''';
                    var methodIcon = '''';
                    switch (payment.PaymentMethod) {
                        case ''CASH'':
                            methodText = ''Tiền mặt'';
                            methodIcon = ''bi-wallet2'';
                            break;
                        case ''BANK_TRANSFER'':
                            methodText = ''Chuyển khoản'';
                            methodIcon = ''bi-bank'';
                            break;
                        case ''PAYOS'':
                            methodText = ''PayOS'';
                            methodIcon = ''bi-qr-code'';
                            break;
                        default:
                            methodText = payment.PaymentMethod || ''-'';
                    }

                    var paymentDate = payment.PaymentDate ? new Date(payment.PaymentDate).toLocaleString(''vi-VN'') : ''-'';
                    html += ''<div class="payment-history-item">'';
                    html += ''<div class="row align-items-center">'';
                    html += ''<div class="col-md-3"><div class="fw-bold text-success">'' + formatNumber(payment.Amount || 0) + '' VNĐ</div></div>'';
                    html += ''<div class="col-md-3"><div><i class="bi '' + methodIcon + '' me-1"></i>'' + methodText + ''</div></div>'';
                    html += ''<div class="col-md-3"><div class="small text-muted">'' + paymentDate + ''</div></div>'';
                    html += ''<div class="col-md-3"><div class="small">'' + (payment.Note || ''-'') + ''</div></div>'';
                    html += ''</div>'';
                    if (payment.BankDetails) {
                        html += ''<div class="row mt-2"><div class="col-12"><small class="text-muted"><i class="bi bi-info-circle me-1"></i>'' + payment.BankDetails + ''</small></div></div>'';
                    }
                    html += ''</div>'';
                });

                historyContainer.innerHTML = html;
            });

            document.getElementById("modal-payment-history").classList.add("show");
        }

        // --- EXPORT FUNCTION ---
        async function exportDebtData() {
            var subjectid = 3;
            showLoadingByClassOrID("#sp_Debt_ListCustomerDebt", "Xuất dữ liệu");
            //console.log(arg);

            let exportItem = {
                name: "File mẫu import câu hỏi",
                text: "File mẫu import câu hỏi",
                item: "Debt_List_Export",
                query: "sp_tblDebt_List_Export",
                fileName: "Info_Template.xlsx",
                getParamFunctionName: "get_sp_Template_ImportTrainingQuestion_Param",
            };
            let ExportName = exportItem.item;

            try {
                if (!exportItem.fileName) {
                    let exportTemp = await AjaxHPAParadiseAsync({
                        data: {
                            name: exportItem.item,
                            param: [],
                        },
                        success: function (resultData) { },
                    });

                    exportTemp =
                        typeof exportTemp === "string"
                            ? JSON.parse(exportTemp)
                            : exportTemp;
                    ExportName =
                        exportTemp.data[0][0][
                        Object.keys(exportTemp.data[0][0]).find(
                            (x) => x.toLowerCase() == "exportname"
                        )
                        ] ?? ExportName;
                }

                let resultData = await AjaxHPAParadiseParadiseAsync({
                    data: {
                        //name: "ExportLocationFolderSaveAsFileAsync",
                        name: "ExportLocationFolder",
                        param: [
                            "",
                            ExportName,
                            exportItem.fileName
                        ],
                    },
                    success: function (resultData) { },
                    error: function (xhr, status, error) { },
                });

                let jsonData =
                    typeof resultData === "string" ? JSON.parse(resultData) : resultData;

                if (jsonData.result == "error")
                    throw new Error(jsonData.reason ?? "Lỗi bất thường");
                //console.log(resultData)
                if (jsonData) {
                    if (
                        ParadiseOption &&
                        ParadiseOption.AppInfoPackageName ==
                        "com.vietinsoft.onshiftparadisehr"
                    ) {
                        AjaxHPAParadiseParadise({
                            data: {
                                name: "MobileOpenFileAsync",
                                param: [jsonData.FilePath, exportItem.fileName],
                            },
                            success: function (resultData) { },
                            error: function (xhr, status, error) { },
                        });
                    } else {
                        jsonData =
                            typeof jsonData.data === "string"
                                ? JSON.parse(jsonData.data)
                                : jsonData.data;

                        AjaxHPAParadiseParadise({
                            data: {
                                name: "ReadPathFileToByte",
                                param: [jsonData.FilePath],
                            },
                            success: function (result) {
                                let resultData =
                                    typeof result === "string" ? JSON.parse(result) : result;
                                saveAsFile(jsonData.FileName, resultData.data);
                            },
                            error: function (xhr, status, error) { },
                        });
                    }
                }

                HideLoadingByClassOrID("#sp_Debt_ListCustomerDebt");
            } catch (error) {
                HideLoadingByClassOrID("#sp_Debt_ListCustomerDebt");
                let direction = "up-push";
                let position = "bottom right";

                try {
                    let reason = JSON.parse(jsonData.reason);
                    reason = Array.isArray(reason) ? reason[0] : reason;
                    jsonData.reason = reason.ErrorDetail;
                } catch (jsonError) { }

                let message =
                    jsonData.result == "error" && jsonData.reason
                        ? jsonData.reason
                        : error.message;

                DevExpress.ui.notify(
                    {
                        message: message,
                        type: "error",
                        displayTime: 2500,
                    },
                    {
                        position,
                        direction,
                    }
                );
            }
        }

        // --- INIT IMPORT FILEUPLOADER ---
        var importFileUploaderInstance = null;

        // Hàm xử lý import files
        function processImportFiles(files) {
            if (!files || files.length === 0) return;

            // Xử lý từng file
            files.forEach(function (file) {
                var reader = new FileReader();
                reader.readAsDataURL(file);
                reader.onload = function () {
                    var base64Content = reader.result;
                    base64Content = base64Content.substring(base64Content.indexOf(",") + 1);

                    showLoading();

                    // Kiểm tra xem có AjaxHPAParadiseParadiseAsync không
                    if (typeof AjaxHPAParadiseParadiseAsync !== ''undefined'') {
                        AjaxHPAParadiseParadiseAsync({
                            data: {
                                name: "ImportLocationFolder",
                                param: [base64Content, file.name, "", ""]
                            },
                            success: function (resultData) {
                                hideLoading();
                                uiManager.showAlert({ type: "success", message: "%Debt_ImportSuccess%" });
                                loadData(); // Reload grid
                                // Reset file uploader sau khi import
                                if (importFileUploaderInstance) {
                                    importFileUploaderInstance.reset();
                                }
                            },
                            error: function (xhr, status, error) {
                                hideLoading();
                                console.error("Import error:", error);
                                uiManager.showAlert({ type: "error", message: "%Debt_ImportError%" });
                                // Reset file uploader sau khi lỗi
                                if (importFileUploaderInstance) {
                                    importFileUploaderInstance.reset();
                                }
                            }
                        }).catch(function (e) {
                            hideLoading();
                            console.error("Import async error:", e);
                            uiManager.showAlert({ type: "error", message: "%Debt_ServerConnectionError%" });
                            // Reset file uploader sau khi lỗi
                            if (importFileUploaderInstance) {
                                importFileUploaderInstance.reset();
                            }
                        });
                    } else {
                        // Fallback: dùng AjaxHPAParadise thông thường
                        AjaxHPAParadise({
                            data: {
                                name: "ImportLocationFolder",
                                param: [base64Content, file.name, "", ""]
                            },
                            success: function (res) {
                                hideLoading();
                                try {
                                    var parsed = JSON.parse(res);
                                    if (parsed && parsed.result === ''error'') {
                                        uiManager.showAlert({ type: "error", message: parsed.reason || "%Debt_ImportError%" });
                                        // Reset file uploader sau khi lỗi
                                        if (importFileUploaderInstance) {
                                            importFileUploaderInstance.reset();
                                        }
                                        return;
                                    }
                                    uiManager.showAlert({ type: "success", message: "%Debt_ImportSuccess%" });
                                    loadData(); // Reload grid
                                    // Reset file uploader sau khi import
                                    if (importFileUploaderInstance) {
                                        importFileUploaderInstance.reset();
                                    }
                                } catch (e) {
                                    console.error("Import parse error:", e);
                                    uiManager.showAlert({ type: "error", message: "%Debt_DataProcessingError%" });
                                    // Reset file uploader sau khi lỗi
                                    if (importFileUploaderInstance) {
                                        importFileUploaderInstance.reset();
                                    }
                                }
                            },
                            error: function (err) {
                                hideLoading();
                                console.error("Import error:", err);
                                uiManager.showAlert({ type: "error", message: "%Debt_ServerConnectionError%" });
                                // Reset file uploader sau khi lỗi
                                if (importFileUploaderInstance) {
                                    importFileUploaderInstance.reset();
                                }
                            }
                        });
                    }
                };
                reader.onerror = function () {
                    hideLoading();
                    uiManager.showAlert({ type: "error", message: "%Debt_FileReadError%" });
                    // Reset file uploader sau khi lỗi
                    if (importFileUploaderInstance) {
                        importFileUploaderInstance.reset();
                    }
                };
            });
        }




        // --- EVENTS UI ---
        document.getElementById("show-add-debt").onclick = () => openEditModal(null);
        document.getElementById("debt_empty_add_btn").onclick = () => openEditModal(null);

        // Export button
        var exportBtn = document.getElementById("btn-export-debt");
        if (exportBtn) {
            exportBtn.onclick = exportDebtData;
        }


        document.getElementById("close-modal-debt").onclick = () => document.getElementById("modal-debt").classList.remove("show");
        document.getElementById("close-modal-payment").onclick = () => {
            var paymentModal = document.getElementById("modal-debt-payment");
            if (paymentModal) {
                paymentModal.classList.remove("show");
            }
            stopPayOSPolling();

            // Cleanup PayOS embedded instance
            if (payosEmbeddedInstance && typeof payosEmbeddedInstance.destroy === ''function'') {
                try {
                    payosEmbeddedInstance.destroy();
                    payosEmbeddedInstance = null;
                } catch (e) {
                    // console.error(''Error destroying PayOS instance:'', e);
                }
            }

            // Clear container
            var container = document.getElementById(''payos-embedded-container'');
            if (container) {
                container.innerHTML = '''';
            }

            // Đánh dấu popup vừa đóng để tránh restorePayOSPendingOrder chạy
            payosPopupJustClosed = true;
            setTimeout(function () {
                payosPopupJustClosed = false;
            }, 2000);

            // Trên mobile, xóa pending order nếu người dùng đóng thủ công
            if (isMobileAndTablet()) {
                try {
                    localStorage.removeItem(''payosPendingOrder'');
                } catch (e) { }
            }
        };
        document.getElementById("close-modal-collect").onclick = () => {
            document.getElementById("modal-debt-collect").classList.remove("show");
            currentCollectDebtId = null;
        };
        document.getElementById("close-modal-history").onclick = () => {
            document.getElementById("modal-payment-history").classList.remove("show");
        };

        document.getElementById("search-debt").oninput = renderGrid;
        document.getElementById("filter-status").onchange = renderGrid;

        // Format số tiền khi nhập vào input
        var modalAmountInput = document.getElementById("modal-amount");
        if (modalAmountInput) {
            modalAmountInput.addEventListener(''input'', function (e) {
                var cursorPos = e.target.selectionStart;
                var oldValue = e.target.value;
                var newValue = formatAmountInput(oldValue);

                // Giữ vị trí cursor sau khi format
                if (newValue !== oldValue) {
                    e.target.value = newValue;
                    // Tính lại vị trí cursor sau khi format
                    var diff = newValue.length - oldValue.length;
                    e.target.setSelectionRange(cursorPos + diff, cursorPos + diff);
                }
            });

            // Format khi blur (rời khỏi input)
            modalAmountInput.addEventListener(''blur'', function (e) {
                if (e.target.value) {
                    e.target.value = formatAmountInput(e.target.value);
                }
            });
        }

        var collectAmountInput = document.getElementById("collect-amount");
        if (collectAmountInput) {
            collectAmountInput.addEventListener(''input'', function (e) {
                var cursorPos = e.target.selectionStart;
                var oldValue = e.target.value;
                var newValue = formatAmountInput(oldValue);

                // Giữ vị trí cursor sau khi format
                if (newValue !== oldValue) {
                    e.target.value = newValue;
                    // Tính lại vị trí cursor sau khi format
                    var diff = newValue.length - oldValue.length;
                    e.target.setSelectionRange(cursorPos + diff, cursorPos + diff);
                }
            });

            // Format khi blur (rời khỏi input)
            collectAmountInput.addEventListener(''blur'', function (e) {
                if (e.target.value) {
                    e.target.value = formatAmountInput(e.target.value);
                }
            });
        }

        // PayOS event listeners - wrapper để kiểm soát tốt hơn
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

        // Start
        loadData();
        restorePayOSPendingOrder();

        // --- MOBILE CONFIGURATION ---
        if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
            // Đã sửa ID header thành của trang Công Nợ
            var header = document.getElementById("header_sp_Debt_ListCustomerDebt");
            if (header && !header.querySelector(".back-btn.m-0")) {
                var newButton = document.createElement("button");
                newButton.className = "back-btn m-0";
                newButton.innerHTML = `<i class="fas fa-plus"></i>`;
                newButton.onclick = function () {
                    openEditModal(null);
                };
                header.appendChild(newButton);
            }
        }
        // import excel
        // Ngăn validation form khi click nút import
        var importBtn = document.getElementById("import-excel-fileuploader-container");
        if (importBtn) {
            importBtn.addEventListener("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                // Tắt validation của form tạm thời
                var form = document.getElementById("modal-debt-form");
                if (form) {
                    form.noValidate = true;
                }
            });
        }

        var fileUploaderts_btnImportFileTemplate = $("<div>").dxFileUploader({
            visible: false,
            multiple: true,
            dialogTrigger: "#import-excel-fileuploader-container", // <-- Khi click nút này sẽ mở chọn file
            uploadMode: "useButtons",
            allowedFileExtensions: [".xlsx", ".xls", ".csv", ".txt"],
            inputAttr: {
                accept: ".xlsx, .xls, .csv, .txt",
            },
            onValueChanged: async function (arg) {
                if (arg.value.length === 0) return;
                let result = false;
                showConfirmPopup({
                    title: "%btnAuthenticator%",
                    message: "%Import_Confirm%",
                    YesText: "%ConfirmYes%",
                    NoText: "%cancelBtn%",
                    onYes: async () => {
                        for (const file of arg.value) {
                            const functionParam = ["Info_Template"].find(
                                (x) => file.name.toLowerCase().includes(x.toLowerCase())
                            );
                            if (!file.path) {
                                const reader = new FileReader();
                                reader.readAsDataURL(file);
                                reader.onload = async function () {
                                    file.path = reader.result.split(",")[1];
                                    showLoading();
                                    try {
                                        await AjaxHPAParadiseParadiseAsync({
                                            data: {
                                                name: "ImportLocationFolder",
                                                param: [file.path, file.name, "", ""],
                                            },
                                            success: function () {
                                                hideLoading();
                                                uiManager.showAlert({
                                                    type: "success",
                                                    message: "%ImportResultSuccess%",
                                                });
                                                // Refresh dữ liệu sau khi import thành công
                                                loadData();
                                                // Reset file uploader
                                                fileUploaderts_btnImportFileTemplate
                                                    .dxFileUploader("instance")
                                                    .reset();
                                            },
                                            error: function (xhr, status, error) {
                                                hideLoading();
                                                uiManager.showAlert({
                                                    type: "error",
                                                    message: "%Debt_ImportError%",
                                                });
                                                // Reset file uploader khi lỗi
                                                fileUploaderts_btnImportFileTemplate
                                                    .dxFileUploader("instance")
                                                    .reset();
                                            }
                                        });
                                    } catch (e) {
                                        hideLoading();
                                        console.error("Import error:", e);
                                        uiManager.showAlert({
                                            type: "error",
                                            message: "%Debt_ServerConnectionError%",
                                        });
                                        // Reset file uploader khi lỗi
                                        fileUploaderts_btnImportFileTemplate
                                            .dxFileUploader("instance")
                                            .reset();
                                    }
                                };
                                reader.onerror = function () {
                                    hideLoading();
                                    uiManager.showAlert({
                                        type: "error",
                                        message: "%Debt_FileReadError%",
                                    });
                                    // Reset file uploader khi lỗi
                                    fileUploaderts_btnImportFileTemplate
                                        .dxFileUploader("instance")
                                        .reset();
                                };
                            } else {
                                showLoading();
                                try {
                                    await AjaxHPAParadiseParadiseAsync({
                                        data: {
                                            name: "ImportLocationFolder",
                                            param: [file.path, file.name, "", ""],
                                        },
                                        success: function () {
                                            hideLoading();
                                            uiManager.showAlert({
                                                type: "success",
                                                message: "%ImportResultSuccess%",
                                            });
                                            // Refresh dữ liệu sau khi import thành công
                                            loadData();
                                            // Reset file uploader
                                            fileUploaderts_btnImportFileTemplate
                                                .dxFileUploader("instance")
                                                .reset();
                                        },
                                        error: function (xhr, status, error) {
                                            hideLoading();
                                            uiManager.showAlert({
                                                type: "error",
                                                message: "%Debt_ImportError%",
                                            });
                                            // Reset file uploader khi lỗi
                                            fileUploaderts_btnImportFileTemplate
                                                .dxFileUploader("instance")
                                                .reset();
                                        }
                                    });
                                } catch (e) {
                                    hideLoading();
                                    console.error("Import error:", e);
                                    uiManager.showAlert({
                                        type: "error",
                                        message: "%Debt_ServerConnectionError%",
                                    });
                                    // Reset file uploader khi lỗi
                                    fileUploaderts_btnImportFileTemplate
                                        .dxFileUploader("instance")
                                        .reset();
                                }
                            }
                        }
                    },
                    onNo: function () {
                        // Reset file uploader nếu hủy
                        fileUploaderts_btnImportFileTemplate
                            .dxFileUploader("instance")
                            .reset();
                    }
                });
            },

        });
        $("body").append(fileUploaderts_btnImportFileTemplate);

        // =====================================================================
        // EMPLOYEE MANAGEMENT LOGIC - Quản lý thông tin nhân viên
        // =====================================================================
        var employeeList = [];
        var isManualCustomerMode = false;

        // Load danh sách nhân viên từ tblEmployee
        function loadEmployeeList() {
            AjaxHPAParadise({
                data: { name: "sp_Debt_Employee_GetInfo", param: ["LoginID", LoginID] },
                success: function (res) {
                    try {
                        var parsed = JSON.parse(res);
                        var data = parsed.data;
                        if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) {
                            employeeList = data[0];
                        } else if (Array.isArray(data)) {
                            employeeList = data;
                        } else {
                            employeeList = [];
                        }
                        populateEmployeeSelects();
                    } catch (e) {
                        console.error("Error loading employee list:", e);
                        employeeList = [];
                    }
                },
                error: function (err) {
                    console.error("API Error loading employees:", err);
                    employeeList = [];
                }
            });
        }

        // Điền dữ liệu vào dropdown khách hàng
        // Điền dữ liệu vào dropdown khách hàng (Sử dụng DevExtreme dxSelectBox)
        // Điền dữ liệu vào dropdown khách hàng (Sử dụng DevExtreme dxSelectBox)
        function populateEmployeeSelects() {
            var $select = $("#modal-cust-select");

            // Dispose instance cũ nếu có để tránh lỗi duplicate hoặc memory leak
            try {
                var instance = $select.dxSelectBox("instance");
                if (instance) {
                    instance.dispose();
                    $select.empty();
                }
            } catch (ex) { }

            try {
                $select.dxSelectBox({
                    dataSource: employeeList,
                    displayExpr: function (item) {
                        return item ? (item.FullName + " (" + item.EmployeeID + ")") : "";
                    },
                    valueExpr: "EmployeeID",
                    searchEnabled: true,
                    searchExpr: ["FullName", "EmployeeID", "MobilePhone"],
                    placeholder: "-- Chọn khách hàng hoặc tìm kiếm --",
                    showClearButton: true,
                    width: "100%",
                    onValueChanged: function (e) {
                        // FIX: Tìm item trực tiếp từ data source để đảm bảo chính xác
                        var selectedVal = e.value;
                        var selectedItem = null;

                        if (selectedVal && employeeList && employeeList.length > 0) {
                            selectedItem = employeeList.find(function (x) { return x.EmployeeID == selectedVal; });
                        }

                        // Fallback lấy từ widget nếu tìm không thấy
                        if (!selectedItem) selectedItem = e.component.option("selectedItem");

                        var custCodeInput = document.getElementById("modal-cust-code");
                        var custNameInput = document.getElementById("modal-cust-name");
                        var custPhoneInput = document.getElementById("modal-cust-phone");
                        var custAddrInput = document.getElementById("modal-cust-address");

                        if (selectedItem) {
                            // Khi chọn: Tự động điền các trường khác
                            if (custCodeInput) custCodeInput.value = selectedItem.EmployeeID || "";
                            if (custNameInput) custNameInput.value = selectedItem.FullName || "";
                            if (custPhoneInput) custPhoneInput.value = selectedItem.MobilePhone || "";
                            if (custAddrInput) custAddrInput.value = selectedItem.Address || selectedItem.tmpAddress || "";
                        } else {
                            // Khi clear: Chỉ thực hiện nếu là thao tác của người dùng
                            if (e.event && !isManualCustomerMode) {
                                if (custCodeInput) custCodeInput.value = "";
                                if (custNameInput) custNameInput.value = "";
                                if (custPhoneInput) custPhoneInput.value = "";
                                if (custAddrInput) custAddrInput.value = "";
                            }
                        }
                    }
                });
            } catch (e) { console.error("Error init dxSelectBox", e); }
        }



        // Toggle giữa chọn khách hàng và nhập thủ công
        document.getElementById("btn-toggle-manual-cust").addEventListener("click", function () {
            isManualCustomerMode = !isManualCustomerMode;
            var custSelect = document.getElementById("modal-cust-select");
            var custCode = document.getElementById("modal-cust-code");
            var custName = document.getElementById("modal-cust-name");
            var custPhone = document.getElementById("modal-cust-phone");
            var custAddress = document.getElementById("modal-cust-address");

            if (isManualCustomerMode) {
                // Chuyển sang chế độ nhập thủ công
                custSelect.style.display = "none";
                custCode.style.display = "block";

                custName.removeAttribute("readonly");
                custPhone.removeAttribute("readonly");
                custAddress.removeAttribute("readonly");

                this.innerHTML = ''<i class="bi bi-arrow-left"></i>'';
                this.setAttribute("title", "Quay lại chọn từ danh sách");

                // Clear values để nhập mới
                custSelect.value = "";
                custCode.value = "";
                custName.value = "";
                custPhone.value = "";
                custAddress.value = "";
            } else {
                // Chuyển về chế độ chọn từ danh sách
                // custSelect.style.display = "block"; // Input group handle display
                custSelect.style.display = "block";
                custCode.style.display = "none";

                custName.setAttribute("readonly", "readonly");
                custPhone.setAttribute("readonly", "readonly");
                custAddress.setAttribute("readonly", "readonly");

                this.innerHTML = ''<i class="bi bi-pencil"></i>'';
                this.setAttribute("title", "Nhập thủ công");

                custCode.value = "";
                custName.value = "";
                custPhone.value = "";
                custAddress.value = "";
            }
        });

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
        function initializeCreatedDate() {
            var today = new Date();
            var dateStr = today.getFullYear() + ''-'' +
                String(today.getMonth() + 1).padStart(2, ''0'') + ''-'' +
                String(today.getDate()).padStart(2, ''0'');
            document.getElementById("modal-created-date").value = dateStr;
        }

        // Hook vào function showAddModal để khởi tạo ngày tạo
        var originalShowAddModal = window.showAddModal || function () {
            editingId = null;
            editingHasHistory = false;
            editingOriginalAmount = 0;
            document.getElementById("modal-debt-form").reset();
            initializeCreatedDate();

            // Reset chế độ khách hàng
            isManualCustomerMode = false;
            document.getElementById("modal-cust-select").style.display = "block";
            document.getElementById("modal-cust-code").style.display = "none";
            document.getElementById("modal-cust-name").setAttribute("readonly", "readonly");
            document.getElementById("modal-cust-phone").setAttribute("readonly", "readonly");
            document.getElementById("modal-cust-address").setAttribute("readonly", "readonly");
            document.getElementById("btn-toggle-manual-cust").innerHTML = ''<i class="bi bi-pencil"></i>'';

            document.getElementById("modal-debt").classList.add("show");
        };

        // Load danh sách nhân viên khi trang được load
        loadEmployeeList();

        // ==========================================
        // PAYOS CANCELLATION FUNCTIONS - sử dụng paymentLinkID
        // ==========================================

        // Hàm hủy thanh toán PayOS - sử dụng getPayOSConfig() đã có sẵn (giống testPay.html)
        function cancelPayOSPaymentLink(paymentLinkID, cancellationReason) {
            return getPayOSConfig().then(function (config) {
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
                        ''x-api-key'': config.ApiKey
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

        function cancelOldPayOSTransactions(recordId) {
            var params = ["Status", "CANCELLED"];
            if (recordId) {
                params.push("RecordID");
                params.push(recordId);
            }

            AjaxHPAParadise({
                data: { name: "sp_Debt_PayOS_GetCancelledTransactions", param: params },
                success: function (res) {
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

        // Hàm này sẽ được gọi TRONG luồng tạo payment mới, không auto-run

        HideLoadingByClassOrID("#sp_Debt_ListCustomerDebt");
    })();
</script>
'
 SELECT @html AS html;
--  exec sp_GenerateHTMLScript 'sp_Debt_ListCustomerDebt_html'
END
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/2]: [dbo].[sp_Debt_ListCustomerDebt]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_Debt_ListCustomerDebt]
 @LoginID int = null,
 @LanguageID varchar(2) = 'VN',
 @EmployeeID Varchar(20) = null
AS
 select html from tblHtmlScriptCache where TableName = 'sp_Debt_ListCustomerDebt_html' and ScreenType = -1 and LanguageID = @LanguageID
GO

