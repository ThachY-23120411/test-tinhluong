/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-3
  MÀN HÌNH / MENU    : Quản trị nhân sự -> Hồ sơ cá nhân (MnuSCR004)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[HR_StaffInformation_ForUserWeb_Beta]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[HR_StaffInformation_ForUserWeb_Beta]

(

  @LoginID int =445,

  @LanguageID varchar(20) = 'VN'

)

AS

--set @LanguageID = 'en'

 SET NOCOUNT ON

 DECLARE @QueryHTML nvarchar(max);

 declare @ScriptHtmlEditStaffInformation nvarchar(max);

 exec sp_EditStaffInformation_script @ScriptHtmlEditStaffInformation = @ScriptHtmlEditStaffInformation output, @LanguageID = @LanguageID



 set @QueryHTML = N'

  <style>

    .modal-dialog {

        overflow: visible !important; /* Bỏ giới hạn kích thước */

    }



    .modal-content {

        overflow: auto; /* Đảm bảo nội dung modal cuộn được khi resize */

    }



    .bootstrap-select .dropdown-toggle {

        width: 100% !important;

    }

    .fade:not(.show) {

        opacity: 1;

    }

    .dx-calendar-view-century .dx-calendar-cell span, .dx-calendar-view-decade .dx-calendar-cell span, .dx-calendar-view-year .dx-calendar-cell span{

        word-spacing: 0em;

    }

    #EmployeeProfile_P .nav-tabs .nav-item {

        margin: 0 !important;

        padding: 0 !important;

    }



    #EmployeeProfile_P .nav-tabs .nav-link {

        padding: 15px 20px;

        height: 60px;

        line-height: 30px;

        background-color: #f0f0f0;

        border-radius: 5px;

        display: flex;

        align-items: center;

    }





    #EmployeeProfile_P .nav-tabs {

        gap: 0 !important;

    }



    #changeDate, #endDate, #effectiveDate1, #effectiveDate2,

    #birthDateEdit_P, #issueDate_P {

        padding: 7px;

        border: var(--bs-border-width) solid var(--bs-border-color);

    }

    #EmployeeProfile_P  .dx-revert-button {

        display: none !important;

    }

    #EmployeeProfile_P  .dx-header-row{

        font-weight: bold !important;

        color: black !important

    }





    #EmployeeProfile_P .nav-item .nav-link {

        transition: background-color 0.3s ease, color 0.3s ease;

        background-color: unset !important;

        color: white !important;



    }



    #EmployeeProfile_P .nav-item .nav-link:hover {

        background-color: var(--background-color) !important;

        color: green !important;

        border-radius: 5px !important;



    }



    #EmployeeProfile_P .nav-item {

        background: unset;



        background-color: var(--background-color) !important;

        color:green /*linear-gradient(90deg, rgba(var(--bs-navbar-bg-1-rgb), 0.95) 0%, rgba(var(--bs-navbar-bg-2-rgb), 1) 50%, rgba(var(--bs-navbar-bg-3-rgb), 0.95) 100%);*/ !important;

        border-radius: 5px !important;

        font-size:15px !important



    }



    #EmployeeProfile_P .nav-item .nav-link {

        border: 1px solid transparent !important;

        border-radius: 5px !important;

        padding: 10px 20px !important;

    }



    #EmployeeProfile_P .nav-item .nav-link:hover,

    #EmployeeProfile_P .nav-item  {

        border: 1px solid #007bff;



    }



    #EmployeeProfile_P .profile-header {

        background: linear-gradient(90deg, rgba(var(--bs-navbar-bg-1-rgb), 0.95) 0%, rgba(var(--bs-navbar-bg-2-rgb), 1) 50%, rgba(var(--bs-navbar-bg-3-rgb), 0.95) 100%);

        color: white;



        border-radius: 10px;

        text-align: center;

        /* box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2); */

        display: flex;

        align-items: center;



        position: relative;

    }

    .header-controls {

        position: absolute;

        right: 0;

        top: 50%;

        transform: translateY(-50%);

        display: flex;

        align-items: center;

        gap: 10px;

    }

    #EmployeeProfile_P .profile-img-container {

        position: relative;

        display: inline-block;

        margin-bottom: 20px;

        z-index: 1;





    }



    #EmployeeProfile_P .profile-header img {

        position: relative;

        top: 50px;

        border: 2px solid white;

        border-radius: 50%;

        width: 210px;

        height: 210px;

        margin-left: 25px;

        object-fit: cover

    }



    #EmployeeProfile_P .profile-info {

        margin-bottom: 3%;

        margin-left: 65px;

        text-align: left;

        z-index: 2;



    }











    #EmployeeProfile_P .profile-info h2 {

        margin: 0;

        font-size: 24px;

    }



    #EmployeeProfile_P .profile-info p {

        margin: 5px 0 0;

        font-size: 16px;

    }





    #EmployeeProfile_P h4.section-title {

        margin-top: 10px;

        margin-bottom: 15px;

        border-bottom: 2px solid #ddd;

        padding-bottom: 5px;

        font-weight: bold;

    }



    #EmployeeProfile_P .icon-text {

        display: flex;

        align-items: center;

        gap: 10px;

        margin-bottom: 10px;

    }



    #EmployeeProfile_P .icon-text i {

        font-size: 20px;

        color: #007bff;

    }



    #EmployeeProfile .form-group {

        margin-bottom: 15px;

    }



    #EmployeeProfile_P .form-group label {

        font-weight: bold;

    }





    #EmployeeProfile_P .form-section {

        margin-top: 20px;

    }



   .dropdown-item {

        padding: 0px 12px;

        cursor: pointer;





    }



    #EmployeeProfile_P .InputContainer {

        border-radius: 11px;

        height: 40px;

        display: flex;

        align-items: center;

        justify-content: center;

        /*background-color: rgb(255, 255, 255);*/employeeInfoBasic

        border-radius: 10px;

        overflow: hidden;

        cursor: pointer;

        padding-left: 15px;

        /*box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.075);*/

    }



    #EmployeeProfile_P .inputSearch {

        width: 170px;

        height: 100%;

        border: none;

        outline: none;

        font-size: 0.9em;

        caret-color: rgb(255, 81, 0);

    }



    #EmployeeProfile_P .labelforsearch {

        cursor: text;

        padding: 0px 12px;

    }



    #EmployeeProfile_P .searchIcon {

        width: 13px;

    }



    #EmployeeProfile_P .border-home {

        height: 40%;

        width: 1.3px;

        background-color: none;

    }



    #EmployeeProfile_P .micIcon {

        width: 12px;

    }



    #EmployeeProfile_P .micButton {

        padding: 0px 15px 0px 12px;

        border: none;

        background-color: transparent;

        height: 40px;

        cursor: pointer;

        transition-duration: .3s;

    }



    #EmployeeProfile_P .searchIcon path {

        fill: rgb(114, 114, 114);

    }

    #modal_addNewEmp .modal {

        display: none;

        position: fixed;

        z-index: 100;

        left: 0;

        top: 0;

        width: 100%;

        height: 100%;

        background-color: rgba(0, 0, 0, 0.7);

        justify-content: center;

        align-items: center;

        overflow-y: auto;

    }



    #modal_addNewEmp .modal-content {



        padding: 20px;

        border-radius: 8px;

        /*box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);*/

        position: relative;

        margin: auto;

    }



    /* Màn hình lớn (desktop) */

    @media (min-width: 1200px) {

        #modal_addNewEmp .modal-content {

            max-width: 900px;

            width: 90%;

            height: auto;

            margin-top: 70px

        }

    }





    @media (min-width: 768px) and (max-width: 1199px) {

        #modal_addNewEmp .modal-content {

            max-width: 700px;

            width: 90%;

            height: auto;

        }

    }





    @media (max-width: 767px) {

        #modal_addNewEmp .modal-content {

            max-width: 95%;

            width: 95%;

            height: auto;

        }

    }



    #modal_addNewEmp .close {

        position: absolute;

        top: 0px;

        right: 0px;

        font-size: 20px;

        color: #fff;

        background: red;

        width: 30px;

        height: 30px;

        text-align: center;

        line-height: 30px;

        border-radius: 5px;

        cursor: pointer;

        display: flex;

        align-items: center;

        justify-content: center;



    }







    #modal_addNewEmp .modal-content h4 {

        margin-top: 0;

        text-align: center;

    }





     .avatar-upload {

        display: flex;

        align-items: center;

        justify-content: center;

        position: relative;

        margin-bottom: 20px;

    }



    .avatar-preview {

        width: 100px;

        height: 100px;

        border-radius: 50%;

        overflow: hidden;



        position: relative;

    }



    .avatar-preview img {

        width: 100%;

        height: 100%;

        object-fit: cover;

    }



    .avatar-upload input[type="file"] {

        display: none;

    }



    .camera-icon {

        position: absolute;

        bottom: 10px;

        right: 13px;

        cursor: pointer;

        font-size: 18px;

        background-color: #d5d5d5;

        color: black;

        border-radius: 50%;

        padding: 5px;

        width: 30px;

        height: 30px;

        display: flex;

        justify-content: center;

        align-items: center;

        z-index: 2;

        /*box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.3);*/

    }



    #modal_addNewEmp .form-section h3 {

        margin-bottom: 10px;

    }



    #modal_addNewEmp .input-group {

        margin-bottom: 15px;

    }



    #modal_addNewEmp .input-row {

        display: flex;

        gap: 15px;

        justify-content: space-between;

    }



    #modal_addNewEmp .input-group label {



        display: block;

        font-weight: bold;

        margin-bottom: 5px;

    }



    #modal_addNewEmp .input-group input[type="text"],

    #modal_addNewEmp .input-group input[type="date"],

    #modal_addNewEmp .input-group select {

        width: 100%;

        padding: 10px;

        border: 1px solid #ccc;

        border-radius: 5px;

    }





    #modal_addNewEmp .gender-options {

        display: flex;

        gap: 13px;

        margin-left: 10px;

    }



    #modal_addNewEmp .gender-option {

        position: relative;

        padding-left: 25px;

        cursor: pointer;

        font-size: 13px;



    }



    #modal_addNewEmp .gender-option input {

        position: absolute;

        opacity: 0;

    }



    #modal_addNewEmp .custom-radio {

        position: absolute;

        top: 50%;

        left: 0;

        transform: translateY(-50%);

        width: 20px;

        height: 20px;

        border: 2px solid #333;

        border-radius: 50%;



        transition: background-color 0.3s, border-color 0.3s;

    }



    #modal_addNewEmp .gender-option input:checked + .custom-radio {

        background-color: var(--background-color-radio);

        border-color: var(--text-color);

    }



    #modal_addNewEmp .gender-option:hover .custom-radio {

        border-color: #0d0d0d;

    }





    #modal_addNewEmp .button-group {

        display: flex;

        justify-content: flex-end;

        gap: 10px;

    }



    #modal_addNewEmp #modal_addNewEmp.btn-save {



        color: white;

        padding: 10px 20px;

        border: none;

        border-radius: 5px;

        cursor: pointer;

    }



    #modal_addNewEmp .btn-cancel {



        color: white;

        padding: 10px 20px;

        border: none;

        border-radius: 5px;

        cursor: pointer;

    }



    #modal_addNewEmp .btn-save:hover,

    #modal_addNewEmp .btn-cancel:hover {

        opacity: 0.8;

    }

    .suggestions-list {

        border-radius: 4px;

        max-height: 150px;

        overflow-y: auto;

        position: absolute;

        background-color: white;

        width: 225px;

        color:black;

        z-index: 1000;

        display: none;

    }

    .suggestion-item {

        padding: 8px;

        cursor: pointer;

    }



    .suggestion-item:hover {

       background: var(--background-color-hover);

       color: var(--text-color)

    }



   .calendar-icon {

        margin-top: 10px;

        position: absolute;

        right: 10px;

        top: 50%;

        transform: translateY(-50%);

        cursor: pointer;

        font-size: 20px;

        color: #888;

    }

    .modal-backdrop{

        z-index: 0 !important

    }

    .modal-backdrop.show{

        opacity: 0 !important;

    }

    .modal-content {

        border-radius: 12px;

        /*box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);*/

    }




    #profileImage_P {
        width: 160px !important;
        height: 160px !important;
        object-fit: cover !important;
        border-radius: 50% !important;
    }
</style>

<div class="modal fade" id="generalEditModal" tabindex="-1" aria-labelledby="generalEditModalLabel"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div class="modal-dialog modal-dialog-centered modal-lg" >

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="generalEditModalLabel"></h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''saveGeneralEditButton'')"></button>

            </div>

            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="general-edit-form">

                            <div class="mb-3">

                                <label for="" class="form-label">%lblHouseNumberHamlet%</label>

                                <input type="text" class="form-control" id="" onchange="UndisableButtonSend_P(''saveGeneralEditButton'')">

                            </div>

                        </form>

                    </div>

                </div>

            </div>

            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="saveGeneralEditButton" disabled><i class="fas fa-save"></i> '+N'%btnSend%</button>

                <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''saveGeneralEditButton'')"><i class="fas fa-times"></i> '+N'%Cancel%</button>

            </div>

        </div>

    </div>

</div>



<div class="modal fade" id="permanentResidenceModal_P" tabindex="-1" aria-labelledby="permanentResidenceModalLabel_P"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div class="modal-dialog modal-dialog-centered modal-lg" >

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="permanentResidenceModalLabel_P">%lblUpdatePermanentAddress%</h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''savePermanentResidenceButton_P'')"></button>

            </div>

            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="permanentResidenceForm_P">

                            <div class="mb-3">

                                <label for="city_P" class="form-label">%lblProvinceID%</label>

                                <select class="form-select" id="PermanentCity_P" onchange="filterDistrictsForPermanentEdit_P(); UndisableButtonSend_P(''savePermanentResidenceButton_P'')">

                                    <option value="-1">%lblSelectProvinceCity%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="district_P" class="form-label">%BirthCert_DistrictID%</label>

                                <select class="form-select" id="PermanentDistrict_P" onchange="filterWardsForPermanentEdit_P(); UndisableButtonSend_P(''savePermanentResidenceButton_P'')">

                                    <option value="-1">%lblSelectDistrict%</option>



                                </select>

                            </div>

                            <div class="mb-3">

















