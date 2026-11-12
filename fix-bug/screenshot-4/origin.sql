/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-4
  MÀN HÌNH / MENU    : Chấm công -> Đăng ký tăng ca (MnuPRL103)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[sp_Overtime_Assignment_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_Overtime_Assignment_html]
(@LoginD int =3, @LanguageID varchar(4) = 'vn')
as
	declare @html nvarchar(max) = '', @Empty nvarchar(max) = ''
    set @html = N'<style>

  /* === [TASK #7339] ĐỒNG BỘ WIDTH KHUNG 768PX THEO CHUẨN XIN BÙ CÔNG (sp_MakeupHours) === */
  #sp_Overtime_Assignment,
  #sp_Overtime_Assignment .menu-tabs,
  #sp_Overtime_Assignment .tab-content,
  #sp_Overtime_Assignment .container-fluid,
  #sp_Overtime_Assignment .container-md,
  #sp_Overtime_Assignment .container {
      max-width: 768px !important;
      margin-left: auto !important;
      margin-right: auto !important;
  }

  #sp_Overtime_Assignment .dx-gridbase-a11y-status-container {
    display: none;
  }
  #sp_Overtime_Assignment .qlrl-otMessError {
    font-size: 13px;
  }
  #sp_Overtime_Assignment .tab-content {
   display: none;
  }

   #sp_Overtime_Assignment .tab-content.active {
    display: block;
  }
  #sp_Overtime_Assignment .menu-tabs {
            display: flex;
            border-bottom: 1px solid #f1f5f9;
            margin-bottom: 16px;
        }

     #sp_Overtime_Assignment .menu-tab {
        padding: 12px 40px;
        font-size: 0.9rem;
        font-weight: 500;
        color: #64748b;
        border-bottom: 2px solid transparent;
        cursor: pointer;
        transition: all 0.2s ease;
    }

     #sp_Overtime_Assignment .menu-tab.active {
        color: #00673b;
        border-bottom-color: #00673b;
    }

</style>
<div id="sp_Overtime_Assignment">

<div class="menu-tabs d-flex align-items-center justify-content-center">
 <div style="font-size: 16px;width: 70px;" class="menu-back" onclick="BackToHome()"><i class="bi bi-arrow-left"></i></div>
    <div class="menu-tab active" data-tab="RegisterOTRequest">%MnuWPT316%</div>
    <div class="menu-tab" data-tab="HistoryOTRequest">Lịch sử</div>
 </div>
<div class="tab-content active" id="RegisterOTRequest-tab">
  <div class="container-fluid container-md">

    <div class="row mt-3">
       <div id="infoRequest" class="col-12">
           <div class="d-flex align-items-center gap-3">
                            <img class="request-avatar-img" src="">
                                            <div class="heheeh">
                            <h5 class="card-title">Loadding...</h5>
                            <div class="d-flex align-items-center gap-1">
                    <p class="employeeid-badge-green text-success bg-success bg-opacity-10 rounded-pill d-inline-block mt-1 mb-1"></p>
                </div>
                </div>
           </div>
       </div>
      <div class="col-12 mb-2">
        <label class="mb-2">%@AttDate%</label>
        <div id="qlrl-dxOTFromDate" class="mb-2"></div>
        <div class="invalid-feedback"></div>
      </div>
      <div class="col-6 mb-2">
        <label for="qlrl-OTCategoryID" class="form-label"
          >%TypeRequest%(<span class="text-danger">*</span>)</label
        >
        <select
          class="form-select"
          id="qlrl-OTCategoryID"
          name="qlrl-OTCategoryID"
        >
          <option value="-1"></option>
        </select>
        <div class="invalid-feedback mt-1"></div>
      </div>
      <div class="col-6 mb-2">
        <label for="qlrl-ShiftCodeOT" class="form-label">%lblShift%</label>
        <select
          class="form-select"
          id="qlrl-ShiftCodeOT"
          name="qlrl-ShiftCodeOT"
        >
          <option value="-1"></option>
        </select>
      </div>
      <div class="col-6 mb-2">
        <label for="qlrl-OTType" class="form-label"
          >%BenefitsInsDetailID%(<span class="text-danger">*</span>)</label
        >
        <select
          class="form-select"
          id="qlrl-OTType"
          name="qlrl-OTType"
        ></select>
      </div>
      <div class="col-6 mb-2">
       <!-- <label for="qlrl-OTValue" class="form-label"
          >%otnew.OTType%(<span class="text-danger">*</span>)</label
        >
        <select
          class="form-select"
          id="qlrl-OTValue"
          name="qlrl-OTValue"
        ></select> -->
      </div>
      <div class="col-4">
        <label class="mb-2">%FromTime%(<span class="text-danger">*</span>)</label>
        <div id="qlrl-OTFrom" class=""></div>
        <div class="mt-1 invalid-feedback"></div>
      </div>
      <div class="col-4">
<label class="mb-2">%lbl@otto%(<span class="text-danger">*</span>)</label>
        <div id="qlrl-OTTo"></div>
        <div class="mt-1 invalid-feedback"></div>
      </div>
      <div class="col-4">
        <label class="mb-2">%colLeaveHours%(<span class="text-danger">*</span>)</label>
        <input class="form-control" type="number" id="qlrl-OTHour" />
        <div class="mt-1 invalid-feedback"></div>
      </div>
      <div class="input-group col-12 mt-2">
        <label class="mb-2">%colContent%(<span class="text-danger">*</span>)</label>
        <textarea
          id="qlrl-NoteOT"
          style="height: 105px; width: 100%"
          class="form-control"
          id="qlrl-dxOTType"
          aria-label="With textarea"
        ></textarea>
        <div class="invalid-feedback mt-1"></div>
      </div>

      <div class="d-flex justify-content-end mt-3">
        <button class="btn btn-success" id="btnAddRequestOT" style="width: 50%">%otnew.AddtoList%</button>
      </div>
    </div>

    <div id="qlrl-dxDataGridOT" class="mt-2"></div>
     <input type="file" id="qlbeta-fileForOT" multiple style="display: none;" />
     <div class="mt-3" id="qlbeta-customchosefileOT"></div>
     <div class="mt-3" id="filePreviewContainer"></div>
    <label class="mt-4">Quá trình duyệt</label>
    <div class="timeline" id="timelineApprover">
        <div class="timeline-step me-2">
                <div class="circle gray">
                    <img>
                </div>
                <div class="name">Loading...<br><br><small></small></div>
                <div style="max-width: 133px;" class="text-wrap"></div>
            </div>

    </div>
     <div class="d-flex justify-content-evenly">
          <button style="width: 90%" class="btn btn-success btnRegister">%SubmitRequest%</button>
          <button style="width: 90%" class="btn btn-danger d-none btnDestroy">%Overtime_Assignment.lblOT_Assignment_Cancel%</button>
          <button style="width: 40%" class="btn btn-success d-none btnApprove">%Approve%</button>
          <button style="width: 40%" class="btn btn-danger d-none btnReject">%Deny%</button>
     </div>
      </div>
    </div>
    <div id="HistoryOTRequest-tab" class="tab-content">
        <div class="container">
            <div id="OTHistoryList"></div>
        </div>
    </div>

     <div class="modal fade shadow" id="modalApproveRemakeForOT" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                  <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                      <div class="modal-body">
                  <div class="mb-3">
                    <label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>

                    <textarea class="form-control" id="approveRemakeForOT" rows="3" style="height: 127px"></textarea>
                    <div class="invalid-feedback mt-1"></div>
                    </div>

                      </div>
                    <div class="modal-footer">
                        <button type="button" class="btn" id="btnActionModalRemakeOT">%Approved%</button>
                        <button type="button" class="btn btn-secondary" id="btnCloseModalRe">%btnClose%</button>
                    </div>
                </div>
                </div>
            </div>
           </div>


