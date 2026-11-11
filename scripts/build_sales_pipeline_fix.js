const fs = require('fs');
const path = require('path');

let sql = fs.readFileSync('fix-bug/sales_pipeline/origin.sql', 'utf8');

function normalize(str) {
  return str.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
}

let normSql = normalize(sql);

// Normalize CREATE to ALTER for step 1
if (normSql.startsWith('\uFEFF')) {
  normSql = normSql.substring(1);
}
normSql = normSql.replace(/^CREATE\s+PROCEDURE/i, 'ALTER PROCEDURE');

function safeReplace(target, replacement, label) {
  const normTarget = normalize(target);
  const normRep = normalize(replacement);
  if (!normSql.includes(normTarget)) {
    console.error(`ERROR: ${label} not found!`);
    process.exit(1);
  }
  normSql = normSql.replace(normTarget, normRep);
  console.log(`✓ Replaced ${label}`);
}

// 1. NHÓM 1, 3, 4, 5, 6: CONTAINER & HEADER CSS (Flat Sibling Hierarchy & Automatic Right Alignment)
const oldContainerAndHeader = `        #customerKanbanComponent .kanban-container {
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
        }`;

const newContainerAndHeader = `        /* ============================================================================
           BỘ 6 NHÓM QUY TẮC RESPONSIVE & BẤT BIẾN STYLE COMPONENT (/responsive-rules)
           ============================================================================ */

        /* NHÓM 1: BASELINE RESOLUTION - Khóa Max-Width chuẩn 1920px & Căn giữa trên 2K/4K */
        #customerKanbanComponent .kanban-container {
            max-width: 1920px;
            margin: 0 auto;
            width: 100%;
        }

        /* NHÓM 3, 4, 5 & 6: FLAT SIBLING HIERARCHY, NORMAL FLOW & ATOMIC GROUP WRAPPING */
        #customerKanbanComponent .kanban-header {
            padding: 0;
            border-radius: 0;
            margin-bottom: 12px;
            border: none;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            flex-wrap: wrap;
            gap: 12px;               /* Fixed Gap 12px đồng nhất cả ngang và dọc */
            position: static;        /* Normal Flow - Triệt tiêu lỗi che khuất */
            height: auto;
            width: 100%;
        }

        #customerKanbanComponent .kanban-header h1 {
            color: #09563c;
            font-size: 28px;
            font-weight: 600;
            display: none;
            align-items: center;
            gap: 12px;
        }

        /* NHÓM 2 & 6: Khóa kích thước tối thiểu Dropdown nhân viên chống rớt dòng */
        #customerKanbanComponent .kanban-emp-wrapper {
            min-width: 180px;
            flex-shrink: 0;
        }

        #customerKanbanComponent #P18F22C9ACED845F4BDA48BAF1F6C8DD6 {
            min-width: 180px;
            width: 100%;
            flex-shrink: 0;
        }

        #customerKanbanComponent .date-input-group {
            display: flex;
            align-items: center;
            gap: 5px;
            flex-shrink: 0;
        }

        #customerKanbanComponent .date-input-group label {
            font-size: 11px;
            font-weight: 600;
            color: #64748b;
            margin: 0;
            white-space: nowrap;
        }

        #customerKanbanComponent .date-input-group input {
            border-radius: 6px;
            padding: 4px 8px;
            font-size: 13px;
            outline: none;
            width: 130px;
        }

        #customerKanbanComponent .date-input-group input:focus {
            border-color: #198754;
        }

        #customerKanbanComponent .btn-refresh-kanban-item {
            flex-shrink: 0;
        }

        /* NHÓM 3 & 6: Cụm Hành động & Tìm kiếm bên phải (Atomic Group) - margin-left: auto */
        #customerKanbanComponent .toolbar-right-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-left: auto !important; /* Tự động bám sát phải trên mọi hàng */
            flex-wrap: nowrap;
            flex-shrink: 0;
        }`;

safeReplace(oldContainerAndHeader, newContainerAndHeader, 'Container and Header CSS');

// 2. NHÓM 2: SEARCH BOX WIDTH ADJUSTMENT (Preserve all visual styling: radius 20px, #f8f9fa, shadow)
const oldSearchCss = `        #customerKanbanComponent .search-box-wrapper {
            display: flex;
            align-items: center;
            position: relative;
            width: 230px;
            margin-right: 12px;
        }`;

const newSearchCss = `        #customerKanbanComponent .search-box-wrapper {
            display: flex;
            align-items: center;
            position: relative;
            width: 260px;
            min-width: 240px;
            flex-shrink: 0;
            margin-right: 0;
        }`;

