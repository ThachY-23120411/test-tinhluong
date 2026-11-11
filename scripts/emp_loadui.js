
    window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
    window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
    let InstanceEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = null;

    function loadGlobalAvatarIfNeededEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(employeeId, storeImgName, paramImg, callbackFn) {
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
   callbacks: callbackFn ? [callbackFn] : []
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
       param: paramArray
      },
      xhrFields: { responseType: "blob" },
      cache: true,
      success: function (blob) {
       const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
       delete window.GlobalEmployeeAvatarLoading[idStr];

       if (blob && blob.size > 0) {
        const url = URL.createObjectURL(blob);
        window.GlobalEmployeeAvatarCache[idStr] = url;

        callbacks.forEach(cb => {
         try { cb(url); } catch (e) { console.error(e); }
        });
       } else {
        //callbacks.forEach(cb => {
       //  try { cb(null); } catch (e) { console.error(e); }
       // });
       }
      },
      error: function () {
       const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
       delete window.GlobalEmployeeAvatarLoading[idStr];

      // callbacks.forEach(cb => {
      //  try { cb(null); } catch (e) { console.error(e); }
      //  });
     }
     });

     return null;
    }

    window["DataSource_EmployeeID"] = window["DataSource_EmployeeID"] || [];
    let spNameDSEEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = "sp_EmployeeListDataMultiSelectSelectBox";
    let EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = [], EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal = [];
    let _autoSaveEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = false;
    let _readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = false;
    let EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6IsSaving = false;
    const MAX_VISIBLE_EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = 3;

    $(document).ready(function() {
     // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
    if (spNameDSEEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 && spNameDSEEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.trim() !== "") {
     loadDataSourceCommon("EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6", spNameDSEEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6, function(data) {
      window["DataSource_EmployeeID"] = data || [];
      if (Array.isArray(data) && data.length > 0) {
       data.forEach(emp => {
        hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV);
       });
      }
      if (typeof renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 === "function") {
       renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
      }
     });
    }
    });

    function getInitialsEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(name) {
     if (!name) return "?";
     const words = name.trim().split(/\s+/);
     if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
     return name.substring(0, 2).toUpperCase();
    }

    function getColorForIdEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(id) {
     const colors = [
      { bg: "#e3f2fd", text: "#1976d2" },
      { bg: "#f3e5f5", text: "#7b1fa2" },
      { bg: "#e8f5e9", text: "#388e3c" },
      { bg: "#fff3e0", text: "#f57c00" },
      { bg: "#fce4ec", text: "#c2185b" }
     ];
     const numId = parseInt(id, 10);
     const index = isNaN(numId) ? 0 : Math.abs(numId) % colors.length;
     return colors[index];
    }

    function renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6() {
     const $displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = $("#EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6_display");
     if (!$displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.length) return;
     $displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.empty();

     const $wrapper = $("<div>").css({
      padding: "0 6px",
      minHeight: "30px",
      display: "flex",
      alignItems: "center",
      cursor: "pointer",
      transition: "border-bottom-color 0.2s",
      width: "100%",
      boxSizing: "border-box"
     })
     .attr("tabIndex", "0")
     .on("keydown", function(e) {
      if (e.key === "Enter" || e.key === " " || e.key === "Spacebar") {
       e.preventDefault();
       if (_readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) return;
       if (!popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) {
        initPopupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
        setTimeout(() => popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.show(), 0);
       } else {
        popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.show();
       }
      }
     })
     .on("focus", function() {
      $wrapper.css({ borderBottom: "2px solid #337ab7", outline: "none" });
     })
     .on("blur", function() {
      $wrapper.css({ borderBottom: "" });
     })
     .hover(
      () => {
       if (!$wrapper.is(":focus")) {
        $wrapper.css({ borderBottom: "1px solid #337ab7" });
       }
      },
     );

     if (EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.length === 0) {
      $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
     } else {
      const displayIds = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.slice(0, MAX_VISIBLE_EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6);
      const $group = $("<div>").css({ display: "flex", alignItems: "center" });

      displayIds.forEach((id, index) => {
       const item = window["DataSource_EmployeeID"].find(e => String(e.ID) === String(id));
       if (!item) return;

       const $chip = $("<div>").css({
        width: "30px",
        height: "30px",
        borderRadius: "50%",
        boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
        marginLeft: index === 0 ? "0" : "-10px",
        zIndex: index + 1,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontWeight: "600", fontSize: window.innerWidth < 768 ? "11px" : "13px",
        position: "relative", overflow: "hidden"
       }).attr("title", item.Name || item.FullName || "");

       const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];

       if (cachedUrl) {
        $chip.append($("<img>")
         .attr("src", cachedUrl)
         .css({ width: "100%", height: "100%", objectFit: "cover" })
        );
       } else if (item.storeImgName) {
        loadGlobalAvatarIfNeededEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(id, item.storeImgName, item.paramImg, function(url) {
         if (url) renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
        });
        const color = getColorForIdEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(id);
        const initials = getInitialsEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.Name || item.FullName);
        $chip.css({ background: color.bg, color: color.text }).text(initials);
       } else {
        const color = getColorForIdEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(id);
        const initials = getInitialsEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.Name || item.FullName);
        $chip.css({ background: color.bg, color: color.text }).text(initials);
       }

       $group.append($chip);
      });

      if (EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.length > MAX_VISIBLE_EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) {
       const remaining = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.length - MAX_VISIBLE_EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6;
       $group.append($("<div>").css({
        width: "30px",
        height: "30px",
        borderRadius: "50%", marginLeft: "-10px",
        zIndex: MAX_VISIBLE_EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 + 1,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontWeight: "700", fontSize: window.innerWidth < 768 ? "10px" : "12px"
       }).text("+" + remaining).attr("title", "Còn " + remaining + " người nữa"));
      }

      $wrapper.append($group);

     }

     $displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.append($wrapper);
     $wrapper.off("click").on("click", () => {
      if (_readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) {
       if (typeof uiManager !== "undefined" && uiManager.showAlert) {
        uiManager.showAlert({ type: "info", message: "This field is read-only." });
       } else {
        alert("This field is read-only.");
       }
       return;
      }
      if (!popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) {
       initPopupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
       setTimeout(() => {
        popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.show();
       }, 0);
      } else {
       popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.show();
      }
     });
    }

    const $containerEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = $("#P18F22C9ACED845F4BDA48BAF1F6C8DD6");
    $containerEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.css({ width: "100%", display: "block" });
    $containerEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.empty();
    const $displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = $("<div>").attr("id", "EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6_display");
    $containerEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.append($displayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6);

    let popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6;
    let popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6Once = false;
    let EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer = null;

    function initPopupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6() {
     if (popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6Once) {
      popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.show();
      return;
     }

     $("#EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6_popup").remove();

     popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6Once = true;
     popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = $("<div>").attr("id", "EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6_popup")
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
           EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = [];
           try {
            EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer.dxDataGrid("instance").deselectAll();
           } catch(e) {}
          }
         }
        },
        {
         widget: "dxButton",
         location: "after",
         toolbar: "bottom",
         options: {
          text: "Hủy",
          onClick: () => {
           EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = [...EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal];
           popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.hide();
          }
         }
      },
        {
         widget: "dxButton",
       location: "after",
         toolbar: "bottom",
         options: {
          text: "Lưu",
          type: "success",
          onClick: async () => {
           if (_autoSaveEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 && typeof saveValueEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 === "function") {
            await saveValueEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
           } else {
            // Local Save (Sync Grid)
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
             try {
              const grid = cellInfo.component;
              const newValue = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.join(",");
              grid.cellValue(cellInfo.rowIndex, "EmployeeID", newValue || null);
              grid.repaint();
             } catch (e) { console.warn(e); }
            }
            EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal = [...EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds];
            renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
           }
           popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.hide();
           
          }
         }
        }
       ],
       contentTemplate: function (contentElement) {
        EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer = $("<div>");
        contentElement.append(EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer);
       },
       onShown: () => {
        const sortedData = window["DataSource_EmployeeID"].sort((a, b) => {
         const aSelected = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.includes(String(a.ID));
         const bSelected = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.includes(String(b.ID));
         return bSelected - aSelected;
        });

        try {
         const existingInstance = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer.dxDataGrid("instance");
         if (existingInstance) {
          existingInstance.dispose();
         }
        } catch (e) {
      // Instance chưa tồn tại hoặc đã bị destroy
        }

        EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6GridContainer
        .empty()
        .dxDataGrid({
         dataSource: sortedData,
         keyExpr: "ID",
         remoteOperations: false,
         columnAutoWidth: true,
         allowColumnResizing: true,
         selection: { mode: "multiple", showCheckBoxesMode: "always" },
         selectedRowKeys: EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds,
         focusStateEnabled: true,
         keyboardNavigation: { enabled: true },
         hoverStateEnabled: true,
         onRowPrepared: function(e) {
          if (e.rowType === "data") {
           e.rowElement.css("cursor", "pointer");
          }
         },
         columns: [
          {
           caption: "Ảnh",
           width: 70,
           alignment: "center",
           cellTemplate: function(container, options) {
            const item = options.data;
            const $cell = $("<div>").css({
             display: "flex",
             justifyContent: "center",
             alignItems: "center",
             height: "100%"
            });

            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];

            if (cachedUrl) {
             $cell.append($("<img>")
              .attr("src", cachedUrl)
              .css({
               width: "30px",
               height: "30px",
               borderRadius: "50%",
               objectFit: "cover",
               border: "2px solid #fff",
               boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
              })
             );
            } else if (item.storeImgName) {
             loadGlobalAvatarIfNeededEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.ID, item.storeImgName, item.paramImg, function(url) {
              if (!url) return;
              $cell.empty().append(
               $("<img>")
                .attr("src", url)
                .css({ width: "30px", height: "30px", borderRadius: "50%",
                 objectFit: "cover", border: "2px solid #fff",
                 boxShadow: "0 2px 4px rgba(0,0,0,0.1)" })
              );
             });

             const initials = getInitialsEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.Name || item.FullName || "?");

             const color = getColorForIdEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.ID);
             $cell.append($("<div>")
              .text(initials)
              .css({
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
               boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
              })
             );
            } else {
             const initials = getInitialsEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.Name || item.FullName || "?");
             const color = getColorForIdEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6(item.ID);
             $cell.append($("<div>")
              .text(initials)
              .css({
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
               boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
              })
             );
            }

            container.append($cell);
           }
          },
          { dataField: "Name", caption: "Họ tên" },
          { dataField: "Email", caption: "Email", hidingPriority: 0 },
          { dataField: "Position", caption: "Chức vụ", hidingPriority: 1 }
         ],
         searchPanel: {
          visible: true,
          placeholder: ""
         },
         onContentReady: function(e) {
          const grid = e.component;
   const searchBox = grid.getView("headerPanel")
                ._$element
                .find(".dx-datagrid-search-panel input");

          if (!searchBox.length) return;

          // Chỉ bind 1 lần, tránh re-bind sau mỗi lần filter re-render
          if (searchBox.data("hpa-search-bound")) return;
          searchBox.data("hpa-search-bound", true);

          if (!$("#custom-search-style-EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6").length) {
           $("<style>")
            .attr("id", "custom-search-style-EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6")
            .text(`
             .dx-datagrid-search-panel input::placeholder {
              color: #999 !important;
              opacity: 1 !important;
             }
             @media (max-width: 767px) {
              .dx-datagrid-container { font-size: 13px !important; }
              .dx-datagrid-search-panel {
               width: 100% !important;
               float: none !important;
               margin: 0 0 8px 0 !important;
              }
              .dx-datagrid-search-panel .dx-texteditor::after {
               display: none !important;
              }
              .dx-popup-title { font-size: 15px !important; }
              .dx-button-text { font-size: 13px !important; }

              /* ++ THÊM VÀO ĐÂY ++ */
              .dx-datagrid-search-panel .dx-texteditor {
               border: 1px solid #ced4da !important;
               border-radius: 6px !important;
               background: #fff !important;
              }
              .dx-datagrid-search-panel .dx-texteditor.dx-state-focused {
               border-color: #337ab7 !important;
               box-shadow: 0 0 0 2px rgba(51,122,183,0.15) !important;
              }
              .dx-datagrid-search-panel .dx-texteditor-input {
               padding: 6px 36px 6px 10px !important;
               font-size: 14px !important;
               min-height: 36px !important;
              }
              .dx-datagrid-search-panel .dx-clear-button-area {
               width: 36px !important;
               min-width: 36px !important;
              }
              .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear {
               font-size: 18px !important;
               line-height: 36px !important;
              }
             }
            `)
            .appendTo("head");
          }

           searchBox.on("mousedown mouseup click", function(e) {
           e.stopPropagation();
          });

          searchBox.off("input keyup change");

          searchBox.on("input", function() {
           const $self = $(this);
           const searchValue = $self.val();

           if (!searchValue) {
            grid.clearFilter();
            // Restore focus sau clearFilter
            setTimeout(() => $self.focus(), 0);
            return;
           }

           const searchNormalized = RemoveToneMarks_Js(searchValue);
           grid.filter(function(item) {
            const fields = ["Name", "Email", "Position"];
            for (let i = 0; i < fields.length; i++) {
             const fieldValue = item[fields[i]];
             if (fieldValue && RemoveToneMarks_Js(String(fieldValue))
                    .indexOf(searchNormalized) !== -1) {
              return true;
             }
            }
            return false;
           });

           // Restore focus sau filter (grid re-render không cướp focus)
           setTimeout(() => $self.focus(), 0);
          });
         },
         paging: {
          enabled: true,
          pageSize: 5,
          pageIndex: 0
         },
     pager: {
          visible: true,
          allowedPageSizes: [5, 10],
          showPageSizeSelector: true,
          showInfo: true,
          showNavigationButtons: true
         },
         onRowClick: function(e) {
          if (e.rowType !== "data") return;
          // Bỏ qua click vào checkbox column (để checkbox tự xử lý)
      if ($(e.event.target).closest(".dx-checkbox").length) return;

          const key = String(e.key);
          const idx = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.indexOf(key);
          if (idx === -1) {
           EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.push(key);
           try { e.component.selectRows(EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds, false); } catch(err) {}
          } else {
           EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.splice(idx, 1);
           try { e.component.deselectRows([key]); } catch(err) {}
          }
         },
         onSelectionChanged: function(e) {
          // Chỉ xử lý khi click vào checkbox trực tiếp (không phải row)
          const addedKeys = (e.currentSelectedRowKeys || []).map(String);
          const removedKeys = (e.currentDeselectedRowKeys || []).map(String);

          addedKeys.forEach(key => {
           if (!EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.includes(key)) {
            EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.push(key);
           }
          });
          removedKeys.forEach(key => {
           const idx = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.indexOf(key);
           if (idx !== -1) EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.splice(idx, 1);
          });
         },
        });
       },
       onHidden: () => {
        // FIXED: KHÔNG dispose grid tại đây
        // Reset position của popup về default
        popupEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6.option("position", { my: "center", at: "center", of: window });

        renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
       }
      }).dxPopup("instance");
    }

    async function saveValueEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6() {
     if (_readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6) {
      if (typeof uiManager !== "undefined" && uiManager.showAlert) {
       uiManager.showAlert({ type: "info", message: "This field is read-only." });
      } else {
       alert("This field is read-only.");
      }
      return;
     }

     const original = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal.slice().sort().join(",");
     const current = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.slice().sort().join(",");
     if (original === current || EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6IsSaving) return;

     EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6IsSaving = true;
     try {
      const newValue = EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.join(",");
      const dataJSON = JSON.stringify(["199939425", ["EmployeeID"], [newValue || null]]);

      let id1 = window.currentRecordID_;
      if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
       id1 = cellInfo.data[""] || id1;
      }
      let idValues = [id1];
      let idFields = [""];

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
       uiManager.showAlert({ type: "error", message: errors[0].Message || "%SaveErrorMessage%" });
             return;
            }

      // Bóp 1 cái còi cục bộ báo là: "Ê tui vừa AutoSave thành công nha!"
      try {
       console.log("[SelectEmployee AutoSave] UID=P18F22C9ACED845F4BDA48BAF1F6C8DD6, ColumnName=EmployeeID, value=", newValue);
       const el = document.getElementById("P18F22C9ACED845F4BDA48BAF1F6C8DD6");
       console.log("[SelectEmployee AutoSave] Element tìm thấy:", !!el);
       if (el) {
el.dispatchEvent(new CustomEvent("onHpaAutoSaveSuccess", {
         bubbles: true,
         detail: { columnName: "EmployeeID", value: newValue }
        }));
        console.log("[SelectEmployee AutoSave] Đã dispatch event onHpaAutoSaveSuccess với columnName=EmployeeID");
       }
      } catch(ex) { console.error("[SelectEmployee AutoSave] Lỗi dispatch:", ex); }

      // SYNC GRID
      if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
       try {
        const grid = cellInfo.component;
        grid.cellValue(cellInfo.rowIndex, "EmployeeID", newValue);
        grid.repaint();
       } catch (syncErr) {
        console.warn("[Grid Sync] SelectEmployee EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6: Không thể sync grid:", syncErr);
       }
      }

      EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal = [...EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds];
      renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
     } catch (err) {
      uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
     } finally {
      EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6IsSaving = false;
     }
    }

    InstanceEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = {
     setValue: function(val) {
      if (typeof val === "string" && val.trim()) {
       EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
      } else if (Array.isArray(val)) {
       EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = val.map(String);
      } else {
       EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds = [];
      }
      EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIdsOriginal = [...EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds];
      renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6();
     },
     getValue: () => EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds,
     getValueAsString: () => EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6SelectedIds.join(","),
     setDataSource: data => {
      window["DataSource_EmployeeID"] = data || [];
     },
     repaint: renderDisplayBoxEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6,
     _readOnly: false,
     _autoSave: false,
     option: function(name, value) {
      if (arguments.length === 2) {
       if (name === "value") this.setValue(value);
       if (name === "readOnly") {
        this._readOnly = value;
        _readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = value;
        const $displayBox = $("#EmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6_display");
        if (value) $displayBox.addClass("disabled-control").css("opacity", "0.6");
        else $displayBox.removeClass("disabled-control").css("opacity", "1");
       }
       if (name === "autoSave") {
        this._autoSave = value;
        _autoSaveEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6 = value;
       }
      } else if (arguments.length === 1) {
       if (name === "value") return this.getValueAsString();
       if (name === "dataSource") return window["DataSource_EmployeeID"];
       if (name === "readOnly") return _readOnlyEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6;
       if (name === "autoSave") return _autoSaveEmployeeIDP18F22C9ACED845F4BDA48BAF1F6C8DD6;
      }
      return undefined;
     },
     _suppressValueChangeAction: function() {},
     _resumeValueChangeAction: function() {}
    };
   