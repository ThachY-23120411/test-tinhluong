CREATE PROCEDURE [dbo].[sp_KPIProcessCustomer_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'EN',
    @isWeb INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
 DECLARE @html NVARCHAR(MAX);
    SET @html = N'
<div id="customerKanbanComponent">
    <style>
        .card-info-item.support {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* Có người hỗ trợ */
        .card-info-item.support.has-support {
            color: #16a34a;
        }

        .card-info-item.support.has-support i {
            color: #16a34a;
        }

        /* Chưa có */
        .card-info-item.support.no-support {
            color: #9ca3af;
        }

        .card-info-item.support.no-support i {
            color: #9ca3af;
        }

        /* Dot indicator */
        .support-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            margin-left: auto;
        }

        /* xanh */
        .has-support .support-dot {
            background: #16a34a;
        }

        /* xám */
        .no-support .support-dot {
            background: #d1d5db;
        }

        #customerKanbanComponent {
            font-family: -apple-system, BlinkMacSystemFont, '' Segoe UI'', Roboto, '' Helvetica Neue'', Arial, sans-serif;
            padding: 15px;
        }

        #customerKanbanComponent * {
            box-sizing: border-box;
        }

        #customerKanbanComponent .kanban-container {
            max-width: 100%;
            margin: 0 auto;
        }

        #customerKanbanComponent .kanban-header {
            padding: 0;
            border-radius: 0;
            margin-bottom: 10px;
            border: none;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        #customerKanbanComponent .kanban-header h1 {
            color: #09563c;
            font-size: 28px;
            font-weight: 600;
            display: none;
            align-items: center;
            gap: 12px;
        }

        #customerKanbanComponent .header-actions {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
            width: 100%;
        }

        #customerKanbanComponent .date-filter {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            padding: 0;
            border-radius: 0;
            flex-wrap: wrap;
        }

        #customerKanbanComponent .date-filter .date-input-group {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        #customerKanbanComponent .date-filter label {
            font-size: 11px;
            font-weight: 600;
            color: #64748b;
            margin: 0;
            white-space: nowrap;
        }

        #customerKanbanComponent .date-filter input {
            border-radius: 6px;
            padding: 4px 8px;
            font-size: 13px;
            outline: none;
            width: 130px;
        }

        #customerKanbanComponent .date-filter input:focus {
            border-color: #198754;
        }

        #customerKanbanComponent .view-all-checkbox {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 11px;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 10px;
        }

        #customerKanbanComponent .filter-checkbox-group {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        #customerKanbanComponent .view-all-checkbox input[type="checkbox"] {
            cursor: pointer;
            width: 15px;
            height: 15px;
            accent-color: #198754;
        }



        #customerKanbanComponent .btn-primary {
            background: #198754;
            color: white;
        }

        #customerKanbanComponent .btn-refresh {
            color: #198754;
            border: 2px solid #198754;
        }

        #customerKanbanComponent .search-box-wrapper {
            display: flex;
            align-items: center;
            position: relative;
            width: 230px;
            margin-right: 12px;
        }

        #customerKanbanComponent .search-box-wrapper i {
            position: absolute;
            left: 6px;
            color: #6c757d;
            font-size: 14px;
            pointer-events: none;
            z-index: 1;
        }

        #customerKanbanComponent .kanban-search-input {
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 6px 6px 6px 20px;
            font-size: 13px;
            outline: none;
            width: 100%;
            transition: all 0.25s ease;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        #customerKanbanComponent .kanban-search-input::placeholder {
            color: #adb5bd;
            font-size: 12px;
        }

        #customerKanbanComponent .kanban-search-input:focus {
            border-color: #198754;
            box-shadow: 0 0 0 0.2rem rgba(25, 135, 84, 0.15);
        }

        #customerKanbanComponent .kanban-search-input:hover:not(:focus) {
            border-color: #ced4da;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }

        #customerKanbanComponent .btn-clear-search {
            position: absolute;
            right: 10px;
            background: none;
            border: none;
            cursor: pointer;
            color: #9ca3af;
            font-size: 16px;
            display: none;
            padding: 2px 6px;
            z-index: 2;
            transition: color 0.2s ease;
            text-align: center;
        }

        #customerKanbanComponent .btn-clear-search:hover {
            color: #e74c3c;
        }

        #customerKanbanComponent .btn-clear-search i {
            position: static;
        }

        #customerKanbanComponent .kanban-board {
            display: flex;
            gap: 20px;
            overflow-x: auto;
            padding-bottom: 20px;
            position: relative;
        }

        #customerKanbanComponent .kanban-scroll-arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            z-index: 20;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(25, 135, 84, 0.9);
            border: none;
            color: white;
            font-size: 20px;
            cursor: pointer;
            display: none;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            transition: all 0.2s ease;
            padding: 0;
        }

        #customerKanbanComponent .kanban-scroll-arrow.right {
            right: 10px;
        }

        #customerKanbanComponent .kanban-scroll-arrow.left {
            left: 10px;
        }

        #customerKanbanComponent .kanban-board.has-overflow-right .kanban-scroll-arrow.right {
            display: flex;
        }

        #customerKanbanComponent .kanban-board.has-overflow-left .kanban-scroll-arrow.left {
            display: flex;
        }

        #customerKanbanComponent .kanban-scroll-arrow:hover {
            background: rgba(25, 135, 84, 1);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            transform: translateY(-50%) scale(1.05);
        }

        #customerKanbanComponent .kanban-columns-wrapper {
            display: flex;
            flex-direction: column;
            width: 100%;
        }

        #customerKanbanComponent .kanban-content {



            display: flex;
            gap: 10px;
            flex: 1;
            overflow-x: auto;
            padding-bottom: 20px;
        }

        #customerKanbanComponent .kanban-column {
            flex: 0 0 220px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            backdrop-filter: blur(10px);
            height: 80vh;
            display: flex;
            flex-direction: column;
            transition: background 0.3s ease;
        }

        #customerKanbanComponent .column-header {
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            flex-shrink: 0;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        #customerKanbanComponent .column-title {
            font-size: 13px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #customerKanbanComponent .column-count {
            background: #198754;
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

       #customerKanbanComponent .column-cards {
            display: flex;
            flex-direction: column;
            gap: 12px;
            min-height: 100px;
            flex-grow: 1;
            overflow-y: auto;
            overflow-x: hidden;
            max-height: calc(100% - 80px);
        }

        #customerKanbanComponent .customer-card {
            border-radius: 8px;
            padding: 12px;
            cursor: move;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border-left: 4px solid #198754;
        }

        #customerKanbanComponent .customer-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        #customerKanbanComponent .customer-card.dragging {
            opacity: 0.5;
            transform: rotate(5deg);
        }

        #customerKanbanComponent .kanban-column.drag-over {
            background: rgba(255, 255, 255, 0.2);
            border: 2px dashed rgba(255, 255, 255, 0.5);
        }

        #customerKanbanComponent .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        #customerKanbanComponent .card-name {
            font-size: 13px;
            font-weight: 600;

            margin-bottom: 4px;
        }

        #customerKanbanComponent .card-company {
            font-size: 12px;
        }

        #customerKanbanComponent .card-info {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 12px;
        }

        #customerKanbanComponent .card-info-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;

        }

        #customerKanbanComponent .card-info-item i {
            /* color: #667eea; - Removed color for text icons */
            width: 16px;
        }

        /* #customerKanbanComponent .card-content {
            font-size: 13px;

            padding: 8px;
            border-radius: 6px;
            margin-bottom: 8px;
            max-height: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
        } */

        #customerKanbanComponent .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        #customerKanbanComponent .card-assignee {
   display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;

        }

        #customerKanbanComponent .card-date {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;

        }

        #customerKanbanComponent .card-actions {
            display: flex;
            gap: 8px;
        }

        #customerKanbanComponent .btn-icon {
            background: none;
            border: none;
            cursor: pointer;
            padding: 4px;
            border-radius: 4px;
            transition: all 0.2s ease;

        }

        #customerKanbanComponent .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
        }

        #customerKanbanComponent .badge-contact {
            background: #d4edda;
            color: #155724;
        }

        #customerKanbanComponent .badge-no-contact {
            background: #f8d7da;
            color: #721c24;
        }

        @keyframes kanbanFadeIn {
            from {
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        #customerKanbanComponent .loading {

            text-align: center;
            padding: 40px;
            color: #198754;
            font-size: 18px;
        }

        #customerKanbanComponent .kanban-skeleton-column {
            flex: 0 0 220px;
            background: rgba(255, 255, 255, 0.06);
            border-radius: 12px;
            height: 80vh;
            display: flex;
            flex-direction: column;
            gap: 12px;
            padding: 12px;
        }

        #customerKanbanComponent .skeleton-line,
        #customerKanbanComponent .skeleton-pill {
            background: linear-gradient(90deg, #ececec 25%, #f5f5f5 50%, #ececec 75%);
            background-size: 200% 100%;
            animation: kanbanSkeletonShimmer 1.4s infinite;
        }

        #customerKanbanComponent .skeleton-line {
            border-radius: 8px;
            height: 12px;
        }

        #customerKanbanComponent .skeleton-pill {
            border-radius: 999px;
            height: 24px;
            width: 52px;
        }

        #customerKanbanComponent .kanban-skeleton-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }

        #customerKanbanComponent .kanban-skeleton-title {
            flex: 1;
            max-width: 120px;
            height: 14px;
        }

        #customerKanbanComponent .kanban-skeleton-card {
            background: rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        #customerKanbanComponent .kanban-skeleton-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
        }

        #customerKanbanComponent .kanban-skeleton-body {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        #customerKanbanComponent .kanban-skeleton-body .skeleton-line:nth-child(1) {
            width: 78%;
        }

        #customerKanbanComponent .kanban-skeleton-body .skeleton-line:nth-child(2) {
            width: 60%;
        }

        #customerKanbanComponent .kanban-skeleton-body .skeleton-line:nth-child(3) {
            width: 86%;
        }

        #customerKanbanComponent .col-loading-skeleton {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding: 8px;
        }

        #customerKanbanComponent .col-loading-skeleton-card {
            background: rgba(0, 0, 0, 0.03);
            border-radius: 8px;
            padding: 14px 10px;
            min-height: 96px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 8px;
        }

        #customerKanbanComponent .col-loading-skeleton-card .skeleton-line:nth-child(1) {
            width: 72%;
        }

        #customerKanbanComponent .col-loading-skeleton-card .skeleton-line:nth-child(2) {
            width: 56%;
        }

        #customerKanbanComponent .col-loading-skeleton-card .skeleton-line:nth-child(3) {
            width: 84%;
        }

        @keyframes kanbanSkeletonShimmer {
            0% {
                background-position: 200% 0;
            }

            100% {
                background-position: -200% 0;
            }
        }

        #customerKanbanComponent .empty-state {
            text-align: center;
            padding: 40px 20px;

        }


        #customerKanbanComponent .empty-state i {
            font-size: 48px;
            margin-bottom: 5px;
            opacity: 0.5;
        }

        /* Scrollbar styling */
        #customerKanbanComponent .kanban-board::-webkit-scrollbar {
            height: 8px;
        }

        #customerKanbanComponent .kanban-board::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.05);
            border-radius: 4px;
        }

        #customerKanbanComponent .kanban-board::-webkit-scrollbar-thumb {
            background: #198754;
            border-radius: 4px;
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
            }
        }

        @media (max-width: 992px) {
            #customerKanbanComponent {
                padding: 15px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                height: 500px;
            }

            #customerKanbanComponent .kanban-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            #customerKanbanComponent .header-actions {
                width: 100%;
            }

            #customerKanbanComponent .date-filter {
                width: 100%;
            }

        }

        @media (max-width: 768px) {
            #customerKanbanComponent {
                padding: 10px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                height: 450px;
                padding: 12px;
            }

            #customerKanbanComponent .column-header {
                padding: 12px;
                margin-bottom: 8px;
            }

            #customerKanbanComponent .column-title {
                font-size: 14px;
            }

            #customerKanbanComponent .column-count {
                padding: 3px 10px;
                font-size: 11px;
            }

            #customerKanbanComponent .customer-card {
                padding: 12px;
            }

            #customerKanbanComponent .card-name {
                font-size: 14px;
            }

            #customerKanbanComponent .card-company {
                font-size: 12px;
            }

            #customerKanbanComponent .card-info-item {
                font-size: 12px;
            }

            #customerKanbanComponent .date-filter .date-input-group {
                flex: 0 0 calc(50% - 6px);
            }

            #customerKanbanComponent .date-filter input {
                width: 100%;
            }
        }

        @media (max-width: 576px) {
            #customerKanbanComponent {
                padding: 8px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 200px;
                height: 400px;
                padding: 10px;
            }

            #customerKanbanComponent .column-header {
                padding: 10px;
                margin-bottom: 6px;
            }

            #customerKanbanComponent .column-title {
                font-size: 13px;
            }

            #customerKanbanComponent .customer-card {
                padding: 10px;
            }

            #customerKanbanComponent .card-name {
                font-size: 13px;
            }

            #customerKanbanComponent .card-company {
                font-size: 11px;
            }

            #customerKanbanComponent .card-info-item {
                font-size: 11px;
                gap: 4px;
            }

            #customerKanbanComponent .date-filter .date-input-group {
                flex: 1 1 auto;
            }

            #customerKanbanComponent .date-filter label {
                font-size: 11px;
            }

            #customerKanbanComponent .date-filter input {
                width: 100%;
                padding: 3px 6px;
                font-size: 12px;
            }


            #customerKanbanComponent .form-control {
                padding: 8px 10px;
                font-size: 13px;
            }
        }
   </style>
    <div class="kanban-container">
        <div class="kanban-header">
            <div class="header-actions">
                <div class="date-filter">
                    <div class="d-flex" style="align-items: center; gap:5px;">
                        <div id="P18F22C9ACED845F4BDA48BAF1F6C8DD6"></div>
                    </div>
                    <div id="PF21A8E6224C94FB5A94E862AEDA0DC46"></div>
                    <div class="date-input-group">
                        <label for="kanbanFromDate">Từ:</label>
                        <!-- <input type="date" id="kanbanFromDate"> -->
                        <div id="P59A6A90D898E4345813592F4BDF3847D"></div>
                    </div>
                    <div class="date-input-group">
                        <label for="kanbanToDate">Đến:</label>
                        <!-- <input type="date" id="kanbanToDate"> -->
                        <div id="P3F439F29229C4DFEB0D31C9198E35FC4"></div>
                    </div>
                    <button class="btn btn-success btn-sm px-3" onclick="loadKanbanData()"
                        style="height: 30px; padding: 0 15px;">
                        <i class="bi bi-filter"></i> Làm mới
                    </button>

                </div>
            </div>

            <div class="search-box-wrapper">
                <i class="bi bi-search"></i>
                <input type="text" id="kanbanSearchInput" class="kanban-search-input form-control"
                    placeholder="Tìm kiếm theo tên, công ty, SĐT..." oninput="handleKanbanSearch(this)">
                <button class="btn-clear-search" id="btnClearSearch" onclick="clearKanbanSearch()" title="Xóa tìm kiếm">
                    <i class="bi bi-x-circle-fill"></i>
                </button>
            </div>
            <button class="btn btn-success" style="    padding: 6px 12px;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                    font-weight: 500;
                    font-size: 12px;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    width: 120px;
                    transition: all 0.3s ease;
                    background-color: #198754;
                    color: white;" onclick="openAddCustomerModal()">
                + Thêm mới
            </button>
        </div>
        <!-- <div
            style="display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-top:10px; margin-bottom: 10px;"> -->
        <!-- <div class="filter-checkbox-group">
                <label class="view-all-checkbox">
                    <input type="checkbox" id="viewAllCheckbox" onchange="handleViewAllChange()">
                    <span>Xem tất cả ngày</span>
                </label>
                <label class="view-all-checkbox">
                    <input type="checkbox" id="onlyMeCheckbox" onchange="handleOnlyMeChange()">
                    <span>Của tôi</span>
                </label>
            </div> -->

        <!-- </div> -->
    </div>

    <div class="kanban-board" id="kanbanBoard">
        <div class="loading">
            <i class="bi bi-hourglass-split"></i> Đang tải dữ liệu...
        </div>
    </div>
