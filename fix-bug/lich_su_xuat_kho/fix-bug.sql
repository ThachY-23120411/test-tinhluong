USE [Vietinsoft_ForTest_Tai2];
GO

/* ====================================================================================================
   DỰ ÁN: PARADISE HRM - SỬA LỖI RESPONSIVE & ĐỒNG BỘ GIAO DIỆN
   MENU: TRANG CHỦ CRM > KHO > LỊCH SỬ XUẤT KHO (MnuKPI021)
   DATABASE: Vietinsoft_ForTest_Tai2
   MÃ NGUỒN: sp_WH_InventoryExport_html & sp_WH_InventoryExport
   THAM CHIẾU CHUẨN MỰC: Lịch sử nhập kho (sp_WH_InventoryImport_html / MnuKPI019)
   MỤC TIÊU:
     1. Khắc phục lỗi bố cục Toolbar bị vỡ 2 tầng rời rạc, cụm checkbox nằm trơ trọi Hàng 2.
     2. Đồng bộ 100% phong cách giao diện Dark Theme và bố cục Toolbar linh hoạt của Lịch sử nhập kho.
     3. Tối ưu hóa kích thước ô chọn ngày (105px dd/MM/yyyy) với nhãn ngoài gọn gàng.
     4. Tích hợp nút [+ Thêm mới] và ô [🔍 Tìm kiếm theo nội dung] căn phải (toolbar-right-actions).
     5. Dàn đều trên 1 HÀNG DUY NHẤT trên Desktop lớn (1920px/1440px) và ngắt chuẩn 2 HÀNG trên Snap 868px.
==================================================================================================== */
GO

-- BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN [dbo].[sp_WH_InventoryExport_html]
-- ============================================================================
-- 10. sp_WH_InventoryExport_html
-- ============================================================================

ALTER PROCEDURE [dbo].[sp_WH_InventoryExport_html]
as
	DECLARE @Empty nvarchar(max) = '', @Html nvarchar(max) = ''

	select @Html = N'
        <style>
/* ============================================================================
   LỊCH SỬ XUẤT KHO (sp_WH_InventoryExport_html) - UNIFIED DARK THEME & RESPONSIVE
   Tham chiếu chuẩn mực từ Lịch sử nhập kho (sp_WH_InventoryImport_html)
   ============================================================================ */
#sp_WH_InventoryExport_html {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

#sp_WH_InventoryExport_html .container-fluid {
    padding-left: 16px !important;
    padding-right: 16px !important;
    margin-top: 10px !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

/* --- DATAGRID CONTAINER --- */
#gridInventoryExport {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

#gridInventoryExport .dx-datagrid {
    max-width: 100% !important;
    font-size: 13px !important;
}

#gridInventoryExport .dx-datagrid-headers,
#gridInventoryExport .dx-datagrid-rowsview,
#gridInventoryExport .dx-datagrid-total-footer {
    overflow-x: auto !important;
}

#gridInventoryExport .dx-datagrid-headers .dx-header-row > td {
    font-weight: 600 !important;
    vertical-align: middle !important;
    white-space: nowrap !important;
}

#gridInventoryExport .dx-datagrid-rowsview .dx-row > td {
    vertical-align: middle !important;
}

/* FIX CHE KHUẤT DGV: Tự động co giãn theo chiều cao toolbar, không để headers đè lên toolbar */
#gridInventoryExport .dx-datagrid-header-panel {
    height: auto !important;
    overflow: visible !important;
    padding: 4px 0 8px 0 !important;
}

/* --- UNIFIED FLUID TOOLBAR (DÀN ĐỀU 1 HÀNG TRÊN MÀN HÌNH CHUẨN, WRAP TỰ NHIÊN KHI HẾT CHỖ) --- */
#gridInventoryExport .dx-toolbar {
    height: auto !important;
    min-height: auto !important;
    overflow: visible !important;
    background: transparent !important;
}

#gridInventoryExport .dx-toolbar-items-container {
    height: auto !important;
    min-height: auto !important;
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    width: 100% !important;
    padding: 0 !important;
}

/* Đưa dx-toolbar-before về normal flow (position: static) để header-panel tự động đẩy dgv xuống */
#gridInventoryExport .dx-toolbar-before {
    position: static !important;
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    height: auto !important;
    padding: 0 !important;
}

#gridInventoryExport .dx-toolbar-after,
#gridInventoryExport .dx-toolbar-center {
    display: none !important;
}

#gridInventoryExport .dx-toolbar-item,
#gridInventoryExport .dx-toolbar-item-content {
    position: static !important;
    flex: 1 1 100% !important;
    width: 100% !important;
    max-width: 100% !important;
    height: auto !important;
    padding: 0 !important;
}

/* --- FILTER TOOLBAR ITEMS (TẤT CẢ PHẦN TỬ CĂN TRÁI LIỀN MẠCH, THẲNG HÀNG) --- */
#gridInventoryExport .ms-filter-toolbar {
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    justify-content: flex-start !important;
    gap: 6px !important;
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

/* --- EMPLOYEE FILTER DISPLAY BOX (GIỮ NGUYÊN BẢN GỐC, TĂNG CHIỀU NGANG ĐỂ KHÔNG BỊ XUỐNG DÒNG) --- */
#gridInventoryExport #multilselectedEmployeeInventoryExport {
    width: 170px !important;
    max-width: 100% !important;
    min-width: 0 !important;
    white-space: nowrap !important;
}

#gridInventoryExport #multilselectedEmployeeInventoryExport * {
    white-space: nowrap !important;
}

/* --- DATE PICKERS (CLEAN SINGLE-BORDER DESIGN, 105PX VỪA VẶN dd/MM/yyyy) --- */
#gridInventoryExport .filter-from-date,
#gridInventoryExport .filter-to-date {
    width: 105px !important;
    min-width: 105px !important;
    height: 32px !important;
    min-height: 32px !important;
    max-height: 32px !important;
    background-color: #212529 !important;
    border: 1px solid #3e444a !important;
    border-radius: 4px !important;
    box-sizing: border-box !important;
    transition: border-color 0.2s, box-shadow 0.2s !important;
}

#gridInventoryExport .filter-from-date.dx-editor-outlined,
#gridInventoryExport .filter-to-date.dx-editor-outlined {
    border: 1px solid #3e444a !important;
}

#gridInventoryExport .filter-from-date:hover,
#gridInventoryExport .filter-to-date:hover,
#gridInventoryExport .filter-from-date.dx-state-focused,
#gridInventoryExport .filter-to-date.dx-state-focused {
    border-color: #198754 !important;
}

#gridInventoryExport .filter-from-date .dx-dropdowneditor-input-wrapper,
#gridInventoryExport .filter-to-date .dx-dropdowneditor-input-wrapper,
#gridInventoryExport .filter-from-date .dx-texteditor-container,
#gridInventoryExport .filter-to-date .dx-texteditor-container {
    border: none !important;
    background: transparent !important;
    height: 30px !important;
}

#gridInventoryExport .filter-from-date .dx-texteditor-input,
#gridInventoryExport .filter-to-date .dx-texteditor-input {
    color: #ffffff !important;
    background-color: transparent !important;
    height: 30px !important;
    font-size: 12px !important;
    padding: 0 4px !important;
    border: none !important;
    box-sizing: border-box !important;
}

#gridInventoryExport .filter-from-date .dx-dropdowneditor-button,
#gridInventoryExport .filter-to-date .dx-dropdowneditor-button {
    width: 24px !important;
    min-width: 24px !important;
}

#gridInventoryExport .filter-from-date .dx-dropdowneditor-icon,
#gridInventoryExport .filter-to-date .dx-dropdowneditor-icon {
    color: #8b949e !important;
}

/* --- ACTION BUTTONS (GỌN GÀNG, ĐỒNG BỘ MÀU XANH PARADISE) --- */
#gridInventoryExport .btn-add-inventory {
    height: 32px !important;
    min-height: 32px !important;
    padding: 0 8px !important;
    font-size: 12px !important;
    font-weight: 500 !important;
    border-radius: 4px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 5px !important;
    white-space: nowrap !important;
    box-sizing: border-box !important;
    transition: all 0.2s !important;
    box-shadow: none !important;
}

#gridInventoryExport .btn-add-inventory.btn-success {
    background-color: #198754 !important;
    border: 1px solid #198754 !important;
    color: #ffffff !important;
}

#gridInventoryExport .btn-add-inventory.btn-success:hover {
    background-color: #157347 !important;
    border-color: #146c43 !important;
}

#gridInventoryExport .btn-add-inventory.btn-outline-success {
    background-color: transparent !important;
    border: 1px solid #198754 !important;
    color: #198754 !important;
}

#gridInventoryExport .btn-add-inventory.btn-outline-success:hover {
    background-color: #198754 !important;
    color: #ffffff !important;
}

/* --- CHECKBOXES IN TOOLBAR --- */
#gridInventoryExport .toolbar-checkbox-wrap {
    display: inline-flex !important;
    align-items: center !important;
    gap: 8px !important;
    padding: 0 2px !important;
    height: 32px !important;
}

#gridInventoryExport .toolbar-checkbox-item {
    display: inline-flex !important;
    align-items: center !important;
    gap: 5px !important;
    cursor: pointer !important;
    margin: 0 !important;
    user-select: none !important;
}