safeReplace(oldSearchCss, newSearchCss, 'Search Box Width');

// 3. NHÓM 2, 4, 6: MEDIA QUERIES (Zero Internal Mutation & Sibling Row Consolidation)
const oldMediaQueries = `        @media (max-width: 1200px) {
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
        }`;

const newMediaQueries = `        /* BẢO TOÀN KÍCH THƯỚC CỘT KANBAN: flex-shrink: 0, min-width: 220px (Zero Internal Mutation) */
        @media (max-width: 1200px) {
            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                min-width: 220px;
            }
        }

        /* WINDOWS SNAP 1/2 (~960px - 1024px): Giữ nguyên bố cục phẳng, không ép column */
        @media (max-width: 992px) {
            #customerKanbanComponent {
                padding: 15px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                min-width: 220px;
            }

            #customerKanbanComponent .kanban-header {
                gap: 12px;
            }

            #customerKanbanComponent .toolbar-right-actions {
                margin-left: auto !important;
            }
        }

        /* TABLET & SNAP 1/3 (768px): Cụm Right Actions bám sát lề phải, Date Input co giãn */
        @media (max-width: 768px) {
            #customerKanbanComponent {
                padding: 10px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                min-width: 220px;
            }

            #customerKanbanComponent .date-input-group {
                flex: 0 0 auto;
            }

            #customerKanbanComponent .toolbar-right-actions {
                width: 100%;
                justify-content: flex-end;
                margin-left: auto !important;
            }

            #customerKanbanComponent .search-box-wrapper {
                flex: 1 1 auto;
                min-width: 200px;
                max-width: 320px;
            }
        }

        /* MOBILE (<= 576px): Wrap nhẹ nhàng khi hết chỗ, giữ nguyên 100% style của Card */
        @media (max-width: 576px) {
            #customerKanbanComponent {
                padding: 8px;
            }

            #customerKanbanComponent .kanban-column {
                flex: 0 0 220px;
                min-width: 220px;
            }

            #customerKanbanComponent .toolbar-right-actions {
                flex-wrap: wrap;
                width: 100%;
                gap: 8px;
                justify-content: flex-start;
            }

            #customerKanbanComponent .search-box-wrapper {
                width: 100%;
                min-width: 100%;
                max-width: 100%;
            }
        }`;

safeReplace(oldMediaQueries, newMediaQueries, 'Media Queries (Zero Internal Mutation)');

// 4. NHÓM 6.1: FLAT SIBLING HIERARCHY (Bỏ bọc nhóm giả tạo .header-actions và .date-filter)
const oldHtmlHeader = `        <div class="kanban-header">
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
        </div>`;

const newHtmlHeader = `        <div class="kanban-header">
            <!-- QUY TẮC 6.1: ĐỒNG CẤP HÓA CÁC WIDGET (FLAT SIBLINGS TRONG 1 FLEX CONTAINER DUY NHẤT) -->
            <div class="d-flex kanban-emp-wrapper" style="align-items: center; gap:5px;">
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
            <button class="btn btn-success btn-sm px-3 btn-refresh-kanban-item" onclick="loadKanbanData()"
                style="height: 30px; padding: 0 15px;">
                <i class="bi bi-filter"></i> Làm mới
            </button>

            <!-- QUY TẮC 6.2 & 6.3: CỤM NGUYÊN TỬ PHẢI (ATOMIC GROUP) BÁM LỀ PHẢI QUA margin-left: auto -->
            <div class="toolbar-right-actions">
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
        </div>`;

safeReplace(oldHtmlHeader, newHtmlHeader, 'Flat Sibling HTML Header');

// Clean Code Step 2 and Step 3 per AGENTS.md
const cleanCodeEnd = `
GO

-- ============================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI (sp_KPIProcessCustomer)
-- ============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_KPIProcessCustomer](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';
    SELECT TOP 1 html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_KPIProcessCustomer'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ============================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ============================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_KPIProcessCustomer_html', 'VN', 'sp_KPIProcessCustomer';
    EXEC sp_GenerateHTMLScript_new 'sp_KPIProcessCustomer_html', 'EN', 'sp_KPIProcessCustomer';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_KPIProcessCustomer_html';
END
GO
`;

// Convert back to CRLF
const finalSql = (normSql.trim() + '\n' + cleanCodeEnd.trim() + '\n').replace(/\n/g, '\r\n');

fs.writeFileSync('fix-bug/sales_pipeline/fix-bug.sql', finalSql, 'utf8');
console.log('✓ Successfully generated fix-bug/sales_pipeline/fix-bug.sql, length:', finalSql.length);