<label for="ward_P" class="form-label">%lblWard%</label>

                                <select class="form-select" id="PermanentWard_P" onchange="UndisableButtonSend_P(''savePermanentResidenceButton_P'')">

                                    <option value="-1">%lblSelectWard%</option>

                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="address_P" class="form-label">%lblHouseNumberHamlet%</label>

                                <input type="text" class="form-control" id="PermanentAddress_P" onchange="UndisableButtonSend_P(''savePermanentResidenceButton_P'')">

                            </div>

                        </form>

                    </div>

                </div>

            </div>

            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="savePermanentResidenceButton_P" disabled><i class="fas fa-save"></i> '+N'%btnSend%</button>

                <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''savePermanentResidenceButton_P'')"><i class="fas fa-times"></i> '+N'%Cancel%</button>

            </div>

        </div>

    </div>

</div>



<div class="modal fade" id="temporaryResidenceModal_P" tabindex="-1" aria-labelledby="temporaryResidenceModalLabel"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div class="modal-dialog modal-dialog-centered modal-lg" >

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="temporaryResidenceModalLabel_P">%lblUpdateTemporaryAddress%</h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''saveTemporaryResidenceButton_P'')"></button>

            </div>

            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="temporaryResidenceForm_P">



                            <div class="mb-3">

                                <label for="city_P" class="form-label">%lblProvinceID%</label>

                                <select class="form-select" id="ResidenceCity_P" onchange="filterDistrictsByGroupEdit_P(); UndisableButtonSend_P(''saveTemporaryResidenceButton_P'')">

                                    <option value="-1">%lblSelectProvinceCity%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="district_P" class="form-label">%BirthCert_DistrictID%</label>

                                <select class="form-select" id="ResidenceDistrict_P" onchange="filterWardsByGroupEdit_P(); UndisableButtonSend_P(''saveTemporaryResidenceButton_P'')">

                                    <option value="-1">%lblSelectDistrict%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="ward_P" class="form-label">%lblWard%</label>

                                <select class="form-select" id="ResidenceWard_P" onchange="UndisableButtonSend_P(''saveTemporaryResidenceButton_P'')">

                                    <option value="-1">%lblSelectWard%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="address_P" class="form-label">%lblHouseNumberHamlet%</label>

                                <input type="text" class="form-control" id="ResidenceAddress_P" onchange="UndisableButtonSend_P(''saveTemporaryResidenceButton_P'')">

                            </div>

                        </form>

                  </div>

 </div>



           </div>



































            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="saveTemporaryResidenceButton_P" disable><i class="fas fa-save"></i> '+N'%btnSend%</button>

                <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''saveTemporaryResidenceButton_P'')"><i class="fas fa-times"></i> '+N'%Cancel%</button>

            </div>

        </div>

    </div>

</div>



<div class="modal fade" id="editEmployeeInfoModal_P" tabindex="-1" aria-labelledby="editEmployeeInfoModalLabel"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div class="modal-dialog modal-dialog-centered modal-lg">

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="editEmployeeInfoModalLabel_P">%lblEditEmployeeInfo%</h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''saveEmployeeInfoButton_P'')"></button>

            </div>

            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="employeeInfoForm_P">

                            <div class="mb-3">

                                <label for="birthDate_P" class="form-label">%Birthday%</label>

                                <input type="text" class="form-control" id="birthDateEdit_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                <div class="error-message" id="birthDateEditError_P" style="color: red; display: none;"></div>

                            </div>

                            <div class="mb-3">

                                <label for="birthPlace_P" class="form-label">%BirthPlace%</label>

                                <select class="form-select" id="birthPlace_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                    <option value="-1">%lblSelectPlaceOfBirth%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="maritalStatus_P" class="form-label">%lblMaritalStatusID%</label>

                                <select class="form-select" id="maritalStatus_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                    <option value="-1">%lblSelectMaritalStatus%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="ethnicity_P" class="form-label">%Ethnic%</label>

                                <select class="form-select" id="ethnicity_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                    <option value="-1">%lblSelectEthnicity%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="religion_P" class="form-label">%lblReligionID%</label>

                                <select class="form-select" id="religion_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                    <option value="-1">%lblSelectReligion%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="idCard_P" class="form-label">CMND/CCCD</label>

                                <input type="number" class="form-control" id="idCard_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                            </div>

                            <div class="mb-3">

       <label for="issueDate_P" class="form-label">%lblIssueDate%</label>

                                <input type="text" class="form-control" id="issueDate_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                <div class="error-message" id="issueDateError_P" style="color: red; display: none;"></div>

                            </div>

                            <div class="mb-3">

                                <label for="issuePlace_P" class="form-label">%WorkPermit_Issue_Place%</label>

                                <select class="form-select" id="issuePlace_P" onchange="UndisableButtonSend_P(''saveEmployeeInfoButton_P'')">

                                    <option value="-1">%lblSelectPlaceOfIssue%</option>



                                </select>

                            </div>

                        </form>

                    </div>

                </div>

            </div>

            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="saveEmployeeInfoButton_P" disabled><i class="fas fa-save"></i> '+N'%btnSend%</button>

                <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''saveEmployeeInfoButton_P'')"><i class="fas fa-times"></i> '+N'%Cancel%</button>

            </div>

        </div>

    </div>

</div>



<div class="modal fade" id="editBankInfoModal_P" tabindex="-1" aria-labelledby="editBankInfoModalLabel"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div class="modal-dialog modal-dialog-centered modal-lg">

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="editBankInfoModalLabel_P">%lblEditBankInfo%</h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''saveBankInfoButton_P'')"></button>

            </div>



            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="bankInfoForm_P">

                            <div class="mb-3">

                                <label for="accountNumberEdit_P" class="form-label">%lblAccountNo%</label>

                                <input type="text" class="form-control" id="accountNumberEdit_P" value="" onchange="UndisableButtonSend_P(''saveBankInfoButton_P'')">

                            </div>

                            <div class="mb-3">

                                <label for="accountHolderNameEdit_P" class="form-label">%lblAccountName%</label>

                                <input type="text" class="form-control" id="accountHolderNameEdit_P" value="" onchange="UndisableButtonSend_P(''saveBankInfoButton_P'')">

                            </div>

                            <div class="mb-3">

                                <label for="bankNameEdit_P" class="form-label">%BankName%</label>

                                <select class="form-select" id="bankNameEdit_P" onchange="UndisableButtonSend_P(''saveBankInfoButton_P'')">

                                    <option value="-1">%lblSelectBank%</option>



                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="taxCodeEdit_P" class="form-label">%lblTaxRegNo%</label>

                                <input type="text" class="form-control" id="taxCodeEdit_P" value="" onchange="UndisableButtonSend_P(''saveBankInfoButton_P'')">

                            </div>

                        </form>

                    </div>

                </div>

            </div>



            <!-- Modal Footer -->

            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="saveBankInfoButton_P" disabled> <i class="fas fa-save"></i> '+N'%btnSend%</button>

 <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''saveBankInfoButton_P'')"><i class="fas fa-times"></i> '+N'%Cancel%</button>

            </div>

        </div>

    </div>

</div>



<div class="modal fade" id="editEmployeeModal_P" tabindex="-1" aria-labelledby="editEmployeeModalLabel"  style="background-color: rgba(0, 0, 0, 0.7);"  data-bs-hrm="modal-input">

    <div style="margin-top: 5%" class="modal-dialog modal-dialog-centered  modal-lg">

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title" id="editEmployeeModalLabel_P">%lblEditInformation%</h5>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="DisableButtonSend(''saveEmployeeButton_P'')"></button>

            </div>



            <div class="modal-body">

                <div class="card">

                    <div class="card-body">

                        <form id="employeeForm_P">

                            <div class="avatar-upload">

                                <div class="avatar-preview" id="avatarPreview_P">

                                    <img id="avatarImageEdit_P" src="">

                                    <label for="avatarUploadNew_P" class="camera-icon">

                                        <i style="color:gray" class="bi bi-camera-fill"></i>

                                    </label>



                                </div>

                                <input type="file" id="avatarUploadNew_P" onchange="loadAvatarEdit_P(event)" accept="image/*" />

                            </div>

                            <div class="mb-3">

                                <label for="employeeID_P" class="form-label">%lblEmployeeID% (<span style="color: red;">*</span>)</label>

                                <input type="text" class="form-control" id="employeeIDEditData_P" readonly>

                            </div>

                            <div class="mb-3">

                                <label for="fullName_P" class="form-label">%lblFullName% (<span style="color: red;">*</span>)</label>

                                <input type="text" class="form-control" id="fullNameEditData_P" onchange="UndisableButtonSend_P(''saveEmployeeButton_P'')">

                            </div>



                            <div class="mb-3">

                                <label for="phoneNumber_P" class="form-label">%lbPhoneNumber%</label>

                                <input type="text" class="form-control" id="phoneNumberEditData_P" onchange="UndisableButtonSend_P(''saveEmployeeButton_P'')">

                            </div>

                            <div class="mb-3">

                                <label for="gender_P" class="form-label">%Gender%</label>

                                <select class="form-select" id="genderEditData_P" onchange="UndisableButtonSend_P(''saveEmployeeButton_P'')">

                                    <option value="Nam">%Boy%</option>

                                    <option value="Nữ">%Female%</option>

                                </select>

                            </div>

                            <div class="mb-3">

                                <label for="email_P" class="form-label">Email</label>

                                <input type="email" class="form-control" id="emailEditData_P" onchange="UndisableButtonSend_P(''saveEmployeeButton_P'')">

                            </div>

                        </form>

                    </div>

                </div>

            </div>



            <!-- Modal Footer -->

            <div class="modal-footer">

                <button type="button" class="btn btn-success" id="saveEmployeeButton_P" disabled> <i class="fas fa-save"></i> '+N' %btnSend%</button>

    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" onclick="DisableButtonSend(''saveEmployeeButton_P'')"><i class="fas fa-times"></i>' +N' %Cancel%</button>



            </div>

        </div>

    </div>

</div>



<div id="EmployeeProfile_P" style="margin-left: 0.5%;">

<div id="profileContainer_P"></div>

    <div class="d-flex" >

       <div id="employeeDetailsContainer_P" style="width: 23%;margin-top:5%"></div>



        <div style="width: 2%;" class="">

        </div>



        <div style="width: 75%;height: 660px;height: 60vh;" data-bs-hrm="input-container">

            <div class="w-100 justify-content-center" style="display: none;">

                <img class="img-thumbnail rounded-circle" style="height: 10rem; aspect-ratio: 1; object-fit: cover;" data-bs-hrm="mobile-avatar">

            </div>



            <div style="margin-top:3.2%">

                <div id="employee-info_P" aria-labelledby="employee-info-tab">

                    <div class="card shadow-sm border-0 mb-4 d-none" style=" position: static !important;">

                        <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                            <h5 class="mb-0"><i class="bi bi-person-badge me-2"></i>%grbBasicInformation%</h5>

                            <button onClick="show_editEmployeeButton_P()" class="btn btn-outline-secondary text-body btn-sm">

                                <i class="bi bi-pencil-square"></i> %btnChange%

                            </button>

                        </div>

                        <div class="card-body" id="employeeInfoBasic_P">



                        </div>

                    </div>



                     <!-- Employee Information -->

                    <div class="card shadow-sm border-0 mb-4 d-none">

                        <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                            <h5 class="mb-0"><i class="bi bi-briefcase me-2"></i>%lblJobInformation%</h5>

                            <button onClick="showEditOfficeModal()" class="btn btn-outline-secondary btn-sm text-body d-none">

                                <i class="bi bi-pencil-square"></i> %btnChange%

                            </button>

                        </div>

                        <div class="card-body" id="companyInfoBasic_P">



                        </div>

                    </div>



                    <!-- Bank Information -->

                    <div class="card shadow-sm border-0 mb-4 d-none">

                        <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                            <h5 class="mb-0"><i class="bi bi-bank me-2"></i>%lblBankInformation%</h5>

                            <button onClick="showEditBankInfoModal_P()" class="btn btn-outline-secondary btn-sm  text-body">

                                <i class="bi bi-pencil-square"></i> %btnChange%

                            </button>

                        </div>



                        <div class="card-body" id="bankInfoContainer_P">



                        </div>

                    </div>

                    <div class="card shadow-sm border-0 mb-4 d-none">

                        <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                            <h5 class="mb-0"><i class="bi bi-person me-2"></i>%grbPersonalInformation%</h5>

                            <button onClick="showEditEmployeeInfoModal_P()" class="btn btn-outline-secondary btn-sm  text-body">

                                <i class="bi bi-pencil-square"></i> %btnChange%

                            </button>

                        </div>

                        <div class="card-body" id="personalInfoContainer_P">



                        </div>

                    </div>

                    <div class="card shadow-sm border-0 mb-4 d-none">

                        <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                            <h5 class="mb-0"><i class="bi bi-bank me-2"></i>%CurrentAddress%</h5>

                            <button onClick="showTemporaryResidenceModal_P()" class="btn btn-outline-secondary btn-sm  text-body">

                                <i class="bi bi-pencil-square"></i> %btnChange%

                            </button>

                        </div>

                        <div class="card-body" id="provinceInfoContainer_P">



                        </div>

                    </div>



                    <div class="card shadow-sm border-0 mb-4 d-none">

                    <div class="card-header bg-body text-body d-flex justify-content-between align-items-center">

                        <h5 class="mb-0"><i class="bi bi-bank me-2"></i>%PermanentAddress%</h5>

                        <button onClick="showPermanentResidenceModal_P()" class="btn btn-outline-secondary btn-sm  text-body">



                            <i class="bi bi-pencil-square"></i> %btnChange%

                        </button>

                    </div>

                    <div class="card-body" id="permanentAddressContainer_P">



                    </div>

                </div>









            </div>



        </div>



    </div>

</div>



<script>



var EmployeeIDList = [];

var EmployeeIDListWithFullName = [];

var thongTinNhanVien;

var dataFieldList;

var dataDisplaySetting;

var todayPicker = new Date().toISOString().split("T")[0];

var isDOBWrong = false;

var imageTempEdit;

var EmployeeIDNow;