#gridInventoryExport .toolbar-checkbox-item input[type="checkbox"] {
    width: 15px !important;
    height: 15px !important;
    accent-color: #198754 !important;
    cursor: pointer !important;
    margin: 0 !important;
}

#gridInventoryExport .toolbar-checkbox-item label,
#gridInventoryExport .toolbar-checkbox-label {
    font-size: 12px !important;
    color: #adb5bd !important;
    cursor: pointer !important;
    margin: 0 !important;
    font-weight: 400 !important;
    white-space: nowrap !important;
}

/* --- COMPACT FLUID SEARCH BOX (KHÔNG BỊ BÓNG MA, CĂN PHẢI, HIỂN THỊ ĐẦY ĐỦ TEXT) --- */
#gridInventoryExport .filter-search-box {
    height: 32px !important;
    min-height: 32px !important;
    max-height: 32px !important;
    width: 185px !important;
    flex: 0 0 185px !important;
    min-width: 160px !important;
    max-width: 220px !important;
    background-color: #212529 !important;
    border: 1px solid #3e444a !important;
    border-radius: 4px !important;
    display: inline-flex !important;
    align-items: center !important;
    padding: 0 8px !important;
    box-sizing: border-box !important;
    transition: border-color 0.2s !important;
}

#gridInventoryExport .filter-search-box:hover,
#gridInventoryExport .filter-search-box:focus-within {
    border-color: #198754 !important;
}

#gridInventoryExport .filter-search-box i {
    color: #8b949e !important;
    font-size: 12px !important;
    margin-right: 6px !important;
}

#gridInventoryExport .filter-search-box input {
    border: none !important;
    background: transparent !important;
    color: #ffffff !important;
    font-size: 12px !important;
    width: 100% !important;
    outline: none !important;
    padding: 0 !important;
}

#gridInventoryExport .filter-search-box input::placeholder {
    color: #8b949e !important;
    font-size: 12px !important;
    opacity: 1 !important;
}

/* --- RIGHT-ALIGNED ACTIONS (+ THÊM MỚI & SEARCH BOX CĂN PHẢI) --- */
#gridInventoryExport .toolbar-right-actions {
    display: flex !important;
    align-items: center !important;
    gap: 6px !important;
    margin-left: auto !important;
    flex: 0 0 auto !important;
}

@media (max-width: 480px) {
    #gridInventoryExport .toolbar-right-actions {
        width: 100% !important;
        margin-left: 0 !important;
        justify-content: space-between !important;
    }
    #gridInventoryExport .filter-search-box {
        flex: 1 1 auto !important;
        max-width: 100% !important;
    }
}
</style>
 <div id="sp_WH_InventoryExport_html" class="mt-4">
  <div class="container-fluid">
        <div class="d-none"><div id="EmployeeListInventoryExport"></div></div>

      <div id="gridInventoryExport" style="height: 100%"></div>
  </div>
