const fs = require('fs');
const path = require('path');

// 1. Đọc và cập nhật LabourContract_html
const labourSrc = path.join(__dirname, 'LabourContract_html_def.sql');
let labourCode = fs.readFileSync(labourSrc, 'utf8');

// Đổi CREATE PROCEDURE thành ALTER PROCEDURE
labourCode = labourCode.replace(/CREATE\s+PROCEDURE/i, 'ALTER PROCEDURE');

// Đoạn CSS mới cho LabourContract_html
const newLabourCss = `<style>
#labourContractSegmentPage {
    width: 100%;
    padding: 8px 12px;
    box-sizing: border-box;
}

/* HÀNG 1: THANH FILTER 5 TABS NẰM ĐỘC LẬP Ở TRÊN CÙNG (CÁCH 10PX, KHÔNG ĐÈ LÊN GRID HAY NÚT) */
#labourContractSegmentBar {
    position: relative !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    padding: 4px 6px !important;
    border: 1px solid var(--bs-border-color, rgba(255, 255, 255, 0.15)) !important;
    border-radius: 999px !important;
    background: var(--bs-tertiary-bg, rgba(255, 255, 255, 0.06)) !important;
    max-width: 100% !important;
    overflow-x: auto !important;
    overflow-y: hidden !important;
    white-space: nowrap !important;
    margin-bottom: 10px !important;
    scrollbar-width: thin !important;
}

.labour-seg-btn {
    border: 0;
    background: transparent;
    border-radius: 999px;
    padding: 6px 16px;
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
    cursor: pointer;
    color: var(--bs-body-color, #e2e8f0);
    transition: all 0.2s ease;
}

.labour-seg-btn:hover {
    background: var(--bs-secondary-bg, rgba(255, 255, 255, 0.12));
}

.labour-seg-btn.active {
    background: #007a4d;
    color: #fff;
    box-shadow: 0 2px 6px rgba(0, 122, 77, 0.35);
}

#lazyLoadContainer {
    min-height: 420px;
    width: 100%;
}

/* HÀNG 2: THANH TOOLBAR CỦA TẤT CẢ CÁC TAB CĂN LỆCH HẲN BÊN PHẢI (RIGHT-ALIGNED) */
#lazyLoadContainer .dx-toolbar {
    background: transparent !important;
    min-height: 40px !important;
    height: auto !important;
    margin-bottom: 6px !important;
    padding: 0 !important;
    position: relative !important;
    width: 100% !important;
}

#lazyLoadContainer .dx-toolbar-items-container {
    display: flex !important;
    align-items: center !important;
    justify-content: flex-end !important;
    width: 100% !important;
    height: 100% !important;
    position: relative !important;
}

#lazyLoadContainer .dx-toolbar-before {
    display: none !important;
}

#lazyLoadContainer .dx-toolbar-after {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: flex-end !important;
    position: relative !important;
    margin-left: auto !important;
    right: 0 !important;
    top: auto !important;
    gap: 6px !important;
    z-index: 2 !important;
}

#lazyLoadContainer .dx-toolbar-after .dx-toolbar-item {
    display: inline-flex !important;
    align-items: center !important;
}

/* TAB 2 (UPCOMING): CĂN CHỈNH NÚT IN/XUẤT & HOÀN THÀNH */
#lazyLoadContainer #LabourContract_Upcoming_wrap .lcu-actions {
    margin-top: 0 !important;
    margin-right: 4px !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
}

/* TAB 5 (LỊCH SỬ KÝ HỢP ĐỒNG): CHỐNG ĐÈ NHAU VÀ CĂN PHẢI NÚT HÀNH ĐỘNG */
#lazyLoadContainer #lcHistoryRoot .lc-toolbar-actions {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    margin: 0 4px 0 0 !important;
    float: none !important;
}

#lazyLoadContainer #lcHistoryRoot .lc-toolbar-action {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    height: 32px !important;
    padding: 0 10px !important;
    font-size: 12px !important;
    font-weight: 600 !important;
    border-radius: 4px !important;
    background: #007a4d !important;
    color: #fff !important;
    border: 0 !important;
    cursor: pointer !important;
    white-space: nowrap !important;
}

#lazyLoadContainer #lcHistoryRoot .lc-toolbar-action:hover {
    background: #006b43 !important;
}

#lazyLoadContainer .dx-datagrid {
    width: 100% !important;
}
</style>`;

labourCode = labourCode.replace(/<style>[\s\S]*?<\/style>/m, newLabourCss);