if (typeof HR_StaffInformation_ForUserWeb.DataFieldLookupList === "undefined")

    HR_StaffInformation_ForUserWeb.DataFieldLookupList = [];



async function api_loadDataEmployee_P(EmployeeID) {

    showLoadingByClassOrID("#EmployeeProfile_P", "%lblLoadingEmployeeData%", "Black", "Black");

    await AjaxHPAParadiseAsync({

        data: {

            name: "HR_StaffInformation_List_2_Data",

            param: ["LoginID", LoginID, "EmployeeID", EmployeeID, "LanguageID", LanguageID]

        },

        success: async function (result) {

            let parsedData = JSON.parse(result).data;



            thongTinNhanVien = parsedData[0];

            dataDisplaySetting = parsedData.pop();

            dataFieldList = parsedData.pop();

            EmployeeIDNow = thongTinNhanVien[0].EmployeeID

            if(thongTinNhanVien.length  < 1){

                showNotificationModal("Lỗi hiển thị nhân viên, vui lòng thử lại sau.", "%barCancel%", "primary", () => {

                    HideLoadingByClassOrID("#HR_StaffInformation_ForUserWeb");

                    return;

                });

            }

            //render_thongTinNhanVien_P(thongTinNhanVien);



            RenderEmployeeInformationByGroup(dataFieldList, dataDisplaySetting, thongTinNhanVien);



            setTimeout(function () {

                // api_GetDataDivDepSecPos_P();

            }, 0);



            let avatarElement = $("#profileImage_P");

		

            imageTempEdit = thongTinNhanVien[0]?.PhotoImage || "";

            //avatarElement.attr("src", imageTempEdit ? "data:image/jpeg;base64," + imageTempEdit : ImageParadiseDefault);



            //avatarElement.attr("src", thongTinNhanVien[0]?.ImageUrl)

            let decoded_param = decodeURIComponent(thongTinNhanVien[0]?.paramImg); //LuongNQ

            let storeImgName = thongTinNhanVien[0]?.storeImgName;



                        if (typeof callImg_with_loginID_or_employeeID === ''function'') {
                await callImg_with_loginID_or_employeeID(avatarElement, null, EmployeeID);
            } else if (typeof window.callImg_with_loginID_or_employeeID === ''function'') {
                await window.callImg_with_loginID_or_employeeID(avatarElement, null, EmployeeID);
            } else {
                avatarElement.attr(''_name'', storeImgName);
                avatarElement.attr(''_param'', decoded_param);
                await callImg(avatarElement);
            }



            $("#avatar-edit-for-user").attr("src", avatarElement.attr("src"))



            $(`[data-bs-hrm="input-container"] img[data-bs-hrm="mobile-avatar"]`).attr("src",  avatarElement.attr("src"));

			$(`[data-bs-hrm="mobile-avatar"]`).attr(`data-employee-id`, window.EmployeeID_Login);

			loadEmployeeFrameAssignments();



            HideLoadingByClassOrID("#HR_StaffInformation_ForUserWeb");



            let tmpProvinceID = thongTinNhanVien[0]?.tmpProvinceID;

      let tmpDistrictID = thongTinNhanVien[0]?.tmpDistrictID;

            let provinceID = thongTinNhanVien[0]?.ProvinceID;

            let districtID = thongTinNhanVien[0]?.DistrictID;

            // if (tmpProvinceID && tmpDistrictID) api_loadTamTru_P(tmpProvinceID, tmpDistrictID);

            // if (provinceID && districtID) api_loadThuongTru_P(provinceID, districtID);





            //render_backGroundColor_ProfileHeader();



            //HideLoadingByClassOrID("#HR_StaffInformation_ForUserWeb");

            //Button mở template file mẫu

            // $("#btnImportTemplate").on("click", function () {

            //     showLoadingByClassOrID("#EmployeeProfile_P", "%lblLoadingImportTemplate%", "Black", "Black");

            //

            //     window.POptionDic["HR_StaffInformation_ForUserWeb"].OnExport("template_importemployeeprofile_P");

            //

            //

            //     setTimeout(function () {

            //         HideLoadingByClassOrID("#HR_StaffInformation_ForUserWeb");

            //     }, 3000);

            // });

            //Button phóng to hình ảnh đại diện

            $("#profileImage_P").on("click", function () {

                let imgSrc = $(this).attr("src");

                $("#zoomed-profileImage_P").attr("src", imgSrc).css({

                    "max-width": "auto",

                    "max-height": "auto",

                    "width": "250px",

                    "height": "250px",

                    "border": "none",

                    "border-radius": "0",

                    "display": "block"

                });

				loadEmployeeFrameAssignments();



                $("#overlay-profileImage_P").css({

                    "position": "fixed",

                    "top": "0",

                    "left": "0",

                    "width": "100%",

                    "height": "100%",

                    "background": "rgba(0, 0, 0, 0.7)",

                    "display": "flex",

                    "justify-content": "center",

                    "align-items": "center",

                    "z-index": "1000"

                });

            });



            $("#overlay-profileImage_P").on("click", function () {

                $(this).hide();

                $("#zoomed-profileImage_P").hide();

            });







            // LoadSelectionValueForDataField();

        },

        error: function () {

            HideLoadingByClassOrID("#HR_StaffInformation_ForUserWeb");

        }

    });

}





async function RenderEmployeeInformationByGroup(

    dataFieldGroup,

    dataDisplaySetting,

    employeeData

) {

    var checkPhoto = employeeData?.[0]?.PhotoImage || null;

    var PhotoImageEmp = employeeData[0].ImageUrl;

    /*

    lUONGnQ

    if (checkPhoto) {

        PhotoImageEmp = "data:image/png;base64," + employeeData[0].PhotoImage;

    } else {

        PhotoImageEmp = ImageParadiseDefault;

    } */



    var container = document.getElementById("profileContainer_P");

    container.innerHTML = `

<div id="profile-header_P" class="profile-header" style="position: relative;">

    <img id="profileImage_P" data-employee-id=''${window.EmployeeID_Login}'' src=''${PhotoImageEmp}'' alt="Profile Picture">

    <div class="profile-info">

        <p style="font-size: 2rem;">${employeeData[0].FullNameNew}</p>

        <p style="font-size: 1.5rem;" class="position-name mb-0">${employeeData[0].PositionName}</p>

    </div>



    <div id="overlay-profileImage_P" style="display: none;">

        <img id="zoomed-profileImage_P" data-employee-id=''${window.EmployeeID_Login}'' src="" alt="Zoomed Image" style="display: none;">

    </div>

</div>

    `;



    var containerDetail = document.getElementById("employeeDetailsContainer_P");



    containerDetail.innerHTML = `



<div>

    <div class="card shadow-sm border-0 mb-4">

        <div class="card-body">

            <h4 class="">

                <i class="bi bi-person-circle me-2"></i>%lblIntroduction%

            </h4>

            <hr />

            <ul class="list-unstyled">

     <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%lbPhoneNumber%"

                            class="bi bi-telephone-fill text-body me-2"

                        ></i>

                        <!--<strong>%lbPhoneNumber%:</strong> -->

                    </div>

                    <div class="col-11">

           <span class="value"



         >${thongTinNhanVien[0].MobilePhone || ""}</span

        >

                 </div>

            </li>

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="'+N'Email"

                            class="bi bi-envelope-fill text-body me-2"

                        ></i>

                        <!--<strong>Email:</strong>-->

                    </div>

                    <div class="col-11">

                        <span class="value"

                            >${thongTinNhanVien[0].Email || ""}</span

                        >

                    </div>

                </li>

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%HireDate%"

                            class="bi bi-calendar-check-fill text-body me-2"

                        ></i>

                        <!--<strong>%HireDate%:</strong>-->

                    </div>

                    <div class="col-11">

                        <span class="value"

                            >${thongTinNhanVien[0].HireDateName || ""}</span

                        >

                    </div>

                </li>

                <li class="row">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%Seniority%"

                            class="bi bi-clock-history text-body me-2"

                        ></i>

                        <!--<strong>%Seniority%:</strong>-->

                    </div>

                    <div class="col-11">

                        <span class="value"

                            >${thongTinNhanVien[0].Seniority || ""}</span

                        >

                    </div>

                </li>

            </ul>

        </div>

    </div>



    <div class="card shadow-sm border-0 mb-4">

        <div class="card-body">

            <h4 class="">

                <i class="bi bi-clipboard-data me-2"></i>%lblOverview%

            </h4>

            <hr />

            <ul class="list-unstyled">

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%colPosition%"

                            class="bi bi-person-badge-fill text-body me-2"

                        ></i>

                        <!--<strong>%colPosition%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].PositionName || ""}

                    </div>

                </li>

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%Department%"

                            class="bi bi-building text-body me-2"

                        ></i>

                        <!--<strong>%Department%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].DepartmentName || ""}

                    </div>

                </li>

                <li class="row">

   <div class="col-1 d-flex align-items-center">

                        <i

                            title="%DivisionID%"

    class="bi bi-people-fill text-body me-2"



                        ></i>

                        <!--<strong>%DivisionID%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].DivisionName || ""}

                    </div>

                </li>

            </ul>

        </div>

    </div>

    <div class="card shadow-sm border-0">

       <div class="card-body">

 <h4 class=" ">

                <i class="bi bi-briefcase-fill me-2"></i>%colDepViewInfo%



            </h4>

            <hr />

            <ul class="list-unstyled">

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

               <i

                            title="%lblLineManager_FullName%"

                            class="bi bi-person-badge text-body me-2"

                        ></i>

                        <!--<strong>%lblLineManager_FullName%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].LineManager_FullName_Label || ""}

                    </div>

                </li>

                <li class="row mb-2">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%colPosition%"

                            class="bi bi-briefcase text-body me-2"

                        ></i>

                        <!--<strong>%colPosition%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].LineManager_PositionName || ""}

                    </div>

                </li>

                <li class="row">

                    <div class="col-1 d-flex align-items-center">

                        <i

                            title="%lbPhoneNumber%"

                            class="bi bi-telephone text-body me-2"

                        ></i>

                        <!--<strong>%lbPhoneNumber%:</strong>-->

                    </div>

                    <div class="col-11">

                        ${thongTinNhanVien[0].LineManager_Mobible || ""}

                    </div>

                </li>

            </ul>

        </div>

    </div>

</div>



    `;



    dataFieldGroup = dataFieldGroup.sort((a, b) => a.TypeID - b.TypeID);



    $("#employee-info_P").html("");



    dataFieldGroup.forEach((x) => {

        $("#employee-info_P").append(

            `<div class="card shadow-sm border-0 mb-4" style="position: static !important" data-bs-hrm-container="${x.TypeID}">

        <div

            class="card-header bg-body text-body d-flex justify-content-between align-items-center"

        >

            <h5 class="mb-0">

                <i class="${x.DataFieldIcon} me-2"></i>${x.Description}

            </h5>

            <button onClick="ShowEmployeeEditModal(''${x.Description}'', ''${x.TypeID}'')" class="btn btn-outline-secondary text-body btn-sm">

                <i class="bi bi-pencil-square"></i> %btnChange%

            </button>

        </div>

        <div class="card-body" data-bs-hrm-group="${x.TypeID}"></div>

    </div>

    `

        );

    });



    // dataDisplaySetting.find((x) => x.ColumName == "PhotoImage").Visible = false;



    dataFieldGroup.forEach((group) => {

        let groupDataField = dataDisplaySetting.filter(

            (x) => x.TypeID == group.TypeID

        );



        if (!groupDataField.some((x) => x.isEdit))

            $(

                `div.card[data-bs-hrm-container="${group.TypeID}"]>.card-header>button`

            ).addClass("d-none");



        groupDataField

            .sort((a, b) => a.ORDs - b.ORDs)

            .forEach((dataField) => {

                if (dataField.Visible && dataField.ControlType != "PictureEdit") {

                    // console.log(

                    //     `🚀 ~ employeeData[0]["${dataField.ColumName}"]:`,

//    employeeData[0][

                    //         dataField.ColumName.replace(/ID$/i, "") + "Name"

                    //     ] ??

                    //         employeeData[0][dataField.ColumName + "New"] ??

                    //         employeeData[0][dataField.ColumName]

                    // );

                    $(

                        `div.card-body[data-bs-hrm-group="${group.TypeID}"]`

                 ).append(

  `<div class="row mb-3">



            <label class="col-sm-3 col-form-label" for="${

            dataField.ColumName + "_Static_P"

            }"

                >${dataField.LabelContent} :</label

            >

            <div class="col-sm-9">

                <input type="text" class="form-control"

                id = "${dataField.ColumName + "_Static_P"}"

                value="${

                    employeeData[0][

                        dataField.ColumName.replace(/ID$/i, "") + "Name"

                    ] ??

                    employeeData[0][dataField.ColumName + "New"] ??

                    employeeData[0][dataField.ColumName] ??

                    ""

                }" readonly>

            </div>

        </div>`

                    );

                }

            });

    });

}







