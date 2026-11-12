/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-1
  MÀN HÌNH / MENU    : Quà tặng -> Lịch sử nhận quà (MnuPRL451)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[sp_gift_history_gift_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_gift_history_gift_html]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX);
    SET @html = N'
<style>
    /* --- CSS SYSTEM VARS --- */
    :root {
        --training-primary: #2E7D32;
        --training-danger: #E53935;
        --training-warning: #FBC02D;
        --training-info: #0288D1;
        --training-purple: #6c5ce7;
    }

    #sp_gift_history_gift {
        min-height: 100vh;
        margin-bottom: 3rem;
        font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
    }

    #sp_gift_history_gift .header-section { border-bottom: 2px solid rgba(128, 128, 128, 0.2); }

    /* Search & Inputs */
    #sp_gift_history_gift .search-box { position: relative; flex: 1; }
    #sp_gift_history_gift .search-icon { position: absolute; width: 0; left: 1rem; top: 50%; transform: translateY(-50%); opacity: 0.6; }
    #sp_gift_history_gift .search-input { padding-left: 2.5rem !important; height: 48px; border-radius: 12px; border: 2px solid rgba(128, 128, 128, 0.2); }
    #sp_gift_history_gift .search-input:focus { border-color: var(--training-primary); outline: none; }

    #sp_gift_history_gift .form-select {
        border: 2px solid rgba(128, 128, 128, 0.2);
        border-radius: 12px;
        height: 48px;
        padding: 0.375rem 2.25rem 0.375rem 0.75rem;
    }

    /* Grid Styling */
    #sp_gift_history_gift .grid-container { border-radius: 12px; overflow: hidden; border: 2px solid rgba(128, 128, 128, 0.2); }
    #sp_gift_history_gift .dx-datagrid { border: none !important; background: unset; }
    #sp_gift_history_gift .dx-datagrid-headers .dx-header-row > td {
        font-weight: 700 !important; padding: 1rem !important; height: 60px !important;
        vertical-align: middle !important; border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }
    #sp_gift_history_gift .dx-datagrid-row > td {
        padding: 0.75rem 1rem !important; vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }

    /* Status Badges */
    #sp_gift_history_gift .badge-status { padding: 0.35rem 0.85rem; border-radius: 6px; font-size: 0.75rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; }
    #sp_gift_history_gift .badge-pending { background: rgba(251, 192, 45, 0.15); color: #F57F17; }
    #sp_gift_history_gift .badge-approved { background: rgba(46, 125, 50, 0.15); color: var(--training-primary); }
    #sp_gift_history_gift .badge-rejected { background: rgba(229, 57, 53, 0.1); color: var(--training-danger); }
    #sp_gift_history_gift .badge-request { background: rgba(108, 92, 231, 0.15); color: var(--training-purple); }

    #sp_gift_history_gift .product-thumb { width: 40px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #eee; background: #fff; }

    /* Modal Styles */
    #sp_gift_history_gift .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.6); z-index: 1050; align-items: center; justify-content: center; }
    #sp_gift_history_gift .modal-overlay.show { display: flex; }
    #sp_gift_history_gift .modal-content { background: var(--bs-body-bg, white); color: var(--bs-body-color, black); border-radius: 16px; width: 90%; max-width: 500px; padding: 0; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
    #sp_gift_history_gift .modal-header-c { padding: 1.25rem; display: flex; justify-content: space-between; align-items: center; }
    #sp_gift_history_gift .modal-body-c { padding: 1.5rem; }
    #sp_gift_history_gift .info-row { display: flex; justify-content: space-between; margin-bottom: 1rem; padding-bottom: 0.5rem; }
    #sp_gift_history_gift .info-label { color: #666; font-size: 0.9rem; }
    #sp_gift_history_gift .info-val { font-weight: 600; text-align: right; }

    @media (max-width: 768px) {
        #sp_gift_history_gift .header-section { display: none; }
    }
</style>

