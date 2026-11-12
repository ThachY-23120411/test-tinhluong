
   $(() => {
    $("#reloadData").off("click").on("click", function(){
       getDetailedRequest_api()
    })

    var registereds = [];
    var allRegisters = []; // mảng dữ liệu load sẵn 1 lần
   var batchSize = 10;    // số card hiển thị mỗi lần
   var currentIndex = 0;
    var cbxApprovalGroupList = [];
    var cbxApproveStatusList = [];
    var cbxEmployeeList = [];
    var grouplist = -1;
    var defaultFormData = {
       Employees: [],
       FromDate: null,
       ToDate: null,
       Approve_Status : null,
       Approvalgrouplist_param: grouplist
    };
        var panel = document.querySelector('.filter-panel');
       if (document.documentElement.getAttribute("data-bs-theme") == "dark") {
         panel.style.background = "#1e1e1e";
         panel.style.color = "#fff";
         panel.style.borderColor = "#444";
       } else {
         panel.style.background = "white";
         panel.style.color = "#000";
         panel.style.borderColor = "#ccc";
       }

    $('#filter-button').on('click', function () {
       $('#filter-panel').slideToggle(400, () => {});
     });
     // Đóng panel

     $('#close-filter').on('click', function () {
       $('#filter-panel').slideUp();
     });
    $("#filter-body").dxForm({
       formData: {...defaultFormData},
       labelLocation: "top",
       colCountByScreen: {
           xs: 2,
           sm: 2,
           md: 2,
           lg: 2
       },
       items: [
           {
               dataField: "FromDate",
               editorType: "dxDateBox",
               colSpan: 1,
               label: {
                   text: "Từ ngày",
       visible: false
               },
               editorOptions: {
                   pickerType: "rollers",
                   displayFormat: "dd/MM/yyyy",
               dropDownOptions: {
                       title: "Từ ngày"
                   },
                   labelMode: "static"
               }
           },
           {
       dataField: "ToDate",
               editorType: "dxDateBox",
               colSpan: 1,
               label: {
                   text: "Đến ngày",
                   visible: false
               },
               editorOptions: {
                   pickerType: "rollers",
                   displayFormat: "dd/MM/yyyy",
                   dropDownOptions: {
                       title: "Đến ngày"
                   },
                   labelMode: "static"
               }
           },
     {
               dataField: "Employees",
               editorType: "dxDropDownBox",
               colSpan: 2,
               label: {
                   text: "nhân viên",
                   visible: false
               },
               editorOptions: {
                   displayExpr: function (selectedItems) {
                       if (!Array.isArray(selectedItems)) {
                           selectedItems = [selectedItems];
                       }

                       const names = selectedItems.map(emp => emp?.FullName || "").filter(name => !!name);
                       return names.join(", ");
                   },
                   valueExpr: "EmployeeID",
                   labelMode: "static",
                   contentTemplate: function (e) {
                       const $list = $("<div>").dxList({
                           showSelectionControls: true,
      dataSource: cbxEmployeeList,
                           keyExpr: "EmployeeID",
                           displayExpr: "FullName",
                           valueExpr: "EmployeeID",
                           searchEnabled: true,
                           searchExpr: ["FullName", "EmployeeID"],
                           selectionMode: "multiple",
                           showSelectAll: true,
                           selectedItemKeys: e.component.option("value") || [],
                           onSelectionChanged: function (args) {
                               let selectedIDs = args.component.option("selectedItemKeys");
                e.component.option("value", selectedIDs);
                           },
                           onItemClick: function () {
                           },
                           height: 300
                       });
                       return $list;
                   }
               }
           },
       {
               dataField: "Approve_Status",
               editorType: "dxDropDownBox",
    colSpan: 2,
            label: {
                   text: "Trạng thái",
                   visible: false
               },
               editorOptions: {
                   displayExpr: "Description",
                   valueExpr: "Approve_Status",
                   labelMode: "static",
                   contentTemplate: function (e) {
                       const $list = $("<div>").dxList({
                           dataSource: cbxApproveStatusList,
                           displayExpr: "Description",
                           selectionMode: "single",
                           selectedItemKeys: [e.component.option("value")],
                         onItemClick: function (args) {
                               e.component.option("value", args.itemData.Approve_Status);
                               e.component.close();
                           }
                       });
                       return $list;
                   }
               }
           },
           {
               dataField: "Approvalgrouplist_param",
               editorType: "dxRadioGroup",
               colSpan: 2,
               label: {
                   text: "Loại đăng ký"
               },
               editorOptions: {
     dataSource: cbxApprovalGroupList,
                   displayExpr: "Content",
                   valueExpr: "Approvalgrouplist_param",
                   labelMode: "static",
                   contentTemplate: function (e) {
                       const $list = $("<div>").dxList({
                           dataSource: cbxApprovalGroupList,
                           displayExpr: "Content",
                           selectionMode: "single",
                           selectedItemKeys: [e.component.option("value")],
                           onItemClick: function (args) {
                               e.component.option("value", args.itemData.Approvalgrouplist_param);
                               e.component.close();
                           }
                       });
                       return $list;
                   }
               }
           },
           {
               itemType: "button",
               colSpan: 1,
               buttonOptions: {
                   text: "Thiết lập lại",
                   type: "normal",
                   elementAttr: {
        class: 'w-100 text-success mt-2',
                   },
                   onClick: function () {
                       var formInstance = $("#filter-body").dxForm("instance");
                       formInstance.option("formData", { ...defaultFormData });;
                   }
               }
           },
           {
               itemType: "button",
               colSpan: 1,
               buttonOptions: {
                   text: "Áp dụng ",
                   elementAttr: {
        class: 'w-100 bg-success mt-2',
                   },
                   type: "default",
                   onClick: onClickFilter
               }
           }
       ]
   });
   // Khởi tạo ScrollView

   $("#scrollView").dxScrollView({
       scrollByContent: true,
       scrollByThumb: true,
       //height: "100%",

       showScrollbar: 'onScroll',
       reachBottomText: 'Đang tải......',
       onReachBottom: function(e) {
         setTimeout(() => {
            console.log('Đã scroll tới đây');
            renderNextBatch();
            e.component.release()
         },500)
       }
   });
    initAPI();
    async function initAPI() {
       //showLoadingByClassOrID("#list-to-review", "Đang tải...", "Black", "Black");

       if(sp_List_To_Review_param.DataParam && sp_List_To_Review_param.DataParam != '')

       {
           $("#filter-body").dxForm("instance").option("formData",JSON.parse(sp_List_To_Review_param.DataParam))
       }

       await getEmployeeList()

       await getDetailedRequest_api()

        HideLoadingByClassOrID("#sp_List_To_Review")
    }

    async function getEmployeeList(){
       let selectBox = $("#filter-body").dxForm("instance").getEditor("Employees");
     await AjaxHPAParadiseAsync({
     data: {
      name: "sp_EmployeeIDFullName",
      param: ["LanguageID",LanguageID]
     },
     success: function (e) {
      result = JSON.parse(e).data

      cbxEmployeeList = result[0];
      selectBox.option("dataSource", cbxEmployeeList);
      cbxApproveStatusList = result[1];
      $("#filter-body").dxForm("instance").getEditor("Approve_Status").option("dataSource", cbxApproveStatusList);
      cbxApprovalGroupList = result[2];
      $("#filter-body").dxForm("instance").getEditor("Approvalgrouplist_param").option("dataSource", cbxApprovalGroupList);
      //$("#ltr-title").text(cbxApprovalGroupList.find(item => item.Approvalgrouplist_param === $("#filter-body").dxForm("instance").getEditor("Approvalgrouplist_param").option("value")).Content);
    }})}

    async function getDetailedRequest_api() {
    sp_List_To_Review_param.DataParam = JSON.stringify($("#filter-body").dxForm("instance").option("formData"))

    var selectBoxInstance = $("#filter-body").dxForm("instance").getEditor("Approvalgrouplist_param");
    var selectedValue = selectBoxInstance.option("value");
    if(cbxApprovalGroupList.length != 0)

    {
       $("#ltr-title").text(cbxApprovalGroupList.find(item => item.Approvalgrouplist_param === selectedValue).Content);
    }

    console.log("Dữ liệu grouplist: ", grouplist)

    await AjaxHPAParadiseAsync({
      data: {
       name: "api_getRegistereds",
       param: ["LoginID", LoginID,
        "LanguageID", LanguageID,
        "Group", grouplist,
        "Approve_Status", $("#filter-body").dxForm("instance").option("formData").Approve_Status,
        "FromDate", $("#filter-body").dxForm("instance").option("formData").FromDate,
        "ToDate", $("#filter-body").dxForm("instance").option("formData").ToDate,
        "Employees", JSON.stringify($("#filter-body").dxForm("instance").option("formData").Employees)
        ]
      },
      success: function (result) {
       let parsedResult = JSON.parse(result);
       allRegisters  = parsedResult.data[0];
           //getRegisterCard(registereds)

           if(allRegisters.length == 0 || !allRegisters)

           {
               $('#cardregistered').empty()

                $('#cardregistered').append(`<p class="text-danger">Không có dữ liệu</p>`);
           }

           currentIndex = 0

           renderNextBatch(false)
      },
      error: function (error) {
       console.error("Error fetching leave types:", error);
      }
     });
    }

   function onClickFilter() {
       grouplist = $("#filter-body").dxForm("instance").option("formData").Approvalgrouplist_param;
       getDetailedRequest_api()

       $('#filter-panel').slideUp();
    }

    function getAvatar(photo, employeeId) {
     return photo
   ? `<img data-employee-id="${employeeId}" class="request-avatar-img">`
      : `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-person request-avatar-img" viewBox="0 0 16 16">
       <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0m4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4m-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10s-3.516.68-4.168 1.332c-.678.678-.83 1.418-.832 1.664z"/>
        </svg>`;
    }

   function renderNextBatch(flag = true) {
       var scroll = $("#scrollView").dxScrollView("instance")

       if (currentIndex >= allRegisters.length)

       {
          scroll.release(true);
          return; // hết dữ liệu
       }

           scroll.release(false);
           scroll.option("reachBottomEnabled", true);
       let nextBatch = allRegisters.slice(currentIndex, currentIndex + batchSize);
       getRegisterCard(nextBatch, flag); // append = true
       currentIndex += batchSize;
       if(currentIndex >= allRegisters.length)

       {
          scroll.release(true);
       }
   }

   // Hàm getRegisterCard đã chỉnh sửa để hỗ trợ append

   function getRegisterCard(registers, append = false) {
       if (!append) $('#cardregistered').empty();
       let html = "";
       registers.forEach(item => {
           var html_await_approve ="";
           var checkPhotoImage = item.PhotoImage

           var checkParamImg = item.paramImg

           if(checkParamImg){
               checkParamImg = decodeURIComponent(checkParamImg);
               var match = checkParamImg.match(/"FilePath"\s*,\s*"([^"]+)"/i);
               if (match) {
                   checkParamImg = match[1];
               }
           }

           var linkimg = checkPhotoImage

               ? checkPhotoImage

               : checkParamImg

           let timeago

           var checkCreateTime = item.CreateTime

           var checkChangeDate = item.ChangeDate

           if(checkCreateTime){
               timeago = timeAgo(checkCreateTime);
           } else if (checkChangeDate){
               timeago = timeAgo(checkChangeDate);
           }

           var checkApprove_Status = item.Approve_Status

  if(checkApprove_Status){
checkApprove_Status = checkApprove_Status >= 4 ? "text-danger" : "text-success"
           }else if (item.GroupList){
                html_await_approve = `<div class="d-flex justify-content-end"><div class="thisApproved-btn">Chờ duyệt</div></div>`;
           }

        var checkGroupList = item.GroupList

           var checkChangeDescription = item.Description

           if (checkGroupList){
               checkGroupList = checkGroupList ? cbxApprovalGroupList.find(e => e.Approvalgrouplist_param === item.GroupList).Content : ""
           } else if(checkChangeDescription){
               checkGroupList = checkChangeDescription || ""
           }

           var checkRemark = item.Remark ?? "";
           var checkGroupList_code = item.GroupList ? item.GroupList : 9

           var checkIdentity_ID

           if(checkGroupList_code === 9){
               checkIdentity_ID = item.EmployeeID
           } else{
               checkIdentity_ID = item.Identity_ID
           }

           html += `<div class="card getcardregisteredOA" data-value="${checkIdentity_ID}" data-group="${checkGroupList_code}">
                       <div class="card-body">
                           <div class="employee align-items-center gap-3">
                               ${getAvatar(linkimg, item.EmployeeID)}

                               <div>
               <h5>${item.FullName}</h5>
                <p>${item.EmployeeID} - ${timeago}</p>
                               </div>
      </div>
                           <div class="cardcontent">
                        <div class="${checkApprove_Status}">
                                   ${checkGroupList}

                               </div>
                               <div>${checkRemark}</div>
                           </div>
                           ${viewStatusApprove(item.Approve_Status)}

                           ${html_await_approve}

                       </div>
                    </div>`;
       });
       $('#cardregistered').append(html);
       LoadImageCardregistered();
   }

    function viewStatusApprove(approveStatus) {
     switch (approveStatus) {
      case 2:
       return `<div class="d-flex justify-content-end"><div class="approved-btn">Đã duyệt</div></div>`

      case 1:
      case 5:
       return `<div class="d-flex justify-content-end"><div class="thisApproved-btn">Chờ duyệt</div></div>`

      case 3:
       return `<div class="d-flex justify-content-end"><div class="rejected-btn">Từ chối</div></div>`

      case 4:
       return `<div class="d-flex justify-content-end"><div class="request-draft-btn">Hủy thành công</div></div>`

      default: return ``;
     }
    }

    function setEventClickCard() {
           $(document).off('click', '.getcardregisteredOA'); // Gỡ sự kiện cũ
           $(document).on('click', '.getcardregisteredOA', function () {
               ApproveList_WebidentityID = $(this).data('value');
               group = $(this).data('group');
               console.log(ApproveList_WebidentityID,group)

               switch (group) {
                   case 1:
                       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_ResignationLeave`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       } else {
                           openFormParam(`sp_ResignationLeave`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                  }

                       break;
                   case 4:
                       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_ApplicationForExpenses_Mobile`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
} else {
 openFormParam(`sp_ApplicationForExpenses_Mobile`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       }

                       break;
                   case 5:
       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_MakeupHours`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       } else {
                           openFormParam(`sp_MakeupHours`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       }

                       break;
                   case 6:
                 if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_overtime_assignment`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       } else {
                           openFormParam(`sp_overtime_assignment`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       }

                       break;
                   case 8:
                       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_ResignationLetter_Register`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       } else {
                         openFormParam(`sp_ResignationLetter_Register`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       }

                      break;
                   case 9:
                       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_EmployeeChange_Detail`, { LoginID: LoginID, EmployeeID: `${ApproveList_WebidentityID}`, LanguageID: LanguageID });
                       } else {
                           openFormParam(`sp_EmployeeChange_Detail`, {  LoginID: LoginID, EmployeeID: `${ApproveList_WebidentityID}`, LanguageID: LanguageID});
                       }

                      break;
                    case 10:
                       if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                           OpenFormParamMobile(`sp_CRM_SalesApproved`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       } else {
                           openFormParam(`sp_CRM_SalesApproved`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${ApproveList_WebidentityID}` });
                       }

                      break;
               }
           });
       }

    setEventClickCard();
    //Hàm bổ trợ

    function getAvatarApprover(photo) {
     return photo

      ? `<img src="data:image/jpeg;base64,${photo}">`

      : `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-person" viewBox="0 0 16 16">
       <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0m4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4m-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10s-3.516.68-4.168 1.332c-.678.678-.83 1.418-.832 1.664z"/>
        </svg>`;
    }

    function formatTimeToHHmm(input) {
     const date = new Date(input);
     if (date instanceof Date && !isNaN(date)) {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
     } else {
      return null;
     }
    }

    function formatDate(date) {
      let year = date.getFullYear();
      let month = String(date.getMonth() + 1).padStart(2, "0");
      let day = String(date.getDate()).padStart(2, "0"
      );
      let hours = String(date.getHours()).padStart(2, "0");
      let minutes = String(date.getMinutes()).padStart(2, "0");
      return `${day}/${month}/${year}`;
      }

      function setTimeFromString(dateInput,stringTime) {
      if (!(dateInput instanceof Date)) {
       console.log("Tham số phải là một đối tượng Date.");
      }

      // Phân tích chuỗi thời gian "hh:mm:ss"

      var [hours, minutes, seconds] = stringTime.split(":").map(Number);
      // Gán giờ, phút, giây vào đối tượng Date

      dateInput.setHours(hours, minutes, seconds, 0); // milliseconds = 0
      return dateInput;
     }

     function formatToDDMMYYYY(dateString) {
       let date = new Date(dateString);
       let day = String(date.getDate()).padStart(2, "0");
       let month = String(date.getMonth() + 1).padStart(2, "0"); // Tháng bắt đầu từ 0
       let year = date.getFullYear();
       return `${day}/${month}/${year}`;
    }

    function removeVietnameseTones(str) {
       return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/d/g, "d").replace(/D/g, "D");
       }

    function timeAgo(input) {
      if(input == null) return ``;
     var inputDate = new Date(input);
     var now = new Date();
     var past = new Date(inputDate);
     var seconds = Math.floor((now - past) / 1000);
     var lang = [
         "giây trước",
         "phút trước",
         "giờ trước",
         "ngày trước",
         "tháng trước",
         "năm trước"
     ];
     if (seconds < 60) {
      return `${seconds} ${lang[0]}`;
     }

     let minutes = Math.floor(seconds / 60);
     if (minutes < 60) {
      return `${minutes} ${lang[1]}`;
     }

     let hours = Math.floor(minutes / 60);
     if (hours < 24) {
      return `${hours} ${lang[2]}`;
     }

     let days = Math.floor(hours / 24);
     if (days < 30) {
      return `${days} ${lang[3]}`;
     }

     let months = Math.floor(days / 30);
     if (months < 12) {
      return `${months} ${lang[4]}`;
     }

     let years = Math.floor(months / 12);
     return `${years} ${lang[5]}`;
    }

       async function LoadImageCardregistered()
       {
           if($("#cardregistered img[src=''], #cardregistered img:not([src])").length === 0) return

          $("#cardregistered img[src=''], #cardregistered img:not([src])").each(function() {
               let self = $(this)
               let employeeId = self.attr("data-employee-id");
               if (!employeeId || employeeId.length === 0 || employeeId === 'null' || employeeId === 'undefined') {
                   return;
               }
               let name = "paradisefile_sp_GetFileAPI_profile";
               let param = ["EmployeeID", employeeId];
               self.removeAttr("_name");
               self.removeAttr("_param");
               AjaxHPAParadise({
                   data: { name: name, param: param},
                   xhrFields: { responseType: "blob" },
                   success: function (blob, status, xhr) {
                       if (blob && blob.size > 0) {
                           try {
                               var url = URL.createObjectURL(blob);
                               self.attr("src", url);
                           } catch(e) {}
                       }
                   }
               })
           });
       }
    })

   