async function BuildDataFieldInputHTML(dataField, value, valueText) {

    let inputHTML = `<div class="row mb-3 ${dataField.Visible ? "" : "d-none"}">

            <label class="col-sm-3 col-form-label" for="${

                dataField.ColumName + "_Input_P"

            }"

                >${dataField.LabelContent} :</label

            >

            <div class="col-sm-9">

                <input type="text" class="form-control ${

                    dataField.awaitApproved ? "await-approval" : ""

                }" data-bs-hrm-input="${dataField.ColumName}"

                id = "${dataField.ColumName + "_Input_P"}"

                value="${

                    dataField.awaitApproved

                        ? HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList.find(

                              (x) => x.FieldNameCode == dataField.ColumName

                          ).NewValue

                        : valueText ?? value

                }" ${

        dataField.isEdit && !dataField.awaitApproved ? "" : "readonly"

    }

                onchange="UndisableButtonSend_P(''saveGeneralEditButton'')">

            </div>

        </div>`;

    let afterAppendFunction;



    if (dataField.ControlType == "PictureEdit") {

        inputHTML = `

<div class="avatar-upload ${dataField.Visible ? "" : "d-none"}"">

    <div class="avatar-preview rounded-circle ${

        dataField.awaitApproved ? "await-approval" : ""

    }">

        <img data-employee-id=''${window.EmployeeID_Login}'' id="avatar-edit-for-user" src=''${

            (dataField.awaitApproved

                ? "data:image/jpeg;base64," + HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList.find(

                      (x) => x.FieldNameCode == dataField.ColumName

                  ).NewValueP

                : $("#UserAvatar").attr("src"))

        }'' data-bs-hrm-input="${dataField.ColumName}">

        <label for="avatarUploadNew1_P" class="camera-icon ${

            dataField.isEdit && !dataField.awaitApproved ? "" : "d-none"

        }">

            <i style="color:gray" class="bi bi-camera-fill"></i>

        </label>



    </div>

    <input type="file" id="avatarUploadNew1_P" onchange="loadAvatarEdit_P(event, ''avatar-edit-for-user'', ''saveGeneralEditButton'')" accept="image/*" ${

        dataField.isEdit && !dataField.awaitApproved ? "" : "readonly"

    }/>

</div>

        `;



    }



    if (dataField.ControlType == "DateTimeEdit") {

        inputHTML = `

        <div class="row mb-3 ${dataField.Visible ? "" : "d-none"}">

            <label class="col-sm-3 col-form-label" for="${

                dataField.ColumName + "_Input_P"

            }"

                >${dataField.LabelContent} :</label

>

            <div class="col-sm-9">

                <${dataField.isEdit && !dataField.awaitApproved ? "div" : "input"} type="text" class="form-control px-2 ${

                    dataField.awaitApproved ? "await-approval" : ""

                }" data-bs-hrm-input="${dataField.ColumName}"

                id = "${dataField.ColumName + "_Input_P"}"

 value="${

                    dataField.awaitApproved

 ? HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList.find(

                              (x) => x.FieldNameCode == dataField.ColumName

                          ).NewValue

                        : valueText ?? value

                }" ${

            dataField.isEdit && !dataField.awaitApproved ? "" : "readonly"

        }

                raw-value="${value}"

                onchange="UndisableButtonSend_P(''saveGeneralEditButton'')">

            </div>

        </div>`;



        afterAppendFunction = () => {

            if (dataField.isEdit && !dataField.awaitApproved)

                initDateBox_P(

                    `[data-bs-hrm-input="${dataField.ColumName}"]`,

                    `label[for="${dataField.ColumName + "_Input_P"}"]`,

                    value,

                    false,

                    {

                        inputAttr: {

                            class: "p-0",

                            "aria-owns": null

                        }

                    }

                );

        };

    }



    if (dataField.ControlType == "SearchLookUpEdit") {

        inputHTML = `

        <div class="row mb-3 ${dataField.Visible ? "" : "d-none"}">

       <label class="col-sm-3 col-form-label" for="${

           dataField.ColumName + "_Input_P"

       }"

                >${dataField.LabelContent} :</label>

            <div class="col-sm-9">

                <div class="form-control ${

                    dataField.awaitApproved ? "await-approval" : ""

                }" data-bs-hrm-input="${dataField.ColumName}"

                ${

                    dataField.isEdit && !dataField.awaitApproved

                        ? ""

                        : "disabled"

                }>

                </div>

            </div>

        </div>`;



        afterAppendFunction = async () => {

            if (

                HR_StaffInformation_ForUserWeb.comboBox[dataField.Query] &&

                !dataField.DataSettingSource

            ) {

                dataField.DataSettingSource =

                    HR_StaffInformation_ForUserWeb.comboBox[dataField.Query];

            }



            if (!dataField.DataSettingSource || Object.values(HR_StaffInformation_ForUserWeb.comboBoxDataSchema).length == 0) {

                let params = [];



                dataField.QueryParams?.split("|").forEach((param) => {

                    let paramValue =

                        window[param.replace("@", "")] ??

                        thongTinNhanVien[0][param];

                    params.push(param);

                    params.push(paramValue);

                });



                let result = await AjaxHPAParadiseAsync({

                    data: {

                        name: dataField.Query,

                        param: params,

                    },

                    success: function (result) {},

                });



                let data = JSON.parse(result).data[0];



                // data.forEach(x => {

                //     x.searchText = toLowerCaseNonAccentVietnamese(x[JSON.parse(result).dataSchema[0][1].name]);

                // });



                data.forEach(x => {

                    x.getSearchText =  () => {

                        return toLowerCaseNonAccentVietnamese(x[JSON.parse(result).dataSchema[0][1].name]);

                    }

                });



                dataField.DataSettingSource = data;

                HR_StaffInformation_ForUserWeb.comboBox[dataField.Query] =

    dataField.DataSettingSource;

       HR_StaffInformation_ForUserWeb.comboBoxDataSchema[

                    dataField.Query

                ] = JSON.parse(result).dataSchema[0];

            }



            let columnIDName =

                HR_StaffInformation_ForUserWeb.comboBoxDataSchema[

                    dataField.Query

                ][0].name;

            let columnDescriptionName =

 HR_StaffInformation_ForUserWeb.comboBoxDataSchema[

                    dataField.Query

                ][1].name;

            let columnParentIDName =

                HR_StaffInformation_ForUserWeb.comboBoxDataSchema[

                    dataField.Query

                ][2]?.name;



            let dataSource = columnParentIDName

                ? dataField.DataSettingSource.filter(



                      (x) =>

                     x[columnParentIDName] ==

                          thongTinNhanVien[0][

                              dataField.ColumName.replace(columnIDName, "") +

                                  columnParentIDName

                          ]

                  )

                : dataField.DataSettingSource;



             value = dataField.awaitApproved

                ? dataSource.find(

                      (data) =>

                          data[columnIDName] ==

                          HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList.find(

                              (x) => x.FieldNameCode == dataField.ColumName

                          ).NewValueCode

                  )[columnIDName]

                : value;



            $(`[data-bs-hrm-input="${dataField.ColumName}"]`).dxDropDownBox({

                dataSource: dataSource,

                displayExpr: columnDescriptionName,

                valueExpr: columnIDName,

                value: value,

                // acceptCustomValue: true,

                stylingMode: "outlined",

                // disabled: dataField.isEdit && dataField.awaitApproved,

                readOnly: dataField.isEdit && dataField.awaitApproved,

                // inputAttr: {

                //     id: (dataField.ColumName + "_Input_P"),

                // },

                dropDownOptions: {

                    container: "#generalEditModal",

                    shading: IsMobile(),

                    // position: {

                    //     my: "left top",

                    //     at: "left bottom",

                    //     collision: "flipfit",

                    // },

                    height: dataSource.length > 20 ? "40vh" : "auto",

                    maxHeight: "45vh",

                    minWidth: "10vw",

                    width: "100%",

                    maxWidth: IsMobile() ? "80vw" : $(`[data-bs-hrm-input="${dataField.ColumName}"]`).innerWidth() /* "60vw" */,

                    wrapperAttr: {

                        class: "dx-data-setting-dropdown",

                    },

                    toolbarItems: [

                        {

                            widget: "dxButton",

                            toolbar: "bottom",

                            location: "before",

                            options: {

                                text: "%Reload%",

                                onClick: async function () {

                                    let params = [];



                                    dataField.QueryParams?.split("|").forEach((param) => {

                                        let paramValue =

                                            window[param.replace("@", "")] ??

                                            thongTinNhanVien[0][param];

                                        params.push(param);

    params.push(paramValue);

                                    });



                                    let result = await AjaxHPAParadiseAsync({

data: {

               name: dataField.Query,

                             param: params,



      },

                                        success: function (result) {},

                                    });



                                    let data = JSON.parse(result).data[0];



          // data.forEach(x => {

                 //     x.searchText = toLowerCaseNonAccentVietnamese(x[JSON.parse(result).dataSchema[0][1].name]);

                                    // });



                                    data.forEach(x => {

                                        x.getSearchText =  () => {

                                            return toLowerCaseNonAccentVietnamese(x[JSON.parse(result).dataSchema[0][1].name]);

                                        }

                                    });





                                    dataField.DataSettingSource = data;

                                    HR_StaffInformation_ForUserWeb.comboBox[dataField.Query] =

                                        dataField.DataSettingSource;

                                    HR_StaffInformation_ForUserWeb.comboBoxDataSchema[

                                        dataField.Query

                                    ] = JSON.parse(result).dataSchema[0];



                                    let datasource = columnParentIDName

                                        ? dataField.DataSettingSource.filter(

                                              (x) =>

                                                  x[columnParentIDName] ==

                                                  thongTinNhanVien[0][

                                                      dataField.ColumName.replace(columnIDName, "") +

                                                          columnParentIDName

                                                  ]

                                          )

                                        : dataField.DataSettingSource;



                                    $(`[data-bs-hrm-input="${dataField.ColumName}"]`)

                                        .dxDropDownBox("instance")

                                        .option("dataSource", datasource);



                                    $(`[data-bs-hrm-input="${dataField.ColumName}"]`)

                                        .dxDropDownBox("instance")

                                        .option("contentList")

                                        .option("dataSource", datasource);

                                },

                            },

                        },

                        {

                            widget: "dxButton",

                            toolbar: "bottom",

                            location: "after",

                            options: {

                                text: "%ClearEditValue%",

                                onClick: async function () {



                                },

                            },

                        },

                    ],

                    onShowing: function (arg) {

                        arg.component.option("maxWidth", IsMobile() ? "80vw" : $(`[data-bs-hrm-input="${dataField.ColumName}"]`).innerWidth() /* "60vw" */);

                    }



                },

                onValueChanged: (arg) => {

                    arg.element.attr("value", arg.value);

                    UndisableButtonSend_P("saveGeneralEditButton");

                },

                contentTemplate: (arg) => {

                    let list = $("<div>").dxList({

                        dataSource: arg.component.option("dataSource"),

                        displayExpr: columnDescriptionName,

                        valueExpr: columnIDName,

                        keyExpr: columnIDName,

                        height: "100%",

      width: "100%",

                        selectionMode: "single",

 selectByClick: true,

                        selectedItemKeys: value,



    searchEnabled:



arg.component.option("dataSource")?.length > 20,

                        searchExpr: ["searchText", columnDescriptionName, "getSearchText"],

  searchTimeout: 300,

          searchEditorOptions: {

              disabled: false,

                            readOnly: false,

                            showClearButton: false,

                            valueChangeEvent: "keyup",

                            inputAttr: {

                                id: `search-${dataField.ColumName}`,

                                tabindex: 0,

                            }

                        },

                        elementAttr: {

                            class: `m-1 p-1 mxh-inherit ${

                                IsMobile() ? " h-100" : ""

                            }`,

                        },

                        onSelectionChanged: (e) => {

                            arg.value = e.addedItems[0]?.[columnIDName];

                            arg.component.option("value", arg.value);

                            arg.component.close();

                        },

                    });

                    arg.component.option(

                        "contentList",

                        list.dxList("instance")

                    );



                    setTimeout(() => {

                        let searchInput = list.find("input.dx-texteditor-input")[0];

                        if (searchInput) searchInput.focus();

                    });



                    return list;

                },

            });



  if (IsMobile()) {

                $(`[data-bs-hrm-input="${dataField.ColumName}"]`)

                    .dxDropDownBox("instance")

                    .option("dropDownOptions", {

                        position: {

                            my: "center",

                            at: "center",

                            of: "window",

             },

     maxHeight: "80vh",

                    });

            }



       if (

                columnParentIDName &&

              $(

                    `[data-bs-hrm-input="${

                        dataField.ColumName.replace(columnIDName, "") + columnParentIDName

                    }"]`

             ).length > 0

            ) {

                setTimeout(() => {

                    $(

                        `[data-bs-hrm-input="${

                            dataField.ColumName.replace(columnIDName, "") +

                            columnParentIDName

                        }"]`

                    )

                        .dxDropDownBox("instance")

                        .option("onValueChanged", (arg) => {

                            arg.element.attr("value", arg.value);

                            UndisableButtonSend_P("saveGeneralEditButton");



                            let dataSourceTemp =

                                dataField.DataSettingSource.filter(

                                    (x) => x[columnParentIDName] == arg.value

                                );



                            $(`[data-bs-hrm-input="${dataField.ColumName}"]`)

                                .dxDropDownBox("instance")

                                .option({

                                    value: -1,

                                    dataSource: dataSourceTemp,

                                });



                            if (

                                $(

                                    `[data-bs-hrm-input="${dataField.ColumName}"]`

                                )

                                    .dxDropDownBox("instance")

                                    .option("contentList")

                            ) {

                    $(

                               `[data-bs-hrm-input="${dataField.ColumName}"]`

          )

                                  .dxDropDownBox("instance")

                    .option("contentList")

               .option({



     selectedItemKeys: -1,

                                        dataSource: dataSourceTemp,

                   });



                            }

                        });

                }, 1500);

            }

        };



        if (

            !HR_StaffInformation_ForUserWeb.DataFieldLookupList.some(

                (x) => x.ColumName == dataField.ColumName

            )

        )

            HR_StaffInformation_ForUserWeb.DataFieldLookupList.push(dataField);

        else {

            let temp = HR_StaffInformation_ForUserWeb.DataFieldLookupList.find(

                (x) => x.ColumName == dataField.ColumName

            );

            Object.assign(temp, dataField);

        }

    }



    dataField["InputHTML"] = inputHTML;

    dataField["AfterAppendFunction"] = afterAppendFunction;

}









 function render_thongTinNhanVien_P(thongTinNhanVien){



  var checkPhoto = thongTinNhanVien?.[0]?.PhotoImage || null;

  var PhotoImageEmp;

  if(checkPhoto){

   PhotoImageEmp = "data:image/png;base64,"+thongTinNhanVien[0].PhotoImage;

  }else{

   PhotoImageEmp = ImageParadiseDefault;

  }



  var container = document.getElementById("profileContainer_P");

    container.innerHTML = `

    <div id="profile-header_P" class="profile-header" style="position: relative;">

    <img id="profileImage_P" data-employee-id=''${window.EmployeeID_Login}'' src="${PhotoImageEmp}" alt="Profile Picture">

    <div class="profile-info">

        <p style="font-size: 2rem;">${thongTinNhanVien[0].FullNameNew}</p>

   <p style="font-size: 1.5rem;" class="position-name mb-0">${thongTinNhanVien[0].PositionName}</p>

    </div>



 <div id="overlay-profileImage_P" style="display: none;">

    <img id="zoomed-profileImage_P" data-employee-id=''${window.EmployeeID_Login}'' src="" alt="Zoomed Image" style="display: none;">

</div>

    `;

  var containerDetail = document.getElementById("employeeDetailsContainer_P");



    containerDetail.innerHTML = `



            <div>

                <div class="card shadow-sm border-0 mb-4">

                    <div class="card-body">

                        <h4 class=""><i class="bi bi-person-circle me-2"></i>%lblIntroduction%</h4>

      <hr>

                        <ul class="list-unstyled">

       <li class="row mb-2">

        <div class="col-1 d-flex align-items-center">

         <i title="%lbPhoneNumber%" class="bi bi-telephone-fill text-body me-2"></i>

         <!--<strong>%lbPhoneNumber%:</strong> -->

        </div>

        <div class="col-11">



            <span class="value">${thongTinNhanVien[0].MobilePhone || ""}</span>

        </div>

       </li>

       <li class="row mb-2">

        <div class="col-1 d-flex align-items-center">

         <i title="'+N'Email" class="bi bi-envelope-fill text-body me-2"></i>

         <!--<strong>Email:</strong>-->

        </div>

        <div class="col-11">

         <span class="value">${thongTinNhanVien[0].Email || ""}</span>

        </div>

       </li>

       <li class="row mb-2">

        <div class="col-1 d-flex align-items-center">

         <i title="%HireDate%" class="bi bi-calendar-check-fill text-body me-2"></i>

         <!--<strong>%HireDate%:</strong>-->

        </div>

        <div class="col-11">



          <span class="value">${thongTinNhanVien[0].HireDateName || ""}</span>

        </div>

       </li>

       <li class="row">

        <div class="col-1 d-flex align-items-center">

         <i title="%Seniority%" class="bi bi-clock-history text-body me-2"></i>

         <!--<strong>%Seniority%:</strong>-->

        </div>

        <div class="col-11">

         <span class="value">${thongTinNhanVien[0].Seniority || ""}</span>

        </div>

       </li>

      </ul>



</div>

</div>



                <div class="card shadow-sm border-0 mb-4">

                <div class="card-body">

       <h4 class=""><i class="bi bi-clipboard-data me-2"></i>%lblOverview%</h4>

   <hr>

                 <ul class="list-unstyled">

       <li class="row mb-2">

        <div class="col-1 d-flex align-items-center">

         <i title="%colPosition%" class="bi bi-person-badge-fill text-body me-2"></i>

   <!--<strong>%colPosition%:</strong>-->

        </div>

        <div class="col-11">

         ${thongTinNhanVien[0].PositionName || ""}

        </div>

       </li>

       <li class="row mb-2">

        <div class="col-1 d-flex align-items-center">

         <i title="%Department%" class="bi bi-building text-body me-2"></i>

         <!--<strong>%Department%:</strong>-->

      </div>

        <div class="col-11">

         ${thongTinNhanVien[0].DepartmentName || ""}

        </div>

       </li>

       <li class="row">

        <div class="col-1 d-flex align-items-center">

         <i title="%DivisionID%" class="bi bi-people-fill text-body me-2"></i>

         <!--<strong>%DivisionID%:</strong>-->

        </div>

        <div class="col-11">

         ${thongTinNhanVien[0].DivisionName || ""}

        </div>

       </li>

      </ul>



                    </div>

               </div>

<div class="card shadow-sm border-0">

 <div class="card-body">

               <h4 class=" "><i class="bi bi-briefcase-fill me-2"></i>%colDepViewInfo%</h4>

                        <hr>

                       <ul class="list-unstyled">

      <li class="row mb-2">

       <div class="col-1 d-flex align-items-center">

        <i title="%lblLineManager_FullName%" class="bi bi-person-badge text-body me-2"></i>

        <!--<strong>%lblLineManager_FullName%:</strong>-->

       </div>

       <div class="col-11">

        ${thongTinNhanVien[0].LineManager_FullName_Label || ""}

       </div>

      </li>

      <li class="row mb-2">

       <div class="col-1 d-flex align-items-center">

        <i title="%colPosition%" class="bi bi-briefcase text-body me-2"></i>

        <!--<strong>%colPosition%:</strong>-->

       </div>

       <div class="col-11">

        ${thongTinNhanVien[0].LineManager_PositionName || ""}

       </div>

      </li>

      <li class="row">

       <div class="col-1 d-flex align-items-center">

  <i title="%lbPhoneNumber%" class="bi bi-telephone text-body me-2"></i>

        <!--<strong>%lbPhoneNumber%:</strong>-->

       </div>

       <div class="col-11">

        ${thongTinNhanVien[0].LineManager_Mobible || ""}

       </div>

      </li>

     </ul>



                    </div>

                </div>

            </div>

    `;



 var employeeInfoBasic = document.getElementById("employeeInfoBasic_P");



    employeeInfoBasic.innerHTML = `

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblEmployeeID% <span class="text-danger">*</span>:</label>

  <div class="col-sm-9">

                <input id="EmployeeHR_P" type="text" class="form-control" value="${thongTinNhanVien[0].EmployeeID || ""}" readonly>

           </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%FullName% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].FullNameNew || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lbPhoneNumber%:</label>

        <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].MobilePhone || ""}" readonly>

            </div>

   </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%Gender%:</label>

            <div class="col-sm-9">

         <input type="text" class="form-control" value="${thongTinNhanVien[0].SexName || ""}" readonly>

  </div>

        </div>

        <div class="row mb-3">

  <label class="col-sm-3 col-form-label">%HireDate% <span class="text-danger">*</span>:</label>

       <div class="col-sm-9">

 <input type="text" class="form-control" value="${thongTinNhanVien[0].HireDateName || ""}" readonly>

            </div>

 </div>

   <div class="row mb-3">



            <label class="col-sm-3 col-form-label">%ProbationEndDate% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

 <input type="text" class="form-control" value="${thongTinNhanVien[0].ProbationEndDateName || ""}" readonly>

            </div>

  </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%EmployeeKind% <span class="text-danger">*</span>:</label>

         <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].EmployeeTypeName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">Email:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].Email || ""}" readonly>

            </div>

      </div>

    `;





    var employeeStatusBasic = document.getElementById("companyInfoBasic_P");



    employeeStatusBasic.innerHTML = `

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%Approve_Status% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].EmployeeStatusName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

        <label class="col-sm-3 col-form-label">%DivisionID% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

  <input type="text" class="form-control" value="${thongTinNhanVien[0].Division_Label || ""}" readonly>

          </div>

        </div>

        <div class="row mb-3">

           <label class="col-sm-3 col-form-label">%Department% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

     <input type="text" class="form-control" value="${thongTinNhanVien[0].DepartmentName_Label || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%colSectionID%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].SectionName || ""}" readonly>

            </div>

        </div>

   <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%colGroupID%:</label>

            <div class="col-sm-9">

           <input type="text" class="form-control" value="${thongTinNhanVien[0].GroupName || ""}" readonly>

            </div>

        </div>

  <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%EffectDate% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].SecPosChangedDateNew || ""}" readonly>

            </div>

  </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%colPosition% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].PositionName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

  <label class="col-sm-3 col-form-label">%EffectDate% <span class="text-danger">*</span>:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].PositionEffectiveDateNew || ""}" readonly>

 </div>

  </div>

  <div class="row mb-3">

       <label class="col-sm-3 col-form-label">%lblLineManager_FullName%:</label>

          <div class="col-sm-9">

         <input type="text" class="form-control" value="${thongTinNhanVien[0].LineManager_FullName_Label || ""}" readonly>

 </div>

        </div>

    `;



   var bankInfoContainer = document.getElementById("bankInfoContainer_P");

   bankInfoContainer.innerHTML = `



     <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblAccountNo%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].AccountNo || ""}" readonly>

 </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblAccountName%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].AccountNameNew || ""}" readonly>



            </div>

        </div>

        <div class="row mb-3">

      <label class="col-sm-3 col-form-label">%BankName%:</label>

   <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].BankNameNew || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblTaxNo%:</label>

          <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].TaxRegNo || ""}" readonly>

            </div>

        </div>

    `;



 var personalInfoContainer = document.getElementById("personalInfoContainer_P");

    personalInfoContainer.innerHTML = `

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%Birthday%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].BirthdayName || ""}" readonly>

</div>

   </div>

    <div class="row mb-3">

    <label class="col-sm-3 col-form-label">%BirthPlace%:</label>

   <div class="col-sm-9">

    <input type="text" class="form-control" value="${thongTinNhanVien[0].BirthPlaceProvinceName || ""}" readonly>

            </div>



        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%MaritalStatusName%:</label>

  <div class="col-sm-9">

        <input type="text" class="form-control" value="${thongTinNhanVien[0].MaritalStatusName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblEthnicID%:</label>

            <div class="col-sm-9">

             <input type="text" class="form-control" value="${thongTinNhanVien[0].EthnicName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblReligionID%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].ReligionName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%ID_No%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].ID_Number || ""}" readonly>

          </div>

        </div>

        <div class="row mb-3">

     <label class="col-sm-3 col-form-label">%ID_Issue_Date%:</label>

            <div class="col-sm-9">

   <input type="text" class="form-control" value="${thongTinNhanVien[0].ID_Issue_DateName || ""}" readonly>

</div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblIssuePlace%</label>

            <div class="col-sm-9">



      <input type="text" class="form-control" value="${thongTinNhanVien[0].Issue_Name || ""}" readonly>

            </div>

        </div>

    `;



 var provinceInfoContainer = document.getElementById("provinceInfoContainer_P");

provinceInfoContainer.innerHTML = `

        <div class="row mb-3">

 <label class="col-sm-3 col-form-label">%lblProvinceID%:</label>

  <div class="col-sm-9">

  <input type="text" class="form-control" value="${thongTinNhanVien[0].tmpProvinceName || ""}" readonly>

            </div>

 </div>

        <div class="row mb-3">

        <label class="col-sm-3 col-form-label">%BirthCert_DistrictID%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].tmpDistrictName || ""}" readonly>

            </div>

  </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lbltmpWardID%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].tmpWardName || ""}" readonly>

    </div>

        </div>

        <div class="row mb-3">

<label class="col-sm-3 col-form-label">%lblHouseNumberHamlet%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].tmpAddressName || ""}" readonly>

         </div>

        </div>

    `;



 var permanentAddressContainer = document.getElementById("permanentAddressContainer_P");

    permanentAddressContainer.innerHTML = `

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblProvinceID%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].province || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">



            <label class="col-sm-3 col-form-label">%BirthCert_DistrictID%:</label>

            <div class="col-sm-9">

    <input type="text" class="form-control" value="${thongTinNhanVien[0].DistrictName || ""}" readonly>

            </div>

        </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lbltmpWardID%:</label>

        <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].WardName || ""}" readonly>

            </div>

     </div>

        <div class="row mb-3">

            <label class="col-sm-3 col-form-label">%lblHouseNumberHamlet%:</label>

            <div class="col-sm-9">

                <input type="text" class="form-control" value="${thongTinNhanVien[0].ResidentAddName || ""}" readonly>

            </div>

        </div>

    `;

 }

 function formatDateH_P(inputDate) {

    if (!inputDate) return "";



    const date = new Date(inputDate);

    if (isNaN(date.getTime())) return "";



    const day = String(date.getDate()).padStart(2, "0");

    const month = String(date.getMonth() + 1).padStart(2, "0");

    const year = date.getFullYear();



    return `${day}/${month}/${year}`;

}



 function api_getEmployeeLoginid() {

 AjaxHPAParadise({

  data: {

   name: "sp_GetEmployeeLogin",

   param: ["LoginID",LoginID]

  },

  success: async function(resultData) {

   let employeeList = JSON.parse(resultData).data;

            var employee = employeeList[0];

   var employee2 = employee[0].EmployeeID;

   console.log(employeeList)

   await api_loadDataEmployee_P(employee2);

   await GetEmployeeDataChangedRequest()

   await CreateDataFieldsInputHTML(dataFieldList, dataDisplaySetting, thongTinNhanVien);

   LoadSelectionValueForDataField();

  },

 });

}

 api_getEmployeeLoginid()

 //api_loadDataEmployee_P(EmployeeParam);



