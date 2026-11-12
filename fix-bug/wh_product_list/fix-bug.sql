
ALTER PROCEDURE [dbo].[sp_WH_ProductList_html]
as
    DECLARE @html nvarchar(max) = '', @Empty nvarchar(max) = ''

    select @html = N'
      <style>
  /* =====================================================================
     RESPONSIVE DESIGN SYSTEM: sp_WH_ProductList (Danh mục sản phẩm)
     Tuân thủ Bộ 9 Quy tắc Bất biến về Bố cục & Widget (/responsive-rules)
     - Quy tắc 1 & 8: Khóa biên khung nhìn & Viewport Boundary Lock
     - Quy tắc 6 & 6.4: Toolbar rớt hàng tự do, triệt tiêu bẫy thẻ bọc trung gian
     - Quy tắc 7: Khóa nguyên tử nhãn chữ & nút bấm (Atomic Non-shrink)
     - Sửa lỗi chia 2 cột bộ lọc tồn kho: Đưa về 3 cột đều nhau 100%
     - Sửa lỗi ô tìm kiếm chiếm 100% đẩy văng các nút Action ra ngoài mép
     - Quy tắc 9: Cô lập cuộn bảng DataGrid (Wide-Component Scroll Isolation)
     ===================================================================== */

  /* 1. KHUNG CHỨA TOÀN TRANG: Khóa biên chống vỡ trang */
  #sp_WH_ProductList_html {
    width: 100% !important;
    height: 100% !important;
    min-width: 0 !important;
    max-width: 100% !important;
    overflow-x: hidden !important;
    box-sizing: border-box !important;
  }

  #sp_WH_ProductList_html *,
  #sp_WH_ProductList_html *::before,
  #sp_WH_ProductList_html *::after {
    box-sizing: border-box !important;
  }

  #sp_WH_ProductList_html #gridProductList {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    overflow: hidden !important;
  }

  #sp_WH_ProductList_html #gridProductList .dx-datagrid {
    max-width: 100% !important;
    min-width: 0 !important;
  }

  /* 2. TOOLBAR CONTAINER: Tự do co giãn theo chiều cao thực tế (Quy tắc 6) */
  #sp_WH_ProductList_html #gridProductList .dx-toolbar,
  #sp_WH_ProductList_html #gridProductList .dx-toolbar-items-container {
    height: auto !important;
    min-height: 40px !important;
    overflow: visible !important;
    background: transparent !important;
  }

  #sp_WH_ProductList_html #gridProductList .dx-toolbar-items-container {
    display: flex !important;
    flex-direction: row !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    justify-content: space-between !important;
    gap: 10px !important;
    width: 100% !important;
    max-width: 100% !important;
    padding: 6px 0 !important;
    box-sizing: border-box !important;
  }

  /* 3. ĐỒNG CẤP HÓA CÁC CỤM TOOLBAR (BEFORE & AFTER): position static & bám lề */
  #sp_WH_ProductList_html #gridProductList .dx-toolbar-before,
  #sp_WH_ProductList_html #gridProductList .dx-toolbar-center,
  #sp_WH_ProductList_html #gridProductList .dx-toolbar-after {
    position: static !important;
    display: flex !important;
    align-items: center !important;
    flex-wrap: wrap !important;
    gap: 8px !important;
    height: auto !important;
    max-width: 100% !important;
    min-width: 0 !important;
    overflow: visible !important;
    white-space: normal !important;
    padding: 0 !important;
  }

  #sp_WH_ProductList_html #gridProductList .dx-toolbar-before {
    flex: 0 0 auto !important;
    width: auto !important;
  }

  #sp_WH_ProductList_html #gridProductList .dx-toolbar-after {
    flex: 1 1 auto !important;
    justify-content: flex-end !important;
    margin-left: auto !important;
  }

  #sp_WH_ProductList_html #gridProductList .dx-toolbar-item,
  #sp_WH_ProductList_html #gridProductList .dx-toolbar-item-content {
    max-width: 100% !important;
    min-width: 0 !important;
    overflow: visible !important;
    white-space: normal !important;
  }

  /* 4. SỬA DỨT ĐIỂM LỖI 1: BỘ LỌC TỒN KHO (.stock-filter)
     - Chia 3 cột đều nhau hoặc 1 hàng Segmented Pill hoàn hảo
     - Tuyệt đối loại bỏ chia 2 cột làm nút Hết hàng bị rớt dòng lẻ loi */
  #sp_WH_ProductList_html .stock-filter {
    display: inline-grid !important;
    grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
    align-items: center !important;
    gap: 4px !important;
    width: 100% !important;
    max-width: 360px !important;
    min-width: 260px !important;
    border-radius: 50px !important;
    border: 1px solid rgba(255, 255, 255, 0.15) !important;
    padding: 4px !important;
    background: rgba(255, 255, 255, 0.03) !important;
    box-sizing: border-box !important;
    flex: 0 0 auto !important;
  }

  #sp_WH_ProductList_html .stock-btn {
    border-radius: 40px !important;
    padding: 6px 14px !important;
    font-size: 0.85rem !important;
    border: none !important;
    background: transparent !important;
    cursor: pointer !important;
    transition: background-color 0.2s ease, color 0.2s ease !important;
    white-space: nowrap !important;
    font-weight: 600 !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    text-align: center !important;
    width: 100% !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    box-sizing: border-box !important;
    color: #94a3b8 !important;
  }

  #sp_WH_ProductList_html .stock-btn.active {
    background: #198754 !important;
    color: #ffffff !important;
    box-shadow: 0 2px 6px rgba(25, 135, 84, 0.35) !important;
  }

  /* 5. SỬA DỨT ĐIỂM LỖI 2: CỤM TOOLBAR RIGHT & Ô TÌM KIẾM
     - Cho phép flex-wrap và co giãn chia sẻ không gian với nút bấm
     - Không cho ô tìm kiếm nuốt trọn 100% đẩy văng các nút Action */
  #sp_WH_ProductList_html .toolbar-right {
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    justify-content: flex-end !important;
    gap: 8px !important;
    width: 100% !important;
    max-width: 100% !important;
  }

  /* Khóa cứng kích thước Searchbox 200px: KHÔNG TỰ Ý CO GIÃN LẤP ĐẦY DÒNG */
  #sp_WH_ProductList_html .ctlist-search-wrap {
    position: relative !important;
    display: inline-flex !important;
    align-items: center !important;
    flex: 0 0 200px !important;
    width: 200px !important;
    min-width: 180px !important;
    max-width: 220px !important;
    box-sizing: border-box !important;
    margin: 0 !important;
  }

  #sp_WH_ProductList_html .ctlist-search-icon {
    position: absolute !important;
    top: 50% !important;
    left: 10px !important;
    transform: translateY(-50%) !important;
    color: #94a3b8 !important;
    font-size: 0.85rem !important;
    pointer-events: none !important;
    z-index: 2 !important;
  }

  #sp_WH_ProductList_html .ctlist-search-input {
    height: 32px !important;
    padding: 0 10px 0 32px !important;
    border: 1px solid var(--bs-border-color, #475569) !important;
    border-radius: 6px !important;
    font-size: 0.875rem !important;
    width: 100% !important;
    min-width: 100% !important;
    max-width: 100% !important;
    background: var(--bs-body-bg, #1e293b) !important;
    color: var(--bs-body-color, #f8fafc) !important;
    box-sizing: border-box !important;
    outline: none !important;
    transition: border-color 0.15s !important;
  }

  #sp_WH_ProductList_html .ctlist-search-input:focus {
    border-color: #198754 !important;
  }

  /* 6. KHÓA NGUYÊN TỬ CÁC NÚT HÀNH ĐỘNG (Quy tắc 7: Atomic Non-shrink) */
  #sp_WH_ProductList_html .btn-ctlist-reload {
    height: 32px !important;
    width: 32px !important;
    min-width: 32px !important;
    max-width: 32px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    border: 1px solid var(--bs-border-color, #475569) !important;
    border-radius: 6px !important;
    background: var(--bs-body-bg, #1e293b) !important;
    color: #94a3b8 !important;
    cursor: pointer !important;
    padding: 0 !important;
    flex: 0 0 32px !important;
    flex-shrink: 0 !important;
    box-sizing: border-box !important;
  }

  #sp_WH_ProductList_html .btn-ctlist-reload:hover {
    color: #ffffff !important;
    border-color: #198754 !important;
  }

  /* TRIỆT TIÊU BẪY THẺ BỌC $btnGroup (Quy tắc 6.4 & 6.1):
     Phẳng hóa hoàn toàn để TỪNG BUTTON RỚT HÀNG ĐỘC LẬP khi thiếu chỗ, không rớt cả cụm! */
  #sp_WH_ProductList_html .toolbar-right > .d-flex {
    display: contents !important;
  }

  #sp_WH_ProductList_html .btn-add-productlist {
    white-space: nowrap !important;
    padding: 0 12px !important;
    height: 32px !important;
    font-weight: 500 !important;
    font-size: 0.85rem !important;
    border: none !important;
    border-radius: 6px !important;
    flex: 0 0 auto !important;
    flex-shrink: 0 !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 5px !important;
    box-sizing: border-box !important;
  }

  #sp_WH_ProductList_html .dropdown {
    flex: 0 0 auto !important;
    flex-shrink: 0 !important;
  }

  #sp_WH_ProductList_html .dropdown .toolbar-toggle {
    height: 32px !important;
    width: 32px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    flex-shrink: 0 !important;
    border: 1px solid var(--bs-border-color, #475569) !important;
    border-radius: 6px !important;
    background: var(--bs-body-bg, #1e293b) !important;
    color: #94a3b8 !important;
    padding: 0 !important;
  }

  /* 7. RESPONSIVE MEDIA QUERIES (Windows Snap Layouts 1100px / 768px / 480px) */
  @media (max-width: 1100px) {
    #sp_WH_ProductList_html #gridProductList .dx-toolbar-before {
      width: 100% !important;
      flex: 1 1 100% !important;
    }

    #sp_WH_ProductList_html #gridProductList .dx-toolbar-after {
      width: 100% !important;
      flex: 1 1 100% !important;
      justify-content: flex-start !important;
      margin-left: 0 !important;
    }

    #sp_WH_ProductList_html .toolbar-right {
      justify-content: flex-start !important;
    }

    #sp_WH_ProductList_html .stock-filter {
      max-width: 100% !important;
      width: 100% !important;
    }
  }

  @media (max-width: 768px) {
    /* Searchbox vẫn giữ nguyên kích thước gọn gàng 200px, không chiếm hết dòng */
    #sp_WH_ProductList_html .ctlist-search-wrap {
      flex: 0 0 200px !important;
      width: 200px !important;
      max-width: 200px !important;
    }
  }

  @media (max-width: 480px) {
    #sp_WH_ProductList_html .stock-btn {
      padding: 6px 4px !important;
      font-size: 0.78rem !important;
    }

    #sp_WH_ProductList_html .btn-add-productlist {
      font-size: 0.8rem !important;
      padding: 0 8px !important;
    }

    #sp_WH_ProductList_html .modal-dialog {
      max-width: calc(100vw - 12px) !important;
      margin: 6px auto !important;
    }

    #sp_WH_ProductList_html .modal-body .col-6 {
      flex: 0 0 100% !important;
      max-width: 100% !important;
    }
  }

  /* 8. QUY TẮC 9: CÔ LẬP CUỘN BẢNG DỮ LIỆU LỚN (Wide-Component Scroll Isolation) */
  #sp_WH_ProductList_html #gridProductList .dx-datagrid-headers,
  #sp_WH_ProductList_html #gridProductList .dx-datagrid-rowsview,
  #sp_WH_ProductList_html #gridProductList .dx-datagrid-total-footer {
    overflow-x: auto !important;
    -webkit-overflow-scrolling: touch !important;
    width: 100% !important;
    max-width: 100% !important;
  }