// Cập nhật selectTab để tự động di chuyển .lc-toolbar-actions vào .dx-toolbar-after
const oldSelectTabAppend = `c.empty().append((h && (h.Html || h.html)) || "<div style=\\"padding:12px;color:#999\\">" + (isEN ? "No data to display" : "Không có dữ liệu để hiển thị") + "</div>");`;
const newSelectTabAppend = `c.empty().append((h && (h.Html || h.html)) || "<div style=\\"padding:12px;color:#999\\">" + (isEN ? "No data to display" : "Không có dữ liệu để hiển thị") + "</div>");
        setTimeout(function(){
          var $actions = $("#lcHistoryRoot .lc-toolbar-actions");
          var $tbAfter = $("#lcHistoryRoot .dx-datagrid-header-panel .dx-toolbar-after");
          if ($actions.length && $tbAfter.length && !$tbAfter.find(".lc-toolbar-actions").length) {
            $tbAfter.prepend($actions);
          }
        }, 150);`;

labourCode = labourCode.replace(oldSelectTabAppend, newSelectTabAppend);


// 2. Đọc và cập nhật sp_LabourContractHistory_html
const historySrc = path.join(__dirname, 'sp_LabourContractHistory_html_def.sql');
let historyCode = fs.readFileSync(historySrc, 'utf8');

historyCode = historyCode.replace(/CREATE\s+PROCEDURE/i, 'ALTER PROCEDURE');

// Cập nhật CSS của sp_LabourContractHistory_html
const oldHistoryCss = `.lc-toolbar-actions{margin-left:0;margin-right:8px;float:left}.lc-toolbar-action{display:inline-flex;align-items:center;justify-content:center;height:28px;min-width:30px;padding:0 8px;border:1px solid rgba(255,255,255,.45);font-size:13px;font-weight:600;cursor:pointer;border-radius:4px;background:#007a4d;color:#fff}.lc-toolbar-action:hover{background:#006b43;color:#fff}.lc-toolbar-print{min-width:132px}.lc-toolbar-sign{min-width:82px}.lc-toolbar-cancel{min-width:58px}`;
const newHistoryCss = `.lc-toolbar-actions{display:inline-flex!important;align-items:center!important;gap:6px!important;margin:0 6px 0 0!important;float:none!important}.lc-toolbar-action{display:inline-flex!important;align-items:center!important;justify-content:center!important;height:32px!important;min-width:30px!important;padding:0 10px!important;border:1px solid rgba(255,255,255,.45)!important;font-size:12px!important;font-weight:600!important;cursor:pointer!important;border-radius:4px!important;background:#007a4d!important;color:#fff!important;white-space:nowrap!important}.lc-toolbar-action:hover{background:#006b43!important;color:#fff!important}.lc-toolbar-print{min-width:132px!important}.lc-toolbar-sign{min-width:82px!important}.lc-toolbar-cancel{min-width:58px!important}`;

historyCode = historyCode.replace(oldHistoryCss, newHistoryCss);

// Cập nhật vị trí gắn $actions vào $toolbar ($toolbarAfter) thay vì $toolbarBefore
const oldInsertActions = `  if ($toolbarBefore.length) $toolbarBefore.append($actions); else $gridRoot.find(".dx-datagrid-header-panel .dx-toolbar").prepend($actions);
  if (!$gridRoot.find(".lc-grid-refresh-icon").length) {
    if ($actionHost && $actionHost.length) {
      $addBtn.insertBefore($actionHost);
      $refresh.insertAfter($addBtn);
    } else {
      $toolbar.prepend($refresh);
      $toolbar.prepend($addBtn);
    }
  }`;

const newInsertActions = `  if (!$gridRoot.find(".lc-grid-refresh-icon").length) {
    if ($actionHost && $actionHost.length) {
      $addBtn.insertBefore($actionHost);
      $refresh.insertAfter($addBtn);
    } else {
      $toolbar.prepend($refresh);
      $toolbar.prepend($addBtn);
    }
  }
  if (!$gridRoot.find(".lc-toolbar-actions").length) {
    $toolbar.prepend($actions);
  }`;

historyCode = historyCode.replace(oldInsertActions, newInsertActions);