function saveEmployee_P() {

  var employeeId = document.getElementById("employeeId_P").value;

    var fullName = document.getElementById("fullName").value;



    var dob = document.getElementById("dob").value;

    var genderElement = document.querySelector(''input[name="gender"]:checked'');

    var gender = genderElement ? genderElement.value : null;

    var startDate = document.getElementById("startDate").value;

 var avatarEmp = document.getElementById("avatarImage_P").src;



 if (avatarEmp === ImageParadiseDefault){

  avatarEmp = null



 }else{

  const base64Regex = /^data:image\/(png|jpg|jpeg|gif);base64,/;

 if (base64Regex.test(avatarEmp)) {



    avatarEmp = avatarEmp.replace(base64Regex, '''');

  } else {

   avatarEmp = null;



}

 }





}





var getallemployeeID =() =>{

 AjaxHPAParadise({

  data: {

   name: "get_allEmployeeID",



   param: ["LoginID",LoginID]

  },

  success: function(resultData) {

   let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;

   EmployeeIDList = [];

   EmployeeIDListWithFullName = [];

   jsonData.data[0].forEach(function (employee) {

    EmployeeIDList.push(employee.EmployeeID);

    const formattedEmployee = `${employee.FullName}(${employee.EmployeeID})`;

    EmployeeIDListWithFullName.push(formattedEmployee);

   });

  },

  error: function(xhr, status, error) {

  }

 });

}



function isEmployeeIDExist_P(employeeID) {

    return EmployeeIDList.includes(employeeID);

}



function UndisableButtonSend_P(getID) {

 document.getElementById(getID).disabled = false;

}



function DisableButtonSend(getID) {

 document.getElementById(getID).disabled = true;

}



function filterWardsByGroupEdit_P() {

     const ResidenceDistrictList_P = document.getElementById(''ResidenceDistrict_P'').value;



    const ResidenceWardList_P = document.getElementById(''ResidenceWard_P'');

    const selectedDistrictList_P = ResidenceDistrictList_P.value;



    AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["DistrictId",ResidenceDistrictList_P]

        },

        success: function (result) {

   var data =JSON.parse(result).data[0]

    var options = ''<option value="-1">%lblSelectWard%</option>'';



 data.forEach(function(item) {

            options += ''<option data-group="'' + item.DistrictId + ''" value="'' + item.WardID + ''">'' + item.WardName + ''</option>'';



   });



        document.getElementById("ResidenceWard_P").innerHTML = options;

  document.getElementById("PermanentWard_P").innerHTML = options;

        }

    });

}

function filterDistrictsByGroupEdit_P() {

     const ResidenceCityList_P = document.getElementById(''ResidenceCity_P'').value;

    const ResidenceDistrictList_P = document.getElementById(''ResidenceDistrict_P'');

 const ResidenceWard_P= document.getElementById(''ResidenceWard_P'');

    const selectedCityList_P = ResidenceCityList_P.value;

   AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["ProvinceID",ResidenceCityList_P]

 },

        success: function (result) {

    var data =JSON.parse(result).data[1]

            var options = ''<option value="-1">%lblSelectDistrict%</option>'';



      data.forEach(function(item) {



            options += ''<option data-group="'' + item.ProvinceID + ''" value="'' + item.DistrictID+ ''">'' + item.DistrictName+ ''</option>'';

        });



        document.getElementById("ResidenceDistrict_P").innerHTML = options;

  document.getElementById("PermanentDistrict_P").innerHTML = options;

  filterWardsByGroupEdit_P();

        }

    });

}



function filterDistrictsForPermanentEdit_P() {

     const ResidenceCityList_P = document.getElementById(''PermanentCity_P'').value;

    const ResidenceDistrictList_P = document.getElementById(''PermanentDistrict_P'');

    const selectedCityList_P = ResidenceCityList_P.value;



    AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["ProvinceID",ResidenceCityList_P]

        },

        success: function (result) {

    var data =JSON.parse(result).data[1]

            var options = ''<option value="-1">%lblSelectDistrict%</option>'';



        data.forEach(function(item) {

            options += ''<option data-group="'' + item.ProvinceID + ''" value="'' + item.DistrictID+ ''">'' + item.DistrictName+ ''</option>'';

        });



        document.getElementById("ResidenceDistrict_P").innerHTML = options;

  document.getElementById("PermanentDistrict_P").innerHTML = options;

  filterWardsForPermanentEdit_P();

}

   });

}

function filterWardsForPermanentEdit_P() {

     const ResidenceCityList_P = document.getElementById(''PermanentDistrict_P'').value;

    const ResidenceDistrictList_P = document.getElementById(''PermanentWard_P'');

    const selectedCityList_P = ResidenceCityList_P.value;

  AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["DistrictId",ResidenceCityList_P]

        },

        success: function (result) {

    var data =JSON.parse(result).data[0]

            var options = ''<option value="-1">%lblSelectWard%</option>'';



  data.forEach(function(item) {

            options += ''<option data-group="'' + item.DistrictId + ''" value="'' + item.WardID + ''">'' + item.WardName + ''</option>'';

  });



        document.getElementById("ResidenceWard_P").innerHTML = options;

  document.getElementById("PermanentWard_P").innerHTML = options;

        }

    });

}



function initDateBox_P(id, iconId, defaultDate = null ,isDob = false, dateboxOption = {}) {

    $(id).css("padding", ".375rem .75rem !important");

    $(id).dxDateBox({

        type: "date",

        stylingMode: "outlined",

        displayFormat: "dd/MM/yyyy",

        useMaskBehavior: true,

        value: defaultDate ? new Date(defaultDate) : null,

        ...dateboxOption,

        onValueChanged: function(e) {

            if (e.value) {



                let date = new Date(e.value);



  let day = ("0" + date.getDate()).slice(-2);

                let month = ("0" + (date.getMonth() + 1)).slice(-2);

                let year = date.getFullYear();

                let formattedDate = `${day}/${month}/${year}`;

             $(id).val(formattedDate).trigger("input").trigger("onchange");

                $(id).attr("raw-value", GetFormatDate(date, "yyyy-MM-ddT00:00:00"));

                // $(id).attr("raw-value", GetFormatDate(date, "yyyy-MM-ddTHH:mm:ss"));

                if (isDob) {

                    let today = new Date();

                    let age = today.getFullYear() - year;

                    let monthDiff = today.getMonth() - date.getMonth();

               let dayDiff = today.getDate() - date.getDate();



                    if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {

                        age--;

                    }

                    var  errorMessage = document.getElementById("dobError");

                    if (age < 16) {

                        errorMessage = document.getElementById("dobError");

                        errorMessage.textContent = "%lblAgeInvalid%";

                        errorMessage.style.display = "block";

                        isDOBWrong = true;

                        return;

                    } else {

                        errorMessage.style.display = "none";



                    }

                }

            }

        }

    });



    $(iconId).on("click", function() {

        let instance = $(id).dxDateBox("instance");

        if (!instance.option("value")) {

            instance.option("value", new Date(defaultDate));

        }

        instance.open();

    });

    $(id).on("click", function() {

        let instance = $(id).dxDateBox("instance");

        if (!instance.option("value")) {

            instance.option("value", new Date(defaultDate));

        }

        instance.open();

    });

}



initDateBox_P("#dob", "#calendarIconDOB", "2000-01-01",true);

initDateBox_P("#startDate", "#calendarIcon", todayPicker);

//initDateBox("#effectiveDateEmployeeType", "#calendarIconEffectiveDateEmployeeType", todayPicker);

//initDateBox("#effectiveDatePosition", "#calendarIconEffectiveDatePosition", todayPicker);

//initDateBox("#effectiveDateEmployeeStatus", "#calendarIconEffectiveDateEmployeeStatus", todayPicker);

initDateBox_P("#changeDate", "#calendarIconChangeDate", todayPicker);

initDateBox_P("#endDate", "#calendarIconEndDate", todayPicker);

initDateBox_P("#effectiveDate1", "#calendarIconEffectiveDate1", todayPicker);

initDateBox_P("#effectiveDate2", "#calendarIconEffectiveDate2", todayPicker);

initDateBox_P("#birthDateEdit_P", "#calendarIconBirthDateEdit_P", "2000-01-01");

initDateBox_P("#issueDate_P", "#calendarIconIssueDate_P", todayPicker);





function loadAvatar_P(event) {

    const file = event.target.files[0];

    if (!file) return;



    const reader = new FileReader();

    reader.onload = function (e) {

        const img = new Image();

        img.src = e.target.result;



        img.onload = function () {

            const canvas = document.createElement("canvas");

            const ctx = canvas.getContext("2d");



        canvas.width = img.width;

            canvas.height = img.height;



            ctx.drawImage(img, 0, 0, img.width, img.height);



         // Chuyển hình ảnh sang base64

            const compressedImage = canvas.toDataURL("image/jpeg", 0.5);

            const base64Data = compressedImage.replace(/^data:image\/\w+;base64,/, "");

   const output = document.getElementById("avatarImage_P");

      // Gửi ảnh lên API để kiểm tra

            AjaxHPAParadiseParadise({

                data: {

                    name: "DetectFaceAndPortraitVer2",

       param: [base64Data]

                },

                success: function (result) {

                    console.log(result);

       try {

                        var parsedResult = JSON.parse(result);

                       var data = parsedResult;

      console.log(data.data)

                        if (!data || data.data.length === 0) {

                          showNotificationModal('+N'"Hình ảnh không phù, vui lòng chọn hình ảnh có khuôn mặt rõ ràng để hệ thống nhận diện","Tôi đã hiểu","primary"

       ,() =>{

       output.src = ImageParadiseDefault;

                            return;

       }

)



                        }





        if (output) {

                            output.src = "data:image/jpeg;base64," + data.data;

                        }

                    } catch (error) {

                        console.error("Lỗi khi xử lý JSON:", error);

    alert("Có lỗi xảy ra khi xử lý hình ảnh.");

                    }

 }

            });





        };

    };

    reader.readAsDataURL(file);

}





function loadAvatarEdit_P(event, imgElement = "avatarImageEdit_P", buttonUndisable) {

    const file = event.target.files[0];

    console.log(123)

    if (!file) return;



    const reader = new FileReader();

    reader.onload = function (e) {

        const img = new Image();

        img.src = e.target.result;



        img.onload = function () {

            const canvas = document.createElement("canvas");

            const ctx = canvas.getContext("2d");



            canvas.width = img.width;

            canvas.height = img.height;



            ctx.drawImage(img, 0, 0, img.width, img.height);





            const compressedImage = canvas.toDataURL("image/jpeg", 0.5);

            const base64Data = compressedImage.replace(/^data:image\/\w+;base64,/, "");

            // const output = document.getElementById("avatarImageEdit_P");

            const output = document.getElementById(imgElement);



            AjaxHPAParadiseParadise({

                data: {

                    name: "DetectFaceAndPortraitVer2",

                    param: [base64Data]

                },

                success: function (result) {

                    console.log(result);

                    try {

                        var parsedResult = JSON.parse(result);

                        var data = parsedResult;

                        console.log(data.data)

                        if (!data || data.data.length === 0) {

                            showNotificationModal('+N'"Hình ảnh không phù, vui lòng chọn hình ảnh có khuôn mặt rõ ràng để hệ thống nhận diện","Tôi đã hiểu","primary"

                                ,() => {

                         output.src = "data:image/jpeg;base64," + imageTempEdit;

                   return;

 }

                  )



  }





       if (output) {

                         output.src = "data:image/jpeg;base64," + data.data;

                            if (buttonUndisable) UndisableButtonSend_P(buttonUndisable);

                        }

                    } catch (error) {

                        console.error("Lỗi khi xử lý JSON:", error);

                        alert("Có lỗi xảy ra khi xử lý hình ảnh.");

                    }

                }

            });



        };

    };

    reader.readAsDataURL(file);

}



function convertToSQLDate_P(dateString) {

    const dateParts = dateString.split("/");



    if (dateParts.length !== 3) {

        return null;

    }



    let day = dateParts[0].padStart(2, "0");

    let month = dateParts[1].padStart(2, "0");

    let year = dateParts[2];





    if (year.length !== 4) {

        return null;

    }



    return `${year}-${month}-${day}`;

}

function formatDateInput_P(input) {

    let value = input.value.replace(/\D/g, "");



    if (value.length > 8) {

        value = value.substring(0, 8);

    }



    let day = value.substring(0, 2);

    let month = value.length > 2 ? value.substring(2, 4) : "";

    let year = value.length > 4 ? value.substring(4, 8) : "";



    // Kiểm tra giới hạn ngày, tháng, năm

    if (parseInt(day) > 31) day = "31";

    if (parseInt(month) > 12) month = "12";



    let currentYear = new Date().getFullYear() + 2;

    if (year.length === 4 && parseInt(year) >= currentYear) year = (currentYear - 1).toString();



    let formattedValue = day;

    if (month) formattedValue += "/" + month;



    if (year) formattedValue += "/" + year;



    input.value = formattedValue;

}



function formatDateInput_P(input) {

    let value = input.value.replace(/\D/g, ""); // Loại bỏ tất cả ký tự không phải số



    if (value.length > 8) {

        value = value.substring(0, 8); // Giới hạn tối đa 8 số

}



    let day = value.substring(0, 2);

    let month = value.length > 2 ? value.substring(2, 4) : "";

    let year = value.length > 4 ? value.substring(4, 8) : "";



    // Kiểm tra giới hạn ngày, tháng, năm

    if (parseInt(day) > 31) day = "31";

    if (parseInt(month) > 12) month = "12";



    let currentYear = new Date().getFullYear() + 1;

    if (year.length === 4 && parseInt(year) >= currentYear) year = (currentYear - 1).toString();



    let formattedValue = day;

    if (month) formattedValue += "/" + month;

    if (year) formattedValue += "/" + year;



    input.value = formattedValue;

}

function load_dateFields_P(){

var dateFields = [

    "#dob", "#startDate", "#joinDateEditData",

    "#changeDate", "#endDate", "#effectiveDate1",

    "#effectiveDate2", "#birthDateEdit_P", "#issueDate_P"

];



dateFields.forEach(selector => {

    const element = document.querySelector(selector);

    if (element) {

  element.setAttribute("placeholder", "dd/mm/yyyy");

        element.addEventListener("input", function() {

            formatDateInput_P(this);

        });

    }

});

}

load_dateFields_P()





</script>

 <script>





  function show_editEmployeeButton_P(){

  fetchEmployeeData_P()

    const modal = new bootstrap.Modal(document.getElementById("editEmployeeModal_P"));

           modal.show();

  }

  function fetchEmployeeData_P() {

    // Cập nhật giá trị cho các input

    document.getElementById("employeeIDEditData_P").value = thongTinNhanVien[0].EmployeeID;

    document.getElementById("fullNameEditData_P").value = thongTinNhanVien[0].FullNameNew;

    document.getElementById("phoneNumberEditData_P").value = thongTinNhanVien[0].MobilePhone;

    document.getElementById("genderEditData_P").value = thongTinNhanVien[0].SexName;

    document.getElementById("emailEditData_P").value = thongTinNhanVien[0].Email_Label;



}

  document.getElementById("saveEmployeeButton_P").addEventListener("click", function () {

    if (!validateForm_P()) {

        return;

   }



    if (window.isWeb == 2)

        showConfirmPopup({

         title: "%lblEditEmployeeInfo%",

 message: "%lblConfirmEditEmployee%",

            icon: "bi-question-circle",

            yesText: "%Confirm%",

            noText: "%Cancel%",

            onYes: async function() {

                await saveDataEditUserData();



                hideConfirmPopup();



   document.activeElement.blur();

                $("#editEmployeeModal_P").modal("hide");

                var employeeID = document.getElementById("employeeIDEditData_P").value;

                document.getElementById("saveEmployeeButton_P").disabled = true;

                api_loadDataEmployee_P(employeeID);



            },

        });

    else

        showConfirmationModal("%lblConfirmEditEmployee%", "%Confirm%", "%Cancel%", () => {

            return new Promise((resolve) => {

                saveDataEditUserData();

                setTimeout(() => {

                    resolve();

                }, 1000);

            }).then(() => {

     document.activeElement.blur();

                $("#editEmployeeModal_P").modal("hide");

                var employeeID = document.getElementById("employeeIDEditData_P").value;

                document.getElementById("saveEmployeeButton_P").disabled = true;

                api_loadDataEmployee_P(employeeID);

            });

        });

});



function validateForm_P() {

    var emptyFields = [];



    var requiredFields = [

"employeeIDEditData_P",

        "fullNameEditData_P",

        "phoneNumberEditData_P",

        "genderEditData_P",

 "emailEditData_P"

    ];



  requiredFields.forEach(id => {

        var inputElement = document.getElementById(id);

        if (inputElement) {

            var labelOrSpan = inputElement.previousElementSibling;



            if (labelOrSpan && labelOrSpan.innerHTML.includes("*")) {

                var isEmpty = false;



                if (inputElement.tagName === "SELECT") {



                    if (inputElement.value === "-1") {

                        isEmpty = true;

                   }

                } else {

      // Nếu là <input> hoặc <textarea> và rỗng => lỗi

                    if (!inputElement.value.trim()) {

                        isEmpty = true;

                    }

                }



                if (isEmpty) {

                    emptyFields.push(labelOrSpan.textContent.replace(/\(\*\)/g, "").trim());

                }

      }

        }

    });



    if (emptyFields.length > 0) {

        const message = `%lblMissingEmployeeData%: ${emptyFields.join(", ")}`;

        showNotificationModal(message, "%barCancel%", "primary", () => {

            return;

        });

  return false;

}

    return true;

}



async function saveDataEditUserData() {



    var employeeID = document.getElementById("employeeIDEditData_P").value;

    var fullName = document.getElementById("fullNameEditData_P").value;

    var phoneNumber = document.getElementById("phoneNumberEditData_P").value;

    var gender = document.getElementById("genderEditData_P").value;

    var genderValue = gender === "Nam" ? 1 : gender === "Nữ" ? 0 : null;

    var email = document.getElementById("emailEditData_P").value;

    var ImagePhoto = $("#avatarImageEdit_P").attr("src").replace(/^data:image\/[a-z]+;base64,/, "");



    await AjaxHPAParadiseAsync({

        data: {

            name: "api_saveDataEditUserData_1",

            param: [

                "EmployeeID", employeeID,

                "fullName", fullName,

                "phoneNumber", phoneNumber,

                "gender", genderValue,

                "email", email,

                "PhotoImage", ImagePhoto

   ]

        },

        success: function (result) {

            // Xử lý sau khi lưu thành công



        }

    });

}

function showEditBankInfoModal_P() {

    fetchBankInfoData_P();

    const modal = new bootstrap.Modal(document.getElementById("editBankInfoModal_P"));

    modal.show();

}



function fetchBankInfoData_P() {

   //document.getElementById("bankEmployeeID").value = thongTinNhanVien[0].FullNameNew;

    document.getElementById("accountNumberEdit_P").value = thongTinNhanVien[0].AccountNo;

    document.getElementById("accountHolderNameEdit_P").value = thongTinNhanVien[0].AccountNameNew;

    document.getElementById("bankNameEdit_P").value = thongTinNhanVien[0].BankCode;

    document.getElementById("taxCodeEdit_P").value = thongTinNhanVien[0].TaxRegNo;

}



document.getElementById("saveBankInfoButton_P").addEventListener("click", function () {

showConfirmationModal("%lblConfirmEditBankInfo%", "%Confirm%", "%Cancel%", () => {

    return new Promise((resolve) => {

     saveBankInfoData_P();

     setTimeout(() => {

      resolve();

     }, 1000);

    }).then(() => {

     $("#editBankInfoModal_P").modal("hide");

     document.getElementById("saveBankInfoButton_P").disabled = true;

     api_loadDataEmployee_P(EmployeeIDNow);

    });

            });



});



function saveBankInfoData_P() {

 //var EmployeeID = document.getElementById("bankEmployeeID").value;

    var accountNumber = document.getElementById("accountNumberEdit_P").value;

    var accountHolderName = document.getElementById("accountHolderNameEdit_P").value;

    var bankName = document.getElementById("bankNameEdit_P").value;

    var taxCode = document.getElementById("taxCodeEdit_P").value;



    AjaxHPAParadise({

        data: {

   name: "api_saveDataEditUserData_4",

            param: [

    "EmployeeID",EmployeeIDNow,

     "AccountNumber", accountNumber,

"AccountHolderName", accountHolderName,



                "BankName", bankName,

              "TaxCode", taxCode

          ]

        },

    success: function (result) {

  --console.log(result)

        }

    });

}

function showEditEmployeeInfoModal_P() {

    fetchEmployeeInfo_P();

    const modal = new bootstrap.Modal(document.getElementById("editEmployeeInfoModal_P"));

    modal.show();

}



function fetchEmployeeInfo_P() {

    //document.getElementById("employeeID").value = thongTinNhanVien[0].FullNameNew;

    document.getElementById("birthDateEdit_P").value = thongTinNhanVien[0].BirthdayName;

    document.getElementById("birthPlace_P").value = thongTinNhanVien[0].ProvinceIDNew;

    document.getElementById("maritalStatus_P").value = thongTinNhanVien[0].MaritalStatusIDNew;

    document.getElementById("ethnicity_P").value = thongTinNhanVien[0].EthnicIDNew;

    document.getElementById("religion_P").value = thongTinNhanVien[0].ReligionIDNew;

    document.getElementById("idCard_P").value = thongTinNhanVien[0].ID_Number;

    document.getElementById("issueDate_P").value = thongTinNhanVien[0].ID_Issue_DateName;

    document.getElementById("issuePlace_P").value = thongTinNhanVien[0].ID_Issue_Place;

}

document.getElementById("saveEmployeeInfoButton_P").addEventListener("click", function () {

showConfirmationModal("%lblConfirmEditEmployeeInfo%", "%Confirm%", "%Cancel%", () => {

    return new Promise((resolve) => {

     saveEmployeeInfo_P();

     setTimeout(() => {

      resolve();

     }, 1000);

    }).then(() => {

     $("#editEmployeeInfoModal_P").modal("hide");

     document.getElementById("saveEmployeeInfoButton_P").disabled = true;

     api_loadDataEmployee_P(EmployeeIDNow);

    });

            });



});



function saveEmployeeInfo_P() {

    //var EmployeeID = document.getElementById("employeeID").value;

    var BirthDate = document.getElementById("birthDateEdit_P").value;

    var BirthPlace = document.getElementById("birthPlace_P").value;



    var MaritalStatus = document.getElementById("maritalStatus_P").value;

    var Ethnicity = document.getElementById("ethnicity_P").value;

    var Religion = document.getElementById("religion_P").value;

    var IDCard = document.getElementById("idCard_P").value;

    var IssueDate = document.getElementById("issueDate_P").value;

    var IssuePlace = document.getElementById("issuePlace_P").value;



    AjaxHPAParadise({

  data: {

            name: "api_saveDataEditUserData_5",

    param: [

   "EmployeeID", EmployeeIDNow,

        "BirthDate", convertToSQLDate_P(BirthDate),

                "BirthPlace", BirthPlace,

          "MaritalStatus", MaritalStatus,

                "Ethnicity", Ethnicity,

                "Religion", Religion,

                "IDCard", IDCard,

                "IssueDate", convertToSQLDate_P(IssueDate),

                "IssuePlace", IssuePlace

            ]

        },

success: function (result) {

 console.log(result)

        }

    });

}

function showTemporaryResidenceModal_P() {

    fetchTemporaryResidenceData_P();

    const modal = new bootstrap.Modal(document.getElementById("temporaryResidenceModal_P"));

    modal.show();

}



function fetchTemporaryResidenceData_P() {

    //document.getElementById("ResidenceEmployeeID").value = thongTinNhanVien[0].FullNameNew;

    document.getElementById("ResidenceCity_P").value = thongTinNhanVien[0].tmpProvinceID || "-1";

    document.getElementById("ResidenceDistrict_P").value = thongTinNhanVien[0].tmpDistrictID || "-1";

    document.getElementById("ResidenceWard_P").value = thongTinNhanVien[0].tmpWardID || "-1";

    document.getElementById("ResidenceAddress_P").value = thongTinNhanVien[0].tmpAddress || "";

}



document.getElementById("saveTemporaryResidenceButton_P").addEventListener("click", function () {

  showConfirmationModal("%lblConfirmEditEmployeeInfo%", "%Confirm%", "%Cancel%", () => {



    return new Promise((resolve) => {

    saveTemporaryResidence_P();

    setTimeout(() => {

     resolve();

    }, 1000);

   }).then(() => {

    $("#temporaryResidenceModal_P").modal("hide");

     document.getElementById("saveTemporaryResidenceButton_P").disabled = true;

     api_loadDataEmployee_P(EmployeeIDNow);

   });

            });



});



function saveTemporaryResidence_P() {



    //const EmployeeID = document.getElementById("ResidenceEmployeeID").value;

    const City_P = document.getElementById("ResidenceCity_P").value;

    const District_P = document.getElementById("ResidenceDistrict_P").value;

    const Ward_P = document.getElementById("ResidenceWard_P").value;

    const Address_P = document.getElementById("ResidenceAddress_P").value;



    AjaxHPAParadise({

        data: {

            name: "api_saveDataEditUserData_6",

       param: [

                "EmployeeID", EmployeeIDNow,

                "City", City_P,

                "District", District_P,

                "Ward", Ward_P,

                "Address", Address_P

            ]

        },

    success: function (result) {



        }

   });

}

function api_loadTamTru_P(tmpProvinceID,tmpDistrictID){

    var ProvinceLoad = document.getElementById(''ResidenceCity_P'').value;

    const DistrictLoad_P = document.getElementById(''ResidenceDistrict_P'').value;

    AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["ProvinceID",tmpProvinceID,"DistrictID",tmpDistrictID]

        },

        success: function (result) {

            var data =JSON.parse(result).data[0];

            var data1 = JSON.parse(result).data[1];

            var options = ''<option value="-1">%lblSelectWard%</option>'';



            data.forEach(function(item) {

                options += ''<option data-group="'' + item.DistrictId + ''" value="'' + item.WardID + ''"'' +

                    (item.DistrictId === thongTinNhanVien[0].tmpDistrictID ? '' selected'' : '''') + ''>'' +

                    item.WardName + ''</option>'';

           });

            const wardSelect_P = document.getElementById("ResidenceWard_P");

       wardSelect_P.innerHTML = options;

            wardSelect_P.selectedIndex = 0;



            var options1 = ''<option value="-1">%lblSelectDistrict%</option>'';

data1.forEach(function(item) {

 options1 += ''<option data-group="'' + item.ProvinceID + ''" value="'' + item.DistrictID + ''"'' +

    (item.ProvinceID === thongTinNhanVien[0].tmpProvinceID ? '' selected'' : '''') + ''>'' +

                item.DistrictName + ''</option>'';

            });



            const districtSelect_P = document.getElementById("ResidenceDistrict_P");

            districtSelect_P.innerHTML = options1;

            districtSelect_P.selectedIndex = 0;

        }

    });

 }



function api_loadThuongTru_P(ProvinceID,DistrictID){

    const PermanentCity_P = document.getElementById(''PermanentCity_P'').value;

    const PermanentDistrict_P = document.getElementById(''PermanentDistrict_P'').value;

    AjaxHPAParadise({

        data: {

            name: "api_getWard",

            param: ["ProvinceID",ProvinceID,"DistrictID",DistrictID]

        },

        success: function (result) {

            var data =JSON.parse(result).data[0];

            var data1 = JSON.parse(result).data[1];

            var options = ''<option value="-1">%lblSelectWard%</option>'';



            data.forEach(function(item) {

                options += ''<option data-group="'' + item.DistrictId + ''" value="'' + item.WardID + ''"'' +

                (item.DistrictId === thongTinNhanVien[0].DistrictID ? '''' : '''') + ''>'' +

                item.WardName + ''</option>'';

            });

            const wardSelect = document.getElementById("PermanentWard_P");

            wardSelect.innerHTML = options;

            wardSelect.selectedIndex = 0;



            var options1 = ''<option value="-1">%lblSelectDistrict%</option>'';

            data1.forEach(function(item) {

                options1 += ''<option data-group="'' + item.ProvinceID + ''" value="'' + item.DistrictID + ''"'' +

                (item.ProvinceID === thongTinNhanVien[0].ProvinceID ? '''' : '''') + ''>'' +

                item.DistrictName + ''</option>'';

            });



   const districtSelect = document.getElementById("PermanentDistrict_P");

            districtSelect.innerHTML = options1;

            districtSelect.selectedIndex = 0;

        }

    });

 }



 function showPermanentResidenceModal_P() {

 fetchPermanentResidenceData_P();

    const modal = new bootstrap.Modal(document.getElementById("permanentResidenceModal_P"));

    modal.show();

}



function fetchPermanentResidenceData_P() {

 //document.getElementById("PermanentEmployeeID").value = thongTinNhanVien[0].FullNameNew;

    document.getElementById("PermanentCity_P").value = thongTinNhanVien[0].ProvinceID || "-1";

    document.getElementById("PermanentDistrict_P").value = thongTinNhanVien[0].DistrictID || "-1";

    document.getElementById("PermanentWard_P").value = thongTinNhanVien[0].WardIDNew || "-1";

    document.getElementById("PermanentAddress_P").value = thongTinNhanVien[0].ResidentAdd || "";

}



document.getElementById("savePermanentResidenceButton_P").addEventListener("click", function () {

  showConfirmationModal("%lblConfirmEditEmployeeInfo%", "%Confirm%", "%Cancel%", () => {

    return new Promise((resolve) => {

     savePermanentResidence_P();

     setTimeout(() => {

      resolve();

     }, 1000);

    }).then(() => {

     $("#permanentResidenceModal_P").modal("hide");

     document.getElementById("savePermanentResidenceButton_P").disabled = true;

     api_loadDataEmployee_P(EmployeeIDNow);

    });

            });



});



function savePermanentResidence_P() {

    //const EmployeeID = document.getElementById("PermanentEmployeeID").value;

    const City_P = document.getElementById("PermanentCity_P").value;

    const District_P = document.getElementById("PermanentDistrict_P").value;

    const Ward_P = document.getElementById("PermanentWard_P").value;



    const Address_P = document.getElementById("PermanentAddress_P").value;







    AjaxHPAParadise({

      data: {

name: "api_saveDataEditUserData_7",

           param: [

         "EmployeeID", EmployeeIDNow,

         "City", City_P,

      "District", District_P,

      "Ward", Ward_P,

     "Address", Address_P

            ]

    },

        success: function (result) {



        }

    });

}



var api_GetDataDivDepSecPos_P = () => {

 var EmployeeID = $("#EmployeeHR_P").val()

    AjaxHPAParadise({

        data: {

            name: "api_GetDataDivDepSecPos",

            param: ["LanguageID",LanguageID,"EmployeeID","EmployeeID"]

        },

        success: function (result) {

          var data = JSON.parse(result).data;



function populateSelect_P(id, dataIndex, valueField, textField, defaultLabel) {

    let select = document.getElementById(id);

 if (!select) return;



    let fragment = document.createDocumentFragment();

    let defaultOption = document.createElement("option");

    defaultOption.value = "-1";

    defaultOption.textContent = defaultLabel;

    fragment.appendChild(defaultOption);

    data[dataIndex].forEach(item => {

        let option = document.createElement("option");

  option.value = item[valueField];

        option.textContent = item[textField];



        fragment.appendChild(option);

    });



    let selectedValue = select.value;

    select.innerHTML = "";

    select.appendChild(fragment);



}



   function populateAllSelects_P() {

    populateSelect_P("bankNameEdit_P", 10, "BankCode", "BankName", "%lblSelectBank%");

    populateSelect_P("PermanentCity_P", 11, "ProvinceID", "ProvinceName", "%lblSelectProvinceCity%");

    populateSelect_P("ResidenceCity_P", 11, "ProvinceID", "ProvinceName", "%lblSelectProvinceCity%");

    populateSelect_P("birthPlace_P", 11, "ProvinceID", "ProvinceName", "%lblSelectPlaceOfBirth%");

    populateSelect_P("issuePlace_P", 11, "ProvinceID", "ProvinceName", "%lblSelectPlaceOfIssue%");

    populateSelect_P("PermanentDistrict_P", 12, "DistrictID", "DistrictName", "%lblSelectDistrict%");

    populateSelect_P("ResidenceDistrict_P", 12, "DistrictID", "DistrictName", "%lblSelectDistrict%");

    populateSelect_P("maritalStatus_P", 13, "MaritalStatusID", "MaritalStatusName", "%lblSelectMaritalStatus%");

    populateSelect_P("ethnicity_P", 14, "EthnicID", "EthnicName", "%lblSelectEthnicity%");

    populateSelect_P("religion_P", 15, "ReligionID", "ReligionName", "%lblSelectReligion%");

   }

   populateAllSelects_P();

  }



    });

};



 </script>







 <script>

    if (window.isWeb == 2) {

        $("#EmployeeProfile_P").css("margin-left", 0);

        $("#profileContainer_P").hide();

        $("#employeeDetailsContainer_P").hide();

        $("#employeeDetailsContainer_P").parent().children().hide();

        $("#employeeDetailsContainer_P").parent().children(`[data-bs-hrm="input-container"]`).show().addClass("w-100 h-100");

        $(`[data-bs-hrm="input-container"] img[data-bs-hrm="mobile-avatar"]`).parent().addClass("d-flex");

        $(`[data-bs-hrm="modal-input"] .modal-body`).css("max-height", "calc(90vh - 140px)").css("overflow", "scroll");

    }



    $("#saveGeneralEditButton").on("click", async () => {

        await SaveEditDataEmployee();

    });





       async function ShowEmployeeEditModal(title, typeID, content) {

    const modalEl = document.getElementById("generalEditModal");

    const modal = new bootstrap.Modal(modalEl);

    $("#generalEditModalLabel").text(title);



    $("#generalEditModal .card-body>#general-edit-form").html("");

    dataDisplaySetting.filter(x => x.TypeID == typeID).sort((a,b) => a.ORDs - b.ORDs).forEach(dataField => {

        $("#generalEditModal .card-body>#general-edit-form").append(dataField.InputHTML);

        if (dataField.AfterAppendFunction) dataField.AfterAppendFunction();

    });



    // Đảm bảo chỉ gọi loadEmployeeFrameAssignments sau khi modal đã hiện hoàn toàn

    $(modalEl).one(''shown.bs.modal'', function() {

        loadEmployeeFrameAssignments();

    });

    modal.show();

}



    async function LoadSelectionValueForDataField() {

        let result = await AjaxHPAParadiseAsync({

            data: {

    name: "sp_GetColumnsComboBoxAttribute",

                param: [

                    "@LoginID",

              window.LoginID,

     "@LanguageID",

 window.LanguageID,

     "@Columns",

          HR_StaffInformation_ForUserWeb.DataFieldLookupList.filter(

                        (x) => x.isEdit

        )

                        .map((x) => x.ColumName)

                        .join(","),

                    "@TableName",

                    "HR_StaffInformation_ForUser",

                ],

            },

            success: function (result) {},

        });



        let data = JSON.parse(result).data[0];



        data.forEach((dataField) => {

            let temp = dataDisplaySetting.find(

                (x) => x.ColumName == dataField.ColumnName

            );

            if (temp)

                Object.assign(temp, dataField);

        });

    }





    async function SaveEditDataEmployee() {

        let [ColumnsWithDataType, ColumnsWithValue] = await CreateParamSaveData();

        console.log(

            "🚀 ~ SaveEditDataEmployee ~ ColumnsWithValue:",

            ColumnsWithValue

        );

        console.log(

            "🚀 ~ SaveEditDataEmployee ~ ColumnsWithDataType:",

            ColumnsWithDataType

        );



        if (!ColumnsWithDataType || !ColumnsWithValue) return;



        let result = await AjaxHPAParadiseAsync({

            data: {

                name: "api_saveDataEditUserData_All",

                param: [

                    "@LoginID",

                    window.LoginID,

                    "@LanguageID",

                 window.LanguageID,

                    "@EmployeeID",

                    EmployeeIDNow,

     "@ColumnsWithDataType",

                    ColumnsWithDataType,

 "@ColumnsWithValue",

                    ColumnsWithValue,

                ],

            },

            success: function (result) {},

        });



        let data = JSON.parse(result);

        console.log("🚀 SaveEditDataEmployee ~ data:", data);



  $("#generalEditModal").modal("hide");

        document.getElementById("saveGeneralEditButton").disabled = true;

        await api_loadDataEmployee_P(EmployeeIDNow);

        await GetEmployeeDataChangedRequest()

        await CreateDataFieldsInputHTML(dataFieldList, dataDisplaySetting, thongTinNhanVien);

        LoadSelectionValueForDataField();

    }





    async function CreateParamSaveData() {

        let ColumnsWithDataType = [],

            ColumnsWithValue = [];



        let temp = $("#general-edit-form")

            .find("[data-bs-hrm-input]")

            .toArray();

      // lọc ra chỉ các input type="text"

        let textInputs = temp.filter(el => el.tagName === "INPUT" && el.type === "text");



        // cập nhật lại attribute value = value người dùng nhập

        textInputs.forEach(el => {

            el.setAttribute("value", el.value);

        });





        // input tag value -> check value with old value

        temp.filter(

            (field) =>

                //LuongNQ loai bỏ field dang cho duyet

                !field.classList.contains("await-approval")

                &&

                (

                // check value

                $(field).attr("raw-value") ||

                    $(field).attr("value") ||

                    (

                        $(field).attr("src")?.replace("data:image/jpeg;base64,", "") &&

                        !$(field).attr("src").includes("https") && $(field).attr("src") != "undefined"

                    )

                    ) &&

                // check difference

                thongTinNhanVien[0][$(field).attr("data-bs-hrm-input")] !=

                    ($(field).attr("raw-value") ||

                        $(field).attr("value") ||

                        $(field)

                            .attr("src")

            ?.replace("data:image/jpeg;base64,", "")

                        )

 ).forEach((Item) => {

                //danh dau

  let dataField = dataDisplaySetting.find(

         (x) => x.ColumName == $(Item).attr("data-bs-hrm-input")

            );







            if (dataField.ControlType == "PictureEdit") {

                ColumnsWithDataType.push(`${dataField.ColumName}&VARBINARY(MAX)`);

                ColumnsWithValue.push(`${

                    dataField.ColumName

                }&CONVERT(VARBINARY(MAX),

        CAST(N'''' AS XML).value(

            ''xs:base64Binary("${$(Item)

                .attr("src")

     .replace("data:image/jpeg;base64,", "")}")'',

            ''VARBINARY(MAX)''

        )

    )`);

            } else if (dataField.ControlType == "DateTimeEdit") {

                ColumnsWithDataType.push(

                    `${dataField.ColumName}&${dataField.DataType}`

                );

                ColumnsWithValue.push(

                    `${dataField.ColumName}&''${$(Item).attr("raw-value")}''`

                );

            } else if (dataField.ControlType == "SearchLookUpEdit") {

                ColumnsWithDataType.push(

                    `${dataField.ColumName}&${

                        dataField.DataType.includes("varchar")

                            ? dataField.DataType + "(MAX)"

                            : dataField.DataType

                    }`

                );

                ColumnsWithValue.push(

                    `${dataField.ColumName}&N''${$(Item).attr("value")}''`

                );

            } else {

                ColumnsWithDataType.push(

                    `${dataField.ColumName}&${

                        dataField.DataType.includes("varchar")

                            ? dataField.DataType + "(MAX)"

                            : dataField.DataType

                    }`

                );

                ColumnsWithValue.push(

                    `${dataField.ColumName}&N''${$(Item).attr("value")}''`

                );

            }

        });



        return [ColumnsWithDataType.join("|"), ColumnsWithValue.join("|")];

    }





    async function GetEmployeeDataChangedRequest() {



  let result = await AjaxHPAParadiseAsync({

            data: {

                name: "sp_EmployeeChange_Check",

                param: [

                    "@EmployeeID",

                    EmployeeIDNow,

                    "@LanguageID",

                    window.LanguageID,

                ],

            },

          success: function (result) {},

        });



        let data = JSON.parse(result);

        console.log("🚀 SaveEditDataEmployee ~ data:", data);



        HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList = data.data[0] ?? [];



        HR_StaffInformation_ForUserWeb.EmployeeDataRequestChangeList.forEach(request => {

            if (request.NewValueP) {

                $(`#profileImage_P`).addClass("await-approval").attr("src", "data:image/jpeg;base64," + request.NewValueP);

            } else

                $(`input#${request.FieldNameCode}_Static_P`).addClass("await-approval").attr("value", request.NewValue);

        });

    }



    async function CreateDataFieldsInputHTML(

        dataFieldGroup,

        dataDisplaySetting,

        employeeData

    ) {

        dataFieldGroup.forEach((group) => {

            let groupDataField = dataDisplaySetting.filter(

                (x) => x.TypeID == group.TypeID

            );



            groupDataField

                .sort((a, b) => a.ORDs - b.ORDs)

                .forEach((dataField) => {

                    //LuongNQ

                    var ColumName = dataField.ColumName == "PhotoImage" ? $("#profileImage_P").attr("src") : dataField.ColumName

                    BuildDataFieldInputHTML(

                        dataField,

               dataField.ColumName === "PhotoImage"

                        ? $("#profileImage_P").attr("src")

                        : employeeData[0][dataField.ColumName],

                        employeeData[0][dataField.ColumName.replace(/ID$/i, "") + "Name"] ??

                            employeeData[0][dataField.ColumName + "New"] ??

                      employeeData[0][dataField.ColumName] ??

                            ""

                    );

       });

        });

    }



 </script>

 '