<script>
  $(() => {
    var FileSelected = []
    var EmployeeID = EmployeeID_Login;
    var otKind, otHour;
    var IdentityID = '''';
    var lastValue = null;
    var QLRLdxOTFromDate, QLRLdxOTToDate; //2 cái datebox
    var qlrlDivLogMess = $(''#qlrl-otMessError'');
    var FlagOTFromChangeEvent = true;
    var FlagOTToChangeEvent = true;
    var FlagOTDateChangeEvent = true;
    var onRowClick = true
   $("#sp_Overtime_Assignment .menu-tab").each(function () {

        $(this).off("click").on("click", function () {
            var target = $(this).attr("data-tab");

            // Remove active trên tất cả tab
            $("#sp_Overtime_Assignment .menu-tab").removeClass("active");

            // Add active cho tab đang click
            $(this).addClass("active");

            // Nếu là 2 tab này thì active tab-content
            if (target === "RegisterOTRequest" || target === "HistoryOTRequest") {
                $("#sp_Overtime_Assignment .tab-content").removeClass("active");
                $(`#${target}-tab`).addClass("active");
                //$(`#${target}-tab`).removeClass("d-none");
            }



            // Xử lý HistoryOTRequest
            if (target === "HistoryOTRequest") {
                console.log("history");
                    getHistoryOT(IdentityID)
                // showLoadingByClassOrID("#sp_Overtime_Assignment");
                // if(IsRegisterExp){
                //     LoadRegisterHistory()
                // }
                // else{
                //     LoadHistoryByIdentityID()
                // }
            }
        });
   });

    function qlrlOTLoadAction() {
      QLRLdxOTFromDate = $(''#qlrl-dxOTFromDate'')
        .dxDateBox({
          type: ''date'',
          displayFormat: ''dd/MM/yyyy'',
          //value: new Date(),
          pickerType: ''calendar'',
          useMaskBehavior: true,
          inputAttr: { ''aria-label'': ''Date Time'' },
          onValueChanged: async function (e) {
            if (!FlagOTDateChangeEvent) return;
            var data = await ChangeDxDateBoxOTDate(
              formatDateSQL(e.value),
              formatDateSQL(e.value)
            );

            var OTData = data[0];
            var OTErrorMess = data[1];
            if (OTErrorMess.length != 0) {
              //console.log(OTErrorMess)
             SetInvalid(''#qlrl-dxOTFromDate'', OTErrorMess[0].ErrorDetail, 1);
              DisabledAll();
              return;
            }
            EnabledAll();
            SetValid(''#qlrl-dxOTFromDate'', 1);
            await SetValueFromOTData(OTData[0]);
            $(''#qlrl-OTCategoryID'').trigger(''change'');
            $(''#qlrl-NoteOT'').trigger(''input'');
            //console.log(data)
          },
        })
        .dxDateBox(''instance'');

      QLRLdxOTFrom = $(''#qlrl-OTFrom'')
        .dxDateBox({
          type: ''time'',
          displayFormat: ''HH:mm'',
          value: new Date(),
          pickerType: ''list'',
          useMaskBehavior: true,
          inputAttr: { ''aria-label'': ''Date Time'' },
          onValueChanged: async function (e) {
            if (!FlagOTFromChangeEvent) return;
            await QLRLLogMess();
            //await QLRLLogMess("#qlrl-OTTo")
            await CaculalorHour();
            $(''#qlrl-OTHour'').val(otHour);
            $(''#qlrl-OTHour'').trigger(''change'');
          },
        })
        .dxDateBox(''instance'');
      QLRLdxOTTo = $(''#qlrl-OTTo'')
        .dxDateBox({
          type: ''time'',
          displayFormat: ''HH:mm'',
          value: new Date(),
          pickerType: ''list'',
          useMaskBehavior: true,
         inputAttr: { ''aria-label'': ''Date Time'' },
          onValueChanged: async function (e) {
            if (!FlagOTToChangeEvent) return;
            await QLRLLogMess();
            //await QLRLLogMess("#qlrl-OTTo")
            await CaculalorHour();
            $(''#qlrl-OTHour'').val(otHour);
            $(''#qlrl-OTHour'').trigger(''change'');
          },
        })
        .dxDateBox(''instance'');

      QLRLdxDataGridOT = $(''#qlrl-dxDataGridOT'')
        .dxDataGrid({
          dataSource: [],
          width: ''100%'',
          keyExpr: ''DetailID'',
          //focusedRowEnabled: true,
          focusedRowIndex: 0,
          allowColumnReordering: false,
          columnAutoWidth: true,
          columnResizingMode: ''widget'',
          height: 300,
          scrolling: {
            scrollByThumb: true,
            useNative: true,
      },
          searchPanel: {
            visible: false,
            width: 300,
            placeholder: '''',
          },
          selection: {
            mode: ''single'',
          },
          accessibility: {
            enable: false,
          },

          editing: {
            startEditAction: ''click'',
            confirmDelete: false,
          },

          columnAutoWidth: true,
          onRowClick: function (e) {
            if(!onRowClick)
            {
                return
            }
            SetValueControlOTDetail(e.data);
          },
          columns: [
            //{ dataField: "EmployeeID", caption: "Mã", alignment: "left", width: "auto",allowEditing: false},
            //{ dataField: "FullName", caption: "Họ tên", alignment: "left",  width: "auto",allowEditing: false   },
            //{ dataField: "SectionName", caption: "Phòng ban", alignment: "left",  width: "auto",allowEditing: false   },
            {
              dataField: ''OTDate'',
              caption: ''Ngày'',
              alignment: ''left'',
              format: ''dd/MM/yyyy'',
              dataType: ''date'',
              width: ''auto'',
              allowEditing: false,
           },
            {
              dataField: ''ShiftCode'',
              caption: ''Ca'',
              alignment: ''left'',
              width: ''auto'',
              allowEditing: false,
            },
            {
              dataField: ''OTCategoryID'',
              caption: ''Loại đơn'',
              alignment: ''left'',
              width: ''auto'',
              allowEditing: false,
            },
            {
              dataField: ''OTType'',
              caption: ''Chế độ'',
              alignment: ''left'',
     width: ''auto'',
              allowEditing: false,
            },
            {
              dataField: ''OTFrom'',
              caption: ''Từ'',
              format: ''HH:mm'',
              dataType: ''datetime'',
              allowEditing: true,
              alignment: ''left'',
              width: 120,
            },
            {
              dataField: ''OTTo'',
              caption: ''Đến'',
              format: ''HH:mm'',
              dataType: ''datetime'',
              alignment: ''left'',
              allowEditing: true,
              width: 120,
            },
            {
              dataField: ''OTHour'',
              caption: ''Số giờ'',
              alignment: ''left'',
              width: ''auto'',
              allowEditing: false,
  },
            {
              dataField: ''Note'',
              caption: ''Ghi chú'',
              alignment: ''left'',
              width: ''auto'',
              allowEditing: false,
            },
            {
              type: ''buttons'',
              name: "deleteBtn",
              buttons: [
                {
                  hint: ''Xóa'',
                  icon: ''trash'',
                  onClick: function (e) {
                showConfirmPopup({
                        title: "%Notification%",
                        message: "%Common_Confirm_DeleteTitle%!",
                        YesText: "%Yes%",
                        NoText: "%No%",
                        onYes: function() {
                             ApiDeleteOTDetail(e.row.data.DetailID);
                        }
                    });
                  },
                },
              ],
            },
          ],
        })
        .dxDataGrid(''instance'');
    }
    var IsRegister = true
    async function initOT() {
      qlrlOTLoadAction();
      HideLoadingByClassOrID("#sp_Overtime_Assignment")
      //ch?y l?n d?u
      if(sp_overtime_assignment_param.IdentityID && sp_overtime_assignment_param.IdentityID != "")
      {
        IsRegister = false
        IdentityID = sp_overtime_assignment_param.IdentityID
        getTimelineqlbeta(IdentityID,6,"timelineApprover","infoRequest")

        await processDataQLRLdxDataGridOTDetail(IdentityID);
        await getQLRLSelectedOT();
        var data = QLRLdxDataGridOT.option(''dataSource'')
        SetValueControlOTDetail(data[0])
        SetControlFromHistory()
        StatusButton(IdentityID)
      }
      else
      {
        IsRegister = true
        onRowClick = false
        QLRLdxOTFromDate.option(''value'', new Date());
        getTimelineqlbeta("",6,"timelineApprover","infoRequest")
        processDataQLRLdxDataGridOTDetail("");
        StatusButton("")
        getQLRLSelectedOT();
      }


    }
    async function StatusButton(IdentityID)
    {
      await AjaxHPAParadiseAsync({
        data: {
          name: ''sp_overtime_CheckActionRequest'',
          param: [''IdentityID'', IdentityID, LoginID, UserID],
        },
        success: function (result) {
          var data = JSON.parse(result).data[0][0];
          var flag = data.Flag ? data.Flag : 1

          if(flag == 1)
          {
            SetGroupButtonAction("Register")
          }
          else if(flag == 2)
          {
             SetGroupButtonAction("Approved")
          }
          else if(flag == 3)
          {
            SetGroupButtonAction("Destroy")
          }
          else
          {
            SetGroupButtonAction("Hidden")
          }
        },
      });

    }
    // G?i hàm async
    initOT();
    async function QLRLLogMess() {
      var OTFrom = QLRLdxOTFrom.option(''value'');
      var OTTo = QLRLdxOTTo.option(''value'');
      var ShiftCode = $(''#qlrl-ShiftCodeOT'').val();
      var OTCategoryID = $(''#qlrl-OTCategoryID'').val();
      var OTDate = formatDateSQL(QLRLdxOTFromDate.option(''value''));

      var arrMess = await ApiValidateOTFromOTTo(
        OTFrom,
        OTTo,
        ShiftCode,
        OTCategoryID,
        OTDate
      );
      //console.log(arrMess)
      if (!arrMess.isValid) {
        SetInvalid(`#qlrl-OTFrom,#qlrl-OTTo`, arrMess.ErrorMess, 1);
      } else {
        SetValid(`#qlrl-OTFrom,#qlrl-OTTo`, 1);
      }
    }

    async function getQLRLSelectedOT() {
      return new Promise((resolve, reject) => {
        AjaxHPAParadise({
          data: {
            name: ''sp_OverTime_getSelected'',
            param: [''LanguageID'', LanguageID],
          },
          success: function (result) {
            var data = JSON.parse(result).data;
            //var arrOTValue = data[0];
            var arrOTCategory = data[0];
            var arrShift = data[1];
            var arrOTType = data[2];

            /*$.each(arrOTValue, function (index, item) {
              $(''#qlrl-OTValue'').append(
                $(''<option>'', {
                  value: item.OTValue,
                  text: item.Description,
                })
              );
            });*/
            $.each(arrOTCategory, function (index, item) {
              $(''#qlrl-OTCategoryID'').append(
                $(''<option>'', {
                  value: item.OTCategoryID,
  text: item.Description,
                })
              );
            });
            $.each(arrShift, function (index, item) {
              $(''#qlrl-ShiftCodeOT'').append(
                $(''<option>'', {
                  value: item.ShiftCode,
                  text: item.ShiftName,
                })
              );
            });
            $.each(arrOTType, function (index, item) {
              $(''#qlrl-OTType'').append(
                $(''<option>'', {
                  value: item.OTType,
                  text: item.Description,
                })
              );
            });
            //combobox của dataGrid
   QLRLdxDataGridOT.columnOption(''ShiftCode'', {
              lookup: {
                dataSource: arrShift,
                valueExpr: ''ShiftCode'',
                displayExpr: ''ShiftName'',
              },
            });
            QLRLdxDataGridOT.columnOption(''OTCategoryID'', {
              lookup: {
        dataSource: arrOTCategory,
                valueExpr: ''OTCategoryID'',
                displayExpr: ''Description'',
              },
            });
           /* QLRLdxDataGridOT.columnOption(''OTValue'', {
              lookup: {
                dataSource: arrOTValue,
                valueExpr: ''OTValue'',
                displayExpr: ''Description'',
              },
            }); */
            QLRLdxDataGridOT.columnOption(''OTType'', {
              lookup: {
                dataSource: arrOTType,
                valueExpr: ''OTType'',
                displayExpr: ''Description'',
              },
            });

            resolve(); // Chờ load xong mới resolve
          },
          error: function (err) {
            console.error(''AJAX failed'', err);
            reject(err); // Trong trường hợp lỗi
          },
        });
      });
    }

    async function ChangeDxDateBoxOTDate(fromdate, todate, note) {
      return new Promise(function (resolve, reject) {
        AjaxHPAParadise({
          data: {
            name: ''sp_Overtime_ChangeDate'',
            param: [
              ''LoginID'',
              LoginID,
              ''LanguageID'',
              LanguageID,
              ''FromDate'',
              fromdate,
              ''ToDate'',
              todate,
              ''Note'',
              note,
            ],
          },
          success: function (result) {
            try {
              var data = JSON.parse(result).data;
              resolve(data); //trả về
            } catch (e) {
              reject(e);
            }
          },
          error: function (err) {
            reject(err);
          },
        });
      });
    }

    var isholiday = false;
    async function SetValueFromOTData(OTData) {
      //console.log(OTData)
     /* if (OTData.OTCategoryID == 3) {
        $(''#qlrl-OTCategoryID'').val(3);
      } else {
        $(''#qlrl-OTCategoryID'').val(-1);
      } */
      $(''#qlrl-OTCategoryID'').val(OTData.OTCategoryID)
      if (OTData.ShiftCode != null) {
        $(''#qlrl-ShiftCodeOT'').val(OTData.ShiftCode);
        if (OTData.HolidayStatus != 0) {
          //ẩn option
          isholiday = true;
          $(''#qlrl-OTCategoryID option[value="1"]'').hide();
          $(''#qlrl-OTCategoryID option[value="2"]'').hide();
          $(''#qlrl-OTCategoryID option[value="3"]'').show();
        } else {
          isholiday = false;
          $(''#qlrl-OTCategoryID option[value="1"]'').show();
          $(''#qlrl-OTCategoryID option[value="2"]'').show();
          $(''#qlrl-OTCategoryID option[value="3"]'').hide();
        }
      }

      if (OTData.OTType != null) {
        $(''#qlrl-OTType'').val(OTData.OTType);
      }

      if (OTData.OTValue != null) {
        $(''#qlrl-OTValue'').val(OTData.OTValue);
      }

      if (OTData.OTKind != null) {
     otKind = OTData.OTKind;
      }

      if (OTData.OTHour != null) {
        otHour = OTData.OTHour;
      }

      if (OTData.Identity_ID != null) {
        IdentityID = OTData.Identity_ID;
      }
      FlagOTFromChangeEvent = false;
      FlagOTToChangeEvent = false;
      QLRLdxOTTo.option(''value'', new Date(OTData.OTTo));
      QLRLdxOTFrom.option(''value'', new Date(OTData.OTFrom));
      FlagOTFromChangeEvent = true;
      FlagOTToChangeEvent = true;
      if (!isholiday) {
        await CaculalorHour();
      }
      $(''#qlrl-OTHour'').val(otHour);
      $(''#qlrl-OTHour'').trigger(''change'');
    }

    async function CaculalorHour() {

      if (CheckValid(''#qlrl-OTFrom'', 1) && CheckValid(''#qlrl-OTTo'', 1)) {
        var otfrom = QLRLdxOTFrom.option(''value'');
        var otto = QLRLdxOTTo.option(''value'');
        var shiftcode = $(''#qlrl-ShiftCodeOT'').val();
        var otdate = formatDateSQL(QLRLdxOTFromDate.option(''value''));
        if (isholiday && shiftcode != -1) {
          otHour = await ApiCalculateHoursHoliday(
            otfrom,
            otto,
            shiftcode,
            otdate
          );
        } else {
          otHour = await ApiCalculateHours(otfrom, otto);
        }
      }
    }
    async function CaculalorHourCompare() {
      var otHour = 0;
      if (CheckValid(''#qlrl-OTFrom'', 1) && CheckValid(''#qlrl-OTTo'', 1)) {
        var otfrom = QLRLdxOTFrom.option(''value'');
        var otto = QLRLdxOTTo.option(''value'');
        otHour = await ApiCalculateHours(otfrom, otto);
      }
      return otHour;
    }
    $(''#qlrl-OTCategoryID'')
      .off(''change'')
      .on(''change'', async function () {
        var shiftcode = $(''#qlrl-ShiftCodeOT'').val();
        var categoryid = $(this).val();

        if ((isholiday && categoryid != 3) || categoryid == -1) {
          if (categoryid == -1) {
            SetInvalid(''#qlrl-OTCategoryID'', ''%CannotBeEmpty%!'', 0);
          } else {
            SetInvalid(''#qlrl-OTCategoryID'', ''%Invalid%!'', 0);
      }
        } else if ((!isholiday && categoryid == 3) || categoryid == -1) {
          if (categoryid == -1) {
            SetInvalid(''#qlrl-OTCategoryID'', ''%CannotBeEmpty%!'', 0);
          } else {
            SetInvalid(''#qlrl-OTCategoryID'', ''%Invalid%!'', 0);
          }
        } else {
          SetValid(''#qlrl-OTCategoryID'', 0);
        }

        //khóa OTFrom OTTo nếu loại đơn sai
        if ($(''#qlrl-OTCategoryID'').hasClass(''is-invalid'')) {
          SetStatusOTFromOTTo(0);
        } else {
          SetStatusOTFromOTTo(1);
        }

        await QLRLLogMess();
        //await QLRLLogMess("#qlrl-OTTo")
        await CaculalorHour()

        $(''#qlrl-OTHour'').val(otHour);
         $(''#qlrl-OTHour'').trigger("change")
      });
    $(''#qlrl-ShiftCodeOT'')
      .off(''change'')
      .on(''change'', async function () {
        await QLRLLogMess();
        //await QLRLLogMess("#qlrl-OTTo")
        await CaculalorHour();
        $(''#qlrl-OTHour'').val(otHour);
      });

    function SetInvalid(id, feedbacktext = ''%Invalid%!'', type = 0) {
      //type = 0 bootrap,type = 1 devexpress tự chế
      var taget = $(`${id}`);
      if (taget) {
        if (type == 0) {
          //console.log(feedbacktext)
    if (!taget.hasClass(''is-invalid'')) {
            taget.addClass(''is-invalid'');
          }
          taget.next(''.invalid-feedback'').text(feedbacktext);
        } else {
          if (!taget.hasClass(''border'') && !taget.hasClass(''border-danger'')) {
            taget.addClass(''border border-danger'');
          }
          taget.next(''.invalid-feedback'').text(feedbacktext).addClass(''d-flex'');
          //border border-danger
        }
      }
    }
    function SetValid(id, type = 0) {
      var taget = $(`${id}`);
      if (taget) {
    if (type == 0) {
          taget.removeClass(''is-invalid'');
        } else {
    taget
            .removeClass(''border border-danger'')
            .next(''.invalid-feedback'')
            .removeClass(''d-flex'');
        }
      }
    }
    function CheckValid(id, type) {
      var flag = true;
      var taget = $(`${id}`);
      if (taget) {
        if (type == 0) {
          //console.log(feedbacktext)
          if (taget.hasClass(''is-invalid'')) {
            flag = false;
          }
        } else {
          if (taget.hasClass(''border'') && taget.hasClass(''border-danger'')) {
            flag = false;
          }
        }
      }
      return flag;
    }
    function SetStatusOTFromOTTo(type = 0) {
      // type = 0 Disable,type = 1 Enable
      if (type == 0) {
        QLRLdxOTFrom.option(''disabled'', true);
        QLRLdxOTTo.option(''disabled'', true);
      } else {
        QLRLdxOTFrom.option(''disabled'', false);
        QLRLdxOTTo.option(''disabled'', false);
      }
}

    //var qlrlOTFromDate =  formatDateSQL($("#qlrl-dxOTFromDate").dxDateBox("instance").option("value")) //từ ngày
    //var qlrlOTToDate = formatDateSQL($("#qlrl-dxOTToDate").dxDateBox("instance").option("value")) //đến ngày ngày
    function formatDateSQL(date) {
      var d = new Date(date);
      var year = d.getFullYear();
      var month = String(d.getMonth() + 1).padStart(2, ''0'');
      var day = String(d.getDate()).padStart(2, ''0'');
      return `${year}-${month}-${day}`;
    }
    async function processDataQLRLdxDataGridOTDetail(IdentityID) {
      await AjaxHPAParadiseAsync({
        data: {
          name: ''sp_OverTime_ProcessDetailDraft'',
          param: [''IdentityID'', IdentityID, ''LanguageID'', LanguageID,"EmployeeID", EmployeeID],
        },
        success: function (result) {
          var data = JSON.parse(result).data;
          var arrtblOTListRegisteredDetail = data[0];
          var fileData = data[1] ? data[1] : []
          arrtblOTListRegisteredDetail = arrtblOTListRegisteredDetail
            ? arrtblOTListRegisteredDetail
            : [];
          QLRLdxDataGridOT.option(''dataSource'', arrtblOTListRegisteredDetail);
          QlbetaAddFileUIOT(data[1],1)
        },
      });
    }
    //processDataQLRLdxDataGridOT(qlrlOTFromDate,qlrlOTToDate)

    async function ApiCalculateHours(OTFrom, OTTo) {
      var shiftcode = $(''#qlrl-ShiftCodeOT'').val();
      if ((shiftcode = -1)) {
        shiftcode = null;
      }
      var otdate = formatDateSQL(QLRLdxOTFromDate.option(''value''));
      return new Promise(function (resolve, reject) {
        AjaxHPAParadise({
          data: {
            name: ''sp_Overtime_Detail_Event'',
            param: [
              ''OTFrom'',
              OTFrom,
              ''OTTo'',
              OTTo,
              ''ShiftCode'',
              shiftcode,
              ''OTDate'',
              otdate,
            ],
          },
          success: function (result) {
            try {
              var data = JSON.parse(result).data;
              var arrOTHour = data[0][0];
              //console.log(arrOTHour)
              resolve(arrOTHour.OTHour);
            } catch (e) {
              reject(e);
            }
          },
          error: function (err) {
            reject(err);
          },
        });
      });
    }
    async function ApiCalculateHoursHoliday(OTFrom, OTTo, ShiftCode, OTDate) {
      return new Promise(function (resolve, reject) {
        AjaxHPAParadise({
          data: {
            name: ''sp_Overtime_Detail_Event_Holiday'',
            param: [
              ''OTFrom'',
              OTFrom,
              ''OTTo'',
              OTTo,
              ''ShiftCode'',
              ShiftCode,
              ''OTDate'',
              OTDate,
            ],
          },
          success: function (result) {
            try {
              var data = JSON.parse(result).data;
              var arrOTHour = data[0][0];
              //console.log(arrOTHour)
              resolve(arrOTHour.OTHour);
            } catch (e) {
              reject(e);
            }
          },
          error: function (err) {

            reject(err);
          },
        });
      });
    }
    async function ApiValidateOTFromOTTo(
      OTFrom,
      OTTo,
      ShiftCode,
      OTCategoryID,
      OTDate
    ) {
      var type = 0;
      if (!OTFrom || !OTTo || !ShiftCode || !OTCategoryID || !OTDate) {
        return;
      }
      if (isholiday) {
        type = 1;
      }
      return new Promise(function (resolve, reject) {
      AjaxHPAParadise({
          data: {
            name: ''sp_Overtime_ValidateOTFromOTTo'',
            param: [
              ''OTFrom'',
              OTFrom,
              ''OTTo'',
              OTTo,
              ''ShiftCode'',
              ShiftCode,
 ''OTCategoryID'',
              OTCategoryID,
    ''OTDate'',
            OTDate,
              ''Type'',
              type,
              "LanguageID",LanguageID
            ],
          },
          success: function (result) {
            try {
              var data = JSON.parse(result).data;
              var arrVali = data[0][0];
              //console.log(arrOTHour)
              resolve(arrVali);
            } catch (e) {
              reject(e);
            }
          },
          error: function (err) {
            reject(err);
          },
        });
      });
    }
    //type = 0 thêm vào detail, type = 1, json truyền vào IDentityID cập nhật trạng thái đăng ký
    function ApiSubmitRequestOT(json, type) {
      var mess = '''';
      if (type == 0) {
        mess = ''%AddSuccess%'';
      } else {
        mess = ''%Successfully%'';
      }
      AjaxHPAParadise({
        data: {
          name: ''sp_OverTime_SubmitOTDetail'',
          param: [''JsonValue'', json, ''Type'', type,"JsonFile", FileSelected],
        },
        success:async function (result) {
          uiManager.showAlert({
            message: `${mess}`,
            type: ''success'',
             width: 300,
            displayTime: 4000,
            position: {
              my: ''top right'',
              at: ''top right'',
              of: ''#sp_Overtime_Assignment'',
              offset: ''0 50'',
            },
          });
          if(type == 0)
          {
            processDataQLRLdxDataGridOTDetail(IdentityID);
            ClearData();
          }
          else
          {
            //QLRLdxDataGridOT.option(''dataSource'', []);
            getTimelineqlbeta(IdentityID,6,"timelineApprover","infoRequest")
            await processDataQLRLdxDataGridOTDetail(IdentityID);
            var data = QLRLdxDataGridOT.option(''dataSource'')
            SetValueControlOTDetail(data[0])
            SetControlFromHistory()
            StatusButton(IdentityID)
            $("#filePreviewContainer").empty()
            //QlbetaAddFileUIOT(FileSelected,1)
            FileSelected = []
         }


        },
      });
    }
    function ClearData() {
      FlagOTFromChangeEvent = false;
      FlagOTToChangeEvent = false;
      FlagOTDateChangeEvent = false;
      QLRLdxOTFromDate.option(''value'', null);
      QLRLdxOTFrom.option(''value'', null);
      QLRLdxOTTo.option(''value'', null);
      $(''#qlrl-ShiftCodeOT'').val(-1);
      $(''#qlrl-OTCategoryID'').val(-1);
      $(''#qlrl-NoteOT'').val('''');
      $(''#qlrl-OTHour'').val('''');
      $(''#btnAddRequestOT'').prop(''disabled'', true);
      FlagOTFromChangeEvent = true;
      FlagOTToChangeEvent = true;
      FlagOTDateChangeEvent = true;
      DisabledAll();
    }
    function DisabledAll() {
      $(
        ''#qlrl-OTCategoryID, #qlrl-OTType, #qlrl-OTValue, #qlrl-NoteOT,#qlrl-ShiftCodeOT,#btnAddRequestOT''
      ).prop(''disabled'', true);
      $(''#qlrl-OTFrom'').dxDateBox(''instance'').option(''disabled'', true);
      $(''#qlrl-OTTo'').dxDateBox(''instance'').option(''disabled'', true);
    }
    function EnabledAll() {
 $(
        ''#qlrl-OTCategoryID, #qlrl-OTType, #qlrl-OTValue, #qlrl-NoteOT,#qlrl-ShiftCodeOT,#btnAddRequestOT''
      ).prop(''disabled'', false);
      $(''#qlrl-OTFrom'').dxDateBox(''instance'').option(''disabled'', false);
      $(''#qlrl-OTTo'').dxDateBox(''instance'').option(''disabled'', false);
    }
    $(''#btnAddRequestOT'')
      .off(''click'')
      .on(''click'', function () {
        if (
          !CheckValid(''#qlrl-OTCategoryID'', 0) ||
          !CheckValid(''#qlrl-NoteOT'', 0) ||
          !CheckValid(''#qlrl-OTFrom'', 1) ||
          !CheckValid(''#qlrl-OTTo'', 1) ||
          !CheckValid(''#qlrl-OTHour'', 0)
        ) {
          uiManager.showAlert({
            message: `%PleaseReivewWarning%`,
            type: ''warning'',
            width: 300,
            displayTime: 4000,
            position: {
              my: ''top right'',
              at: ''top right'',
              of: ''#sp_Overtime_Assignment'',
              offset: ''0 50'',
 },
          });
          return;
        }
        var otCategoryID = $(''#qlrl-OTCategoryID'').val();
        var otType = $(''#qlrl-OTType'').val();
        var otValue = $(''#qlrl-OTValue'').val();
        var noteOT = $(''#qlrl-NoteOT'').val();
        var shiftCode = $(''#qlrl-ShiftCodeOT'').val();
        // Lấy giá trị từ các thành phần dxDateBox
        var otFrom = $(''#qlrl-OTFrom'').dxDateBox(''instance'').option(''value'');
        var otTo = $(''#qlrl-OTTo'').dxDateBox(''instance'').option(''value'');
        var otDate = formatDateSQL(
          $(''#qlrl-dxOTFromDate'').dxDateBox(''instance'').option(''value'')
        );
        var OTHour = $(''#qlrl-OTHour'').val();
        // Tạo đối tượng JSON
        var requestData = {
          Identity_ID: IdentityID,
          EmployeeID: EmployeeID,
          OTCategoryID: otCategoryID,
          OTType: otType,
          OTValue: otValue,
          Note: noteOT,
          OTFrom: otFrom,
          OTTo: otTo,
          OTDate: otDate,
          ShiftCode: shiftCode,
          OTKind: otKind,
          OTHour: OTHour,
        };
        //console.log(requestData)

        ApiSubmitRequestOT(JSON.stringify(requestData), 0);
      });
    $(''#qlrl-NoteOT'')
      .off(''input'')
      .on(''input'', function () {
        var note = $(this).val();
        if (note == '''') {
          SetInvalid(''#qlrl-NoteOT'', ''%CannotBeEmpty%!'', 0);
        } else {
          SetValid(''#qlrl-NoteOT'', 0);
        }
      });
    function ApiDeleteOTDetail(id) {
      AjaxHPAParadise({
        data: {
          name: ''sp_OverTime_DeleteOTDetail'',
          param: [''DetailID'', id],
        },
        success: function (result) {
          uiManager.showAlert({
            message: ''%DltSuccess%'',
            type: ''success'',
            width: 300,
            displayTime: 4000,
            position: {
              my: ''top right'',
              at: ''top right'',
              of: ''#sp_Overtime_Assignment'',
              offset: ''0 50'',
            },
          });
          processDataQLRLdxDataGridOTDetail(IdentityID);
        },
      });
    }

    $(''#sp_Overtime_Assignment .btnRegister'')
      .off(''click'')
      .on(''click'', function () {
        var jsondata = QLRLdxDataGridOT.option(''dataSource'');
        if (jsondata.length == 0) {
          uiManager.showAlert({
            message: `%HASNODATA%!`,
            type: ''warning'',
            width: 300,
            displayTime: 4000,
            position: {
              my: ''top right'',
              at: ''top right'',
              of: ''#sp_Overtime_Assignment'',
              offset: ''0 50'',
            },
          });
          return;
        }
        showConfirmPopup({
            title: "%Notification%",
            message: "%ConfirmRegister%!",
            YesText: "%Yes%",
            NoText: "%No%",
            onYes: function() {
                ApiSubmitRequestOT(IdentityID, 1);
                SetValid(''#qlrl-dxOTFromDate'', 1);
            }
        });

      });
    $(''#qlrl-OTHour'')
      .off(''change'')
      .on(''change'', async function () {
        var othour = $(this).val();

        if(!CheckValid(''#qlrl-OTFrom'', 1) || !CheckValid(''#qlrl-OTTo'', 1))
        {
            return
        }
        var hour = await CaculalorHourCompare();

        if (othour > hour) {
          SetInvalid(
            ''#qlrl-OTHour'',
            ''Không hợp lệ. Số giờ lớn hơn khoảng thời gian từ giờ đến giờ!'',
            0
          );
        } else if (othour == '''' || othour == 0) {
          SetInvalid(''#qlrl-OTHour'', ''%Invalid%!'', 0);
        } else {
          SetValid(''#qlrl-OTHour'', 0);
        }
      });

        $("#header_sp_overtime_assignment").addClass("d-none")
$("#contentContainer_sp_overtime_assignment").css("height", "calc(100vh - 65px)")


     function getHistoryOT(IdentityID)
      {
         AjaxHPAParadise({
            data: {
              name: ''sp_overtime_history'',
              param: [''LoginID'', UserID,
                      "IdentityID",IdentityID,
                      ''LanguageID'', LanguageID],
            },
            success: function (result) {
              var data = JSON.parse(result).data;
              var arr = data[0] ? data[0] : []
              renderOAList(arr)


            },
          });
      }

    function renderOAList(list) {

      let container = $("#OTHistoryList");
      container.empty()

      list.forEach(item => {
       let card = document.createElement("div");
       card.className = "oa-card";
       card.innerHTML = `
                <div class="card containers pt-2 pb-2 " style="">
                    <div class="request-subtitle mt-2">
                        <b>%OTType%:</b> ${item.OTType}
                    </div>
                    <div class="request-subtitle">
                        <b>%colNote%:</b> ${item.Note}
                    </div>
                    <div class="request-subtitle">
                        <b>${item.ViewDate}</b><br>${item.ViewTime}
                    </div>
                    <span data-content="${item.ApproveStatus}"></span>
                    ${viewStatus(item.Approve_Status,item.ApproveStatus)}
            </div>
          `;
       card.addEventListener("click", async  function (){
            await processDataQLRLdxDataGridOTDetail(item.IdentityID)
            StatusButton(item.IdentityID)
            //xoa het canh bao vao readonly tat ca
            SetControlFromHistory()
            //lay dong dau tien gan vao
            var data = QLRLdxDataGridOT.option(''dataSource'')
            SetValueControlOTDetail(data[0])
            getTimelineqlbeta(item.IdentityID,6,"timelineApprover","infoRequest")
            //aa
            $("#sp_Overtime_Assignment .tab-content").removeClass("active");
            $(`#RegisterOTRequest-tab`).addClass("active");
            $(`.menu-tab[data-tab="HistoryOTRequest"]`).removeClass("active");
            $(`.menu-tab[data-tab="RegisterOTRequest"]`).addClass("active");

            onRowClick = true

       });
       container.append(card);
      });
     }
     function SetValueControlOTDetail(data) {
			if(data)
			{														
                FlagOTFromChangeEvent = false;
                FlagOTToChangeEvent = false;
                FlagOTDateChangeEvent = false;
				$(''#qlrl-OTCategoryID option[value="1"]'').show();
				$(''#qlrl-OTCategoryID option[value="2"]'').show();
				$(''#qlrl-OTCategoryID option[value="3"]'').show();
				
						
				// Thiết lập giá trị cho các trường select
				$("#qlrl-OTCategoryID").val(data.OTCategoryID);
				$("#qlrl-ShiftCodeOT").val(data.ShiftCode ? data.ShiftCode : -1);
				$("#qlrl-OTType").val(data.OTType);
				$("#qlrl-NoteOT").val(data.Note)

				// Thiết lập giá trị cho các trường input
				$("#qlrl-OTHour").val(data.OTHour);
		
				// Thiết lập giá trị cho dxDateBox
				QLRLdxOTFromDate.option("value", data.OTDate);

				//console.log(data.OTFrom,data.OTTo)
				QLRLdxOTFrom.option("value", new Date(`2025 ${data.OTFrom}`));
				QLRLdxOTTo.option("value", new Date(`2025 ${data.OTTo}`));
			     FlagOTFromChangeEvent = true;
                FlagOTToChangeEvent = true;
  FlagOTDateChangeEvent = true;
                IdentityID = data.IdentityID
			}				
		}
   function SetControlFromHistory()
   {
    SetValid(''#qlrl-OTCategoryID'');
    SetValid(''#qlrl-OTType'');
    SetValid(''#qlrl-OTValue'');
    SetValid(''#qlrl-NoteOT'');
    SetValid(''#qlrl-ShiftCodeOT'');
    SetValid(''#btnAddRequestOT'');
    SetValid("#qlrl-OTHour")

    SetValid(''#qlrl-dxOTFromDate'',1);
    SetValid(''#qlrl-OTFrom'',1);
    SetValid(''#qlrl-OTTo'',1);


    QLRLdxDataGridOT.columnOption("deleteBtn", "visible", false);
    $(''#qlrl-OTCategoryID, #qlrl-OTType, #qlrl-OTValue, #qlrl-NoteOT,#qlrl-ShiftCodeOT,#btnAddRequestOT,#qlrl-OTHour'').prop(''disabled'', true);
      $(''#qlrl-dxOTFromDate'').dxDateBox(''instance'').option(''disabled'', true);
      $(''#qlrl-OTFrom'').dxDateBox(''instance'').option(''disabled'', true);
      $(''#qlrl-OTTo'').dxDateBox(''instance'').option(''disabled'', true);
       $("#qlbeta-customchosefileOT").dxButton("instance").option("disabled", true);
   }

   $("#sp_Overtime_Assignment .btnApprove").off("click").on("click",function(){
        $("#btnActionModalRemakeOT").removeClass("btn-danger");
       $("#btnActionModalRemakeOT").attr("data-action", "approve");
        $("#btnActionModalRemakeOT").text("%IsApproval%");
        $("#btnActionModalRemakeOT").addClass("btn-success");
        $("#modalApproveRemakeForOT").modal(''show'')

   })

   $("#sp_Overtime_Assignment .btnReject").off("click").on("click",function(){
        $("#btnActionModalRemakeOT").removeClass("btn-success");
        $("#btnActionModalRemakeOT").attr("data-action", "reject");
        $("#btnActionModalRemakeOT").text("%Deny%");
        if(!$("#btnActionModalRemakeOT").hasClass("btn-danger"))
        {
            $("#btnActionModalRemakeOT").addClass("btn-danger");
        }
        $("#modalApproveRemakeForOT").modal(''show'')
   })

   $("#sp_Overtime_Assignment .btnDestroy").off("click").on("click",function(){
         $("#btnActionModalRemakeOT").removeClass("btn-success");
       $("#btnActionModalRemakeOT").attr("data-action", "destroy");
        $("#btnActionModalRemakeOT").text("%DestroyL%");
        if(!$("#btnActionModalRemakeOT").hasClass("btn-danger"))
        {
            $("#btnActionModalRemakeOT").addClass("btn-danger");
        }
        $("#modalApproveRemakeForOT").modal(''show'')

   })

   $("#btnActionModalRemakeOT").off("click").on("click",async function(){
        $("#btnActionModalRemakeOT,#sp_Overtime_Assignment .btnApprove,#sp_Overtime_Assignment .btnDestroy,#sp_Overtime_Assignment .btnReject").prop(''disabled'', true);
        var action = $(this).attr("data-action")
        var reason = $("#approveRemakeForOT").val()
        console.log(IdentityID)

        if(action == "approve")
        {
            await api_approveRegister(IdentityID, reason)
        }
        else if(action == "reject")
        {
           await api_rejectRegister(IdentityID, reason)
        }
        else
        {
           if(reason == "")
           {
                SetInvalid("#approveRemakeForOT","%Required%",0)
                $("#btnActionModalRemakeOT,#sp_Overtime_Assignment .btnApprove,#sp_Overtime_Assignment .btnDestroy,#sp_Overtime_Assignment .btnReject").prop(''disabled'', false);
                return
           }
           await onCancelOARequest(IdentityID, reason);
        }
        $("#btnActionModalRemakeOT,#sp_Overtime_Assignment .btnApprove,#sp_Overtime_Assignment .btnDestroy,#sp_Overtime_Assignment .btnReject").prop(''disabled'', false);
        getTimelineqlbeta(IdentityID,6,"timelineApprover","infoRequest")
        StatusButton(IdentityID)
        $("#btnCloseModalRe").trigger("click")
   })
   $("#btnCloseModalRe").off("click").on("click", function(){
     SetValid("#approveRemakeForOT",0)
     $("#approveRemakeForOT").val("")
     $("#modalApproveRemakeForOT").modal(''hide'')
   })
  //Hàm duyệt
 async function api_approveRegister(identityID, remake)
 {
  await AjaxHPAParadiseAsync({
   data: {
            name: "API_Overtime_Assignment_Do_Approve",
            param: ["Identity_ID",identityID,
            "LoginID", LoginID,
            "ApproverRemark", remake,
            "LanguageID",LanguageID]
        },
        success: function (e) {
        var result = JSON.parse(e);
    if (result.data && result.data[0] && result.data[0]?.length > 0) {
     let errors = result.data[0]

     errors.forEach(err => {
      showNotification("%lblerror%", err.Detail, err.ErrorType);
     });
    } else{
     showNotification("%lblSuc%", "%sp_resignationletter_register_approvesuccessful%!", "success");
    }
        },
        error: function (error) {
            console.error("Lỗi api duyệt:", error);
        }
    });
 }
 //Hàm từ chối
 async function api_rejectRegister(identityID, remake){
    await AjaxHPAParadiseAsync({
       data: {
                name: "API_Overtime_Assignment_Do_Reject",
                param: ["Identity_ID",identityID,
         "LoginID", LoginID,
         "ApproverRemark", remake]
        },
        success: function (e) {
        var result = JSON.parse(e);
    if (result.data && result.data[0] && result.data[0]?.length > 0) {
         let errors = result.data[0]
         errors.forEach(err => {
          showNotification("%lblerror%", err.Detail, err.ErrorType);
         });
        } else {
         showNotification("%lblSuc%", "%sp_resignationletter_register_rejectsuccessful%!", "success");
        }

            },
            error: function (error) {
                console.error("Lỗi api từ chối duyệt:", error);
            }
        });
  }

 async function onCancelOARequest(ID, reason){

      await AjaxHPAParadiseAsync({
      data: {
       name: "Overtime_Assignment_CancelTheRequest",
       param: ["LoginID",LoginID,"LanguageID",LanguageID,"IdentityID",ID, "Remark", reason]
      },
      success: function (e) {
       var result = JSON.parse(e);
       if (result.data && result.data[0] && result.data[0]?.length > 0) {
        let errors = result.data[0]
        errors.forEach(err => {
            showNotification("%lblerror%", err.Detail, err.ErrorType);
        });
       }
 }})}
   function SetGroupButtonAction(Action) {

    if (Action == "Hidden") {
      if (
        !$(''#sp_Overtime_Assignment .btnApprove'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnApprove'').addClass(''d-none'');
      }
      if (
        !$(''#sp_Overtime_Assignment .btnReject'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnReject'').addClass(''d-none'');
      }

      if (
        !$(''#sp_Overtime_Assignment .btnRegister'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnRegister'').addClass(''d-none'');
      }
      if (
        !$(''#sp_Overtime_Assignment .btnDestroy'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnDestroy'').addClass(''d-none'');
      }
    } else if(Action == "Approved") {
      $(''#sp_Overtime_Assignment .btnApprove'').removeClass(''d-none'');
      $(''#sp_Overtime_Assignment .btnReject'').removeClass(''d-none'');
      if (
        !$(''#sp_Overtime_Assignment .btnRegister'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnRegister'').addClass(''d-none'');
      }
      if (
        !$(''#sp_Overtime_Assignment .btnDestroy'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnDestroy'').addClass(''d-none'');
      }
    }
    else if(Action == "Destroy")
    {
         $(''#sp_Overtime_Assignment .btnDestroy'').removeClass(''d-none'');

     if (
        !$(''#sp_Overtime_Assignment .btnRegister'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnRegister'').addClass(''d-none'');
  }
      if (
        !$(''#sp_Overtime_Assignment .btnApprove'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnApprove'').addClass(''d-none'');
      }
      if (
        !$(''#sp_Overtime_Assignment .btnReject'').hasClass(''d-none'')
      ) {
        $(''#sp_Overtime_Assignment .btnReject'').addClass(''d-none'');
      }
    }
    else if(Action == "Register")
    {
        $(''#sp_Overtime_Assignment .btnRegister'').removeClass(''d-none'')
        if (
    !$(''#sp_Overtime_Assignment .btnApprove'').hasClass(''d-none'')
          ) {
$(''#sp_Overtime_Assignment .btnApprove'').addClass(''d-none'');
          }
          if (
            !$(''#sp_Overtime_Assignment .btnReject'').hasClass(''d-none'')
          ) {
            $(''#sp_Overtime_Assignment .btnReject'').addClass(''d-none'');
          }
          if (!$(''#sp_Overtime_Assignment .btnDestroy'').hasClass(''d-none'')) {
            $(''#sp_Overtime_Assignment .btnDestroy'').addClass(''d-none'');
          }
     }
  }
  function OpenFormOA(identityID){
    if ( ["Android", "iOS"].includes(getMobileOperatingSystem())) {
                OpenFormParamMobile(`Overtime_Assignment_web`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${identityID}` });
    } else {
                openFormParam(`Overtime_Assignment_web`, { LoginID: LoginID, LanguageID: LanguageID, IdentityID: `${identityID}` });
    }
 }
 $("#approveRemakeForOT").off("input").on("input", function(){
    if($("#btnActionModalRemakeOT").attr("data-action") != "destroy")
    {
        return
    }
    var val = $("#approveRemakeForOT").val()
    if(val != "")
    {
        SetValid("#approveRemakeForOT")
    }
    else
    {
        SetInvalid("#approveRemakeForOT","%Required%",0)
    }

 })
 $(''#qlbeta-customchosefileOT'').dxButton({
      icon: "upload",
     stylingMode: ''contained'',
     text: ''%ChoseFile%'',
     type: ''normal'',
     width: 150,
     onClick: async function (){
       if (ParadiseOption.AppInfoVersionString.length > 0 && getMobileOperatingSystem() == "Android") {
       var result = await apimobileAjaxAsync({}, {
        "MethodName": "MobileFilePickerMultipleAsync",
        "prs": [],
       });
       if(result == "Object reference not set to an instance of an object")
       {
        HideLoadingByClassOrID("#sp_Overtime_Assignment");
        return
       }
       showLoadingByClassOrID("#sp_Overtime_Assignment");
       var promises = result.map(async (file, i) => {
        const optimized = await optimizeImageBase64IfNeeded({
         fileName: file.fileName,
         data: file.data
        });
        optimized.uid = Date.now() + ''_'' + i;
        return optimized;
       });

       var arrFileNew = await Promise.all(promises);
       FileSelected.push(...arrFileNew)
       QlbetaAddFileUIOT(FileSelected);
       HideLoadingByClassOrID("#sp_Overtime_Assignment");
      } else {
       $("#qlbeta-fileForOT").trigger("click");
      }
     },
    })
  function QlbetaAddFileUIOT(files, sender = 0) {

        const previewContainer = $("#filePreviewContainer");
        previewContainer.empty();
        var isHidenRemoveFile = ""

        if (sender == 1) isHidenRemoveFile = "d-none"

        files.forEach((file, index) => {
         var fileName = file.fileName;
         if(file.UrlFile)
         {
          fileName = file.UrlFile.split("\\").pop();
          console.log("🚀 ~ fileName:",  fileName);
         }
         const extension = fileName.split(''.'').pop().toLowerCase();

         let iconClass = "bi bi-file-earmark";
         let coloricon = "rgb(156, 163, 175)";
         let isImage = false;

         if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].includes(extension)) {
          iconClass = "bi bi-image";
          coloricon = "rgb(59, 130, 246)";
          isImage = true;
         } else if (["mp4", "mov", "avi", "mkv", "webm"].includes(extension)) {
          iconClass = "fa-file-video";
          coloricon = "rgb(220, 38, 38)";
         } else if (extension === "pdf") {
          iconClass = "bi bi-filetype-pdf";
          coloricon = "rgb(220, 38, 38)";
         } else if (["doc", "docx"].includes(extension)) {
          iconClass = "bi bi-file-word";
          coloricon = "rgb(30, 64, 175)";
         } else if (["xls", "xlsx", "csv"].includes(extension)) {
          iconClass = "bi bi-file-earmark-spreadsheet-fill";
          coloricon = "rgb(25, 135, 84)";
         } else if (["txt", "md", "log"].includes(extension)) {
          iconClass = "bi bi-file-text";
          coloricon = "rgb(107, 114, 128)";
         }

         const fileItem = $(`
                    <div class="preview-image" data-index="${index}">
                  <div class="d-flex align-items-center border-bottom gap-3" style="height: 50px;">

                    <span class="hr-badge" style="font-size:15px;">
                    <i class="fas ${iconClass}" style="font-size:20px;color:${coloricon};"></i>
                  </span>

                  <div class="hr-employee-content flex-grow-1">
                    <div class="text-break" style="cursor:pointer;">${fileName}</div>
                 </div>

                 <span class="text-body hr-badge btn-remove-file ${isHidenRemoveFile}"
                      style="font-size:15px; cursor:pointer;">
                    <i class="bi bi-trash text-primary"></i>
                </span>


                </div>
         `);

         // Click xóa
         fileItem.find(".btn-remove-file").off("click").on("click", function (e) {
            e.stopPropagation();
          const index = fileItem.data("index");
          FileSelected.splice(index, 1);
          QlbetaAddFileUIOT(FileSelected); // render lại
         });
         fileItem.off("click").on("click", function () {
              showLoadingByClassOrID("#sp_Overtime_Assignment")
              const base64 = file.data;
              getFileQlbeta(base64,fileName,isImage,1)
              HideLoadingByClassOrID("#sp_Overtime_Assignment")
           });
         previewContainer.append(fileItem)
      })
    }
    $(''#qlbeta-fileForOT'').off("change").on("change", async function (e) {
        const files = e.target.files;

        showLoadingByClassOrID("#sp_Overtime_Assignment");
        let promises = [];

        $.each(files, function (i, file) {
         const reader = new FileReader();
         promises.push(new Promise((resolve, reject) => {
          reader.onload = async function (e) {
           const base64Data = e.target.result.split('','')[1];
           const optimized = await optimizeImageBase64IfNeeded({
            fileName: file.name,
            data: base64Data
           });
           optimized.uid = Date.now() + ''_'' + i;
           FileSelected.push(optimized);
           resolve();
          };
          reader.onerror = reject;
          reader.readAsDataURL(file);
         }));
        });

        await Promise.all(promises);

        QlbetaAddFileUIOT(FileSelected);
        HideLoadingByClassOrID("#sp_Overtime_Assignment")
   });
   function optimizeImageBase64IfNeeded(fileObj, maxWidth = 1280, maxHeight = 1280, quality = 0.8) {
       return new Promise((resolve, reject) => {
        const extension = fileObj.fileName.split(''.'').pop().toLowerCase();
        const isImage = ["jpg", "jpeg", "png", "bmp", "webp"].includes(extension);

        if (!isImage) {
         // Không phải ảnh thì không tối ưu
         return resolve(fileObj);
        }

        const img = new Image();
        img.src = "data:image/*;base64," + fileObj.data;

        img.onload = function () {
         let width = img.width;
         let height = img.height;

         // Resize nếu cần
         if (width > maxWidth || height > maxHeight) {
          const ratio = Math.min(maxWidth / width, maxHeight / height);
          width = width * ratio;
          height = height * ratio;
         }

         const canvas = document.createElement("canvas");
         canvas.width = width;

         canvas.height = height;
         const ctx = canvas.getContext("2d");
         ctx.drawImage(img, 0, 0, width, height);

         const compressedDataUrl = canvas.toDataURL("image/jpeg", quality);
         const base64Data = compressedDataUrl.split('','')[1];

         resolve({
          fileName: fileObj.fileName,
          data: base64Data
         });
        };

        img.onerror = reject;
       });
     }
});
</script>
'

select @html html
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/2]: [dbo].[sp_Overtime_Assignment]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_Overtime_Assignment]
(@LoginD int =3, @LanguageID varchar(4) = 'vn',@IdentityID varchar(36) = '')
as
	declare @html nvarchar(max) = '', @Empty nvarchar(max) = ''
    select html from tblHtmlScriptCache where TableName = 'sp_Overtime_Assignment' and LanguageID = @LanguageID
    --set @html = N''
GO