<div id="sp_gift_history_gift">
    <div class="header-section pb-3 mb-4">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3">
            <div>
                <h3 class="mb-1 fw-bold">
                    <i class="bi bi-clipboard-check-fill me-2"></i>%ApproveRedemptionHeader%
                </h3>
                <p class="mb-0 opacity-75">%RedemptionApprovalDesc%</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary px-3" onclick="loadHistoryData()">
                    <i class="bi bi-arrow-clockwise me-1"></i> %RefreshButton%
                </button>
            </div>
        </div>
    </div>

    <div class="mb-4">
        <div class="row g-3">
            <div class="col-md-8">
                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" class="form-control search-input" id="search-history" placeholder="%RedemptionSearchPlaceholder%...">
                </div>
            </div>
            <div class="col-md-4">
                <select class="form-select" id="filter-status">
                    <option value="" selected >%AllStatusesFilter%</option>
                    <option value="Chờ nhận">%PendingReceiptStatus%</option>
                    <option value="Đã nhận">%ReceivedStatus%</option>
                    <option value="Trả hàng">%ReturnStatusFilter%</option>
                    <option value="Yêu cầu hủy">%RequestCancelStatus%</option>
                    <option value="Yêu cầu trả hàng">%RequestReturnStatus%</option>
                </select>
            </div>
        </div>
    </div>

    <div class="grid-container">
        <div id="hist_loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">%LoadingDataStatus%</p>
        </div>
        <div id="hist_grid_wrapper" style="display: none;">
            <div id="hist_grid"></div>
        </div>
    </div>

    <div class="modal-overlay" id="modal-detail">
        <div class="modal-content">
            <div class="modal-header-c">
                <h5 class="mb-0 fw-bold">%RequestDetailsLink%</h5>
                <button type="button" class="btn-close" onclick="closeModalDetail()"></button>
            </div>
            <div class="modal-body-c">
                <div class="text-center mb-4">
                    <img id="d-img" src="" style="width: 80px; height: 80px; object-fit: contain; border-radius: 50%; background: #f5f5f5; padding: 5px;">
                    <h5 class="mt-2 fw-bold" id="d-prodName">...</h5>
                    <div class="text-danger fw-bold" id="d-coins">0 Coin</div>
                </div>
                <div class="info-row">
                    <span class="info-label">%Qty%:</span>
                    <span class="info-val" id="d-quantity">...</span>
                </div>
                <div class="info-row">
                    <span class="info-label">%colEmployeeName%:</span>
                    <span class="info-val" id="d-empName">...</span>
                </div>
                <div class="info-row">
                    <span class="info-label">%RedemptionDateLabel%:</span>
                    <span class="info-val" id="d-date">...</span>
                </div>
                <div class="info-row" style="border: none;">
                    <span class="info-label">%Status%:</span>
                    <span class="info-val" id="d-status">...</span>
                </div>

                <div id="action-buttons" class="mt-4 pt-3 border-top d-flex gap-2 justify-content-end" style="display: none;">
                    <button id="btn-modal-reject" class="btn btn-danger flex-grow-1"></button>
                    <button id="btn-modal-approve" class="btn btn-success flex-grow-1"></button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
        var header = document.getElementById("header_sp_gift_history_gift");
        if (header && !header.querySelector(".back-btn.m-0")) {
            var newButton = document.createElement("button");
            newButton.className = "back-btn m-0";
            newButton.innerHTML = `<i class="bi bi-arrow-clockwise"></i>`;
            newButton.onclick = function() { loadHistoryData(); };
            header.appendChild(newButton);
        }
    }