--Đổi ngôn ngữ

--IF object_id('tempdb..#Results') IS NOT NULL DROP TABLE #Results

--SELECT @QueryHTML html INTO #Results



--IF object_id('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable

--SELECT * INTO #temptable FROM dbo.SplitString(@QueryHTML,'%') WHERE Items NOT LIKE '% %'



--IF OBJECT_ID('tempdb..#tblMD_Message') IS NOT NULL DROP TABLE #tblMD_Message

--SELECT MessageID,Content  INTO #tblMD_Message FROM dbo.tblMD_Message md WITH (NOLOCK)

--WHERE Language = @LanguageID and exists(select 1 from #temptable t where md.MessageID = t.Items)



/*

nếu biết trước MessageID được sử dụng where cho nhanh, không cần cũng được vì html chạy 1 lần



UPDATE t SET html = REPLACE(html,'%'+m.MessageID+'%',m.Content)

FROM #Results t INNER JOIN #tblMD_Message m ON m.MessageID = 'YearOld'

*/

----DECLARE @sql VARCHAR(MAX) = STUFF((SELECT '  UPDATE t SET html = REPLACE(html,''%''+m.MessageID+''%'',m.Content) FROM #Results t INNER JOIN #tblMD_Message m ON m.MessageID = '''+m.MessageID+'''' FROM #tblMD_Message m FOR XML PATH ('')) , 1, 1, '')

----EXEC (@sql)

--DECLARE @sql VARCHAR(MAX) = STUFF((SELECT '  UPDATE t SET html = REPLACE(html,''%''+m.MessageID+''%'',m.Content) FROM #Results t INNER JOIN #tblMD_Message m ON m.MessageID = '''+m.MessageID+'''' FROM #tblMD_Message m FOR XML PATH ('')) , 1, 1, '')



--EXEC (@sql)

--select html as Col1 FROM #Results



SELECT @QueryHTML html
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/2]: [dbo].[HR_StaffInformation_ForUserWeb]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[HR_StaffInformation_ForUserWeb]
(
  @LoginID int = 3,
  @LanguageID varchar(20) = 'VN',
  @EmployeeID varchar(20) = '-1',
  @isWeb int = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT html AS Col1 
    FROM tblHtmlScriptCache 
    WHERE TableName = 'HR_StaffInformation_ForUserWeb_Beta' 
      AND LanguageID = @LanguageID 
      AND ScreenType = -1;
END;
GO