</style>
<div id="sp_WH_ProductList_html">
  <div id="gridProductList"></div>
  <div id="HR_StaffInformation_List_2">
    <div class="modal fade" id="modalAddProduct" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Thông tin</h5>
            <button class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" style="height: fit-content">
            <div class="row">
              <div class="col-6 mb-2">
                <label class="form-label"
                  >Mã sản phẩm <span class="text-danger">(*)</span></label
                >
                <div id="P914E2DFF7C71419AAD600EC0D2FD9FEE"></div>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6 mb-2">
                <label class="form-label"
                  >Tên sản phẩm <span class="text-danger">(*)</span></label
                >
                <div id="PECA1DAA2949E4990A48E870437498233"></div>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6 mb-2">
                <label class="form-label"
                  >Loại sản phẩm <span class="text-danger">(*)</span></label
                >
                <div id="PF4DF84154877400A85E5EFEAB7677123"></div>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6 mb-2">
                <label class="form-label"
                  >Nhà cung cấp <span class="text-danger">(*)</span></label
                >
                <div id="P84157933DC4B44EB86F89E812CA51D6C"></div>
      <div class="invalid-feedback"></div>
              </div>
              <div class="col-12 mb-2">
                <label class="form-label">
                  Giá tiền <span class="text-danger">(*)</span>
                </label>
                <div id="PE6DCBEC1068F4D209A2325579D004887"></div>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6 mb-2">
                <label class="form-label"
                  >Tồn kho <span class="text-danger"></span
                ></label>
                <div id="P14F3D24DB1F4440F8DDB1935FE19215A"></div>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6 mb-2">
                <label class="form-label">%Status%</label>
                <div id="P34FED30C5F294596A5F228581F51FDD9"></div>
              </div>
              <div class="col-12 mb-2">
                <label class="form-label">%Description%</label>
                <textarea
                  height="25px"
                  class="form-control"
                  id="PF061CC3D4269482DAE3CF6BA5806817F"
                ></textarea>
              </div>
              <div class="col-12 mb-2">
                <label class="form-label">Hình ảnh sản phẩm</label>
                <div id="PE62E638E2FBB4772BDE9C9525F2DED9D"></div>
              </div>
              <div class="d-flex justify-content-end mt-4 gap-2">
                <div id="btnSaveProduct"></div>
                <div id="btnAddProduct"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <script>
    (() => {
      let fileUploaderts_btnImportProduct = $("<div>").dxFileUploader({
        visible: false,
        multiple: true,
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
                const functionParam = ["Template_ImportProduct"].find((x) =>
                  file.name.toLowerCase().includes(x.toLowerCase()),
                );
                if (!file.path) {
                  const reader = new FileReader();
                  reader.readAsDataURL(file);
                  reader.onload = async function () {
                    file.path = reader.result.split(",")[1];
                    showLoadingByClassOrID(
                      "#sp_CRM_ContractHistory",
                      "Đang tải",
                    );
                    await AjaxHPAParadiseParadiseAsync({
                      data: {
                        name: "ImportLocationFolder",
                        param: [file.path, file.name, "", "@LoginID", UserID],
                      },
                      success: function (data) {
                        let dataObject = JSON.parse(data);
                        let newData = dataObject.data;

                        let finalMsg = parseErrorMessage(newData);
                        if (finalMsg != "") {
  showPopupNotify("%Result%", finalMsg, "OK", "40vw");
                        } else {
                          uiManager.showAlert({
                            type: "success",
                            message: "%ImportData_Completed%",
                          });
                        }
                        HideLoadingByClassOrID("#sp_CRM_ContractHistory");

                        /*uiManager.showAlert({
                                    type: "success",
                                    message: "%ImportResultSuccess%",
                                });*/
                      },
                    });
   //await DataSettingProc.OnBeforeLoad();
                    //await DataSettingProc.OnLoad();
                    //await DataSettingProc.OnAfterLoad();
                    ReloadData();
                  };
                } else {
                  showLoadingByClassOrID("#sp_CRM_ContractHistory", "Đang tải");
                  await AjaxHPAParadiseParadiseAsync({
                    data: {
                      name: "ImportLocationFolder",
                      param: [file.path, file.name, "", "@LoginID", UserID],
                    },
                    success: function (data) {
                      let newData = dataObject.data;

                      let finalMsg = z(newData);
                      showPopupNotify("%Result%", finalMsg, "OK", "40vw");
                      HideLoadingByClassOrID("#sp_CRM_ContractHistory");

                      /*  uiManager.showAlert({
                            type: "success",
                            message: "%ImportResultSuccess%",
                            }); */
                    },
                  });
                  // await DataSettingProc.OnBeforeLoad();
                  // await DataSettingProc.OnLoad();
                  // await DataSettingProc.OnAfterLoad();
                  ReloadData();
                }
                fileUploaderts_btnImportProduct
                  .dxFileUploader("instance")
                  .reset();
              }
            },
          });
        },
      });
      $("body").append(fileUploaderts_btnImportProduct);

      function CheckEmpty() {
        let ProductTypeID =
          InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
            "value",
          );
        let SupplierID =
          InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option("value");
        let ProductCode =
          InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option("value");
        let ProductName =
          InstanceProductNamePECA1DAA2949E4990A48E870437498233.option("value");
        let Iventory =
          InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option("value");
        let Status =
          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("value");
        let Cost =
          InstanceCostPE6DCBEC1068F4D209A2325579D004887.option("value");

        if (!ProductTypeID || ProductTypeID == "") {
          SetInvalid(
            "#PF4DF84154877400A85E5EFEAB7677123",
            "%CannotBeEmpty%",
            1,
          );
        }
        if (!SupplierID || SupplierID == "") {
          SetInvalid(
            "#P84157933DC4B44EB86F89E812CA51D6C",
            "%CannotBeEmpty%",
            1,
          );
        }
        if (!ProductCode || ProductCode == "") {
          SetInvalid(
            "#P914E2DFF7C71419AAD600EC0D2FD9FEE",
            "%CannotBeEmpty%",
            1,
          );
        }
        if (!ProductName || ProductName == "") {
          SetInvalid(
            "#PECA1DAA2949E4990A48E870437498233",
            "%CannotBeEmpty%",
            1,
          );
        }
        if (!Cost || Cost == "") {
          SetInvalid(
            "#PE6DCBEC1068F4D209A2325579D004887",
            "%CannotBeEmpty%",
            1,
          );
        }
      }
      function CheckValidControl() {
        if (
          CheckValid("#PF4DF84154877400A85E5EFEAB7677123", 1) &&
          CheckValid("#P84157933DC4B44EB86F89E812CA51D6C", 1) &&
          CheckValid("#P914E2DFF7C71419AAD600EC0D2FD9FEE", 1) &&
          CheckValid("#PECA1DAA2949E4990A48E870437498233", 1) &&
          CheckValid("#P14F3D24DB1F4440F8DDB1935FE19215A", 1) &&
          CheckValid("#PF59EA746646E4808A819133A4C03D93A", 1) &&
          CheckValid("#PF061CC3D4269482DAE3CF6BA5806817F", 1) &&
          CheckValid("#PE6DCBEC1068F4D209A2325579D004887", 1)
        ) {
          return true;
        } else {
    return false;
        }
   }

      async function AddProduct(type = 0) {
        let ProductTypeID =
          InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
            "value",
          );
        let SupplierID =
          InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option("value");
        let ProductCode =
          InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option("value");
        let ProductName =
          InstanceProductNamePECA1DAA2949E4990A48E870437498233.option("value");
        let Iventory =
          InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option("value");
        let Status =
          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("value");
        let Description = $("#PF061CC3D4269482DAE3CF6BA5806817F").val();
        let ProductImage = "";
        
        // 1. Đọc đường dẫn từ uploader hoặc window.Path
        if (window.PathPE62E638E2FBB4772BDE9C9525F2DED9D && window.PathPE62E638E2FBB4772BDE9C9525F2DED9D.trim() !== "") {
          ProductImage = window.PathPE62E638E2FBB4772BDE9C9525F2DED9D.trim();
        } else if (window["DataSource_ProductImage"] && window["DataSource_ProductImage"].length > 0) {
          ProductImage = window["DataSource_ProductImage"][0].UrlFile || window["DataSource_ProductImage"][0].Url || window["DataSource_ProductImage"][0].url || "";
        }

        // Chuẩn hóa dấu gạch chéo
        if (ProductImage) {
          ProductImage = ProductImage.replace(/\\/g, "/");
          if (ProductImage.startsWith("/")) ProductImage = ProductImage.substring(1);
        }

        // 2. Nếu là file tạm trong temp/ -> gọi sp_SendFile chuyển chính thức sang Products/
        if (ProductImage && ProductImage.toLowerCase().indexOf("temp/") > -1) {
          try {
            let jsonFiles = JSON.stringify([{ Url: ProductImage }]);
            let resSend = await AjaxHPAParadiseAsync({
              data: {
                name: "sp_SendFile",
                param: ["LoginID", UserID, "IDValue", "Products", "FileURL", jsonFiles]
              }
            });
            let dataSend = typeof resSend === "string" ? JSON.parse(resSend) : resSend;
            if (dataSend && dataSend.data && dataSend.data[0] && dataSend.data[0][0] && dataSend.data[0][0].ListFiles) {
              let movedFiles = JSON.parse(dataSend.data[0][0].ListFiles);
              if (movedFiles && movedFiles.length > 0) {
                let movedUrl = movedFiles[0].Url || movedFiles[0].UrlFile || "";
                if (movedUrl) {
                  // Cắt lấy đường dẫn tương đối bắt đầu từ Products/
                  let idx = movedUrl.replace(/\\/g, "/").toLowerCase().indexOf("products/");
                  if (idx > -1) {
                    ProductImage = movedUrl.substring(idx);
                  } else {
                    ProductImage = movedUrl;
                  }
                }
              }
            }
          } catch (e) {
            console.error("Lỗi chuyển file từ Temp:", e);
          }
        }

        let Cost =
          InstanceCostPE6DCBEC1068F4D209A2325579D004887.option("value");
        let jsonvalue = [
          {
            ProductTypeID: ProductTypeID,
            SupplierID: SupplierID,
            ProductCode: ProductCode,
            ProductName: ProductName,
            Inventory: Iventory,
            Status: Status,
            Description: Description,
            ProductImage: ProductImage,
            Cost: Cost,
          },
        ];
        
        let messageText = type == 0 ? (LanguageID == "EN" ? "Are you sure you want to add this product?" : "B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n th\u00eam s\u1ea3n ph\u1ea9m n\u00e0y?") : (LanguageID == "EN" ? "Are you sure you want to update this product?" : "B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n c\u1eadp nh\u1eadt s\u1ea3n ph\u1ea9m n\u00e0y?");
        let titleText = LanguageID == "EN" ? "Confirmation" : "X\u00e1c nh\u1eadn";
        let yesText = LanguageID == "EN" ? "Confirm" : "X\u00e1c nh\u1eadn";
        let noText = LanguageID == "EN" ? "Cancel" : "H\u1ee7y";

        showConfirmPopup({
          title: titleText,
          message: messageText,
          YesText: yesText,
          NoText: noText,
          onYes: function () {
            AjaxHPAParadise({
              data: {
                name: "sp_WH_AddProduct",
                param: ["LoginID", LoginID, "json", jsonvalue, "type", type],
              },
              success: async function (res) {
                if (type == 0) {
                  let resuft = JSON.parse(res).data[0][0];
                  if (resuft.Cout == 1) {
                    uiManager.showAlert({
                      type: "success",
                      message: LanguageID == "EN" ? "Added successfully!" : "Th\u00ea m th\u00e0nh c\u00f4ng!",
                    });
                    ClearAllControl();
                    $("#modalAddProduct").modal("hide");

                    ReloadData();
                  } else {
                    SetInvalid(
                      "#P914E2DFF7C71419AAD600EC0D2FD9FEE",
                      "Trùng mã",
                      1,
                    );
                  }
                } else {
                  uiManager.showAlert({
                    type: "success",
                    message: "%success%!",
                  });
                  ClearAllControl();
                  $("#modalAddProduct").modal("hide");
                  ReloadData();
                }
              },
            });
          },
        });
      }
      function SaveProduct() {}

      let btnsave = $("#btnSaveProduct")
        .dxButton({
          stylingMode: "contained",
          text: "%Save%",
          type: "success",
          width: 120,
          onClick() {
            CheckEmpty();
            if (!CheckValidControl()) {
              uiManager.showAlert({
                type: "warning",
                message: "%PleaseReivewWarning%!",
              });
              return;

            }
            AddProduct(1);
          },
        })
        .dxButton("instance");
      let btnadd = $("#btnAddProduct")
        .dxButton({
          stylingMode: "contained",
          text: "%AddProductButton%",
          type: "success",
          width: 120,
          onClick() {
            CheckEmpty();
            if (!CheckValidControl()) {
              uiManager.showAlert({
                type: "warning",
                message: "%PleaseReivewWarning%!",
              });
              return;
            }
            AddProduct();
          },
        })
        .dxButton("instance");

      let DataSource = [];

      let InstanceCostPE6DCBEC1068F4D209A2325579D004887 = null;
      let CostTimeOut;
      let _autoSaveCostPE6DCBEC1068F4D209A2325579D004887 = false;
      let _readOnlyCostPE6DCBEC1068F4D209A2325579D004887 = false;
      let $containerCostPE6DCBEC1068F4D209A2325579D004887 = $(
        "#PE6DCBEC1068F4D209A2325579D004887",
      );

      async function NumberBoxSaveLogicCost() {
        let val = InstanceCostPE6DCBEC1068F4D209A2325579D004887.option("value");

        const dataJSON = JSON.stringify(["-280779754", ["Cost"], [val]]);

        // Context-aware record IDs
        let id1 = currentRecordID_ProductID;
        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
          id1 = cellInfo.data["ProductID"] || id1;
        }
        let currentRecordIDValue = [id1];
        let currentRecordID = ["ProductID"];

        if ("" && "".trim() !== "") {
          let id2 = currentRecordID_;
          if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
            id2 = cellInfo.data[""] || id2;
          }
          currentRecordIDValue.push(id2);
          currentRecordID.push("");
        }

        const idValsJSON = JSON.stringify([
          currentRecordIDValue,
          currentRecordID,
        ]);

        try {
          const json = await saveFunction(dataJSON, idValsJSON);
          const dtError = json.data[json.data.length - 1] || [];
          if (dtError.length > 0 && dtError[0].Status === "ERROR") {
            uiManager.showAlert({
              type: "error",
              message: dtError[0]?.Message || "%SaveErrorMessage%",
            });
          } else {
            if (
              0 != 0 &&
              0 != null &&
              0 != "" &&
              window.hpaSharedGridDataSources["0"]
            ) {
              try {
                var updateData = {};
                updateData["ProductID"] = currentRecordIDValue[0];
                updateData["Cost"] =
                  InstanceCostPE6DCBEC1068F4D209A2325579D004887.option("value");

                var id2FieldName = "";
                var hasKey2 =
                  id2FieldName &&
                  id2FieldName !== "" &&
                  id2FieldName.indexOf("%") === -1;

                if (hasKey2) {
                  if (
                    currentRecordIDValue.length > 1 &&
                    currentRecordIDValue[1] !== undefined
                  ) {
                    updateData[id2FieldName] = currentRecordIDValue[1];
                  }
                }

                // Thực hiện update shared grid
                window.updateSharedGridRow("0", updateData);

                // Kiểm tra và cập nhật biến DataSource cục bộ
                if (
                  typeof DataSource !== "undefined" &&
                  Array.isArray(DataSource)
                ) {
                  var ds;
                  if (!hasKey2) {
                    // Trường hợp 1 khóa
                    ds = DataSource.filter(
                      (item) => item["ProductID"] === updateData["ProductID"],
                    );
                  } else {
                    // Trường hợp 2 khóa
                    ds = DataSource.filter(
   (item) =>
                        item["ProductID"] === updateData["ProductID"] &&
                        item[id2FieldName] === updateData[id2FieldName],
                    );
                  }

                  if (ds && ds.length > 0) {
                    ds[0]["Cost"] = updateData["Cost"];
                  }
                }
              } catch (dsErr) {
                console.warn(
                  "[Grid Sync] NumberBox CostPE6DCBEC1068F4D209A2325579D004887: Không thể sync shared grid data source:",
                  dsErr,
                );
              }
            }
          }

  if (
            typeof cellInfo !== "undefined" &&
            cellInfo &&
            cellInfo.component
          ) {
            try {
              const grid = cellInfo.component;
              grid.cellValue(cellInfo.rowIndex, "Cost", val);
              grid.repaint();
            } catch (syncErr) {
              console.warn(
                "[Grid Sync] NumberBox CostPE6DCBEC1068F4D209A2325579D004887: Error",
                syncErr,
              );
            }
          }
        } catch (err) {
          console.error("NumberBox Save Error:", err);
        }
      }

      let CostPE6DCBEC1068F4D209A2325579D004887RealInstance = $(
        "#PE6DCBEC1068F4D209A2325579D004887",
      )
        .dxNumberBox({
          format: "#,##0",
          showSpinButtons: false,
          showClearButton: false,
          width: "100%",
          elementAttr: { class: "hpa-dx-numberbox-inline" },
          readOnly: _readOnlyCostPE6DCBEC1068F4D209A2325579D004887,
          /*onKeyDown: function(e) {
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    if (_autoSaveCostPE6DCBEC1068F4D209A2325579D004887) {
                        NumberBoxSaveLogicCost();
                    }
                }
            },
            onValueChanged: async (e) => {
                if (_autoSaveCostPE6DCBEC1068F4D209A2325579D004887) {
                    clearTimeout(CostTimeOut);
                    e.event && await NumberBoxSaveLogicCost();
                } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "Cost", e.value);
                    }
                }
            },
 onKeyUp: (e) => {
                if (_autoSaveCostPE6DCBEC1068F4D209A2325579D004887) {
                    clearTimeout(CostTimeOut);
                    CostTimeOut = setTimeout(async () => NumberBoxSaveLogicCost(), 1000);
                }
            } */
          onInput: (e) => {
            let value = e.event.target.value;

            if (!value || value == 0) {
              SetInvalid(
                "#PE6DCBEC1068F4D209A2325579D004887",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#PE6DCBEC1068F4D209A2325579D004887", 1);
            }
          },
        })
        .dxNumberBox("instance");

      /* =============== Public API =============== */
      InstanceCostPE6DCBEC1068F4D209A2325579D004887 = {
        option: function (name, value) {
          if (value !== undefined) {
            return CostPE6DCBEC1068F4D209A2325579D004887RealInstance.option(
              name,
              value,
            );
          } else {
            return CostPE6DCBEC1068F4D209A2325579D004887RealInstance.option(
              name,
            );
          }
        },
        repaint: function () {
          CostPE6DCBEC1068F4D209A2325579D004887RealInstance.repaint();
        },
        focus: function () {
          CostPE6DCBEC1068F4D209A2325579D004887RealInstance.focus();
        },
        _suppressValueChangeAction: function () {
          // NumberBox không hỗ trợ method này
        },
        _resumeValueChangeAction: function () {
          // NumberBox không hỗ trợ method này
        },
      };

      window["DataSource_ProductTypeID"] =
        window["DataSource_ProductTypeID"] || [];

      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123DataSourceSP =
        "sp_getProductType";
      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123IsLoading = false;
      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123IsDataLoaded = false;
      let _autoSaveProductTypeIDPF4DF84154877400A85E5EFEAB7677123 = false;
      let _readOnlyProductTypeIDPF4DF84154877400A85E5EFEAB7677123 = false;
let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123TableAddNew = "";
      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123ColumnAddNew = "";
      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch = "";
      let ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue = "";
      let InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 = null;
      const ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchClass =
        "hpa-last-search-PF4DF84154877400A85E5EFEAB7677123";

      function getDataSourceConfigProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
        data,
      ) {
        const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
        return new DevExpress.data.DataSource({
          paginate: false,
          store: new DevExpress.data.CustomStore({
            key: idField,
            load: function (loadOptions) {
              let searchValue =
                ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch ||
                "";

              if (!searchValue && loadOptions && loadOptions.searchValue) {
                searchValue = loadOptions.searchValue;
              }

              if (
                !searchValue &&
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 &&
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option
              ) {
                searchValue =
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                    "searchValue",
                  ) || "";
              }

              let result = data || [];

              if (searchValue && searchValue.trim()) {
                result = result.filter((item) =>
                  customSearchProductTypeID(item, searchValue),
                );

                if (
                  ProductTypeIDPF4DF84154877400A85E5EFEAB7677123TableAddNew &&
                  ProductTypeIDPF4DF84154877400A85E5EFEAB7677123TableAddNew.trim() !==
                    ""
                ) {
                  const nameField =
                    window["DataSourceNameField_ProductTypeID"] || "Name";
                  const addNewItem = { IsAddNew: true };
                  addNewItem[nameField] = searchValue.trim();
                  result.push(addNewItem);
                }
              }

              return Promise.resolve(result);
            },
            byKey: function (key) {
              const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
              return Promise.resolve(
                (data || []).find((i) => i[idField] === key),
              );
            },
          }),
        });
      }

      async function processAddNewProductTypeID(newValue) {
        if (!newValue || !newValue.trim()) return;

        InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
          "disabled",
          true,
        );

        const dataJSON = JSON.stringify([
          ProductTypeIDPF4DF84154877400A85E5EFEAB7677123TableAddNew,
          [ProductTypeIDPF4DF84154877400A85E5EFEAB7677123ColumnAddNew],
          [newValue.trim()],
        ]);

        try {
          console.log("dataJSON", dataJSON);
          const json = await saveFunction(dataJSON);
          const dtError = json.data[json.data.length - 1] || [];

          if (dtError.length > 0 && dtError[0].Status === "ERROR") {
            uiManager.showAlert({
              type: "error",
              message: dtError[0]?.Message || "Lỗi thêm mới",
            });
          } else {
            const newItemID = dtError[0]?.IDValue || null;

            if (newItemID) {
              const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
              const nameField =
                window["DataSourceNameField_ProductTypeID"] || "Name";

              const newItem = {};

              newItem[idField] = newItemID;
              newItem[nameField] = newValue.trim();

              if (!window["DataSource_ProductTypeID"]) {
                window["DataSource_ProductTypeID"] = [];
              }
              window["DataSource_ProductTypeID"].push(newItem);

              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "dataSource",
                getDataSourceConfigProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
                  window["DataSource_ProductTypeID"],
                ),
              );

              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "value",
                newItemID,
              );
              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "searchValue",
                "",
              );
              ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch = "";
            }
          }
        } catch (e) {
          console.error(e);
          uiManager.showAlert({
            type: "error",
            message: "Có lỗi khi thêm mới",
          });
        } finally {
          InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
            "disabled",
            false,
          );
          InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.close();
        }
      }

      function customSearchProductTypeID(item, searchValue) {
        if (!searchValue) return true;
        const searchNormalized = hpaUtils
          .removeToneMarks(searchValue)
          .toLowerCase();
        const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
        const nameField = window["DataSourceNameField_ProductTypeID"] || "Name";
        const fields = [idField, nameField, "Code", "Description"];

        for (let i = 0; i < fields.length; i++) {
          const fieldValue = item[fields[i]];
          if (fieldValue) {
            const fieldNormalized = hpaUtils
              .removeToneMarks(String(fieldValue))
              .toLowerCase();
            if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
          }
        }
        return false;
      }

      function renderLastSearchHintProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
        $popupContent,
      ) {
        if (!$popupContent || !$popupContent.length) return;

        const lastSearch = (
          ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue || ""
        ).trim();
        let $hint = $popupContent.find(
          "." + ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchClass,
        );

        if (!lastSearch) {
          if ($hint.length) {
            $hint.remove();
          }
          return;
        }

        if (!$hint.length) {
          $hint = $("<div>")
            .addClass(
              ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchClass +
                " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom",
            )
            .css({
              fontSize: "12px",
              background: "#f8f9fa",
            })
            .prependTo($popupContent);

          $("<span>")
            .addClass("flex-fill text-muted text-truncate")
            .appendTo($hint);

          $("<button>")
            .attr("type", "button")
            .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
            .text("Áp dụng lại")
            .on("dxclick", function (ev) {
              ev.preventDefault();
              ev.stopPropagation();
              if (
                !ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue
              )
                return;
              ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch =
                ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue;
              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "searchValue",
                ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue,
              );
              const $input = $("#PF4DF84154877400A85E5EFEAB7677123").find(
                ".dx-texteditor-input",
              );
              if ($input && $input.length) {
                setTimeout(function () {
                  $input.focus();
                }, 0);
              }
            })
            .appendTo($hint);
        }

        $hint.find("span").text(''Lần tìm trước: "'' + lastSearch + ''"'');
      }

      InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 = $(
        "#PF4DF84154877400A85E5EFEAB7677123",
      )
        .dxSelectBox({
          readOnly: _readOnlyProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
          dataSource:
            getDataSourceConfigProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
              window["DataSource_ProductTypeID"],
            ),
          valueExpr: window["DataSourceIDField_ProductTypeID"] || "ID",
          displayExpr: window["DataSourceNameField_ProductTypeID"] || "Name",
          onOptionChanged: function (e) {
            if (!e || !e.component) return;
            if (e.name === "searchValue") {
              const newVal = (e.value || "").toString();
              ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch =
                newVal;
              if (newVal && newVal.trim()) {
                ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue =
                  newVal;
              }

              if (e.component.option("opened") && e.component._popup) {
                renderLastSearchHintProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
                  $(e.component._popup.content()),
                );
              }
            }
          },
          onContentReady: function (e) {},
          placeholder: "Tìm kiếm hoặc chọn...",
          searchEnabled: true,
          searchTimeout: 300,
          minSearchLength: 0,
          showDataBeforeSearch: true,
          showClearButton: false,
          stylingMode: "outlined",
          dropDownOptions: {
            showTitle: false,
            closeOnOutsideClick: true,
            height: "auto",
            maxHeight: 400,
            minWidth: 320,
            onShowing: function (e) {
              if (
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 &&
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option
              ) {
                const pendingSearch =
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                    "searchValue",
                  ) || "";
                if (pendingSearch && pendingSearch.trim()) {
                  ProductTypeIDPF4DF84154877400A85E5EFEAB7677123LastSearchValue =
                    pendingSearch;
                }
                ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch =
                  "";
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                  "searchValue",
                  "",
                );
              }
            },
            onHidden: function () {
              ProductTypeIDPF4DF84154877400A85E5EFEAB7677123CurrentSearch = "";
              if (
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 &&
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option
              ) {
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                  "searchValue",
                  "",
                );
              }
            },
          },
          itemTemplate: function (data, index) {
            if (data.IsAddNew) {
              const nameField =
                window["DataSourceNameField_ProductTypeID"] || "Name";
              const $item = $("<div>")
                .addClass(
                  "d-flex align-items-center gap-2 px-3 py-2 text-primary",
                )
                .css({
                  cursor: "pointer",
                  borderTop: "1px dashed #dee2e6",
                  fontWeight: "600",
                });

              $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
              $("<span>")
                .text(''Thêm mới: "'' + data[nameField] + ''"'')
                .appendTo($item);

              $item.on("dxclick", async function (e) {
                e.stopPropagation();
                if (
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 &&
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.blur
                )
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.blur();
                await processAddNewProductTypeID(data[nameField]);
              });

              return $item;
            }

            const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
            const nameField =
              window["DataSourceNameField_ProductTypeID"] || "Name";
            const searchValue =
              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "searchValue",
              ) || "";

            const $item = $("<div>")
              .addClass(
                "d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light",
              )
              .css({ cursor: "pointer" });

            const $content = $("<div>")
              .addClass("flex-fill")
              .css("minWidth", "0");

            const displayName =
              (data[idField] !== undefined ? data[idField] + " - " : "") +
              (data[nameField] || "");
            $("<div>")
              .addClass("fw-normal ")

              .css({
                fontSize: "13px",
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              })
              .html(hpaUtils.highlightText(displayName, searchValue))
              .appendTo($content);

            if (data.Description || data.Code) {
              $("<div>")
                .addClass("text-muted")
                .css({
                  fontSize: "11px",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                })
                .text(data.Code || data.Description)
                .appendTo($content);
            }

            $content.appendTo($item);

            if (data.Status) {
              const badgeClass =
                data.Status === "Active" ? "bg-success" : "bg-secondary";
              $("<span>")
                .addClass("badge " + badgeClass)
                .css({
                  fontSize: "9px",
                  padding: "3px 6px",
                  borderRadius: "4px",
                  opacity: "0.8",
                })
                .text(data.Status)
                .appendTo($item);
            }

            return $item;
          },
          onOpened: function (e) {
            const $popupContent = $(e.component._popup.content());
            $popupContent.parent().addClass("shadow-lg border rounded").css({
              borderRadius: "8px",
              padding: "4px 0",
              borderColor: "#dee2e6",
            });

            renderLastSearchHintProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
              $popupContent,
            );
          },
          onFocusIn: function (e) {
            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
              "showClearButton",
              true,
            );
          },
          onFocusOut: function (e) {
            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
              "showClearButton",
              false,
            );
          },
          onKeyDown: function (e) {
            if (e.key === "Enter" || e.key === "Tab") {
              InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                "showClearButton",
                false,
              );
            }
          },
          onValueChanged: async function (e) {
            if (!e.event) return;
            if (!e.value) {
              SetInvalid(
                "#PF4DF84154877400A85E5EFEAB7677123",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#PF4DF84154877400A85E5EFEAB7677123", 1);
            }

            if (_autoSaveProductTypeIDPF4DF84154877400A85E5EFEAB7677123) {
              if (
                e.value === "" ||
                e.value == null ||
                e.value === 0 ||
                e.value === "0"
              ) {
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                  "value",
                  _initialProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
                );
                return;
              }

              $("#PF4DF84154877400A85E5EFEAB7677123")
                .find(".dx-texteditor-input")
                .blur();
              if (
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123 &&
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.blur
              )
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.blur();

              if (
                typeof window["onSelectBoxChanged_ProductTypeID"] === "function"
              ) {
                window["onSelectBoxChanged_ProductTypeID"](
                  e.value,
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
                  e,
                );
              }

              const val = e.value;
              const dataJSON = JSON.stringify([
                "-280779754",
                ["ProductTypeID"],
                [val || ""],
              ]);

              let id1 = currentRecordID_ProductID;
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.data
              ) {
                id1 = cellInfo.data["ProductID"] || id1;
              }
              let currentRecordIDValue = [id1];
              let currentRecordID = ["ProductID"];

              if ("" && "".trim() !== "") {
                let id2 = currentRecordID_;
                if (
                  typeof cellInfo !== "undefined" &&
                  cellInfo &&
                  cellInfo.data
                ) {
                  id2 = cellInfo.data[""] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("");
              }
              const idValsJSON = JSON.stringify([
                currentRecordIDValue,
                currentRecordID,
              ]);

              try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                  uiManager.showAlert({
                    type: "error",
                    message: dtError[0]?.Message || "Lưu thất bại",
                  });
                  InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                    "value",
                    _initialProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
                  );
                } else {
                  if (
                    gridProductList != 0 &&
                    gridProductList != null &&
                    gridProductList != "" &&
               window.hpaSharedGridDataSources["gridProductList"]
                  ) {
                    try {
                      let KeyRowTable = window.currentClicked_gridProductList;
                      console.log("KeyRowTable:", KeyRowTable);
                      if (KeyRowTable != null && KeyRowTable != undefined) {
                        var updateData = {};
                        updateData["0"] = KeyRowTable;
                        updateData["ProductTypeID"] =
                          InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                            "value",
                          );

                        // 2. Thực hiện update Shared Grid
                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                        window.updateSharedGridRow(
                          "gridProductList",
                          updateData,
                        );

                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                        if (
                          typeof DataSource !== "undefined" &&
                          Array.isArray(DataSource)
                        ) {
                          // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                          var ds = DataSource.filter(
                            (item) => item.RowID === KeyRowTable,
                          );

                          if (ds && ds.length > 0) {
                            ds[0]["ProductTypeID"] =
                              updateData["ProductTypeID"];

                            // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                            // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                          }
                        }
                      }

                      var updateData = {};
                      updateData["ProductID"] = currentRecordIDValue[0];
                      updateData["ProductTypeID"] =
                        InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                          "value",
                        );

                      var id2FieldName = "";
                      var hasKey2 =
                        id2FieldName &&
                        id2FieldName !== "" &&
                        id2FieldName.indexOf("%") === -1;

                      if (hasKey2) {
                        if (
                          currentRecordIDValue.length > 1 &&
                          currentRecordIDValue[1] !== undefined
                        ) {
                          updateData[id2FieldName] = currentRecordIDValue[1];
                        }
                      }

                      window.updateSharedGridRow("gridProductList", updateData);

                      if (
                        typeof DataSource !== "undefined" &&
                        Array.isArray(DataSource)
                      ) {
                        var ds;
                        if (!hasKey2) {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"],
                          );
                        } else {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"] &&
                              item[id2FieldName] === updateData[id2FieldName],
                          );
                        }

                        if (ds && ds.length > 0) {
                          ds[0]["ProductTypeID"] = updateData["ProductTypeID"];
                        }
                      }
                    } catch (dsErr) {
                      console.warn(
                        "[Grid Sync] SelectBox ProductTypeIDPF4DF84154877400A85E5EFEAB7677123: Không thể sync shared grid data source:",
                        dsErr,
                      );
                    }
                  }

                  if (
                    typeof cellInfo !== "undefined" &&
                    cellInfo &&
                    cellInfo.component
                  ) {
                    try {
                      const grid = cellInfo.component;
                      grid.cellValue(cellInfo.rowIndex, "ProductTypeID", val);
                      grid.repaint();
                    } catch (syncErr) {
                      console.warn(
                        "[Grid Sync] SelectBox ProductTypeIDPF4DF84154877400A85E5EFEAB7677123: Không thể sync grid:",
                        syncErr,
                      );
                    }
                  }
                  _initialProductTypeIDPF4DF84154877400A85E5EFEAB7677123 = val;
                }
              } catch (err) {
                uiManager.showAlert({
                  type: "error",
                  message: "Có lỗi xảy ra khi lưu",
                });
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
                  "value",
                  _initialProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
                );
                console.error("SelectBox Save Error:", err);
              }
              return;
            }

            // Manual mode - no save, just callbacks and grid sync
            if (
              typeof window["onSelectBoxChanged_ProductTypeID"] === "function"
            ) {
              window["onSelectBoxChanged_ProductTypeID"](
                e.value,
                InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123,
                e,
              );
            }

            if (
              typeof cellInfo !== "undefined" &&
              cellInfo &&
              cellInfo.component
            ) {
              try {
                const grid = cellInfo.component;
                grid.cellValue(cellInfo.rowIndex, "ProductTypeID", e.value);
                grid.repaint();
              } catch (syncErr) {
                console.warn("[Grid Sync] Không thể sync grid:", syncErr);
              }
            }
          },
        })
        .dxSelectBox("instance");

      let _initialProductTypeIDPF4DF84154877400A85E5EFEAB7677123 =
        InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option("value");

      if (
        ProductTypeIDPF4DF84154877400A85E5EFEAB7677123DataSourceSP &&
        ProductTypeIDPF4DF84154877400A85E5EFEAB7677123DataSourceSP !== ""
      ) {
        loadDataSourceCommon(
          "ProductTypeID",
          ProductTypeIDPF4DF84154877400A85E5EFEAB7677123DataSourceSP,
          function (data) {
            ProductTypeIDPF4DF84154877400A85E5EFEAB7677123IsDataLoaded = true;

            const idField = window["DataSourceIDField_ProductTypeID"] || "ID";
            const nameField =
              window["DataSourceNameField_ProductTypeID"] || "Name";

            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
              "valueExpr",
              idField,
            );
            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
 "displayExpr",
              nameField,
            );

            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
              "dataSource",
              getDataSourceConfigProductTypeIDPF4DF84154877400A85E5EFEAB7677123(
                data,
              ),
            );
            InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.repaint();
          },
        );
      }

      window["DataSource_SupplierID"] = window["DataSource_SupplierID"] || [];

      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CDataSourceSP =
        "sp_getSupplier";
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CIsLoading = false;
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CIsDataLoaded = false;
      let _autoSaveSupplierIDP84157933DC4B44EB86F89E812CA51D6C = false;
      let _readOnlySupplierIDP84157933DC4B44EB86F89E812CA51D6C = false;
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CTableAddNew =
        "tblCRM_ContractType";
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CColumnAddNew =
        "ContractName";
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch = "";
      let SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue = "";
      let InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C = null;
      const SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchClass =
        "hpa-last-search-P84157933DC4B44EB86F89E812CA51D6C";

      function getDataSourceConfigSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
        data,
      ) {
        const idField = window["DataSourceIDField_SupplierID"] || "ID";
        return new DevExpress.data.DataSource({
          paginate: false,
          store: new DevExpress.data.CustomStore({
            key: idField,
            load: function (loadOptions) {
              let searchValue =
                SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch || "";

              if (!searchValue && loadOptions && loadOptions.searchValue) {
                searchValue = loadOptions.searchValue;
              }

              if (
                !searchValue &&
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C &&
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option
              ) {
                searchValue =
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                    "searchValue",
                  ) || "";
              }

              let result = data || [];

              if (searchValue && searchValue.trim()) {
                result = result.filter((item) =>
                  customSearchSupplierID(item, searchValue),
                );

                if (
                  SupplierIDP84157933DC4B44EB86F89E812CA51D6CTableAddNew &&
                  SupplierIDP84157933DC4B44EB86F89E812CA51D6CTableAddNew.trim() !==
                    ""
                ) {
                  const nameField =
                    window["DataSourceNameField_SupplierID"] || "Name";
                  const addNewItem = { IsAddNew: true };
                  addNewItem[nameField] = searchValue.trim();
                  result.push(addNewItem);
                }
              }

              return Promise.resolve(result);
            },
            byKey: function (key) {
              const idField = window["DataSourceIDField_SupplierID"] || "ID";
              return Promise.resolve(
                (data || []).find((i) => i[idField] === key),
              );
            },
          }),
        });
      }

      async function processAddNewSupplierID(newValue) {
        if (!newValue || !newValue.trim()) return;

        InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
          "disabled",
          true,
        );

        const dataJSON = JSON.stringify([
          SupplierIDP84157933DC4B44EB86F89E812CA51D6CTableAddNew,
          [SupplierIDP84157933DC4B44EB86F89E812CA51D6CColumnAddNew],
          [newValue.trim()],
        ]);

        try {
          console.log("dataJSON", dataJSON);
          const json = await saveFunction(dataJSON);
          const dtError = json.data[json.data.length - 1] || [];

          if (dtError.length > 0 && dtError[0].Status === "ERROR") {
            uiManager.showAlert({
              type: "error",
              message: dtError[0]?.Message || "Lỗi thêm mới",
            });
          } else {
            const newItemID = dtError[0]?.IDValue || null;

            if (newItemID) {
              const idField = window["DataSourceIDField_SupplierID"] || "ID";
              const nameField =
                window["DataSourceNameField_SupplierID"] || "Name";

              const newItem = {};
              newItem[idField] = newItemID;
              newItem[nameField] = newValue.trim();

              if (!window["DataSource_SupplierID"]) {
                window["DataSource_SupplierID"] = [];
              }
              window["DataSource_SupplierID"].push(newItem);

              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "dataSource",
                getDataSourceConfigSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
                  window["DataSource_SupplierID"],
                ),
              );

              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "value",
                newItemID,
              );
              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "searchValue",
                "",
              );
              SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch = "";
            }
          }
        } catch (e) {
          console.error(e);
          uiManager.showAlert({
            type: "error",
            message: "Có lỗi khi thêm mới",
          });
        } finally {
          InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
            "disabled",
            false,
          );
          InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.close();
        }
      }

      function customSearchSupplierID(item, searchValue) {
        if (!searchValue) return true;
        const searchNormalized = hpaUtils
          .removeToneMarks(searchValue)
          .toLowerCase();
        const idField = window["DataSourceIDField_SupplierID"] || "ID";
        const nameField = window["DataSourceNameField_SupplierID"] || "Name";
        const fields = [idField, nameField, "Code", "Description"];

        for (let i = 0; i < fields.length; i++) {
          const fieldValue = item[fields[i]];
          if (fieldValue) {
            const fieldNormalized = hpaUtils
              .removeToneMarks(String(fieldValue))
              .toLowerCase();
            if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
          }
        }
        return false;
      }

      function renderLastSearchHintSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
        $popupContent,
      ) {
        if (!$popupContent || !$popupContent.length) return;

        const lastSearch = (
          SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue || ""
        ).trim();
        let $hint = $popupContent.find(
          "." + SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchClass,
        );

        if (!lastSearch) {
          if ($hint.length) {
            $hint.remove();
          }
          return;
        }

        if (!$hint.length) {
          $hint = $("<div>")
            .addClass(
              SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchClass +
                " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom",
            )
            .css({
              fontSize: "12px",
              background: "#f8f9fa",
            })
   .prependTo($popupContent);

          $("<span>")
            .addClass("flex-fill text-muted text-truncate")
            .appendTo($hint);

          $("<button>")
            .attr("type", "button")
            .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
            .text("Áp dụng lại")
            .on("dxclick", function (ev) {
              ev.preventDefault();
              ev.stopPropagation();
              if (!SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue)
                return;
              SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch =
           SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue;
              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "searchValue",
                SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue,
              );
              const $input = $("#P84157933DC4B44EB86F89E812CA51D6C").find(
                ".dx-texteditor-input",
              );
              if ($input && $input.length) {
                setTimeout(function () {
                  $input.focus();
                }, 0);
              }
            })
            .appendTo($hint);
        }

        $hint.find("span").text(''Lần tìm trước: "'' + lastSearch + ''"'');
      }

      InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C = $(
        "#P84157933DC4B44EB86F89E812CA51D6C",
      )
        .dxSelectBox({
          readOnly: _readOnlySupplierIDP84157933DC4B44EB86F89E812CA51D6C,
          dataSource:
            getDataSourceConfigSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
              window["DataSource_SupplierID"],
            ),
          valueExpr: window["DataSourceIDField_SupplierID"] || "ID",
          displayExpr: window["DataSourceNameField_SupplierID"] || "Name",
          onOptionChanged: function (e) {
            if (!e || !e.component) return;
            if (e.name === "searchValue") {
              const newVal = (e.value || "").toString();
              SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch = newVal;
              if (newVal && newVal.trim()) {
                SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue =
                  newVal;
              }

              if (e.component.option("opened") && e.component._popup) {
                renderLastSearchHintSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
                  $(e.component._popup.content()),
                );
              }
            }
          },
          onContentReady: function (e) {},
          placeholder: "Tìm kiếm hoặc chọn...",
          searchEnabled: true,
          searchTimeout: 300,
          minSearchLength: 0,
          showDataBeforeSearch: true,
          showClearButton: false,
          stylingMode: "outlined",
          dropDownOptions: {
            showTitle: false,
            closeOnOutsideClick: true,
            height: "auto",
            maxHeight: 400,
            minWidth: 320,
            onShowing: function (e) {
              if (
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C &&
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option
              ) {
                const pendingSearch =
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                    "searchValue",
                  ) || "";
                if (pendingSearch && pendingSearch.trim()) {
                  SupplierIDP84157933DC4B44EB86F89E812CA51D6CLastSearchValue =
                    pendingSearch;
                }
                SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch = "";
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                  "searchValue",
                  "",
                );
              }
            },
            onHidden: function () {
              SupplierIDP84157933DC4B44EB86F89E812CA51D6CCurrentSearch = "";
              if (
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C &&
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option
              ) {
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                  "searchValue",
                  "",
                );
              }
            },
          },
          itemTemplate: function (data, index) {
            if (data.IsAddNew) {
              const nameField =
                window["DataSourceNameField_SupplierID"] || "Name";
              const $item = $("<div>")
                .addClass(
                  "d-flex align-items-center gap-2 px-3 py-2 text-primary",
                )
                .css({
                  cursor: "pointer",
                  borderTop: "1px dashed #dee2e6",
                  fontWeight: "600",
                });

              $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
              $("<span>")
                .text(''Thêm mới: "'' + data[nameField] + ''"'')
                .appendTo($item);

              $item.on("dxclick", async function (e) {
                e.stopPropagation();
                if (
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C &&
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.blur
                )
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.blur();
                await processAddNewSupplierID(data[nameField]);
              });

              return $item;
            }

            const idField = window["DataSourceIDField_SupplierID"] || "ID";
            const nameField =
              window["DataSourceNameField_SupplierID"] || "Name";
            const searchValue =
              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "searchValue",
              ) || "";

            const $item = $("<div>")
              .addClass(
                "d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light",
              )
              .css({ cursor: "pointer" });

            const $content = $("<div>")
              .addClass("flex-fill")
              .css("minWidth", "0");

            const displayName =
              (data[idField] !== undefined ? data[idField] + " - " : "") +
              (data[nameField] || "");
            $("<div>")
              .addClass("fw-normal ")
              .css({
                fontSize: "13px",
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              })
              .html(hpaUtils.highlightText(displayName, searchValue))
              .appendTo($content);

            if (data.Description || data.Code) {
              $("<div>")
                .addClass("text-muted")
                .css({
                  fontSize: "11px",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                })
                .text(data.Code || data.Description)
                .appendTo($content);
            }

            $content.appendTo($item);

            if (data.Status) {
              const badgeClass =
                data.Status === "Active" ? "bg-success" : "bg-secondary";
              $("<span>")
                .addClass("badge " + badgeClass)
                .css({
                  fontSize: "9px",
                  padding: "3px 6px",
                  borderRadius: "4px",
                  opacity: "0.8",
                })
                .text(data.Status)
                .appendTo($item);
            }

            return $item;
          },
          onOpened: function (e) {
            const $popupContent = $(e.component._popup.content());
            $popupContent.parent().addClass("shadow-lg border rounded").css({
              borderRadius: "8px",
              padding: "4px 0",
              borderColor: "#dee2e6",
            });

            renderLastSearchHintSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
              $popupContent,
            );
          },
          onFocusIn: function (e) {
            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
              "showClearButton",
              true,
            );
          },
          onFocusOut: function (e) {
            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
              "showClearButton",
          false,
            );
          },
          onKeyDown: function (e) {
            if (e.key === "Enter" || e.key === "Tab") {
              InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                "showClearButton",
                false,
              );
            }
          },
          onValueChanged: async function (e) {
            if (!e.event) return;
            if (!e.value) {
              SetInvalid(
                "#P84157933DC4B44EB86F89E812CA51D6C",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#P84157933DC4B44EB86F89E812CA51D6C", 1);
            }
            if (_autoSaveSupplierIDP84157933DC4B44EB86F89E812CA51D6C) {
              if (
                e.value === "" ||
                e.value == null ||
                e.value === 0 ||
                e.value === "0"
              ) {
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                  "value",
                  _initialSupplierIDP84157933DC4B44EB86F89E812CA51D6C,
                );
                return;
              }

              $("#P84157933DC4B44EB86F89E812CA51D6C")
                .find(".dx-texteditor-input")
                .blur();
              if (
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C &&
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.blur
              )
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.blur();

              if (
                typeof window["onSelectBoxChanged_SupplierID"] === "function"
              ) {
                window["onSelectBoxChanged_SupplierID"](
                  e.value,
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C,
                  e,
                );
              }

              const val = e.value;
              const dataJSON = JSON.stringify([
                "-280779754",
                ["SupplierID"],
                [val || ""],
              ]);

              let id1 = currentRecordID_ProductID;
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.data
              ) {
                id1 = cellInfo.data["ProductID"] || id1;
              }
              let currentRecordIDValue = [id1];

              let currentRecordID = ["ProductID"];

              if ("" && "".trim() !== "") {
                let id2 = currentRecordID_;
                if (
                  typeof cellInfo !== "undefined" &&
                  cellInfo &&
                  cellInfo.data
                ) {
                  id2 = cellInfo.data[""] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("");
              }
              const idValsJSON = JSON.stringify([
                currentRecordIDValue,
                currentRecordID,
              ]);

              try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                  uiManager.showAlert({
                    type: "error",
                    message: dtError[0]?.Message || "Lưu thất bại",
                  });
                  InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                    "value",
                    _initialSupplierIDP84157933DC4B44EB86F89E812CA51D6C,
                  );
                } else {
                  if (
                    gridProductList != 0 &&
                    gridProductList != null &&
                    gridProductList != "" &&
                    window.hpaSharedGridDataSources["gridProductList"]
              ) {
                    try {
               let KeyRowTable = window.currentClicked_gridProductList;
                      console.log("KeyRowTable:", KeyRowTable);
                      if (KeyRowTable != null && KeyRowTable != undefined) {
                        var updateData = {};
                        updateData["0"] = KeyRowTable;
                        updateData["SupplierID"] =
                          InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                            "value",
                          );

                        // 2. Thực hiện update Shared Grid
                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                        window.updateSharedGridRow(
                          "gridProductList",
                          updateData,
                        );

                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                        if (
                          typeof DataSource !== "undefined" &&
                          Array.isArray(DataSource)
                        ) {
                          // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                          var ds = DataSource.filter(
                            (item) => item.RowID === KeyRowTable,
                          );

                          if (ds && ds.length > 0) {
                            ds[0]["SupplierID"] = updateData["SupplierID"];

                            // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                            // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                          }
                        }
                      }

                      var updateData = {};
                      updateData["ProductID"] = currentRecordIDValue[0];
                      updateData["SupplierID"] =
                        InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                          "value",
                        );

                      var id2FieldName = "";
                      var hasKey2 =
                        id2FieldName &&
                        id2FieldName !== "" &&
                        id2FieldName.indexOf("%") === -1;

                      if (hasKey2) {
                        if (
                          currentRecordIDValue.length > 1 &&
                          currentRecordIDValue[1] !== undefined
                        ) {
                          updateData[id2FieldName] = currentRecordIDValue[1];
                        }
                      }

                      window.updateSharedGridRow("gridProductList", updateData);

                      if (
                        typeof DataSource !== "undefined" &&
                        Array.isArray(DataSource)
                      ) {
                        var ds;
                        if (!hasKey2) {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"],
                          );
                        } else {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"] &&
                              item[id2FieldName] === updateData[id2FieldName],
                          );
                        }

                        if (ds && ds.length > 0) {
                          ds[0]["SupplierID"] = updateData["SupplierID"];
                        }
                      }
                    } catch (dsErr) {
                      console.warn(
                        "[Grid Sync] SelectBox SupplierIDP84157933DC4B44EB86F89E812CA51D6C: Không thể sync shared grid data source:",
                        dsErr,
            );
                    }
                  }

                 if (
                    typeof cellInfo !== "undefined" &&
                    cellInfo &&
                    cellInfo.component
                  ) {
                    try {
                      const grid = cellInfo.component;
                      grid.cellValue(cellInfo.rowIndex, "SupplierID", val);
                      grid.repaint();
                    } catch (syncErr) {
                      console.warn(
                        "[Grid Sync] SelectBox SupplierIDP84157933DC4B44EB86F89E812CA51D6C: Không thể sync grid:",
                        syncErr,
                      );
                    }
                  }
                  _initialSupplierIDP84157933DC4B44EB86F89E812CA51D6C = val;
                }
              } catch (err) {
                uiManager.showAlert({
                  type: "error",
                  message: "Có lỗi xảy ra khi lưu",
                });
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
                  "value",
                  _initialSupplierIDP84157933DC4B44EB86F89E812CA51D6C,
                );
                console.error("SelectBox Save Error:", err);
              }
              return;
            }

            // Manual mode - no save, just callbacks and grid sync
            if (typeof window["onSelectBoxChanged_SupplierID"] === "function") {
              window["onSelectBoxChanged_SupplierID"](
                e.value,
                InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C,
                e,
              );
            }

            if (
              typeof cellInfo !== "undefined" &&
              cellInfo &&
              cellInfo.component
            ) {
              try {
                const grid = cellInfo.component;
                grid.cellValue(cellInfo.rowIndex, "SupplierID", e.value);
                grid.repaint();
              } catch (syncErr) {
                console.warn("[Grid Sync] Không thể sync grid:", syncErr);
              }
            }
          },
        })
        .dxSelectBox("instance");

      let _initialSupplierIDP84157933DC4B44EB86F89E812CA51D6C =
        InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option("value");

      if (
        SupplierIDP84157933DC4B44EB86F89E812CA51D6CDataSourceSP &&
        SupplierIDP84157933DC4B44EB86F89E812CA51D6CDataSourceSP !== ""
      ) {
        loadDataSourceCommon(
          "SupplierID",
          SupplierIDP84157933DC4B44EB86F89E812CA51D6CDataSourceSP,
          function (data) {
            SupplierIDP84157933DC4B44EB86F89E812CA51D6CIsDataLoaded = true;

            const idField = window["DataSourceIDField_SupplierID"] || "ID";
            const nameField =
              window["DataSourceNameField_SupplierID"] || "Name";

            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
              "valueExpr",
              idField,
            );
            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
              "displayExpr",
              nameField,
            );

            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
              "dataSource",
              getDataSourceConfigSupplierIDP84157933DC4B44EB86F89E812CA51D6C(
        data,
              ),
            );
            InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.repaint();
          },
        );
      }

      if (!window.__hpaTextBoxUnderlineStyleInjected) {
        $("<style>")
          .attr("id", "hpa-textbox-underline-style")
          .text(
            `
                            .dx-texteditor.dx-editor-underlined::after {
    border-bottom-color: #ddd !important;
                            }
                        `,
          )
          .appendTo("head");
        window.__hpaTextBoxUnderlineStyleInjected = true;
      }

      let InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = null;
      let $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = $(
        "#P914E2DFF7C71419AAD600EC0D2FD9FEE",
      );

      let _autoSaveProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
      let _readOnlyProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;

      let ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue = "";
      let _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
      let ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance = null;

      /* =============== Helper Functions =============== */

      function isValidCustomFunction(func) {
        return (
          func &&
          func !== "" &&
          func !== null &&
          func !== undefined &&
          typeof func === "function"
        );
      }

      function showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE(
        message,
      ) {
        // Tô background đỏ nhạt và đổi màu underline
        $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE
          .find("input")
          .css({
            "background-color": "#ffe6e6",
          });
        // Bắn UI Alert
        if (
          message &&
          message != "" &&
          typeof uiManager !== "undefined" &&
          uiManager.showAlert
        ) {
          uiManager.showAlert({ type: "error", message: message });
        }
      }

      function hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE() {
        $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE
          .find("input")
          .css({
            "background-color": "",
          });
      }

      async function saveValueProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE() {
        if (_savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE) return;

        const newVal =
          ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
            "value",
          );

        if (
          newVal === ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue
        ) {
          _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
          return;
        }

        try {
          _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = true;

          if (0 === 1) {
            if (!newVal || newVal.trim() === "") {
              const errorMsg =
                window.ValidationEngine &&
                window.ValidationEngine.getRequiredMessage
                  ? window.ValidationEngine.getRequiredMessage()
                  : "Trường này là bắt buộc";

              showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE(
                errorMsg,
              );
              _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;

              setTimeout(() => {
                $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE
                  .find("input")
                  .focus();
              }, 50);

              return;
            }
          }

          // Custom validation check
          if (isValidCustomFunction(0)) {
            try {
              const validationResult = await 0(newVal);
              if (!validationResult) {
                showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
                _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
                return;
              }
            } catch (validationError) {
              const errorMsg =
                typeof validationError === "string"
                  ? validationError
                  : "Validation failed";
              showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
              _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
              return;
            }
          }

          console.log(_autoSaveProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE);
          hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
          if (_autoSaveProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE) {
            const dataJSON = JSON.stringify([
              "-280779754",
              ["ProductCode"],
              [newVal],
            ]);

            let id1 = currentRecordID_ProductID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
              id1 = cellInfo.data["ProductID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ProductID"];

            if ("" && "".trim() !== "") {
              let id2 = currentRecordID_;
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.data
              ) {
                id2 = cellInfo.data[""] || id2;
              }
              currentRecordIDValue.push(id2);
              currentRecordID.push("");
            }

            const idValsJSON = JSON.stringify([
              currentRecordIDValue,
              currentRecordID,
            ]);

            const json = await saveFunction(dataJSON, idValsJSON);

            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
              uiManager.showAlert({
                type: "error",
                message: dtError[0]?.Message || "%SaveErrorMessage%",
              });
              _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
              return;
            }

            {
              try {
                let KeyRowTable = window.currentClicked_;
                console.log("KeyRowTable:", KeyRowTable);
                if (KeyRowTable != null && KeyRowTable != undefined) {
                  var updateData = {};
                  updateData["0"] = KeyRowTable;
                  updateData["ProductCode"] =
                    InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
                      "value",
                    );

                  // 2. Thực hiện update Shared Grid
                  // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                  window.updateSharedGridRow("", updateData);

                  // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                  if (
                    typeof DataSource !== "undefined" &&
                    Array.isArray(DataSource)
                  ) {
                    // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                    var ds = DataSource.filter(
                      (item) => item.RowID === KeyRowTable,
                    );

                    if (ds && ds.length > 0) {
                      ds[0]["ProductCode"] = updateData["ProductCode"];

                      // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                      // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                    }
                  }
                }

                var updateData = {};
                updateData["ProductID"] = currentRecordIDValue[0];
                updateData["ProductCode"] =
                  InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
     "value",
                  );

                var id2FieldName = "";
                var hasKey2 =
                  id2FieldName &&
                  id2FieldName !== "" &&
                  id2FieldName.indexOf("%") === -1;

                if (hasKey2) {
                  if (
                    currentRecordIDValue.length > 1 &&
                    currentRecordIDValue[1] !== undefined
                  ) {
                    updateData[id2FieldName] = currentRecordIDValue[1];
                  }
                }

                // Thực hiện update shared grid
                window.updateSharedGridRow("", updateData);

                // Kiểm tra và cập nhật biến DataSource cục bộ
                if (
                  typeof DataSource !== "undefined" &&
                  Array.isArray(DataSource)
                ) {
                  var ds;
                  if (!hasKey2) {
                    // Trường hợp 1 khóa
                    ds = DataSource.filter(
                      (item) => item["ProductID"] === updateData["ProductID"],
                    );
                  } else {
                    // Trường hợp 2 khóa
                    ds = DataSource.filter(
                      (item) =>
                        item["ProductID"] === updateData["ProductID"] &&
                        item[id2FieldName] === updateData[id2FieldName],
                    );
                  }

                  if (ds && ds.length > 0) {
                    ds[0]["ProductCode"] = updateData["ProductCode"];
                  }
                }
              } catch (dsErr) {
                console.warn(
                  "[Grid Sync] TextBox ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE: Không thể sync shared grid data source:",
                  dsErr,
                );
              }
            }
          }

          ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue = newVal;

          if (
            typeof cellInfo !== "undefined" &&
            cellInfo &&
            cellInfo.component
          ) {
            try {
              const grid = cellInfo.component;
              grid.cellValue(cellInfo.rowIndex, "ProductCode", newVal);
              grid.repaint();
            } catch (syncErr) {
              console.warn("[Grid Sync] Không thể sync grid:", syncErr);
            }
          }
        } catch (err) {
          console.warn(
            "[ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE] Có lỗi:",
            err,
          );
        } finally {
          setTimeout(function () {
            _savingProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = false;
          }, 100);
        }
      }

      /* =============== Create UI =============== */

      ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance = $("<div>")
        .appendTo($containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE)
        .dxTextBox({
          value: "",
          width: "100%",
          placeholder: "",
          readOnly: _readOnlyProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE,
          stylingMode: "underlined",
          inputAttr: {
            style:
              "font-size: inherit; font-weight: inherit; border-bottom-color: #ddd;",
          },
          onValueChanged: function (e) {
            if (e.value && e.value.trim() !== "") {
              hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
            }
          },
          onFocusOut: function (e) {
            if (_readOnlyProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE) return;

            const $input =
              $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.find(
                "input",
              );
            const currentValue = $input.val();

            // Validate required
            if (0 === 1) {
              if (!currentValue || currentValue.trim() === "") {
                const errorMsg =
                  window.ValidationEngine &&
                  window.ValidationEngine.getRequiredMessage
                    ? window.ValidationEngine.getRequiredMessage(
                        "%DisplayName%",
                      )
                    : "%DisplayName% là bắt buộc";

                showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE(
                  errorMsg,
                );
                return;
              }
            }

            hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
            // 👉 chỉ save khi value thay đổi
            if (
currentValue !==
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue
            ) {
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
                "value",
                currentValue,
              );
              saveValueProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue =
                currentValue;
            }
          },
          onKeyDown: function (e) {
            if (e.event.key === "Enter") {
              e.event.preventDefault();

              const currentValue =
                $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE
                  .find("input")
                  .val();

              if (0 === 1) {
                if (!currentValue || currentValue.trim() === "") {
                  const errorMsg =
                    window.ValidationEngine &&
                    window.ValidationEngine.getRequiredMessage
                      ? window.ValidationEngine.getRequiredMessage(
                          "%DisplayName%",
                        )
                      : "%DisplayName% là bắt buộc";

                  showValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE(
                    errorMsg,
                  );
                  return;
                }
              }

              hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
                "value",
                currentValue,
              );
              saveValueProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
            }

            if (e.event.key === "Tab") {
              e.event.preventDefault();
              const $input =
                $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.find(
                  "input",
                );
              const currentValue = $input.val();
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
                "value",
                currentValue,
              );
              saveValueProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
            }

            if (e.event.key === "Escape") {
              e.event.preventDefault();
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
                "value",
                ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue,
              );
              hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
              $containerProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE
                .find("input")
                .blur();
            }
          },
          onInput: function (e) {
            let value = e.event.target.value;

            if (!value) {
              SetInvalid(
                "#P914E2DFF7C71419AAD600EC0D2FD9FEE",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#P914E2DFF7C71419AAD600EC0D2FD9FEE", 1);
            }
          },
        })
        .dxTextBox("instance");

      /* =============== Public API =============== */
      InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE = {
        setValue: function (val) {
          const displayVal = val == null || val === "" ? "" : String(val);
          ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue =
            displayVal;
          ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
            "value",
            displayVal,
          );
        },
        getValue: function () {
          return ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
            "value",
          );
        },
        option: function (name, value) {
          if (value !== undefined) {
            ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
              name,
              value,
            );

            if (name === "value") {
              const val = value || "";
              ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEEOriginalValue = val;

              if (
                this.__cellInfo &&
                typeof this.__cellInfo.setValue === "function" &&
                this.__cellInfo.component
              ) {
                try {
                  this.__cellInfo.setValue(val);
                } catch (e) {
                  console.warn("[hpaControlText] Grid sync skipped", e);
                }
              }
            }
          } else {
            return ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.option(
              name,
            );
          }
        },
        repaint: function () {
          ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance.repaint();
        },
        clearValidationError: function () {
          hideValidationErrorProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE();
        },
        _suppressValueChangeAction: function () {
          if (
            ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance._suppressValueChangeAction
          ) {
            ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance._suppressValueChangeAction();
          }
        },
        _resumeValueChangeAction: function () {
          if (
            ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance._resumeValueChangeAction
          ) {
            ProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEERealInstance._resumeValueChangeAction();
          }
        },
      };

      if (!window.__hpaTextBoxUnderlineStyleInjected) {
        $("<style>")
          .attr("id", "hpa-textbox-underline-style")
          .text(
            `
                            .dx-texteditor.dx-editor-underlined::after {
                                border-bottom-color: #ddd !important;
                            }
                        `,
          )
          .appendTo("head");
        window.__hpaTextBoxUnderlineStyleInjected = true;
      }

      let InstanceProductNamePECA1DAA2949E4990A48E870437498233 = null;
      let $containerProductNamePECA1DAA2949E4990A48E870437498233 = $(
        "#PECA1DAA2949E4990A48E870437498233",
      );

      let _autoSaveProductNamePECA1DAA2949E4990A48E870437498233 = false;
      let _readOnlyProductNamePECA1DAA2949E4990A48E870437498233 = false;

      let ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue = "";
      let _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
      let ProductNamePECA1DAA2949E4990A48E870437498233RealInstance = null;

      /* =============== Helper Functions =============== */

      function isValidCustomFunction(func) {
        return (
          func &&
          func !== "" &&
          func !== null &&
          func !== undefined &&
          typeof func === "function"
        );
      }

      function showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233(
        message,
      ) {
        // Tô background đỏ nhạt và đổi màu underline
        $containerProductNamePECA1DAA2949E4990A48E870437498233
          .find("input")
          .css({
            "background-color": "#ffe6e6",
          });
        // Bắn UI Alert
        if (
          message &&
          message != "" &&
          typeof uiManager !== "undefined" &&
          uiManager.showAlert
        ) {
          uiManager.showAlert({ type: "error", message: message });
        }
      }

      function hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233() {
        $containerProductNamePECA1DAA2949E4990A48E870437498233
          .find("input")
          .css({
            "background-color": "",
          });
      }

      async function saveValueProductNamePECA1DAA2949E4990A48E870437498233() {
        if (_savingProductNamePECA1DAA2949E4990A48E870437498233) return;

        const newVal =
          ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
            "value",
          );

        if (
          newVal === ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue
        ) {
          _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
          return;
        }

        try {
          _savingProductNamePECA1DAA2949E4990A48E870437498233 = true;

          if (0 === 1) {
            if (!newVal || newVal.trim() === "") {
              const errorMsg =
                window.ValidationEngine &&
                window.ValidationEngine.getRequiredMessage
                  ? window.ValidationEngine.getRequiredMessage()
                  : "Trường này là bắt buộc";

              showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233(
                errorMsg,
              );
              _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;

              setTimeout(() => {
                $containerProductNamePECA1DAA2949E4990A48E870437498233
                  .find("input")
                  .focus();
              }, 50);

              return;
            }
          }

          // Custom validation check
          if (isValidCustomFunction(0)) {
            try {
              const validationResult = await 0(newVal);
              if (!validationResult) {
                showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
                _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
                return;
              }
            } catch (validationError) {
              const errorMsg =
                typeof validationError === "string"
                  ? validationError
                  : "Validation failed";
              showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
              _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
              return;
            }
          }

          console.log(_autoSaveProductNamePECA1DAA2949E4990A48E870437498233);
          hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
          if (_autoSaveProductNamePECA1DAA2949E4990A48E870437498233) {
            const dataJSON = JSON.stringify([
              "-280779754",
              ["ProductName"],
              [newVal],
            ]);

            let id1 = currentRecordID_ProductID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
              id1 = cellInfo.data["ProductID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ProductID"];

            if ("" && "".trim() !== "") {
              let id2 = currentRecordID_;
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.data
              ) {
                id2 = cellInfo.data[""] || id2;
              }
              currentRecordIDValue.push(id2);
              currentRecordID.push("");
            }

            const idValsJSON = JSON.stringify([
              currentRecordIDValue,
              currentRecordID,
            ]);

            const json = await saveFunction(dataJSON, idValsJSON);

            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
              uiManager.showAlert({
                type: "error",
                message: dtError[0]?.Message || "%SaveErrorMessage%",
              });
              _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
              return;
            }

            {
              try {
                let KeyRowTable = window.currentClicked_;
                console.log("KeyRowTable:", KeyRowTable);
                if (KeyRowTable != null && KeyRowTable != undefined) {
                  var updateData = {};
                  updateData["0"] = KeyRowTable;
                  updateData["ProductName"] =
                    InstanceProductNamePECA1DAA2949E4990A48E870437498233.option(
                      "value",
                    );

                  // 2. Thực hiện update Shared Grid
                  // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                  window.updateSharedGridRow("", updateData);

                  // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                  if (
                    typeof DataSource !== "undefined" &&
                    Array.isArray(DataSource)
                  ) {
                    // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                    var ds = DataSource.filter(
                      (item) => item.RowID === KeyRowTable,
                    );

                    if (ds && ds.length > 0) {
                      ds[0]["ProductName"] = updateData["ProductName"];

                      // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                      // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                    }
                  }
                }

                var updateData = {};
                updateData["ProductID"] = currentRecordIDValue[0];
                updateData["ProductName"] =
                  InstanceProductNamePECA1DAA2949E4990A48E870437498233.option(
                    "value",
                  );

                var id2FieldName = "";
                var hasKey2 =
                  id2FieldName &&
                  id2FieldName !== "" &&
                  id2FieldName.indexOf("%") === -1;

                if (hasKey2) {
                  if (
                    currentRecordIDValue.length > 1 &&
                    currentRecordIDValue[1] !== undefined
                  ) {
                    updateData[id2FieldName] = currentRecordIDValue[1];
                  }
                }

                // Thực hiện update shared grid
                window.updateSharedGridRow("", updateData);

                // Kiểm tra và cập nhật biến DataSource cục bộ
                if (
                  typeof DataSource !== "undefined" &&
                  Array.isArray(DataSource)
                ) {
                  var ds;
                  if (!hasKey2) {
                    // Trường hợp 1 khóa
                    ds = DataSource.filter(
                      (item) => item["ProductID"] === updateData["ProductID"],
                    );
                  } else {
                    // Trường hợp 2 khóa
                    ds = DataSource.filter(
                      (item) =>
                        item["ProductID"] === updateData["ProductID"] &&
                        item[id2FieldName] === updateData[id2FieldName],
                    );
                  }

                  if (ds && ds.length > 0) {
                    ds[0]["ProductName"] = updateData["ProductName"];
                  }
                }
              } catch (dsErr) {
                console.warn(
                  "[Grid Sync] TextBox ProductNamePECA1DAA2949E4990A48E870437498233: Không thể sync shared grid data source:",
                  dsErr,
                );
              }
            }
          }

          ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue = newVal;

          if (
            typeof cellInfo !== "undefined" &&
            cellInfo &&
            cellInfo.component
          ) {
            try {
              const grid = cellInfo.component;
              grid.cellValue(cellInfo.rowIndex, "ProductName", newVal);
              grid.repaint();
            } catch (syncErr) {
              console.warn("[Grid Sync] Không thể sync grid:", syncErr);
            }
          }
  } catch (err) {
          console.warn(
            "[ProductNamePECA1DAA2949E4990A48E870437498233] Có lỗi:",
            err,
          );
        } finally {
          setTimeout(function () {
            _savingProductNamePECA1DAA2949E4990A48E870437498233 = false;
          }, 100);
        }
      }

      /* =============== Create UI =============== */

      ProductNamePECA1DAA2949E4990A48E870437498233RealInstance = $("<div>")
        .appendTo($containerProductNamePECA1DAA2949E4990A48E870437498233)
        .dxTextBox({
          value: "",
          width: "100%",
          placeholder: "",
          readOnly: _readOnlyProductNamePECA1DAA2949E4990A48E870437498233,
          stylingMode: "underlined",
          inputAttr: {
            style:
              "font-size: inherit; font-weight: inherit; border-bottom-color: #ddd;",
          },
          onValueChanged: function (e) {
            //var value = e.component.option("value");
            if (!e.value) {
              SetInvalid(
                "#PECA1DAA2949E4990A48E870437498233",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#PECA1DAA2949E4990A48E870437498233", 1);
            }
          } /*
          onFocusOut: function (e) {
            if (_readOnlyProductNamePECA1DAA2949E4990A48E870437498233) return;

            const $input =
              $containerProductNamePECA1DAA2949E4990A48E870437498233.find(
                "input",
              );
            const currentValue = $input.val();

            // Validate required
            if (0 === 1) {
              if (!currentValue || currentValue.trim() === "") {
                const errorMsg =
                  window.ValidationEngine &&
                  window.ValidationEngine.getRequiredMessage
                    ? window.ValidationEngine.getRequiredMessage(
                        "%DisplayName%",
                      )
                    : "%DisplayName% là bắt buộc";

                showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233(
                  errorMsg,
                );
                return;
              }
            }

            hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
            // 👉 chỉ save khi value thay đổi
            if (
              currentValue !==
              ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue
            ) {
              ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
                "value",
                currentValue,
              );
              saveValueProductNamePECA1DAA2949E4990A48E870437498233();
             ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue =
   currentValue;
            }
      },
          onKeyDown: function (e) {
    if (e.event.key === "Enter") {
 e.event.preventDefault();

      const currentValue =
                $containerProductNamePECA1DAA2949E4990A48E870437498233

                  .find("input")
         .val();

              if (0 === 1) {
                if (!currentValue || currentValue.trim() === "") {
                  const errorMsg =
                    window.ValidationEngine &&
                    window.ValidationEngine.getRequiredMessage
                      ? window.ValidationEngine.getRequiredMessage(
                          "%DisplayName%",
                        )
                      : "%DisplayName% là bắt buộc";

                  showValidationErrorProductNamePECA1DAA2949E4990A48E870437498233(
                    errorMsg,
                  );
                  return;
                }
              }

              hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
              ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
  "value",
                currentValue,
              );
     saveValueProductNamePECA1DAA2949E4990A48E870437498233();
            }

            if (e.event.key === "Tab") {
              e.event.preventDefault();
              const $input =
                $containerProductNamePECA1DAA2949E4990A48E870437498233.find(
                  "input",
                );
              const currentValue = $input.val();
              ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
                "value",
                currentValue,
);
              saveValueProductNamePECA1DAA2949E4990A48E870437498233();
            }

     if (e.event.key === "Escape") {
              e.event.preventDefault();
              ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
                "value",
                ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue,
              );
              hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
              $containerProductNamePECA1DAA2949E4990A48E870437498233
                .find("input")
                .blur();
            }
          }, */,
          onInput: function (e) {
            let value = e.event.target.value;
            if (!value) {
              SetInvalid(
                "#PECA1DAA2949E4990A48E870437498233",
                "%CannotBeEmpty%",
                1,
              );
            } else {
              SetValid("#PECA1DAA2949E4990A48E870437498233", 1);
            }
          },
        })
        .dxTextBox("instance");

      /* =============== Public API =============== */
      InstanceProductNamePECA1DAA2949E4990A48E870437498233 = {
        setValue: function (val) {
          const displayVal = val == null || val === "" ? "" : String(val);
          ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue =
            displayVal;
          ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
            "value",
            displayVal,
          );
        },
        getValue: function () {
          return ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
            "value",
          );
        },
        option: function (name, value) {
          if (value !== undefined) {
            ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
              name,
              value,
            );

            if (name === "value") {
              const val = value || "";
              ProductNamePECA1DAA2949E4990A48E870437498233OriginalValue = val;

              if (
                this.__cellInfo &&
                typeof this.__cellInfo.setValue === "function" &&
                this.__cellInfo.component
              ) {
                try {
                  this.__cellInfo.setValue(val);
                } catch (e) {
                  console.warn("[hpaControlText] Grid sync skipped", e);
                }
              }
            }
          } else {
            return ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.option(
              name,
            );
          }
        },
        repaint: function () {
          ProductNamePECA1DAA2949E4990A48E870437498233RealInstance.repaint();
        },
        clearValidationError: function () {
          hideValidationErrorProductNamePECA1DAA2949E4990A48E870437498233();
        },
        _suppressValueChangeAction: function () {
          if (
            ProductNamePECA1DAA2949E4990A48E870437498233RealInstance._suppressValueChangeAction
          ) {
            ProductNamePECA1DAA2949E4990A48E870437498233RealInstance._suppressValueChangeAction();
          }
        },
        _resumeValueChangeAction: function () {
          if (
            ProductNamePECA1DAA2949E4990A48E870437498233RealInstance._resumeValueChangeAction
          ) {
            ProductNamePECA1DAA2949E4990A48E870437498233RealInstance._resumeValueChangeAction();
          }
      },
      };

      let InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A = null;
      let IventoryTimeOut;
      let _autoSaveIventoryP14F3D24DB1F4440F8DDB1935FE19215A = false;
      let _readOnlyIventoryP14F3D24DB1F4440F8DDB1935FE19215A = false;
      let $containerIventoryP14F3D24DB1F4440F8DDB1935FE19215A = $(
        "#P14F3D24DB1F4440F8DDB1935FE19215A",
      );

      async function NumberBoxSaveLogicIventory() {
        let val =
          InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option("value");

        const dataJSON = JSON.stringify(["-280779754", ["Iventory"], [val]]);

        // Context-aware record IDs
        let id1 = currentRecordID_ProductID;
        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
          id1 = cellInfo.data["ProductID"] || id1;
        }
        let currentRecordIDValue = [id1];
        let currentRecordID = ["ProductID"];

        if ("" && "".trim() !== "") {
          let id2 = currentRecordID_;
          if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
            id2 = cellInfo.data[""] || id2;
          }
          currentRecordIDValue.push(id2);
          currentRecordID.push("");
        }

        const idValsJSON = JSON.stringify([
          currentRecordIDValue,
          currentRecordID,
        ]);

        try {
          const json = await saveFunction(dataJSON, idValsJSON);
          const dtError = json.data[json.data.length - 1] || [];
          if (dtError.length > 0 && dtError[0].Status === "ERROR") {
            uiManager.showAlert({
              type: "error",
              message: dtError[0]?.Message || "%SaveErrorMessage%",
            });
          } else {
            {
              try {
                var updateData = {};
                updateData["ProductID"] = currentRecordIDValue[0];
                updateData["Iventory"] =
                  InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option(
                    "value",
                  );

                var id2FieldName = "";
                var hasKey2 =
                  id2FieldName &&
                  id2FieldName !== "" &&
                  id2FieldName.indexOf("%") === -1;

                if (hasKey2) {
                  if (
                    currentRecordIDValue.length > 1 &&
                    currentRecordIDValue[1] !== undefined
                  ) {
                    updateData[id2FieldName] = currentRecordIDValue[1];
                  }
                }

                // Thực hiện update shared grid
                window.updateSharedGridRow("", updateData);

                // Kiểm tra và cập nhật biến DataSource cục bộ
                if (
                  typeof DataSource !== "undefined" &&
                  Array.isArray(DataSource)
                ) {
                  var ds;
                  if (!hasKey2) {
                    // Trường hợp 1 khóa
                    ds = DataSource.filter(
                      (item) => item["ProductID"] === updateData["ProductID"],
                    );
                  } else {
                    // Trường hợp 2 khóa
                    ds = DataSource.filter(
                      (item) =>
                        item["ProductID"] === updateData["ProductID"] &&
                      item[id2FieldName] === updateData[id2FieldName],
                    );
                  }

                  if (ds && ds.length > 0) {
                    ds[0]["Iventory"] = updateData["Iventory"];
                  }
                }
              } catch (dsErr) {
                console.warn(
                  "[Grid Sync] NumberBox IventoryP14F3D24DB1F4440F8DDB1935FE19215A: Không thể sync shared grid data source:",
                  dsErr,
                );
              }
            }
          }

          if (
            typeof cellInfo !== "undefined" &&
      cellInfo &&
            cellInfo.component
          ) {
            try {
              const grid = cellInfo.component;
              grid.cellValue(cellInfo.rowIndex, "Iventory", val);
              grid.repaint();
            } catch (syncErr) {
              console.warn(
                "[Grid Sync] NumberBox IventoryP14F3D24DB1F4440F8DDB1935FE19215A: Error",
                syncErr,
              );
            }
          }
        } catch (err) {
          console.error("NumberBox Save Error:", err);
        }
      }

      let IventoryP14F3D24DB1F4440F8DDB1935FE19215ARealInstance = $(
        "#P14F3D24DB1F4440F8DDB1935FE19215A",
      )
        .dxNumberBox({
          format: "#,##0",
          disabled: true,
          showSpinButtons: false,
          showClearButton: false,
          width: "100%",
          elementAttr: { class: "hpa-dx-numberbox-inline" },
          readOnly: _readOnlyIventoryP14F3D24DB1F4440F8DDB1935FE19215A,
          onKeyDown: function (e) {
            if (e.event.key === "Enter") {
              e.event.preventDefault();
              if (_autoSaveIventoryP14F3D24DB1F4440F8DDB1935FE19215A) {
                NumberBoxSaveLogicIventory();
              }
            }
          },
          onValueChanged: async (e) => {
            if (_autoSaveIventoryP14F3D24DB1F4440F8DDB1935FE19215A) {
              clearTimeout(IventoryTimeOut);
              e.event && (await NumberBoxSaveLogicIventory());
            } else {
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.component
              ) {
                const grid = cellInfo.component;
                grid.cellValue(cellInfo.rowIndex, "Iventory", e.value);
              }
            }
          },
          onKeyUp: (e) => {
            if (_autoSaveIventoryP14F3D24DB1F4440F8DDB1935FE19215A) {
              clearTimeout(IventoryTimeOut);
              IventoryTimeOut = setTimeout(
                async () => NumberBoxSaveLogicIventory(),
                1000,
              );
            }
          },
        })
        .dxNumberBox("instance");

      /* =============== Public API =============== */
      InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A = {
        option: function (name, value) {
          if (value !== undefined) {
            return IventoryP14F3D24DB1F4440F8DDB1935FE19215ARealInstance.option(
              name,
              value,
            );
          } else {
            return IventoryP14F3D24DB1F4440F8DDB1935FE19215ARealInstance.option(
              name,
            );
          }
        },
        repaint: function () {
          IventoryP14F3D24DB1F4440F8DDB1935FE19215ARealInstance.repaint();
        },
        focus: function () {
          IventoryP14F3D24DB1F4440F8DDB1935FE19215ARealInstance.focus();
        },
        _suppressValueChangeAction: function () {
          // NumberBox không hỗ trợ method này
        },
        _resumeValueChangeAction: function () {
          // NumberBox không hỗ trợ method này
        },
      };

      window["DataSource_StatusProduct"] =
        window["DataSource_StatusProduct"] || [];

      let StatusP34FED30C5F294596A5F228581F51FDD9DataSourceSP =
        "sp_getStatusProduct";
      let StatusP34FED30C5F294596A5F228581F51FDD9IsLoading = false;
      let StatusP34FED30C5F294596A5F228581F51FDD9IsDataLoaded = false;
      let _autoSaveStatusP34FED30C5F294596A5F228581F51FDD9 = false;
      let _readOnlyStatusP34FED30C5F294596A5F228581F51FDD9 = false;
      let StatusP34FED30C5F294596A5F228581F51FDD9TableAddNew = "";
      let StatusP34FED30C5F294596A5F228581F51FDD9ColumnAddNew = "";
      let StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch = "";
      let StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue = "";
      let InstanceStatusP34FED30C5F294596A5F228581F51FDD9 = null;
      const StatusP34FED30C5F294596A5F228581F51FDD9LastSearchClass =
        "hpa-last-search-P34FED30C5F294596A5F228581F51FDD9";

      function getDataSourceConfigStatusP34FED30C5F294596A5F228581F51FDD9(
        data,
      ) {
        const idField = window["DataSourceIDField_Status"] || "ID";
        return new DevExpress.data.DataSource({
          paginate: false,
          store: new DevExpress.data.CustomStore({
            key: idField,
            load: function (loadOptions) {
              let searchValue =
                StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch || "";

              if (!searchValue && loadOptions && loadOptions.searchValue) {
                searchValue = loadOptions.searchValue;
              }

              if (
                !searchValue &&
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9 &&
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option
              ) {
                searchValue =
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                    "searchValue",
                  ) || "";
              }

              let result = data || [];

              if (searchValue && searchValue.trim()) {
                result = result.filter((item) =>
                  customSearchStatus(item, searchValue),
                );

                if (
                  StatusP34FED30C5F294596A5F228581F51FDD9TableAddNew &&
                  StatusP34FED30C5F294596A5F228581F51FDD9TableAddNew.trim() !==
                    ""
                ) {
                  const nameField =
                    window["DataSourceNameField_Status"] || "Name";
                  const addNewItem = { IsAddNew: true };
                  addNewItem[nameField] = searchValue.trim();
                  result.push(addNewItem);
                }
              }

              return Promise.resolve(result);
            },
            byKey: function (key) {
              const idField = window["DataSourceIDField_Status"] || "ID";
              return Promise.resolve(
                (data || []).find((i) => i[idField] === key),
              );
            },
          }),
        });
      }

      async function processAddNewStatus(newValue) {
        if (!newValue || !newValue.trim()) return;

        InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
          "disabled",
          true,
        );

        const dataJSON = JSON.stringify([
          StatusP34FED30C5F294596A5F228581F51FDD9TableAddNew,
          [StatusP34FED30C5F294596A5F228581F51FDD9ColumnAddNew],
          [newValue.trim()],
        ]);

        try {
          console.log("dataJSON", dataJSON);
          const json = await saveFunction(dataJSON);
          const dtError = json.data[json.data.length - 1] || [];

          if (dtError.length > 0 && dtError[0].Status === "ERROR") {
            uiManager.showAlert({
              type: "error",
              message: dtError[0]?.Message || "Lỗi thêm mới",
            });
          } else {
            const newItemID = dtError[0]?.IDValue || null;

            if (newItemID) {
              const idField = window["DataSourceIDField_Status"] || "ID";
              const nameField = window["DataSourceNameField_Status"] || "Name";

              const newItem = {};
              newItem[idField] = newItemID;
              newItem[nameField] = newValue.trim();

              if (!window["DataSource_StatusProduct"]) {
                window["DataSource_StatusProduct"] = [];
              }
              window["DataSource_StatusProduct"].push(newItem);

              InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "dataSource",
                getDataSourceConfigStatusP34FED30C5F294596A5F228581F51FDD9(
   window["DataSource_StatusProduct"],
                ),
              );

         InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "value",
                newItemID,
              );
              InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "searchValue",
                "",
              );
              StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch = "";
            }
          }
        } catch (e) {
          console.error(e);
          uiManager.showAlert({
            type: "error",
            message: "Có lỗi khi thêm mới",
          });
        } finally {
          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
            "disabled",
            false,
          );
          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.close();
        }
      }

      function customSearchStatus(item, searchValue) {
        if (!searchValue) return true;
        const searchNormalized = hpaUtils
          .removeToneMarks(searchValue)
          .toLowerCase();
        const idField = window["DataSourceIDField_Status"] || "ID";
        const nameField = window["DataSourceNameField_Status"] || "Name";
        const fields = [idField, nameField, "Code", "Description"];

        for (let i = 0; i < fields.length; i++) {
          const fieldValue = item[fields[i]];
          if (fieldValue) {
            const fieldNormalized = hpaUtils
              .removeToneMarks(String(fieldValue))
              .toLowerCase();
            if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
          }
        }
        return false;
      }

      function renderLastSearchHintStatusP34FED30C5F294596A5F228581F51FDD9(
        $popupContent,
      ) {
        if (!$popupContent || !$popupContent.length) return;

        const lastSearch = (
          StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue || ""
        ).trim();
        let $hint = $popupContent.find(
          "." + StatusP34FED30C5F294596A5F228581F51FDD9LastSearchClass,
        );

        if (!lastSearch) {
          if ($hint.length) {
            $hint.remove();
          }
          return;
        }

        if (!$hint.length) {
          $hint = $("<div>")
            .addClass(
              StatusP34FED30C5F294596A5F228581F51FDD9LastSearchClass +
                " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom",
            )
            .css({
              fontSize: "12px",
              background: "#f8f9fa",
            })
            .prependTo($popupContent);

          $("<span>")
            .addClass("flex-fill text-muted text-truncate")
            .appendTo($hint);

          $("<button>")
            .attr("type", "button")
            .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
            .text("Áp dụng lại")
            .on("dxclick", function (ev) {
              ev.preventDefault();
              ev.stopPropagation();
              if (!StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue)
                return;
              StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch =
                StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue;
              InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "searchValue",
                StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue,
              );
              const $input = $("#P34FED30C5F294596A5F228581F51FDD9").find(
                ".dx-texteditor-input",
              );
              if ($input && $input.length) {
                setTimeout(function () {
                  $input.focus();
                }, 0);
              }
            })
            .appendTo($hint);
        }

        $hint.find("span").text(''Lần tìm trước: "'' + lastSearch + ''"'');
      }

      InstanceStatusP34FED30C5F294596A5F228581F51FDD9 = $(
        "#P34FED30C5F294596A5F228581F51FDD9",
      )
  .dxSelectBox({
          readOnly: _readOnlyStatusP34FED30C5F294596A5F228581F51FDD9,
          dataSource:
            getDataSourceConfigStatusP34FED30C5F294596A5F228581F51FDD9(
              window["DataSource_StatusProduct"],
            ),
          valueExpr: window["DataSourceIDField_Status"] || "ID",
          displayExpr: window["DataSourceNameField_Status"] || "Name",
          onOptionChanged: function (e) {
            if (!e || !e.component) return;
            if (e.name === "searchValue") {
              const newVal = (e.value || "").toString();
              StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch = newVal;
              if (newVal && newVal.trim()) {
                StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue = newVal;
              }

              if (e.component.option("opened") && e.component._popup) {
                renderLastSearchHintStatusP34FED30C5F294596A5F228581F51FDD9(
                  $(e.component._popup.content()),
                );
              }
            }
          },
          onContentReady: function (e) {},
          placeholder: "Tìm kiếm hoặc chọn...",
          searchEnabled: true,
          searchTimeout: 300,
          minSearchLength: 0,
          showDataBeforeSearch: true,
          showClearButton: false,
          stylingMode: "outlined",
          dropDownOptions: {
            showTitle: false,
            closeOnOutsideClick: true,
            height: "auto",
            maxHeight: 400,
            minWidth: 320,
            onShowing: function (e) {
              if (
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9 &&
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option
              ) {
                const pendingSearch =
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                    "searchValue",
                  ) || "";
                if (pendingSearch && pendingSearch.trim()) {
                  StatusP34FED30C5F294596A5F228581F51FDD9LastSearchValue =
                    pendingSearch;
                }
                StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch = "";
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                  "searchValue",
                  "",
                );
              }
            },
            onHidden: function () {
              StatusP34FED30C5F294596A5F228581F51FDD9CurrentSearch = "";
              if (
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9 &&
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option
              ) {
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                  "searchValue",
                  "",
                );
              }
            },
          },
          itemTemplate: function (data, index) {
            if (data.IsAddNew) {
              const nameField = window["DataSourceNameField_Status"] || "Name";
              const $item = $("<div>")
                .addClass(
                  "d-flex align-items-center gap-2 px-3 py-2 text-primary",
                )
                .css({
                  cursor: "pointer",
                  borderTop: "1px dashed #dee2e6",
                  fontWeight: "600",
                });

              $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
              $("<span>")
                .text(''Thêm mới: "'' + data[nameField] + ''"'')
                .appendTo($item);

              $item.on("dxclick", async function (e) {
                e.stopPropagation();
                if (
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9 &&
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9.blur
                )
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9.blur();
                await processAddNewStatus(data[nameField]);
              });

              return $item;
            }

            const idField = window["DataSourceIDField_Status"] || "ID";
            const nameField = window["DataSourceNameField_Status"] || "Name";
            const searchValue =
              InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "searchValue",
              ) || "";

            const $item = $("<div>")
              .addClass(
                "d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light",
              )
              .css({ cursor: "pointer" });

            const $content = $("<div>")
              .addClass("flex-fill")
              .css("minWidth", "0");

            const displayName =
              (data[idField] !== undefined ? data[idField] + " - " : "") +
              (data[nameField] || "");
            $("<div>")
              .addClass("fw-normal ")
              .css({
                fontSize: "13px",
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              })
              .html(hpaUtils.highlightText(displayName, searchValue))
              .appendTo($content);

            if (data.Description || data.Code) {
              $("<div>")
                .addClass("text-muted")
                .css({
                  fontSize: "11px",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                })
                .text(data.Code || data.Description)
                .appendTo($content);
            }

            $content.appendTo($item);

            if (data.Status) {
              const badgeClass =
                data.Status === "Active" ? "bg-success" : "bg-secondary";
              $("<span>")
                .addClass("badge " + badgeClass)
                .css({
                  fontSize: "9px",
                  padding: "3px 6px",
                  borderRadius: "4px",
                  opacity: "0.8",
                })
                .text(data.Status)
                .appendTo($item);
            }

            return $item;
          },
          onOpened: function (e) {
            const $popupContent = $(e.component._popup.content());
            $popupContent.parent().addClass("shadow-lg border rounded").css({
              borderRadius: "8px",
              padding: "4px 0",
              borderColor: "#dee2e6",
            });

            renderLastSearchHintStatusP34FED30C5F294596A5F228581F51FDD9(
              $popupContent,
            );
          },
          onFocusIn: function (e) {
            InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
              "showClearButton",
              true,
            );
          },
          onFocusOut: function (e) {
            InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
              "showClearButton",
              false,
            );
          },
          onKeyDown: function (e) {
            if (e.key === "Enter" || e.key === "Tab") {
              InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                "showClearButton",
                false,
              );
            }
          },
          onValueChanged: async function (e) {
            if (!e.event) return;

            if (_autoSaveStatusP34FED30C5F294596A5F228581F51FDD9) {
              if (
                e.value === "" ||
                e.value == null ||
                e.value === 0 ||
                e.value === "0"
              ) {
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                  "value",
                  _initialStatusP34FED30C5F294596A5F228581F51FDD9,
                );
                return;
      }

              $("#P34FED30C5F294596A5F228581F51FDD9")
                .find(".dx-texteditor-input")
                .blur();
              if (
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9 &&
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.blur
              )
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.blur();

              if (typeof window["onSelectBoxChanged_Status"] === "function") {
                window["onSelectBoxChanged_Status"](
                  e.value,
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9,
                  e,
                );
              }

              const val = e.value;
              const dataJSON = JSON.stringify([
                "-280779754",
                ["Status"],
                [val || ""],
              ]);

              let id1 = currentRecordID_ProductID;
              if (
                typeof cellInfo !== "undefined" &&
                cellInfo &&
                cellInfo.data
              ) {
                id1 = cellInfo.data["ProductID"] || id1;
              }
              let currentRecordIDValue = [id1];
              let currentRecordID = ["ProductID"];

              if ("" && "".trim() !== "") {
                let id2 = currentRecordID_;
                if (
                  typeof cellInfo !== "undefined" &&
                  cellInfo &&
                  cellInfo.data
                ) {
                  id2 = cellInfo.data[""] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("");
              }
              const idValsJSON = JSON.stringify([
                currentRecordIDValue,
                currentRecordID,
              ]);

              try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                  uiManager.showAlert({
                    type: "error",
                    message: dtError[0]?.Message || "Lưu thất bại",
                  });
                  InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                    "value",
                    _initialStatusP34FED30C5F294596A5F228581F51FDD9,
                  );
                } else {
                  if (
                    0 != 0 &&
                    0 != null &&
                    0 != "" &&
                    window.hpaSharedGridDataSources["0"]
                  ) {
                    try {
                      let KeyRowTable = window.currentClicked_0;
                      console.log("KeyRowTable:", KeyRowTable);
                      if (KeyRowTable != null && KeyRowTable != undefined) {
                        var updateData = {};
                        updateData["0"] = KeyRowTable;
                        updateData["Status"] =
                          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                            "value",
                          );

                        // 2. Thực hiện update Shared Grid
                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                        window.updateSharedGridRow("0", updateData);

                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                        if (
                          typeof DataSource !== "undefined" &&
                          Array.isArray(DataSource)
                        ) {
                          // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                          var ds = DataSource.filter(
                            (item) => item.RowID === KeyRowTable,
                          );

                          if (ds && ds.length > 0) {
    ds[0]["Status"] = updateData["Status"];

                            // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                            // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                          }
                        }
                      }

                      var updateData = {};
                      updateData["ProductID"] = currentRecordIDValue[0];
                      updateData["Status"] =
                        InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                          "value",
                        );

                      var id2FieldName = "";
                      var hasKey2 =
                        id2FieldName &&
                        id2FieldName !== "" &&
                        id2FieldName.indexOf("%") === -1;

                      if (hasKey2) {
                        if (
                          currentRecordIDValue.length > 1 &&
                          currentRecordIDValue[1] !== undefined
                        ) {
                          updateData[id2FieldName] = currentRecordIDValue[1];
                        }
                      }

                      window.updateSharedGridRow("0", updateData);

                      if (
                        typeof DataSource !== "undefined" &&
                        Array.isArray(DataSource)
                      ) {
                        var ds;
                        if (!hasKey2) {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"],
                          );
                        } else {
                          ds = DataSource.filter(
                            (item) =>
                              item["ProductID"] === updateData["ProductID"] &&
                              item[id2FieldName] === updateData[id2FieldName],
                          );
                        }

                        if (ds && ds.length > 0) {
                          ds[0]["Status"] = updateData["Status"];
                        }
                      }
                    } catch (dsErr) {
                      console.warn(
                        "[Grid Sync] SelectBox StatusP34FED30C5F294596A5F228581F51FDD9: Không thể sync shared grid data source:",
                        dsErr,
                      );
                    }
                  }

                  if (
                    typeof cellInfo !== "undefined" &&
                    cellInfo &&
                    cellInfo.component
                  ) {
                    try {
                      const grid = cellInfo.component;
                      grid.cellValue(cellInfo.rowIndex, "Status", val);
                      grid.repaint();
                    } catch (syncErr) {
                      console.warn(
                        "[Grid Sync] SelectBox StatusP34FED30C5F294596A5F228581F51FDD9: Không thể sync grid:",
                        syncErr,
                      );
                    }
                  }
                  _initialStatusP34FED30C5F294596A5F228581F51FDD9 = val;
                }
              } catch (err) {
                uiManager.showAlert({
                  type: "error",
                  message: "Có lỗi xảy ra khi lưu",
                });
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
                  "value",
                  _initialStatusP34FED30C5F294596A5F228581F51FDD9,
                );
                console.error("SelectBox Save Error:", err);
              }
              return;
            }

            // Manual mode - no save, just callbacks and grid sync
            if (typeof window["onSelectBoxChanged_Status"] === "function") {
              window["onSelectBoxChanged_Status"](
        e.value,
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9,
                e,
              );
         }

            if (
              typeof cellInfo !== "undefined" &&
              cellInfo &&
              cellInfo.component
            ) {
              try {
                const grid = cellInfo.component;
                grid.cellValue(cellInfo.rowIndex, "Status", e.value);
                grid.repaint();
              } catch (syncErr) {
                console.warn("[Grid Sync] Không thể sync grid:", syncErr);
              }
            }
          },
        })
        .dxSelectBox("instance");

      /*  let _initialStatusP34FED30C5F294596A5F228581F51FDD9 = InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("value");

        if (StatusP34FED30C5F294596A5F228581F51FDD9DataSourceSP && StatusP34FED30C5F294596A5F228581F51FDD9DataSourceSP !== "") {
            loadDataSourceCommon("Status", StatusP34FED30C5F294596A5F228581F51FDD9DataSourceSP, function(data) {
                StatusP34FED30C5F294596A5F228581F51FDD9IsDataLoaded = true;

                const idField = window["DataSourceIDField_Status"] || "ID";
                const nameField = window["DataSourceNameField_Status"] || "Name";

                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("valueExpr", idField);
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("displayExpr", nameField);

                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("dataSource", getDataSourceConfigStatusP34FED30C5F294596A5F228581F51FDD9(data));
                InstanceStatusP34FED30C5F294596A5F228581F51FDD9.repaint();
        });
        }
        */
      window.InstancegridProductListP167883E16F8440A68C0E2A5302C36104 = null;
      // Thêm responsive styles cho grid header
      const stylegridProductList = document.createElement("style");
      stylegridProductList.textContent = `
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
                            }

                            @media (max-width: 768px) {
                                .dx-datagrid {
                                    font-size: 12px;
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
          overflow: visible !important;
                               white-space: nowrap;
                                    text-overflow: ellipsis;
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
                                    white-space: nowrap;
                                    text-overflow: ellipsis;
 word-break: break-word !important;
                                    vertical-align: middle !important;
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
    document.head.appendChild(stylegridProductList);

      // Helper normalize function: bỏ dấu - dùng chung cho search/grid
      window.normalizeVietnameseText =
        window.normalizeVietnameseText ||
        function (value) {
          if (value === undefined || value === null) return "";
          let text = String(value);
          if (typeof RemoveToneMarks_Js === "function") {
            text = RemoveToneMarks_Js(text);

          } else if (text.normalize) {
            text = text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
          }
          return text.replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase();
        };

        const gridName = "gridProductList";
      // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
      // Hàm tính remoteOperations dựa trên số lượng dòng
      window.getGridConfig_gridProductList = function (dataArray) {
        const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
        const isLargeDataset = dataSize > 1000;

        return {
          remoteOperations: isLargeDataset,
          pageSize: isLargeDataset ? 25 : 10,
          allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100],
        };
      };

      InstancegridProductListP167883E16F8440A68C0E2A5302C36104 = $(
        "#gridProductList",
      )
        .dxDataGrid({
          dataSource: [],
          keyExpr: "ProductID",
          height: "89vh",
          width: "99%",
          showBorders: true,
          showRowLines: true,
          rowAlternationEnabled: false,
          hoverStateEnabled: false,
          columnAutoWidth: true,
          allowColumnReordering: false,
          allowColumnResizing: false,
          columnResizingMode: "widget",
          columnMinWidth: 80,
          wordWrapEnabled: true,
          scrolling: {
                mode: "standard", // hoặc "virtual"
                useNative: true,
                showScrollbar: "always"
            },
          paging: {
            enabled: true,
            pageSize: 50,
          },

          pager: {
            visible: true,
            allowedPageSizes: [5, 10, 50, 100],
            showPageSizeSelector: true,
            showInfo: true,
            showNavigationButtons: true,
          },

          searchPanel: {
            visible: false,
            width: 260,
            highlightSearchResults: false,
            highlightCaseSensitive: false,
            placeholder: "Tìm kiếm theo nội dung",
          },

          headerFilter: { visible: false },
          columnChooser: {
            enabled: false,
            mode: "select",

            title: "Chọn cột hiển thị",
            allowSearch: true,
          },

          stateStoring: {
            enabled: false,
            type: "localStorage",
            storageKey: "gridState_gridProductList",
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
                if (val === undefined || val === null) return "";
                return String(val).toLowerCase();
              };

            columns.forEach(function (column) {
              if (column._hpaSearchNormalized) return;
              column._hpaSearchNormalized = true;

              const originalCalculate = column.calculateFilterExpression;
              const dataFieldPath = column.dataField || column.name || "";
              const getValue = column.calculateCellValue
                ? column.calculateCellValue.bind(column)
                : function (dataObj) {
                    if (!dataObj || !dataFieldPath) return null;
                    if (dataFieldPath.indexOf(".") === -1) {
                      return dataObj[dataFieldPath];
                    }
                    return dataFieldPath.split(".").reduce(function (acc, key) {
                      return acc && acc[key] !== undefined ? acc[key] : null;
                    }, dataObj);
                  };

              column.calculateFilterExpression = function (
                filterValue,
                selectedFilterOperation,
                target,
              ) {
                if (target === "search") {
                  const normalizedFilter = normalizeText(filterValue);
                  if (!normalizedFilter) {
                    if (originalCalculate) {
                      return originalCalculate.call(
                        this,
                        filterValue,
                        selectedFilterOperation,
                        target,
                      );
                    }
                    if (this.defaultCalculateFilterExpression) {
                      return this.defaultCalculateFilterExpression(
                        filterValue,
                        selectedFilterOperation,
                        target,
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
                    target,
                  );
                }

                if (this.defaultCalculateFilterExpression) {
                  return this.defaultCalculateFilterExpression(
                    filterValue,
                    selectedFilterOperation,
                    target,
                  );
                }

                return null;
              };
            });
          },

          editing: {
            mode: "cell",
            allowUpdating: false,
          },
          rowDragging: {
            allowReordering: false,
            showDragIcons: false,
          },
          noDataText: "Không có dữ liệu",
          columns: [
            {
              dataField: "ProductCode",
              caption: "Mã hàng",
              width: "200px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
                if (val === undefined || val === null || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("")
                    .appendTo(cellElement);
                  return;
                }
                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              dataField: "ProductName",
              caption: "Tên hàng",
              width: "450px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
                if (val === undefined || val === null || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("--")
                    .appendTo(cellElement);
                  return;
                }
                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              dataField: "Inventory",
              caption: "Tồn kho",
              width: "200px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
            if (val === undefined || val === null || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
         .text("")
                    .appendTo(cellElement);
                  return;
                }

                $("<div>").text(val).addClass("fw-bold").appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              dataField: "ProductTypeID",
              caption: "Loại sản phẩm",
              width: "200px",
              alignment: "left",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
                if (!val || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("--")
                    .appendTo(cellElement);
                  return;
                }
                const ds = window["DataSource_ProductTypeID"];
                if (ds && Array.isArray(ds)) {
                  const f = ds.find((x) => x.id == val || x.ID == val);
                  if (f) {
                    $("<div>")
                      .text(f.Text || f.Name || "")
                      .appendTo(cellElement);
                    return;
                  }
                }
                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },

            {
              dataField: "SupplierID",
              caption: "Nhà cung cấp",
              width: "200px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
                if (!val || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("--")
                    .appendTo(cellElement);
                  return;
                }
                const ds = window["DataSource_SupplierID"];
                if (ds && Array.isArray(ds)) {
                  const f = ds.find((x) => x.id == val || x.ID == val);
                  if (f) {
                    $("<div>")
                      .text(f.Text || f.Name || "")
                      .appendTo(cellElement);
                    return;
                  }
                }

                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              dataField: "Cost",
              caption: "Giá tiền",
              width: "200px",
              alignment: "center",
              minWidth: 80,
              maxWidth: 400,
              allowSorting: true,
              allowFiltering: true,
              format: "#,##0 ''đ''",
              /*cellTemplate: function(cellElement, cellInfo){
                                            const val = cellInfo.value;
                                            if (val === undefined || val === null || val === "") {
                                                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                                                return;
                                            }
                                            $("<div>").text(val).appendTo(cellElement);
                                  },*/
              allowEditing: false,
            },
            {
              dataField: "Status",
              caption: "%Status%",
              width: "200px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
          if (!val || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("--")
     .appendTo(cellElement);
                  return;
                }
                const ds = window["DataSource_StatusProduct"];

                if (ds && Array.isArray(ds)) {
                  const f = ds.find((x) => x.id == val || x.ID == val);
                  if (f) {
                    $("<div>")
                      .text(f.Text || f.Name || "")
                      .appendTo(cellElement)
                      .addClass(`text-${cellInfo.data.Color}`);
                    return;
                  }
                }

                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              dataField: "Description",
              caption: "Mô tả",
              width: "200px",
              alignment: "center",
              allowSorting: true,
              allowFiltering: true,
              cellTemplate: function (cellElement, cellInfo) {
                const val = cellInfo.value;
                if (val === undefined || val === null || val === "") {
                  $("<div>")
                    .addClass("dx-placeholder")
                    .text("--")
                    .appendTo(cellElement);
                  return;
                }
                $("<div>").text(val).appendTo(cellElement);
              },
              allowEditing: false,
            },
            {
              type: "buttons",
              name: "updateBtn",
              buttons: [
                {
                  hint: "Sửa",
                  icon: "edit",
                  onClick: function (e) {
                    SetValueControl(e.row.data);
                    InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
                      "disabled",
                      true,
                    );
                    $("#modalAddProduct").modal("show");
                    btnadd.option("visible", false);
                    btnsave.option("visible", true);
                    InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option(
                      "disabled",
                      true,
                    );
                  },
                },
              ],
            },
          ],
          onCellClick(e) {
            if (0 !== 1) return;

            const rowDataObject = e.data;

            const recordID = e.key ?? e.data?.["ProductID"];
            if (!recordID) return;
            window.currentClicked_gridProductList = recordID;
            window.currentRecordID_ProductID = recordID;
            openDetailProductID?.(rowDataObject);
          },
          onRowPrepared(e) {},
          onToolbarPreparing: function (e) {
            let isReloading = true;

            const grid = e.component;

            e.toolbarOptions.items.unshift(
              {
                location: "before",
                template: function () {
                  const $wrap = $(
                    ''<div class="stock-filter" id="stock-filter-productlist"></div>'',
                  );

                  const filters = [
                    { text: "Tất cả", value: "all" },
                    { text: "Còn hàng", value: "instock" },
                    { text: "Hết hàng", value: "outstock" },
                  ];

                  filters.forEach((f) => {
                    const $btn = $(`
                                                <div class="stock-btn  ${f.value === "all" ? "active" : ""}" data-value=''${f.value}''>
                        ${f.text}
               </div>
                                                `);

                    $btn.on("click", function () {
                      $wrap.find(".stock-btn").removeClass("active");
                      $(this).addClass("active");
                      //_pageCache = {};
                      InstancegridProductListP167883E16F8440A68C0E2A5302C36104.getDataSource().reload();
                    });

                    $wrap.append($btn);
                  });

                  return $wrap;
                },
              },

              {
                location: "after",
                template: function () {
                  const $wrap = $(
                    ''<div class="toolbar-right d-flex align-items-center gap-2"></div>'',
                  );

                  const $searchWrap = $(
                    ''<div class="ctlist-search-wrap"></div>'',
                  );
                  const $searchIcon = $(
                    ''<i class="bi bi-search ctlist-search-icon"></i>'',
                  );
                  const $searchInput = $("<input>", {
                    type: "text",
                    class: "ctlist-search-input",
                    placeholder: "Tìm kiếm sản phẩm...",
                  });
                  let setTimeOutSeach = null;

                  $searchInput.off("input").on("input", function () {
                    clearTimeout(setTimeOutSeach);

                    setTimeOutSeach = setTimeout(function () {
                      let keyword = $searchInput.val() || "";

                      if (typeof RemoveToneMarks_Js === "function")
                        keyword = RemoveToneMarks_Js(keyword);
                      else if (keyword.normalize)
                        keyword = keyword
                          .normalize("NFD")
                          .replace(/[\u0300-\u036f]/g, "");

                      keyword = keyword
                        .replace(/đ/g, "d")
                        .replace(/Đ/g, "D")
                        .toLowerCase()
                        .trim();

                      _currentKeyword = keyword;

                      _pageCache = {};

                      InstancegridProductListP167883E16F8440A68C0E2A5302C36104.getDataSource().reload();
                    }, 300);
                  });

                  $searchWrap.append($searchIcon, $searchInput);

                  const $btnReload = $(`
                                                <button class="btn-ctlist-reload" title="Tải lại">
                                                <i class="bi bi-arrow-clockwise"></i>
                                                </button>
                                             `);
                  $btnReload.on("click", async function () {
                    $btnReload.prop("disabled", true);

                    await ReloadData();

                    $btnReload.prop("disabled", false);
                  });
                  const $btnAdd = $(`
                                                <button class="btn btn-add-productlist btn-success">
                                                <i class="bi bi-plus-lg"></i> Thêm mới
                                                </button>
                                                `);
                  $btnAdd.off("click").on("click", function () {
                    InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option(
                      "disabled",
                      false,
                    );

                    ClearAllControl();
                    window.isNewProductDraft = true;
                    window.currentRecordID_ProductID = "sp_" + Math.floor(1000 + Math.random() * 90000);
                    window.currentRecordID_Temp_ProductID = window.currentRecordID_ProductID;

                    $("#modalAddProduct").modal("show");
                    btnadd.option("visible", true);
                    btnsave.option("visible", false);
                  });
                  let $btnInventoryImport =
                    $(`<button class="btn btn-add-productlist btn-success">
                                                                %spWH_productlistHistory.InventoryImport%
                                                                </button>`);
                  let $btnInventoryExport =
                    $(`<button class="btn btn-add-productlist btn-success">
                                                                 %spWH_productlistHistory.InventoryExport%
                                                                </button>`);
                  $btnInventoryImport.off("click").on("click", function () {
                    if (
                      ["Android", "iOS"].includes(getMobileOperatingSystem())
                    ) {
                      OpenFormParamMobile(`sp_WH_InventoryImport`);
                    } else {
                      openFormParam(`sp_WH_InventoryImport`);
                    }
                  });
                  $btnInventoryExport.off("click").on("click", function () {
                    if (
                      ["Android", "iOS"].includes(getMobileOperatingSystem())
                    ) {
                      OpenFormParamMobile(`sp_WH_InventoryExport`);
                    } else {
                      openFormParam(`sp_WH_InventoryExport`);
                    }
                  });
                  const $btnToggle = $(`
                                                <div class="dropdown">
                                                    <button class="toolbar-toggle dropdown-toggle" data-bs-toggle="dropdown">
                                                        <i class="bi bi-three-dots-vertical"></i>
                                                    </button>

                                                    <ul class="dropdown-menu">
                                                        <li>
                                                            <a class="dropdown-item btn-template">
                                                   <i class="bi bi-download"></i> File mẫu import
                      </a>
                                                        </li>
                   <li>
                                                            <a class="dropdown-item btn-import">

                                                                <i class="bi bi-upload"></i> Nhập vào
                                   </a>
                                                        </li>
                                                    </ul>
                                                </div>
                                                `);
                  $btnToggle.find(".btn-template").on("click", function () {
                    ExportTemplateImportProduct();
                  });

                  $btnToggle.find(".btn-import").on("click", function () {
                    fileUploaderts_btnImportProduct
                      .dxFileUploader("instance")
                      ._selectButton._clickAction();
                  });
                  $btnReload.on("click", () => grid.refresh());

                  $searchInput.on("input", function () {
                    grid.searchByText(this.value);
                  });

                  // Bình đẳng hóa phần tử con: Từng button được gắn trực tiếp vào Toolbar container
                  // Cho phép từng button rớt hàng độc lập khi màn hình co nhỏ
                  $wrap.append($searchWrap, $btnReload, $btnAdd, $btnInventoryImport, $btnInventoryExport, $btnToggle);

                  return $wrap;
                },
              },
            );
          },
  selection: {
            mode: "multiple",
            showCheckBoxesMode: "always",
            selectAllMode: "page",
          },
        })
        .dxDataGrid("instance");



      // Shared grid data source registry so detail forms can trigger refreshes
      window.hpaSharedGridDataSources = window.hpaSharedGridDataSources || {};

      if (!window.reloadSharedGridDataSource) {
        window.reloadSharedGridDataSource = function (name, params) {
          const registry = window.hpaSharedGridDataSources || {};
          const entry = registry[name];
          if (!entry || typeof entry.reload !== "function") {
            console.warn("[SharedGrid] Grid", name, "is not registered");
            return Promise.resolve([]);
          }
          return entry.reload(params);
        };
      }

      if (!window.getSharedGridDataSource) {
        window.getSharedGridDataSource = function (name) {
          const registry = window.hpaSharedGridDataSources || {};
          return registry[name];
        };
      }

      if (!window.updateSharedGridRow) {
        window.updateSharedGridRow = function (name, rowData, options) {
          const registry = window.hpaSharedGridDataSources || {};
          const entry = registry[name];
          if (!entry || typeof entry.applyRowChanges !== "function") {
            console.warn(
              "[SharedGrid] Grid",
              name,
              "cannot accept row updates",
            );
            return Promise.resolve(false);
          }
          return entry.applyRowChanges(rowData, options);
        };
      }

      if (!window.removeSharedGridRow) {
        window.removeSharedGridRow = function (name, options) {
          const registry = window.hpaSharedGridDataSources || {};
          const entry = registry[name];
          if (!entry || typeof entry.removeRow !== "function") {
            console.warn("[SharedGrid] Grid", name, "cannot remove rows");
            return Promise.resolve(false);
          }
          return entry.removeRow(options);
        };
      }

      (function setupSharedGridSource() {
        const sharedKey = gridName;
        const primaryKeyField = "ProductID";

        const loginValue =
          typeof window.UserID !== "undefined"
            ? window.UserID
            : typeof LoginID !== "undefined"
              ? LoginID
              : null;
        const languageValue =
          typeof window.LanguageID !== "undefined"
            ? window.LanguageID
            : typeof LanguageID !== "undefined"
              ? LanguageID
              : null;

        const snapshotGridData = function (instance) {
          if (!instance) return [];
          try {
            if (typeof instance.getDataSource === "function") {
              const ds = instance.getDataSource();
              if (ds && typeof ds.items === "function") {
                const dsItems = ds.items();
                if (Array.isArray(dsItems)) {
                  return dsItems.map(function (item) {
                    return item && typeof item === "object"
                      ? Object.assign({}, item)
                      : item;
                  });
                }
              }
            }

            if (typeof instance.option === "function") {
              const rawData = instance.option("dataSource");
              if (Array.isArray(rawData)) {
                return rawData.map(function (item) {
                  return item && typeof item === "object"
                    ? Object.assign({}, item)
                    : item;
                });
              }
            }
          } catch (snapshotErr) {
            console.warn(
              "[SharedGrid] Unable to snapshot grid data",
              snapshotErr,
            );
          }
          return [];
        };

        let sharedEntry = window.hpaSharedGridDataSources[sharedKey];
        if (!sharedEntry) {
          sharedEntry = {
            data: [],
            subscribers: [],
            loading: false,
          };
        }

        sharedEntry.primaryKey = sharedEntry.primaryKey || primaryKeyField;
        sharedEntry.data = Array.isArray(sharedEntry.data)
          ? sharedEntry.data
          : [];
        sharedEntry.subscribers = Array.isArray(sharedEntry.subscribers)
          ? sharedEntry.subscribers
          : [];
        sharedEntry.loading = !!sharedEntry.loading;

        if (typeof sharedEntry.normalizeParams !== "function") {
          sharedEntry.normalizeParams = function (customParams) {
            const base = [];
            if (loginValue !== null && loginValue !== undefined) {
              base.push("LoginID", loginValue);
            }
            if (languageValue !== null && languageValue !== undefined) {
              base.push("LanguageID", languageValue);
            }

            if (Array.isArray(customParams) && customParams.length > 0) {
              return base.concat(customParams);
            }

            if (customParams && typeof customParams === "object") {
              const extras = [];
              Object.keys(customParams).forEach(function (key) {
                extras.push(key, customParams[key]);
              });
              return base.concat(extras);
            }

            return base;
          };
        }

        if (typeof sharedEntry.notify !== "function") {
          sharedEntry.notify = function () {
            this.subscribers.forEach(function (callback) {
              try {
                callback(this.data);
              } catch (err) {
                console.error("[SharedGrid] subscriber error", err);
              }
            }, this);
          };
        }

        if (typeof sharedEntry.subscribe !== "function") {
          sharedEntry.subscribe = function (callback) {
            if (typeof callback === "function") {
              this.subscribers.push(callback);
            }
            return () => {
              this.subscribers = this.subscribers.filter(function (fn) {
                return fn !== callback;
              });
            };
          };
        }

        if (typeof sharedEntry.applyRowChanges !== "function") {
          sharedEntry.applyRowChanges = function (rowData, options) {
            const opts = options || {};
            const keyField = this.primaryKey;
            let keyValue = opts.key;
            if (
              (keyValue === undefined || keyValue === null) &&
              rowData &&
              rowData[keyField] !== undefined
            ) {
              keyValue = rowData[keyField];
            }

            if (keyValue === undefined || keyValue === null) {
              console.warn(
                "[SharedGrid] Missing key when applying row changes for",
                sharedKey,
              );
              return Promise.resolve(false);
            }

            if (typeof this.ensureLocalData === "function") {
              this.ensureLocalData();
            }

            const compare =
              opts.strict === true
                ? function (candidate) {
                    return candidate === keyValue;
                  }
                : function (candidate) {
                    if (candidate === undefined || candidate === null)
                      return candidate === keyValue;
                    if (keyValue === undefined || keyValue === null)
                      return false;
                    return String(candidate) === String(keyValue);
                  };

            const nextData = Array.isArray(this.data) ? this.data.slice() : [];
            let targetIndex = nextData.findIndex(function (item) {
              return item ? compare(item[keyField]) : false;
            });

            const normalizedRow = Object.assign(
              {},
              targetIndex > -1 ? nextData[targetIndex] : {},
              rowData,
            );

            if (targetIndex === -1) {
              if (opts.ignoreMissing === true) {
                return Promise.resolve(false);
              }
              if (opts.append === true) {
                nextData.push(normalizedRow);
              targetIndex = nextData.length - 1;
              } else {
                nextData.unshift(normalizedRow);
                targetIndex = 0;
              }
           } else {
              nextData[targetIndex] = normalizedRow;
            }

            this.data = nextData;
            try {
              if (this.instance && typeof this.instance.option === "function") {
                this.instance.option("dataSource", nextData);
                this.instance.refresh();
              }
            } catch (applyErr) {
              console.warn("[SharedGrid] Unable to push row update", applyErr);
            }
            this.notify();
            return Promise.resolve({ index: targetIndex, data: normalizedRow });
          };
        }

        if (typeof sharedEntry.removeRow !== "function") {
          sharedEntry.removeRow = function (options) {
            const opts = options || {};
            const keyField = this.primaryKey;
            const keyValue = opts.key;

            if (keyValue === undefined || keyValue === null) {
              console.warn(
                "[SharedGrid] Missing key when removing row for",
                sharedKey,
              );
              return Promise.resolve(false);
            }

            if (typeof this.ensureLocalData === "function") {
              this.ensureLocalData();
            }

            const filtered = (Array.isArray(this.data) ? this.data : []).filter(
              function (item) {
                if (!item) return true;
                const candidate = item[keyField];
                if (opts.strict === true) {
                  return candidate !== keyValue;
                }
                if (candidate === undefined || candidate === null) {
                  return keyValue !== candidate;
                }
                return String(candidate) !== String(keyValue);
              },
            );

            if (
              filtered.length ===
              (Array.isArray(this.data) ? this.data.length : 0)
            ) {
              return Promise.resolve(false);
            }

            this.data = filtered;
            try {
              if (this.instance && typeof this.instance.option === "function") {
                this.instance.option("dataSource", filtered);
                this.instance.refresh();
              }
            } catch (removeErr) {
              console.warn("[SharedGrid] Unable to remove row", removeErr);
            }
            this.notify();
            return Promise.resolve(true);
          };
        }

        sharedEntry.instance =
          InstancegridProductListP167883E16F8440A68C0E2A5302C36104;

        if (typeof sharedEntry.ensureLocalData !== "function") {
          sharedEntry.ensureLocalData = function () {
            if (Array.isArray(this.data) && this.data.length > 0) {
              return;
            }
            const snapshot = snapshotGridData(this.instance);
            if (snapshot.length > 0) {
              this.data = snapshot;
            }
          };
        }

        const currentSnapshot = snapshotGridData(sharedEntry.instance);
        if (currentSnapshot.length > 0) {
          sharedEntry.data = currentSnapshot;
        }

        sharedEntry.getData = function () {
          return this.data;
        };

        window.hpaSharedGridDataSources[sharedKey] = sharedEntry;
      })();

      // Load DataSource: sp_getProductType
      /*   if ("sp_getProductType" && "sp_getProductType".trim() !== "") {
                loadDataSourceCommon("ProductTypeID", "sp_getProductType", function(data) {
              // Data được shared qua callback
                });
            }

            // Load DataSource: sp_getSupplier
            if ("sp_getSupplier" && "sp_getSupplier".trim() !== "") {
                loadDataSourceCommon("SupplierID", "sp_getSupplier", function(data) {
              // Data được shared qua callback
                });
            } */
      if ("sp_getStatusProduct" && "sp_getStatusProduct".trim() !== "") {
        loadDataSourceCommon("Status", "sp_getStatusProduct", function (data) {
          InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
            "dataSource",
            DataSource_StatusProduct,
          );
        });
      }

      function loadDataSourceCommon(
        columnName,
        dataSourceSP,
        onSuccessCallback,
      ) {
        if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
          console.warn(
            "[loadDataSourceCommon] Missing columnName or dataSourceSP",
          );
          return;
        }

        const dataSourceKey =
          columnName != "Status"
            ? "DataSource_" + columnName
            : "DataSource_StatusProduct";
        // Sử dụng format: columnNameDataSourceLoaded để tương thích với code hiện tại
        const loadedKey = columnName + "DataSourceLoaded";

        // Kiểm tra nếu đã load rồi thì không load lại
        /*  if (window[loadedKey] === true) {
                if (typeof onSuccessCallback === "function") {
                    onSuccessCallback(window[dataSourceKey] || []);
                }
                return;
            } */

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

        AjaxHPAParadise({
          data: {
            name: dataSourceSP,
            param: ["LoginID", LoginID, "LanguageID", LanguageID],
          },
          success: function (res) {
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
              "Instance" +
                columnName.charAt(0).toUpperCase() +
                columnName.slice(1) +
                "P167883E16F8440A68C0E2A5302C36104",
              "Instance" + columnName + "P167883E16F8440A68C0E2A5302C36104",
              "instance" +
                columnName.charAt(0).toUpperCase() +
                columnName.slice(1) +
                "P167883E16F8440A68C0E2A5302C36104",
            ];

            for (let i = 0; i < instanceVariants.length; i++) {
              const instanceKey = instanceVariants[i];

              if (window[instanceKey] || instanceKey) {
                const instanceObj = window[instanceKey] || instanceKey;

                // Kiểm tra nếu đây là dxDataGrid
                if (
                  typeof instanceObj.dxDataGrid === "function" ||
                  (instanceObj.option &&
                    instanceObj.option("dataSource") !== undefined)
                ) {
                  try {
                    // Nếu là Grid, apply dynamic config
                    const gridConfigFn =
                      window[
                        "getGridConfig_" +
                          columnName.charAt(0).toUpperCase() +
                          columnName.slice(1)
                      ];
                    if (typeof gridConfigFn === "function") {
                      const gridConfig = gridConfigFn(window[dataSourceKey]);

                      instanceObj.option(
                        "remoteOperations",
                        gridConfig.remoteOperations,
                  );
                      instanceObj.option(
                        "paging.pageSize",
                        gridConfig.pageSize,
                      );
                      instanceObj.option(
                        "pager.allowedPageSizes",
                        gridConfig.allowedPageSizes,
                      );
                    }

                    instanceObj.option("dataSource", window[dataSourceKey]);
                    break;
                  } catch (e) {
                    console.warn(
                      "[LoadDataSourceCommon] Grid config error:",
                      e,
                    );
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
                  } catch (e) {
                    // Continue to next variant
                  }
                }
              }
            }
          },

          error: function (err) {
            console.error(
              "[loadDataSourceCommon] Failed to load datasource for",
              columnName,
              ":",
              err,
            );
            window[loadedKey] = false;
            if (typeof onSuccessCallback === "function") {
              onSuccessCallback([]);
            }
          },
        });
      }

      window.currentRecordID_ProductID = null;
      window.currentRecordID_Temp_ProductID = null;

      let _pageCache = {};
      let dataStore_GridListProduct = [];
      let _currentKeyword = "";
      async function ReloadData(pageNumber = 1, pageSize = 50) {
        // Load DataSource: sp_getProductType
        if ("sp_getProductType" && "sp_getProductType".trim() !== "") {
          loadDataSourceCommon(
            "ProductTypeID",
            "sp_getProductType",
            function (data) {
              // Data được shared qua callback
            },
          );
        }

        // Load DataSource: sp_getSupplier
        if ("sp_getSupplier" && "sp_getSupplier".trim() !== "") {
          loadDataSourceCommon("SupplierID", "sp_getSupplier", function (data) {
            // Data được shared qua callback
          });
        }
        //let _currentKeyword = "";
        _pageCache = {};

        const gridInstance =
          InstancegridProductListP167883E16F8440A68C0E2A5302C36104;

        function getFilterOption() {
          let value = null;

          $("#stock-filter-productlist .stock-btn.active").each(function () {
            const v = $(this).data("value");
            if (v) value = v;
          });

          return value;
        }

        function normalizeKeyword(text) {
          if (!text) return "";

          let t = String(text);

          if (typeof RemoveToneMarks_Js === "function")
            t = RemoveToneMarks_Js(t);
          else if (t.normalize)
            t = t.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

          return t.replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase().trim();
        }

        dataStore_GridListProduct = new DevExpress.data.CustomStore({
          key: "ProductID",
          load: async function (loadOptions) {
            const take = loadOptions.take || pageSize;
            const skip = loadOptions.skip || 0;
            const curPage = Math.floor(skip / take) + 1;

            const keyword = _currentKeyword;
            const filterOption = getFilterOption();

            const cacheKey = `${curPage}_${take}_${keyword}_${filterOption}`;

            if (_pageCache[cacheKey]) {
              return _pageCache[cacheKey];
            }

            const params = [
              "LoginID",
              window.UserID,
              "LanguageID",
              window.LanguageID,
              "PageNumber",
              curPage,
              "PageSize",
              take,
              "Keyword",
              keyword,
            ];

            if (filterOption) {
              params.push("option", filterOption);
            }
            console.log(params);
            let result = await AjaxHPAParadiseAsync({
              data: {
                name: "sp_WH_GetProductList",
                param: params,
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
              totalCount: totalCount,
            };

            _pageCache[cacheKey] = pageData;

            return pageData;
          },
        });

        gridInstance.beginUpdate();

        gridInstance.option({
          dataSource: dataStore_GridListProduct,

          scrolling: {
            mode: "standard",
            showScrollbar: "onHover",
          },

          remoteOperations: {
            paging: true,
            filtering: true,
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

          /* onOptionChanged: function (e) {

                    if (e.fullName === "searchPanel.text") {

                        _currentKeyword = normalizeKeyword(e.value);

                        _pageCache = {};
                    }
                } */
        });

        gridInstance.endUpdate();
      }

      ReloadData();
      function ClearAllControl() {
        InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
          "disabled",
          false,
        );

        InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
          "value",
          null,
        );
        InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
          "value",
          null,
        );
        InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
          "value",
          null,
        );
        InstanceProductNamePECA1DAA2949E4990A48E870437498233.option(
          "value",
          null,
        );
        InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option("value", null);
        InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option("value", null);
        $("#PF061CC3D4269482DAE3CF6BA5806817F").val("");
        InstanceCostPE6DCBEC1068F4D209A2325579D004887.option("value", null);
        // Reset ID record
        window.isNewProductDraft = false;
        window.currentRecordID_ProductID = null;
        window.currentRecordID_Temp_ProductID = null;
        
        // Reset sạch uploader và mảng cache ảnh
        window._uploadedPaths_PE62E638E2FBB4772BDE9C9525F2DED9D = [];
        window.PathPE62E638E2FBB4772BDE9C9525F2DED9D = "";
        window["DataSource_ProductImage"] = [];
        if (typeof resetFileUploader_PE62E638E2FBB4772BDE9C9525F2DED9D === "function") {
          resetFileUploader_PE62E638E2FBB4772BDE9C9525F2DED9D();
        }
        SetValid("#PECA1DAA2949E4990A48E870437498233", 1);
      }
      function SetValueControl(data) {
        window.isNewProductDraft = false;
        window.currentRecordID_ProductID = data.ProductID;
        window.currentRecordID_Temp_ProductID = data.ProductID;
        InstanceProductTypeIDPF4DF84154877400A85E5EFEAB7677123.option(
          "value",
          data.ProductTypeID,
        );
        InstanceSupplierIDP84157933DC4B44EB86F89E812CA51D6C.option(
          "value",
          data.SupplierID,
        );
        InstanceProductCodeP914E2DFF7C71419AAD600EC0D2FD9FEE.option(
          "value",
          data.ProductCode,
        );
        InstanceProductNamePECA1DAA2949E4990A48E870437498233.option(
          "value",
          data.ProductName,
        );
        InstanceIventoryP14F3D24DB1F4440F8DDB1935FE19215A.option(
          "value",
          data.Iventory,
        );
        InstanceStatusP34FED30C5F294596A5F228581F51FDD9.option(
          "value",
          data.Status,
        );
        $("#PF061CC3D4269482DAE3CF6BA5806817F").val(data.Description);
        InstanceCostPE6DCBEC1068F4D209A2325579D004887.option(
          "value",
          data.Cost,
        );
        // Reset uploader & cache trước khi nạp dữ liệu sản phẩm
        window._uploadedPaths_PE62E638E2FBB4772BDE9C9525F2DED9D = [];
        window.PathPE62E638E2FBB4772BDE9C9525F2DED9D = "";
        if (typeof resetFileUploader_PE62E638E2FBB4772BDE9C9525F2DED9D === "function") {
          resetFileUploader_PE62E638E2FBB4772BDE9C9525F2DED9D();
        }
        
        // Load ảnh sản phẩm từ server khi mở popup edit chuẩn HPA bằng thủ tục sp_GetProductImage
        AjaxHPAParadise({
          data: {
            name: "sp_GetProductImage",
            param: ["LoginID", typeof LoginID !== "undefined" ? LoginID : 0, "IdentityID", data.ProductID]
          },
          success: function (res) {
            try {
              var json = typeof res === "string" ? JSON.parse(res) : res;
              var list = (json.data && json.data[0]) || [];
              window["DataSource_ProductImage"] = list;
            } catch (e) {
              window["DataSource_ProductImage"] = [];
            }
          }
        });
      }
      function SetValidAll() {
        SetValid("#PF4DF84154877400A85E5EFEAB7677123", 1);
        SetValid("#P84157933DC4B44EB86F89E812CA51D6C", 1);
        SetValid("#P914E2DFF7C71419AAD600EC0D2FD9FEE", 1);
        SetValid("#PECA1DAA2949E4990A48E870437498233", 1);
        SetValid("#P14F3D24DB1F4440F8DDB1935FE19215A", 1);
        SetValid("#PF061CC3D4269482DAE3CF6BA5806817F", 1);
        SetValid("#P34FED30C5F294596A5F228581F51FDD9", 1);
        SetValid("#PE6DCBEC1068F4D209A2325579D004887", 1);
      }
      function DeleteTempImagesIfAny() {
        var tempID = window.currentRecordID_ProductID || window.currentRecordID_Temp_ProductID;
        if (tempID && String(tempID).startsWith("sp_")) {
          AjaxHPAParadise({
            data: {
              name: "sp_WH_DeleteTempFileRequest",
              param: ["IdentityID", tempID]
            }
          });
        }
      }

      $("#modalAddProduct").find(".btn-close").off("click.delTemp").on("click.delTemp", function () {
        DeleteTempImagesIfAny();
      });

      $("#modalAddProduct").on("hide.bs.modal", function (e) {
        DeleteTempImagesIfAny();
        SetValidAll();
        ClearAllControl();
      });
      async function ExportTemplateImportProduct() {
        let arrID =
          InstancegridProductListP167883E16F8440A68C0E2A5302C36104.getSelectedRowKeys();

        showLoadingByClassOrID("#sp_WH_ProductList_html", "Xuất dữ liệu");
        //console.log(arg);

        let exportItem = {
          item: "TemplateImportProduct",
          query: "spWH_Export_TemplateImportProduct",
          fileName: "Template_ImportProduct.xlsx",
        };
        let ExportName = exportItem.item;

        try {
          if (!exportItem.fileName) {
            let exportTemp = await AjaxHPAParadiseAsync({
              data: {
                name: exportItem.item,
                param: ["@LoginID", UserID, "@arrID", JSON.stringify(arrID)],
              },
              success: function (resultData) {},
            });

            exportTemp =
              typeof exportTemp === "string"
                ? JSON.parse(exportTemp)
                : exportTemp;
            ExportName =
              exportTemp.data[0][0][
                Object.keys(exportTemp.data[0][0]).find(
                  (x) => x.toLowerCase() == "exportname",
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
                exportItem.fileName,
                "@LoginID",
                UserID,
                "@arrID",
                JSON.stringify(arrID),
              ],
            },
            success: function (resultData) {},
            error: function (xhr, status, error) {},
          });

          let jsonData =
            typeof resultData === "string"
              ? JSON.parse(resultData)
              : resultData;

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
                success: function (resultData) {},
                error: function (xhr, status, error) {},
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
                error: function (xhr, status, error) {},
              });
            }
          }

          HideLoadingByClassOrID("#sp_WH_ProductList_html");
        } catch (error) {
          HideLoadingByClassOrID("#sp_WH_ProductList_html");
          let direction = "up-push";
          let position = "bottom right";

          try {
            let reason = JSON.parse(jsonData.reason);
            reason = Array.isArray(reason) ? reason[0] : reason;
            jsonData.reason = reason.ErrorDetail;
          } catch (jsonError) {}

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
            },
          );
        }
      }
      function parseErrorMessage(rawData) {
        if (!rawData || typeof rawData !== "string") return;

        const lines = rawData.split("\n");

        let errors = [];
        let successes = [];

        lines.forEach((line) => {
          const content = line.trim();
          if (!content) return;

          let message = "";
          const upperContent = content.toUpperCase();
          const trimmed = content.trim();
          if (!trimmed || /^error:$/i.test(trimmed)) {
            return;
          }

          if (upperContent.includes("ERROR")) {
            let message = "";

            if (content.includes("|")) {
              const parts = content.split("|");
              const taxCodeMatch = parts[0].match(/\d+/);
              const taxCode = taxCodeMatch ? taxCodeMatch[0] : "";
              const errorText = parts[1].trim();

              if (errorText != "") {
                message = "<b>%Tax_code%:</b> " + taxCode + " - " + errorText;
              }
            } else {
              message = content
                .replace(/Error:/gi, "")
                .replace(/:/g, "")
                .trim();
            }

            if (message) {
              errors.push(message);
            }
            let cleanSuccess = content.includes("|")
              ? content.split("|")[1].trim()
              : content;
            cleanSuccess = cleanSuccess.replace(/^Success:\s*/i, "");
            successes.push(cleanSuccess);
          }
        });

        let displayMessage = "";

        if (errors.length > 0) {
          displayMessage += "<b>%Failure%:</b><br/>" + errors.join("<br/>");
        }

        return displayMessage;
      }
    })();
    '
    +N' window.isCollapsible_ProductImagePE62E638E2FBB4772BDE9C9525F2DED9D = 0; '
    +(select loadUI from tblCommonControlType_Signed where UID = 'PE62E638E2FBB4772BDE9C9525F2DED9D')
    +(select loadData from tblCommonControlType_Signed where UID = 'PE62E638E2FBB4772BDE9C9525F2DED9D')
    +N'
    // === OVERRIDE: Chỉ cho phép upload 1 ảnh (Truy cập qua DOM element #uploader_ProductImage) ===
    (function checkUploaderPE62E638() {
        var $uploaderEl = $("#uploader_ProductImage");
        if ($uploaderEl.length && $uploaderEl.data("dxFileUploader")) {
            var instance = $uploaderEl.dxFileUploader("instance");
            instance.option("multiple", false);
            instance.option("onValueChanged", function (e) {
                if (e.value && e.value.length > 1) {
                    if (typeof uiManager !== "undefined" && uiManager.showAlert) {
                        uiManager.showAlert({ type: "error", message: "Ch\u1ec9 \u0111\u01b0\u1ee3c t\u1ea3i l\u00ean t\u1ed1i \u0111a 1 h\u00ecnh \u1ea3nh m\u1ed7i l\u1ea7n!" });
                    } else if (typeof DevExpress !== "undefined" && DevExpress.ui && DevExpress.ui.notify) {
                        DevExpress.ui.notify("Ch\u1ec9 \u0111\u01b0\u1ee3c t\u1ea3i l\u00ean t\u1ed1i \u0111a 1 h\u00ecnh \u1ea3nh m\u1ed7i l\u1ea7n!", "error", 3000);
                    }
                    e.component.option("value", [e.value[e.value.length - 1]]);
                }
            });
            $("#dropzone_ProductImage .sub-text")
                .text("Ch\u1ec9 h\u1ed7 tr\u1ee3: 1 h\u00ecnh \u1ea3nh (JPG, JPEG, PNG, GIF, BMP, WEBP)");
        } else {
            setTimeout(checkUploaderPE62E638, 100);
        }
    })();
  </script>
</div>
'

   -- ===================================================================
   -- CHỐNG LỖI CỐT LÕI (ROOT CAUSE: "Identifier 'colName' has already been declared")
   -- Cơ chế Stale-While-Revalidate của Paradise Web Client re-inject script vào cùng DOM/Window.
   -- Các biến top-level trong signed common control khai báo bằng const/let sẽ gây vỡ toàn trang.
   -- Chuẩn hóa thành var để trình duyệt cho phép redeclaration an toàn tuyệt đối 100%.
   -- ===================================================================
   SET @html = REPLACE(@html, 'const colName = ', 'var colName = ');
   SET @html = REPLACE(@html, 'const $containerPE62E638', 'var $containerPE62E638');
   SET @html = REPLACE(@html, 'let instancUploaderPE62E638', 'var instancUploaderPE62E638');
   SET @html = REPLACE(@html, 'let timeOutSavePE62E638', 'var timeOutSavePE62E638');
   SET @html = REPLACE(@html, 'const BlobCache_PE62E638', 'var BlobCache_PE62E638');
   SET @html = REPLACE(@html, 'const Base64Cache_PE62E638', 'var Base64Cache_PE62E638');
   SET @html = REPLACE(@html, 'let _observer_PE62E638', 'var _observer_PE62E638');
   SET @html = REPLACE(@html, 'const PreviewCache_PE62E638', 'var PreviewCache_PE62E638');
   SET @html = REPLACE(@html, 'let activeBlobUrl', 'var activeBlobUrl');
   SET @html = REPLACE(@html, 'let _localData_PE62E638', 'var _localData_PE62E638');
   SET @html = REPLACE(@html, 'const uploaderConfigPE62E638', 'var uploaderConfigPE62E638');
   SET @html = REPLACE(@html, 'let InstanceProductImagePE62E638', 'var InstanceProductImagePE62E638');

   SELECT @html AS html;

GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_WH_ProductList]
-- ===================================================================
IF OBJECT_ID('dbo.sp_WH_ProductList', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_WH_ProductList AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [dbo].[sp_WH_ProductList](
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
    WHERE TableName = 'sp_WH_ProductList'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE & CẬP NHẬT VERSION
-- ===================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_WH_ProductList_html', 'VN', 'sp_WH_ProductList';
    EXEC sp_GenerateHTMLScript_new 'sp_WH_ProductList_html', 'EN', 'sp_WH_ProductList';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_WH_ProductList_html';
END
GO