</div>

<!-- Customer Detail Modal -->
<div class="modal fade" id="customerDetailModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Chi tiết khách hàng</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                    onclick="closeCustomerDetailModal()"></button>
            </div>
            <div class="modal-body" id="customerDetailBody">
                <!-- Content will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
                    onclick="closeCustomerDetailModal()">Đóng</button>
                <button type="button" class="btn btn-primary" onclick="editCustomer()">
                    <i class="bi bi-pencil"></i> Chỉnh sửa
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
        let _activeStatusID = -1;
        // Khai báo biến toàn cục (Data sẽ được load từ API)
        var statusData = [];
        var customerData = [];

        // Lazy loading config
        var COLUMN_PAGE_SIZE = 10;
        var SERVER_PAGE_SIZE = 10;
        var MIN_INITIAL_SKELETON_MS = 350;
        var MIN_COLUMN_SKELETON_MS = 220;
        var columnDataMap = {};   // { statusId: [customers] }
        var columnPageMap = {};   // { statusId: currentPage }
        var statusServerStateMap = {}; // { statusId: { nextCursor, hasMore, loading } }
        var currentLoadToken = 0;
        var isKanbanLoading = false;
        var currentFilterState = { fromDate: '''', toDate: '''', viewAll: true, employeeIDs: null, searchText: '''' };

        var currentCustomer = null;

        // Initialize global avatar cache
        if (!window.GlobalEmployeeAvatarCache) {
            window.GlobalEmployeeAvatarCache = {};
        }
        if (!window.GlobalEmployeeAvatarPending) {
            window.GlobalEmployeeAvatarPending = {};
        }

        let DataSegmented_DateTimePF21A8E6224C94FB5A94E862AEDA0DC46 = [
            { ID: -1, Name: "%All%" },
            { ID: 1, Name: "%Today%" },
            { ID: 2, Name: "%ThisMonth%" },
            { ID: 3, Name: "%ThisQuater%" },
            { ID: 4, Name: "%ThisYear%" }
        ];

        // Shared customer datasource (cross-menu)
        if (!window.KanbanSharedCustomerStore) {
            window.KanbanSharedCustomerStore = (function () {
                var map = {};
                var listeners = [];
                var hasDx = !!(window.DevExpress && window.DevExpress.data);
                var dxStore = hasDx ? new window.DevExpress.data.ArrayStore({ key: ''CRM_CustomerID'', data: [] }) : null;
                var dxDataSource = hasDx ? new window.DevExpress.data.DataSource({ store: dxStore }) : null;

                function emit(payload) {
                    listeners.slice().forEach(function (fn) {
                        try { fn(payload || {}); } catch (e) { console.warn(''[KanbanSharedCustomerStore] listener error'', e); }
                    });
                }

                function normalizeId(item) {
                    if (!item) return null;
                    var id = item.CRM_CustomerID;
                    return (id === null || id === undefined || id === '''') ? null : String(id);
                }

                function rebuildDxData() {
                    if (!dxStore || !dxDataSource) return;
                    var all = Object.keys(map).map(function (k) { return map[k]; });
                    dxStore = new window.DevExpress.data.ArrayStore({ key: ''CRM_CustomerID'', data: all });
                    dxDataSource = new window.DevExpress.data.DataSource({ store: dxStore });
                }

                return {
                    getAll: function () {
                        return Object.keys(map).map(function (k) { return map[k]; });
                    },
                    getById: function (id) {
                        return map[String(id)] || null;
                    },
                    replaceAll: function (rows, meta) {
                        map = {};
                        (rows || []).forEach(function (item) {
                            var id = normalizeId(item);
                            if (id !== null) map[id] = item;
                        });

                        rebuildDxData();
                        emit({ type: ''replaceAll'', items: this.getAll(), meta: meta || {} });
                    },
                    upsert: function (item, meta) {
                        var id = normalizeId(item);
                        if (id === null) return;
                        map[id] = Object.assign({}, map[id] || {}, item);
                        rebuildDxData();
                        emit({ type: ''upsert'', item: map[id], meta: meta || {} });
                    },
                    upsertMany: function (rows, meta) {
                        (rows || []).forEach(function (item) {
                            var id = normalizeId(item);
                            if (id !== null) map[id] = Object.assign({}, map[id] || {}, item);
                        });
                        rebuildDxData();
                        emit({ type: ''upsertMany'', items: rows || [], meta: meta || {} });
                    },
                    remove: function (id, meta) {
                        delete map[String(id)];
                        rebuildDxData();
                        emit({ type: ''remove'', id: String(id), meta: meta || {} });
                    },
                    removeByCompanyId: function (companyId, meta) {
                        if (companyId === null || companyId === undefined || companyId === '''') return;

                        var targetCompanyId = String(companyId);
                        var removedIds = [];

                        Object.keys(map).forEach(function (key) {
                            var item = map[key];
                            if (item && String(item.Company_ID) === targetCompanyId) {
                                removedIds.push(String(item.CRM_CustomerID));
                                delete map[key];
                            }
                        });

                        if (removedIds.length === 0) return;

                        rebuildDxData();
                        emit({ type: ''removeByCompanyId'', companyId: targetCompanyId, removedIds: removedIds, meta: meta || {} });
                    },
                    subscribe: function (fn) {
                        if (typeof fn !== ''function'') return function () { };
                        listeners.push(fn);
                        return function () {
                            listeners = listeners.filter(function (x) { return x !== fn; });
                        };
                    },
     getDataSource: function () {
                        return dxDataSource;
                    }
                };
            })();
        }

        var _sharedStoreUnsubscribe = null;
        function _bindSharedCustomerStore() {
            if (_sharedStoreUnsubscribe || !window.KanbanSharedCustomerStore) return;
            _sharedStoreUnsubscribe = window.KanbanSharedCustomerStore.subscribe(function (payload) {
                console.log(''[Kanban Listener]Received payload: '', payload);

                if (payload && payload.meta && payload.meta.source === ''processcus'') {
                    console.log(''[Kanban Listener]Ignoring own update from processcus'');
                    return;
                }

                if (payload.type === ''replaceAll'') {
                    customerData = (payload.items || []).slice();
                } else if (payload.type === ''upsert'' && payload.item) {
                    var upsertId = String(payload.item.CRM_CustomerID);
                    var idx = customerData.findIndex(function (c) { return String(c.CRM_CustomerID) === upsertId; });
                    if (idx >= 0) {
                        customerData[idx] = Object.assign({}, customerData[idx], payload.item);
                    } else {
                        customerData.push(payload.item);
                    }
                } else if (payload.type === ''upsertMany'') {
                    (payload.items || []).forEach(function (it) {
                        var itemId = String(it.CRM_CustomerID);
                        var i = customerData.findIndex(function (c) { return String(c.CRM_CustomerID) === itemId; });
                        if (i >= 0) customerData[i] = Object.assign({}, customerData[i], it);
                        else customerData.push(it);
                    });
                } else if (payload.type === ''remove'') {
                    customerData = customerData.filter(function (c) { return String(c.CRM_CustomerID) !== String(payload.id); });
                } else if (payload.type === ''removeByCompanyId'') {
                    customerData = customerData.filter(function (c) { return String(c.Company_ID) !== String(payload.companyId); });
                }

                renderKanbanBoard();
            });
        }

        '
            + (select loadUI from tblCommonControlType_Signed where UID = 'P18F22C9ACED845F4BDA48BAF1F6C8DD6')
        + (select loadUI from tblCommonControlType_Signed where UID = 'P59A6A90D898E4345813592F4BDF3847D')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P3F439F29229C4DFEB0D31C9198E35FC4')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PF21A8E6224C94FB5A94E862AEDA0DC46')
        +N'

        let instanceDateTime = window["InstanceSegmented_DateTimePF21A8E6224C94FB5A94E862AEDA0DC46"];

        window.onSegmentedChanged_DateTimePF21A8E6224C94FB5A94E862AEDA0DC46 = function (id, data) {
            _activeStatusID = id;

            const dateGroups = document.querySelectorAll(''#customerKanbanComponent .date-input-group'');

            if (id === -1) {
                // Ẩn nút filter FromDate,ToDate
                dateGroups.forEach(el => el.style.display = ''none'');
                updateDateFilterState();
            } else {
                // Hiện ra
                dateGroups.forEach(el => el.style.display = ''flex'');

                // Tính toán ngày
                let fromDate = '''', toDate = '''';
                const now = new Date();

                if (id === 1) { // Today
                    fromDate = toDate = now.toISOString().split(''T'')[0];
                } else if (id === 2) { // This Month
                    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
                    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                    fromDate = firstDay.toISOString().split(''T'')[0];
                    toDate = lastDay.toISOString().split(''T'')[0];
                } else if (id === 3) { // This Quarter
                    const q = Math.floor(now.getMonth() / 3);
                    const firstDay = new Date(now.getFullYear(), q * 3, 1);
                    const lastDay = new Date(now.getFullYear(), (q + 1) * 3, 0);
                    fromDate = firstDay.toISOString().split(''T'')[0];
                    toDate = lastDay.toISOString().split(''T'')[0];
                } else if (id === 4) { // This Year
                    const firstDay = new Date(now.getFullYear(), 0, 1);
                    const lastDay = new Date(now.getFullYear(), 11, 31);
                    fromDate = firstDay.toISOString().split(''T'')[0];
                    toDate = lastDay.toISOString().split(''T'')[0];
                }

                // Load ngày lên ô input
                loadDateFilter(fromDate, toDate);

                // Chạy hàm loadData để load danh sách (thông qua updateDateFilterState)
                updateDateFilterState();
            }
        };

        instanceDateTime.setData(DataSegmented_DateTimePF21A8E6224C94FB5A94E862AEDA0DC46);
        instanceDateTime.setValue(_activeStatusID);
        const dateGroups = document.querySelectorAll(''#customerKanbanComponent .date-input-group'');
        dateGroups.forEach(el => el.style.display = ''none'');


        // Load DataSource: sp_EmployeeListDataMultiSelectSelectBox
        if ("sp_EmployeeListDataMultiSelectSelectBox" && "sp_EmployeeListDataMultiSelectSelectBox".trim() !== "") {
            loadDataSourceCommon("EmployeeID", "sp_EmployeeListDataMultiSelectSelectBox", function (data) {
                // Data được shared qua callback
            });
        }

        function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
            if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
                console.warn("[loadDataSourceCommon] Missing columnName or dataSourceSP");
                return;
            }

            const dataSourceKey = "DataSource_" + columnName;
            // Sử dụng format: columnNameDataSourceLoaded để tương thích với code hiện tại
            const loadedKey = columnName + "DataSourceLoaded";

            // Kiểm tra nếu đã load rồi thì không load lại

            if (window[loadedKey] === true) {
                if (typeof onSuccessCallback === "function") {
                    onSuccessCallback(window[dataSourceKey] || []);
                }
                return;
            }

            // Kiểm tra nếu đang load thì đợi
            if (window[loadedKey] === "loading") {
                // Đợi một chút rồi thử lại
                setTimeout(function () {
                    loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                }, 100);

                return;
            }


            // Đánh dấu đang load để tránh load trùng lặp
            window[loadedKey] = "loading";

            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: dataSourceSP,
                        param: ["LoginID", LoginID, "LanguageID", LanguageID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;

                        window[dataSourceKey] = (json.data && json.data[0]) || [];
                        window[loadedKey] = true;

                        // Ưu tiên lấy từ json response (nếu API trả về explicit)
                        // Sau đó mới fallback query dataSchema
                        let idField = json.valueExpr;
                        let nameField = json.displayExpr;

                        if (!idField || !nameField) {
                            if (json.dataSchema && json.dataSchema[0]) {
                                const schema = json.dataSchema[0];
                                if (!idField) idField = schema[0]?.name;
                                if (!nameField) nameField = schema[1]?.name;
                            }
                        }

                        window["DataSourceIDField_" + columnName] = idField || "ID";
                        window["DataSourceNameField_" + columnName] = nameField || "Name";

                        const data = window[dataSourceKey];

                        // callback trước
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback(data, json);
                        }

                        // resolve sau
                        resolve(data);
                    },
                    error: function (err) {
                        console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                        window[loadedKey] = false;

                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback([]);
                        }

                        reject(err);
                    }
                });
            });
        }

        function loadDateFilter(fromdate, todate) {
            let obj = {
                "FromDate": fromdate,
                "ToDate": todate
            }
            ' +(select loadData from tblCommonControlType_Signed where UID = 'P59A6A90D898E4345813592F4BDF3847D')
                + (select loadData from tblCommonControlType_Signed where UID = 'P3F439F29229C4DFEB0D31C9198E35FC4') +N'
        }

        // Remove Vietnamese accents for search
        function removeAccents(str) {
            if (!str) return '''';
            return str
                .normalize(''NFD'')
                .replace(/[\u0300-\u036f]/g, '''') // Remove diacritics
                .toLowerCase();
        }

        var searchKeyword = '''';
        var searchDebounceTimer = null;

        function handleKanbanSearch(input) {
            var val = input.value.trim();
            var clearBtn = document.getElementById(''btnClearSearch'');
            if (clearBtn) clearBtn.style.display = val ? ''block'' : ''none'';

            clearTimeout(searchDebounceTimer);
            searchDebounceTimer = setTimeout(function () {
                searchKeyword = val;
                loadKanbanData();
            }, 180);
        }

        function clearKanbanSearch() {
            searchKeyword = '''';
            var input = document.getElementById(''kanbanSearchInput'');
            if (input) input.value = '''';
            var clearBtn = document.getElementById(''btnClearSearch'');
            if (clearBtn) clearBtn.style.display = ''none'';
            loadKanbanData();
        }

        // Update date filter state manually based on current period selection
        function updateDateFilterState() {
            const isViewAll = (_activeStatusID === -1);

            if (isViewAll) {
                InstanceFromDateP59A6A90D898E4345813592F4BDF3847D.option(''disabled'', true);
                InstanceToDateP3F439F29229C4DFEB0D31C9198E35FC4.option(''disabled'', true);
            } else {
                InstanceFromDateP59A6A90D898E4345813592F4BDF3847D.option(''disabled'', false);
                InstanceToDateP3F439F29229C4DFEB0D31C9198E35FC4.option(''disabled'', false);
            }

            // Load data with the new state
            loadKanbanData();
        }

        // Initialize on page load

        _bindSharedCustomerStore();

        // Bootstrap modals are managed by the framework, no need for manual onclick handling

        function mergeCustomerRows(existingRows, newRows) {
            var map = {};
            (existingRows || []).forEach(function (row) {
                if (row && row.CRM_CustomerID !== null && row.CRM_CustomerID !== undefined) {
                    map[String(row.CRM_CustomerID)] = row;
                }
            });
            (newRows || []).forEach(function (row) {
                if (row && row.CRM_CustomerID !== null && row.CRM_CustomerID !== undefined) {
                    map[String(row.CRM_CustomerID)] = row;
                }
            });
            return Object.keys(map).map(function (k) { return map[k]; });
        }

        function sortCustomersByColumnRules(rows) {
            (rows || []).sort(function (a, b) {
                var aEmployeeIDs = String(a.EmployeeIDs || '''').trim().toLowerCase();
                var bEmployeeIDs = String(b.EmployeeIDs || '''').trim().toLowerCase();
                var aHasEmployee = aEmployeeIDs !== '''' && aEmployeeIDs !== ''null'' && aEmployeeIDs !== ''undefined'';
                var bHasEmployee = bEmployeeIDs !== '''' && bEmployeeIDs !== ''null'' && bEmployeeIDs !== ''undefined'';

                if (!aHasEmployee && bHasEmployee) return -1;
                if (aHasEmployee && !bHasEmployee) return 1;

                var aCreated = new Date(a.CreatedDate || 0).getTime() || 0;
                var bCreated = new Date(b.CreatedDate || 0).getTime() || 0;
                if (bCreated !== aCreated) return bCreated - aCreated;

                var aId = Number(a.CRM_CustomerID || 0);
                var bId = Number(b.CRM_CustomerID || 0);
                return bId - aId;
            });
        }

        function getStatusServerState(statusId) {
            var sid = String(statusId);
            if (!statusServerStateMap[sid]) {
                statusServerStateMap[sid] = {
                    nextCursor: null,
                    hasMore: true,
                    loading: false,
                    lastRequestKey: null,
                    lastRequestAt: 0
                };
            }
            return statusServerStateMap[sid];
        }

        function buildCursorFromLastRow(rows) {
            if (!rows || !rows.length) return null;
            var last = rows[rows.length - 1] || {};
            var timeVal = last.CreatedDate || last.UpdatedDate || '''';
            var idVal = last.CRM_CustomerID || '''';
            if (!timeVal && !idVal) return null;
            return String(timeVal) + '' | '' + String(idVal);
        }

        function extractNextCursor(dataObject, rows, pageSize) {
            if (dataObject && (dataObject.nextCursor || dataObject.NextCursor || dataObject.cursor || dataObject.Cursor)) {
                return dataObject.nextCursor || dataObject.NextCursor || dataObject.cursor || dataObject.Cursor;
            }

            var data2 = dataObject && dataObject.data && dataObject.data[2];
            if (Array.isArray(data2) && data2[0]) {
                var item = data2[0];
                return item.nextCursor || item.NextCursor || item.cursor || item.Cursor || null;
            }

            if (!Array.isArray(rows) || rows.length < pageSize) return null;
            return buildCursorFromLastRow(rows);
        }

        function waitMs(ms) {
            return new Promise(function (resolve) { setTimeout(resolve, ms); });
        }

        async function loadData(fromDate, toDate, viewAll = true, employeeIDs = null, cursor = null, pageSize = SERVER_PAGE_SIZE, append = false, statusId = null, loadToken = null, suppressRender = false) {
            var statusState = null;
            if (statusId !== null && statusId !== undefined && statusId !== '''') {
                statusState = getStatusServerState(statusId);
                statusState.loading = true;
            }

            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: "sp_KPIGetProcessStatus",
                 param: [

                            ''LoginID'', window.UserID,
                            ''LanguageID'', window.LanguageID || ''VN'',
                            ''FromDate'', fromDate || '''',
                            ''ToDate'', toDate || '''',
                            ''ViewAll'', viewAll ? 1 : 0,
                            ''EmployeeID'', employeeIDs ? employeeIDs : InstanceEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.option("value") || '''',
                            ''SearchText'', currentFilterState.searchText || '''',
                            ''Status'', (statusId !== null && statusId !== undefined) ? statusId : '''',
                            ''Cursor'', cursor || '''',
                            ''Limit'', pageSize
                        ]
                    },
                    success: function (data) {
                        try {
                            if (loadToken !== null && loadToken !== currentLoadToken) {
                                if (statusState) statusState.loading = false;
                                resolve(false);
                                return;
                            }

                            if (typeof data == "string" && !IsNullOrEmpty(data)) {
                                data = data.includes("{") ? data : EncryptionStringDecryption(data);
           }
                            let dataObject = JSON.parse(data);
                            var nextStatusData = dataObject.data[0] || [];
                            var nextCustomerData = dataObject.data[1] || [];

                            if ((!append || statusData.length === 0) && (statusId === null || statusId === undefined || statusId === '''')) {
                                statusData = nextStatusData;
                            }

                            if (!append) {
                                customerData = nextCustomerData;
                            } else {
                                customerData = mergeCustomerRows(customerData, nextCustomerData);
                            }

                            if (statusState) {
                                var sid = String(statusId);
                                var currentRequestCursor = (cursor || '''').trim();
                                var nextCursor = extractNextCursor(dataObject, nextCustomerData, pageSize);
                                statusState.nextCursor = nextCursor;
                                statusState.hasMore = !!nextCursor;
                                statusState.loading = false;

                                // Nếu cursor không tiến triển hoặc backend trả rỗng thì dừng gọi tiếp để tránh loop API.
                                if (!nextCustomerData || nextCustomerData.length === 0 || (currentRequestCursor && String(nextCursor || '''') === currentRequestCursor)) {
                                    statusState.hasMore = false;
                                }

                                columnDataMap[sid] = mergeCustomerRows(columnDataMap[sid] || [], nextCustomerData);
                                sortCustomersByColumnRules(columnDataMap[sid]);
                            }

                            if (window.KanbanSharedCustomerStore) {
                                window.KanbanSharedCustomerStore.replaceAll(customerData, { source: ''processcus'' });
                            }

                            if (!suppressRender && (!append || statusId === null || statusId === undefined || statusId === '''')) {
                                renderKanbanBoard();
                            }

                            resolve(true);
                        } catch (error) {
                            console.error("Parse data error:", error);
                            if (statusState) statusState.loading = false;
                            resolve(false);
                    }
       },
                    error: function (err) {
                        console.error("Ajax error:", err);
                        if (statusState) statusState.loading = false;
                        resolve(false);
                    }
                });
            });
        }

        // Hàm async để load toàn bộ dữ liệu từ API
        async function loadKanbanData() {
            if (isKanbanLoading) return;
            isKanbanLoading = true;
            try {

                renderKanbanSkeleton(6);
                var skeletonStartedAt = Date.now();

                // 2. Lấy giá trị từ date pickers
                let fromDate = '''';
                let toDate = '''';

                const isViewAll = (_activeStatusID === -1);
                if (!isViewAll) {
                    fromDate = InstanceFromDateP59A6A90D898E4345813592F4BDF3847D.option("value");
                    toDate = InstanceToDateP3F439F29229C4DFEB0D31C9198E35FC4.option("value");
                }

                currentFilterState = {
                    fromDate: fromDate,
                    toDate: toDate,
                    viewAll: isViewAll,
                    employeeIDs: InstanceEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.option("value") || '''',
                    searchText: searchKeyword || ''''
                };

                currentLoadToken += 1;
                var loadToken = currentLoadToken;
                customerData = [];
                columnDataMap = {};
                columnPageMap = {};
                statusServerStateMap = {};

                // Lấy một lần: status + 10 card đầu tiên cho mỗi status
                await loadData(fromDate, toDate, isViewAll, currentFilterState.employeeIDs, null, SERVER_PAGE_SIZE, false, null, loadToken, true);
                if (loadToken !== currentLoadToken) return;

                // Khởi tạo trạng thái từng cột từ batch đầu (mỗi cột tối đa SERVER_PAGE_SIZE)
                statusData.forEach(function (status) {
                    var sid = String(status.Status);
                    var initialRows = (customerData || []).filter(function (c) { return String(c.StatusID) === sid; });
                    var totalCount = Number(status.TotalCount || status.TotalCustomerCount || 0);

                    columnDataMap[sid] = initialRows;
                    columnPageMap[sid] = 0;
                    statusServerStateMap[sid] = {
                        nextCursor: initialRows.length > 0 ? buildCursorFromLastRow(initialRows) : null,
                        hasMore: totalCount > initialRows.length,
                        loading: false,
                        lastRequestKey: null,
                        lastRequestAt: 0
                    };
                });
                renderKanbanSkeleton(statusData.length || 6);

                if (loadToken !== currentLoadToken) return;
                var elapsedSkeleton = Date.now() - skeletonStartedAt;
                if (elapsedSkeleton < MIN_INITIAL_SKELETON_MS) {
                    await waitMs(MIN_INITIAL_SKELETON_MS - elapsedSkeleton);
                }
                renderKanbanBoard();

            } catch (error) {
                console.error(''Lỗi khi tải dữ liệu Kanban: '', error);
                const $board = document.getElementById(''kanbanBoard'');
                if ($board) {
                    $board.innerHTML = `
<div class="empty-state">
                            <i class="bi bi-exclamation-triangle"></i>
   <p>Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại sau.</p>
                        </div>
       `;
                }
            } finally {
                isKanbanLoading = false;
            }
        }

        // Render Kanban board
        function renderKanbanSkeleton(columnCount) {
            const $board = document.getElementById(''kanbanBoard'');
            if (!$board) return;

            var columns = '''';
            var totalColumns = Math.max(1, columnCount || 6);

            for (var i = 0; i < totalColumns; i++) {
                columns += `
                    <div class="kanban-skeleton-column">
                        <div class="kanban-skeleton-header">
                            <div class="skeleton-line kanban-skeleton-title"></div>
                            <div class="skeleton-pill"></div>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:12px;flex:1;overflow:hidden;">
                            <div class="kanban-skeleton-card">
                                <div class="skeleton-line kanban-skeleton-avatar"></div>
                                <div class="kanban-skeleton-body">
                                    <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                </div>
                            </div>
                            <div class="kanban-skeleton-card">
                                <div class="skeleton-line kanban-skeleton-avatar"></div>
                                <div class="kanban-skeleton-body">
        <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                </div>
                            </div>
                            <div class="kanban-skeleton-card">
                                <div class="skeleton-line kanban-skeleton-avatar"></div>
                                <div class="kanban-skeleton-body">
                                    <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                    <div class="skeleton-line"></div>
                                </div>
                            </div>
                        </div>
                    </div>`;
            }

            $board.innerHTML = columns;
        }

        function renderKanbanBoard() {
            const $board = document.getElementById(''kanbanBoard'');
            $board.innerHTML = '''';

            if (statusData.length === 0) {
                $board.innerHTML = ''<div class="empty-state"><i class="bi bi-inbox"></i><p>Không có dữ liệu trạng thái</p></div>'';
                return;
            }

            // Sort statusData by Priority (low to high - left to right)
            statusData.sort((a, b) => (a.Priority || 0) - (b.Priority || 0));

            // Pre-group customers by StatusID once (O(n) instead of O(n * columns))
            // Apply search filter if keyword is set
            var filteredData = customerData;
            columnDataMap = {};
            columnPageMap = {};
            filteredData.forEach(c => {
                var sid = String(c.StatusID);
                if (!columnDataMap[sid]) columnDataMap[sid] = [];
                columnDataMap[sid].push(c);
            });

            // Sort each column: prioritize unassigned (EmployeeIDs null/empty) on top, then newest first
            Object.keys(columnDataMap).forEach(function (sid) {
                columnDataMap[sid].sort(function (a, b) {
                    var aEmployeeIDs = String(a.EmployeeIDs || '''').trim().toLowerCase();
                    var bEmployeeIDs = String(b.EmployeeIDs || '''').trim().toLowerCase();
                    var aHasEmployee = aEmployeeIDs !== '''' && aEmployeeIDs !== ''null'' && aEmployeeIDs !== ''undefined'';
                    var bHasEmployee = bEmployeeIDs !== '''' && bEmployeeIDs !== ''null'' && bEmployeeIDs !== ''undefined'';

                    if (!aHasEmployee && bHasEmployee) return -1;
                 if (aHasEmployee && !bHasEmployee) return 1;

                    // Secondary sort: newest first so upserted/new records appear on top
                    var aCreated = new Date(a.CreatedDate || 0).getTime() || 0;
                    var bCreated = new Date(b.CreatedDate || 0).getTime() || 0;
                    if (bCreated !== aCreated) return bCreated - aCreated;

                    // Final tiebreaker: larger CRM_CustomerID first
                    var aId = Number(a.CRM_CustomerID || 0);
                    var bId = Number(b.CRM_CustomerID || 0);
                    return bId - aId;
                });
            });

            // Create columns container
            let columnsHtml = ''<div class="kanban-columns-wrapper"><div class="kanban-content">'';
            statusData.forEach(status => {
                var sid = String(status.Status);
                columnPageMap[sid] = 0;
                var allCustomers = columnDataMap[sid] || [];
                var initialSlice = allCustomers.slice(0, COLUMN_PAGE_SIZE);
                var totalCount = Number(status.TotalCount || status.TotalCustomerCount || allCustomers.length || 0);
                columnsHtml += createColumnHtml(status, initialSlice, totalCount);
            });
            columnsHtml += ''</div></div>'';

    $board.insertAdjacentHTML(''beforeend'', columnsHtml);

            // Hover scrolling
            bindKanbanScrollEvent($board);

            // Attach scroll-to-load-more per column
            document.querySelectorAll(''.column-cards'').forEach(function (colCards) {
                colCards.addEventListener(''scroll'', function () {
                    var threshold = 100;
                    if (colCards.scrollHeight - colCards.scrollTop - colCards.clientHeight < threshold) {
                        loadMoreCardsInColumn(colCards);
                    }
                });
            });

            // Initialize drag and drop via event delegation
            initializeDragAndDrop();

            // Load employee avatars for all cards
            loadEmployeeAvatarsForCards();
        }

        function bindKanbanScrollEvent(board) {
            if (!board) return;
            var scrollTarget = board.querySelector(''.kanban-content'') || board;
            var scrollStep = 25; // pixels per interval
            var scrollInterval = null;

            if (!scrollTarget) return;

            function startScrollLeft() {
                if (scrollInterval) return;
                scrollInterval = setInterval(function () {
                    scrollTarget.scrollLeft -= scrollStep;
                }, 50);
            }

            function startScrollRight() {
                if (scrollInterval) return;
                scrollInterval = setInterval(function () {
                    scrollTarget.scrollLeft += scrollStep;
                }, 50);
            }

            function stopScroll() {
                if (scrollInterval) {
                    clearInterval(scrollInterval);
                    scrollInterval = null;
                }
            }

            board.addEventListener(''mousemove'', function (e) {
                var rect = board.getBoundingClientRect();
                var threshold = 80;

                if (e.clientX > rect.right - threshold) {
                    stopScroll();
                    startScrollRight();
                } else if (e.clientX < rect.left + threshold) {
                    stopScroll();
                    startScrollLeft();
                } else {
                    stopScroll();
                }
            });

            board.addEventListener(''mouseleave'', stopScroll);
        }

        function showColumnLoadingSkeleton(colCards) {
            if (!colCards || colCards.querySelector(''.col-loading-skeleton'')) return;

            var oldLoader = colCards.querySelector(''.col-loader'');
            if (oldLoader) oldLoader.remove();

            var loadingEl = document.createElement(''div'');
            loadingEl.className = ''col-loading-skeleton'';
            loadingEl.innerHTML = `
                <div class="col-loading-skeleton-card">
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line"></div>
                </div>
                <div class="col-loading-skeleton-card">
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line"></div>
                </div>
            `;
            colCards.appendChild(loadingEl);
        }

        function hideColumnLoadingSkeleton(colCards) {
            if (!colCards) return;
            var loadingEl = colCards.querySelector(''.col-loading-skeleton'');
            if (loadingEl) loadingEl.remove();
        }


        // Append next batch of cards into a column
        function loadMoreCardsInColumn(colCards) {
            var sid = String(colCards.getAttribute(''data-status-id''));
            var allCustomers = columnDataMap[sid] || [];
            var currentPage = columnPageMap[sid] || 0;
            var nextPage = currentPage + 1;
            var start = nextPage * COLUMN_PAGE_SIZE;
            var end = start + COLUMN_PAGE_SIZE;

            if (start >= allCustomers.length) {
                var statusState = getStatusServerState(sid);
                if (statusState.hasMore && !statusState.loading) {
                    var currentToken = currentLoadToken;
                    var requestCursor = String(statusState.nextCursor || '''').trim();
                    var requestKey = sid + '' | '' + requestCursor;

                    // Chống spam khi scroll nhanh: cùng status + cursor thì không gọi lặp sát nhau.
                    if (statusState.lastRequestKey === requestKey && (Date.now() - (statusState.lastRequestAt || 0) < 800)) {
                        return;
                    }
                    statusState.lastRequestKey = requestKey;
                    statusState.lastRequestAt = Date.now();

                    var columnSkeletonStartedAt = Date.now();
                    showColumnLoadingSkeleton(colCards);
                    loadData(
                        currentFilterState.fromDate,
                        currentFilterState.toDate,
                        currentFilterState.viewAll,
                        currentFilterState.employeeIDs,
                        statusState.nextCursor,
                        SERVER_PAGE_SIZE,
                        true,
                        sid,
                        currentToken
                    ).then(function () {
                        var elapsed = Date.now() - columnSkeletonStartedAt;
                        var waitFor = Math.max(0, MIN_COLUMN_SKELETON_MS - elapsed);
                    setTimeout(function () {
                            hideColumnLoadingSkeleton(colCards);
                            if (currentToken !== currentLoadToken) return;
                            var refreshedColCards = document.querySelector(''.column-cards[data-status-id="'' + sid + ''"]'');
                            if (refreshedColCards) {
                                loadMoreCardsInColumn(refreshedColCards);
                            }
                        }, waitFor);
                    }).catch(function () {
                        var elapsed = Date.now() - columnSkeletonStartedAt;
                        var waitFor = Math.max(0, MIN_COLUMN_SKELETON_MS - elapsed);
                        setTimeout(function () {
                            hideColumnLoadingSkeleton(colCards);
                        }, waitFor);
                    });
                }
                return;
            }

            columnPageMap[sid] = nextPage;

            // Remove loader sentinel if present
            var loader = colCards.querySelector(''.col-loader'');
            if (loader) loader.remove();

            // Build and append next batch
            var fragment = document.createDocumentFragment();
            var wrapper = document.createElement(''div'');
            var batch = allCustomers.slice(start, end);

            wrapper.innerHTML = batch.map(function (customer) {
                customer.StatusID = allCustomers[0] ? allCustomers[0].StatusID : sid;
                return createCardHtml(customer);
            }).join('''');
            while (wrapper.firstChild) fragment.appendChild(wrapper.firstChild);

            // Append loader sentinel if more remain
            if (end < allCustomers.length) {
                var sentinel = document.createElement(''div'');
                sentinel.className = ''col-loader'';
                sentinel.style.cssText = ''text-align: center; padding: 8px; font-size: 12px; color:#9ca3af; '';
                sentinel.textContent = ''Cuộn để xem thêm...'';
                fragment.appendChild(sentinel);
            }

            colCards.appendChild(fragment);

            // Load avatars for newly appended cards
            setTimeout(function () {
                loadEmployeeAvatarsForCards();
            }, 50);
        }

        // Create column HTML (renders only initial slice, total is the real count)
        function createColumnHtml(status, initialCustomers, totalCount) {
            var cardsHtml = initialCustomers.map(function (customer) {
                customer.StatusID = status.Status;
                return createCardHtml(customer);
            }).join('''');

            var hasMore = totalCount > COLUMN_PAGE_SIZE;
            var loaderHtml = hasMore
                ? ''<div class="col-loader" style="text-align:center;padding:8px;font-size:12px;color:#9ca3af;">Cuộn để xem thêm...</div>''
                : '''';

            var displayCount = Number(totalCount || 0).toLocaleString(''vi-VN'');

            return `
                <div class="kanban-column" data-status-name="${status.StatusName}" data-status-id="${status.Status}">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-circle-fill" style="font-size: 8px; color: ${getStatusColor(status.Status)}"></i>
                            ${status.StatusName}
                        </div>
                        <div class="column-count">${displayCount}</div>
                    </div>
                    <div class="column-cards" data-status-name="${status.StatusName}" data-status-id="${status.Status}">
                        ${cardsHtml || ''<div class="empty-state"><i class="bi bi-inbox"></i></div>''}
                        ${loaderHtml}
                    </div>
                </div >
        `;
        }
       // Create card HTML
        function createCardHtml(customer) {
            // Determine badge style based on status
            let badgeClass = ''badge-contact'';
            // Status 0: Chưa liên hệ, Status 5: Thất bại
            if (customer.StatusID == 0 || customer.StatusID == 6) {
                badgeClass = ''badge-no-contact'';
            }


            const updateTime = customer.CreatedDate
                ? new Date(customer.CreatedDate).toLocaleDateString(''vi-VN'')
                : ''N/A'';


            const isMyAccount = String(customer.OwnerID) === String(window.EmployeeID_Login);
            const ownerDisplay = isMyAccount ? "Tôi" : `${customer.OwnerID} -${customer.EmployeeName} `;

            return `
        <div class="customer-card" draggable="true" data-employee-id="${customer.EmployeeIDs}" data-customer-id="${customer.CRM_CustomerID}" data-company-id="${customer.Company_ID}" data-have-zalo="${customer.haveZalo || 0}" ondblclick="viewCustomerDetail(${customer.Company_ID}, ${customer.StatusID}, ${customer.CRM_CustomerID})">
                    <div class="card-header">
                        <div>
                            <div class="card-name">${customer.name || ''N/A''}</div>
                            <div class="card-company">${customer.Company || ''Chưa có thông tin''}</div>
           </div>
                    </div>

                    <div class="card-info">
                        ${customer.TaxCode ? `<div class="card-info-item"><i class="bi bi-building"></i>${customer.TaxCode}</div>` : ''''}
                        ${customer.Email ? `<div class="card-info-item"><i class="bi bi-envelope"></i>${customer.Email}</div>` : ''''}
                        ${customer.phone ? `<div class="card-info-item"><i class="bi bi-telephone"></i>${customer.phone}</div>` : ''''}

                        <!-- Avatar Stack cho người phụ trách -->
    <div class="card-info-item support ${customer.EmployeeIDs && String(customer.EmployeeIDs).trim() !== '''' ? ''has-support'' : ''no-support''}" style="flex-wrap: wrap; gap: 4px;">
                            <i class="bi bi-person" style="margin-right: auto;"></i>
                            <div id="employee-avatars-${customer.CRM_CustomerID}" style="display: flex; align-items: center; gap: 2px; flex: 1;">
                                ${customer.EmployeeIDs && String(customer.EmployeeIDs).trim() !== ''''
                    ? `<div style="display: flex; align-items: center; gap: -8px;">
                                        ${(() => {
                        const empIds = String(customer.EmployeeIDs).split(",").map(id => id.trim()).filter(id => id);
                        const empNames = customer.EmployeeNames ? String(customer.EmployeeNames).split(",").map(name => name.trim()) : [];

                        // Hiển thị max 3 avatars
                        const maxVisible = 3;
                        const visibleCount = empIds.length > maxVisible ? maxVisible - 1 : empIds.length;
                        const remaining = empIds.length - visibleCount;
                        const ImageParadiseDefault = `data:image/svg+xml,${encodeURIComponent(DEFAULT_AVATAR_SVG)}`;

                        return empIds.slice(0, visibleCount).map((empId, idx) => `
                                                <img
                                                    src="${ImageParadiseDefault}"
                                                    data-emp-id="${empId}"
                                                    data-emp-name="${empNames[idx] || empId}"
                                                    title="${empNames[idx] || empId}"
                                                    style="width: 22px; height: 22px; border-radius: 50%; border: 1.5px solid white; margin-left: ${idx > 0 ? ''-10px'' : ''0''}; cursor: pointer; box-shadow: 0 0 3px rgba(0,0,0,0.1); flex-shrink: 0; z-index: ${empIds.length - idx};"
                                class="employee-avatar-card"
                                                />
                                            `).join('''')
                            + (remaining > 0 ? `
                                                <div title="+${remaining} more" style="width: 22px; height: 22px; border-radius: 50%; background: #e8e8e8; display: flex; align-items: center; justify-content: center; font-size: 9px; font-weight: bold; border: 1.5px solid white; margin-left: -10px; color: #666; flex-shrink: 0; z-index: 0;">+${remaining}</div>
                                            ` : '''');
                    })()}
                                       </div>`
                    : ''<span style="font-size: 11px; color: #999;">Chưa gán</span>''
                }
                            </div>
                        </div>
                    </div>

                    <div class="card-footer">
             <div class="card-date">
                         <i class="bi bi-clock"></i>
${updateTime}
                        </div>
                        <div class="card-actions">
                            <button class="btn-icon" onclick="viewCustomerDetail(${customer.Company_ID}, ${customer.StatusID}, ${customer.CRM_CustomerID})" title="Chi tiết">
                                <i class="bi bi-eye fs-7"></i>
                            </button>
                        </div>
                    </div>

                </div >
        `;
        }
        // Load employee avatars for all cards in Kanban
        function loadEmployeeAvatarsForCards() {
            document.querySelectorAll(''.employee-avatar-card'').forEach(function ($img) {
                const empId = $img.getAttribute(''data-emp-id'');

                if (window.GlobalEmployeeAvatarCache && window.GlobalEmployeeAvatarCache[empId]) {
                    $img.src = window.GlobalEmployeeAvatarCache[empId];
                    return;
                }

                if (window.GlobalEmployeeAvatarPending && window.GlobalEmployeeAvatarPending[empId]) {
                    return;
                }

                const customerCard = $img.closest(''.customer-card'');
                if (!customerCard) return;

                const customerId = customerCard.getAttribute(''data-customer-id'');
   const customer = customerData.find(function (c) { return String(c.CRM_CustomerID) === customerId; });
                if (!customer) return;

                const paramImgsArray = customer.paramImgs
                    ? (Array.isArray(customer.paramImgs) ? customer.paramImgs : String(customer.paramImgs).split(''|''))
                    : [];
                const storeImgName = ''paradisefile_sp_GetFileAPI_profile'';

                const empIds = String(customer.EmployeeIDs || '''').split('','').map(function (id) { return id.trim(); }).filter(function (id) { return id; });
                const empIndex = empIds.indexOf(empId);
                const paramImg = empId;

                window.GlobalEmployeeAvatarPending[empId] = true;

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: ["EmployeeID", decodeURIComponent(paramImg)]
                    },
                    xhrFields: { responseType: ''blob'' },
                    cache: true,
                    success: function (blob) {
                        try {
                            var blobUrl = '''';
                            if (blob instanceof Blob) {
                                blobUrl = URL.createObjectURL(blob);
                            } else if (blob instanceof ArrayBuffer) {
                                var newBlob = new Blob([blob], { type: ''image/jpeg'' });
       blobUrl = URL.createObjectURL(newBlob);
                            } else if (typeof blob === ''string'' && blob.startsWith(''blob:'')) {
                                blobUrl = blob;
                            }

                            if (blobUrl) {
                                if (!window.GlobalEmployeeAvatarCache) {
                                    window.GlobalEmployeeAvatarCache = {};
                                }
                                window.GlobalEmployeeAvatarCache[empId] = blobUrl;
                                $img.src = blobUrl;
                                $img.style.cursor = ''pointer'';

                                document.querySelectorAll(''.employee-avatar-card[data-emp-id="'' + empId + ''"]'').forEach(function (img) {
                                    img.src = blobUrl;
                                });
                            }
                        } catch (ex) {
                            console.warn(''[Kanban Avatar] Error loading:'', empId, ex);
                        } finally {
                            delete window.GlobalEmployeeAvatarPending[empId];
                        }
                    },
                    error: function (err) {
                        console.warn(''[Kanban Avatar] API error for'', empId, err);
                        delete window.GlobalEmployeeAvatarPending[empId];
                    }
                });
            });
        }

        // Get status color
        function getStatusColor(statusId) {
            const colors = [''#3498db'', ''#f39c12'', ''#9b59b6'', ''#e74c3c'', ''#2ecc71'', ''#1abc9c''];
            return colors[statusId % colors.length];
        }

        function viewCustomerDetail(Company_ID, StatusID, CRM_CustomerID) {
            window.currentRecordID_Company_ID = Company_ID;
            window.currentRecordID_CRM_CustomerID = CRM_CustomerID
            const isMobile = ["Android", "iOS"].includes(getMobileOperatingSystem());
            if (StatusID == 0 || StatusID == 7) {
                if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                    OpenFormParamMobile(`sp_CRM_CompanyDetail`);
    } else {
                    openFormParam(`sp_CRM_CompanyDetail`);
                }
            } else {
                window.Company_ID = Company_ID;
    openFormParam(`sp_CRM_CustomerDetail`, {
                    LoginID: window.UserID,
                    LanguageID: window.LanguageID,
                    Company_ID: window.Company_ID
                });
            }

        }

        // Initialize drag and drop via event delegation (no per-card listeners)
        function initializeDragAndDrop() {
            const board = document.getElementById(''kanbanBoard'');
            if (!board || board._dndInitialized) return;
            board._dndInitialized = true;

            // Delegated dragstart / dragend on cards
            board.addEventListener(''dragstart'', function (e) {
                var card = e.target.closest(''.customer-card'');
                if (!card) return;
                draggedElement = card;
                card.classList.add(''dragging'');
                e.dataTransfer.effectAllowed = ''move'';
                e.dataTransfer.setData(''text/plain'', card.getAttribute(''data-customer-id''));
            });

            board.addEventListener(''dragend'', function (e) {
                var card = e.target.closest(''.customer-card'');
                if (card) card.classList.remove(''dragging'');
            });

            // Delegated dragover / drop / dragleave on columns
            board.addEventListener(''dragover'', function (e) {
                var col = e.target.closest(''.kanban-column'');
                if (!col) return;
                e.preventDefault();
                e.dataTransfer.dropEffect = ''move'';

                col.classList.add(''drag-over'');

                // Auto-scroll horizontally
                var kanbanContent = document.querySelector(''#customerKanbanComponent .kanban-content'');
                if (kanbanContent) {
                    var rect = kanbanContent.getBoundingClientRect();
                    var threshold = 80, speed = 25;
                    if (e.clientX > rect.right - threshold) kanbanContent.scrollLeft += speed;
                    else if (e.clientX < rect.left + threshold) kanbanContent.scrollLeft -= speed;
                }
            });

            board.addEventListener(''dragleave'', function (e) {
                var col = e.target.closest(''.kanban-column'');
                if (col && !col.contains(e.relatedTarget)) col.classList.remove(''drag-over'');
            });

            board.addEventListener(''drop'', function (e) {
                var col = e.target.closest(''.kanban-column'');
                if (!col) return;
                e.stopPropagation();
                col.classList.remove(''drag-over'');

                if (draggedElement && draggedElement !== col) {
                    var customerId = draggedElement.getAttribute(''data-customer-id'');
                    var companyId = draggedElement.getAttribute(''data-company-id'');
                    var employeeId = draggedElement.getAttribute(''data-employee-id'');
                    var haveZalo = parseInt(draggedElement.getAttribute(''data-have-zalo'') || ''0'', 10);
                    var newStatusId = col.getAttribute(''data-status-id'');
                    var newStatusName = col.getAttribute(''data-status-name'');
                    let customerName = draggedElement.querySelector(''.card-name'') ? draggedElement.querySelector(''.card-name'').textContent : ''N/A'';
                    let oldStatusName = draggedElement.closest(''.kanban-column'') ? draggedElement.closest(''.kanban-column'').getAttribute(''data-status-name'') : ''N/A'';

                    // Find old status
                    var oldStatusId = null;
                    var oldColumn = draggedElement.closest(''.kanban-column'');
                    if (oldColumn) {
    oldStatusId = oldColumn.getAttribute(''data-status-id'');
                    }

                    if (oldStatusId !== newStatusId) {
                        // Check if transitioning FROM status 0 or 7 TO any status (except 6 = failed) WITHOUT Zalo
                        var oldStatusInt = parseInt(oldStatusId, 10);
                        var newStatusInt = parseInt(newStatusId, 10);
                        if ((oldStatusInt === 0 || oldStatusInt === 7) && newStatusInt !== 6 && haveZalo === 0) {
                            // Require adding Zalo before transition
                            showConfirmPopup({
                                title: "Chưa có Số Zalo",
                                message: "Bạn chưa thêm Số Zalo cho khách hàng này. Vui lòng thêm trước khi chuyển trạng thái.",
                                YesText: "Thêm Zalo",
                                NoText: "Hủy",

                                onYes: () => {
                                    console.log("Đã chọn thêm Zalo");
                                    window.currentRecordID_CRM_CustomerID = customerId;
                                    if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                                        OpenFormParamMobile(`sp_CRM_CreateCustomer`);
                                    } else {
                                        openFormParam(`sp_CRM_CreateCustomer`);
                                    }
                                },
                                onNo: () => {
                                    console.log("Đã chọn HỦY");
                                }
                            });
                        } else if (haveZalo == 1) {
                            // haveZalo = 1: Ask to delete notification
                            showConfirmPopup({
                                title: "Đổi trạng thái?",
                                message: "Bạn có chắc thay đổi trạng thái khách hàng này?",
                                YesText: "Đồng ý",
                                NoText: "Hủy",

                                onYes: () => {
                                    console.log("Đã chọn YES");
                                    // Update customer status (proceed with drag)
                                    if (newStatusId == 0) {
                                        let employeeIDUpdate = employeeId;
                                        let employeeIDDel = null;
                                        if (employeeId && window.EmployeeID_Login) {
                                            let stringdata = employeeId.split('','').filter(id => id.trim() == window.EmployeeID_Login).join('','');
                                            if (stringdata) {
                                                employeeIDDel = window.EmployeeID_Login;
                                            }
                                        }
                                        updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeIDUpdate, 0, employeeIDDel).then(function (success) {
                                            if (success) {
                                                renderKanbanBoard();
                                            }
                                        });
                                    } else {
                                        updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeId).then(function (success) {
                                            if (success) {
                                                renderKanbanBoard();
                                            }
                                        });
                                    }
                                },
                                onNo: () => {
                                    console.log("Đã chọn NO");
                                }
                            });
                        } else {
                            // Normal drag operation when haveZalo is not 0 or 1
          if (newStatusId == 0) {
                                let employeeIDUpdate = employeeId;
                                let employeeIDDel = null;
                                if (employeeId && window.EmployeeID_Login) {
                                    let stringdata = employeeId.split('','').filter(id => id.trim() == window.EmployeeID_Login).join('','');
                                    if (stringdata) {
                                        employeeIDDel = window.EmployeeID_Login;
                                    }
                                }

                                showConfirmPopup({
                                    title: "Xác nhận chuyển đổi trạng thái",
                                    message: `Bạn có chắc chắn muốn chuyển đổi trạng thái khách hàng "${customerName} từ "${oldStatusName} " sang "${newStatusName}, sau khi chuyển đổi sẽ xóa bạn ra khỏi danh sách người phụ trách của khách hàng này"?`,
                                    YesText: "Chuyển đổi",
                                    NoText: "Hủy",

                                    onYes: () => {
                                        updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeIDUpdate, 0, employeeIDDel).then(function (success) {
                                            if (success) {
                                                renderKanbanBoard();
                                            }
                                        });
                                    },
                                    onNo: () => {

                                    }
                                });
                                return
                            }

                            if (oldStatusId == 0) {
                                showConfirmPopup({
                                    title: "Xác nhận chuyển đổi trạng thái",
                                    message: `Bạn có chắc chắn muốn chuyển đổi trạng thái khách hàng "${customerName} từ "${oldStatusName}" sang "${newStatusName}"?`,
                                    YesText: "Chuyển đổi",
                                    NoText: "Hủy",

                                    onYes: () => {
                                        updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeId).then(function (success) {
                                            if (success) {
                                                renderKanbanBoard();
                                            }
                                        });
                                    },
                                    onNo: () => {

                                    }
                                });
                            } else {
                                updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeId).then(function (success) {
                                    if (success) {
                                        renderKanbanBoard();
                                    }
                                });
                            }
                        }


                    }
                }
            });
        }



        var draggedElement = null;

        function openAddCustomerModal() {
            if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                OpenFormParamMobile(`sp_CRM_CreateLead`);
            } else {
                openFormParam(`sp_CRM_CreateLead`);
            }
        }

        async function updateCustomerStatus(customerId, companyId, newStatusId, newStatusName, employeeid, isNotification, employeedel) {

            const formDataCustomer = {
                CRM_CustomerID: Number(customerId),
                CRM_CompanyID: Number(companyId),
                StatusID: newStatusId,
           OwnerID: employeeid && employeeid !== ''undefined'' && employeeid !== ''null'' ? null : (window.EmployeeID_Login),
                EmployeeIDDel: employeedel
            };

            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: "sp_UpdateContactCustomerStatus",
                        param: [
                            "LoginID", window.UserID,
                            "JSONdata", JSON.stringify(formDataCustomer),
                            "isNotification", isNotification
                        ]
                    },
                    success: function (data) {
                        if (typeof data === "string" && !IsNullOrEmpty(data)) {
                            data = data.includes("{") ? data : EncryptionStringDecryption(data);
                        }

                        let dataObject = typeof data === "string" ? JSON.parse(data) : data;
                        let result = dataObject?.data?.[0];

                        if (result && result.length > 0 && result[0].Success == 1) {
                            let updateData = customerData.find(c => String(c.CRM_CustomerID) == String(customerId));
                            if (updateData) {
                                updateData.StatusID = newStatusId;
                                updateData.StatusName = newStatusName;
                                updateData.EmployeeIDs = result[0].EmployeeIDs || '''';
                                updateData.EmployeeNames = result[0].EmployeeNames || '''';
                                updateData.paramImgs = result[0].paramImgs || '''';
                                if (window.KanbanSharedCustomerStore) {
                                    window.KanbanSharedCustomerStore.upsert(updateData, { source: ''processcus'' });
                                }


                                const cardEl = document.querySelector(`.customer-card[data-id="${customerId}"]`);
                                if (cardEl) {
                                    const statusEl = cardEl.querySelector(''.customer - status'');
                                    if (statusEl) {
                                        statusEl.textContent = newStatusName;
                                        statusEl.dataset.statusId = newStatusId;
                                    }
                                }
                            }
                            uiManager.showAlert({ type: "success", message: "%SaveContactSuccess%" });
                            resolve(true);    // ✅ trả về true khi thành công
                        } else {
                            uiManager.showAlert({ type: "error", message: result?.Message || "%SaveContactFailed%" });
                            resolve(false);   // ✅ trả về false khi thất bại
                        }
                    },
                    error: function () {
                        reject(false);        // ✅ trả về false khi lỗi mạng
                    }
                });
            });
        }

        // Helper function to check if value is null or empty
        function IsNullOrEmpty(value) {
            return value === null || value === undefined || value === '''';
        }

        // ===============================================
        // ✅ NAMESPACE OBJECT - Tránh global pollution
        // ===============================================
        // Chỉ expose 1 namespace duy nhất vào window
        if (!window.KanbanApp) {
            window.KanbanApp = {};
        }

        window.KanbanApp = {
            // Data accessors (read-only references)
   getStatusData: () => statusData,
            getCustomerData: () => customerData,
            getCurrentCustomer: () => currentCustomer,
            setCurrentCustomer: (data) => { currentCustomer = data; },


            // Core Kanban functions
            loadKanbanData: loadKanbanData,
            loadData: loadData,
            renderKanbanBoard: renderKanbanBoard,
            loadMoreCardsInColumn: loadMoreCardsInColumn,
            handleKanbanSearch: handleKanbanSearch,

            // Card & Column rendering
            createColumnHtml: createColumnHtml,
            createCardHtml: createCardHtml,

            // Avatar functions
            loadEmployeeAvatarsForCards: loadEmployeeAvatarsForCards,

            // UI functions
            getStatusColor: getStatusColor,
            viewCustomerDetail: viewCustomerDetail,
            initializeDragAndDrop: initializeDragAndDrop,
            openAddCustomerModal: openAddCustomerModal,

            // Update & status
            updateCustomerStatus: updateCustomerStatus,

            // Shared datasource APIs (for other menu/modules)

            getSharedCustomerDataSource: function () {
                return window.KanbanSharedCustomerStore ? window.KanbanSharedCustomerStore.getDataSource() : null;
            },
            upsertSharedCustomer: function (row, source) {
                if (window.KanbanSharedCustomerStore) {
                    window.KanbanSharedCustomerStore.upsert(row, { source: source || ''external'' });
                }
            },
            patchSharedCustomer: function (customerId, data, source) {
                if (!window.KanbanSharedCustomerStore) return;
                if (customerId === null || customerId === undefined || customerId === '''') return;
                window.KanbanSharedCustomerStore.upsert(Object.assign({ CRM_CustomerID: customerId }, data || {}), { source: source || ''external'' });
            },
            upsertSharedCustomers: function (rows, source) {
                if (window.KanbanSharedCustomerStore) {
                    window.KanbanSharedCustomerStore.upsertMany(rows, { source: source || ''external'' });
                }
            },
            removeSharedCustomer: function (customerId, source) {
                if (window.KanbanSharedCustomerStore) {
                    window.KanbanSharedCustomerStore.remove(customerId, { source: source || ''external'' });
                }
            },
            removeSharedCustomerByCompanyId: function (companyId, source) {
                if (window.KanbanSharedCustomerStore) {
                    window.KanbanSharedCustomerStore.removeByCompanyId(companyId, { source: source || ''external'' });
                }
            },
            reloadFromSharedCustomerStore: function () {
                if (!window.KanbanSharedCustomerStore) return;
                customerData = window.KanbanSharedCustomerStore.getAll();
                renderKanbanBoard();
            },

            // Utilities
            IsNullOrEmpty: IsNullOrEmpty,
            removeAccents: removeAccents,
            loadDateFilter: loadDateFilter,

            // Global avatar cache reference
            getAvatarCache: () => window.GlobalEmployeeAvatarCache,
            clearAvatarCache: () => { window.GlobalEmployeeAvatarCache = {}; },
            saveAvatarCacheToLocalStorage: function () {
                try {
                    localStorage.setItem(''KanbanAvatarCache'', JSON.stringify(window.GlobalEmployeeAvatarCache));
                } catch (e) {
                    console.warn(''[KanbanApp] Failed to save avatar cache: '', e);
                }
            },
            loadAvatarCacheFromLocalStorage: function () {
                try {
                    const saved = localStorage.getItem(''KanbanAvatarCache'');
                    if (saved) {
                        window.GlobalEmployeeAvatarCache = JSON.parse(saved);
                    }
                } catch (e) {
                    console.warn(''[KanbanApp] Failed to load avatar cache: '', e);
    }
            }
        };

        renderKanbanSkeleton(6);
        loadKanbanData();

        window.openAddCustomerModal = () => window.KanbanApp.openAddCustomerModal();
        window.viewCustomerDetail = (id, status, customerId) => window.KanbanApp.viewCustomerDetail(id, status, customerId);
        window.handleKanbanSearch = (keyword) => window.KanbanApp.handleKanbanSearch(keyword);
        window.loadKanbanData = () => window.KanbanApp.loadKanbanData();
        window.handleViewAllChange = () => handleViewAllChange();
        window.handleOnlyMeChange = () => handleOnlyMeChange();
        window.clearKanbanSearch = () => clearKanbanSearch();
        window.patchKanbanCustomer = (customerId, data) => window.KanbanApp.patchSharedCustomer(customerId, data);
        window.KanbanApp_viewCustomerDetail = (id, status, customerId) => window.KanbanApp.viewCustomerDetail(id, status, customerId);
        window.KanbanApp_openAddCustomerModal = () => window.KanbanApp.openAddCustomerModal();

    })();
</script>
	'
    SELECT @html AS html;

    -- exec sptblCommonControlType_Signed_DUC 'sp_KPIProcessCustomer_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_KPIProcessCustomer_html'
    -- EXEC sp_GenerateHTMLScript 'sp_Dashboard_Mobile_beta'
END