(function () {
    var historyData = [];
    var gridInstance = null;
    var currentId = null;

    function formatNumber(num) { return num ? num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") : "0"; }
    function showLoading() { document.body.style.cursor = ''wait''; }
    function hideLoading() { document.body.style.cursor = ''default''; }

    function normalizeVietnamese(str) {
        if (!str) return '''';
        str = String(str);
        return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    }

    // --- 1. LOAD DATA ---
    window.loadHistoryData = function() {
        document.getElementById("hist_loading").style.display = "block";
        document.getElementById("hist_grid_wrapper").style.display = "none";

        AjaxHPAParadise({
            data: { name: "sp_Gift_History_Admin_Get", param: ["Mode", 1] },
            success: function(res) {
                try {
                    var parsed = JSON.parse(res);
                    var data = parsed.data;
                    if(Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) data = data[0];
                    historyData = Array.isArray(data) ? data : [];
                    renderGrid();
                    document.getElementById("hist_loading").style.display = "none";
                    document.getElementById("hist_grid_wrapper").style.display = "block";
                    loadHistoryImagesBackground();
                } catch(e) {
                    document.getElementById("hist_loading").style.display = "none";
                    document.getElementById("hist_grid_wrapper").style.display = "block";
                }
            },
            error: function() {
                document.getElementById("hist_loading").style.display = "none";
                document.getElementById("hist_grid_wrapper").style.display = "block";
            }
        });
    }

    function loadHistoryImagesBackground() {
        if (!historyData || historyData.length === 0) return;
        var visibleHistoryIds = [];
        if (gridInstance) {
            var visibleItems = gridInstance.option("dataSource");
            if (Array.isArray(visibleItems)) visibleHistoryIds = visibleItems.map(function(item) { return item.HistoryID; });
        }
        if (visibleHistoryIds.length === 0) visibleHistoryIds = historyData.map(function(item) { return item.HistoryID; });
        if (visibleHistoryIds.length > 100) visibleHistoryIds = visibleHistoryIds.slice(0, 100);
        if (visibleHistoryIds.length === 0) return;

        var historyIdsParam = visibleHistoryIds.join('','');

        AjaxHPAParadise({
            data: { name: "sp_Gift_History_Admin_Get", param: ["Mode", 2, "HistoryIDs", historyIdsParam] },
            success: function(res) {
                try {
                    var parsed = JSON.parse(res);
                    var images = parsed.data;
                    if(Array.isArray(images) && images.length > 0 && Array.isArray(images[0])) images = images[0];
                    if (!Array.isArray(images)) images = [];
      images.forEach(function(imgData) {
                        var historyItem = historyData.find(function(item) { return item.HistoryID == imgData.HistoryID; });
                        if (historyItem && imgData.ImageURL) historyItem.ImageURL = imgData.ImageURL;
                    });
                    if (gridInstance) renderGrid();
                } catch(e) {}
            }
        });
    }

    // --- 2. RENDER GRID ---
    function renderGrid() {
        var searchText = document.getElementById("search-history").value;
        var filterStatus = document.getElementById("filter-status").value;
        var normalizedSearch = normalizeVietnamese(searchText);

        var filtered = historyData.filter(item => {
            var matchText = true;
            if (normalizedSearch && normalizedSearch.trim() !== '''') {
                var normalizedLoginName = normalizeVietnamese(item.LoginName || '''');
                var normalizedEmployeeCode = normalizeVietnamese(item.EmployeeCode || '''');
                var normalizedProductName = normalizeVietnamese(item.ProductName || '''');
                var normalizedFullName = normalizeVietnamese(item.FullName || '''');
                matchText = normalizedLoginName.includes(normalizedSearch) || normalizedEmployeeCode.includes(normalizedSearch) || normalizedProductName.includes(normalizedSearch) || normalizedFullName.includes(normalizedSearch);
            }

            var currentSt = item.Status_History;
            var matchStatus = true;
            if (filterStatus !== "") {
                if (filterStatus === "Chờ nhận" && (currentSt === "Chờ nhận" || currentSt === "Chờ duyệt")) matchStatus = true;
                else matchStatus = currentSt === filterStatus;
            }
            return matchText && matchStatus;
        });

        if (gridInstance) {
            gridInstance.option("dataSource", filtered);
        } else {
            gridInstance = $("#hist_grid").dxDataGrid({
                dataSource: filtered,
                keyExpr: "HistoryID",
                showBorders: false,
                hoverStateEnabled: true,
                columnAutoWidth: true,
                paging: { pageSize: 20 },
                pager: { showPageSizeSelector: true, allowedPageSizes: [20, 50, 100], showInfo: true, visible: true },
                columns: [
                    { caption: "%RedemptionDateLabel%", dataField: "OrderDate", dataType: "date", format: "dd/MM/yyyy HH:mm", width: 160 },
                    { caption: "%colEmployeeName%", cellTemplate: function(container, options) { $("<div>").addClass("fw-bold").text(options.data.FullName || "Unknown").appendTo(container); } },
                    {
                        caption: "%GiftsLabel%",
                        cellTemplate: function(container, options) {
                            var d = options.data;
                            var img = d.ImageURL && d.ImageURL.trim() !== '''' ? d.ImageURL : ''data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'';
                            var wrapper = $("<div>").addClass("d-flex align-items-center gap-2");
                            $("<img>").addClass("product-thumb").attr("src", img).appendTo(wrapper);
                            $("<div>").text(d.ProductName || "").appendTo(wrapper);
                            wrapper.appendTo(container);
                        }
                    },
                    { caption: "Coin", dataField: "TotalCoins", width: 80, alignment: "right", cellTemplate: function(c, o) { $("<span>").addClass("text-danger fw-bold").text(formatNumber(o.value)).appendTo(c); } },
                    {
                        caption: "%Status%", dataField: "Status_History", width: 150, alignment: "center",
                        cellTemplate: function(container, options) {
                            var st = options.value;
             var cls = "badge-pending";
                            var icon = "bi-hourglass-split";

                            if(st === "Đã nhận") { cls = "badge-approved"; icon = "bi-check-circle-fill"; }
                            else if(st === "Trả hàng" || st === "Đã hủy" || st === "Đã trả hàng") { cls = "badge-rejected"; icon = "bi-x-circle-fill"; }
                            else if(st.indexOf("Yêu cầu") >= 0) { cls = "badge-request"; icon = "bi-exclamation-circle-fill"; }

                            $("<span>").addClass("badge-status " + cls).html(`<i class="bi ${icon}"></i> ${st}`).appendTo(container);
                        }
                    }
                ],
                onRowClick: function(e) { openModalDetail(e.data); },
            }).dxDataGrid("instance");
        }
    }

    // --- 3. ACTIONS ---
    window.processRequest = function(histId, targetStatus) {
        if(!histId || !targetStatus) return;

        var confirmMsg = "";
        if (targetStatus === "Đã nhận") confirmMsg = "%ConfirmReceiptQuestion%";
        else if (targetStatus === "Đã hủy") confirmMsg = "%ConfirmCancelAndRefundQuestion%";
        else if (targetStatus === "Trả hàng") confirmMsg = "%ConfirmReturnAndRefundQuestion%";
        else if (targetStatus === "Chờ nhận") confirmMsg = "%RejectCancelQuestion%";
        else confirmMsg = "%ConfirmStatusChangeQuestion%: " + targetStatus + "?";

        showConfirmPopup({
            title: "%Confirm%",
            message: confirmMsg,
            icon: "bi bi-question-circle",
            YesText: "%ConfirmButtonGeneric%",
            NoText: "%Cancel%",
            onYes: function() {
                showLoading();
                AjaxHPAParadise({
                    data: {
                        name: "sp_Gift_History_UpdateStatus",
                        param: ["HistoryID", histId, "NewStatus", targetStatus]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "%UpdateSuccessMessage%: " + targetStatus });
                        closeModalDetail();
                        loadHistoryData();
                    },
                    error: function() { uiManager.showAlert({ type: "error", message: "%GenericErrorMessage%" }); },
                    complete: function() { hideLoading(); }
                });
            }
        });
    };

    // --- 4. OPEN MODAL & SETUP BUTTONS ---
    window.openModalDetail = function(data) {
        currentId = data.HistoryID;
        window.currentId = data.HistoryID;
        document.getElementById("d-img").src = data.ImageURL || ''https://via.placeholder.com/80'';
        document.getElementById("d-prodName").textContent = data.ProductName;
        document.getElementById("d-coins").textContent = formatNumber(data.TotalCoins) + " Coin";
        document.getElementById("d-empName").textContent = data.FullName;
        document.getElementById("d-date").textContent = new Date(data.OrderDate).toLocaleString(''vi-VN'');
        document.getElementById("d-quantity").textContent = formatNumber(data.Quantity || 1);

        var st = data.Status_History;
        var stEl = document.getElementById("d-status");
        stEl.textContent = st;
        stEl.className = "info-val";

        if(st === "Đã nhận") stEl.classList.add("text-success");
        else if(st.includes("Hủy") || st.includes("Trả")) stEl.classList.add("text-danger");
        else stEl.classList.add("text-warning");

        // --- XỬ LÝ NÚT BẤM ---
        var btnGroup = document.getElementById("action-buttons");
        var btnApprove = document.getElementById("btn-modal-approve"); // Nút Bên Phải
        var btnReject = document.getElementById("btn-modal-reject");   // Nút Bên Trái

        // Reset clone node để xóa event cũ
        var newApprove = btnApprove.cloneNode(true);
        var newReject = btnReject.cloneNode(true);
        btnApprove.parentNode.replaceChild(newApprove, btnApprove);
        btnReject.parentNode.replaceChild(newReject, btnReject);
        btnApprove = newApprove;
        btnReject = newReject;

        // Mặc định ẩn
        btnGroup.style.display = "none";
        btnApprove.style.display = "none";
        btnReject.style.display = "none";

        // Lưu HistoryID vào biến local để các closure có thể truy cập
        var histId = data.HistoryID;

        // CASE 1: Đơn mới -> Nút Trái: Hủy / Nút Phải: Duyệt Giao
        if (st === "Chờ nhận" || st === "Chờ duyệt") {
            btnGroup.style.setProperty("display", "flex", "important");

            // Phải: Xác nhận đã giao
            btnApprove.style.display = "block";
            btnApprove.className = "btn btn-success flex-grow-1";
            btnApprove.innerHTML = ''<i class="bi bi-check-circle me-1"></i> %AcknowledgeReceiptButton%'';
            btnApprove.onclick = function() { processRequest(histId, "Đã nhận"); };

            // Trái: Hủy đơn
            btnReject.style.display = "block";
            btnReject.className = "btn btn-danger flex-grow-1";
            btnReject.innerHTML = ''<i class="bi bi-x-circle me-1"></i> %CancelOrderButton%'';
            btnReject.onclick = function() { processRequest(histId, "Đã hủy"); };
        }
        // CASE 2: Yêu cầu hủy -> Nút Trái: Từ chối / Nút Phải: Đồng ý Hủy
        else if (st === "Yêu cầu hủy") {
            btnGroup.style.setProperty("display", "flex", "important");

            // Phải: Xác nhận hủy (Nguy hiểm -> Đỏ)
            btnApprove.style.display = "block";
            btnApprove.className = "btn btn-danger flex-grow-1";
            btnApprove.innerHTML = ''<i class="bi bi-check-circle me-1"></i> %ConfirmCancelButton%'';
            btnApprove.onclick = function() { processRequest(histId, "Đã hủy"); };

            // Trái: Từ chối hủy (Quay về Chờ nhận -> Xám)
            btnReject.style.display = "block";
            btnReject.className = "btn btn-secondary flex-grow-1";
            btnReject.innerHTML = ''<i class="bi bi-arrow-counterclockwise me-1"></i> %RejectCancelButton%'';
            btnReject.onclick = function() { processRequest(histId, "Chờ nhận"); };
        }
        // CASE 3: Yêu cầu trả -> Nút Trái: Từ chối / Nút Phải: Đồng ý Trả
        else if (st === "Yêu cầu trả hàng") {
            btnGroup.style.setProperty("display", "flex", "important");

            // Phải: Xác nhận trả (Nguy hiểm -> Đỏ)
            btnApprove.style.display = "block";
            btnApprove.className = "btn btn-danger flex-grow-1";
            btnApprove.innerHTML = ''<i class="bi bi-check-circle me-1"></i> %ConfirmReturnButton%'';
            btnApprove.onclick = function() { processRequest(histId, "Trả hàng"); };

            // Trái: Từ chối trả (Quay về Đã nhận -> Xanh)
            btnReject.style.display = "block";
            btnReject.className = "btn btn-success flex-grow-1";
            btnReject.innerHTML = ''<i class="bi bi-arrow-counterclockwise me-1"></i> %RejectReturnButton%'';
            btnReject.onclick = function() { processRequest(histId, "Đã nhận"); };
        }

        document.getElementById("modal-detail").classList.add("show");
    };

    window.closeModalDetail = function() {
        document.getElementById("modal-detail").classList.remove("show");
    };

    document.getElementById("search-history").oninput = renderGrid;
    document.getElementById("filter-status").onchange = renderGrid;
    document.getElementById("modal-detail").addEventListener(''click'', function(e){
        if(e.target === this) closeModalDetail();
    });

    loadHistoryData();
    if(typeof HideLoadingByClassOrID === ''function'') HideLoadingByClassOrID("#sp_gift_history_gift");
})();
</script>
    '

    SELECT @html AS html;


END
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/2]: [dbo].[sp_gift_history_gift]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_gift_history_gift]
   @LoginID VARCHAR(50) = NULL,
   @LanguageID varchar(2) = 'VN',
   @EmployeeID Varchar(20) = null
AS
	select html
from tblHtmlScriptCache
where TableName = 'sp_gift_history_gift_html' and ScreenType = -1 and LanguageID = @LanguageID
GO