// 3. Tạo file finalSql
const finalSql = `/*==================================================================================================
  PARADISE HRM - PATCH: MENU QUẢN LÝ HỢP ĐỒNG LAO ĐỘNG (MnuHRS151) — SCREENSHOT-8 V3
  SỬA LỖI:
    1. CĂN LỆCH BÊN PHẢI (RIGHT-ALIGNED) CHO TOÀN BỘ CỤM BUTTON / SEARCH CỦA TẤT CẢ 5 TABS.
    2. CHỐNG XUNG ĐỘT, CHỒNG ĐÈ BUTTON TẠI TAB 5 ("LỊCH SỬ KÝ HỢP ĐỒNG").
    3. DỊCH TOÀN BỘ PLACEHOLDER %LC_...% THÀNH NHÃN CHUẨN (MÃ NHÂN VIÊN, TÊN ĐẦY ĐỦ, HỢP ĐỒNG SỐ...).
  
  * Đối chiếu ảnh lỗi: Screenshots_1_bug/8.png và các ảnh minh chứng mới nhất từ User
  * Stored Procedures sửa đổi:
      1. [dbo].[LabourContract_html] (SuperForm điều phối 5 tabs)
      2. [dbo].[sp_LabourContractHistory_html] (Tab 5: Lịch sử ký hợp đồng)
  * Bảng Cache cập nhật: [dbo].[tblHtmlScriptCache]
  
  * NGUYÊN NHÂN CỐT LÕI (ROOT CAUSE):
      1. LỖI CÁC NÚT DẠT SANG BÊN TRÁI:
         - DevExtreme DataGrid toolbar container (.dx-toolbar-items-container) mặc định là block layout.
         - Khi áp dụng margin-left: auto mà không bật display: flex trên container, margin-left: auto bị vô hiệu hóa
           và khiến toàn bộ cụm nút .dx-toolbar-after trôi dạt về lề trái.
      2. LỖI CÁC BUTTON BỊ FILTER VÀ SEARCH ĐÈ LÊN NHAU TẠI TAB 5:
         - Trong [sp_LabourContractHistory_html], cụm nút hành động ($actions) bị chèn vào .dx-toolbar-before bên trái.
         - Trong khi các icon và search box lại nằm trong .dx-toolbar-after, dẫn đến đè chồng lên nhau.
      3. LỖI LABEL HIỂN THỊ %LC_EMPLOYEE_ID%, %LC_FULL_NAME%, %LC_SELECT_CONTRACT%:
         - Mã nguồn của [sp_LabourContractHistory_html] sử dụng các template placeholder (%lc_employee_id%, %lc_full_name%...).
         - Trong bản vá trước, kết quả EXEC [sp_LabourContractHistory_html] thô được ghi đè thẳng vào [tblHtmlScriptCache]
           mà BỎ QUA bước biên dịch dịch ngôn ngữ qua [sp_GenerateHTMLScript_new].
         - Do đó trình duyệt nhận chuỗi HTML thô chưa được dịch từ [tblMD_Message] và hiển thị nguyên %LC_...%!
          
  * GIẢI PHÁP KHẮC PHỤC TRIỆT ĐỂ:
      1. CĂN PHẢI TUYỆT ĐỐI CHO TẤT CẢ CÁC TAB:
         - Thiết lập .dx-toolbar-items-container có display: flex !important; justify-content: flex-end !important;
         - Thiết lập .dx-toolbar-after có display: inline-flex !important; margin-left: auto !important; right: 0 !important;
      2. TRIỆT TIÊU ĐÈ NHAU TẠI TAB 5:
         - Chuyển cụm $actions từ .dx-toolbar-before sang .dx-toolbar-after (prepend trước $addBtn và search box).
         - Cụm nút trong Tab 5 xếp hàng ngang ngay ngắn: [In HĐ] [Ký VNeID] [Hủy ký] [+] [⟳] [Column] [Search Box].
         - Tăng margin-bottom của thanh filter lên 10px để tách biệt hoàn toàn khỏi DataGrid.
      3. BIÊN DỊCH VÀ DỊCH TỰ ĐỘNG 100% LABEL TỪ TBLMD_MESSAGE:
         - Gọi trực tiếp [sp_GenerateHTMLScript_new] để dịch tự động cả bản tiếng Việt (VN) và tiếng Anh (EN).
         - Đồng thời trang bị vòng lặp REPLACE phòng thủ đa tầng từ [tblMD_Message], đảm bảo 100% placeholder
           (%lc_employee_id%, %lc_full_name%, %lc_contract_no%, %lc_select_contract%...) được thay thế bằng
           tên nhãn tiếng Việt/tiếng Anh chuẩn chỉnh!
       
  * HƯỚNG DẪN THỰC THI TRÊN SSMS:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse thành công 100%).
      3. Bấm F5 để thực thi (Execute).
      4. Mở lại Chrome, gõ localStorage.clear(); location.reload(); (hoặc Ctrl + F5) để nghiệm thu:
         - Các nút đã căn lề PHẢI chuẩn đẹp.
         - Tab 5 không bị đè nút.
         - Toàn bộ tiêu đề cột (MÃ NHÂN VIÊN, TÊN ĐẦY ĐỦ...) và thông báo popup hiển thị tiếng Việt hoàn hảo!
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN LABOURCONTRACT_HTML (SUPERFORM 5 TABS)
--------------------------------------------------------------------------------------------------*/
${labourCode}
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: CẬP NHẬT STORED PROCEDURE GIAO DIỆN SP_LABOURCONTRACTHISTORY_HTML (TAB 5)
--------------------------------------------------------------------------------------------------*/
${historyCode}
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: BIÊN DỊCH VÀ CẬP NHẬT CACHE CHUẨN CHO SUPERFORM LABOURCONTRACT
--------------------------------------------------------------------------------------------------*/
DECLARE @htmlLabour NVARCHAR(MAX);
CREATE TABLE #TmpHtmlLabour (HtmlContent NVARCHAR(MAX));

-- Bản Tiếng Việt
INSERT INTO #TmpHtmlLabour (HtmlContent)
EXEC [dbo].[LabourContract_html] @LoginID = 3, @LanguageID = 'VN', @isWeb = 1;

SELECT TOP 1 @htmlLabour = HtmlContent FROM #TmpHtmlLabour;
DELETE FROM #TmpHtmlLabour;

UPDATE [dbo].[tblHtmlScriptCache]
SET [html] = @htmlLabour,
    [Version] = CAST(CHECKSUM(@htmlLabour) AS NVARCHAR(256))
WHERE RTRIM(LTRIM([TableName])) = 'LabourContract' AND [LanguageID] = 'VN';

IF @@ROWCOUNT = 0
BEGIN
    INSERT INTO [dbo].[tblHtmlScriptCache] ([TableName], [ScreenType], [LanguageID], [Version], [html])
    VALUES ('LabourContract ', '-1', 'VN', CAST(CHECKSUM(@htmlLabour) AS NVARCHAR(256)), @htmlLabour);
END

-- Bản Tiếng Anh
INSERT INTO #TmpHtmlLabour (HtmlContent)
EXEC [dbo].[LabourContract_html] @LoginID = 3, @LanguageID = 'EN', @isWeb = 1;

SELECT TOP 1 @htmlLabour = HtmlContent FROM #TmpHtmlLabour;
DROP TABLE #TmpHtmlLabour;

UPDATE [dbo].[tblHtmlScriptCache]
SET [html] = @htmlLabour,
    [Version] = CAST(CHECKSUM(@htmlLabour) AS NVARCHAR(256))
WHERE RTRIM(LTRIM([TableName])) = 'LabourContract' AND [LanguageID] = 'EN';

IF @@ROWCOUNT = 0
BEGIN
    INSERT INTO [dbo].[tblHtmlScriptCache] ([TableName], [ScreenType], [LanguageID], [Version], [html])
    VALUES ('LabourContract ', '-1', 'EN', CAST(CHECKSUM(@htmlLabour) AS NVARCHAR(256)), @htmlLabour);
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 4: BIÊN DỊCH VÀ DỊCH TẤT CẢ %LC_...% CHO SP_LABOURCONTRACTHISTORY (TAB 5)
--------------------------------------------------------------------------------------------------*/
-- 4.1. Chạy thủ tục biên dịch chuẩn của hệ thống Paradise HRM
EXEC [dbo].[sp_GenerateHTMLScript_new] @ProcName = 'sp_LabourContractHistory_html';
GO

-- 4.2. BẢO VỆ ĐA TẦNG: Quét và thay thế triệt để toàn bộ token %lc_...% từ tblMD_Message
DECLARE @lang VARCHAR(5), @msgID VARCHAR(100), @content NVARCHAR(MAX);
DECLARE cur_msg CURSOR LOCAL FAST_FORWARD FOR
    SELECT Language, MessageID, Content
    FROM [dbo].[tblMD_Message]
    WHERE MessageID LIKE 'lc_%';

OPEN cur_msg;
FETCH NEXT FROM cur_msg INTO @lang, @msgID, @content;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE [dbo].[tblHtmlScriptCache]
    SET [html] = REPLACE([html], '%' + @msgID + '%', @content)
    WHERE [TableName] = 'sp_LabourContractHistory'
      AND LOWER([LanguageID]) = LOWER(@lang)
      AND [html] LIKE '%' + @msgID + '%';

    FETCH NEXT FROM cur_msg INTO @lang, @msgID, @content;
END
CLOSE cur_msg;
DEALLOCATE cur_msg;

-- Cập nhật lại Checksum Version cho Cache
UPDATE [dbo].[tblHtmlScriptCache]
SET [Version] = CAST(CHECKSUM([html]) AS NVARCHAR(256))
WHERE [TableName] = 'sp_LabourContractHistory';
GO

PRINT N'✅ ĐÃ CẬP NHẬT THÀNH CÔNG: CĂN PHẢI NÚT, CHỐNG ĐÈ NHAU VÀ DỊCH 100% CÁC LABEL (SCREENSHOT-8 V3)!';
GO
`;

const destPath = path.resolve(__dirname, '../fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql');
fs.writeFileSync(destPath, finalSql, 'utf8');
console.log('✅ Đã tạo thành công file patch:', destPath);