</div>
<script>
  (() => {
    let InventoryCode
    let fromDateValue,toDateValue,isViewAll = true

    let _pageCache = {};
        let dataStore_GridInventoryExport = [];
        let _currentKeyword = "";

        async function ReloadData(pageNumber = 1, pageSize = 50) {

          function normalizeKeyword(text) {

            if (!text) return "";

            let t = String(text);

            if (typeof RemoveToneMarks_Js === "function") t = RemoveToneMarks_Js(t);
            else if (t.normalize)
              t = t.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

            return t.replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase().trim();
          }

          let gridInstance = InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90;

          dataStore_GridInventoryImport = new DevExpress.data.CustomStore({
            key: "InventoryCode",

            load: async function (loadOptions) {
              const arrEmployee = InstanceEmployeeIDEmployeeListInventoryExport.option("value") || ""
              const take = loadOptions.take || pageSize;
              const skip = loadOptions.skip || 0;

              const curPage = Math.floor(skip / take) + 1;

              const keyword = _currentKeyword;

              const cacheKey =
                `${fromDateValue}_${toDateValue}_${isViewAll}_${arrEmployee}_${keyword}_${curPage}_${take}`;

              if (_pageCache[cacheKey]) {
                return _pageCache[cacheKey];
              }

              let result = await AjaxHPAParadiseAsync({
                data: {
                  name: "sp_WH_getGridInventoryExport",
                  param: [
                    "FromDate", fromDateValue,
                    "ToDate", toDateValue,
                    "isViewAll", isViewAll,
                    "arrEmployee", arrEmployee,
                    "Keyword", keyword,
                    "PageNumber", curPage,
                    "PageSize", take
                  ],
                },
              });

              let json = typeof result === "string" ? JSON.parse(result) : result;

              let rows = Array.isArray(json?.data?.[0])
                ? json.data[0]
                : json?.data?.[0]
                  ? [json.data[0]]
                  : [];

              let totalCount = json?.data?.[1]?.[0]?.TotalCount ?? rows.length;

              const pageData = {
                data: rows,
                totalCount: totalCount
              };

              _pageCache[cacheKey] = pageData;

              return pageData;
            },
          });

          gridInstance.beginUpdate();

          gridInstance.option({
            dataSource: dataStore_GridInventoryImport,

            scrolling: {
              mode: "standard",
              showScrollbar: "onHover",
            },

            remoteOperations: {
              paging: true,
              filtering: false
            },

            paging: {
              enabled: true,
              pageSize: pageSize,
      },

            pager: {
              visible: true,
              allowedPageSizes: [5, 10, 50, 100],
              showPageSizeSelector: true,
              showInfo: true,
              showNavigationButtons: true,
            },

            searchPanel: {
              highlightSearchText: false,
            },

            onOptionChanged: function (e) {
              if (e.fullName === "searchPanel.text") {

                _currentKeyword = normalizeKeyword(e.value);

                _pageCache = {};

                gridInstance.refresh();
              }
            },
          });

          gridInstance.endUpdate();
        }

  window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
  window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
  let InstanceEmployeeIDEmployeeListInventoryExport = null;

  function loadGlobalAvatarIfNeededEmployeeIDEmployeeListInventoryExport(
    employeeId,
    storeImgName,
    paramImg,
    callbackFn,
  ) {
    const idStr = String(employeeId);

    if (window.GlobalEmployeeAvatarCache[idStr]) {
      if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
      return window.GlobalEmployeeAvatarCache[idStr];
    }

    if (window.GlobalEmployeeAvatarLoading[idStr]) {
      if (callbackFn) {
        window.GlobalEmployeeAvatarLoading[idStr].callbacks =
          window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
      }
      return null;
    }

    if (!storeImgName) {
      return null;
    }

    window.GlobalEmployeeAvatarLoading[idStr] = {
      loading: true,
      callbacks: callbackFn ? [callbackFn] : [],
    };

    let paramArray = [];
    if (paramImg) {
      try {
        const decoded = decodeURIComponent(paramImg);
        paramArray = JSON.parse(decoded);
      } catch (e) {
        paramArray = [];
      }
    }

    AjaxHPAParadise({
      data: {
        name: storeImgName,
        param: paramArray,
      },
      xhrFields: { responseType: "blob" },
      cache: true,
      success: function (blob) {
        const callbacks =
          window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
        delete window.GlobalEmployeeAvatarLoading[idStr];

        if (blob && blob.size > 0) {
          const url = URL.createObjectURL(blob);
          window.GlobalEmployeeAvatarCache[idStr] = url;

          callbacks.forEach((cb) => {
            try {
              cb(url);
            } catch (e) {
              console.error(e);
            }
          });
        } else {
          callbacks.forEach((cb) => {
            try {
              cb(null);
            } catch (e) {
              console.error(e);
            }
          });
        }
      },
      error: function () {
        const callbacks =
          window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
        delete window.GlobalEmployeeAvatarLoading[idStr];

        callbacks.forEach((cb) => {
          try {
            cb(null);
          } catch (e) {
            console.error(e);
          }
        });
      },
    });

    return null;
  }

  window["DataSource_EmployeeIDWH_InventoryExport"] = window["DataSource_EmployeeIDWH_InventoryExport"] || [];
  let spNameDSEEmployeeIDEmployeeListInventoryExport =
    "sp_EmployeeListDataMultiSelectSelectBox";
  let EmployeeIDEmployeeListInventoryExportSelectedIds = [],
    EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal = [];
  const MAX_VISIBLE_EmployeeIDEmployeeListInventoryExport = 3;
  let _autoSaveEmployeeIDEmployeeListInventoryExport = false;
  let _readOnlyEmployeeIDEmployeeListInventoryExport = false;
  let EmployeeIDEmployeeListInventoryExportIsSaving = false;

  $(document).ready(function () {
    // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
    if (
      spNameDSEEmployeeIDEmployeeListInventoryExport &&
      spNameDSEEmployeeIDEmployeeListInventoryExport.trim() !== ""
    ) {
      loadDataSourceCommon(
        "EmployeeIDEmployeeListInventoryExport",
        spNameDSEEmployeeIDEmployeeListInventoryExport,
        function (data) {
          window["DataSource_EmployeeIDWH_InventoryExport"] = data || [];
          if (Array.isArray(data) && data.length > 0) {
            data.forEach((emp) => {
              hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV);
            });
          }
          if (
            typeof renderDisplayBoxEmployeeIDEmployeeListInventoryExport ===
            "function"
          ) {
            renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
          }
        },
      );
    }
  });

  function getInitialsEmployeeIDEmployeeListInventoryExport(name) {
    if (!name) return "?";
    const words = name.trim().split(/\s+/);
    if (words.length >= 2)
      return (words[0][0] + words[words.length - 1][0]).toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  function getColorForIdEmployeeIDEmployeeListInventoryExport(id) {
    const colors = [
      { bg: "#e3f2fd", text: "#1976d2" },
      { bg: "#f3e5f5", text: "#7b1fa2" },
      { bg: "#e8f5e9", text: "#388e3c" },
      { bg: "#fff3e0", text: "#f57c00" },
      { bg: "#fce4ec", text: "#c2185b" },
    ];
    const numId = parseInt(id, 10);
    const index = isNaN(numId) ? 0 : Math.abs(numId) % colors.length;
    return colors[index];
  }

  function renderDisplayBoxEmployeeIDEmployeeListInventoryExport() {
    const $displayBoxEmployeeIDEmployeeListInventoryExport = $(
      "#EmployeeIDEmployeeListInventoryExport_display",
    );
    if (!$displayBoxEmployeeIDEmployeeListInventoryExport.length) return;
    $displayBoxEmployeeIDEmployeeListInventoryExport.empty();

    const $wrapper = $("<div>")
      .css({
        borderBottom: "1px solid #ddd",
        padding: "0 6px",
        minHeight: "30px",
        display: "flex",
        alignItems: "center",
        cursor: "pointer",
        transition: "border-bottom-color 0.2s",
      })
      .attr("tabIndex", "0")
      .on("keydown", function (e) {
        if (e.key === "Enter" || e.key === " " || e.key === "Spacebar") {
          e.preventDefault();
          if (_readOnlyEmployeeIDEmployeeListInventoryExport) return;
          if (!popupEmployeeIDEmployeeListInventoryExport) {
            initPopupEmployeeIDEmployeeListInventoryExport();
            setTimeout(
              () => popupEmployeeIDEmployeeListInventoryExport.show(),
              0,
            );
          } else {
            popupEmployeeIDEmployeeListInventoryExport.show();
          }
        }
      })
      .on("focus", function () {
        $wrapper.css({ borderBottom: "2px solid #337ab7", outline: "none" });
      })
      .on("blur", function () {
        $wrapper.css({ borderBottom: "1px solid #ddd" });
      })
      .hover(
        () => {
          if (!$wrapper.is(":focus")) {
            $wrapper.css({ borderBottom: "1px solid #337ab7" });
          }
        },
        () => {
          if (!$wrapper.is(":focus")) {
            $wrapper.css({ borderBottom: "1px solid #ddd" });
          }
        },
      );

    if (EmployeeIDEmployeeListInventoryExportSelectedIds.length === 0) {
      $wrapper.append(
        $("<span>")
          .addClass("text-muted")
          .html(''<i class="bi bi-person-plus me-2"></i>Chọn nhân viên...''),
      );
    } else {
      const displayIds =
        EmployeeIDEmployeeListInventoryExportSelectedIds.slice(
          0,
          MAX_VISIBLE_EmployeeIDEmployeeListInventoryExport,
        );
      const $group = $("<div>").css({ display: "flex", alignItems: "center" });

      displayIds.forEach((id, index) => {
        const item = window["DataSource_EmployeeIDWH_InventoryExport"].find(
          (e) => String(e.ID) === String(id),
        );
        if (!item) return;

        const $chip = $("<div>")
          .css({
            width: "36px",
            height: "36px",
            borderRadius: "50%",
            border: "3px solid #fff",
            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
            marginLeft: index === 0 ? "0" : "-10px",
            zIndex: index + 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontWeight: "600",
            fontSize: "13px",
            position: "relative",
            overflow: "hidden",
          })
          .attr("title", item.Name || item.FullName || "");

        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];

        if (cachedUrl) {
          $chip.append(
            $("<img>")
              .attr("src", cachedUrl)
              .css({ width: "100%", height: "100%", objectFit: "cover" }),
          );
        } else if (item.storeImgName) {
          loadGlobalAvatarIfNeededEmployeeIDEmployeeListInventoryExport(
            id,
            item.storeImgName,
            item.paramImg,
            function (url) {
              renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
            },
          );
          const color =
            getColorForIdEmployeeIDEmployeeListInventoryExport(id);
          const initials =
            getInitialsEmployeeIDEmployeeListInventoryExport(
              item.Name || item.FullName,
            );
          $chip.css({ background: color.bg, color: color.text }).text(initials);
        } else {
          const color =
            getColorForIdEmployeeIDEmployeeListInventoryExport(id);
          const initials =
            getInitialsEmployeeIDEmployeeListInventoryExport(
              item.Name || item.FullName,
            );
          $chip.css({ background: color.bg, color: color.text }).text(initials);
        }

        $group.append($chip);
      });

      if (
        EmployeeIDEmployeeListInventoryExportSelectedIds.length >
        MAX_VISIBLE_EmployeeIDEmployeeListInventoryExport
      ) {
        const remaining =
          EmployeeIDEmployeeListInventoryExportSelectedIds.length -
          MAX_VISIBLE_EmployeeIDEmployeeListInventoryExport;
        $group.append(
          $("<div>")
            .css({
              width: "36px",
              height: "36px",
              borderRadius: "50%",
              border: "3px solid #fff",
              marginLeft: "-10px",
              zIndex:
                MAX_VISIBLE_EmployeeIDEmployeeListInventoryExport + 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontWeight: "700",
              fontSize: "12px",
            })
            .text("+" + remaining)
            .attr("title", "Còn " + remaining + " người nữa"),
        );
      }

      $wrapper.append($group);
    }

    $displayBoxEmployeeIDEmployeeListInventoryExport.append($wrapper);
    $wrapper.off("click").on("click", () => {
      if (_readOnlyEmployeeIDEmployeeListInventoryExport) {
        if (typeof uiManager !== "undefined" && uiManager.showAlert) {
          uiManager.showAlert({
            type: "info",
            message: "This field is read-only.",
          });
        } else {
          alert("This field is read-only.");
        }
        return;
      }
      if (!popupEmployeeIDEmployeeListInventoryExport) {
        initPopupEmployeeIDEmployeeListInventoryExport();
        setTimeout(() => {
          popupEmployeeIDEmployeeListInventoryExport.show();
        }, 0);
      } else {
        popupEmployeeIDEmployeeListInventoryExport.show();
      }
    });
  }

  const $containerEmployeeIDEmployeeListInventoryExport = $(
    "#EmployeeListInventoryExport",
  );
  $containerEmployeeIDEmployeeListInventoryExport.empty();
  const $displayBoxEmployeeIDEmployeeListInventoryExport = $(
    "<div>",
  ).attr("id", "EmployeeIDEmployeeListInventoryExport_display");
  $containerEmployeeIDEmployeeListInventoryExport.append(
    $displayBoxEmployeeIDEmployeeListInventoryExport,
  );

  let popupEmployeeIDEmployeeListInventoryExport;
  let popupEmployeeIDEmployeeListInventoryExportOnce = false;
  let EmployeeIDEmployeeListInventoryExportGridContainer = null;

  function initPopupEmployeeIDEmployeeListInventoryExport() {
    if (popupEmployeeIDEmployeeListInventoryExportOnce) {
      popupEmployeeIDEmployeeListInventoryExport.show();
      return;
    }

    // FIXED: Dọn dẹp DOM rác
    $("#EmployeeIDEmployeeListInventoryExport_popup").remove();

    popupEmployeeIDEmployeeListInventoryExportOnce = true;
    popupEmployeeIDEmployeeListInventoryExport = $("<div>")
      .attr("id", "EmployeeIDEmployeeListInventoryExport_popup")
      .appendTo(document.body)
      .addClass("hpa-responsive")
      .dxPopup({
        width: () => (window.innerWidth < 768 ? "95vw" : 750),
        maxHeight: "90vh",
        height: "auto",
        animation: null,
        showTitle: true,
        title: "Chọn nhân viên",
        dragEnabled: true,
        closeOnOutsideClick: true,
        showCloseButton: true,
        toolbarItems: [
          {
            widget: "dxButton",
            location: "before",
            toolbar: "bottom",
            options: {
              text: "Xóa chọn",
              type: "danger",
              stylingMode: "outlined",
              onClick: () => {
                EmployeeIDEmployeeListInventoryExportSelectedIds = [];
                try {
                  EmployeeIDEmployeeListInventoryExportGridContainer.dxDataGrid(
                    "instance",
                  ).deselectAll();
                } catch (e) {}
              },
            },
          },
          {
            widget: "dxButton",
            location: "after",
            toolbar: "bottom",
            options: {
              text: "Hủy",
              onClick: () => {
                EmployeeIDEmployeeListInventoryExportSelectedIds = [
                  ...EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal,
                ];
                popupEmployeeIDEmployeeListInventoryExport.hide();
              },
            },
          },
          {
            widget: "dxButton",
            location: "after",
            toolbar: "bottom",
            options: {
              text: "Lưu",
              type: "success",
              '+@Empty+N'
              onClick: async () => {
                if (
                  _autoSaveEmployeeIDEmployeeListInventoryExport &&
                  typeof saveValueEmployeeIDEmployeeListInventoryExport ===
                    "function"
                ) {
                  await saveValueEmployeeIDEmployeeListInventoryExport();
                } else {
                  // Local Save (Sync Grid)
                  if (
                    typeof cellInfo !== "undefined" &&
                    cellInfo &&
                    cellInfo.component
                  ) {
                    try {
                      const grid = cellInfo.component;
                      const newValue =
                        EmployeeIDEmployeeListInventoryExportSelectedIds.join(
                          ",",
                        );
                      grid.cellValue(
                        cellInfo.rowIndex,
                        "EmployeeID",
                        newValue || null,
                      );
                      grid.repaint();
                    } catch (e) {
                      console.warn(e);
                    }
                  }
                  EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal =
 [...EmployeeIDEmployeeListInventoryExportSelectedIds];
                  renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
                }
                popupEmployeeIDEmployeeListInventoryExport.hide();
              },
            },
          },
        ],
        contentTemplate: function (contentElement) {
          EmployeeIDEmployeeListInventoryExportGridContainer = $("<div>");
          contentElement.append(
            EmployeeIDEmployeeListInventoryExportGridContainer,
          );
        },
        onShown: () => {
          const sortedData = window["DataSource_EmployeeIDWH_InventoryExport"].sort((a, b) => {
            const aSelected =
              EmployeeIDEmployeeListInventoryExportSelectedIds.includes(
                String(a.ID),
              );
            const bSelected =
              EmployeeIDEmployeeListInventoryExportSelectedIds.includes(
                String(b.ID),
              );
            return bSelected - aSelected;
          });

          try {
            const existingInstance =
              EmployeeIDEmployeeListInventoryExportGridContainer.dxDataGrid(
                "instance",
              );
            if (existingInstance) {
              existingInstance.dispose();
            }
          } catch (e) {
            // Instance chưa tồn tại hoặc đã bị destroy
          }

          EmployeeIDEmployeeListInventoryExportGridContainer.empty().dxDataGrid(
            {
              dataSource: sortedData,
              keyExpr: "ID",
              remoteOperations: false,
              columnAutoWidth: true,
              allowColumnResizing: true,
              selection: { mode: "multiple", showCheckBoxesMode: "always" },
              selectedRowKeys:
                EmployeeIDEmployeeListInventoryExportSelectedIds,
              focusStateEnabled: true,
              keyboardNavigation: { enabled: true },
              hoverStateEnabled: true,
              columns: [
                {
                  caption: "Ảnh",
                  width: 70,
                  alignment: "center",
                  cellTemplate: function (container, options) {
                    const item = options.data;
                    const $cell = $("<div>").css({
                      display: "flex",
                      justifyContent: "center",
                      alignItems: "center",
                      height: "100%",
                    });

                    const cachedUrl =
                      window.GlobalEmployeeAvatarCache[String(item.ID)];

                    if (cachedUrl) {
                      $cell.append(
                        $("<img>").attr("src", cachedUrl).css({
                          width: "30px",
                          height: "30px",
                          borderRadius: "50%",
                          objectFit: "cover",
                          border: "2px solid #fff",
                          boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                        }),
                      );
                    } else if (item.storeImgName) {
                      loadGlobalAvatarIfNeededEmployeeIDEmployeeListInventoryExport(
                        item.ID,
                        item.storeImgName,
                        item.paramImg,
                        function (url) {
                          EmployeeIDEmployeeListInventoryExportGridContainer.dxDataGrid(
                            "instance",
                          ).refresh();
                        },
                      );

                      const initials =
                        getInitialsEmployeeIDEmployeeListInventoryExport(
                          item.Name || item.FullName || "?",
                        );
                      const color =
                        getColorForIdEmployeeIDEmployeeListInventoryExport(
        item.ID,
       );
                      $cell.append(
                        $("<div>").text(initials).css({
                          width: "30px",
                          height: "30px",
                          borderRadius: "50%",
                          background: color.bg,
                          color: color.text,
                          display: "flex",
                          justifyContent: "center",
                          alignItems: "center",
                          fontWeight: "600",
                          fontSize: "14px",
                          boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                        }),
                      );
                    } else {
                      const initials =
                        getInitialsEmployeeIDEmployeeListInventoryExport(
                          item.Name || item.FullName || "?",
                        );
                      const color =
                        getColorForIdEmployeeIDEmployeeListInventoryExport(
                          item.ID,
                        );
                      $cell.append(
                        $("<div>").text(initials).css({
                          width: "30px",
                          height: "30px",
                          borderRadius: "50%",
                          background: color.bg,
                          color: color.text,
                          display: "flex",
                          justifyContent: "center",
                          alignItems: "center",
                          fontWeight: "600",
                          fontSize: "14px",
                          boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                        }),
                      );
                    }

                    container.append($cell);
                  },
                },
                { dataField: "Name", caption: "Họ tên" },
                { dataField: "Email", caption: "Email", hidingPriority: 0 },
                {
                  dataField: "Position",
                  caption: "Chức vụ",
                  hidingPriority: 1,
                },
              ],
              searchPanel: {
                visible: true,
                placeholder: "",
              },
              onContentReady: function (e) {
                const grid = e.component;

                grid.option("searchPanel.text", "");

                const searchBox = grid
                  .getView("headerPanel")
                  ._$element.find(".dx-datagrid-search-panel input");

                if (searchBox.length) {
                  if (
                    !$(
                      "#custom-search-style-EmployeeIDEmployeeListInventoryExport",
                    ).length
                  ) {
                    $("<style>")
                      .attr(
                        "id",
                        "custom-search-style-EmployeeIDEmployeeListInventoryExport",
                      )
                      .text(
                        `
                                                    .dx-datagrid-search-panel input:not(:placeholder-shown) {
                                                        color: #000 !important;
                                                    }
                                                    .dx-datagrid-search-panel input::placeholder {
                                                        color: #999 !important;
                                                        opacity: 1 !important;
                                                    }
                                                `,
                      )
                      .appendTo("head");
                  }

                  // Unbind only search-related events (preserve click, focus, etc.)
                  searchBox.off("input keyup");

               searchBox.on("input", function () {
                    const searchValue = $(this).val();

                    if (!searchValue) {
                      grid.clearFilter();
                      return;
                    }

                    const searchNormalized = RemoveToneMarks_Js(searchValue);

                    grid.filter(function (item) {
                      const fields = ["Name", "Email", "Position"];
                      for (let i = 0; i < fields.length; i++) {
                        const fieldValue = item[fields[i]];
                        if (fieldValue) {
                          const fieldNormalized = RemoveToneMarks_Js(
                            String(fieldValue),
                          );
                          if (
                            fieldNormalized.indexOf(searchNormalized) !== -1
                          ) {
                            return true;
                          }
                        }
                      }
                      return false;
                    });
                  });
                }
              },
              paging: {
                enabled: true,
                pageSize: 5,
                pageIndex: 0,
              },
              pager: {
                visible: true,
                allowedPageSizes: [5, 10],
                showPageSizeSelector: true,
                showInfo: true,
                showNavigationButtons: true,
              },
              onSelectionChanged: (e) =>
                (EmployeeIDEmployeeListInventoryExportSelectedIds =
                  e.selectedRowKeys || []),
            },
          );
        },
        onHidden: () => {
          // FIXED: KHÔNG dispose grid tại đây
          // Reset position của popup về default
          popupEmployeeIDEmployeeListInventoryExport.option("position", {
            my: "center",
            at: "center",
            of: window,
          });

          renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
        },
      })
      .dxPopup("instance");
  }

  async function saveValueEmployeeIDEmployeeListInventoryExport() {
    if (_readOnlyEmployeeIDEmployeeListInventoryExport) {
      if (typeof uiManager !== "undefined" && uiManager.showAlert) {
        uiManager.showAlert({
          type: "info",
          message: "This field is read-only.",
        });
      } else {
        alert("This field is read-only.");
      }
      return;
    }

    const original =
      EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal.slice()
        .sort()
        .join(",");
    const current =
      EmployeeIDEmployeeListInventoryExportSelectedIds.slice()
        .sort()
        .join(",");
    if (
      original === current ||
      EmployeeIDEmployeeListInventoryExportIsSaving
    )
      return;

    EmployeeIDEmployeeListInventoryExportIsSaving = true;
    try {
      const newValue =
        EmployeeIDEmployeeListInventoryExportSelectedIds.join(",");
      const dataJSON = JSON.stringify([
        "-99218308",
        ["EmployeeID"],
        [newValue || null],
      ]);

      let id1 = window.currentRecordID_EmployeeID;
      if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
        id1 = cellInfo.data["EmployeeID"] || id1;
      }
      let idValues = [id1];
      let idFields = ["EmployeeID"];

      if ("" && "".trim() !== "") {
        let id2 = currentRecordID_;
        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
          id2 = cellInfo.data[""] || id2;
        }
        idValues.push(id2);
        idFields.push("");
      }
      const idValsJSON = JSON.stringify([idValues, idFields]);

      const json = await saveFunction(dataJSON, idValsJSON);
      const errors = json.data?.[json.data.length - 1] || [];
      if (errors.length > 0 && errors[0].Status === "ERROR") {
        uiManager.showAlert({
          type: "error",
  message: errors[0].Message || "%SaveErrorMessage%",
        });
        return;
      }

      // SYNC GRID
      if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
        try {
          const grid = cellInfo.component;
          grid.cellValue(cellInfo.rowIndex, "EmployeeID", newValue);
          grid.repaint();
        } catch (syncErr) {
          console.warn(
            "[Grid Sync] SelectEmployee EmployeeIDEmployeeListInventoryExport: Không thể sync grid:",
            syncErr,
          );
        }
      }

      EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal = [
        ...EmployeeIDEmployeeListInventoryExportSelectedIds,
      ];
      renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
    } catch (err) {
      uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
    } finally {
      EmployeeIDEmployeeListInventoryExportIsSaving = false;
    }
  }

  InstanceEmployeeIDEmployeeListInventoryExport = {
    setValue: function (val) {
      if (typeof val === "string" && val.trim()) {
        EmployeeIDEmployeeListInventoryExportSelectedIds = val
          .split(",")
          .map((v) => v.trim())
          .filter((v) => v);
      } else if (Array.isArray(val)) {
        EmployeeIDEmployeeListInventoryExportSelectedIds =
          val.map(String);
      } else {
        EmployeeIDEmployeeListInventoryExportSelectedIds = [];
      }
      EmployeeIDEmployeeListInventoryExportSelectedIdsOriginal = [
        ...EmployeeIDEmployeeListInventoryExportSelectedIds,
      ];
      renderDisplayBoxEmployeeIDEmployeeListInventoryExport();
    },
    getValue: () => EmployeeIDEmployeeListInventoryExportSelectedIds,
    getValueAsString: () =>
      EmployeeIDEmployeeListInventoryExportSelectedIds.join(","),
    setDataSource: (data) => {
      window["DataSource_EmployeeIDWH_InventoryExport"] = data || [];
    },
    repaint: renderDisplayBoxEmployeeIDEmployeeListInventoryExport,
    _readOnly: false,
    _autoSave: false,
    option: function (name, value) {
      if (arguments.length === 2) {
        if (name === "value") this.setValue(value);
        if (name === "readOnly") {
          this._readOnly = value;
          _readOnlyEmployeeIDEmployeeListInventoryExport = value;
          const $displayBox = $(
            "#EmployeeIDEmployeeListInventoryExport_display",
          );
          if (value)
            $displayBox.addClass("disabled-control").css("opacity", "0.6");
          else $displayBox.removeClass("disabled-control").css("opacity", "1");
        }
        if (name === "autoSave") {
          this._autoSave = value;
          _autoSaveEmployeeIDEmployeeListInventoryExport = value;
        }
      } else if (arguments.length === 1) {
        if (name === "value") return this.getValueAsString();
        if (name === "dataSource") return window["DataSource_EmployeeIDWH_InventoryExport"];
        if (name === "readOnly")
          return _readOnlyEmployeeIDEmployeeListInventoryExport;
        if (name === "autoSave")
          return _autoSaveEmployeeIDEmployeeListInventoryExport;
      }
      return undefined;
    },
    _suppressValueChangeAction: function () {},
    _resumeValueChangeAction: function () {},
  };

    window.InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90 = null;
    // Thêm responsive styles cho grid header
    const stylegridInventoryExport = document.createElement(''style'');
    stylegridInventoryExport.textContent = `
                            /* =============== RESPONSIVE POPUP STYLES =============== */
                            .dx-datagrid-search-panel .dx-placeholder {
                                display: none !important;
                            }

                            /* =============== FIX TEXTBOX TRONG GRID =============== */
                            .dx-datagrid .dx-texteditor {
                    width: 100% !important;
                                min-width: 0 !important;
                            }

                            .dx-datagrid .dx-texteditor-input {
                                width: 100% !important;
                                min-width: 0 !important;
                                box-sizing: border-box !important;
                            }

                            .dx-datagrid-rowsview .dx-row > td > div {
                                white-space: nowrap;
                                overflow: hidden;
                                text-overflow: ellipsis;
                                word-break: break-word !important;
                                line-height: 1.4 !important;
                            }

                            .dx-popup.hpa-responsive {
                                max-width: 95vw !important;
                                max-height: 95vh !important;
                                width: 95vw !important;
                                left: 0 !important;
                                top: 0 !important;
                            }

 .dx-popup.hpa-responsive .dx-popup-content {
                                height: calc(95vh - 120px) !important;
                                max-height: calc(95vh - 120px) !important;
                                overflow-y: auto !important;
            padding: 8px !important;
                                display: flex !important;
      flex-direction: column !important;
                            }

                 .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                flex: 1 !important;
                                min-height: 0 !important;
                                overflow: auto !important;
                            }

                            .dx-popup-content.dx-popup-content-scrollable {
                  height: auto !important;
                            }

                            .dx-popup.hpa-responsive .dx-toolbar-items {
                                padding: 4px 0 !important;
                                flex-wrap: wrap;
                            }

                            .dx-popup.hpa-responsive .dx-toolbar-item {
                                margin: 2px 2px !important;
                            }

                            /* =============== GRID HEADER STYLES =============== */
                     .dx-datagrid {
                                font-size: 14px;
                                table-layout: fixed !important;
                            }

                            /* FIX COLUMN WIDTH ALIGNMENT */
                            .dx-datagrid-table {
                                table-layout: fixed !important;
                                width: 100% !important;
                            }

                            .dx-datagrid-headers .dx-datagrid-table {
                                table-layout: fixed !important;
                            }

                            .dx-datagrid-rowsview .dx-datagrid-table {
                                table-layout: fixed !important;
                            }

                            /* Ensure header and content cells have same width calculation */
                            .dx-datagrid .dx-header-row > td,
                            .dx-datagrid .dx-data-row > td {
                                box-sizing: border-box !important;
                                overflow: hidden !important;
                            }

                            .dx-datagrid-headers {
                                white-space: normal;
                                word-break: break-word;
                            }

                            .dx-datagrid-header-panel {
                 padding: 8px;
        }

                            .dx-datagrid .dx-header-row {
                                height: auto;
                                min-height: 44px;
                            }

                            .dx-datagrid .dx-row > td {
                                padding: 8px !important;
                                vertical-align: middle !important;
                            }

                            .dx-datagrid .dx-col-fixed {
                                z-index: 800 !important;
                            }

                            /* FORCE COLUMN WIDTH CONSISTENCY */
                            .dx-datagrid .dx-header-row > td,
                            .dx-datagrid .dx-data-row > td {
                                min-width: 0 !important;
                                width: auto !important;
                                max-width: none !important;
                            }

                            /* Prevent column width calculation conflicts */
                            .dx-datagrid-headers .dx-header-row td,
                            .dx-datagrid-rowsview .dx-data-row td {
                                position: relative !important;
                            }

                            /* Group row - sát mép */
                            .dx-datagrid .dx-group-row {

                             padding: 0 !important;
                            }

                            .dx-datagrid .dx-group-row > td {
                                padding: 8px !important;
                            }

                            .dx-datagrid .dx-group-row .dx-group-text {
                                padding: 0 !important;
                                margin: 0 !important;
                            }

                            /* Mobile responsive */
                            @media (max-width: 1024px) {
                                .dx-popup.hpa-responsive {
                                    max-width: 90vw !important;
                                    max-height: 90vh !important;
                                    width: 90vw !important;
                                    left: 5vw !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 90vw !important;
                                    max-width: 90vw !important;
                                }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    max-height: calc(95vh - 120px) !important;
                                }

                                /* Fix grid width alignment on tablet */
                                .dx-datagrid-table {
                                    min-width: 100% !important;
                                }
                            }

                            @media (max-width: 768px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                /* Maintain fixed table layout on mobile */
                                .dx-datagrid-table {
                                    table-layout: fixed !important;
                                    min-width: 100% !important;
                                }

                                .dx-datagrid-headers {
                                    padding: 4px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    height: auto;
                         min-height: 36px;
                                    padding: 0 !important;
          }

.dx-datagrid-text-content {
                                    padding: 4px 2px !important;
                                    font-size: 11px !important;
                                    line-height: 1.3 !important;
       overflow: hidden !important;
                               white-space: nowrap !important;
                                    text-overflow: ellipsis !important;
                                    word-break: break-word !important;
                                }

                                .dx-datagrid-text-content.dx-header-filter {
                                    padding: 2px 1px !important;
                                }

                                .dx-checkbox {
                                    width: 24px !important;
                             height: 24px !important;
                  }

                                .dx-datagrid-rowsview {
                                    padding: 0 !important;
                                }

                                .dx-datagrid .dx-row {
                                    height: auto;
                                    min-height: 36px !important;
         padding: 0 !important;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 4px 8px !important;

   white-space: nowrap !important;
                                    text-overflow: ellipsis !important;
                                    word-break: break-word !important;
                                    vertical-align: middle !important;
                                    overflow: hidden !important;
                                    box-sizing: border-box !important;
                                }

                                .dx-datagrid .dx-group-row > td {
                                    padding: 4px 2px !important;
                                }

                                .dx-pager {
                                    padding: 4px 0 !important;
                                }

                                .dx-pager-page,
                                .dx-pager-navigation {
                                    padding: 2px 4px !important;
                                    font-size: 11px !important;
                                }

                                .dx-searchbox {
                                    width: 100% !important;
                                    max-width: none !important;
                                }

                                .dx-searchbox .dx-texteditor-input {
                                    padding: 4px !important;
                                    font-size: 12px !important;
                                    height: 32px !important;
                                }

                                .dx-popup.hpa-responsive {
                                    max-width: 95vw !important;
                                    max-height: 85vh !important;
                                    width: 95vw !important;
                                    left: 2.5vw !important;
                                    top: 5vh !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 95vw !important;
                                    max-width: 95vw !important;
                                    height: auto !important;
                                    max-height: 85vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {
                                    position: fixed !important;
                                }
       .dx-popup.hpa-responsive .dx-popup-content {
      height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
                                    font-size: 13px !important;
                                    padding: 6px !important;
                             display: flex !important;
    flex-direction: column !important;
                                }

                                .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                    flex: 1 !important;
                                    min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }

                     /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
        width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                        font-size: 12px !important;
                                }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 12px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 4px 2px !important;
                                }
                            }

                            @media (max-width: 480px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                .dx-datagrid-headers {
                                    padding: 2px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid-text-content {
                                    padding: 2px 1px !important;
                                    font-size: 12px !important;
                                }

                                .dx-checkbox {
                                    width: 20px !important;
                                    height: 20px !important;
                                }

                                .dx-datagrid .dx-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 8px !important;
                                    font-size: 12px !important;
                                }

                    .dx-pager-page,
                                .dx-pager-navigation {
            padding: 1px 2px !important;
                                    font-size: 12px !important;
                    }

                              .dx-popup.hpa-responsive {
                                    max-width: 98vw !important;
           max-height: 80vh !important;
                      width: 98vw !important;
                          left: 1vw !important;
                                    top: 10vh !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 98vw !important;
                                    max-width: 98vw !important;
                                    height: auto !important;
                                    max-height: 80vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {

                                    position: fixed !important;
                    }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
             font-size: 12px !important;
                         padding: 4px !important;
                                    display: flex !important;
                                 flex-direction: column !important;
                                }

                                .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                    flex: 1 !important;
                                    min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }
                                /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
                                    padding: 4px 8px !important;
                                    font-size: 11px !important;
                                    min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 4px 8px !important;
                                    font-size: 11px !important;
                                    min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid {
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 2px 1px !important;
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-header-row {
                                    min-height: 28px !important;
    }
                                .dx-popup.hpa-responsive .dx-checkbox {
                                   width: 18px !important;
                                    height: 18px !important;
       }
                            }
                        `;
    document.head.appendChild(stylegridInventoryExport);

    // Helper normalize function: bỏ dấu - dùng chung cho search/grid
    window.normalizeVietnameseText =
      window.normalizeVietnameseText ||
      function (value) {
        if (value === undefined || value === null) return '''';
        let text = String(value);
        if (typeof RemoveToneMarks_Js === ''function'') {
          text = RemoveToneMarks_Js(text);
        } else if (text.normalize) {
          text = text.normalize(''NFD'').replace(/[\u0300-\u036f]/g, '''');
        }
        return text.replace(/đ/g, ''d'').replace(/Đ/g, ''D'').toLowerCase();
      };

    // ===== Column chooser persistence helpers (shared) =====
    const gridName = ''gridInventoryExport'';
    window.hpaColumnChooser = window.hpaColumnChooser || { saveTimers: {} };
    const chooser = window.hpaColumnChooser;

    if (!chooser.normalize) {
      chooser.normalize = function (res) {
        if (typeof res === ''string'' && res.trim() !== '''') {
          return res.includes(''{'')
            ? JSON.parse(res)
            : JSON.parse(EncryptionStringDecryption(res));
        }
 return res;
      };

    }

    if (!chooser.load) {
    chooser.load = function (gridInstance, gridNameParam) {
        AjaxHPAParadise({
          data: {
            name: ''sp_GridColumnChooser_Load'',
            param: [''LoginID'', window.UserID, ''GridName'', gridNameParam],
          },
          success: function (res) {
            const json = chooser.normalize(res);
            const rows = (json?.data && json.data[0]) || [];
            const settingsJson = rows[0]?.SettingsJson;
            if (!settingsJson) return;
            let arr = [];
            try {
              arr = JSON.parse(settingsJson) || [];
            } catch (e) {
              arr = [];
            }
            arr.forEach((r) => {
              if (!r.ColumnName) return;
              const opts = {};
              if (r.IsVisible !== undefined && r.IsVisible !== null)
                opts.visible = r.IsVisible === 1;
              if (r.OrderIndex !== undefined && r.OrderIndex !== null)
                opts.visibleIndex = r.OrderIndex;
              if (r.ColumnWidth !== undefined && r.ColumnWidth !== null)
                opts.width = r.ColumnWidth;
              gridInstance.columnOption(r.ColumnName, opts);
            });
          },
        });
      };
    }

    if (!chooser.save) {
      chooser.save = function (gridInstance, gridNameParam) {
        const cols = (gridInstance.getColumns() || [])
          .map((c) => {
            const name = c.dataField || c.name;
            if (!name) return null;
            return {
              ColumnName: name,
              IsVisible: c.visible !== false ? 1 : 0,
              OrderIndex: c.visibleIndex,
              ColumnWidth: c.width ? parseInt(c.width) : null,
            };
          })
          .filter(Boolean);

        AjaxHPAParadise({
          data: {
            name: ''sp_GridColumnChooser_Save'',
            param: [
              ''LoginID'',
              window.UserID,
              ''GridName'',
              gridNameParam,
              ''Columns'',
              JSON.stringify(cols),
            ],
          },
          success: function (res) {
            if (typeof res === ''string'' && res.trim() !== '''') {
              res = res.includes(''{'') ? res : EncryptionStringDecryption(res);
            }
          },
        });
      };
    }

    // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
    // Hàm tính remoteOperations dựa trên số lượng dòng
    window.getGridConfig_gridInventoryExport = function (dataArray) {
      const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
      const isLargeDataset = dataSize > 1000;

      return {
        remoteOperations: isLargeDataset,
        pageSize: isLargeDataset ? 25 : 10,
        allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100],
      };
    };

    InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90 = $(
      ''#gridInventoryExport''
    )
      .dxDataGrid({
        dataSource: [],
        keyExpr: ''InventoryCode'',
        height: ''100%'',
        width: ''100%'',
        showBorders: true,
        showRowLines: true,
        rowAlternationEnabled: false,
        hoverStateEnabled: false,
        columnAutoWidth: true,
        allowColumnReordering: true,
        allowColumnResizing: true,
        columnResizingMode: ''widget'',
        columnMinWidth: 80,
        wordWrapEnabled: true,

        scrolling: {
          mode: ''virtual'', // standard
          showScrollbar: ''onHover'',
        },

        paging: {
          enabled: true,
          pageSize: 10,
        },

        pager: {
          visible: true,
          allowedPageSizes: [5, 10, 50, 100],
          showPageSizeSelector: true,
          showInfo: true,
          showNavigationButtons: true,
        },

        selection: {
          mode: ''single'',
          showCheckBoxesMode: ''none'',
  allowSelectAll: false,
        },

        searchPanel: { visible: false },

        headerFilter: { visible: false },

        stateStoring: {
          enabled: false,
          type: ''localStorage'',
          storageKey: ''gridState_gridInventoryExport'',
        },

        grouping: {
          autoExpandAll: false,
          contextMenuEnabled: false,
          allowCollapsing: false,
        },

        groupPanel: { visible: false },
        columnFixing: { enabled: false },

        customizeColumns: function (columns) {
          const normalizeText =
            window.normalizeVietnameseText ||
            function (val) {
              if (val === undefined || val === null) return '''';
              return String(val).toLowerCase();
            };

          columns.forEach(function (column) {
            if (column._hpaSearchNormalized) return;
            column._hpaSearchNormalized = true;

            const originalCalculate = column.calculateFilterExpression;
            const dataFieldPath = column.dataField || column.name || '''';
            const getValue = column.calculateCellValue
              ? column.calculateCellValue.bind(column)
              : function (dataObj) {
                  if (!dataObj || !dataFieldPath) return null;
                  if (dataFieldPath.indexOf(''.'') === -1) {
                    return dataObj[dataFieldPath];
                  }
                  return dataFieldPath.split(''.'').reduce(function (acc, key) {
                    return acc && acc[key] !== undefined ? acc[key] : null;
                  }, dataObj);
                };

            column.calculateFilterExpression = function (
              filterValue,
              selectedFilterOperation,
              target
            ) {
              if (target === ''search'') {
                const normalizedFilter = normalizeText(filterValue);
                if (!normalizedFilter) {
                  if (originalCalculate) {
                    return originalCalculate.call(
                      this,
                      filterValue,
                      selectedFilterOperation,
                      target
                    );
                  }
                  if (this.defaultCalculateFilterExpression) {
                    return this.defaultCalculateFilterExpression(
                      filterValue,
                      selectedFilterOperation,
                  target
                    );
                  }
                  return null;
 }

                return function (dataItem) {
                  const rawValue = getValue ? getValue(dataItem) : null;
                  const normalizedValue = normalizeText(rawValue);
                  return normalizedValue.indexOf(normalizedFilter) > -1;
                };
              }

              if (originalCalculate) {
                return originalCalculate.call(
                  this,
                  filterValue,
                  selectedFilterOperation,
                  target
                );
              }

              if (this.defaultCalculateFilterExpression) {
                return this.defaultCalculateFilterExpression(
                  filterValue,
                  selectedFilterOperation,
                  target
                );
              }

              return null;
            };
          });
        },

        editing: {
          mode: ''cell'',
          allowUpdating: false,
     },
        rowDragging: {
          allowReordering: false,
          showDragIcons: false,
        },
        noDataText: ''Không có dữ liệu'',
        columns: [
          {
            dataField: ''InventoryCode'',
            caption: ''Lệnh xuất hàng'',
            width: 150,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (val === undefined || val === null || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              $(''<div>'').text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },

          {
            dataField: ''Date'',
            caption: ''Ngày lập lệnh'',
            width: 150,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              const d = new Date(val);
              let text = '''';
              text = DevExpress.localization.formatDate(d, ''dd/MM/yyyy'');
              $(''<div>'').text(text).appendTo(cellElement);
            },
            allowEditing: false,
          },

          {
            dataField: ''ExpDate'',
            caption: ''Hạn nhập kho'',
            width: 150,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              const d = new Date(val);
              let text = '''';
              text = DevExpress.localization.formatDate(d, ''dd/MM/yyyy'');
              $(''<div>'').text(text).appendTo(cellElement);
            },
            allowEditing: false,
          },

          {
            dataField: ''EmployeeID'',
            caption: ''Người thực hiện'',
width: 150,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              const ds = window[''DataSource_EmployeeID''];

              if (ds && Array.isArray(ds)) {
                const f = ds.find((x) => x.id == val || x.ID == val);
                if (f) {
                  $(''<div>'')
                    .text(f.Text || f.Name || '''')
                    .appendTo(cellElement);
                  return;
                }
              }

              $(''<div>'').text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },

          {
            dataField: ''CustomerID'',
            caption: ''Khách hàng'',
            width: 150,
            alignment: ''left'',
            minWidth: 80,
           maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              const ds = window[''DataSource_CustomerID''];

              if (ds && Array.isArray(ds)) {
                const f = ds.find((x) => x.id == val || x.ID == val);
                if (f) {
                  $(''<div>'')
                    .text(f.Text || f.Name || '''')
                    .appendTo(cellElement);
                  return;
                }
              }

              $(''<div>'').text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },
            /*{
            dataField: ''Description'',
            caption: ''Diễn giải'',
            width: 200,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text(''--'')
                  .appendTo(cellElement);
                return;
              }
             $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text(`${val}`)
                  .appendTo(cellElement);

              $(''<div>'').text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },*/
          {
            dataField: ''StatusID'',
            caption: ''Tình trạng thực hiện'',
            width: 200,
            alignment: ''left'',
            minWidth: 80,
            maxWidth: 400,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === '''') {
                $(''<div>'')
                  .addClass(''dx-placeholder'')
                  .text('''')
                  .appendTo(cellElement);
                return;
              }
              const ds = window[''DataSource_StatusID''];

              $(''<div>'').text(val).addClass(`text-${cellInfo.data.Color}`).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
                    caption: "",
                    width: 50,
                    alignment: "center",
                    cellTemplate: function (cellElement, cellInfo) {
                        if (String(cellInfo.data.Status) === "2" || String(cellInfo.data.StatusID) === "2") {
                            let $btn = $("<button>").addClass("text-danger").html(''<i class="bi bi-trash"></i>'');
                            $btn.on("click", async function (e) {
                                e.stopPropagation();
                                showConfirmPopup({
                                    title: "%ACComfirm%",
                                    message: "%Common_Confirm_DeleteTitle%",
                                    YesText: "%ConfirmYes%",
                                    NoText: "%cancelBtn%",
                                    onYes: async () => {
                                        const skeletonId = "skeleton-delete-" + Date.now();
                                        const skeletonHTML = `
                                        <div id="${skeletonId}" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(var(--bs-body-bg-rgb), 0.8); z-index: 9999; display: flex; align-items: center; justify-content: center;">
                                            <div style="color: var(--bs-primary); font-size: 24px; font-weight: bold; letter-spacing: 4px;">║  ║  ║</div>
                                        </div>
                                    `;
                                        $("body").append(skeletonHTML);

                                        try {
                                            let res = await AjaxHPAParadiseAsync({
                                                data: { name: "spWH_DeleteInventoryExport", param: ["Action", "Delete", "InventoryCode", cellInfo.data.InventoryCode] }
                                            });

                                            if (res) {
                                                uiManager.showAlert({ type: "success", message: "Xóa thành công!" });
                                                // Xóa row đã xóa trong _pageCache
                                                    if (typeof _pageCache !== "undefined") {

                                                        const deletedCode = cellInfo.data.InventoryCode;
                                                        Object.keys(_pageCache).forEach(key => {
                                                            if (_pageCache[key] && Array.isArray(_pageCache[key].data)) {
                                                                let originalLength = _pageCache[key].data.length;
                                                                _pageCache[key].data = _pageCache[key].data.filter(item => item.InventoryCode !== deletedCode);
                                                                let newLength = _pageCache[key].data.length;
                                                                if (originalLength > newLength) {
                                                                    _pageCache[key].totalCount = Math.max(0, _pageCache[key].totalCount - (originalLength - newLength));
                                                                }
                                                            }
                                                        });
                                                    }
                                                InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.getDataSource().reload();
                                            } else {
                                                uiManager.showAlert({ type: "warning", message: "Xóa thất bại!" });
                                            }
                                        } catch (err) {
                                            uiManager.showAlert({ type: "danger", message: "Lỗi hệ thống!" });
                                        } finally {
                                            $("#" + skeletonId).remove();
                                        }
                                    }
                                })
                            });
                            cellElement.append($btn);
                        }
                    },
                    allowEditing: false,
                },
        ],
        onCellClick(e) {
          if (0 !== 1) return;

          // Nếu có multi select:
          // - Click vào detail column (_detailAction) thì mở detail
          // - Click vào checkbox column thì chỉ select
          // - Click vào columns khác thì không làm gì
          if (0 === 1) {
            if (e.column.dataField === ''_detailAction'') {
              // Click vào detail button - mở detail
              const rowDataObject = e.data;
              const recordID = e.key ?? e.data?.[''InventoryCode''];
              if (!recordID) return;
              window.currentClicked_gridInventoryExport = recordID;
              window.currentRecordID_InventoryCode = recordID;
              openDetailInventoryCode?.(rowDataObject);
            }
            return; // Không xử lý các column khác khi có multi select
}

          const rowDataObject = e.data;

          const recordID = e.key ?? e.data?.[''InventoryCode''];
          if (!recordID) return;
          window.currentClicked_gridInventoryExport = recordID;
          window.currentRecordID_InventoryCode = recordID;
          openDetailInventoryCode?.(rowDataObject);
        },
        onRowPrepared(e) {},
        onOptionChanged(e) {
          // Persist column chooser changes (visibility/order/width)
          if (e.fullName && e.fullName.startsWith(''columns['')) {
            const timers = chooser.saveTimers;
            if (timers[gridName]) {
              clearTimeout(timers[gridName]);
            }
            timers[gridName] = setTimeout(function () {
              chooser.save(
                InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90,
                gridName
              );
            }, 400);
          }
        },
        onToolbarPreparing: function (e) {
            e.toolbarOptions.items.unshift({
              location: "before",
              template: function (data, index, element) {
                const $container = $(`
                  <div class="ms-filter-toolbar"></div>
                `);

                let $employeeDiv;
                if (window.EmployeeID_Login) {
                  $employeeDiv = $(`
                    <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                      <label style="font-size:11px;color:#64748b;white-space:nowrap;margin:0;">Nhân viên:</label>
                      <div id="multilselectedEmployeeInventoryExport" style="width:170px;white-space:nowrap;"></div>
                    </div>
                  `);
                }

                const $fromDiv = $(`
                  <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                    <label style="font-size:12px;color:#adb5bd;white-space:nowrap;margin:0;">Từ:</label>
                    <div class="filter-from-date"></div>
                  </div>
                `);

                let InstanceFromDate = $fromDiv
                  .find(".filter-from-date")
                  .dxDateBox({
                    width: 105,
                    type: "date",
                    disabled: true,
                    displayFormat: "dd/MM/yyyy",
                    value: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
                    onValueChanged: function (e) {
                      fromDateValue = e.value;
                    }
                  })
                  .dxDateBox("instance");

                const $toDiv = $(`
                  <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                    <label style="font-size:12px;color:#adb5bd;white-space:nowrap;margin:0;">Đến:</label>
                    <div class="filter-to-date"></div>
                  </div>
                `);

                let InstanceToDate = $toDiv
                  .find(".filter-to-date")
                  .dxDateBox({
                    width: 105,
                    type: "date",
                    displayFormat: "dd/MM/yyyy",
                    disabled: true,
                    value: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0),
                    onValueChanged: function (e) {
                      toDateValue = e.value;
                    }
                  })
                  .dxDateBox("instance");

                const $actionButtonContainer = $(`
                  <div style="display:inline-flex;gap:5px;align-items:center;flex:0 0 auto;"></div>
                `);

                $filterBtn = $(`<button class="btn btn-add-inventory btn-success" title="Tìm kiếm">
                    <i class="bi bi-funnel"></i> %search%
                </button>`);

                $filterBtn.on("click", function () {
                  InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.getDataSource().reload();
                });

                const $resetBtn = $(`
                  <button class="btn btn-outline-success btn-add-inventory" title="Làm mới">
                    <i class="bi bi-arrow-clockwise"></i> Làm mới
                  </button>
                `);

                $actionButtonContainer.append($filterBtn, $resetBtn);

                const $checkboxRow = $(`
                  <div class="toolbar-checkbox-wrap" style="flex:0 0 auto;"></div>
                `);

                $checkboxRow.append(`
                  <label class="toolbar-checkbox-item">
                    <input type="checkbox" checked class="toolbar-view-all">
                    <span class="toolbar-checkbox-label">Xem tất cả</span>
                  </label>
                `);

                if (window.EmployeeID_Login) {
                  $checkboxRow.append(`
                    <label class="toolbar-checkbox-item">
                      <input type="checkbox" class="toolbar-only-user">
                      <span class="toolbar-checkbox-label">Chỉ xem của tôi</span>
                    </label>
                  `);
                }

                $checkboxRow
                  .find(".toolbar-view-all")
                  .off("change")
                  .on("change", function () {
                    const checked = $(this).is(":checked");
                    isViewAll = checked;
                    InstanceToDate.option("disabled", checked);
                    InstanceFromDate.option("disabled", checked);
                    if (checked) {
                      fromDateValue = null;
                      toDateValue = null;
                    } else {
                      fromDateValue = InstanceFromDate.option("value");
                      toDateValue = InstanceToDate.option("value");
                    }
                    InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.getDataSource().reload();
                    $fromDiv.css("opacity", checked ? "0.4" : "1");
                    $toDiv.css("opacity", checked ? "0.4" : "1");
                  });

                $checkboxRow
                  .find(".toolbar-only-user")
                  .off("change")
                  .on("change", function () {
                    const checked = $(this).is(":checked");
                    if (checked) {
                        InstanceEmployeeIDEmployeeListInventoryExport.option("value", EmployeeID_Login);
                    } else {
                        InstanceEmployeeIDEmployeeListInventoryExport.option("value", null);
                    }
                    InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.getDataSource().reload();
                });

                const $btnAdd = $(`<button class="btn btn-add-inventory btn-success" title="Thêm mới" style="flex:0 0 auto;">
                    <i class="bi bi-plus-lg"></i> %addnew%
                </button>`);
                $btnAdd.off("click").on("click", function () {
                    addInventory();
                });

                const $searchDiv = $(`
                  <div class="filter-search-box">
                    <i class="bi bi-search"></i>
                    <input type="text" placeholder="Tìm kiếm theo nội dung">
                  </div>
                `);
                $searchDiv.find("input").on("input", function () {
                  InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.searchByText($(this).val());
                });

                $resetBtn.off("click").on("click", function () {
                    isViewAll = true;
                    InstanceToDate.option("disabled", isViewAll);
                    InstanceFromDate.option("disabled", isViewAll);
                    $checkboxRow.find(".toolbar-view-all").prop("checked", true);
                    $checkboxRow.find(".toolbar-only-user").prop("checked", false);
                    fromDateValue = null;
                    toDateValue = null;
                    InstanceEmployeeIDEmployeeListInventoryExport.option("value", null);
                    $searchDiv.find("input").val("");
                    InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.searchByText("");
                    InstancegridInventoryExportP466C3CC0680D4A82A0C1F9EADDB38A90.getDataSource().reload();
                });

                const $rightActions = $(`
                  <div class="toolbar-right-actions"></div>
                `);
                $rightActions.append($btnAdd, $searchDiv);

                $container.append(
                  $employeeDiv || $("<div></div>"),
                  $fromDiv,
                  $toDiv,
                  $actionButtonContainer,
                  $checkboxRow,
                  $rightActions
                );

                $(element).parent().prepend($container);
              }
            });
        },
        onRowDblClick: function (e) {
                                let InventoryCode = e?.data?.InventoryCode || "";

                                if (InventoryCode !== "") {
                                    if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                                        OpenFormParamMobile("sp_WH_InventoryExport_Detail", {
                                            InventoryCode: InventoryCode
                                        });
                                    } else {
                                        openFormParam("sp_WH_InventoryExport_Detail", {
                                            InventoryCode: InventoryCode
                                        });
                                    }
                                }
                            },

      })
      .dxDataGrid(''instance'');
      async function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
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
                setTimeout(function() {
                    loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                }, 100);
                return;
            }

 // Đánh dấu đang load để tránh load trùng lặp
            window[loadedKey] = "loading";

            await AjaxHPAParadiseAsync({
                data: {
                   name: dataSourceSP,
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    window[dataSourceKey] = (json.data && json.data[0]) || [];					

					// load trong form bth co combox luon
					

                    window[loadedKey] = true;

                    // Gọi callback nếu có
                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback(window[dataSourceKey]);
                    }

                    // Tự động cập nhật control nếu có method setDataSource hoặc option
                    // Thử nhiều format tên instance để tương thích
                    const instanceVariants = [
                        "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PED6A4AAAA14F4706822A32B2859DDDAD",
                        "Instance" + columnName + "PED6A4AAAA14F4706822A32B2859DDDAD",
                        "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PED6A4AAAA14F4706822A32B2859DDDAD"
                    ];

                    for (let i = 0; i < instanceVariants.length; i++) {
                        const instanceKey = instanceVariants[i];				

                  if (window[instanceKey] || instanceKey) {
                            const instanceObj = window[instanceKey] || instanceKey;

                            // Kiểm tra nếu đây là dxDataGrid
                            if (typeof instanceObj.dxDataGrid === "function" || instanceObj.option && instanceObj.option("dataSource") !== undefined) {
                                try {
                                    // Nếu là Grid, apply dynamic config
                                    const gridConfigFn = window["getGridConfig_" + columnName.charAt(0).toUpperCase() + columnName.slice(1)];
                                    if (typeof gridConfigFn === "function") {
                                        const gridConfig = gridConfigFn(window[dataSourceKey]);
                                        instanceObj.option("remoteOperations", gridConfig.remoteOperations);
                                        instanceObj.option("paging.pageSize", gridConfig.pageSize);
                                        instanceObj.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                                    }

                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                } catch(e) {
                 console.warn("[LoadDataSourceCommon] Grid config error:", e);
                                    // Fallback: just set data source

                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                }
                       } else if (typeof instanceObj.setDataSource === "function") {
                                instanceObj.setDataSource(window[dataSourceKey]);
                                break;
                            } else if (typeof instanceObj.option === "function") {
                                try {
                                    instanceObj.option("dataSource", window[dataSourceKey]);
                    break;
                       } catch(e) {
                           // Continue to next variant
                             }
                            }
                        }
                    }
                },
                error: function(err) {
                   console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                    window[loadedKey] = false;
    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback([]);
  }
                }
            });
     }
         setTimeout(() => {
               var employeeFilterWrapper = document.getElementById("multilselectedEmployeeInventoryExport");
                   if (employeeFilterWrapper && employeeFilterWrapper.children.length === 0) {
                       var originalEmployee = document.getElementById("EmployeeListInventoryExport");
                       if (originalEmployee && originalEmployee.parentElement) {
                           var employeeDiv = originalEmployee.parentElement.querySelector(''div'');
                           if (employeeDiv) {
                               employeeFilterWrapper.appendChild(employeeDiv);
                           }
                       }
                   }

           }, 300);
            async function addInventory()
           {
                await AjaxHPAParadiseAsync({
                    data: {
                        name: "sp_WH_CRUDCommandExport",
                        param: ["LoginID", UserID]
                    },
                    success: function (res) {
                        if (typeof res == "string" && !IsNullOrEmpty(res)) {
                            res = res.includes("{") ? res : EncryptionStringDecryption(res);
                        }
                        let data = JSON.parse(res).data[0]
                        let IventoryCode = data.length > 0 ? data[0].InventoryCode : ""

                        if(IventoryCode != "")
                        {
                            if (["Android", "iOS"].includes(getMobileOperatingSystem()))
                            {
                                OpenFormParamMobile(`sp_WH_InventoryExport_Detail`,{InventoryCode: IventoryCode});
                            }
                            else
                            {
                                openFormParam(`sp_WH_InventoryExport_Detail`,{InventoryCode: IventoryCode });
                            }
                        }
                    }
                });
           }
           ReloadData()
  })();
</script>
'
    select @Html
	--exec sp_GenerateHTMLScript_new 'sp_WH_InventoryExport_html'
GO

-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_WH_InventoryExport]
IF OBJECT_ID('dbo.sp_WH_InventoryExport', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_WH_InventoryExport AS SELECT 1');
GO

ALTER PROCEDURE [dbo].[sp_WH_InventoryExport](
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
    WHERE TableName = 'sp_WH_InventoryExport'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- BƯỚC 3: BIÊN DỊCH VÀO BẢNG CACHE VÀ CẬP NHẬT BẢN GHI
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_WH_InventoryExport_html', 'VN', 'sp_WH_InventoryExport';
    EXEC sp_GenerateHTMLScript_new 'sp_WH_InventoryExport_html', 'EN', 'sp_WH_InventoryExport';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_WH_InventoryExport_html';
END
GO
