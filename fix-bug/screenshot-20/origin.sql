/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-20 -> 23 (Và lỗi Console DevTools lúc Login)
  MÀN HÌNH / MENU    : Layout tổng MacOS Desktop (HtmlMacOSLayOut_html)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/1]: [dbo].[HtmlMacOSLayOut_html]
--------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[HtmlMacOSLayOut_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lấy CSS từ Cache hoặc SP (sslayoutbody đã có nên comment lại)
    DECLARE @StyleCSSParadise NVARCHAR(MAX) = N'';
    /*
    SELECT TOP 1 @StyleCSSParadise = html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_MainStyleCSSParadise' AND (LanguageID = @LanguageID OR LanguageID = '-1');

    IF ISNULL(@StyleCSSParadise, '') = ''
    BEGIN
        EXEC sp_MainStyleCSSParadise @StyleHtml = @StyleCSSParadise OUTPUT;
    END
    */

    -- 2. Lấy Script chính hệ thống từ Cache hoặc SP (sslayoutbody đã có nên comment lại)
    DECLARE @ScriptMainParadise NVARCHAR(MAX) = N'';
    /*
    SELECT TOP 1 @ScriptMainParadise = html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_MainScriptParadise' AND (LanguageID = @LanguageID OR LanguageID = '-1');

    IF ISNULL(@ScriptMainParadise, '') = ''
    BEGIN
        IF OBJECT_ID('tempdb..#TempMainScript') IS NOT NULL DROP TABLE #TempMainScript;
        CREATE TABLE #TempMainScript (Script NVARCHAR(MAX));
        INSERT INTO #TempMainScript EXEC sp_MainScriptParadise @OnlyScript = 1;
        SELECT TOP 1 @ScriptMainParadise = Script FROM #TempMainScript;
        IF OBJECT_ID('tempdb..#TempMainScript') IS NOT NULL DROP TABLE #TempMainScript;
    END
    */

    -- 3. Nối Script điều hướng mở form chuẩn
    DECLARE @ScriptOpenForm NVARCHAR(MAX) = N'';
    EXEC ScriptOpenForm @LanguageID = @LanguageID, @isWeb = 1, @SriptHtml = @ScriptOpenForm OUTPUT;

    IF CHARINDEX('<TypeLayout>', @ScriptOpenForm) > 0
        SET @ScriptOpenForm = REPLACE(@ScriptOpenForm, '<TypeLayout>', '1');
    -- Khong chen the <style> truc tiep vao ben trong doan script tranh gay loi chia tach the cua HTML Parser
    IF CHARINDEX('the-style-tag', @ScriptOpenForm) > 0
        SET @ScriptOpenForm = REPLACE(@ScriptOpenForm, 'the-style-tag', 'the_style_tag');
    IF CHARINDEX('the-end-style-tag', @ScriptOpenForm) > 0
        SET @ScriptOpenForm = REPLACE(@ScriptOpenForm, 'the-end-style-tag', 'the_end_style_tag');
    SET @ScriptOpenForm = REPLACE(@ScriptOpenForm, '<style>', '/*style*/');
    SET @ScriptOpenForm = REPLACE(@ScriptOpenForm, '</style>', '/*endstyle*/');

    -- Đảm bảo thẻ bọc đúng
    /*
    IF CHARINDEX('<script', @ScriptMainParadise) = 0 AND ISNULL(@ScriptMainParadise, '') <> ''
        SET @ScriptMainParadise = N'<script>' + CHAR(10) + @ScriptMainParadise + CHAR(10) + N'</script>';

    IF CHARINDEX('<style', @StyleCSSParadise) = 0 AND ISNULL(@StyleCSSParadise, '') <> ''
        SET @StyleCSSParadise = N'<style>' + CHAR(10) + @StyleCSSParadise + CHAR(10) + N'</style>';
    */

    IF CHARINDEX('<script', @ScriptOpenForm) = 0 AND ISNULL(@ScriptOpenForm, '') <> ''
        SET @ScriptOpenForm = N'<script>' + CHAR(10) + @ScriptOpenForm + CHAR(10) + N'</script>';

    DECLARE @htmlStr NVARCHAR(MAX) = N'




<script>
// ============================================================================
// 1. BIẾN TOÀN CỤC HỆ THỐNG (GLOBAL SCOPE VARIABLES)
// ============================================================================
// User Request: nếu window.LoginID undefine thì kiểm tra window.UserID coi còn tồn tại không thì đè lên
if (typeof window.LoginID === "undefined" || !window.LoginID || (typeof window.UserID !== "undefined" && window.UserID && window.LoginID !== window.UserID)) {
    if (typeof window.UserID !== "undefined" && window.UserID) {
        window.LoginID = window.UserID;
    } else if (typeof UserID !== "undefined" && UserID) {
        window.LoginID = UserID;
    }
}
var LoginID = window.LoginID;
var isWeb = (typeof window.isWeb !== "undefined" && window.isWeb) ? window.isWeb : 1;
var UserName = (typeof window.UserName !== "undefined" && window.UserName) ? window.UserName : "";
var LanguageID = (typeof window.LanguageID !== "undefined" && window.LanguageID) ? window.LanguageID : "VN";

window.LoginID = LoginID;
window.isWeb = isWeb;
window.UserName = UserName;
window.LanguageID = LanguageID;

// ============================================================================
// SERVICE WORKER REGISTRATION
// ============================================================================
(() => {
  if (!("serviceWorker" in navigator)) {
    console.error("Trình duyệt không hỗ trợ Service Worker!");
    return;
  }

  const scriptPath = window.APPLICATION_ADDRESS + "/Scripts/service-worker.js";

  navigator.serviceWorker.register(scriptPath)
    .then((registration) => {
      console.log("1. Đã đăng ký thành công! Scope:", registration.scope);

      // 1. Nếu đang cài đặt
      if (registration.installing) {
        console.log("2. Worker đang ở trạng thái: INSTALLING");
        registration.installing.addEventListener("statechange", (event) => {
          console.log("Trạng thái chuyển đổi thành:", event.target.state);
        });
      }

      // 2. Nếu đang chờ kích hoạt
      if (registration.waiting) {
        console.log("2. Worker đang ở trạng thái: WAITING. Đang gửi lệnh SKIP_WAITING...");
        registration.waiting.postMessage({ type: "SKIP_WAITING" });
      }

      // 3. Nếu đã active thành công
      if (registration.active) {
        console.log("2. BÁO CÁO: Service Worker ĐÃ ACTIVE THÀNH CÔNG! Trạng thái:", registration.active.state);
      }

      // 4. Kiểm tra quyền kiểm soát trang
      if (navigator.serviceWorker.controller) {
        console.log("3. Service Worker đang điều khiển trang này thành công!");
      } else {
        console.warn("3. Service Worker đã active nhưng CHƯA điều khiển trang /Tai3 vì trang nằm ngoài phạm vi scope: " + registration.scope);
      }
    })
    .catch((error) => {
      console.error("Lỗi khi đăng ký:", error);
    });

  // Lắng nghe sự kiện chuyển đổi quyền điều khiển
  navigator.serviceWorker.addEventListener("controllerchange", () => {
    console.log("THÔNG BÁO: Service Worker vừa nhận quyền điều khiển trang web!");
  });
})();

// ============================================================================
// 2. BỘ HÀM TIỆN ÍCH CỐT LÕI (CORE UTILITIES) CỦA DEVEXPRESS GRID & HỆ THỐNG
// ============================================================================
if (typeof window.getArrayTypeDistinct !== "function") {
    window.getArrayTypeDistinct = function(arr) {
        return [...(new Set(arr.map(x => typeof x)))];
    };
}
var getArrayTypeDistinct = window.getArrayTypeDistinct;

if (typeof window.createConditionQuery !== "function") {
    window.createConditionQuery = function(filter, schema, comboBoxColumn) {
        if (!filter || !Array.isArray(filter) || filter.length === 0) return "";
        let condition = "";
        if (Array.isArray(filter) && filter.length == 3 && ["=", "<", ">"].includes(filter[1])) {
            if (filter[2] == null) {
                filter[0] = `ISNULL(${filter[0]} , '''')`;
                filter[2] = "''''";
            } else if (typeof filter[2] == "object") {
                filter[2] = "''" + filter[2].toISOString() + "''";
            } else if (typeof filter[2] == "number") {
                filter[2] = "''" + filter[2].toString() + "''";
            } else if (typeof filter[2] == "string") {
                filter[2] = "N''" + filter[2] + "''";
            }
        } else if (Array.isArray(filter) && filter.length == 3 && Array.isArray(filter[2]) && filter[2].length == 0) {
            filter.pop();
            filter.pop();
        }
        if (Array.isArray(filter)) {
            filter.forEach(item => {
                let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
                if ((Array.isArray(item) && typeList.length > 1) || (Array.isArray(item) && typeList.length == 1 && typeList[0] == "object")) {
                    condition += `(${createConditionQuery(item, schema, comboBoxColumn)})`;
                } else if (Array.isArray(item) && typeList.length == 1) {
                    condition += `${item[0]}`;
                    if (schema && schema.find && schema.find(x => x.name == item[0]) && schema.find(x => x.name == item[0]).type == "System.String") condition += " COLLATE Latin1_General_CI_AI";
                    if (comboBoxColumn && comboBoxColumn.includes(item[0])) condition += ` like N''${item[2]}''`;
                    else condition += `${item[1] == "contains" ? ` like N''%${item[2]}%''` : ` = N''${item[2]}''`}`;
                } else {
                    condition += " " + (item == null ? "NULL" : (item.toLocaleString().toLocaleUpperCase())) + " ";
                }
            });
        }
        return condition.trim().replace(/\s*=\s*/g, "= ");
    };
}
var createConditionQuery = window.createConditionQuery;

if (typeof window.createParamString !== "function") {
    window.createParamString = function(param) {
        let paramString = "";
        for (let index = 0; index < param.length; index += 2) {
            if (index > 0) paramString += ", ";
            paramString += `${param[index]} = N''${param[index+1]}''`;
        }
        return paramString;
    };
}
var createParamString = window.createParamString;

if (typeof window.transformDateToHierarchy !== "function") {
    window.transformDateToHierarchy = function(data) {
        let result = [], col0Map = new Map();
        if (!Array.isArray(data)) return result;
        data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
            if (!col0Map.has(col0)) {
                let col0Obj = { key: col0, items: [] };
                col0Map.set(col0, col0Obj);
                result.push(col0Obj);
            }
            if (!col1) return;
            let col0Obj = col0Map.get(col0), col1Map = col0Obj._col1Map || new Map();
            if (!col1Map.has(col1)) {
                let col1Obj = { key: col1, items: []};
                if (col2) col1Obj.count = totalCount;
                col1Map.set(col1, col1Obj);
                col0Obj.items.push(col1Obj);
            }
            col0Obj._col1Map = col1Map;
            if (!col2) return;
            let col1Obj = col1Map.get(col1), col2Map = col1Obj._col2Map || new Map();
            if (!col2Map.has(col2)) {
                let col2Obj = { key: col2, items: []};
                if (col3) col1Obj.count = totalCount;
                col2Map.set(col2, col2Obj);
                col1Obj.items.push(col2Obj);
            }
            col1Obj._col2Map = col2Map;
            if (!col3) return;
            let col2Obj = col2Map.get(col2), col3Map = col2Obj._col3Map || new Map();
            if (!col3Map.has(col3)) {
                let col3Obj = { key: col3, items: []};
                if (col4) col2Obj.count = totalCount;
                col3Map.set(col3, col3Obj);
                col2Obj.items.push(col3Obj);
            }
            col2Obj._col3Map = col3Map;
        });
        return result;
    };
}
var transformDateToHierarchy = window.transformDateToHierarchy;

if (typeof window.GetFormatDate !== "function") {
    window.GetFormatDate = function(date, format) {
        if (!date) return "";
        let d = new Date(date);
        if (isNaN(d.getTime())) return "";
        let day = ("0" + d.getDate()).slice(-2);
        let month = ("0" + (d.getMonth() + 1)).slice(-2);
        let year = d.getFullYear();
        let hours = ("0" + d.getHours()).slice(-2);
        let minutes = ("0" + d.getMinutes()).slice(-2);
        let seconds = ("0" + d.getSeconds()).slice(-2);
        if (!format) return day + "/" + month + "/" + year;
        return format.replace("dd", day).replace("MM", month).replace("yyyy", year).replace("HH", hours).replace("mm", minutes).replace("ss", seconds);
    };
}
var GetFormatDate = window.GetFormatDate;

if (!Object.filter) {
    Object.filter = function(obj, predicate) {
        return Object.keys(obj)
            .filter(key => predicate(obj[key]))
            .reduce((res, key) => (res[key] = obj[key], res), {});
    };
}

if (typeof window.parseJson !== "function") {
    window.parseJson = function(str) {
        if (!str) return null;
        if (typeof str === "object") return str;
        try { return JSON.parse(str); } catch(e) { return null; }
    };
}
var parseJson = window.parseJson;

// ============================================================================
// 3. ĐĂNG KÝ ZALO SIGNALR CONNECTIONID: Đã vô hiệu hóa ở Layout cha để tránh cướp kết nối của tab Zalo
// ============================================================================
/*
if (typeof $ !== "undefined" && $.connection && $.connection.hub && ($.connection.zaloHub || $.connection.hpaHub)) {
    try {
        $.connection.hub.start().done(function() {
            if ($.connection.hub.id) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_zalo_updateWebClientConnection",
                        param: ["ConnectionID", $.connection.hub.id, "LoginID", LoginID]
                    }
                });
            }
        }).catch(function() {});
    } catch(e) {}
}
*/

// taidang: Khởi tạo biến toàn cục đồng bộ ngăn lỗi ReferenceError trước khi API trả về
if (!window.StackOpenForm) {
    window.StackOpenForm = class {
        constructor() {
            this.forms = [];
        }
        open(formName) {
            if (this.forms.length === 0 || this.forms[this.forms.length - 1] !== formName) {
                this.forms.push(formName);
                console.log(`Mở form: ${formName}`);
            } else {
                console.log(`Form ${formName} đang mở trên cùng, bỏ qua`);
            }
        }
        close() {
            if (this.isEmpty()) {
                console.log("Không còn form nào để đóng");
                return null;
            }
            const closedForm = this.forms.pop();
            console.log(`Đóng form: ${closedForm}`);
            return closedForm;
        }
        current() {
            return this.isEmpty() ? null : this.forms[this.forms.length - 1];
        }
        isEmpty() {
            return this.forms.length === 0;
        }
        clear() {
            this.forms = [];
        }
        print() {
            console.log("StackOpenForm:", this.forms);
        }
    };
}
if (!window.stackOpenForm) {
    window.stackOpenForm = new window.StackOpenForm();
}

window.ParadiseOption = window.ParadiseOption || {};
window.dataMenuViewHtml = window.dataMenuViewHtml || [];
var dataMenuViewHtml = window.dataMenuViewHtml;

window.apps = Array.isArray(window.apps) ? window.apps : [];
var apps = window.apps;

window.appsDock = Array.isArray(window.appsDock) ? window.appsDock : [];
var appsDock = window.appsDock;

window.ShortcutKeysList = window.ShortcutKeysList || [];
var ShortcutKeysList = window.ShortcutKeysList;

window.fullRightObject = window.fullRightObject || [];
var fullRightObject = window.fullRightObject;

window.orderDockApp = window.orderDockApp || [];
var orderDockApp = window.orderDockApp;

window.filteredApps = window.filteredApps || [];
var filteredApps = window.filteredApps;

window.firtHrElement = window.firtHrElement || 0;
var firtHrElement = window.firtHrElement;

window.secondHrElement = window.secondHrElement || 0;
var secondHrElement = window.secondHrElement;

window.currentAppIdOpen = window.currentAppIdOpen || new Set();
var currentAppIdOpen = window.currentAppIdOpen;

var itemsPerPage = 28;
var currentPage = 1;
var totalPages = 0;
var currentSelectedMenu = null;
var currentSelectedMenuName = null;

window.launchpad = {
    get container() { return document.querySelector(".container__Window"); },
    get window() { return document.getElementById("launchpad") || document.querySelector(".launchpad"); },
    get searchbox() { return document.querySelector(".launchpad .searchbox"); },
    get app_container() { return document.querySelector(".Apps-container") || document.querySelector(".carousel"); },
    get point() { return document.querySelector("#point-launchpad"); },
    get opening() { return document.querySelector(".open-lunchpad") || document.querySelector(".MnuHRS238"); }
};
var launchpad = window.launchpad;

window.elements = {
    get body() { return document.querySelector("body"); },
    get navbar() { return document.querySelector(".navbar"); },
    get open_spotlight() { return document.querySelector(".open_Search"); },
    get spotlight_search() { return document.querySelector(".spotlight_serach"); },
    get brightness_range() { return document.getElementById("brightness"); },
    get sound_range() { return document.getElementById("sound"); },
    get clockElement() { return document.getElementById("clock"); },
    get clockWrapper() { return document.querySelector(".clock"); },
    get widgetsPanel() { return document.querySelector(".widgets-panel"); },
    get batteryButton() { return document.querySelector(".battery"); },
    get batteryText() { return document.querySelector(".battery__text"); },
    get batteryPopup() { return document.querySelector(".battery__popup"); },
    get batteryPopupText() { return document.querySelector(".battery__popup header span"); },
    get batteryProgress() { return document.querySelector(".battery__progress"); },
    get batteryIsChargingLogo() { return document.querySelector(".is-charging"); },
    get powerSource() { return document.querySelector(".power-source"); }
};
var elements = window.elements;
</script>

<style>
body {
  --google-font-color-materialiconstwotone:none;
}

.material-icons {
  font-family: ''Material Icons'';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}

.material-icons-outlined {
  font-family: ''Material Icons Outlined'';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}

.material-icons-round {
  font-family: ''Material Icons Round'';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}

.material-icons-sharp {
  font-family: ''Material Icons Sharp'';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}

.material-icons-two-tone {
  font-family: ''Material Icons Two Tone'';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}
</style>

<style>
.custom-overlay {
position: absolute;
top: 0;
left: 0;
width: 100%;
height: 100%;
background: rgba(0, 0, 0, 0.5);
z-index: 999;
}

.custom-spinner-container {
position: absolute;
top: 50%;
left: 50%;
transform: translate(-50%, -50%);
text-align: center;
padding: 20px 30px;

border-radius: 8px;

z-index: 1000;
}

.spinner-border {
width: 2.5rem;
height: 2.5rem;
border-width: 0.25rem; /* Viền nhỏ lại cho gọn */
}

.custom-spinner-text {
margin-top: 10px;
font-size: 16px;
font-weight: 500;
color: #333; /* Màu mặc định cho chữ */
text-shadow: 0px 1px 2px rgba(0, 0, 0, 0.1); /* Đổ bóng nhẹ để dễ đọc */
}


    /* Đảm bảo phần tử cha có position relative */
    .custom-relative {
        position: relative;
    }
.modal-header {
background: #00673b !important;
        color: white;


    }
.modal-title {

        color: white;


    }
</style> <style>
		
		@import url(https://fonts.googleapis.com/css?family=Inter:100,200,300,regular,500,600,700,800,900);

		/* Reset CSS */

		*{
			margin: 0;
			padding: 0;
			box-sizing: border-box;
			font-family: "Inter", sans-serif;
		}

		:root{
			--primary: #0B9F57;
			--primary-hover: #E7F7EF;
		}

		body{
			background-color: #5b6677;
		}

		.container{
			width: 100%;
			height: 100vh;
		}

		


		.number {
			color: #ffffff;  /* White color for the number */
			font-size: 17px;  /* Size of the number */
			font-weight: bold;  /* Make the number bold */
			font-family: ''Arial'', sans-serif;  /* Font family */

		}

		/* Header area */
		header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			background-color: #fff;
			padding: 10px 20px;
			box-shadow: 0 2px 4px rgba(0,0,0,0.1);
		}

		.header-left{
			display: flex;
			padding-left: 5px ;
			align-items: center;
		}

		.logo {
			height: 40px;
			margin-left: 30px;
		}

		

		.search-container {
			position: relative;
			flex-grow: 1;
			margin-left: 40px;
		}

		.search-icon {
			position: absolute;
			top: 50%;
			left: 10px;
			transform: translateY(-50%);
		}

		.search-input-windown {
			width: 320px;
			height: 48px;
			padding: 10px 20px 10px 40px;
			border: none;
			border-radius: 8px;
			background-color: #FAFAFA;
			font-size: 14px;
			color: #21252B;
			outline: none;
			box-shadow: 0 1px 1px var(--box-shadow);
		}

		.search-input-windown::placeholder {
			color: #B8BDC5;
		}


		.user-info {
			display: flex;
			align-items: center;
			/* align-items: center; */
		}

	

		.user-info .notifications {
			margin-right: 15px;
			position: relative;
			cursor: pointer;
		
		}

		.user-info .profile {
			position: relative;
			display: flex;
			align-items: center;
			cursor: pointer;
		}

		.user-info .profile .profile-menu {
			margin: unset;
			padding: unset;
			position: absolute;
			width: 154px;
			top: 4.2vh;
			right: 0vh;
			border-radius: 8px;
			background-color: var(--background-color);
			color: var(--text-color);
			border: 1px solid #e0e0e0;
			display: none;
		}

		.user-info .profile .profile-menu .profile-menu-item{
			text-align: center;
			display: flex;
			align-items: center;
			justify-content: center;
			height: 36px;
		}


		.user-info .profile img {
			border-radius: 50%;
			width: 42px;
			height: 42px;
			margin-right: 5px;
		}
		.notifications .bi-bell::after {
			content: "";
			height: 0.25rem;
			width: 0.25rem;
			background: red;
			position: absolute;
			border-radius: 50%;
			right: 0.2rem;
			top: 0.5vh;
		}

		/* Sidebar area */
		


		


	 </style> <style>
  /* Hiếu: đoạn này chỉnh respon cho cái modal nhắc việc*/
  @media (max-width: 992px) {
    .settings-menu {
        width: calc(100% ) !important;
    }
}


@media (max-width: 768px) {
    .settings-menu {
        width: calc(100% ) !important;
    }
}


@media (min-width: 1170px) {
    .settings-menu {
        width: calc(100%) !important;
    }
}
@media (max-width: 576px) {
    .settings-menu {
        width: calc(100%) !important;
        left: 10px;
        right: 10px;
    }
}
  .dx-drawer-shrink .dx-drawer-panel-content{
   display: none;
  }

  html, body {
   overscroll-behavior-x: none;
   height: 100% !important;
   max-height: 100% !important;
   overflow: hidden !important;
   margin: 0 !important;
   padding: 0 !important;
  }

  #MemuMenu, #MemuLogo{
     display: none;
   }

   .dx-form-group-with-caption>.dx-form-group-content{
       margin-top: unset;
     border-top: unset;
   }

   .dx-widget {
   padding: 0;
   color: unset;
  }
      :root {
      --color-white: #fff;
      --color-white-100: rgba(255, 255, 255, 0.1);
      --color-white-200: rgba(255, 255, 255, 0.2);
      --color-white-400: rgba(255, 255, 255, 0.4);
      --color-white-800: rgba(255, 255, 255, 0.8);
      --color-white-900: rgba(255, 255, 255, 0.9);
      --color-black: #1e1e1e;
      --color-black-100: rgba(0, 0, 0, 0.1);
      --color-black-50: rgba(211, 197, 197, 0.39);
      --color-black-200: rgba(0, 0, 0, 0.2);
      --color-black-500: rgba(0, 0, 0, 0.5);
      --color-black-600: rgba(0, 0, 0, 0.6);
      --color-blue-800: #007ff7;
      --app-color-white: rgb(252, 255, 251);
      --color-red: rgba(255, 2, 2, 0.788);
      --color-green: #11dd4e;
   --background-color: #ffffff;
   --background-color-radio: #000;
   --background-color-navbar: #006bc9;
   --background-color-container__Window : #262e4b;
   --background-color-transparent: rgba(0, 0, 0, 0);
      --text-color: #000000;
   --background-color-hover: rgba(0, 0, 0, 0.03);
   --text-color-hover: #ffffff;
   --selected-bg-color: #00000;
   --bd-header-rgb: 169, 94, 163;

   --bg-navtab-active: #FFFFFF;
   --bg-navtab-inactive: #E3E3E3;
   --bs-nav-link-font-size: 13px;
   --bs-nav-link-font-weight: 300;

   --bs-navbar-bg-1-rgb: 0,63,45;
   --bs-navbar-bg-2-rgb: 0,86,46;
   --bs-navbar-bg-3-rgb: 0,76,57;

   --bs-body-bg-1-rgb: 183, 177, 255;
   --bs-body-bg-2-rgb: 183, 177, 255;
   --bs-body-bg-3-rgb: 237, 249, 162;
   --bs-body-bg-4-rgb: 156, 250, 212;
   --bs-body-bg-5-rgb: 248, 176, 179;
    }
 /* Dark theme overrides */
    body.dark-mode {
 --background-color-radio: #fff;
    --background-color: #1e2329;
 --background-color-navbar: #001e38;
 --background-color-container__Window : #212529;
    --text-color: #ffffff;
 --background-color-hover: rgba(255, 255, 255,0.03);
 --text-color-hover: #000000;
 --selected-bg-color: #0B9F57;
 --bg-navtab-active: #3C3C3C;
 --bg-navtab-inactive : #2B2B2B;

   --bs-navbar-bg-1-rgb: 0, 37, 26;
   --bs-navbar-bg-2-rgb: 0, 86, 46;
   --bs-navbar-bg-3-rgb: 0, 53, 39;

   --bs-body-bg-1-rgb: 59, 55, 59;
   --bs-body-bg-2-rgb: 221, 219, 222;
   --bs-body-bg-3-rgb: 202, 212, 223;
   --bs-body-bg-4-rgb: 101, 110, 119;
   --bs-body-bg-5-rgb: 59, 55, 59;
    }

    * {
      margin: 0;
      padding: 0;
      outline: 0;
      border: 0;
      list-style: none;
    }

    @media screen and (max-width: 900px) {

    }

    button,
    input {
      background-color: transparent;
      border: 0;
      outline: 0;
      -webkit-tap-highlight-color: transparent;
    }

    body {
      height: 100vh;
      user-select: none;
      font-family: "Lexend", sans-serif;

      background-size: cover;
      overflow: hidden;
    }

  .navbar__right{
    display: flex;
    align-items: center;
    padding: 0.2rem 0.5rem 0 0.5rem;
    top: 0%;
right: 0%;
    height: 5%;
    border-radius: 14px;
    z-index: 10;
 }




    .dock {
      display: flex;
      align-items: center;
      position: fixed;
      padding: 0.2rem 0.5rem 0 0.5rem;
      left: 50%;
      transform: translateX(-50%);
      z-index: 10000;
    }

    @media screen and (max-width: 900px) {
      .dock {
        border-radius: 20px;
      }
    }

    .dock .point {
      width: 6px;
      height: 6px;
      margin: 0;
      background: #f08080;
      border-radius: 50%;
      display: none;
      animation: top-to-bottom 0.3s;
      transition: 0.3s;
 }

    /* ===== AVATAR SIZING & CIRCULAR CROPPING ===== */
    .avatar-img, .request-avatar-img {
        width: 56px !important;
        height: 56px !important;
        min-width: 56px !important;
        max-width: 56px !important;
        min-height: 56px !important;
        max-height: 56px !important;
        object-fit: cover !important;
        border-radius: 50% !important;
        border: 2px solid rgba(255, 255, 255, 0.2) !important;
        padding: 2px !important;
        box-sizing: border-box !important;
        display: inline-block !important;
        vertical-align: middle !important;
    }

    .circle, .circle.gray {
        width: 52px !important;
        height: 52px !important;
        min-width: 52px !important;
        max-width: 52px !important;
        min-height: 52px !important;
        max-height: 52px !important;
        border-radius: 50% !important;
        overflow: hidden !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        background-color: #ffffff !important;
        border: 3.5px solid #6c757d !important;
        box-sizing: border-box !important;
    }
    .circle.yellow {
        border-color: #f59e0b !important;
    }
    .circle.green {
        border-color: #10b981 !important;
    }
    .circle.red {
        border-color: #ef4444 !important;
    }
    .circle.blue {
        border-color: #0d6efd !important;
    }

    .circle img {
        width: 40px !important;
        height: 40px !important;
        min-width: 40px !important;
        max-width: 40px !important;
        min-height: 40px !important;
        max-height: 40px !important;
        border-radius: 50% !important;
        object-fit: cover !important;
        display: block !important;
    }

    .dock hr, .dock .column {
      display: inline-block !important;
      width: 1px !important;
      height: 24px !important;
      min-height: 18px !important;
      border: none !important;
      border-left: 1px solid rgba(255, 255, 255, 0.45) !important;
      background: rgba(255, 255, 255, 0.45) !important;
      margin: 0 6px !important;
      padding: 0 !important;
      opacity: 0.85 !important;
      align-self: center !important;
      box-sizing: border-box !important;
    }

    .dock .icon {
      position: relative;
      display: grid;
      place-items: center;
      border: none;
      outline: none;
      transition: all 0.3s;
      transform: translate3d(0px, 0%, 0px);
      -webkit-tap-highlight-color: transparent;
    }



    .dock .icon::after {

      position: absolute;
      background: rgba(0, 0, 0, 0.75);
 color: #FFFFFF;
      left: 50%;












      transform: translateX(-50%);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 10000;
      width: 95px;
      padding: 4px 3px 10px;
   padding-top: 20px;
      border-radius: 8px;
      font-family: "lexend", sans-serif;
      /* font-weight: 700; */

 clip-path: polygon(
         100%  100% ,   /* 100% width, 100% height */
        0px 100%,     /* 0% width, 100% height */
        0%  1.5vh,      /* 0% width, 20% height */
        43% 1.5vh,    /* 43% width, 20% height */
        50%  0%,     /* 50% width, 0% height */
        57% 1.5vh,    /* 57% width, 20% height */
        100% 1.5vh,    /* 100% width, 20% height */
        100% 100%    /* 100% width, 100% height */
);

    }

    .dock .icon svg,
    .dock .icon img,
 .dock .icon i{
      width: 3rem;
      transition: 0.2s;
      transform: translateY(-2.5px);
    }

    .dock .icon:hover svg,
    .dock .icon:hover img,
 .dock .icon:hover i.bi {
 /*  margin: 40px 0 0 0;

     width: 7.1rem; */
    }
    .dock .icon:hover + .icon svg,
    .dock .icon:hover + .icon img,
  .dock .icon:hover + .icon i{
         /* width: 5.6rem;
      margin: 25px 0 0 0; */
    }

 .dock .icon svg:active,
    .dock .icon img:active {

    filter: brightness(0.6) drop-shadow(0 0 10px #2c2c2c);
    }

   .dock .icon i.bi{
   font-size: 25px;
         padding: 0 10px;
   }



    .color_green {
      color: green;
    }

   .color_blue {
      color: #1f48ff;
    }



      .spotlight_serach {
   display: none !important;
      width: 440px;
      top: 28%;
      left: 50%;
      transform: translateX(-50%);
      border-radius: 16px;
      background-color: transparent;
      /* backdrop-filter: blur(10px); */
      z-index: 10;
      position: absolute;
    }

    /* Use flexbox to align the icon and input field */
    .spotlight_search-bar-wrapper {
      display: flex;
      align-items: center;
      border-radius: 16px;
   border-top: 1px solid;
   border-bottom: 1px solid;
   border-right: 1px solid;
   border-left: 1px solid;
      box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
    }

    .spotlight_search-bar {
      height: 50px;
      padding: 10px;
      border: none;
      outline: none;
      width: 90%;
      font-size: 20px;
      font-weight: 100;
      font-family: Lexend;
      margin-left: 10px;
      padding-right: 10px;

    }

    .spotlight_search-icon {
      margin-left: 10px;
      fill: #010003; /* Color of the SVG icon */
      margin-top: 0;
    }

    .spotlight_serach input::placeholder {

    }

    .result {
      margin-top: 15px;
      padding: 10px;
      border-radius: 8px;
      box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
   display: none;
    }

    .result-app {
      display: flex;
      align-items: center;
      padding: 15px;
      margin-bottom: 5px;
      border-radius: 8px;
      box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.1);
    }

    .result-app svg {
      width: 30px;
      height: 30px;
      background-color: #e6e6e6;
      border-radius: 5px;
      margin: 0;
      margin-right: 10px;
    }
 .result-app i{
  width: 40px;
  font-size: 30px;
   margin-right: 10px;
   padding-left: 5.5px;
   padding-top: 2.5px;
   background-color: #e6e6e6;
      border-radius: 5px;
 }

 .app-info {
      font-size: 16px;
    }

    .app-info .app-name {
      font-weight: bold;

    }

    .app-info .app-details {
      color: gray;
      font-size: 12px;
    }
 #appapp{
   background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
 }

.launchpad {

      display: none;
      /* animation: opacity 300ms; */

  width: 100%;
      height: 100vh;
      background-color: transparent;
      /* backdrop-filter: blur(25px);
        -webkit-backdrop-filter: blur(25px); */
      position: relative;
   /* background: var(--background-color-container__Window);
   background-image: radial-gradient(circle, rgba(200, 200, 200, 0.2) 1px, transparent 1px);
   background-size: 20px 20px; */
   padding-top: 3%;
   background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
    }

     .launchpad .child-launchpad svg,
  .launchpad .child-launchpad i{
  border: 1px solid #e0e0e0;
        height: 65px;
        width: 65px;
        border-radius: 16px;
        /* background: linear-gradient(145deg, #f0f0f0, #c0c0c0);
        filter: drop-shadow(0 6px 12px rgba(0, 0, 0, 0.2)); */
        transition: transform 0.3s ease, filter 0.3s ease, background 0.3s ease;
        box-shadow: inset 0 4px 6px rgba(255, 255, 255, 0.3),
                  0 4px 10px rgba(0, 0, 0, 0.1);
  }

 .launchpad .child-launchpad i{
     display: flex;
  align-items: center;
  justify-content: center;
  font-size: 50px;

 }


    .launchpad .child-launchpad svg:hover {
        transform: scale(1.1);
    }


      .launchpad .child-launchpad span{
        margin-top: 8px;

      }



    .prev-button,
    .next-button {
    position: absolute;
    background-color: transparent;
    border: none;
    padding: 10px;
    cursor: pointer;
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px; /* Adjust size as needed */
    }

    .prev-button {
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    }

    .prev-button:hover {
     color:  rgb(175, 173, 173);
    }

    .next-button {
    right: 0;
    top: 50%;
transform: translateY(-50%);
    }

    .next-button:hover {
        color:  rgb(175, 173, 173);;
    }



    .searchbox {
      width: 100%;
      height: 100px;
      display: flex;
      justify-content: center;
      align-items: center;
  }

    .searchbox .searchContainer {









      height: 30px;
     width: 220px;
    display: flex;
  align-items: center;
      justify-content: space-evenly;
      border-top: 1px solid ;
      border-bottom: 1px solid ;
     border-right: 1px solid ;
      border-left: 1px solid ;
      border-radius: 4px;
      padding: 0 3px;
    }

    .searchbox .searchContainer svg {
      fill: #fff;
    }

    .searchbox input {
      text-align: center;

      font-size: 16px;
      height: 100%;
      font-family: "Roboto", sans-serif;
    }

    .searchbox input::placeholder {

      font-weight: 100;
    }

    .searchbox input:focus {
      text-align: left;
    }

    /*.Apps-container {
      width: 90%;
      height: 75%;
      margin-left: 3%;
   margin-right: 3%;
      display: grid;
      grid-row-gap: 10px;
      grid-template-columns: 15% 15% 15% 15% 15% 15% 15%;
      grid-template-rows: 25% 25% 25% 25%;
    } */

    .launchpad .child-launchpad {
   padding-top: 2vh;
      display: flex;
      place-items: center;
      flex-direction: column;
   cursor:  pointer;
    }

    .launchpad .child-launchpad img {
      width: 80px;
    }

    @media screen and (min-width: 1200px) {
     /* .launchpad .Apps-container {
        grid-row-gap: 20px;
      } */
      .launchpad .child-launchpad img {
        width: 80px;
      }
      .launchpad .child-launchpad span {

      }
}



.launchpad .child-launchpad:active {
animation: vibrate 0.1s ease-in forwards infinite alternate;
   transition: transform 0.1s cubic-bezier(0.42, 0, 1, 0.2);
    }

    .launchpad .child-launchpad span {
   /* color: #fff; */
    }


    /******Animations*****/

    @keyframes zoom-out {
      0% {
        transform: scale(1);
      }
      50% {
        transform: scale(1.2);
      }
      100% {
        transform: scale(1);
      }
    }

    @keyframes to-top-bottom {
      0% {
        transform: translate(0);
      }
      25% {
        transform: translateY(-12px);
      }
      50% {
        transform: translateY(-3px);
      }
      75% {
        transform: translateY(-21px);
      }
      100% {
        transform: translateY(0px);
      }
    }

    @keyframes vibrate {
      0% {
        transform: rotate(9deg);
      }
      100% {
        transform: rotate(-9deg);
      }
    }

    @keyframes top-to-bottom {
      0% {
        transform: translateY(-60px);
        opacity: 0;
      }
      100% {
        transform: none;
        opacity: 1;
      }
    }
    @keyframes opacity {
      0% {
        opacity: 0;
        transform: scale(1.2);
      }
      100% {
        opacity: 1;
   transform: scale(1);
      }
    }


 /******Context menu*****/

    .context-menu {
      padding: 0 3px;
      position: absolute;
      border-radius: 7px;
      text-align: center;
      border: 1px solid ;
      overflow: hidden;
      backdrop-filter: blur(15px);
    }

    .context-menu ul {
      padding: 0;
      margin: 0;
      min-width: 250px;
      list-style: none;
    }

    .context-menu ul li {
      margin: 4px 0;
      border-bottom: 1px solid ;
    }

    .context-menu ul li:last-child {
      border: none;
    }

    .context-menu ul li button {

      width: 100%;
      height: 100%;
      text-align: left;
      font-size: 15px;
      font-family: "Lexend", sans-serif;
      border-radius: 5px;
      padding: 4px 8px;
      transition: 80ms;
      font-weight: 300;
      margin: 0 0 4px 0;
      display: flex;
      flex-direction: row;
      cursor: pointer;
    }
    .context-menu ul button:hover {
     /*  background: var(--color-blue-800); */
    }

   /* Widgets panel */
      .widgets-panel {
        position: fixed;
        top: 35%;
        left: 30%;
        transform: translateX(115%);
        transition: all 0.3s cubic-bezier(0.79, 0.14, 0.15, 0.86);
/* backdrop-filter: blur(1rem); */
        border: 1px solid ;
     border-radius: 16px;
overflow: hidden;
  box-shadow: 0 0 30px rgba(0, 0, 0, 0.555);

 }


      .widgets-panel.open {
        transform: translateX(0);
  display: none !important;
      }
      .widgets-panel__calendar {
        background: transparent;
        padding: 16px;
        min-width: 700px;
        min-height: 400px;
      }
      .widgets-panel #taghvim {
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .widgets-panel__calendar h4 {

        font-size: 14px;
        font-weight: 500;
        text-transform: uppercase;
        margin-left: 8px;
        margin-bottom: -10px;
   }
      .widgets-panel__calendar h2 {

        font-size: 45px;
        font-weight: 300;
      }
      .widgets-panel__calendar li {
position: relative;
 padding: 4px 10px;
        font-size: 15px;
        border-radius: 4px;
        margin-left: 8px;
        margin: 8px 0;
      }
      .widgets-panel__calendar li::before {
        content: "";
        width: 8px;
        height: calc(100% - 2px);
        position: absolute;
        border-radius: 99px;
        top: 2px;
        left: -12px;
      }
      .widgets-panel__calendar li.blue {
      color: #34aadc;
        background: #283646;
     }
      .widgets-panel__calendar li.blue::before {
background: #34aadc;
      }
      .widgets-panel__calendar li.green {
        color: #32d74b;
    background: #2d402e;
      }
      .widgets-panel__calendar li.green::before {
        background: #32d74b;
      }
      .widgets-panel__calendar li.purple {
        color: #9c5ffd;
        background: #422948;
      }
      .widgets-panel__calendar li.purple::before {
        background: #7a3edb;
      }
      .widgets-panel__calendar li span {
        display: block;
      }
      .widgets-panel__calendar li span:first-child {
        font-weight: bold;
      }

   /* Container app */

      .container__Window {
        /*
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: space-around;
        align-items: center;
        position: absolute;
        background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
       */
       /* background: var(--background-color-container__Window);
        background-image: radial-gradient(circle, rgba(200, 200, 200, 0.2) 1px, transparent 1px);
        background-size: 20px 20px; */

      }

      .window {
       display: none;
      max-width: 100%;
   min-width: 100%;
      min-height: 93%;
      height: 93%;
   margin-top: 3%;
      overflow: hidden;
      border-radius: 0;
  background: transparent;
      box-shadow: 0 20px 30px var(--color-black-500);
      border: 1px solid #ffffff34;
      animation: zoom-out 0.3s;
   touch-action: none;
    z-index: 100;
    transition: transform 0.7s ease, opacity 0.7s ease, width 0.7s ease, height 0.7s ease;
 }

   .window__taskbar {
    height: 12%;
    display: flex;
    justify-content: space-between;
    padding: 0 16px;
    background-color: var(--app-color-white);
  }

  .window__taskbar--actions {
  display: flex;
  align-items: center;
  }

  .window__taskbar:hover button::after {
    color: #000;
  }

  .window__taskbar--actions button {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 0.8rem;
    height: 0.8rem;
    padding: 8px;
    border-radius: 50%;
    transition: 0.4s;
  }

  .window__taskbar--actions button:not(:last-child) {
    margin-right: 8px;
  }

  .window__taskbar--actions button:nth-child(1) {
    background-color: #ff5f56;
    box-shadow: 0 0 0 0.5px #e0443e;
  }

 .window__taskbar--actions button::after {
    display: block;
    font-size: 14px;
    color: transparent;
    font-weight: 900;
  }

  .window__taskbar--actions button:nth-child(1)::after {
    content: "×";
  }

.window__taskbar--actions button:nth-child(1):hover {
    background-color: #fc3c32;
  }

  .window__taskbar--actions button:nth-child(2) {
    background-color: #ffbd2e;
  box-shadow: 0 0 0 0.5px #dea123;
  }

  .window__taskbar--actions button:nth-child(2)::after {


    content: "−";
  }

  .window__taskbar--actions button:nth-child(2):hover {
    background-color: #ffa600;
  }

  .window__taskbar--actions button:nth-child(3) {
    background-color: #27c93f;
    box-shadow: 0 0 0 0.5px #1aab29;
  }

  .window__taskbar--actions button:nth-child(3)::after {
    content: "🗗";
  }

  .window__taskbar--actions button:nth-child(3):hover {
    background-color: #12aa29;
  }

  .window__taskbar--content {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .window__taskbar--content h2 {
    color: var(--color-black);
    font-weight: 600;
    font-size: 18px;
  }

  .window__taskbar {
    height: 3%;
  }

.window_content {
  width: 100%;
  height: 100%;
  overflow-y: scroll;
/* padding-left: 1rem; */
  background-color: var(--app-color-white);
  /* backdrop-filter: blur(120px); */
  color: rgb(235, 235, 235);
 font-size: 20px;
  font-family: "Roboto Mono", monospace;
}






   .navbar-home {
    border-bottom: 1px solid var(--bs-border-color);
    width: 100%;
    padding: 0.1rem 0;
    position: fixed;
    top: 0;
    left: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    z-index: 10000;
    animation: top-to-bottom 0.3s;
 background: linear-gradient(90deg, rgba(var(--bs-navbar-bg-1-rgb),0.95) 0%, rgba(var(--bs-navbar-bg-2-rgb),1) 50%, rgba(var(--bs-navbar-bg-3-rgb),0.95) 100%);
    /*background-image: linear-gradient(rgba(var(--bd-header-rgb), 1), rgba(var(--bd-header-rgb), 0.95));
    background:  var(--background-color-navbar);
    background-image: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
    background-size: 15px 15px; */
    }

 .navbar-home i{
  color: var(--color-white);
 }

 /* Ensure dropdown menus are hidden by default */
 .dropdown-menu {
   display: none;
   position: absolute;
 }

 /* Show the dropdown menu when it has the ''show'' class */
 .dropdown-menu.show {
   display: block;
   right: 0;
 }
     .hover-span {
            position: relative;
            cursor: pointer;
        }
  .hover-span i {
    transition: all 0.2s ease !important;
  }
   .hover-span:hover i {
   font-size: 55px;
   height: 70px;
   width: 70px;
   }


    .hover-span::after {
            content: "";
            left: 50%;
            opacity: 0;
            pointer-events: none;
           transition: all 0.2s ease !important;
        }



        .hover-span:hover::after {
           opacity: 1;
        }

  .hover-span span {
            transition: opacity 0.3s ease;
        }

   .hover-span:hover span {
            opacity: 0;
        }




  .notifications i{
   padding-top: 20px;
   font-size: 26px;

    }

    .master-tabs{
       /*
       position: absolute;
       top: 6%;
       right: 0%;
       width: 87.4%;
        */
       height: calc(100vh - var(--navbar-height, 37px)) !important;
       min-height: 0 !important;
       max-height: calc(100vh - var(--navbar-height, 37px)) !important;
       background-color: var(--background-color);
       padding-bottom: 0 !important;
       box-sizing: border-box !important;
       overflow: hidden !important;
       /* color: var(--text-color); */
       /*
       z-index: 10000;
       display: none;
       transition: width 0.3s ease;
       */
    }
    .master-tabs .nav-tabs{
       /*padding-top: 0.3vh;*/
    }
     .tab-pane {
        max-height: 90vh;
    }

         /* Customize the scrollbar (Webkit browsers like Chrome, Safari) */

   .tab-pane::-webkit-scrollbar {
    width: 7px;
   }

    .tab-pane::-webkit-scrollbar-thumb {
    background-color: #888;
    border-radius: 10px;
  }

  .tab-pane::-webkit-scrollbar-thumb:hover {
  background: #555;
   }

    .tab-pane::-webkit-scrollbar-track {
    background: #f1f1f1;
   }

    /* Customize the scrollbar (Webkit browsers like Chrome, Safari) */
    #scrollsidebar::-webkit-scrollbar {
    width: 7px;
   }

    #scrollsidebar::-webkit-scrollbar-thumb {
    background-color: #888;
    border-radius: 10px;
   }

    #scrollsidebar::-webkit-scrollbar-thumb:hover {
    background: #555;
   }

    #scrollsidebar::-webkit-scrollbar-track {
    background: #f1f1f1;
   }

    #scrollsidebar::-webkit-scrollbar {
    display: none;
   }


    .home-sidebar{
   position: absolute;
   top: var(--navbar-height, auto);
   bottom: 0px;
   left: 0%;
   /*
   height: 110%;
   */
   height: calc(100vh - var(--navbar-height, 0px));

   z-index: 1000;

   /* overflow-y: scroll;
   direction: rtl; */
   display: none;
    }

    #MainSideBar .sidebar {
      height: 100%;
      min-height: 100%;
    }

    .tab-content{
       /*
       background-color: var(--background-color);
       min-height: 95vh;
       */
       color: var(--text-color);
    }

    /* Text below the icon */
  .icon-text {
   display: block;
   margin-top: 5px;
   font-size: 12px;
   color: white;
  }


   .dock .icon::before {

    position: absolute;
    bottom: -18%;
    left: 50%;

    display: flex;
    justify-content: center;
    align-items: center;

    width: 50px;
    height: 0px;
    font-family: "lexend", sans-serif;
    color: #ffffff;
    /* display: var(--before-display, block); */

    display: none;
  }


  .master-tabs .nav-tabs .nav-item.dropdown{
   /* position: absolute;
      right: 0; */
  }
   #tabContent .overlay {
          position: absolute;
          top: 0;
          left: 0;
          width: 100vw;
          height: 100vh;
          background: rgba(0, 0, 0, 0.5);
          display: none;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          z-index: 50;
          display: none;
        }


      #tabContent .overlay.hidden {
          display: none;
        }
    #tabContent .container-spin {
          --uib-size: 40px;
          --uib-color: white;
          --uib-speed: 2s;
          --uib-bg-opacity: 0;
   height: var(--uib-size);
          width: var(--uib-size);
          transform-origin: center;
          animation: rotate var(--uib-speed) linear infinite;
          will-change: transform;
          overflow: visible;
        }

       #tabContent .car-spin {
          fill: none;
          stroke: var(--uib-color);
          stroke-dasharray: 1, 200;
          stroke-dashoffset: 0;
          stroke-linecap: round;
          animation: stretch calc(var(--uib-speed) * 0.75) ease-in-out infinite;
          will-change: stroke-dasharray, stroke-dashoffset;
          transition: stroke 0.5s ease;
        }

      #master-tabs .track-spin {
          fill: none;
          stroke: var(--uib-color);
          opacity: var(--uib-bg-opacity);
          transition: stroke 0.5s ease;
        }

        @keyframes rotate {
          100% {
            transform: rotate(360deg);
          }
        }

        @keyframes stretch {
          0% {
            stroke-dasharray: 0, 150;
            stroke-dashoffset: 0;
          }

          50% {
            stroke-dasharray: 75, 150;
            stroke-dashoffset: -25;
          }

          100% {
            stroke-dashoffset: -100;
          }
        }

  .highLightApp{
   background: var(--color-white-100);
   border-radius: 6px;
  }

  .nav-item{
    padding-right: 0.1%;
  }

  .nav-tabs .nav-link{
      padding-bottom: 6px;
   padding-right: 10px !important;;
   border-top-left-radius: 13px;
border-top-right-radius: 13px;
  }

  .nav-tabs .nav-link div{
      margin-top: 0.05vh;
   display: flex;
   align-items: center;
   justify-content: center;
  }

  .nav-tabs .nav-link .ms-1{
        margin-left: 0.7rem !important;
  }


button.nav-link:not(.active) {
    background-color: var(--bg-navtab-inactive) !important;
  }

  button.nav-link.active {
    position: relative;
    background-color: var(--bg-navtab-active) !important;
    background: linear-gradient(to bottom, #00a9f2 4px, transparent 4px);
    color: #00a9f2 !important;
  }

  button.nav-link.active::before {
   position: absolute;
   content: '''';
   left: -20%;
   top: 50%;
   height: 50px;
   width: 50px;
   background-color: var(--bg-navtab-active);
   border-radius: 50%;
   display: none;
  }

  .nav-item:has(button.active){
   position: relative;
  }

  .nav-item:has(button.active)::before {
      content: "";
   position: absolute;
   top: 50%;
   left: -30px;
   width: 30px;
   height: 30px;
   background-color: var(--bg-navtab-inactive);

   border-radius: 50%;
   z-index: 1;
   transform: translateY(-50%);
   display: none;
  }



    .tab-content{
  border-left: 1px solid var(--bs-border-color);
  }



  .wrapper-launchpad{
   display: flex;
   padding: 0 35px;
   align-items: center;
   justify-content: center;
  }

  .Apps-page-container{
   position: absolute;
   width: 85.5vw;
   height: 71.5vh;
   display: grid;
   grid-row-gap: 10px;
   grid-template-columns: 15% 15% 15% 15% 15% 15% 15%;
   grid-template-rows: 25% 25% 25% 25%;
  }

  .wrapper-launchpad .Apps-container{
   display: inline-block;

   position: relative;
   height: 75vh;

  }

  .wrapper-launchpad-child{
   max-width: 100vw;
   position: relative;
  }

  .wrapper-launchpad-child i.change-icon{
   top: 50%;
   height: 46px;
   width: 46px;
   cursor: pointer;
   position: absolute;
   font-size: 1.2rem;
   text-align: center;
   line-height: 46px;
   background: #fff;
   color: black;
   border-radius: 50%;
   transform: translateY(-50%);
  }

  .wrapper-launchpad-child i.change-icon:first-child{
   left: -53px;
   display: none;
  }

  .wrapper-launchpad-child i.change-icon:last-child{
   right: -53px;
  }

  .wrapper-launchpad-child .carousel{
   width: 90vw;
   cursor: pointer;
   overflow: hidden;
   white-space: nowrap;
   scroll-behavior: smooth;
  }

  .carousel.dragging{
   cursor: grab;
   scroll-behavior: auto;
  }

  .carousel.dragging .Apps-container{
   pointer-events: none;
  }

  .carousel .Apps-container{

   object-fit: cover;
   margin-left: 14px;
   width: 100%;
  }

  .carousel .Apps-container:first-child{
   margin-left: 0px;
  }


  #master-tabs .nav-tabs span i{
      display: inline-block;
   height: 2vh;
   width: 2vh;
   border-radius: 50%;
  }

  #master-tabs .nav-tabs span i::before{
       display: flex;
   align-items: center;
   justify-content: center;
   height: 2vh;
   width: 2vh;

   border-radius: 50%;
  }



  #master-tabs .nav-tabs span i:hover{
      background: #dcdcdc;
  }

  .nav-link,
  .nav-link:hover
  {
   color: unset;
  }

  .navbar__left .logo{
       cursor: pointer;
  }


  .tab-loader{
   top: 40vh;
   left: 41vw;
   position: absolute;
   z-index: 1000;
  }

  #dashboard_main{
 background-color: var(--background-color);
  }
/*Hiếu: cho tất cả thẻ h cùng 1 màu cho đồng bộ*/
  h1, h2, h3, h4, h5, h6 {
        color: #00673b;
    }
  </style> <style>
				
		

	    </style> <style>
		
		/* Toggle Wrapper */
		.toggle-wrapper {
		  margin-right: 20px;
		/*  position: fixed;
		  top: 1rem;
		  right: 1rem; */
		}

		
    #themeIcon {
      font-size: 24px;
    }


	 </style> <style>
		
		
		#MainSideBar .pool-ball {
			width: 24px;
			height: 24px;
			background-color: #E03137;
			border-radius: 50%;
			display: flex;
			align-items: center;
			justify-content: center;
			position: relative;
			/* transition: all 0.3s; */
		}


		#MainSideBar .number {
			color: #ffffff;
			font-size: 17px;
			font-weight: bold;
			font-family: ''Arial'', sans-serif;

		}
		#MainSideBar .tree-button i{
			font-size: 20px !important;
		}

		#MainSideBar .menu-button {
			background: none;
			border: none;
			font-size: 20px;
			cursor: pointer;
			color: #757575;
			width: 40px;
			height: 40px;
			border-radius: 50%;
			/*background-color: #fff;*/
			/*transition: all 0.3s ease;*/
			z-index: 1000;
		}


		#MainSideBar .menu-button:hover{
			/*background-color: #dbdbdb;
			color: #000;*/
		}

		#MainSideBar .menu-button{
			/*transition: all 0.3s; */
		}
		#MainSideBar .menu-button .collapsed{
			/* margin-left: -33%; */
		}

	
		#MainSideBar .sidebar{
			position: relative;
			/*width: 18%;*/
			height: 106%;
			display: flex;
			flex-direction: column;
			gap: 20px;
			background-color: var(--background-color);
			color: var(--text-color);
			/*padding: 24px;*/
			/* border-radius: 30px; */
			/*transition: all 0.3s; */
			/*overflow: auto;*/
			transition: width 0.3s ease;
			
			/*width: 269px;*/ /* Chiều rộng ban đầu của sidebar */
		}
		#MainSideBar .sidebar.collapsed {
			width: 54px; /* Chiều rộng khi thu nhỏ */
		}
		#MainSideBar .menu ul li a .text {
		}
			#MainSideBar .sidebar.collapsed .menu ul li a .text {
		opacity: 0; /* Ẩn chữ khi thu nhỏ */
		display: none; /* Đảm bảo text ẩn hoàn toàn khi thu nhỏ */
	}
		#MainSideBar .menu .title{
			font-size: 10px;
			font-weight: 600;
			color: #21252B;
			text-transform: uppercase;
			margin-bottom: 10px;
		}

		#MainSideBar .nav{
			flex: 1;
			max-height: 100vh;
		
			padding: 0px 24px;
		}
		

		#MainSideBar .menu ul li{
			position: relative;
			list-style: none;
			margin-bottom: 5px;
		}

		#MainSideBar .menu ul li a{
			display: flex;
			align-items: center;
			gap: 10px;
			font-size: 14px;
			font-weight: 500;
			color: var(--text-color);
			text-decoration: none;
			padding: 12px 8px;
			border-radius: 8px;
			/* transition: all 0.3s; */
		}

		#MainSideBar .menu ul li > a {
			position: relative;
		}

		 #MainSideBar.menu ul li > a:hover::before,
		 .menu ul li.active > a::before {
		
			position: absolute;
			left: 0px;
			top: 50%;
			transform: translateY(-50%);
			width: 2px;
			height: 21px;
			/*background-color: var(--primary);*/
			border-radius: 2px;
			/*color: var(--selected-bg-color);*/
		}
		#MainSideBar .menu ul{
			padding-left: 0;
		}
		#MainSideBar .menu ul li > a:hover,
		#MainSideBar .menu ul li.active > a {
			
			background-color: var(--background-color-hover);
		}

		#MainSideBar .menu ul li .icon{
			font-size: 20px;
		}

		#MainSideBar .menu ul li .text{
			flex: 1;
		}

		#MainSideBar .menu ul li .arrow{
			font-size: 14px;
		/*	transition: all 0.3s; */
		}

		#MainSideBar .menu ul li.active .arrow{
			transform: rotate(180deg);
		}

		#MainSideBar .menu .sub-menu{
			display: none;
			margin-left: 20px;
			/*padding-left: 20px;*/
			padding-top: 5px;
			
		}

		#MainSideBar .menu .sub-menu li a{
			padding: 10px 8px;
			font-size: 14px;
		}

		#MainSideBar .menu:not(:last-child){
			padding-bottom: 10px;
			margin-bottom: 20px;
			border-bottom: 2px solid #f6f6f6;
		}

		#MainSideBar .sidebar.active{
			width: 92px;
		}

		#MainSideBar .sidebar.active .menu .title{
			text-align: center;
		}

		#MainSideBar .sidebar.active .menu ul li .arrow{
			display: none;
		}

		#MainSideBar .sidebar.active .menu > ul > li > a{
			position: relative;
			display: flex;
			align-items: center;
			justify-content: center;
		}

		
			#MainSideBar .menu ul li.active a {
			/*color: var(--selected-bg-color);*/
		}
		

	

		#MainSideBar .sidebar.active .menu .sub-menu{
			position: absolute;
			top: 0;
			left: 20px;
			width: 200px;
			border-radius: 20px;
			padding: 10px 20px;
			border: 1px solid #f6f6f6;
			background-color: #fff;
			box-shadow: 0px 10px 8px rgba(0,0,0,0.1);
		}


		#MainSideBar .sidebar.active .menu ul li .pool-ball{
			position: absolute;
			top: 0;
			right: 0;
			background-color: red;
			color: white;
			border-radius: 50%;
			width: 24px;
			height: 24px;
			display: flex;
			align-items: center;
			justify-content: center;
			font-size: 12px;
			font-weight: bold;
		}
		#MainSideBar .content {
			width: 100%;
			height: 100%;
			
			padding: 24px;
			 overflow-y: auto;
		}
		#MainSideBar .sidebar .text {
			display: inline-block;
			max-width: 190px;
			white-space: normal;
			word-break: break-word;
			line-height: 1.2;
}

		 </style> <style>
			
		 /* Mobile devices (portrait and landscape) */
    @media (max-width: 600px) {
      .dock .icon svg,
        .dock .icon img {
          width: 2rem;

        }

        .widgets-panel {
          left: 0%;
          right: 0%;
        }
        .widgets-panel__calendar{
          min-width: 380px;
          min-height: 300px;
        }
    }

  /* Tablets and small desktops */
@media (min-width: 601px) and (max-width: 1300px) {

		.dock .icon i.bi{
		  font-size: 20px;
		}

		.dock .icon i.bi::before{
		  transform: translateX(-13%);
		}

        .dock .icon svg,
		.dock .icon i,
        .dock .icon img {
          width: 2.2rem;

        }

		.dock hr, .dock .column {
      display: inline-block !important;
      width: 1px !important;
      height: 24px !important;
      min-height: 18px !important;
      border: none !important;
      border-left: 1px solid rgba(255, 255, 255, 0.45) !important;
      background: rgba(255, 255, 255, 0.45) !important;
      margin: 0 6px !important;
      padding: 0 !important;
      opacity: 0.85 !important;
      align-self: center !important;
      box-sizing: border-box !important;
    }

    .dock .icon {
      position: relative;
      display: grid;
      place-items: center;
      border: none;
      outline: none;
      transition: all 0.3s;
      transform: translate3d(0px, 0%, 0px);
      -webkit-tap-highlight-color: transparent;
    }



    .dock .icon::after {

      position: absolute;
      background: rgba(0, 0, 0, 0.75);
 color: #FFFFFF;
      left: 50%;












      transform: translateX(-50%);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 10000;
      width: 95px;
      padding: 4px 3px 10px;
   padding-top: 20px;
      border-radius: 8px;
      font-family: "lexend", sans-serif;
      /* font-weight: 700; */

 clip-path: polygon(
         100%  100% ,   /* 100% width, 100% height */
        0px 100%,     /* 0% width, 100% height */
        0%  1.5vh,      /* 0% width, 20% height */
        43% 1.5vh,    /* 43% width, 20% height */
        50%  0%,     /* 50% width, 0% height */
        57% 1.5vh,    /* 57% width, 20% height */
        100% 1.5vh,    /* 100% width, 20% height */
        100% 100%    /* 100% width, 100% height */
);

    }

    .dock .icon svg,
    .dock .icon img,
 .dock .icon i{
      width: 3rem;
      transition: 0.2s;
      transform: translateY(-2.5px);
    }

    .dock .icon:hover svg,
    .dock .icon:hover img,
 .dock .icon:hover i.bi {
 /*  margin: 40px 0 0 0;

     width: 7.1rem; */
    }
    .dock .icon:hover + .icon svg,
    .dock .icon:hover + .icon img,
  .dock .icon:hover + .icon i{
         /* width: 5.6rem;
      margin: 25px 0 0 0; */
    }

 .dock .icon svg:active,
    .dock .icon img:active {

    filter: brightness(0.6) drop-shadow(0 0 10px #2c2c2c);
    }

   .dock .icon i.bi{
   font-size: 25px;
         padding: 0 10px;
   }



    .color_green {
      color: green;
    }

   .color_blue {
      color: #1f48ff;
    }



      .spotlight_serach {
   display: none !important;
      width: 440px;
      top: 28%;
      left: 50%;
      transform: translateX(-50%);
      border-radius: 16px;
      background-color: transparent;
      /* backdrop-filter: blur(10px); */
      z-index: 10;
      position: absolute;
    }

    /* Use flexbox to align the icon and input field */
    .spotlight_search-bar-wrapper {
      display: flex;
      align-items: center;
      border-radius: 16px;
   border-top: 1px solid;
   border-bottom: 1px solid;
   border-right: 1px solid;
   border-left: 1px solid;
      box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
    }

    .spotlight_search-bar {
      height: 50px;
      padding: 10px;
      border: none;
      outline: none;
      width: 90%;
      font-size: 20px;
      font-weight: 100;
      font-family: Lexend;
      margin-left: 10px;
      padding-right: 10px;

    }

    .spotlight_search-icon {
      margin-left: 10px;
      fill: #010003; /* Color of the SVG icon */
      margin-top: 0;
    }

    .spotlight_serach input::placeholder {

    }

    .result {
      margin-top: 15px;
      padding: 10px;
      border-radius: 8px;
      box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
   display: none;
    }

    .result-app {
      display: flex;
      align-items: center;
      padding: 15px;
      margin-bottom: 5px;
      border-radius: 8px;
      box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.1);
    }

    .result-app svg {
      width: 30px;
      height: 30px;
      background-color: #e6e6e6;
      border-radius: 5px;
      margin: 0;
      margin-right: 10px;
    }
 .result-app i{
  width: 40px;
  font-size: 30px;
   margin-right: 10px;
   padding-left: 5.5px;
   padding-top: 2.5px;
   background-color: #e6e6e6;
      border-radius: 5px;
 }

 .app-info {
      font-size: 16px;
    }

    .app-info .app-name {
      font-weight: bold;

    }

    .app-info .app-details {
      color: gray;
      font-size: 12px;
    }
 #appapp{
   background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
 }

.launchpad {

      display: none;
      /* animation: opacity 300ms; */

  width: 100%;
      height: 100vh;
      background-color: transparent;
      /* backdrop-filter: blur(25px);
        -webkit-backdrop-filter: blur(25px); */
      position: relative;
   /* background: var(--background-color-container__Window);
   background-image: radial-gradient(circle, rgba(200, 200, 200, 0.2) 1px, transparent 1px);
   background-size: 20px 20px; */
   padding-top: 3%;
   background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
    }

     .launchpad .child-launchpad svg,
  .launchpad .child-launchpad i{
  border: 1px solid #e0e0e0;
        height: 65px;
        width: 65px;
        border-radius: 16px;
        /* background: linear-gradient(145deg, #f0f0f0, #c0c0c0);
        filter: drop-shadow(0 6px 12px rgba(0, 0, 0, 0.2)); */
        transition: transform 0.3s ease, filter 0.3s ease, background 0.3s ease;
        box-shadow: inset 0 4px 6px rgba(255, 255, 255, 0.3),
                  0 4px 10px rgba(0, 0, 0, 0.1);
  }

 .launchpad .child-launchpad i{
     display: flex;
  align-items: center;
  justify-content: center;
  font-size: 50px;

 }


    .launchpad .child-launchpad svg:hover {
        transform: scale(1.1);
    }


      .launchpad .child-launchpad span{
        margin-top: 8px;

      }



    .prev-button,
    .next-button {
    position: absolute;
    background-color: transparent;
    border: none;
    padding: 10px;
    cursor: pointer;
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px; /* Adjust size as needed */
    }

    .prev-button {
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    }

    .prev-button:hover {
     color:  rgb(175, 173, 173);
    }

    .next-button {
    right: 0;
    top: 50%;
transform: translateY(-50%);
    }

    .next-button:hover {
        color:  rgb(175, 173, 173);;
    }



    .searchbox {
      width: 100%;
      height: 100px;
      display: flex;
      justify-content: center;
      align-items: center;
  }

    .searchbox .searchContainer {









      height: 30px;
     width: 220px;
    display: flex;
  align-items: center;
      justify-content: space-evenly;
      border-top: 1px solid ;
      border-bottom: 1px solid ;
     border-right: 1px solid ;
      border-left: 1px solid ;
      border-radius: 4px;
      padding: 0 3px;
    }

    .searchbox .searchContainer svg {
      fill: #fff;
    }

    .searchbox input {
      text-align: center;

      font-size: 16px;
      height: 100%;
      font-family: "Roboto", sans-serif;
    }

    .searchbox input::placeholder {

      font-weight: 100;
    }

    .searchbox input:focus {
      text-align: left;
    }

    /*.Apps-container {
      width: 90%;
      height: 75%;
      margin-left: 3%;
   margin-right: 3%;
      display: grid;
      grid-row-gap: 10px;
      grid-template-columns: 15% 15% 15% 15% 15% 15% 15%;
      grid-template-rows: 25% 25% 25% 25%;
    } */

    .launchpad .child-launchpad {
   padding-top: 2vh;
      display: flex;
      place-items: center;
      flex-direction: column;
   cursor:  pointer;
    }

    .launchpad .child-launchpad img {
      width: 80px;
    }

    @media screen and (min-width: 1200px) {
     /* .launchpad .Apps-container {
        grid-row-gap: 20px;
      } */
      .launchpad .child-launchpad img {
        width: 80px;
      }
      .launchpad .child-launchpad span {

      }
}



.launchpad .child-launchpad:active {
animation: vibrate 0.1s ease-in forwards infinite alternate;
   transition: transform 0.1s cubic-bezier(0.42, 0, 1, 0.2);
    }

    .launchpad .child-launchpad span {
   /* color: #fff; */
    }


    /******Animations*****/

    @keyframes zoom-out {
      0% {
        transform: scale(1);
      }
      50% {
        transform: scale(1.2);
      }
      100% {
        transform: scale(1);
      }
    }

    @keyframes to-top-bottom {
      0% {
        transform: translate(0);
      }
      25% {
        transform: translateY(-12px);
      }
      50% {
        transform: translateY(-3px);
      }
      75% {
        transform: translateY(-21px);
      }
      100% {
        transform: translateY(0px);
      }
    }

    @keyframes vibrate {
      0% {
        transform: rotate(9deg);
      }
      100% {
        transform: rotate(-9deg);
      }
    }

    @keyframes top-to-bottom {
      0% {
        transform: translateY(-60px);
        opacity: 0;
      }
      100% {
        transform: none;
        opacity: 1;
      }
    }
    @keyframes opacity {
      0% {
        opacity: 0;
        transform: scale(1.2);
      }
      100% {
        opacity: 1;
   transform: scale(1);
      }
    }


 /******Context menu*****/

    .context-menu {
      padding: 0 3px;
      position: absolute;
      border-radius: 7px;
      text-align: center;
      border: 1px solid ;
      overflow: hidden;
      backdrop-filter: blur(15px);
    }

    .context-menu ul {
      padding: 0;
      margin: 0;
      min-width: 250px;
      list-style: none;
    }

    .context-menu ul li {
      margin: 4px 0;
      border-bottom: 1px solid ;
    }

    .context-menu ul li:last-child {
      border: none;
    }

    .context-menu ul li button {

      width: 100%;
      height: 100%;
      text-align: left;
      font-size: 15px;
      font-family: "Lexend", sans-serif;
      border-radius: 5px;
      padding: 4px 8px;
      transition: 80ms;
      font-weight: 300;
      margin: 0 0 4px 0;
      display: flex;
      flex-direction: row;
      cursor: pointer;
    }
    .context-menu ul button:hover {
     /*  background: var(--color-blue-800); */
    }

   /* Widgets panel */
      .widgets-panel {
        position: fixed;
        top: 35%;
        left: 30%;
        transform: translateX(115%);
        transition: all 0.3s cubic-bezier(0.79, 0.14, 0.15, 0.86);
/* backdrop-filter: blur(1rem); */
        border: 1px solid ;
     border-radius: 16px;
overflow: hidden;
  box-shadow: 0 0 30px rgba(0, 0, 0, 0.555);

 }


      .widgets-panel.open {
        transform: translateX(0);
  display: none !important;
      }
      .widgets-panel__calendar {
        background: transparent;
        padding: 16px;
        min-width: 700px;
        min-height: 400px;
      }
      .widgets-panel #taghvim {
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .widgets-panel__calendar h4 {

        font-size: 14px;
        font-weight: 500;
        text-transform: uppercase;
        margin-left: 8px;
        margin-bottom: -10px;
   }
      .widgets-panel__calendar h2 {

        font-size: 45px;
        font-weight: 300;
      }
      .widgets-panel__calendar li {
position: relative;
 padding: 4px 10px;
        font-size: 15px;
        border-radius: 4px;
        margin-left: 8px;
        margin: 8px 0;
      }
      .widgets-panel__calendar li::before {
        content: "";
        width: 8px;
        height: calc(100% - 2px);
        position: absolute;
        border-radius: 99px;
        top: 2px;
        left: -12px;
      }
      .widgets-panel__calendar li.blue {
      color: #34aadc;
        background: #283646;
     }
      .widgets-panel__calendar li.blue::before {
background: #34aadc;
      }
      .widgets-panel__calendar li.green {
        color: #32d74b;
    background: #2d402e;
      }
      .widgets-panel__calendar li.green::before {
        background: #32d74b;
      }
      .widgets-panel__calendar li.purple {
        color: #9c5ffd;
        background: #422948;
      }
      .widgets-panel__calendar li.purple::before {
        background: #7a3edb;
      }
      .widgets-panel__calendar li span {
        display: block;
      }
      .widgets-panel__calendar li span:first-child {
        font-weight: bold;
      }

   /* Container app */

      .container__Window {
        /*
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: space-around;
        align-items: center;
        position: absolute;
        background-image: linear-gradient(180deg, rgba(var(--bs-body-bg-1-rgb), 0.01), rgba(var(--bs-body-bg-1-rgb), 1) 85%), radial-gradient(ellipse at top left, rgba(var(--bs-body-bg-2-rgb), 0.5), transparent 50%), radial-gradient(ellipse at top right, rgba(var(--bs-body-bg-3-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center right, rgba(var(--bs-body-bg-4-rgb), 0.5), transparent 50%), radial-gradient(ellipse at center left, rgba(var(--bs-body-bg-5-rgb), 0.5), transparent 50%);
       */
       /* background: var(--background-color-container__Window);
        background-image: radial-gradient(circle, rgba(200, 200, 200, 0.2) 1px, transparent 1px);
        background-size: 20px 20px; */

      }

      .window {
       display: none;
      max-width: 100%;
   min-width: 100%;
      min-height: 93%;
      height: 93%;
   margin-top: 3%;
      overflow: hidden;
      border-radius: 0;
  background: transparent;
      box-shadow: 0 20px 30px var(--color-black-500);
      border: 1px solid #ffffff34;
      animation: zoom-out 0.3s;
   touch-action: none;
    z-index: 100;
    transition: transform 0.7s ease, opacity 0.7s ease, width 0.7s ease, height 0.7s ease;
 }

   .window__taskbar {
    height: 12%;
    display: flex;
    justify-content: space-between;
    padding: 0 16px;
    background-color: var(--app-color-white);
  }

  .window__taskbar--actions {
  display: flex;
  align-items: center;
  }

  .window__taskbar:hover button::after {
    color: #000;
  }

  .window__taskbar--actions button {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 0.8rem;
    height: 0.8rem;
    padding: 8px;
    border-radius: 50%;
    transition: 0.4s;
  }

  .window__taskbar--actions button:not(:last-child) {
    margin-right: 8px;
  }

  .window__taskbar--actions button:nth-child(1) {
    background-color: #ff5f56;
    box-shadow: 0 0 0 0.5px #e0443e;
  }

 .window__taskbar--actions button::after {
    display: block;
    font-size: 14px;
    color: transparent;
    font-weight: 900;
  }

  .window__taskbar--actions button:nth-child(1)::after {
    content: "×";
  }

.window__taskbar--actions button:nth-child(1):hover {
    background-color: #fc3c32;
  }

  .window__taskbar--actions button:nth-child(2) {
    background-color: #ffbd2e;
  box-shadow: 0 0 0 0.5px #dea123;
  }

  .window__taskbar--actions button:nth-child(2)::after {


    content: "−";
  }

  .window__taskbar--actions button:nth-child(2):hover {
    background-color: #ffa600;
  }

  .window__taskbar--actions button:nth-child(3) {
    background-color: #27c93f;
    box-shadow: 0 0 0 0.5px #1aab29;
  }

  .window__taskbar--actions button:nth-child(3)::after {
    content: "🗗";
  }

  .window__taskbar--actions button:nth-child(3):hover {
    background-color: #12aa29;
  }

  .window__taskbar--content {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .window__taskbar--content h2 {
    color: var(--color-black);
    font-weight: 600;
    font-size: 18px;
  }

  .window__taskbar {
    height: 3%;
  }

.window_content {
  width: 100%;
  height: 100%;
  overflow-y: scroll;
/* padding-left: 1rem; */
  background-color: var(--app-color-white);
  /* backdrop-filter: blur(120px); */
  color: rgb(235, 235, 235);
 font-size: 20px;
  font-family: "Roboto Mono", monospace;
}






   .navbar-home {
    border-bottom: 1px solid var(--bs-border-color);
    width: 100%;
    padding: 0.1rem 0;
    position: fixed;
    top: 0;
    left: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    z-index: 10000;
    animation: top-to-bottom 0.3s;
 background: linear-gradient(90deg, rgba(var(--bs-navbar-bg-1-rgb),0.95) 0%, rgba(var(--bs-navbar-bg-2-rgb),1) 50%, rgba(var(--bs-navbar-bg-3-rgb),0.95) 100%);
    /*background-image: linear-gradient(rgba(var(--bd-header-rgb), 1), rgba(var(--bd-header-rgb), 0.95));
    background:  var(--background-color-navbar);
    background-image: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
    background-size: 15px 15px; */
    }

 .navbar-home i{
  color: var(--color-white);
 }

 /* Ensure dropdown menus are hidden by default */
 .dropdown-menu {
   display: none;
   position: absolute;
 }

 /* Show the dropdown menu when it has the ''show'' class */
 .dropdown-menu.show {
   display: block;
   right: 0;
 }
     .hover-span {
            position: relative;
            cursor: pointer;
        }
  .hover-span i {
    transition: all 0.2s ease !important;
  }
   .hover-span:hover i {
   font-size: 55px;
   height: 70px;
   width: 70px;
   }


    .hover-span::after {
            content: "";
            left: 50%;
            opacity: 0;
            pointer-events: none;
           transition: all 0.2s ease !important;
        }



        .hover-span:hover::after {
           opacity: 1;
        }

  .hover-span span {
            transition: opacity 0.3s ease;
        }

   .hover-span:hover span {
            opacity: 0;
        }




  .notifications i{
   padding-top: 20px;
   font-size: 26px;

    }

    .master-tabs{
       /*
       position: absolute;
       top: 6%;
       right: 0%;
       width: 87.4%;
        */
       height: calc(100vh - var(--navbar-height, 37px)) !important;
       min-height: 0 !important;
       max-height: calc(100vh - var(--navbar-height, 37px)) !important;
       background-color: var(--background-color);
       padding-bottom: 0 !important;
       box-sizing: border-box !important;
       overflow: hidden !important;
       /* color: var(--text-color); */
       /*
       z-index: 10000;
       display: none;
       transition: width 0.3s ease;
       */
    }
    .master-tabs .nav-tabs{
       /*padding-top: 0.3vh;*/
    }
     .tab-pane {
        max-height: 90vh;
    }

         /* Customize the scrollbar (Webkit browsers like Chrome, Safari) */

   .tab-pane::-webkit-scrollbar {
    width: 7px;
   }

    .tab-pane::-webkit-scrollbar-thumb {
    background-color: #888;
    border-radius: 10px;
  }

  .tab-pane::-webkit-scrollbar-thumb:hover {
  background: #555;
   }

    .tab-pane::-webkit-scrollbar-track {
    background: #f1f1f1;
   }

    /* Customize the scrollbar (Webkit browsers like Chrome, Safari) */
    #scrollsidebar::-webkit-scrollbar {
    width: 7px;
   }

    #scrollsidebar::-webkit-scrollbar-thumb {
    background-color: #888;
    border-radius: 10px;
   }

    #scrollsidebar::-webkit-scrollbar-thumb:hover {
    background: #555;
   }

    #scrollsidebar::-webkit-scrollbar-track {
    background: #f1f1f1;
   }

    #scrollsidebar::-webkit-scrollbar {
    display: none;
   }


    .home-sidebar{
   position: absolute;
   top: var(--navbar-height, auto);
   bottom: 0px;
   left: 0%;
   /*
   height: 110%;
   */
   height: calc(100vh - var(--navbar-height, 0px));

   z-index: 1000;

   /* overflow-y: scroll;
   direction: rtl; */
   display: none;
    }

    #MainSideBar .sidebar {
      height: 100%;
      min-height: 100%;
    }

    .tab-content{
       /*
       background-color: var(--background-color);
       min-height: 95vh;
       */
       color: var(--text-color);
    }

    /* Text below the icon */
  .icon-text {
   display: block;
   margin-top: 5px;
   font-size: 12px;
   color: white;
  }


   .dock .icon::before {

    position: absolute;
    bottom: -18%;
    left: 50%;

    display: flex;
    justify-content: center;
    align-items: center;

    width: 50px;
    height: 0px;
    font-family: "lexend", sans-serif;
    color: #ffffff;
    /* display: var(--before-display, block); */

    display: none;
  }


  .master-tabs .nav-tabs .nav-item.dropdown{
   /* position: absolute;
      right: 0; */
  }
   #tabContent .overlay {
          position: absolute;
          top: 0;
          left: 0;
          width: 100vw;
          height: 100vh;
          background: rgba(0, 0, 0, 0.5);
          display: none;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          z-index: 50;
          display: none;
        }


      #tabContent .overlay.hidden {
          display: none;
        }
    #tabContent .container-spin {
          --uib-size: 40px;
          --uib-color: white;
          --uib-speed: 2s;
          --uib-bg-opacity: 0;
   height: var(--uib-size);
          width: var(--uib-size);
          transform-origin: center;
          animation: rotate var(--uib-speed) linear infinite;
          will-change: transform;
          overflow: visible;
        }

       #tabContent .car-spin {
          fill: none;
          stroke: var(--uib-color);
          stroke-dasharray: 1, 200;
          stroke-dashoffset: 0;
          stroke-linecap: round;
          animation: stretch calc(var(--uib-speed) * 0.75) ease-in-out infinite;
          will-change: stroke-dasharray, stroke-dashoffset;
          transition: stroke 0.5s ease;
        }

      #master-tabs .track-spin {
          fill: none;
          stroke: var(--uib-color);
          opacity: var(--uib-bg-opacity);
          transition: stroke 0.5s ease;
        }

        @keyframes rotate {
          100% {
            transform: rotate(360deg);
          }
        }

        @keyframes stretch {
          0% {
            stroke-dasharray: 0, 150;
            stroke-dashoffset: 0;
          }

          50% {
            stroke-dasharray: 75, 150;
            stroke-dashoffset: -25;
          }

          100% {
            stroke-dashoffset: -100;
          }
        }

  .highLightApp{
   background: var(--color-white-100);
   border-radius: 6px;
  }

  .nav-item{
    padding-right: 0.1%;
  }

  .nav-tabs .nav-link{
      padding-bottom: 6px;
   padding-right: 10px !important;;
   border-top-left-radius: 13px;
border-top-right-radius: 13px;
  }

  .nav-tabs .nav-link div{
      margin-top: 0.05vh;
   display: flex;
   align-items: center;
   justify-content: center;
  }

  .nav-tabs .nav-link .ms-1{
        margin-left: 0.7rem !important;
  }


button.nav-link:not(.active) {
    background-color: var(--bg-navtab-inactive) !important;
  }

  button.nav-link.active {
    position: relative;
    background-color: var(--bg-navtab-active) !important;
    background: linear-gradient(to bottom, #00a9f2 4px, transparent 4px);
    color: #00a9f2 !important;
  }

  button.nav-link.active::before {
   position: absolute;
   content: '''';
   left: -20%;
   top: 50%;
   height: 50px;
   width: 50px;
   background-color: var(--bg-navtab-active);
   border-radius: 50%;
   display: none;
  }

  .nav-item:has(button.active){
   position: relative;
  }

  .nav-item:has(button.active)::before {
      content: "";
   position: absolute;
   top: 50%;
   left: -30px;
   width: 30px;
   height: 30px;
   background-color: var(--bg-navtab-inactive);

   border-radius: 50%;
   z-index: 1;
   transform: translateY(-50%);
   display: none;
  }



    .tab-content{
  border-left: 1px solid var(--bs-border-color);
  }



  .wrapper-launchpad{
   display: flex;
   padding: 0 35px;
   align-items: center;
   justify-content: center;
  }

  .Apps-page-container{
   position: absolute;
   width: 85.5vw;
   height: 71.5vh;
   display: grid;
   grid-row-gap: 10px;
   grid-template-columns: 15% 15% 15% 15% 15% 15% 15%;
   grid-template-rows: 25% 25% 25% 25%;
  }

  .wrapper-launchpad .Apps-container{
   display: inline-block;

   position: relative;
   height: 75vh;

  }

  .wrapper-launchpad-child{
   max-width: 100vw;
   position: relative;
  }

  .wrapper-launchpad-child i.change-icon{
   top: 50%;
   height: 46px;
   width: 46px;
   cursor: pointer;
   position: absolute;
   font-size: 1.2rem;
   text-align: center;
   line-height: 46px;
   background: #fff;
   color: black;
   border-radius: 50%;
   transform: translateY(-50%);
  }

  .wrapper-launchpad-child i.change-icon:first-child{
   left: -53px;
   display: none;
  }

  .wrapper-launchpad-child i.change-icon:last-child{
   right: -53px;
  }

  .wrapper-launchpad-child .carousel{
   width: 90vw;
   cursor: pointer;
   overflow: hidden;
   white-space: nowrap;
   scroll-behavior: smooth;
  }

  .carousel.dragging{
   cursor: grab;
   scroll-behavior: auto;
  }

  .carousel.dragging .Apps-container{
   pointer-events: none;
  }

  .carousel .Apps-container{

   object-fit: cover;
   margin-left: 14px;
   width: 100%;
  }

  .carousel .Apps-container:first-child{
   margin-left: 0px;
  }


  #master-tabs .nav-tabs span i{
      display: inline-block;
   height: 2vh;
   width: 2vh;
   border-radius: 50%;
  }

  #master-tabs .nav-tabs span i::before{
       display: flex;
   align-items: center;
   justify-content: center;
   height: 2vh;
   width: 2vh;

   border-radius: 50%;
  }



  #master-tabs .nav-tabs span i:hover{
      background: #dcdcdc;
  }

  .nav-link,
  .nav-link:hover
  {
   color: unset;
  }

  .navbar__left .logo{
       cursor: pointer;
  }


  .tab-loader{
   top: 40vh;
   left: 41vw;
   position: absolute;
   z-index: 1000;
  }

  #dashboard_main{
 background-color: var(--background-color);
  }
/*Hiếu: cho tất cả thẻ h cùng 1 màu cho đồng bộ*/
  h1, h2, h3, h4, h5, h6 {
        color: #00673b;
    }
</style>

<style>
#MainSideBar .pool-ball {
			width: 24px;
			height: 24px;
			background-color: #E03137;
			border-radius: 50%;
			display: flex;
			align-items: center;
			justify-content: center;
			position: relative;
			/* transition: all 0.3s; */
		}


		#MainSideBar .number {
			color: #ffffff;
			font-size: 17px;
			font-weight: bold;
			font-family: ''Arial'', sans-serif;

		}
		#MainSideBar .tree-button i{
			font-size: 20px !important;
		}

		#MainSideBar .menu-button {
			background: none;
			border: none;
			font-size: 20px;
			cursor: pointer;
			color: #757575;
			width: 40px;
			height: 40px;
			border-radius: 50%;
			/*background-color: #fff;*/
			/*transition: all 0.3s ease;*/
			z-index: 1000;
		}


		#MainSideBar .menu-button:hover{
			/*background-color: #dbdbdb;
			color: #000;*/
		}

		#MainSideBar .menu-button{
			/*transition: all 0.3s; */
		}
		#MainSideBar .menu-button .collapsed{
			/* margin-left: -33%; */
		}

	
		#MainSideBar .sidebar{
			position: relative;
			/*width: 18%;*/
			height: 106%;
			display: flex;
			flex-direction: column;
			gap: 20px;
			background-color: var(--background-color);
			color: var(--text-color);
			/*padding: 24px;*/
			/* border-radius: 30px; */
			/*transition: all 0.3s; */
			/*overflow: auto;*/
			transition: width 0.3s ease;
			
			/*width: 269px;*/ /* Chiều rộng ban đầu của sidebar */
		}
		#MainSideBar .sidebar.collapsed {
			width: 54px; /* Chiều rộng khi thu nhỏ */
		}
		#MainSideBar .menu ul li a .text {
		}
			#MainSideBar .sidebar.collapsed .menu ul li a .text {
		opacity: 0; /* Ẩn chữ khi thu nhỏ */
		display: none; /* Đảm bảo text ẩn hoàn toàn khi thu nhỏ */
	}
		#MainSideBar .menu .title{
			font-size: 10px;
			font-weight: 600;
			color: #21252B;
			text-transform: uppercase;
			margin-bottom: 10px;
		}

		#MainSideBar .nav{
			flex: 1;
			max-height: 100vh;
		
			padding: 0px 24px;
		}
		

		#MainSideBar .menu ul li{
			position: relative;
			list-style: none;
			margin-bottom: 5px;
		}

		#MainSideBar .menu ul li a{
			display: flex;
			align-items: center;
			gap: 10px;
			font-size: 14px;
			font-weight: 500;
			color: var(--text-color);
			text-decoration: none;
			padding: 12px 8px;
			border-radius: 8px;
			/* transition: all 0.3s; */
		}

		#MainSideBar .menu ul li > a {
			position: relative;
		}

		 #MainSideBar.menu ul li > a:hover::before,
		 .menu ul li.active > a::before {
		
			position: absolute;
			left: 0px;
			top: 50%;
			transform: translateY(-50%);
			width: 2px;
			height: 21px;
			/*background-color: var(--primary);*/
			border-radius: 2px;
			/*color: var(--selected-bg-color);*/
		}
		#MainSideBar .menu ul{
			padding-left: 0;
		}
		#MainSideBar .menu ul li > a:hover,
		#MainSideBar .menu ul li.active > a {
			
			background-color: var(--background-color-hover);
		}

		#MainSideBar .menu ul li .icon{
			font-size: 20px;
		}

		#MainSideBar .menu ul li .text{
			flex: 1;
		}

		#MainSideBar .menu ul li .arrow{
			font-size: 14px;
		/*	transition: all 0.3s; */
		}

		#MainSideBar .menu ul li.active .arrow{
			transform: rotate(180deg);
		}

		#MainSideBar .menu .sub-menu{
			display: none;
			margin-left: 20px;
			/*padding-left: 20px;*/
			padding-top: 5px;
			
		}

		#MainSideBar .menu .sub-menu li a{
			padding: 10px 8px;
			font-size: 14px;
		}

		#MainSideBar .menu:not(:last-child){
			padding-bottom: 10px;
			margin-bottom: 20px;
			border-bottom: 2px solid #f6f6f6;
		}

		#MainSideBar .sidebar.active{
			width: 92px;
		}

		#MainSideBar .sidebar.active .menu .title{
			text-align: center;
		}

		#MainSideBar .sidebar.active .menu ul li .arrow{
			display: none;
		}

		#MainSideBar .sidebar.active .menu > ul > li > a{
			position: relative;
			display: flex;
			align-items: center;
			justify-content: center;
		}

		
			#MainSideBar .menu ul li.active a {
			/*color: var(--selected-bg-color);*/
		}
		

	

		#MainSideBar .sidebar.active .menu .sub-menu{
			position: absolute;
			top: 0;
			left: 20px;
			width: 200px;
			border-radius: 20px;
			padding: 10px 20px;
			border: 1px solid #f6f6f6;
			background-color: #fff;
			box-shadow: 0px 10px 8px rgba(0,0,0,0.1);
		}


		#MainSideBar .sidebar.active .menu ul li .pool-ball{
			position: absolute;
			top: 0;
			right: 0;
			background-color: red;
			color: white;
			border-radius: 50%;
			width: 24px;
			height: 24px;
			display: flex;
			align-items: center;
			justify-content: center;
			font-size: 12px;
			font-weight: bold;
		}
		#MainSideBar .content {
			width: 100%;
			height: 100%;
			
			padding: 24px;
			 overflow-y: auto;
		}
		#MainSideBar .sidebar .text {
			display: inline-block;
			max-width: 190px;
			white-space: normal;
			word-break: break-word;
			line-height: 1.2;
}
</style>

<style>
/* Mobile devices (portrait and landscape) */
    @media (max-width: 600px) {
      .dock .icon svg,
        .dock .icon img {
          width: 2rem;

        }

        .widgets-panel {
          left: 0%;
          right: 0%;
        }
        .widgets-panel__calendar{
          min-width: 380px;
          min-height: 300px;
        }
    }

  /* Tablets and small desktops */
@media (min-width: 601px) and (max-width: 1300px) {

		.dock .icon i.bi{
		  font-size: 20px;
		}

		.dock .icon i.bi::before{
		  transform: translateX(-13%);
		}

        .dock .icon svg,
		.dock .icon i,
        .dock .icon img {
          width: 2.2rem;

        }

		.dock .column{
		 height: 6.5vh;
		}

		.navbar__right i{
			 font-size: 20px !important;
		}

		.navbar__right i.bi.bi-chevron-down{
			font-size: 9px !important;
		}

		.user-info .notifications .pool-ball {
			top: -22px;
            right: -14px;
			width: 4px;
			height: 4px;
		}

		

        .widgets-panel {
          left: 30%;
          right: 30%;
        }
        .widgets-panel__calendar{
          min-width: 450px;
          min-height: 300px;
        }

		

		.launchpad .child-launchpad i{
			font-size: 40px;

		}

		.launchpad .child-launchpad svg, .launchpad .child-launchpad i{
			height: 55px;
            width: 55px;
		}

		 .hover-span:hover i {
			font-size: 45px;
			height: 60px;
			width: 60px;
		 }
	
		.spotlight_serach
		{
		  top: 18%;
		}

		.logo{height: 30px;}
      }

      /* Large desktops */
      @media (min-width: 1300px) {
        .dock .icon svg,
        .dock .icon img {
          width: 4.6rem;

        }

		.user-info .profile i:nth-child(1){
			font-size: 25px;
		}

		.user-info .notifications .pool-ball {
			top: -30px;
            right: -18px;
			width: 5px;
			height: 5px;
		}

		.user-info .notifications .pool-ball::after {
		   background-color: red;
		   content: '''';
		   position: absolute;
		   width: 5px;
		   height: 5px;
		   border-radius: 50%;
		   border: 1px solid #FFF;
		   top: 2.5vh;
		   right: 0.3vh;
		}

        .widgets-panel {
          left: 30%;
          right: 30%;
        }
        .widgets-panel__calendar{
          min-width: 450px;
          min-height: 350px;
        }
      }
</style>

<style>
@import url(https://fonts.googleapis.com/css?family=Inter:100,200,300,regular,500,600,700,800,900);

		/* Reset CSS */

		*{
			margin: 0;
			padding: 0;
			box-sizing: border-box;
			font-family: "Inter", sans-serif;
		}

		:root{
			--primary: #0B9F57;
			--primary-hover: #E7F7EF;
		}

		body{
			background-color: #5b6677;
		}

		.container{
			width: 100%;
			height: 100vh;
		}

		


		.number {
			color: #ffffff;  /* White color for the number */
			font-size: 17px;  /* Size of the number */
			font-weight: bold;  /* Make the number bold */
			font-family: ''Arial'', sans-serif;  /* Font family */

		}

		/* Header area */
		header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			background-color: #fff;
			padding: 10px 20px;
			box-shadow: 0 2px 4px rgba(0,0,0,0.1);
		}

		.header-left{
			display: flex;
			padding-left: 5px ;
			align-items: center;
		}

		.logo {
			height: 40px;
			margin-left: 30px;
		}

		

		.search-container {
			position: relative;
			flex-grow: 1;
			margin-left: 40px;
		}

		.search-icon {
			position: absolute;
			top: 50%;
			left: 10px;
			transform: translateY(-50%);
		}

		.search-input-windown {
			width: 320px;
			height: 48px;
			padding: 10px 20px 10px 40px;
			border: none;
			border-radius: 8px;
			background-color: #FAFAFA;
			font-size: 14px;
			color: #21252B;
			outline: none;
			box-shadow: 0 1px 1px var(--box-shadow);
		}

		.search-input-windown::placeholder {
			color: #B8BDC5;
		}


		.user-info {
			display: flex;
			align-items: center;
			/* align-items: center; */
		}

	

		.user-info .notifications {
			margin-right: 15px;
			position: relative;
			cursor: pointer;
		
		}

		.user-info .profile {
			position: relative;
			display: flex;
			align-items: center;
			cursor: pointer;
		}

		.user-info .profile .profile-menu {
			margin: unset;
			padding: unset;
			position: absolute;
			width: 154px;
			top: 4.2vh;
			right: 0vh;
			border-radius: 8px;
			background-color: var(--background-color);
			color: var(--text-color);
			border: 1px solid #e0e0e0;
			display: none;
		}

		.user-info .profile .profile-menu .profile-menu-item{
			text-align: center;
			display: flex;
			align-items: center;
			justify-content: center;
			height: 36px;
		}


		.user-info .profile img {
			border-radius: 50%;
			width: 42px;
			height: 42px;
			margin-right: 5px;
		}
		.notifications .bi-bell::after {
			content: "";
			height: 0.25rem;
			width: 0.25rem;
			background: red;
			position: absolute;
			border-radius: 50%;
			right: 0.2rem;
			top: 0.5vh;
		}

		/* Sidebar area */
</style>

<style>
/* Toggle Wrapper */
		.toggle-wrapper {
		  margin-right: 20px;
		}
    #themeIcon {
      font-size: 24px;
    }
</style>


<div>
<!-- Main Sidebar -->

		
		<div id="MainSideBar" class="home-sidebar">
		
				<div class="sidebar">
					<div class="nav">
					
					  <div class="menu" style="margin: 0px -22px; width: 14vw;">
					
						<div class="d-flex">
							<button class="menu-button main-menu-button">&#9776;</button>
							<!--<button style="margin-left: 70%;" class="menu-button tree-menu-button"><span class="bi bi-bezier fs-4"></span></button>-->
							<button style="margin-left: 70%;" class="menu-button tree-menu-button">
								<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
								  <g fill="none" stroke="#2C3E50" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
									<path d="M14 8h14"/>
									<path d="M14 16h14"/>
									<path d="M14 24h14"/>
									<path d="M6 8V24 M6 16h4 M6 24h4"/>
								  </g>
								  <circle cx="6" cy="8" r="3.5" fill="#2C3E50"/>
								</svg>
							</button>
						</div>
						<ul class="main-menu-ul">
						
						  <li>
							<a style="display: none" href="#">
							  </i>
							</a>
							 <a href="#">
						  <i class="icon ">

						  </i>
						  <span class="text"></span>
						  <i class="arrow">

						  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path fill-rule="evenodd" clip-rule="evenodd" d="M5.29289 8.29289C5.68342 7.90237 6.31658 7.90237 6.70711 8.29289L12 13.5858L17.2929 8.29289C17.6834 7.90237 18.3166 7.90237 18.7071 8.29289C19.0976 8.68342 19.0976 9.31658 18.7071 9.70711L12.7071 15.7071C12.3166 16.0976 11.6834 16.0976 11.2929 15.7071L5.29289 9.70711C4.90237 9.31658 4.90237 8.68342 5.29289 8.29289Z" fill="#CBD5E0"/>
							</svg>

						  </i>
						</a>
							<ul  class="sub-menu">
							  <li style="display: none">
								<a href="#">
								  <span class="text"></span>
								</a>
							  </li>
							</ul>
						  </li>
						</ul>

						
 <style>
  .tree-dropdown .dx-list-item-content {
   padding: 10px
  }

  .tree-dropdown.dx-overlay-shader {
      background-color: transparent !important;
  }

  #employee-tree .dx-treelist-rowsview .dx-selection.dx-row td {
   background-color: transparent;
  }

  #employee-tree .dx-treelist-rowsview .dx-selection.dx-row.dx-row-focused td {
   background-color: #d6e4f1;
  }

  #employee-tree .arrow-button .dx-button-content {
   padding: 0 !important;
  }
 </style>
 <div class="" id="employee-tree-container">
  <div class="d-flex pb-2">
   <div class="col" id="employee-tree-search"></div>
   <div class="" id="employee-tree-filter-button"></div>
  </div>
  <ul class="nav nav-tabs px-0">
   <li class="nav-item mb-0 w-50">
    <p class="nav-link px-2 text-center active">DS Nhân Viên</p>
   </li>
   <li class="nav-item mb-0 w-50">
    <p class="nav-link px-2 text-center" data-terminated="true">NV Nghỉ Việc</p>
   </li>
  </ul>
  <div id="employee-tree"></div>
 </div>


					  </div>
					
					</div>
					
				  </div>
			</div>
	</div>
		
		

<!-- Container Tabs -->


			 <div id="master-tabs" class="master-tabs">
			
			  <!-- Tab Navigation -->
			  <ul class="nav nav-tabs  " id="tabList" role="tablist">
				<!-- Dynamic Tabs Will Be Added Here -->
				  <!-- ''More'' Dropdown Tab -->
					<li class="nav-item dropdown" style="position: absolute; right: 0;">
					  <a
						class="nav-link dropdown-toggle"
						href="#"
						role="button"
						aria-haspopup="true"
						aria-expanded="false"
						id="dropdownToggle"
					  >
						
					  </a>
					  <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownToggle">
					
						<!-- Add more items as needed -->
					  </ul>
					</li>

			  </ul>

			  <!-- Tab Content -->
			  <div class="tab-content" id="tabContent" style=" position: relative;">
				<!-- Dynamic Tab Panes Will Be Added Here -->



				<div class="overlay" id="loading-overlay">
            <svg class="container-spin" viewBox="0 0 40 40" height="40" width="40" style="margin-right: 255px">
              <circle class="track-spin" cx="20" cy="20" r="17.5" pathlength="100" stroke-width="5px" fill="none" />
              <circle class="car-spin" cx="20" cy="20" r="17.5" pathlength="100" stroke-width="5px" fill="none" />
            </svg>
            <p style="margin-right: 255px" class="mt-2 text-white text-sm font-semibold z-[51]">Đang tải dữ liệu, vui lòng đợi...</p>
          </div>
			  </div>
	
		  </div>
		  		
		

<!-- Context Menu -->

			
			  <div id="contextMenuTab" class="context-menu" style="opacity: 0; transition: 0.2s;">
				<ul>
					<li>
					   <button onclick="CloseAllTab()">Close all tabs</button>
					</li>
					<li>
					   <button onclick="CloseOtherTab()">Close other tabs</button>
					</li>
					<li>
					   <button onclick="CloseAllTabOnLeft()">Close all tabs on left</button>
					</li>
					<li>
					   <button onclick="CloseAllTabOnRight()">Close all tabs on right</button>
					</li>
					<li>
					  <button  onclick="CloseThisTab()" >Close this tab</button>
					</li>
				  </ul>
				</div>
	
				<div id="contextMenu" class="context-menu" style="opacity: 0; transition: 0.2s;">
				<ul>
					<li>
					   <button id="contextMenuTab" onclick="handlePinToTaskbarClick()">Pin to taskbar</button>
					</li>
					<li>
					  <button id="actionOpen" onclick="openAppContext()" >Open</button>
					</li>
				  </ul>
				</div>


				<div id="contextMenuDock" class="context-menu" style="opacity: 0; transition: 0.2s;">
				  <ul>
					<li >
					  <button id="actionPinToTaskbar" onclick="handleUnpinToTaskbarClick(true)">Unpin to taskbar</button>
					</li>
					<li>
					  <button id="actionOpen" onclick="openAppContext()" >Open</button>
			 </li>
				  </ul>
				</div>
		

		

<!-- Dock & Navbar -->
<!--Dock start-->
   <div class="snowflakes" id="snowflakesContainer"></div>
    <div class="particles" id="particlesContainer"></div>
   <div ID = "ID-navbar-home" class="navbar-home">
      <div ID = "ID-navbar__left" class="align-items-center d-flex navbar__left">
         <svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1007.89 258.31" class="logo">
  <defs>
    <style>
    /* ============ HIỆU ỨNG TUYẾT RƠI - PHIÊN BẢN NOEL ============ */
.snowflakes {
    position:absolute;
    inset:0;
    overflow:hidden;
    pointer-events:none;
    z-index:10;
}
.snowflake {
    position:absolute;
    top:-20px;
    color:#fff;
    font-size:1.2em;
    user-select:none;
    pointer-events:none;
    opacity:0.9;
    text-shadow: 0 0 8px rgba(255,255,255,0.6);
    animation: fall linear infinite;
}
.snowflake:nth-child(odd) { font-size:1em; }
.snowflake:nth-child(even) { font-size:1.5em; }
@keyframes fall {
    0% {
        transform: translateY(-100vh) translateX(0) rotate(0deg);
        opacity: 0.9;
    }
    100% {
        transform: translateY(100vh) translateX(80px) rotate(360deg);
        opacity: 0.3;
    }
}
 .notification-container {
      display: none;
            width: 529px;

            background-color: var(--background-color);
   color: var(--text-color);
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.notification-1);
            padding: 0;
            position: absolute;
            top: 100%;
            right: 0.5%;
   z-index: 10000;
        }
        .notification-header {
            height: 34px;
            font-size: 14px;
            font-weight: medium;
            color: #0a8e2d;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .notification-header span{
            padding-left: 20px;
        }

        .notification-announcement {
            height: 65px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #f1f1f1;
            padding-right: 10px;
            padding-left: 10px;
        }

        .notification-announcement img {
            border-radius: 50%;
            width: 36px;
            height: 36px;
        }
        .notification-announcement-text {
            flex-grow: 1;
            margin-left: 10px;
            font-size: 14px;
            color: var(--text-color);
        }
        .notification-announcement-text small {
            display: block;
            color: #888;
            margin-top: 5px;
            font-size: 12px;
        }
        .notification-buttons {
            display: flex;
            gap: 10px;
        }
        .notification-button {
            padding: 6px;
            width: 28px;
            height: 28px;
            background-color: #e0e0e0;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .notification-approve {
            background-color: #0B9F57;
            color: white;
        }
        .notification-reject {
            background-color: #f1f1f1;
            color: #888;
        }
.notification-large-button {
            padding: 6px 16px;
            background-color: #e0e0e0;
            border: none;

           border-radius: 5px;
            cursor: pointer;
    font-size: 12px;
        }

  .notification-view-all {
            text-align: center;
            padding: 13px 0;
        }
        .notification-view-all a {
            font-size: 14px;
            color: #0073e6;
            text-decoration: none;
        }
        .notification-view-all a:hover {
            text-decoration: underline;
        }



.notification-menu {
  position: relative;
}

.notification-menu-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 5px;
}

.notification-menu-button:hover {
  opacity: 0.7;
}

.notification-menu-dropdown {
  position: absolute;
  top: 25px;
  right: 0;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 5px;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  display: none;
  width: 200px;
  z-index: 1000;
}

.notification-menu-dropdown button {
  width: 100%;
  text-align: left;
  background: none;
  border: none;
  padding: 10px;
  font-size: 14px;
  cursor: pointer;
}

.notification-menu-dropdown button:hover {
  background: #f5f5f5;
}

.notification-item {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #ddd;
}

.notification-item img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-right: 10px;
  background: #ccc;
}

.notification-text {
  flex-grow: 1;
  font-size: 14px;
}

.notification-text small {
  display: block;
  color: gray;
  font-size: 12px;
}

.notification-actions {
  display: flex;
  gap: 5px;
}

.notification-button {
  width: 30px;
  height: 30px;
  border: none;
  background: none;
  cursor: pointer;
}

.notification-approve {
  background-color: #28a745;
  border-radius: 50%;
}

.notification-reject {
  background-color: #dc3545;
  border-radius: 50%;
}

.notification-view-all {
  text-align: center;
  padding: 10px 0;
}

.notification-view-all a {
  text-decoration: none;
  color: #007bff;
  font-weight: bold;
}

.notification-view-all a:hover {
  text-decoration: underline;
}


.notification-menu.active .notification-menu-dropdown {
  display: block;
}

      .cls-1 {
        fill: #73c41d;
      }

      .cls-2, .cls-3 {
        fill: #fff;
      }

      .cls-4 {
        fill: #004c39;
      }

      .cls-5 {
        fill: none;
        opacity: .5;
        stroke: #004c39;
      }

      .cls-5, .cls-3 {
        isolation: isolate;
        stroke-miterlimit: 10;
      }

      .cls-3 {
        stroke: #73c41d;
      }
    :root {
            --primary-green: #0ca678;
            --secondary-green: #10b981;
            --accent-green: #2ecc71;
            --light-green: #6ae3a3;

            --card-bg: #ffffff;
            --text-primary: #1f2937;
            --text-secondary: #4b5563;
            --hover-color: #e6f3ee;
        }

        #logoutContainer .profile-container {
            position: relative;
            perspective: 1000px;
        }

        #logoutContainer .avatar-trigger {
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            position: relative;
            z-index: 20;
        }

        #logoutContainer .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid transparent;
            transition: all 0.4s ease;
        }

        #logoutContainer .avatar-trigger:hover .avatar {
            transform: scale(1.07);
        }

        /* Menu Profile dùng 100% tokens của hệ thống từ sp_MainStyleCSSParadise */
        #logoutContainer .user-details {
            position: absolute;
            top: 55px;
            left: 53%;
            transform: translateX(-50%) rotateX(-15deg) scale(0.9);
            width: 100%;
            background-color: var(--paradise-card-bg, var(--paradise-bg-1, #ffffff)) !important;
            border-radius: 16px;
            box-shadow: var(--paradise-modal-shadow, 0 16px 48px rgba(0, 0, 0, 0.5)) !important;
            opacity: 0;
            visibility: hidden;
            transition: all 0.4s cubic-bezier(0.25, 0.1, 0.25, 1);
            padding: 25px;
            z-index: 10;
            border: 1px solid var(--paradise-border-color, rgba(0, 0, 0, 0.1)) !important;
        }

        #logoutContainer .user-details.active {
            width: 510px;
            opacity: 1;
            visibility: visible;
            transform: translateX(-93%) rotateX(0) scale(1);
        }

        #logoutContainer .user-info {
            display: flex;
            align-items: center;
            margin-bottom: 25px;
            text-align: center;
            flex-direction: column;
        }

        #logoutContainer .user-text h3 {
            margin: 0;
            font-size: 19px;
            color: var(--paradise-fg-0, var(--paradise-text-body, #1f2937)) !important;
            font-weight: 600;
        }

        #logoutContainer .user-text p {
            margin: 5px 0 0;
            color: var(--paradise-fg-2, var(--paradise-text-muted, #848e9c)) !important;
            font-size: 14px;
        }

        #logoutContainer .actions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 25px;
        }

        #logoutContainer .action-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 15px;
            border-radius: 12px;
            cursor: pointer;
            text-decoration: none;
            color: var(--paradise-fg-0, #1f2937) !important;
            background-color: var(--paradise-bg-2, #f0f9f5) !important;
            border: 1px solid var(--paradise-border-color, transparent) !important;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        #logoutContainer .action-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: var(--paradise-color-primary, #22ab3f);
            opacity: 0;
            transition: opacity 0.3s ease;
            z-index: -1;
        }

        #logoutContainer .action-item:hover {
            transform: translateY(-5px);
            box-shadow: var(--paradise-shadow-md, 0 8px 15px rgba(0, 0, 0, 0.15));
            background-color: var(--paradise-bg-primary-subtle, var(--paradise-bg-2)) !important;
            border-color: var(--paradise-color-primary, #22ab3f) !important;
        }

        #logoutContainer .action-item:hover::before {
            opacity: 0.08;
        }

        #logoutContainer .action-item i {
            font-size: 22px;
            margin-bottom: 8px;
            color: var(--paradise-color-primary, #22ab3f) !important;
            transition: color 0.3s ease;
        }

        #logoutContainer .action-item:hover i {
            color: var(--paradise-color-success, #0ecb81) !important;
        }

        #logoutContainer .action-item span {
            font-size: 12px;
            text-align: center;
            font-weight: 500;
            color: var(--paradise-fg-1, #b7bdc6) !important;
        }

        #logoutContainer .action-item:hover span {
            color: var(--paradise-fg-0, #eaecef) !important;
        }

        #logoutContainer .logout-section {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
            margin-top: 20px;
            border-top: 1px solid var(--paradise-border-color, rgba(0, 0, 0, 0.1)) !important;
            cursor: pointer;
            color: var(--paradise-color-danger, #f6465d) !important;
            transition: background-color 0.3s ease;
            border-radius: 10px;
        }

        #logoutContainer .logout-section:hover {
            background-color: var(--paradise-bg-danger-subtle, rgba(246, 70, 93, 0.15)) !important;
        }

    </style>
  </defs>
  <path class="cls-3" d="M63.11,239.09L9.62,167c-9.86-13.28-11.88-30.82-5.3-46L40,38.68c6.58-15.17,20.74-25.69,37.17-27.59L166.33.8c16.43-1.89,32.62,5.13,42.48,18.41l53.48,72.07c9.86,13.28,11.89,30.82,5.31,46l-35.68,82.35c-6.57,15.18-20.74,25.7-37.17,27.59l-89.19,10.28c-16.42,1.88-32.6-5.13-42.45-18.41Z"/>
  <path class="cls-4" d="M109.07,138l-22.22,6.75c-11.75,4.05-18.52,5.25-30.66,16.74-4.16,3.94-13.35,18.88-11.35,17,21-19.45,45.88-29,51.9-32.23-4.16,3.43-7.89,7.44-12.53,12-3.75,3.57-7.08,7.56-9.92,11.89-1.58,2.56-2.45,4-3.8,6.58-4.54,8.72-8.17,17.87-10.85,27.33-.82,3.47-1.37,7-1.64,10.55,0,0,6.23-4.8,8.85-11.39,1.24-3.11,6.34-17.72,7.63-19.07,1.62-1.69-.8,15.35.84,13.77,2.09-2,4.72-16.84,6.55-18.3,2.66-2.12.76,13,3.16,10.79,1.08-1,4.3-24.58,5.3-25.57,1.32-1.3,1.25,19.74,2.39,18.41,1.31-1.52,5.77-26.13,6.79-27.71s-.51,17.76,1.17,17.46c2.24-1.71,3.95-8.81,4.15-10.42.59-4.88,1.49-7.48,2.24-12.3.68-4.47,1.65-10.4,2-12.28Z"/>
  <path class="cls-4" d="M109.07,38.15l23.66.19c21.14,0,35.4.92,42.78,2.77,10.16,2.34,19.27,7.96,25.92,16,6.75,8.11,10.11,18.29,10.07,30.54-.04,12.25-3.31,22.41-9.81,30.5-6.55,8-15.57,13.39-27.06,16.17-8.39,2-24.07,3-47.06,3v85.89h-18.5V38.15ZM127.56,56.25v62.75l18.12.57c12.67,0,21.94-1.15,27.81-3.45,5.68-2.14,10.52-6.04,13.84-11.12,3.34-5.13,5.08-11.15,5-17.27.05-6.04-1.69-11.95-5-17-3.15-4.98-7.8-8.83-13.28-11-5.49-2.17-14.49-3.26-27-3.26l-19.49-.22Z"/>
  <path id="BambooHR" class="cls-1" d="M1005.64,91.55c1.51,3.44,2.28,7.17,2.25,10.93.04,3.83-.73,7.62-2.25,11.13-1.44,3.31-3.51,6.31-6.08,8.85-2.56,2.52-5.6,4.51-8.93,5.85-3.46,1.4-7.15,2.1-10.88,2.08-3.74.02-7.44-.69-10.91-2.08-3.35-1.34-6.41-3.33-9-5.85-2.59-2.53-4.67-5.53-6.12-8.85-1.52-3.51-2.28-7.3-2.24-11.13-.03-3.76.73-7.49,2.24-10.93,1.45-3.3,3.53-6.28,6.12-8.79,11.09-10.68,28.63-10.68,39.72,0,2.57,2.51,4.64,5.5,6.08,8.79ZM1001,111.99c1.19-3.02,1.79-6.24,1.76-9.49.02-3.18-.57-6.34-1.76-9.3-4.88-11.79-18.39-17.39-30.18-12.51-5.67,2.34-10.17,6.85-12.51,12.51-1.19,2.96-1.79,6.11-1.77,9.3-.03,3.25.57,6.47,1.77,9.49,1.12,2.81,2.77,5.38,4.87,7.56,2.1,2.14,4.6,3.84,7.36,5,2.9,1.23,6.03,1.85,9.18,1.83,6.17.05,12.09-2.43,16.4-6.85,2.1-2.18,3.75-4.74,4.88-7.54ZM990.45,102.1c-1.76,1.41-3.9,2.25-6.15,2.41l9.38,14.37h-5.48l-8.93-14h-5.4v14h-5.1v-32.54h12.68c3.9,0,6.79.77,8.67,2.3,1.88,1.53,2.82,3.87,2.81,7,0,2.93-.82,5.07-2.48,6.44v.02ZM979.2,100.79c1.09.02,2.18-.02,3.26-.11.94-.05,1.87-.26,2.74-.63.78-.33,1.45-.89,1.91-1.6.52-.91.77-1.95.71-3,.05-.91-.17-1.81-.63-2.6-.41-.63-.98-1.15-1.65-1.49-.73-.36-1.52-.6-2.33-.7-.86-.13-1.72-.19-2.59-.19h-6.72v10.32h5.3Z"/>
  <path class="cls-1" d="M295.66,140.05v85.57h-10.58v-16.48c-4.1,5.15-9.27,9.36-15.14,12.34-16.39,7.84-35.96,4.34-48.61-8.7-8.24-8.28-12.76-19.56-12.53-31.24-.18-11.57,4.39-22.71,12.65-30.82,7.92-8.32,18.95-12.97,30.44-12.81,6.46-.09,12.85,1.41,18.59,4.37,5.83,3.17,10.83,7.66,14.6,13.12v-15.35h10.58ZM252.77,148.26c-11.88-.1-22.87,6.33-28.61,16.73-5.99,10.43-5.99,23.26,0,33.69,2.84,5.19,7.04,9.52,12.14,12.52,4.94,2.95,10.59,4.5,16.35,4.48,5.86,0,11.62-1.53,16.7-4.44,5.08-2.79,9.28-6.95,12.13-12,2.9-5.24,4.38-11.15,4.29-17.14,0-9.65-3.18-17.71-9.53-24.2-6.12-6.37-14.64-9.88-23.47-9.68v.04Z"/>
  <path class="cls-1" d="M439.56,140.05v15.34c-3.76-5.45-8.75-9.94-14.56-13.11-5.75-2.96-12.14-4.46-18.6-4.37-11.47-.15-22.49,4.49-30.4,12.79-14.09-14.35-24.51-12.8-27.51-12.8-4.05.04-8,1.28-11.34,3.57-4.12,2.88-7.63,6.54-10.35,10.77v-12.19l-11,2.15v83.42h11v-28.22c0-16.61.67-26.22,2-30.97,1.74-6.19,4.27-10.75,7.59-13.69s6.77-4.41,10.35-4.41c1.52,0,12.66-1.7,22.63,10.78-4.06,6.77-6.14,14.54-6,22.43-.23,11.68,4.29,22.96,12.53,31.24,12.65,13.04,32.22,16.54,48.61,8.7,5.87-2.98,11.03-7.19,15.14-12.34v16.48h10.59v-85.57h-10.68ZM436,199.28c-2.84,5.06-7.05,9.21-12.14,12-5.08,2.91-10.83,4.44-16.69,4.44-5.76.02-11.41-1.53-16.35-4.48-5.1-3-9.3-7.33-12.14-12.52-6-10.43-6-23.26,0-33.69,5.73-10.42,16.72-16.86,28.61-16.77,8.83-.18,17.33,3.35,23.44,9.73,6.35,6.49,9.52,14.56,9.53,24.2.09,5.97-1.38,11.86-4.26,17.09Z"/>
  <path class="cls-1" d="M557.56,107.85v117.72h-10.56v-16.43c-4.11,5.15-9.27,9.36-15.14,12.34-16.39,7.84-35.96,4.34-48.61-8.7-8.25-8.28-12.78-19.56-12.54-31.24-.18-11.57,4.39-22.71,12.65-30.82,7.92-8.32,18.95-12.97,30.44-12.81,6.46-.09,12.85,1.41,18.59,4.37,5.83,3.17,10.83,7.66,14.61,13.12v-47.55h10.56ZM514.66,148.26c-11.88-.1-22.86,6.33-28.6,16.73-6,10.43-6,23.26,0,33.69,2.84,5.19,7.03,9.52,12.13,12.52,4.95,2.95,10.61,4.5,16.37,4.48,5.86,0,11.62-1.53,16.7-4.44,5.09-2.79,9.29-6.95,12.14-12,2.9-5.24,4.37-11.15,4.28-17.14,0-9.65-3.18-17.71-9.54-24.2-6.12-6.37-14.64-9.88-23.47-9.68v.04Z"/>
  <path class="cls-1" d="M585.56,105.7c4.89.16,8.72,4.26,8.56,9.15-.16,4.66-3.9,8.4-8.56,8.56-2.33.03-4.57-.91-6.18-2.6-3.44-3.44-3.44-9.02,0-12.46,0,0,0,0,0,0h0c1.6-1.7,3.84-2.66,6.18-2.65ZM580.23,140.05h10.77v85.52h-10.7l-.07-85.52Z"/>
  <path class="cls-1" d="M655.24,149.14l-6.9,7.13c-5.74-5.58-11.35-8.37-16.83-8.36-3.34-.08-6.57,1.16-9,3.45-2.34,2-3.69,4.92-3.72,8,.06,2.87,1.15,5.61,3.07,7.74,2.05,2.51,6.35,5.45,12.91,8.82,8,4.14,13.43,8.14,16.29,12,2.79,3.8,4.27,8.4,4.22,13.11.12,6.55-2.5,12.86-7.22,17.4-4.77,4.74-11.28,7.31-18,7.13-4.78.01-9.49-1.06-13.79-3.14-4.25-2-7.97-4.96-10.86-8.66l6.75-7.67c5.48,6.19,11.29,9.28,17.44,9.28,4.06.09,8.01-1.39,11-4.14,2.87-2.43,4.52-5.99,4.53-9.74.02-3.01-1.05-5.92-3-8.2-2-2.35-6.51-5.32-13.53-8.9-7.53-3.88-12.65-7.71-15.36-11.5-2.72-3.78-4.15-8.34-4.07-13-.16-5.94,2.19-11.68,6.48-15.8,4.33-4.19,9.8-6.28,16.4-6.29,7.67.06,15.4,3.84,23.19,11.34Z"/>
  <path class="cls-1" d="M744.49,195.79l9,4.75c-2.56,5.28-6.04,10.06-10.28,14.11-3.81,3.53-8.27,6.31-13.12,8.17-5.28,1.93-10.88,2.88-16.5,2.79-13.61,0-24.25-4.46-31.92-13.37-7.67-8.91-11.51-19-11.52-30.25-.11-10.27,3.34-20.26,9.75-28.29,8.24-10.53,19.26-15.79,33.07-15.8,14.23,0,25.59,5.39,34.08,16.18,6,7.62,9.07,17.13,9.2,28.52h-75c.22,9.69,3.33,17.63,9.33,23.83,5.75,6.1,13.81,9.47,22.19,9.29,4.23,0,8.43-.74,12.39-2.21,3.75-1.32,7.22-3.31,10.25-5.88,2.77-2.43,5.79-6.37,9.08-11.84ZM744.49,173.33c-1.09-4.97-3.22-9.65-6.26-13.73-2.93-3.57-6.65-6.4-10.86-8.28-4.44-2.08-9.29-3.15-14.2-3.14-7.79-.15-15.34,2.67-21.11,7.9-4.3,3.83-7.55,9.58-9.75,17.25h62.18Z"/>
  <line class="cls-5" x1="262.12" y1="149.83" x2="266.4" y2="140.05"/>
  <path class="cls-2" d="M782.08,112.52h11.28v47.3h57.42v-47.3h11.27v112.78h-11.27v-54.44h-57.42v54.44h-11.28v-112.78Z"/>
  <path class="cls-2" d="M957.17,209.41c-3.73-8.87-12.5-23.09-36.19-36.6,9.49,0,17.62-1.09,23-3.47,5.12-2.17,9.44-5.85,12.39-10.56,2.95-4.88,4.45-10.5,4.33-16.2,0-7.37-2.1-13.58-6.29-18.61-4.17-5.06-9.92-8.55-16.33-9.92-4.45-1.02-12.94-1.53-25.45-1.53h-22.52v112.82h11.25v-52.37h6.37c1.79,5.37,2.58,6.64,4.81,13.62.86,2.96,1.99,5.83,3.36,8.59.06.13.21.18.33.12.07-.03.12-.1.14-.17.82-3.62-.65-16.62,0-16.76.83-.17,2.11,6,2.78,8.72,1.19,4.9,4.26,16.92,6,18.21.04.01.07.01.11,0,1.25.22-1.32-18.86-.11-19.07.68-.11,3,7.24,4.12,12.7.84,4.11,4.48,16.35,4.67,13.08.24-4.26,0-18.52,1.54-16.6s6.31,21,8,23c1.48,1.74-.85-16.32,1-14.83,1.43,1.2,6,9.5,8,12.42,4.14,6,11.56,14.37,11.26,12.74-.57-3.18-2.27-9.11-6.57-19.33ZM901.38,123.52h19.86c7.73,0,13.26.67,16.59,2,3.32,1.31,6.13,3.63,8.06,6.63,2.04,3.05,3.11,6.65,3.07,10.32.05,3.73-.99,7.39-3,10.54-2.01,3.13-4.97,5.53-8.45,6.86-3.61,1.43-9.18,2.15-16.7,2.15l-19.43-.16v-38.34Z"/>
</svg>
   </div>
      <div class="dock">

      </div>
   <div  class="navbar__right">

   <!-- Theme Toggle Switch -->
    <div class="toggle-wrapper">
        <button type="checkbox" id="theme-toggle" aria-label="Toggle dark mode">
    <i id="themeIcon" class="bi bi-sun"></i>
  </button>

      </div>

        <div class="user-info">
          <div class="notifications">
             <i class="bi bi-bell" ></i>

          </div>
          <div class="profile">
   <div id="logoutContainer">
    <div class="profile-container">
        <div class="avatar-trigger" id="avatarTrigger">
            <img id="randomAvatar" data-disable-profile-click="true" data-employee-id="admin" alt="Avatar" class="avatar">
        </div>


<div class="user-details" id="userDetails">
    <div class="user-info">
        <div class="user-text">
            <h3 id="userName">Xin chào</h3>
            <p id="positionuser"></p>
        </div>
    </div>

    <div class="actions-grid">
        <div id="viewProfile" class="action-item">
            <i class="fas fa-user-circle"></i>
            <span>%profile%</span>
        </div>
        <div id="viewSetting" class="action-item">
            <i class="fas fa-cog"></i>
            <span>%setting%</span>
        </div>
        <div id="viewChangePW" class="action-item">
            <i class="fas fa-lock"></i>
            <span>%change_password%</span>
        </div>
        <div id="viewHelp" class="action-item">
            <i class="fas fa-question-circle"></i>
            <span>%help%</span>
        </div>
        <div class="action-item" id="setup-google-auth">
            <i class="fas fa-lock"></i>
            <span>Google 2FA</span>
        </div>
    </div>

    <div class="logout-section" id="profileLogout">
        <i class="fas fa-sign-out-alt" style="margin-right: 10px; color:red"></i>
        %logout%
    </div>
</div>

</div>
</div>
</div>
          </div>



     <!-- Notification nè-->
<div class="notification-container">
  <div class="notification-header">
    <h6>Thông báo</h6>
    <div class="notification-menu">
      <button class="notification-menu-button">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <circle cx="8" cy="3" r="1.5" fill="#686868"/>
          <circle cx="8" cy="8" r="1.5" fill="#686868"/>
          <circle cx="8" cy="13" r="1.5" fill="#686868"/>
        </svg>
      </button>
      <div class="notification-menu-dropdown">
        <button class="notification-mark-all-read">Ðánh d?u t?t c? dã xem</button>
        <button class="notification-view-list">Xem danh sách thông báo</button>
        <button class="notification-settings">Cài d?t</button>
      </div>
    </div>
  </div>
  <div class="notification-item">
    <img src="" alt="User Image">
    <div class="notification-text">
      Maja Pandev requested Thursday, Jan 3 off – 40 hours of Vacation <br>
      <small>11 days ago</small>
    </div>
    <div class="notification-actions">
      <button class="notification-button notification-approve">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" clip-rule="evenodd"
            d="M8 16C3.58172 16 0 12.4183 0 8C0 3.58172 3.58172 0 8 0C12.4183 0 16 3.58172 16 8C16 12.4183 12.4183 16 8 16ZM12.0335 5.36401C12.3194 4.90439 12.2039 4.2839 11.7756 3.97815C11.3454 3.6704 10.7691 3.79632 10.4842 4.25494L7.27655 9.4187L5.25793 7.97491C4.82777 7.66717 4.25048 7.79302 3.96649 8.25165C3.68064 8.71128 3.79606 9.33182 4.22437 9.63757L7.79236 12.1905L12.0335 5.36401Z"
            fill="#F4F4F4" />
        </svg>
      </button>
      <button class="notification-button notification-reject">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M8 0C3.582 0 0 3.582 0 8C0 12.418 3.582 16 8 16C12.418 16 16 12.418 16 8C16 3.582 12.418 0 8 0ZM11.1379 10.1953C11.3986 10.456 11.3986 10.8773 11.1379 11.138C11.0079 11.268 10.8373 11.3333 10.6666 11.3333C10.496 11.3333 10.3253 11.268 10.1953 11.138L8 8.94266L5.80469 11.138C5.67469 11.268 5.50404 11.3333 5.33337 11.3333C5.16271 11.3333 4.99206 11.268 4.86206 11.138C4.60139 10.8773 4.60139 10.456 4.86206 10.1953L7.05737 8L4.86206 5.80466C4.60139 5.54399 4.60139 5.12267 4.86206 4.862C5.12273 4.60133 5.54402 4.60133 5.80469 4.862L8 7.05734L10.1953 4.862C10.456 4.60133 10.8773 4.60133 11.1379 4.862C11.3986 5.12267 11.3986 5.54399 11.1379 5.80466L8.94263 8L11.1379 10.1953Z"
            fill="#686868" />
        </svg>
      </button>
    </div>
  </div>
  <div class="notification-view-all">
    <a href="#">View All</a>
  </div>
</div>


   <!-- t?i dây -->
        </div>

        </div>
      </div>

    <!--DOCK end-->

<!-- LaunchPad -->

			     <!--LAUNCHPAD start-->
    <div class="launchpad draggableElement" id="launchpad">
       <!-- <button class="prev-button"><i class="bi bi-chevron-left"></i></button>
        <button class="next-button"><i class="bi bi-chevron-right"></i></button> -->
      <div class="searchbox">
        <div class="searchContainer">
          <i class="bi bi-search" style="font-size: 18px"></i>
          <input
          class="search-input"
            type="search"
            name="search"
            placeholder="Search"
            accesskey="s"
          />
        </div>
      </div>

	    <div class="wrapper-launchpad">
        <div class="wrapper-launchpad-child">
            <i id="left" class="change-icon bi bi-chevron-left"></i>
            <div class="carousel">


            </div>
            <i id="right" class="change-icon fa-solid fa-angle-right"></i>
        </div>
    </div>

    <!--  <div class="Apps-container">
      </div> -->
    </div>
    <!--LAUNCHPAD end-->
	

<!-- Window Container -->
<div class="container__Window" style="min-height: 100vh;">
  <div class="bg-body" style="margin-top: 30px;height:100%;overflow-y: auto;">
    <!-- Dynamic dashboard loaded via openFormParam -->
  </div>
</div>

<!-- Widgets Panel -->
<section class="widgets-panel open">
  <div class="widgets-panel__calendar">
    <div id="taghvim">
      <h2>19</h2>
      <h4>Tuesday</h4>
    </div>
    <ul style="padding-left: 0;">
      <li class="blue"><span>Listen podcast</span><span>2:30 - 3:00 PM</span></li>
      <li class="purple"><span>English class</span><span>4:00 - 4:45 PM</span></li>
      <li class="green"><span>Stand-up meeting</span><span>6:15 - 5:30 PM</span></li>
    </ul>
  </div>
</section>

<!-- Spotlight Search -->
<div class="spotlight_serach">
  <div class="spotlight_search-bar-wrapper">
    <i class="bi bi-search spotlight_search-icon" style="font-size: 20px"></i>
    <input type="search" class="spotlight_search-bar" placeholder="%search_menu%" />
  </div>
  <div class="result"></div>
</div>

<!-- Modal Dialog -->

 <div class="modal fade" id="confirmDeleteModal" tabindex="-1" aria-labelledby="confirmDeleteModalLabel" >
  <div class="modal-dialog modal-dialog-centered modal-sm" style="--bs-modal-width: 400px;">
    <div class="modal-content">
      <div class="modal-header">
        <h6 class="modal-title" id="confirmDeleteModalLabel">
          Thông báo
        </h6>
        <button type="button" class="btn-close btn btn-sm" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center">

      </div>
      <div class="modal-footer border-0 justify-content-center">
  <button type="button" class="btn btn-danger" id="confirmDeleteButton">
          <i class="bi bi-x-lg"></i> <span> Đóng </span>
        </button>
        <button type="button" class="btn btn-outline-primary" id="cancelButton" data-bs-dismiss="modal">
          <i class="bi bi-arrow-return-left"></i> <span> Stay </span>
        </button>
      </div>
    </div>
  </div>
</div>


<div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="confirmSuccessModalLabel" >
  <div class="modal-dialog modal-dialog-centered modal-sm" style="--bs-modal-width: 400px;">
    <div class="modal-content">
      <div class="modal-header">
        <h6 class="modal-title" id="confirmDeleteModalLabel">
          Thông báo
        </h6>
        <button type="button" class="btn-close btn btn-sm" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center modal-success">

      </div>
      <div class="modal-footer border-0 justify-content-center modal-footer-success-confirm">
  <button type="button" class="btn btn-success" id="successModalButton">
          <i class="bi bi-x-lg"></i> <span> Đóng </span>
        </button>
  <button type="button" class="btn btn-outline-primary" id="cancelButton1" data-bs-dismiss="modal">
          <i class="bi bi-arrow-return-left"></i> <span> Stay </span>
        </button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="successModalAddNew" tabindex="-1" aria-labelledby="confirmDeleteModalLabelAddNew" >
  <div class="modal-dialog modal-dialog-centered modal-sm" style="--bs-modal-width: 400px;">
    <div class="modal-content">
      <div class="modal-header">
        <h6 class="modal-title" id="confirmDeleteModalLabelAddNew">
          Thông báo
        </h6>
        <button type="button" class="btn-close btn btn-sm" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center modal-success-addNew">
      </div>
      <div class="modal-footer border-0 justify-content-center modal-footer-success-addNew">
        <button type="button" class="btn btn-success" id="successModalButtonAddNew">
          <i class="bi bi-x-lg"></i> <span> Đóng </span>
        </button>
        <button type="button" class="btn btn-outline-primary" id="cancelButton1AddNew" data-bs-dismiss="modal">
          <i class="bi bi-arrow-return-left"></i> <span> Stay </span>
        </button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="notificationModal" tabindex="-1" aria-labelledby="notificationModalLabel" >
  <div class="modal-dialog modal-dialog-centered modal-sm" style="--bs-modal-width: 400px;">
    <div class="modal-content">
      <div class="modal-header">
        <h6 class="modal-title" id="notificationModalLabel">
          Thông báo
        </h6>
        <button type="button" class="btn-close btn btn-sm" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center modal-success"></div>
      <div class="modal-footer border-0 justify-content-center modal-footer-success">
       <button type="button" class="btn" id="notificationModalButton" style="background: #00673b;">
         <i class="bi bi-check-lg"></i> <span>OK</span>
        </button>
      </div>
    </div>
  </div>
</div>
</div>

<!-- Bootstrap JS Bundle -->
<script src="%@APPLICATION_ADDRESS%/Scripts/bootstrap.bundle.min.js"></script>

<script>
var draggableElement = document.querySelector(''.draggableElement'');

  function moveLeftLaunchPad(){
    let firstImgWidth = firstImg.clientWidth + 14;
    carousel.scrollLeft += -firstImgWidth ;
    showHideIcons();
    setTimeout(() => showHideIcons(), 60);
}

function moveRightLaunchPad(){
    let firstImgWidth = firstImg.clientWidth + 14;
    carousel.scrollLeft += firstImgWidth ;
    showHideIcons();
    setTimeout(() => showHideIcons(), 60);
}


		// Get the launchpad element
		var launchpadKey = document.getElementById(''launchpad'');

		// Variables to track scrolling state
		var scrollTimeout;          // Timeout reference for debounce
		var accumulatedDeltaX = 0; // Accumulates the total horizontal scroll

		// Constants
		var SCROLL_THRESHOLD = 30; // Minimum deltaX to trigger navigation
		var DEBOUNCE_DELAY = 100;  // Delay in milliseconds to detect scroll stop

		//launchpadKey.addEventListener(''wheel'', function(event) {
			// Ignore zoom gestures or non-pixel scrolls
		//	if (event.ctrlKey || event.deltaMode !== 0) {
		//		return;
		//	}

			// Accumulate horizontal scroll
			// const appsContainer = document.querySelector(''.Apps-container'');
		//	accumulatedDeltaX += event.deltaX;
			//appsContainer.style.transform = `translateX(${-accumulatedDeltaX}px)`;

			// Reset the debounce timer on every wheel event
		//	clearTimeout(scrollTimeout);
		//	scrollTimeout = setTimeout(function() {
				
		//		handleScrollStop(accumulatedDeltaX);
				
				// Reset the accumulated delta after handling
		//		accumulatedDeltaX = 0;
		//	}, DEBOUNCE_DELAY);
		//});

		function handleScrollStop(totalDeltaX) {
			if (totalDeltaX < -SCROLL_THRESHOLD) {
				// Handle the two-finger swipe right action (scrolling left)
				if (currentPage !== 1) {
					moveLeftLaunchPad();
					//console.log(''Navigated to Previous Page'');
				}
			} else if (totalDeltaX > SCROLL_THRESHOLD) {
				// Handle the two-finger swipe left action (scrolling right)
				if (currentPage !== totalPages) {
					moveRightLaunchPad();
					//console.log(''Navigated to Next Page'');
				}
			} else {
				
				//console.log(''Scroll did not meet the threshold. No action taken.'');
			}
			
		}



	document.addEventListener(''keydown'', function(event) {

	if(	launchpad.window.style.display === "block" &&
		document.querySelector(`.master-tabs`).style.display !== ''none'' &&
		document.querySelector(`.home-sidebar`).style.display !== ''none'' || launchpad.window.style.display === "none" ){
		return;
		}

    if (event.keyCode === 37) {
       moveLeftLaunchPad();
	   console.log(''Previous'');
    } else if (event.keyCode === 39) {
        moveRightLaunchPad();
		console.log(''Next'');
    }
});

		

				var carousel = document.querySelector(".carousel");
				//firstImg = carousel.querySelectorAll(".Apps-container")[0];
				arrowIcons = document.querySelectorAll(".wrapper-launchpad-child i.change-icon");


				var isDragStart = false, isDragging = false, prevPageX, prevScrollLeft,positionDiff,firstImg;



				var showHideIcons = () => {
					let scrollWidth = carousel.scrollWidth - carousel.clientWidth;
					arrowIcons[0].style.display = carousel.scrollLeft == 0 ? "none" : "block";
					arrowIcons[1].style.display = carousel.scrollLeft == scrollWidth ? "none" : "block";

				}

				arrowIcons.forEach(icon => {
					icon.addEventListener("click", () => {
						let firstImgWidth = firstImg.clientWidth + 14;
						carousel.scrollLeft += icon.id == "left" ? -firstImgWidth : firstImgWidth;
						showHideIcons();
						setTimeout(() => showHideIcons(), 60);
					});

				});

				var autoSlide = () => {

					if((arrowIcons[0].style.display === "none"))
						{return;}
					if(carousel.scrollLeft == (carousel.scrollWidth - carousel.clientWidth)) return;

					positionDiff = Math.abs(positionDiff);
					let firstImgWidth = firstImg.clientWidth + 14;
					let valDifference = firstImgWidth - positionDiff;

					if(carousel.scrollLeft > prevScrollLeft){
						return carousel.scrollLeft += positionDiff > firstImgWidth / 3 ? valDifference : -positionDiff;
					}
					carousel.scrollLeft -= positionDiff > firstImgWidth / 3 ? valDifference : -positionDiff;
				}

				var dragStart = (e) => {
					e.preventDefault();
					isDragStart = true;
					prevPageX = e.pageX || e.touches[0].pageX;
					prevScrollLeft = carousel.scrollLeft;
				}

				var dragging = (e) => {
					// || (arrowIcons[0].style.display === "none")
					if(!isDragStart ) return;
					e.preventDefault();
					isDragging = true;
					carousel.classList.add("dragging");
					positionDiff = (e.pageX || e.touches[0].pageX) - prevPageX;
					carousel.scrollLeft = prevScrollLeft - positionDiff;
					showHideIcons();
				}

				var dragStop = () => {
					isDragStart = false;
					carousel.classList.remove("dragging");

					if(!isDragging) return;
					isDragging = false;
					autoSlide();
				}

				carousel.addEventListener("mousedown", dragStart);
				//carousel.addEventListener("touchstart", dragStart);

				carousel.addEventListener("mousemove", dragging);
				//carousel.addEventListener("touchmove", dragging);

				carousel.addEventListener("mouseup",dragStop);
				carousel.addEventListener("mouseleave",dragStop);
				//carousel.addEventListener("touchend",dragStop);
</script>

<script>
var nodeMapHtml = {};

           function getNode(id) {
               if (!nodeMapHtml[id]) {
                   nodeMapHtml[id] = { id, children: [], data: null, svgIcon: null, className: null};
               }
               return nodeMapHtml[id];
           }

           dataMenuViewHtml.forEach(({ Parent, Child,AdditionData, Data, SvgIcon,ClassName  }) => {
               if (Child) {
                   const parentNode = getNode(Parent);
                   const childNode = getNode(Child);
                   childNode.additionData = AdditionData;
                   childNode.data = Data;
                   childNode.svgIcon = SvgIcon;
				   childNode.className = ClassName;
                   parentNode.children.push(childNode);
               } else {
                   const parentNode = getNode(Parent);
                   parentNode.additionData = AdditionData;
                   parentNode.data = Data;
                   parentNode.svgIcon = SvgIcon;
				   parentNode.className = ClassName;
 }
          });
           var rootsHtml = Object.values(nodeMapHtml).filter(node => !dataMenuViewHtml.some(item => item.Child === node.id));
	var hasRenderedButton = false;	

   function renderTree(node, selectedClassName = '''',isRoot = true) {
    let isSelected = (selectedClassName && node.className === selectedClassName) ? ''active'' : '''';
    let html = '''';
	
	 if (!hasRenderedButton && node.children.length > 0) {
        //html += ''<div class ="d-flex"><button class="menu-button main-menu-button">&#9776;</button><button class="menu-button tree-menu-button"><span class="bi-text-left fs-4"></span></button></div>'';

		 html += `
            <li class="${isSelected}">
                <a class="menu-f" href="#" style="">
						
                    <span class="text">${node.data}</span>
                     <i class="arrow" style="font-size: 14px !important;"></i>
                </a>
        `;
		    hasRenderedButton = true;
    }
    else if (node.children.length > 0 ) {
        html += `
		
            <li class="${isSelected}">
                <a class="" href="#">
						 ${node.svgIcon}	
          <span class="text">${node.data}
					<i class="bi bi-chevron-down toggle-icon" style="font-size: 14px;float: right;"></i>
					</span>

                </a>
        `;

    } else {
        html = `
            <li id="${node.id}" class="${isSelected}">
                <a  onClick="OpenAppInSidebar(''${node.id}'')" href="#">
                   ${node.svgIcon}
                    <span class="text">${node.data}</span>
                </a>
        `;



    }

     if (node.children.length > 0) {
        let marginLeft = isRoot ? ''0'' : ''5px'';

        if (isRoot) {
            html += `<div id="scrollsidebar" style="height: calc(85vh - 40px); overflow-y: scroll; margin-left: ${marginLeft} !important">`;
        }

      html += `<ul class="sub-menu ${isRoot ? ''sub-main'' : ''sub-sub''}" style="display: block;${isRoot ? '''' : ''border-left: 2.5px solid #f6f6f6;display:none''}">`;

        node.children.forEach(child => {
            html += renderTree(child, selectedClassName, false);
        });
        html += `</ul>`;

        // Đóng thẻ <div> chỉ khi isRoot là true
        if (isRoot) {
            html += `</div>`;
        }
    }
    html += ''</li>'';

    return html;
}
function scrollToActive() {
    /*const sidebar = document.querySelector(''#scrollsidebar'');
	const activeElement = sidebar.querySelector(''.active'');

    if (activeElement) {
		sidebar.scrollTop = activeElement.offsetTop - sidebar.offsetTop;

    }*/
}
function findAllParents(menuItem) {
    let parents = [];
    let currentItem = menuItem;

    // Tìm tất cả các cha
    while (currentItem && currentItem.Parent !== "Mnu") {
        let parentItem = dataMenuViewHtml.find(item => item.Child === currentItem.Parent);
        if (parentItem) {
            parents.unshift(parentItem);
            currentItem = parentItem;
        } else {
            break;
        }
    }

    return parents;
}
 function renderChildren(menuParent) {

    let childrenNodes;
    if(menuParent.id){
	    childrenNodes = dataMenuViewHtml.filter(item => item.Parent === menuParent.id && item.isShowInMobileLayOut == 0 && item.IsHiddenInTree == 0);
	
    }
    else{
	    childrenNodes = dataMenuViewHtml.filter(item => item.Parent === menuParent.Child && item.isShowInMobileLayOut == 0 && item.IsHiddenInTree ==  0);

    }
     if (childrenNodes.length === 0) {
            return [];
        }
         return childrenNodes.map(child => {
            let childNode = {
                id: child.Child,
                data: child.Data,
                className: child.ClassName,
                svgIcon: child.SvgIcon,
                children: renderChildren(child)
            };
	
            return childNode;
        });
    }

function mergeNodes(nodes) {
    let nodeMap = {};

    function recursiveMerge(node) {
if (nodeMap[node.id]) {
            nodeMap[node.id].children = [
   ...nodeMap[node.id].children,
                ...node.children.map(child => recursiveMerge(child))
 ];
        } else {
    nodeMap[node.id] = { ...node, children: node.children.map(child => recursiveMerge(child)) };
        }
        return nodeMap[node.id];
    }

    nodes.forEach(node => recursiveMerge(node));

    return nodeMap;
}	
function renderMenuForClass(className) {
	let targetNode

	 if (typeof className === "object") {
		targetNode = dataMenuViewHtml.find(item => item.Child === className.id);
	}
	else{
		targetNode = dataMenuViewHtml.find(item => item.ClassName === className || item.Child === className);
	}


    if (!targetNode) {
        console.error(`Class name "${className}" not found.`);
        return;
    }
    let rootParentList  = findAllParents(targetNode);
	console.log(rootParentList)

	let rootnode = [];
if (rootParentList.length > 0) {
	let rootNodeTemp = {
            id: rootParentList[0].Child,
            data: rootParentList[0].Data,
            className: rootParentList[0].ClassName,
            svgIcon: rootParentList[0].SvgIcon,
            children: []
        };
		 rootNodeTemp.children = renderChildren(rootNodeTemp);
	
		rootnode.push(rootNodeTemp);
	
	let mergedTree = mergeNodes(rootnode);
	let resultTree = mergedTree[rootnode[0].id];
	let html = renderTree(resultTree, targetNode.ClassName);
    //document.querySelector(''.sidebar .menu'').innerHTML = `<ul>${html}</ul>`;
    document.querySelector(''.sidebar .menu ul'').innerHTML = html;
	 $("#MainSideBar").on("mouseenter", "a", function() {
        if ($(".sidebar").hasClass("collapsed")) {
            var textContent = $(this).find(".text").text().trim();
			  if ($("#tooltip").length === 0) {

            $("body").append(''<div id="tooltip" style="position:absolute; background-color:black; color:white; border-radius:4px; padding:10px; z-index:9999; display:none;"></div>'');
        }

        $("#tooltip").text(textContent);
        var offset = $(this).offset();
        $("#tooltip").css({
            top: offset.top + 0,
            left: offset.left + $(this).outerWidth() + 10
        }).show();
        }
    });

    $("#MainSideBar").on("mouseleave", "a", function() {
       $("#tooltip").hide();
    });
}
else{
	let rootNodeTemp = {
            id: targetNode.Child,
            data: targetNode.Data,
            className: targetNode.ClassName,
            svgIcon: targetNode.SvgIcon,
            children: []
        };
		 rootNodeTemp.children = renderChildren(rootNodeTemp);
		rootnode.push(rootNodeTemp);

	let mergedTree = mergeNodes(rootnode);

	let resultTree = mergedTree[rootnode[0].id];

	//Hiếu: Nếu mở menu cha không có classname thì mở menu đầu tiên của menu cha đó
    //FIX: Kiểm tra nếu menu có children thì mở child đầu tiên, nếu không thì mở chính nó (tránh lỗi Cannot read properties of undefined)
    if (resultTree.children && resultTree.children.length > 0) {
        insertEmployeeWindow(resultTree.children[0].id,resultTree.children[0].data,resultTree.children[0].className);
        ChangePositionRecent(resultTree.children[0].id);
        document.querySelector(`#point-${resultTree.children[0].id}`).style.display = ''block'';
        let html = renderTree(resultTree, resultTree.children[0].className);
        document.querySelector(''.sidebar .menu ul'').innerHTML = html;
    } else {
        insertEmployeeWindow(resultTree.id,resultTree.data,resultTree.className);
        ChangePositionRecent(resultTree.id);
        let p = document.querySelector(`#point-${resultTree.id}`);
        if (p) p.style.display = ''block'';
        let html = renderTree(resultTree, resultTree.className);
        document.querySelector(''.sidebar .menu ul'').innerHTML = html;
    }
	 $("#MainSideBar").on("mouseenter", "a", function() {
        if ($(".sidebar").hasClass("collapsed")) {
            var textContent = $(this).find(".text").text().trim();
			  if ($("#tooltip").length === 0) {

            $("body").append(''<div id="tooltip" style="position:absolute; background-color:black; color:white; border-radius:4px; padding:10px; z-index:9999; display:none;"></div>'');
        }

        $("#tooltip").text(textContent);
 var offset = $(this).offset();
        $("#tooltip").css({
          top: offset.top + 0,
            left: offset.left + $(this).outerWidth() + 10
  }).show();
       }
    });

    $("#MainSideBar").on("mouseleave", "a", function() {
       $("#tooltip").hide();
    });
}
    attachMenuToggle(targetNode.Parent);
}
function findRootParent(menuItem) {
    let currentItem = menuItem;


    while (currentItem && currentItem.Parent !== '''') {
let parentItem = dataMenuViewHtml.find(item => item.Child === currentItem.Parent);

        if (!parentItem || parentItem.Parent === '''') {
        break;
        }

        currentItem = parentItem;
    }

    return currentItem;
}
	function attachMenuToggle(parent) {
		 var activeItem = $(".sub-main > li").find("li.active").closest("ul.sub-sub");
if (activeItem.length) {
    activeItem.show();
    var icon = activeItem.closest("li").find(".toggle-icon");
    if (icon.length) {
        icon.removeClass("bi-chevron-down").addClass("bi-chevron-up");
    }
}
		 $(parent).off(''click'').on(''click'', function (e) {
		  e.preventDefault();
				e.stopPropagation();
				console.log(1)
		$(this).next(''.sub-menu'').slideToggle();
		});
		 $(".sub-main > li").off("click").on("click", function (e) {
        e.stopPropagation();
		 $(".sub-main > li").not(this).find("ul.sub-sub").slideUp();
		   $(".sub-main > li").not(this).find(".toggle-icon")
        .removeClass("bi-chevron-up")
        .addClass("bi-chevron-down");
		 var subMenu = $(this).find(''ul.sub-sub'').first();
		var icon = $(this).find(''.toggle-icon'');
		
		 if(subMenu.length) {
		
            subMenu.slideToggle();
			 if (icon.hasClass(''bi-chevron-down'')) {
                icon.removeClass(''bi-chevron-down'').addClass(''bi-chevron-up'');
            } else {
                icon.removeClass(''bi-chevron-up'').addClass(''bi-chevron-down'');






          }
       }

	});
	$(".sub-sub li").on("click", function (e) {
    e.stopPropagation();
	
});
	$(".menu-button.main-menu-button").off("click").on("click", function () {
	
	if($(".sidebar .menu ul.main-menu-ul").is(":hidden")) {
		window.TreeCurrentlyOpened = false;
		$(".sidebar .menu ul.main-menu-ul").show();
		$("#employee-tree-container").hide()
		
		return;
	}

	/*$(".sub-main > li ul.sub-sub").slideUp();
	
    $(".sub-main > li .toggle-icon")
        .removeClass("bi-chevron-up")
        .addClass("bi-chevron-down");*/
		setTimeout(function() {
		//$(".sidebar").css("width", "269px");
			 }, 50);
   setTimeout(function() {
        $(".sidebar").toggleClass("collapsed");
        adjustLayout();
		
    }, 250);
		
	
	
});

$(".menu-button.tree-menu-button").off("click").on("click", function () {
	if($("#employee-tree-container").is(":hidden")) {
		window.TreeCurrentlyOpened = true;
		$(".sidebar .menu ul.main-menu-ul").hide();
		$("#employee-tree-container").show();
		
		return;
	}

	$(".sidebar .menu ul.main-menu-ul").show();
	$("#employee-tree-container").hide()
	
	setTimeout(function() {
		//$(".sidebar").css("width", "269px");
			 }, 50);

})

$(".tab-button").on("click", function () {
    //adjustLayout();
	
});
}
function adjustLayout() {
    var nav = document.getElementById("ID-navbar-home");
    if (nav) {
        var nh = nav.offsetHeight;
        if (nh > 0) {
            document.documentElement.style.setProperty("--navbar-height", nh + "px");
            var msb = document.getElementById("MainSideBar");
            if (msb) {
                msb.style.top = nh + "px";
                msb.style.height = "calc(100vh - " + nh + "px)";
            }
        }
    }
    var $sidebar = $(".sidebar");
    var $content = $(".master-tabs");
    var totalWidth = $(window).width();

    var sidebarWidth = $sidebar.hasClass("collapsed") ? 49.28 : (totalWidth * 0.14);
    var contentWidth = totalWidth - sidebarWidth;

    if ($("#MainSideBar .sidebar").hasClass("collapsed")) {
        $(".tree-menu-button").css("display", "none");
        $("MainSideBar .sidebar").css("width", "100%");
        $(".home-sidebar").css("width", "0%");
        $(".sub-main").css("width", sidebarWidth - 10);
        $(".sub-sub").css("margin-left", "-9px");
        $("#MainSideBar .menu").css("margin", "0px -26px");
        $("#MainSideBar .menu .sub-menu .text").css("opacity", "0");
        $("#MainSideBar .menu-f").css("display", "none");
        $("#MainSideBar .menu .sub-menu .text").css("display", "none");
        $("#scrollsidebar").css("margin-left", "-16px");
        $("#MainSideBar .menu i").css("font-size", "20px");

        contentWidth += 9;

        // ✅ QUAN TRỌNG: bỏ margin khi đóng
        $(".master-tabs").css({
            "width": contentWidth + "px",
            "margin-left": "3vw"
        });

        $(".sidebar").css("width", sidebarWidth);

    } else {
        $(".tree-menu-button").css("display", "block");
        $(".sub-main").css("width", sidebarWidth - 26);
        $(".sidebar").css("width", sidebarWidth);
        $(".sub-sub").css("margin-left", "15px");
        $(".sub-sub").css("padding-left", "0.5em");
        $("#MainSideBar .menu").css("margin", "0px -26px");
        $(".home-sidebar").css("width", "14%");
        $("#MainSideBar .menu .sub-menu .text").css("display", "flex");
        $("#MainSideBar .menu .sub-menu .text").addClass("align-items-center justify-content-between");
        $("#MainSideBar .menu .sub-menu .text").css("opacity", "1");
        $("#MainSideBar .menu-f").css("display", "block");
        $("#MainSideBar .menu i").css("font-size", "14px");
        $("#scrollsidebar").css("margin-left", "0px");
    $("#MainSideBar .menu-f").css("width", "92.6%");

        // ✅ QUAN TRỌNG: thêm margin khi mở
        $(".master-tabs").css({
            "width": contentWidth + "px",
            "margin-left": (sidebarWidth - 2) + "px"
        });
    }
}
document.querySelectorAll("#MainSideBar .sidebar.collapsed .menu ul li a").forEach(function(item) {
    item.addEventListener("mouseover", function() {
        const text = this.querySelector(".text");
        if (text) {

        }
    });
});
// Tự động tính toán lại khi thay đổi kích thước cửa sổ
$(window).on(''resize'', function() {
    adjustLayout();
});

$(document).ready(function() {
    adjustLayout();
	
	
});

	
	

	function OpenFormContent(className) {
	hasRenderedButton = false;	
	renderMenuForClass(className);
	  adjustLayout();
	  //scrollToActive();
     /*fetchHtmlString(`https://${window.location.hostname}${window.APPLICATION_ADDRESS}/hpamasterdata/datasetting?tablename=${className}`)
        .then(htmlString => {
	
			$(MainContentHtml).html(htmlString);
			renderMenuForClass(className);	
        })
        .catch(error => {
            console.error("Lỗi goy", error);
 });*/
}
	function OpenFormContent_Sidebar(className){
  let targetNode;
  let currentActiveNode = null;
   if (typeof className === "object") {
   targetNode = dataMenuViewHtml.find(item => item.Child === className.id);
  }
  else{
   targetNode = dataMenuViewHtml.find(item => item.ClassName === className || item.Child === className);
  }


  if (!targetNode) {
   console.error(`Class name "${className}" not found.`);
   return;
  }
  let newActiveElement = document.getElementById(targetNode.Child);

  let activeElements = document.querySelectorAll(''.main-menu-ul .active'');
  activeElements.forEach(element => {
   element.classList.remove(''active'');
  });
  if (newActiveElement) {
   newActiveElement.classList.add(''active'');
  }
  currentActiveNode = newActiveElement;
 }
</script>

<script>
function openMenu(MenuInfor){
    //console.log(MenuInfor)
   //console.log(window.APPLICATION_ADDRESS);
  if (typeof MenuInfor === "string") {
    let className = MenuInfor;
    OpenFormContent_Sidebar(className);
    scrollToActive();
   } else if (typeof MenuInfor === "object") {

    if (MenuInfor.className) {
     OpenFormContent(MenuInfor.className);
     scrollToActive();
    } else {
     OpenFormContent(MenuInfor);
     scrollToActive();
    }
   } else {
    console.error("Lỗi goy: Định dạng MenuInfor không hợp lệ");
   }
  }


window.EnableInstantCacheView = 1;
// Quản lý link cache theo từng Key độc lập trong Local Storage
window.getCacheFormLink = function(key) { try { return localStorage.getItem(key) || ""; } catch(e) { return ""; } };
window.setCacheFormLink = function(key, val) { try { localStorage.setItem(key, val); } catch(e) {} };
window.removeCacheFormLink = function(key) { try { localStorage.removeItem(key); } catch(e) {} };

function fetchHtmlString(url) {
    return new Promise(async (resolve, reject) => {
        try {
            if (!url.trim().startsWith("http"))
                url = window.origin + url.trim();

            let urlObj = new URL(url);
            let urlParams = urlObj.searchParams;
            let rawTableName = urlParams.get("tablename") || urlParams.get("TableName") || "";
            let TableName = rawTableName.replace("_html", "");
            let lang = window.LanguageID || "VN";
            let isWebLocal = window.isWeb || 1;
            let appAddress = window.APPLICATION_ADDRESS || "";
            let serverName = appAddress.replace(/\//g, "") || "root";
            let cacheKeyLink = serverName + "_link_" + TableName;
            let oldUrlFetch = localStorage.getItem(cacheKeyLink) || "";

            if (oldUrlFetch && oldUrlFetch.indexOf(appAddress) === -1) {
                oldUrlFetch = "";
            }

            let resolvedFromCache = false;

            // BƯỚC 1: Lấy từ Browser HTTP Disk Cache ngay lập tức (0ms delay)
            if (window.EnableInstantCacheView === 1 && oldUrlFetch) {
                try {
                    let responseOld = await $.ajax({ url: oldUrlFetch, cache: true, global: false });
                    let cachedHtml = "";
                    if (typeof responseOld === "string") {
                        try { cachedHtml = JSON.parse(responseOld).data[0][0].bytes; } catch(e) { cachedHtml = responseOld; }
                    } else if (responseOld?.data?.[0]?.[0]?.bytes) {
                        cachedHtml = responseOld.data[0][0].bytes;
                    }
                    if (cachedHtml) {
                        resolvedFromCache = true;
                        resolve(cachedHtml);
                    }
                } catch(e) { }
            }

            // BƯỚC 2: Kiểm tra phiên bản ngầm với Server (Stale-While-Revalidate)
            const checkAndFetchServer = async () => {
                try {
                    let currentVersion = "-1";
                    let verData = await AjaxHPAParadiseAsync({
                        showLoading: false,
                        data: {
                            name: "paradisepublic",
                            param: ["paradisepublic", TableName, "LanguageID", lang, "IsWeb", isWebLocal, "ParadiseVersion", "-1"]
                        }
                    });
                    let parsed = typeof verData === "string" ? JSON.parse(verData) : verData;
                    if (parsed?.data?.[0]?.[0]) currentVersion = parsed.data[0][0].ParadiseVersion;

                    if (currentVersion && currentVersion !== "-1") {
                        let baseUrl = appAddress.startsWith("http") ? "" : window.location.origin;
                        let newUrlFetch = `${baseUrl}${appAddress}/api/hpa/paradise?&name=paradisepublic&param=["paradisepublic","${TableName}","LanguageID","${lang}","ParadiseVersion",${currentVersion}]&user=paradisepublic&password=3C9909AFEC25354D551DAE21590BB26E38D53F2173B8D3DC3EEE4C047E7AB1C1EB8B85103E3BE7BA613B31BB5C9C36214DC9F14A42FD7A2FDB84856BCA5C44C2&_cb=${lang}_${currentVersion}`;

                        if (newUrlFetch !== oldUrlFetch || !resolvedFromCache) {
                            let response = await $.ajax({ url: newUrlFetch, cache: true, global: false });
                            let newHtmlContent = "";
                            if (typeof response === "string") {
                                try { newHtmlContent = JSON.parse(response).data[0][0].bytes; } catch (e) { newHtmlContent = response; }
                            } else if (response?.data?.[0]?.[0]?.bytes) {
                                newHtmlContent = response.data[0][0].bytes;
                            }

                            if (newHtmlContent) {
                                try { localStorage.setItem(cacheKeyLink, newUrlFetch); } catch(e) {}

                                if (!resolvedFromCache) {
                                    resolve(newHtmlContent);
                                } else {
                                    // Cập nhật lại UI nếu server vừa đổi code
                                    let activePane = document.querySelector(`[id*="${TableName}"]`) ||
                                                     document.querySelector(`[id*="${TableName.toLowerCase()}"]`) ||
                                                     document.querySelector(`.tab-pane.active`);
                                    if (activePane) {
                                        $(activePane).html(newHtmlContent);
                                        setTimeout(() => { requestAnimationFrame(() => window.dispatchEvent(new Event("resize"))); }, 50);
                                    }
                                }
                                return;
                            }
                        }
                    }
                } catch(e) {
                    console.error("Lỗi check version paradisepublic:", e);
                }

                // Fallback cũ nếu paradisepublic chưa có table này
                if (!resolvedFromCache) {
                    let paramsDataCloud = { data: {
                        name: "ssGetConfigMobileHTMLLayout",
                        param: [
                            "TableName", TableName,
                            "LanguageID", lang,
                            "LoginID", window.LoginID,
                            "IsWeb", window.isWeb,
                            "TypeLayout", -1,
                        ]
                    }};
                    paramsDataCloud.success = function (resultData) {
                        let jsonObj = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                        let jsonData;
                        if (jsonObj.data && jsonObj.data.length > 0) jsonData = jsonObj.data[0][0];
                        if (jsonData && jsonData.Html) {
                            resolve(jsonData.Html);
                        } else {
                            reject("htmlGet attribute not found");
                        }
                    };
                    paramsDataCloud.error = function (xhr, status, error) {
                        reject("AJAX error: " + status + " - " + error);
                    };
                    AjaxHPAParadise(paramsDataCloud);
                }
            };

            if (resolvedFromCache) {
                checkAndFetchServer(); // Chạy ngầm 0ms delay
            } else {
                await checkAndFetchServer();
            }
        } catch (err) {
            reject(err);
        }
    });
}
  function ChangeZIndexWindow(newWindow){

               // Assign events for drag and long-click on the window header
            const header = newWindow;
            let offsetX, offsetY;
            const longClickDuration = 500; // Time in milliseconds for a long click
            let longClickTimeout;

            // Function to bring the window to the front
            function bringToFront() {
                newWindow.style.zIndex = 1000;
                resetOtherZIndexes(newWindow);
            }

            // Reset z-index for other windows
            function resetOtherZIndexes(activeWindow) {
                const windows = document.querySelectorAll(''.window'');
                windows.forEach(win => {
                    if (win !== activeWindow) {
                        win.style.zIndex = 11;
                    }
                });
            }

            // Click and long click event
            header.addEventListener(''mousedown'', (e) => {
  // Start long click timer
                longClickTimeout = setTimeout(bringToFront, longClickDuration);

                // Store offset for dragging
                offsetX = e.clientX - newWindow.getBoundingClientRect().left;
                offsetY = e.clientY - newWindow.getBoundingClientRect().top;

                // Bring window to front on mouse down
                bringToFront();

                // Add mousemove and mouseup listeners
                document.addEventListener(''mousemove'', mouseMoveHandler);
                document.addEventListener(''mouseup'', mouseUpHandler);
            });

            function mouseMoveHandler(e) {
                newWindow.style.left = `${e.clientX - offsetX}px`;
                newWindow.style.top = `${e.clientY - offsetY}px`;
            }

            function mouseUpHandler() {
                // Clear the long click timer
                clearTimeout(longClickTimeout);

                // Reset z-index for other windows
                resetOtherZIndexes(newWindow);

                // Remove mousemove and mouseup listeners
                document.removeEventListener(''mousemove'', mouseMoveHandler);
 document.removeEventListener(''mouseup'', mouseUpHandler);
            }

            // Click event for immediate z-index change
            header.addEventListener(''click'', () => {
                bringToFront();
            });

      }

     // Function to create the Employee window
      function createEmployeeWindow(menuId,menuName,className) {
          // Create the main window div
          let windowDiv = document.createElement(''div'');
          windowDiv.classList.add(''window'', `${menuId}`);

          // Create the window taskbar div
          let taskbarDiv = document.createElement(''div'');
 taskbarDiv.classList.add(''window__taskbar'');

          // Create the taskbar actions div

          let taskbarActionsDiv = document.createElement(''div'');
          taskbarActionsDiv.classList.add(''window__taskbar--actions'');

          // Create the buttons and add them to the actions div
          let closeButton = document.createElement(''button'');
          closeButton.classList.add(`close-${menuId}`);
          taskbarActionsDiv.appendChild(closeButton);

          let backFullButton = document.createElement(''button'');
          backFullButton.classList.add(`backfull-${menuId}`);
          taskbarActionsDiv.appendChild(backFullButton);

          let fullButton = document.createElement(''button'');
          fullButton.classList.add(`full-${menuId}`);
          taskbarActionsDiv.appendChild(fullButton);

          // Add actions div to taskbar div
          taskbarDiv.appendChild(taskbarActionsDiv);

        // Create the taskbar content div
          let taskbarContentDiv = document.createElement(''div'');
          taskbarContentDiv.classList.add(''window__taskbar--content'');

          // Create the h2 element and add it to the content div
          let h2Element = document.createElement(''h2'');
          h2Element.textContent = `${menuName}`;
          taskbarContentDiv.appendChild(h2Element);

          // Add content div to taskbar div
          taskbarDiv.appendChild(taskbarContentDiv);

          // Create the window content div
          let windowContentDiv = document.createElement(''div'');
          windowContentDiv.classList.add(''window_content'');
    if(className){
    console.log(`
   https://paradisehrm.com/Beta/hpamasterdata/datasetting?tablename=${className}`);
     fetchHtmlString(`
   https://paradisehrm.com/Beta/hpamasterdata/datasetting?tablename=${className}`)
     .then(htmlString => {
    // Log or use the returned HTML string
    const windowContentDiv = document.querySelector(`.${menuId} .window_content`);
    if (windowContentDiv) {
      $(windowContentDiv).html(htmlString);

    } else {
      console.error(''No element found with the class "window_content".'');
    }

    // Optionally, insert it into the DOM
    //document.body.innerHTML += htmlString;
     })
     .catch(error => {
    console.error(''Error fetching HTML:'', error);
     });
    }


          // Add taskbar div and content div to the main window div
          windowDiv.appendChild(taskbarDiv);
          windowDiv.appendChild(windowContentDiv);

          return windowDiv;
      }

      // Function to insert the Employee window into the container and assign events
      function insertEmployeeWindow(menuId,menuName,className,param=``) {
   if(className){
  addNewTab(menuId,menuName,className,param);
  //document.querySelector(`#point-${menuId}`).style.display = ''block'';
   }
    return;
        let existingWindow = document.querySelector(`.container__Window .${menuId}`);
        if(!existingWindow){
          // Find the container div
          let containerWindowDiv = document.querySelector(''.container__Window'');

          // Create the window structure and insert it into the container
          let newWindow = createEmployeeWindow(menuId,menuName,className);
          containerWindowDiv.appendChild(newWindow);

 // Terminal App object
          const terminalApp = {
              window: newWindow,
              full: newWindow.querySelector(`.full-${menuId}`),
              close: newWindow.querySelector(`.close-${menuId}`),
        backfull: newWindow.querySelector(`.backfull-${menuId}`),
              point: document.querySelector("#point-terminal"),  // assuming this already exists
              content: newWindow.querySelector(".window_content"),
          taskbar: newWindow.querySelector(".window__taskbar"),
  opening: document.querySelector(`.open-${menuId}`) // assuming this already exists
          };

          // Make the window draggable
          $(function () {
 //    $(newWindow).draggable();
  });




 $(''.modal-dialog'').draggable({
                handle: ".modal-header",
                cursor: "move"
            });




 // Assign event listeners to the buttons
          // terminalApp.opening.addEventListener("click", () =>
          //     open_window(terminalApp.window, terminalApp.point, terminalApp.app_name)
          // );
    terminalApp.taskbar.addEventListener("dblclick", () => {
   if(isMinimized(terminalApp.window))
   {
    handleFullScreen(terminalApp.window);
   }else{
    handleMinimize(terminalApp.window);
   }
   });
          terminalApp.close.addEventListener("click", () =>{
      document.querySelector(`#point-${menuId}`).style.display = ''none'';
      containerWindowDiv.removeChild(terminalApp.window);
       if(currentAppIdOpen.has(menuId)){
      currentSelectedMenu = menuId;
                  //currentAppIdOpen.clear();
    }
    }
          );
          terminalApp.backfull.addEventListener("click", () =>
              handleHide(terminalApp.window)
          );
         terminalApp.full.addEventListener("click", () => {
            if(isMinimized(terminalApp.window))
            {
              handleFullScreen(terminalApp.window);
            }else{
              handleMinimize(terminalApp.window);
            }
          }

          );

   // ChangeZIndexWindow(newWindow);
        }
      }
</script>

<script>
$(".menu > ul > li").click(function(e){
				// remove active from already active
				$(this).siblings().removeClass("active");
				// add active to clicked
				$(this).toggleClass("active");
				// if has sub menu open it
				$(this).find("ul").slideToggle();
				// close other sub menu if any open
				$(this).siblings().find("ul").slideUp();
				// remove active class of sub menu items
				$(this).siblings().find("ul").find("li").removeClass("active");
			});

			$(".menu-button").click(function(){
				$(".sidebar").toggleClass("active");
			});
</script>

<script>
var tabHistory = window.tabHistory || [];
    // Lắng nghe sự kiện chuyển tab của bootstrap để lưu lại lịch sử
    $(document).on(''shown.bs.tab'', ''button[data-bs-toggle="tab"], a[data-bs-toggle="tab"]'', function (e) {
        let tabId = $(e.target).attr("id");
        if (tabId) {
            // Xóa tab khỏi vị trí cũ và đẩy lên vị trí mới nhất (cuối mảng)
            tabHistory = tabHistory.filter(id => id !== tabId);
            tabHistory.push(tabId);
        }
    });

    function onTabClick(menu_id){
    highLightApp(menu_id);
    const appToAdd = findAppById(menu_id);
    OpenFormContent(appToAdd.className);
    const existsInDock = appsDock.slice(0, secondHrElement).some(app => app.id === appToAdd.id);
    load_tab();

    if(existsInDock) {

    return;}
     const appIcon = document.querySelector(`.dock .${menu_id}`);
     if(!appIcon){ ChangePositionRecent(menu_id);  document.querySelector(`#point-${appToAdd.id}`).style.display = ''block'';}
     else{

      const appsDockContainer2 = document.querySelector(''.dock'');
     if(appIcon !== appsDockContainer2.children[secondHrElement+2]){

     appsDockContainer2.insertBefore(appIcon, appsDockContainer2.children[secondHrElement+2]);
     appsDock = appsDock.filter(app => app.id !== appToAdd.id);
     appsDock.splice(secondHrElement,0,appToAdd);
     updateStyleDock();
     }
      //const DockOrder = appsDock.map(app => app.id);
      //const arrayString = ''[`'' + DockOrder.map(item => item).join(''`, `'') + ''`]'';
      //UpdateLayOutApi(''DockOrder'', arrayString);
      UpdateDockOrderApp();
    }

    }
    function getTabCount() {
     return $(''#tabList .nav-item'').length - 1;
    }
    function load_tab() {
    // Kiểm tra xem có tab nào đang active trong #EmployeeProfile không
    const activeTab = document.querySelector("#EmployeeProfile .tab-pane.active");
    const activeNav = document.querySelector("#EmployeeProfile .nav-link.active");

    if (!activeTab || !activeNav) {

        const firstTab = document.querySelector("#EmployeeProfile .tab-pane");
        const firstNav = document.querySelector("#EmployeeProfile .nav-link");

        if (firstTab) {
            firstTab.classList.add("active", "show");
        }
        if (firstNav) {
            firstNav.classList.add("active");
            firstNav.setAttribute("aria-selected", "true");
        }
    }
}


    function OpenTabs(){
      const lp = window.launchpad || (typeof launchpad !== "undefined" ? launchpad : null);
      if (lp && lp.window && lp.window.style) {
        lp.window.style.display = "none";
      } else {
        const lpElem = document.querySelector(".launchpad") || document.getElementById("launchpad");
        if (lpElem) lpElem.style.display = "none";
      }
      const masterTabs = document.querySelector(".master-tabs");
      if (masterTabs) masterTabs.style.display = "block";
      const homeSidebar = document.querySelector(".home-sidebar");
      if (homeSidebar) homeSidebar.style.display = "block";

      if (typeof insertSmallTextDockStyle === "function") insertSmallTextDockStyle();
    }

    function CloseTabs(){
      const masterTabs = document.querySelector(".master-tabs");
      if (masterTabs) masterTabs.style.display = "none";
      const homeSidebar = document.querySelector(".home-sidebar");
      if (homeSidebar) homeSidebar.style.display = "none";

      if (typeof removeSmallTextDockStyle === "function") removeSmallTextDockStyle();
    }

      //Hiếu: hàm mở tab
      function addNewTab(menuId,menuName,className,param = ``) {
        OpenTabs();
        // **1. Check if the tab already exists**
     if (!$(''#dynamic-tab-'' + menuId).length && $(''#dynamic-pane-'' + menuId).length) {

      const tabId = `dynamic-tab-${menuId}`;
      const paneId = `dynamic-pane-${menuId}`;
      //Hiếu: gọi hàm modalsetting

       const tabNavItem = `
       <li class="nav-item" role="presentation" id="tab-${menuId}">
      <button
        class="nav-link"
        id="${tabId}"
        data-bs-toggle="tab"
        data-bs-target="#${paneId}"
        type="button"
        role="tab"
        aria-controls="${paneId}"
        aria-selected="false"
        onclick="onTabClick(''${menuId}'')"
      >
         ${menuName}
        <span class="ms-1" onclick="removeTab(''${menuId}'',''${menuName}'')"><i class="bi bi-x-lg text-secondary"></i></span>
      </button>
       </li>
     `;
     $(''#tabList'').prepend(tabNavItem);
     addRightClickEventForTab(menuId,menuName);
      currentOverflowTab = currentOverflowTab.filter(item => item.id !== menuId);
      deleteListItemByHref(`#tab-${menuId}`);
      updateTabs();
     }

     if ($(''#dynamic-tab-'' + menuId).length) {
       // Tab exists, activate it
       const existingTab = new bootstrap.Tab(document.getElementById(`dynamic-tab-${menuId}`));
       existingTab.show();

       // Kiểm tra version ngầm giống Mobile khi mở lại tab
       if (className && typeof loadLiveData === "function") {
           loadLiveData(className, `dynamic-pane-${menuId}`, param);
       }

       return; // Exit the function
     }


     const tabId = `dynamic-tab-${menuId}`;
     const paneId = `dynamic-pane-${menuId}`;

     const tabNavItem = `
       <li class="nav-item" role="presentation" id="tab-${menuId}">
      <button
        class="nav-link"
        id="${tabId}"
        data-bs-toggle="tab"
        data-bs-target="#${paneId}"
        type="button"
        role="tab"
        aria-controls="${paneId}"
        aria-selected="false"
        onclick="onTabClick(''${menuId}'')"
      >
       <div>
         ${menuName}
        <span class="ms-1" onclick="removeTab(''${menuId}'',''${menuName}'')"><i class="bi bi-x-lg text-secondary"></i></span>
       </div>
      </button>
       </li>
     `;
     const tabScrollPositions = {};

     const tabContentPane = `
       <div
      class="tab-pane fade overflow-auto position-relative"
      id="${paneId}"
      role="tabpanel"
      aria-labelledby="${tabId}">

      <button class="btn btn-success rounded-circle p-1" id="backToTop-${paneId}" title="Back to Top">
        <i class="fas fa-arrow-up"></i>
      </button>
       </div>
     `;


     // Append the new tab and content
     $(''#tabList'').prepend(tabNavItem);
     $(''#tabContent'').prepend(tabContentPane);

     const backToTopCSS = `
       <style>
      #backToTop-${paneId} {
        display: none;
        position: fixed;
        bottom: 20px;
        right: 18px;
        z-index: 100;
        cursor: pointer;
        width: 50px;
        height: 50px;
        font-size: 25px;
         display: none;
        align-items: center;
        justify-content: center;
      }
       </style>
     `;

     // Append the CSS to head
     $("head").append(backToTopCSS);

     $(`#${paneId}`).on("scroll", function () {
       const scrollPos = $(this).scrollTop();
       tabScrollPositions[paneId] = scrollPos;
       if (scrollPos > 200) {
      $(`#backToTop-${paneId}`).fadeIn();
       } else {
      $(`#backToTop-${paneId}`).fadeOut();
       }
     });


     $(`#backToTop-${paneId}`).on("click", function () {
       $(`#${paneId}`).animate({ scrollTop: 0 }, "smooth");
     });
     $(''a[data-bs-toggle="tab"]'').on("shown.bs.tab", function (e) {
       const targetTabId = $(e.target).attr("href").substring(1);

       const savedScrollPos = tabScrollPositions[targetTabId] || 0;
       $(`#${targetTabId}`).scrollTop(savedScrollPos);

       $(`#backToTop-${targetTabId}`).hide();
     });
     addRightClickEventForTab(menuId,menuName);
     // Activate the new tab
     const newTab = new bootstrap.Tab(document.querySelector(`#${tabId}`));
     newTab.show();
     updateTabs();
     // Load live data into the new tab pane
     loadLiveData(className, paneId, param);
     createModalSetting(menuId, menuName, className);
     //Hiếu: thêm cảnh báo thiếu dữ liệu khi có chứa (*)
      let checkExist = setInterval(() => {
      let element = document.getElementById(className);
      let maxAttempts = 10;
      let attempts = 0;
      //Hiếu: phòng trường hợp form load lâu sẽ cho nó check trong 10s để thêm validation
      if (element) {
       validateRequiredFields(className);
       clearInterval(checkExist);
      } else {
       attempts++;
       if (attempts >= maxAttempts) {
        clearInterval(checkExist);

       }
      }
     }, 500);


      }

 function validateRequiredFields(menuId) {
    $(`#${menuId} *`).each(function () {
       let element = $(this);
        let text = element.text().trim();

        let computedStyle = window.getComputedStyle(this, "::after");






        let afterContent = computedStyle ? computedStyle.content.replace(/[''"]/g, "").trim() : "";
        if (/\(\*\)$/.test(text) || /\(\*\)$/.test(afterContent)) {
            let field = element.next("input, select, textarea");
            if (field.length === 0) {
                field = element.closest("div, span, p, label").find("input, select, textarea").first();
            }

            if (field.length) {
                field.on("blur change", function () {
                    let value = $(this).val()?.trim();

                    $(this).next(".error-message-beta").remove();

                    if ($(this).is("select")) {
                        if (value === "-1") {
                            $(this).after(`<div class="error-message-beta text-danger">Vui lòng chọn giá trị !!!</div>`);
                      }
                    } else {
                        if (!value) {
                            $(this).after(`<div class="error-message-beta text-danger">Giá trị không được để trống !!!</div>`);
                        }
                    }
                });
            }
        }
    });
}




      var currentTabIdSelected = null;
      // Function to add a right-click event listener to a specific tab element by menuId
    function addRightClickEventForTab(menuId,menuName) {
     // Select the new tab element by its ID
     const newTabElement = document.getElementById(`tab-${menuId}`);

     if (newTabElement) {
      // Add right-click (contextmenu) event listener
      newTabElement.addEventListener(''contextmenu'', function (event) {
        currentTabIdSelected = menuId;
        rightClickTab(event,menuId,menuName);
      });
     } else {

     }
    }

      var tabToDelete = null;  // Store the tab ID to delete
      // Function to remove a tab
      window.removeTab = function(tabNum,menuName) {
     var textNotification,textConfirm,textCancel
     if(LanguageID === "VN"){
      textNotification = `<p class=fs-6>Xác nhận đóng tab "${menuName}"?</p>`;
      textConfirm = "Đóng"
      textCancel = "Ở lại"
     }else if(LanguageID === "EN"){
      textNotification = `<p class=fs-6>Confirm close of "${menuName}" tab?</p>`;
      textConfirm = "Close"
      textCancel = "Cancel"
     }
     if (0 == 1){
         showConfirmDeleteModal(textNotification,textConfirm,textCancel)
           .then((result) => {
              const listDelete = [tabNum];

                   CloseTab(listDelete);
              if(getTabCount() === 0){
               CloseTabs();
                $("#dashboard_main").show();
                $(".master-tabs, .home-sidebar").hide();
                $("#launchpad").hide();
              }
           })
           .catch((error) => {

           });
     }else{
      const listDelete = [tabNum];

               CloseTab(listDelete);
          if(getTabCount() === 0){
           CloseTabs();
            $("#dashboard_main").show();
            $(".master-tabs, .home-sidebar").hide();
            $("#launchpad").hide();
          }
     }
      }

      // Function to load live data into the tab content
      async function loadLiveData(className, paneId, param = ``, isPopup = false) {
    // 🛡️ BẢO HIỂM: Nếu có chỗ nào vô tình truyền theo kiểu cũ (paneId trước, className sau) thì tự động đảo lại
    if (typeof className === "string" && typeof paneId === "string") {
        if (paneId.endsWith("_html") || className.startsWith("dynamic-") || className.startsWith("#") || className.startsWith("popup") || className.startsWith("comp-")) {
            let temp = className;
            className = paneId;
            paneId = temp;
        }
    }
    if (typeof paneId === "string" && paneId.startsWith("#")) {
        paneId = paneId.substring(1);
    }

    let obj = {};
    if (param && typeof param === "object") {
        obj = param;
    } else if (param) {
        let jsonString = /{.*}/.test(param) ? param : "{" + param + "}";
        try { obj = JSON.parse(jsonString); } catch(e) {}
    }
    obj.isWeb = window.isWeb || 1;
    obj.LanguageID = window.LanguageID || "VN";
    obj.LoginID = window.UserID || window.LoginID;
    window[className + "_param"] = obj;

    let appAddress = window.APPLICATION_ADDRESS || "";
    let serverName = appAddress.replace(/\//g, "") || "root";
    let TableName = className.replace("_html", "");
    let lang = window.LanguageID || "VN";
    let cacheKeyLink = serverName + "_link_" + TableName;
    let oldUrlFetch = localStorage.getItem(cacheKeyLink) || "";

    if (oldUrlFetch && oldUrlFetch.indexOf(appAddress) === -1) {
        oldUrlFetch = "";
    }

    let renderedFromCache = false;

    // BƯỚC 1: Lấy từ Browser Disk Cache ngay lập tức (0ms delay)
    if (window.EnableInstantCacheView === 1 && oldUrlFetch) {
        try {
            let responseOld = await $.ajax({ url: oldUrlFetch, cache: true, global: false });
            let cachedHtml = "";
            if (typeof responseOld === "string") {
                try { cachedHtml = JSON.parse(responseOld).data[0][0].bytes; } catch(e) { cachedHtml = responseOld; }
            } else if (responseOld?.data?.[0]?.[0]?.bytes) {
                cachedHtml = responseOld.data[0][0].bytes;
            }

            if (cachedHtml) {
                let $target = $(`#${paneId}`);
                if ($target.length) {
                    $target.html(cachedHtml);
                    renderedFromCache = true;
                    if (!isPopup) {
                        if (typeof observeChildAddition === "function") observeChildAddition($target[0]);
                        if (typeof validateRequiredFields === "function") validateRequiredFields(className);
                    }
                    setTimeout(() => { requestAnimationFrame(() => window.dispatchEvent(new Event("resize"))); }, 50);
                }
            }
        } catch(e) {}
    }

    // BƯỚC 2: Check Version ngầm với Server (Stale-While-Revalidate)
    const checkAndFetchServer = async () => {
        if (navigator.onLine === false) return; // NẾU TẮT MẠNG -> GIỮ NGUYÊN CACHE HIỆN TẠI 100%
        try {
            let currentVersion = "-1";
            try {
                let verData = await AjaxHPAParadiseAsync({
                    showLoading: false,
                    data: {
                        name: "paradisepublic",
                        param: ["paradisepublic", TableName, "LanguageID", lang, "ParadiseVersion", "-1"]
                    }
                });
                let parsed = typeof verData === "string" ? JSON.parse(verData) : verData;
                if (parsed?.data?.[0]?.[0]) currentVersion = parsed.data[0][0].ParadiseVersion;
            } catch(e) {
                return; // Mất mạng hoặc lỗi kết nối -> Giữ nguyên UI đã render từ cache
            }

            // CHỈ KHI CÓ THAY ĐỔI VERSION THỰC SỰ TRÊN DATABASE MỚI TẢI VÀ RENDER LẠI
            if (currentVersion && currentVersion !== "-1") {
                let baseUrl = appAddress.startsWith("http") ? "" : window.location.origin;
                let newUrlFetch = `${baseUrl}${appAddress}/api/hpa/paradise?&name=paradisepublic&param=["paradisepublic","${TableName}","LanguageID","${lang}","ParadiseVersion",${currentVersion}]&user=paradisepublic&password=3C9909AFEC25354D551DAE21590BB26E38D53F2173B8D3DC3EEE4C047E7AB1C1EB8B85103E3BE7BA613B31BB5C9C36214DC9F14A42FD7A2FDB84856BCA5C44C2&_cb=${lang}_${currentVersion}`;

                if (newUrlFetch !== oldUrlFetch || !renderedFromCache) {
                    try {
                        let response = await $.ajax({ url: newUrlFetch, cache: true, global: false });
                        let newHtmlContent = "";
                        if (typeof response === "string") {
                            try { newHtmlContent = JSON.parse(response).data[0][0].bytes; } catch (e) { newHtmlContent = response; }
                        } else if (response?.data?.[0]?.[0]?.bytes) {
                            newHtmlContent = response.data[0][0].bytes;
                        }

                        if (newHtmlContent) {
                            try { localStorage.setItem(cacheKeyLink, newUrlFetch); } catch(e) {}

                            let $target = $(`#${paneId}`);
                            if ($target.length) {
                                $target.html(newHtmlContent);
                                if (!isPopup) {
                                    if (typeof observeChildAddition === "function") observeChildAddition($target[0]);
                                    if (typeof validateRequiredFields === "function") validateRequiredFields(className);
                                }
                                setTimeout(() => { requestAnimationFrame(() => window.dispatchEvent(new Event("resize"))); }, 50);
                            }
                        }
                    } catch(e) {}
                }
            }
        } catch(e) {}

        // Fallback datasetting CHỈ KHI CHƯA CÓ BẢN CACHE NÀO VÀ ĐANG ONLINE
        if (!renderedFromCache && navigator.onLine !== false) {
            let fallbackUrl = `${appAddress}/hpamasterdata/datasetting?tablename=${className}&paradise_hrm=${encodeURIComponent(JSON.stringify({ ParamControls: obj }))}`;
            try {
                let html = await fetchHtmlString(fallbackUrl);
                if (html) {
                    let $target = $(`#${paneId}`);
                    if ($target.length) {
                        $target.html(html);
                        if (!isPopup) {
                            if (typeof observeChildAddition === "function") observeChildAddition($target[0]);
                            if (typeof validateRequiredFields === "function") validateRequiredFields(className);
                        }
                    }
                }
            } catch(e) {}
        }
    };

    if (renderedFromCache) {
        checkAndFetchServer(); // Chạy ngầm 0ms delay
    } else {
        await checkAndFetchServer();
    }
}

// 🌐 Tạo alias loadCachedComponent đồng nhất với Mobile (className, paneId)
async function loadCachedComponent(componentName, containerId, renderImmediately = true) {
    return loadLiveData(componentName, containerId, ``, false);
}

      // Event listener for the Add New Tab button
      // $(''#addTab'').click(function() {
     // addNewTab();
     //  });

      // Initialize with one tab
    // addNewTab();

     function updateModalButtonText(modalElement, selector, text, defaultText) {
      console.log(text,defaultText)
      if (!modalElement) {
       console.error("modalElement không tồn tại");
       return;
      }

      let targetElement = modalElement.querySelector(selector);
      if (!targetElement) {
       console.error(`Không tìm thấy phần tử với selector: ${selector}`);
       return;
      }

      targetElement.innerText = text || defaultText;
     }


    function updateModalButtonColor(modalElement,selector,color,defaultColor){
     var $element =$(modalElement).find(selector)
     if($element.length){
      $element.css("background-color",color || defaultColor)
      $element.css("border-color",color || defaultColor)
     }
    }

    function showConfirmDeleteModal(itemName, textConfirm, textReject) {
      return new Promise((resolve, reject) => {
     if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
     const modalElement = document.getElementById(''confirmDeleteModal'');

     if(LanguageID === "VN"){
      $("#confirmDeleteModal .modal-title").text("Thông báo");
     }else if(LanguageID === "EN"){
      $("#confirmDeleteModal .modal-title").text("Notification");

     }
     const modal = new bootstrap.Modal(modalElement);

     modalElement.querySelector(''.modal-body'').innerHTML = itemName;

     updateModalButtonText(modalElement,''.modal-footer #confirmDeleteButton span'', textConfirm, ''Đóng'');
     updateModalButtonText(modalElement,''.modal-footer #cancelButton span'', textReject, ''Ở lại'');

     const handleResult = (isConfirmed) => {
       modal.hide();
       var test = document.getElementById("addEmployeeModal");

       isConfirmed ? resolve("User confirmed deletion.") : reject("User canceled the action.");
     };

     modalElement.querySelector(''#confirmDeleteButton'').addEventListener(''click'', () => handleResult(true), { once: true });
     modalElement.querySelectorAll(''[data-bs-dismiss="modal"]'').forEach(button =>
       button.addEventListener(''click'', () => handleResult(false), { once: true })
     );
     modalElement.removeAttribute("aria-hidden");
     modal.show();
      });
    }

 function showConfirmationModal(itemContent, textConfirm = "Xác nhận", textReject = "Cancel", onConfirm, colorButton) {
    return new Promise((resolve, reject) => {
        const modalElement = document.getElementById("successModal");
        const modal = new bootstrap.Modal(modalElement, {
            backdrop: "static",
            keyboard: false
  });

       const modalBody = modalElement.querySelector(".modal-success");
        if (typeof itemContent === "string") {
            modalBody.innerHTML = itemContent;
        } else if (itemContent instanceof HTMLElement) {
            modalBody.innerHTML = "";
            modalBody.appendChild(itemContent);
        }

        // Cập nhật nội dung nút
        updateModalButtonText(modalElement, "#successModalButton", textConfirm, "Đóng");
        updateModalButtonText(modalElement, "#cancelButton1", textReject, "Ở lại");

        // Cập nhật màu cho nút

        updateModalButtonColor("#successModalButton", colorButton, "green");

// Gán lại sự kiện click tránh bị lặp
        $("#successModalButton").off("click").on("click", function () {
            console.log("confirm nè");
            if (typeof onConfirm === "function") {
                onConfirm();
            }
            $("#successModal").modal("hide");
            resolve("User confirmed modal.");
        });

        $("#cancelButton1").off("click").on("click", function () {
            console.log("cancel nè");
            $("#successModal").modal("hide");
            reject("User canceled modal.");
        });

        // Thêm sự kiện khi nhấn Enter
        function handleEnterKey(event) {
            if (event.key === "Enter") {
                $("#successModalButton").click(); // Kích hoạt nút xác nhận
            }
        }

        // Gán sự kiện keydown khi mở modal
        modalElement.addEventListener("keydown", handleEnterKey);

        // Xóa sự kiện keydown khi modal đóng để tránh lặp
        modalElement.addEventListener("hidden.bs.modal", function () {
            modalElement.removeEventListener("keydown", handleEnterKey);
        });

        modalElement.removeAttribute("aria-hidden");
        modal.show();
    });
}

function showSuccessModal(content, confirmText = "OK", cancelText = "Hủy", onConfirm = null, onCancel = null) {
    return new Promise((resolve, reject) => {
        const modalElement = document.getElementById("successModal");
        const modal = new bootstrap.Modal(modalElement, {
            backdrop: "static",
            keyboard: false
        });

        const modalBody = modalElement.querySelector(".modal-body");
        if (typeof content === "string") {
            modalBody.innerHTML = content;
        } else if (content instanceof HTMLElement) {
            modalBody.innerHTML = "";
            modalBody.appendChild(content);
        }

        const confirmButton = modalElement.querySelector("#successModalButton");
        const cancelButton = modalElement.querySelector("#cancelButton1");

       confirmButton.textContent = confirmText;
 cancelButton.textContent = cancelText;


        confirmButton.replaceWith(confirmButton.cloneNode(true));
        cancelButton.replaceWith(cancelButton.cloneNode(true));

        const newConfirmButton = modalElement.querySelector("#successModalButton");
        const newCancelButton = modalElement.querySelector("#cancelButton1");

        function closeModal() {
            modal.hide();
            document.body.focus();
        }

        newConfirmButton.addEventListener("click", () => {
            closeModal();
            if (typeof onConfirm === "function") {
                onConfirm();
            }
            resolve("User confirmed success modal.");
        }, { once: true });

        newCancelButton.addEventListener("click", () => {
            closeModal();
            if (typeof onCancel === "function") {
                onCancel();
            }
            reject("User canceled success modal.");
        }, { once: true });
  modalElement.removeAttribute("aria-hidden");
        modal.show();
    });
}


function showNotificationModal(content, confirmText = "OK", confirmColor = "success", onConfirm = null) {
    return new Promise((resolve) => {
   const modalElement = document.getElementById("notificationModal");
        const modal = new bootstrap.Modal(modalElement, {
            backdrop: "static",
  keyboard: false
        });

        // Cập nhật nội dung modal
        const modalBody = modalElement.querySelector(".modal-body");
        if (typeof content === "string") {
 modalBody.innerHTML = content;
        } else if (content instanceof HTMLElement) {
            modalBody.innerHTML = "";
     modalBody.appendChild(content);
        }

        // Cập nhật nút OK
        const confirmButton = modalElement.querySelector("#notificationModalButton");
confirmButton.innerHTML = `<i class="bi bi-check-lg"></i> <span>${confirmText}</span>`;
        confirmButton.className = `btn btn-${confirmColor}`;

        // Xóa sự kiện cũ và thêm sự kiện mới
        confirmButton.replaceWith(confirmButton.cloneNode(true));
        const newConfirmButton = modalElement.querySelector("#notificationModalButton");

        newConfirmButton.addEventListener("click", () => {
            modal.hide();
            if (typeof onConfirm === "function") {
                onConfirm();
            }
            resolve("User confirmed notification modal.");
        }, { once: true });
  modalElement.removeAttribute("aria-hidden");
        modal.show();
    });
}
function showSuccessModalAddNew(content,confirmText = "OK",cancelText = "Hủy",onConfirm = null,onCancel = null,
    confirmBtnStyle = { textColor: "#fff", bgColor: "#198754" },
    cancelBtnStyle = { textColor: "#000", bgColor: "#dee2e6" }
) {
    return new Promise((resolve, reject) => {
        const modalElement = document.getElementById("successModalAddNew");
        const modal = new bootstrap.Modal(modalElement, {
            backdrop: "static",
            keyboard: false
        });

        const modalBody = modalElement.querySelector(".modal-success-addNew");
        if (typeof content === "string") {
            modalBody.innerHTML = content;
        } else if (content instanceof HTMLElement) {
            modalBody.innerHTML = "";
            modalBody.appendChild(content);
        }

        const confirmButton = modalElement.querySelector("#successModalButtonAddNew");
        const cancelButton = modalElement.querySelector("#cancelButton1AddNew");

        confirmButton.textContent = confirmText;
        cancelButton.textContent = cancelText;

        // Clone để gỡ bỏ event cũ
        confirmButton.replaceWith(confirmButton.cloneNode(true));
        cancelButton.replaceWith(cancelButton.cloneNode(true));

        const newConfirmButton = modalElement.querySelector("#successModalButtonAddNew");
        const newCancelButton = modalElement.querySelector("#cancelButton1AddNew");

        // Gán màu sắc cho nút confirm
        newConfirmButton.style.backgroundColor = confirmBtnStyle.bgColor;
        newConfirmButton.style.color = confirmBtnStyle.textColor;
        newConfirmButton.style.border = "none";

        // Gán màu sắc cho nút cancel
        newCancelButton.style.backgroundColor = cancelBtnStyle.bgColor;
        newCancelButton.style.color = cancelBtnStyle.textColor;
        newCancelButton.style.border = "none";

        newConfirmButton.addEventListener("click", () => {
            modal.hide();
            if (typeof onConfirm === "function") {
                onConfirm();
            }
            resolve("User confirmed success modal.");
        }, { once: true });

        newCancelButton.addEventListener("click", () => {
            modal.hide();
            if (typeof onCancel === "function") {
                onCancel();
            }
            reject("User canceled success modal.");
        }, { once: true });

        modal.show();
        modalElement.removeAttribute("aria-hidden");
    });
}


var observer = new MutationObserver(() => {
    $(".modal-dialog").each(function () {
        if (!$(this).data("draggable")) {
            $(this).draggable({
                handle: ".modal-header",
                cursor: "move"
            }).data("draggable", true);
        }
    });
});


observer.observe(document.body, { childList: true, subtree: true });
</script>

<!-- OVERLAY BACKDROP CHO SETTINGS DRAWER -->
<div id="mobileSettingsOverlay"></div>

<!-- CONTAINER MENU CÀI ĐẶT ĐỒNG BỘ MOBILE (NHÚNG TRỰC TIẾP 0MS) -->
<div id="mobileSettingsContainer">
    <div id="dashboard_mobile_Settings_html">
        <div id="mainSettingsDrawer" class="settings-drawer">
            <!-- DRAWER HEADER -->
            <div class="drawer-header">
                <button class="back-btn" id="closeSettingsDrawerBtn" title="%Close%"><i class="bi bi-arrow-left"></i></button>
                <h4 class="drawer-title" id="settingsDrawerTitle">%NavSettings%</h4>
            </div>

            <!-- DRAWER CONTENT -->
            <div class="drawer-content" style="flex-grow: 1; overflow-y: auto; min-height: 0; padding-bottom: 24px;">
                <!-- 1. USER PROFILE CARD -->
                <div class="user-profile-summary shadow-sm">
                    <div class="position-relative me-3">
                        <div class="avatar-circle-settings rounded-circle border border-2 overflow-hidden bg-white shadow-sm position-relative d-flex align-items-center justify-content-center">
                            <img id="settingsUserAvatar" class="user-avatar-img"
                                 data-default-src="data:image/svg+xml;utf8,<svg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22 style=%22background:%23ebf6ff%22><circle cx=%22100%22 cy=%22235%22 r=%22100%22 fill=%22%23a4c3f5%22 stroke=%22%237192c7%22 stroke-width=%226%22/><circle cx=%22100%22 cy=%2276%22 r=%2243%22 fill=%22%23fde69a%22 stroke=%22%23e0b958%22 stroke-width=%226%22/></svg>"
                                 src=""
                                 style="width: 100%; height: 100%; object-fit: cover;"
                                 onerror="this.onerror=null; this.src=this.getAttribute(''data-default-src'');" />
                        </div>
                        <span class="online-status-dot-settings position-absolute rounded-circle border border-2 border-white shadow-sm"></span>
                    </div>
                    <div class="d-flex flex-column justify-content-center flex-grow-1" style="min-width: 0;">
                        <h5 id="settingsUserName" class="fw-bold text-truncate mb-1" style="font-size: 17px; line-height: 1.2;">Xin chào...</h5>
                        <small id="settingsUserCode" class="text-muted text-truncate mb-2" style="font-size: 13px; line-height: 1.2;"></small>
                        <div>
                            <button class="edit-profile-btn" id="btnOpenProfileSettings">
                                <i class="bi bi-pencil"></i> <span id="txtEditProfile">%Edit%</span>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- 2. SETTINGS LIST GROUP 1 -->
                <div class="settings-list shadow-sm">
                    <!-- BẢO MẬT (ĐỔI MẬT KHẨU) -->
                    <div class="option-item" id="btnOpenSecuritySettings">
                        <div class="option-icon"><i class="bi bi-shield-lock"></i></div>
                        <div class="option-text" id="txtSecurityOpt">%Security%</div>
                        <div class="option-arrow"><i class="bi bi-chevron-right"></i></div>
                    </div>

                    <!-- GOOGLE 2FA (MỤC MỚI THEO YÊU CẦU SẾP ĐỒNG BỘ MOBILE + DESKTOP) -->
                    <div class="option-item" id="btnOpenGoogle2FASettings">
                        <div class="option-icon" style="background-color: rgba(16, 185, 129, 0.12); color: #10b981;"><i class="bi bi-shield-check"></i></div>
                        <div class="option-text">Google 2FA</div>
                        <div class="option-arrow"><i class="bi bi-chevron-right"></i></div>
                    </div>

                    <!-- LOẠI NGÔN NGỮ -->
                    <div class="option-item" id="btnOpenLanguageSettings">
                        <div class="option-icon" style="background-color: rgba(59, 130, 246, 0.12); color: #3b82f6;"><i class="bi bi-translate"></i></div>
                        <div class="option-text" id="txtLanguageOpt">%Language%</div>
                        <div class="option-arrow"><i class="bi bi-chevron-right"></i></div>
                    </div>
                </div>

                <!-- 3. SETTINGS LIST GROUP 2 -->
                <div class="settings-list shadow-sm">
                    <div class="option-item" id="btnOpenHelpSettings">
                        <div class="option-icon text-info bg-info bg-opacity-10"><i class="bi bi-question-circle"></i></div>
                        <div class="option-text" id="txtHelpOpt">%HelpSupport%</div>
                        <div class="option-arrow"><i class="bi bi-chevron-right"></i></div>
                    </div>
                </div>

                <!-- 4. SETTINGS LIST GROUP 3 (LOGOUT) -->
                <div class="settings-list shadow-sm">
                    <div class="option-item text-danger-custom" id="settingsLogoutBtn">
                        <div class="option-icon"><i class="bi bi-box-arrow-right"></i></div>
                        <div class="option-text fw-bold" id="txtLogoutOpt">%Logout%</div>
                    </div>
                </div>
            </div>

            <!-- SUBPAGE HOLDER CHO CÁC TRANG CON ĐỘNG (BẢO MẬT, TRỢ GIÚP...) -->
            <div id="SettingsSubPageHolder"></div>

            <!-- DRAWER NGÔN NGỮ ĐỒNG BỘ MOBILE (NHÚNG CỐ ĐỊNH 0MS) -->
            <div id="dashboard_mobile_Settings_LanguageDrawer">
                <div class="drawer-header">
                    <button class="back-btn" id="closeLanguageDrawer" title="%Back%"><i class="bi bi-arrow-left"></i></button>
                    <h4 class="drawer-title" id="languageDrawerTitle">%Language%</h4>
                </div>
                <div class="drawer-content" style="flex-grow: 1; overflow-y: auto; padding: 14px 16px;">
                    <div class="form-section language-list shadow-sm">
                        <div class="language-option selected" data-lang="VN" id="langOption_VN">
                            <div class="d-flex align-items-center">
                                <img src="https://cdn.paradisehrm.com/Image/Flag_of_Vietnam.svg" alt="Tiếng Việt" style="width:32px; height:24px; object-fit:cover;" class="me-3 shadow-sm rounded-1">
                                <span class="fs-6 language-name fw-semibold">Tiếng Việt</span>
                            </div>
                            <i class="bi bi-check-circle-fill check-icon"></i>
                        </div>

                        <div class="language-option" data-lang="EN" id="langOption_EN">
                            <div class="d-flex align-items-center">
                                <img src="https://cdn.paradisehrm.com/Image/Flag_of_the_United_Kingdom_%281-2%29.svg" alt="English" style="width:32px; height:24px; object-fit:cover;" class="me-3 shadow-sm rounded-1">
                                <span class="fs-6 language-name fw-semibold">English</span>
                            </div>
                            <i class="bi bi-check-circle-fill check-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* OVERLAY & DRAWER CÀI ĐẶT ĐỒNG BỘ MOBILE TRÊN DESKTOP */
#mobileSettingsOverlay {
    position: fixed;
    inset: 0;
    top: 59px;
    background: rgba(0, 0, 0, 0.45);
    backdrop-filter: blur(2px);
    z-index: 19990;
    display: none;
    opacity: 0;
    transition: opacity 0.25s ease;
}
#mobileSettingsOverlay.show {
    display: block;
    opacity: 1;
}
#mobileSettingsContainer,
#mobileNotificationContainer,
#mobileChangePWContainer,
#mobileHelpContainer {
    position: relative;
    z-index: 20000 !important;
}
/* BỎ HOÀN TOÀN BOX SHADOW CỦA CẢ THÔNG BÁO VÀ CÀI ĐẶT - TRÁNH LỖI VỆT MỜ KẸT LẠI MÉP MÀN HÌNH */
#dashboard_mobile_Settings_html .settings-drawer,
.settings-drawer,
#mainSettingsDrawer,
#dashboard_mobile_Notification_html .notification-drawer,
.notification-drawer,
#mainNotificationDrawer {
    box-shadow: none !important;
}
body.dark-mode #dashboard_mobile_Settings_html .settings-drawer,
body.dark-mode .settings-drawer,
body.dark-mode #mainSettingsDrawer,
body.dark-mode #dashboard_mobile_Notification_html .notification-drawer,
body.dark-mode .notification-drawer,
body.dark-mode #mainNotificationDrawer {
    box-shadow: none !important;
}

/* ĐẢM BẢO KHI ĐÓNG THÌ ẨN HOÀN TOÀN (KHÔNG TỒN TẠI TÀN DƯ PIXEL BÓNG HOẶC VIỀN DÍNH MÉP PHẢI) */
#dashboard_mobile_Settings_html .settings-drawer:not(.open),
.settings-drawer:not(.open),
#mainSettingsDrawer:not(.open),
#dashboard_mobile_Notification_html .notification-drawer:not(.open),
.notification-drawer:not(.open),
#mainNotificationDrawer:not(.open) {
    visibility: hidden !important;
    pointer-events: none !important;
    box-shadow: none !important;
}
#dashboard_mobile_Settings_html .settings-drawer.open,
.settings-drawer.open,
#mainSettingsDrawer.open,
#dashboard_mobile_Notification_html .notification-drawer.open,
.notification-drawer.open,
#mainNotificationDrawer.open {
    visibility: visible !important;
    pointer-events: auto !important;
    box-shadow: none !important;
}

/* ĐẢM BẢO Z-INDEX MENU CÀI ĐẶT (20000) NHỎ HƠN uiManager.showAlert (30000) */
#dashboard_mobile_Settings_html .settings-drawer {
    position: fixed;
    top: 59px;
    right: 0;
    width: 440px;
    height: calc(100vh - 59px);
    height: calc(100dvh - 59px);
    z-index: 20000 !important;
    transform: translateX(100%);
    transition: transform 0.28s cubic-bezier(0.25, 0.8, 0.25, 1);
    background-color: var(--paradise-bg-0, #f8fafc);
    border-left: 1px solid var(--paradise-border-color, rgba(0,0,0,0.08));
    box-shadow: none !important;
    display: flex;
    flex-direction: column;
}
/* MODAL GOOGLE 2FA NỔI TRÊN MENU CÀI ĐẶT */
.dx-popup-google-2fa,
.dx-overlay-wrapper.dx-popup-google-2fa {
    z-index: 25000 !important;
}
#dashboard_mobile_Settings_html .settings-drawer.open {
    transform: translateX(0);
}
body.dark-mode #dashboard_mobile_Settings_html .settings-drawer {
    background-color: var(--paradise-bg-0, #0f172a);
    border-left-color: rgba(255,255,255,0.08);
    box-shadow: none !important;
}
#dashboard_mobile_Settings_html .drawer-header {
    background-color: var(--paradise-bg-1, #ffffff);
    padding: 16px;
    display: flex;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 10;
    border-bottom: 1px solid var(--paradise-border-color, rgba(0,0,0,0.05));
}
body.dark-mode #dashboard_mobile_Settings_html .drawer-header {
    background-color: var(--paradise-bg-1, #1e293b);
}
#dashboard_mobile_Settings_html .drawer-header .back-btn {
    background: transparent;
    border: none;
    color: var(--paradise-text-title, #1e293b);
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0 10px;
}
body.dark-mode #dashboard_mobile_Settings_html .drawer-header .back-btn {
    color: #f8fafc;
}
#dashboard_mobile_Settings_html .drawer-header .drawer-title {
    flex-grow: 1;
    text-align: center;
    margin: 0;
    font-weight: 700;
    font-size: 18px;
    color: var(--paradise-text-title, #1e293b);
    padding-right: 30px;
}
body.dark-mode #dashboard_mobile_Settings_html .drawer-header .drawer-title {
    color: #f8fafc;
}
#dashboard_mobile_Settings_html .user-profile-summary {
    background-color: var(--paradise-bg-1, #ffffff);
    padding: 18px 20px;
    display: flex;
    align-items: center;
    margin: 16px 16px 20px 16px;
    border-radius: 18px;
    border: 1px solid var(--paradise-border-color, rgba(0, 0, 0, 0.05));
}
body.dark-mode #dashboard_mobile_Settings_html .user-profile-summary {
    background-color: var(--paradise-bg-1, #1e293b);
    border-color: rgba(255,255,255,0.08);
}
#dashboard_mobile_Settings_html .avatar-circle-settings {
    width: 60px;
    height: 60px;
}
#dashboard_mobile_Settings_html .online-status-dot-settings {
    width: 14px;
    height: 14px;
    background-color: #22c55e;
    bottom: 0px;
    right: 0px;
}
#dashboard_mobile_Settings_html .edit-profile-btn {
    background-color: rgba(34, 171, 63, 0.12);
    border: none;
    border-radius: 20px;
    padding: 6px 14px;
    font-size: 12px;
    font-weight: 600;
    color: #16a34a;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    transition: all 0.2s ease;
}
#dashboard_mobile_Settings_html .edit-profile-btn:hover {
    background-color: #16a34a;
    color: #ffffff;
}
#dashboard_mobile_Settings_html .settings-list {
    background-color: var(--paradise-bg-1, #ffffff);
    padding: 0;
    margin: 0 16px 16px 16px;
    border-radius: 16px;
    border: 1px solid var(--paradise-border-color, rgba(0, 0, 0, 0.05));
    overflow: hidden;
}
body.dark-mode #dashboard_mobile_Settings_html .settings-list {
    background-color: var(--paradise-bg-1, #1e293b);
    border-color: rgba(255,255,255,0.08);
}
#dashboard_mobile_Settings_html .option-item {
    display: flex;
    align-items: center;
    padding: 15px 16px;
    position: relative;
    cursor: pointer;
    background-color: transparent;
    transition: background-color 0.2s ease;
}
#dashboard_mobile_Settings_html .option-item:hover {
    background-color: rgba(0, 0, 0, 0.03);
}
body.dark-mode #dashboard_mobile_Settings_html .option-item:hover {
    background-color: rgba(255, 255, 255, 0.04);
}
#dashboard_mobile_Settings_html .option-item:not(:last-child)::after {
    content: "";
    position: absolute;
    bottom: 0;
    left: 68px;
    right: 0;
    height: 1px;
    background-color: var(--paradise-border-color, rgba(0,0,0,0.05));
}
#dashboard_mobile_Settings_html .option-icon {
    width: 40px;
    height: 40px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(34, 171, 63, 0.12);
    color: #16a34a;
    font-size: 1.25rem;
    margin-right: 14px;
    flex-shrink: 0;
}
#dashboard_mobile_Settings_html .option-text {
    flex-grow: 1;
    font-size: 15px;
    font-weight: 600;
    color: var(--paradise-text-title, #1e293b);
}
body.dark-mode #dashboard_mobile_Settings_html .option-text {
    color: #f1f5f9;
}
#dashboard_mobile_Settings_html .option-arrow {
    color: var(--paradise-text-muted, #94a3b8);
    font-size: 1.05rem;
}
#dashboard_mobile_Settings_html .text-danger-custom .option-text,
#dashboard_mobile_Settings_html .text-danger-custom .option-icon {
    color: #ef4444 !important;
}
#dashboard_mobile_Settings_html .text-danger-custom .option-icon {
    background-color: rgba(239, 68, 68, 0.1) !important;
}
#SettingsSubPageHolder {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: 200;
}
#dashboard_mobile_Settings_LanguageDrawer {
    position: absolute !important;
    inset: 0 !important;
    width: 100% !important;
    height: 100% !important;
    top: 0 !important;
    left: 0 !important;
    right: 0 !important;
    bottom: 0 !important;
    background-color: var(--paradise-card-bg, #181c24) !important;
    z-index: 250 !important;
    display: flex !important;
    flex-direction: column !important;
    transform: translateX(100%);
    transition: transform 0.28s cubic-bezier(0.25, 0.8, 0.25, 1);
    pointer-events: none;
}
#dashboard_mobile_Settings_LanguageDrawer.open {
    transform: translateX(0) !important;
    pointer-events: auto !important;
}
#dashboard_mobile_Settings_LanguageDrawer .drawer-header {
    background-color: var(--paradise-card-bg, #1e293b);
    padding: 16px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid var(--paradise-border-color, rgba(255, 255, 255, 0.08));
}
#dashboard_mobile_Settings_LanguageDrawer .back-btn {
    background: transparent;
    border: none;
    color: var(--paradise-text-body, #f1f5f9);
    font-size: 1.35rem;
    cursor: pointer;
    padding: 0 8px;
    display: flex;
    align-items: center;
    justify-content: center;
}
#dashboard_mobile_Settings_LanguageDrawer .drawer-title {
    flex-grow: 1;
    text-align: center;
    margin: 0;
    font-weight: 700;
    font-size: 17px;
    color: var(--paradise-text-body, #f1f5f9);
    padding-right: 32px;
}
#dashboard_mobile_Settings_LanguageDrawer .form-section {
    background-color: var(--paradise-card-bg, #1e293b);
    padding: 6px 14px;
    margin-top: 14px;
    border-radius: 12px;
    border: 1px solid var(--paradise-border-color, rgba(255, 255, 255, 0.08));
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}
#dashboard_mobile_Settings_LanguageDrawer .language-option {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 10px;
    border-bottom: 1px solid var(--paradise-border-color, rgba(255, 255, 255, 0.08));
    cursor: pointer;
    border-radius: 8px;
    transition: background 0.15s ease;
    color: var(--paradise-text-body, #f1f5f9);
}
#dashboard_mobile_Settings_LanguageDrawer .language-option:last-child {
    border-bottom: none;
}
#dashboard_mobile_Settings_LanguageDrawer .language-option:hover {
    background-color: rgba(255, 255, 255, 0.05);
}
#dashboard_mobile_Settings_LanguageDrawer .language-option .check-icon {
    color: #3b82f6;
    font-size: 1.25rem;
    opacity: 0;
    transition: opacity 0.2s ease, transform 0.2s ease;
    transform: scale(0.8);
}
#dashboard_mobile_Settings_LanguageDrawer .language-option.selected .check-icon {
    opacity: 1;
    transform: scale(1);
}
#dashboard_mobile_Settings_LanguageDrawer .language-option.selected {
    font-weight: 600;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer {
    background-color: #ffffff !important;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .drawer-header {
    background-color: #ffffff;
    border-bottom-color: #e2e8f0;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .back-btn {
    color: #0f172a;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .drawer-title {
    color: #0f172a;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .form-section {
    background-color: #ffffff;
    border-color: #e2e8f0;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .language-option {
    color: #0f172a;
    border-bottom-color: #f1f5f9;
}
body:not(.dark-mode) #dashboard_mobile_Settings_LanguageDrawer .language-option:hover {
    background-color: #f8fafc;
}
/* POPUP XÁC NHẬN CHUẨN MOBILE (MASCOT ROBOT) NẰM ĐÈ LÊN TRƯỚC TẤT CẢ MENU */
#vc-vu-confirm-popup,
#vc-vu-info-popup,
#vc-vu-three-option-popup,
.VC-Vu-component-overlay {
    z-index: 200000 !important;
}
.VC-Vu-popup {
    z-index: 200001 !important;
}
@media (min-width: 768px) {
    #dashboard_mobile_Notification_html .notification-drawer,
    #dashboard_mobile_Settings_html .settings-drawer,
    #dashboard_mobile_Settings_HelpSupportDrawer,
    #dashboard_mobile_Settings_ChangePasswordDrawer {
        width: 440px !important;
        left: auto !important;
        right: 0 !important;
        top: 59px !important;
        height: calc(100vh - 59px) !important;
        height: calc(100dvh - 59px) !important;
        border-left: 1px solid rgba(0,0,0,0.1) !important;
        box-shadow: none !important;
        z-index: 20000 !important;
    }
}
/* An muc Che do toi trong Drawer Cai dat vi Navbar da co nut mat trang rieng */
#rowToggleTheme,
.settings-drawer #rowToggleTheme,
.settings-drawer .option-item:has(#toggleThemeOption) {
    display: none !important;
}

/* Modal Thiet lap nhanh (Settings Modal) */
#paradiseSettingsModal {
    z-index: 20000 !important;
    padding-top: 75px !important;
}
/* Giu modal-backdrop o muc Bootstrap mac dinh (1050), chi override cho #paradiseSettingsModal rieng */
#successModalAddNew, #successModal, #notificationModal {
    z-index: 20005 !important;
}
#successModalAddNew .modal-dialog, #successModal .modal-dialog, #notificationModal .modal-dialog {
    z-index: 20010 !important;
    position: relative !important;
}
#contextMenuTab, #contextMenu, #contextMenuDock {
    z-index: 25000 !important;
}
#paradiseSettingsModal .modal-dialog {
    max-width: 440px !important;
    margin: 10px auto !important;
}
#paradiseSettingsModal .modal-content {
    background-color: var(--paradise-card-bg, #1e293b) !important;
    background: var(--paradise-card-bg, #1e293b) !important;
    color: var(--paradise-text-body, #e2e8f0) !important;
    border: 1px solid var(--paradise-border-color, rgba(255,255,255,0.12)) !important;
    border-radius: 16px !important;
    box-shadow: 0 20px 45px rgba(0,0,0,0.5) !important;
    overflow: hidden !important;
}
body:not(.dark-mode) #paradiseSettingsModal .modal-content {
    background-color: #ffffff !important;
    background: #ffffff !important;
    color: #1e293b !important;
    border: 1px solid rgba(0,0,0,0.1) !important;
    box-shadow: 0 20px 45px rgba(0,0,0,0.15) !important;
}
#paradiseSettingsModal .modal-header {
    background-color: var(--paradise-card-bg, #1e293b) !important;
    background: var(--paradise-card-bg, #1e293b) !important;
    border-bottom: 1px solid var(--paradise-border-color, rgba(255,255,255,0.08)) !important;
    padding: 16px 20px !important;
}
body:not(.dark-mode) #paradiseSettingsModal .modal-header {
    background-color: #ffffff !important;
    background: #ffffff !important;
    border-bottom: 1px solid rgba(0,0,0,0.08) !important;
}
#paradiseSettingsModal .modal-title {
    color: var(--paradise-text-title, #ffffff) !important;
    font-weight: 600 !important;
    font-size: 16px !important;
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    margin: 0 !important;
}
body:not(.dark-mode) #paradiseSettingsModal .modal-title {
    color: #0f172a !important;
}
#paradiseSettingsModal .modal-body {
    padding: 18px 20px !important;
}
#paradiseSettingsModal .settings-section {
    background-color: var(--paradise-bg-1, rgba(255,255,255,0.03)) !important;
    border: 1px solid var(--paradise-border-color, rgba(255,255,255,0.06)) !important;
    border-radius: 12px !important;
    padding: 14px 16px !important;
    margin-bottom: 14px !important;
}
body:not(.dark-mode) #paradiseSettingsModal .settings-section {
    background-color: #f8fafc !important;
    border: 1px solid #e2e8f0 !important;
}
#paradiseSettingsModal .settings-section-title {
    font-size: 13.5px !important;
    font-weight: 600 !important;
    color: var(--paradise-text-title, #f8fafc) !important;
    margin-bottom: 10px !important;
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
}
body:not(.dark-mode) #paradiseSettingsModal .settings-section-title {
    color: #0f172a !important;
}
#paradiseSettingsModal .language-list {
    display: flex !important;
    flex-direction: column !important;
    gap: 8px !important;
}
#paradiseSettingsModal .language-option {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    padding: 11px 14px !important;
    border-radius: 10px !important;
    background: var(--paradise-bg-surface, rgba(255,255,255,0.03)) !important;
    border: 1.5px solid var(--paradise-border-color, rgba(255,255,255,0.08)) !important;
    cursor: pointer !important;
    transition: all 0.2s ease !important;
    user-select: none !important;
}
body:not(.dark-mode) #paradiseSettingsModal .language-option {
    background: #ffffff !important;
    border: 1.5px solid #e2e8f0 !important;
}
#paradiseSettingsModal .language-option:hover {
    border-color: #3b82f6 !important;
    background: rgba(59, 130, 246, 0.08) !important;
}
#paradiseSettingsModal .language-option.selected {
    border-color: #3b82f6 !important;
    background: rgba(59, 130, 246, 0.12) !important;
    font-weight: 600 !important;
}
#paradiseSettingsModal .language-option .check-icon {
    color: #3b82f6 !important;
    font-size: 1.25rem !important;
    display: none !important;
}
#paradiseSettingsModal .language-option.selected .check-icon {
    display: inline-block !important;
}
#paradiseSettingsModal .language-name {
    font-size: 14px !important;
    font-weight: 500 !important;
    color: var(--paradise-text-title, #f8fafc) !important;
}
body:not(.dark-mode) #paradiseSettingsModal .language-name {
    color: #1e293b !important;
}
#paradiseSettingsModal .theme-row {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
}
#paradiseSettingsModal .modal-footer {
    background-color: var(--paradise-card-bg, #1e293b) !important;
    background: var(--paradise-card-bg, #1e293b) !important;
    border-top: 1px solid var(--paradise-border-color, rgba(255,255,255,0.08)) !important;
    padding: 12px 20px !important;
}
body:not(.dark-mode) #paradiseSettingsModal .modal-footer {
    background-color: #ffffff !important;
    background: #ffffff !important;
    border-top: 1px solid rgba(0,0,0,0.08) !important;
}
</style>

<script>
// Get the notification bell icon and the notification container
  var bellIcon = document.querySelector(''.notifications'');
  var notificationContainer = document.querySelector(''.notification-container'');
  var profileContainer = document.querySelector(''.user-info .profile'');
  var profileMenu = document.querySelector(''.user-info .profile .profile-menu'');
  var profileLogout = document.getElementById("profileLogout") || document.querySelector(''.logout-section'');
  var viewProfile = document.getElementById("viewProfile");
  var viewSetting = document.getElementById("viewSetting");
  var viewChangePW = document.getElementById("viewChangePW");
  var viewHelp = document.getElementById("viewHelp");
  var setupGoogleAuthenticator = document.getElementById("setup-google-auth");

  if (viewProfile) {
    viewProfile.addEventListener("click", function(e) {
        e.stopPropagation();
        if (userDetails) userDetails.classList.remove(''active'');
        openFormParam("HR_StaffInformation_List_2", {
            EmployeeID: window.EmployeeID,
            LoginID: LoginID,
            LanguageID: LanguageID,
            TableName: "-1",
            Isweb: 1
        });
    });
  }

  if (viewChangePW) {
    viewChangePW.addEventListener("click", function(e) {
        e.stopPropagation();
        if (userDetails) userDetails.classList.remove(''active'');
        openMobileDrawerComponent("dashboard_mobile_Settings_ChangePassword_html", "#dashboard_mobile_Settings_ChangePasswordDrawer", "mobileChangePWContainer");
    });
  }

  // HÀM TỰ ĐỘNG DỊCH TOÀN BỘ PLACEHOLDER %KEY% TỪ TBLMD_MESSAGE
  window.replaceLanguagePlaceholders = window.replaceLanguagePlaceholders || async function(html, langId) {
      if (!html || html.indexOf("%") === -1) return html;
      var curLang = langId || window.LanguageID || (typeof LanguageID !== "undefined" ? LanguageID : "VN");
      window._GlobalLangCache = window._GlobalLangCache || {};
      if (!window._GlobalLangCache[curLang]) {
          try {
              var res = await AjaxHPAParadiseAsync({
                  data: {
                      name: "sp_MD_Message_GetAll",
                      param: ["@LanguageID", curLang]
                  }
              });
              var data = typeof res === "string" ? JSON.parse(res) : res;
              var rows = (data && data.data && data.data[0]) ? data.data[0] : [];
              window._GlobalLangCache[curLang] = {};
              rows.forEach(function(r) {
                  if (r.MessageID && r.Content) {
                      window._GlobalLangCache[curLang][r.MessageID] = r.Content;
                  }
              });
          } catch(err) {
              console.warn("sp_MD_Message_GetAll error:", err);
          }
      }
      var dict = window._GlobalLangCache[curLang] || {};
      return html.replace(/%([a-zA-Z0-9_.]+)%/g, function(match, key) {
          return dict[key] !== undefined ? dict[key] : match;
      });
  };

  // HÀM HỖ TRỢ KẾ THỪA VÀ NẠP MOBILE DRAWER CÓ CHECK VERSION CHUẨN OPENFORM (THÔNG BÁO, CÀI ĐẶT, TRỢ GIÚP, ĐỔI MẬT KHẨU)
  window.openMobileDrawerComponent = async function(procName, drawerSelector, containerId, autoOpen) {
      if (typeof autoOpen === "undefined") autoOpen = true;
      var container = document.getElementById(containerId);
      if (!container) {
          container = document.createElement("div");
          container.id = containerId;
          document.body.appendChild(container);
      }

      var appAddress = window.APPLICATION_ADDRESS || "";
      var serverName = appAddress.replace(/\//g, "") || "root";
      var TableName = procName.replace("_html", "").trim();
      var curLang = window.LanguageID || (typeof LanguageID !== "undefined" ? LanguageID : "VN");
      var cacheKeyLink = serverName + "_link_" + TableName;
      var oldUrlFetch = localStorage.getItem(cacheKeyLink) || "";

      if (oldUrlFetch && oldUrlFetch.indexOf(appAddress) === -1) {
          oldUrlFetch = "";
      }

      var existingDrawer = container.querySelector(drawerSelector);
      // NẾU ĐÃ MỞ RỒI VÀ AUTOOPEN LÀ TRUE -> CLICK LẦN NỮA LÀ CLOSE FORM (TOGGLE)
      if (existingDrawer && existingDrawer.classList.contains("open") && autoOpen) {
          existingDrawer.classList.remove("open");
          document.body.style.overflow = "";
          var subHolder = existingDrawer.querySelector("#SettingsSubPageHolder");
          if (subHolder) { subHolder.innerHTML = ""; subHolder.style.display = "none"; }
          return;
      }

      // NẾU MỞ THÔNG BÁO HOẶC DRAWER KHÁC -> ĐÓNG NGAY CÀI ĐẶT
      if (autoOpen && typeof window.closeSettingsDrawerMobile === "function") {
          window.closeSettingsDrawerMobile();
      }

      // HÀM SETUP STYLE & EVENT CLOSE CHO DRAWER
      var setupDrawerUI = function(dr) {
          if (!dr) return;
          if (container) {
              container.style.position = "relative";
              container.style.zIndex = "99999";
          }
          if (window.innerWidth >= 768) {
              var nav = document.querySelector(".navbar-home");
              var navH = nav ? nav.offsetHeight : 59;
              dr.style.setProperty("top", navH + "px", "important");
              dr.style.setProperty("height", "calc(100vh - " + navH + "px)", "important");
              dr.style.setProperty("width", "450px", "important");
              dr.style.setProperty("left", "auto", "important");
              dr.style.setProperty("right", "0px", "important");
              dr.style.setProperty("z-index", "99999", "important");
              dr.style.setProperty("box-shadow", "none", "important");
          }
          if (autoOpen) {
              dr.classList.add("open");
              document.body.style.overflow = "hidden";
          }

          // CHỈ NÚT ĐÓNG CỦA CHÍNH DRAWER NÀY MỚI ĐÓNG DR (TRÁNH NÚT BACK CỦA MENU CON ĐÓNG LUÔN CÀI ĐẶT)
          var mainCloseBtns = dr.querySelectorAll(":scope > .drawer-header .back-btn, :scope > .drawer-header .btn-close, #closeNotificationDrawerBtn, #closeNotificationDrawer, #closeSettingsDrawerBtn, #closeChangePasswordDrawer, #cancelChangePassword");
          mainCloseBtns.forEach(function(b) {
              b.onclick = function(e) {
                  e.stopPropagation();
                  dr.classList.remove("open");
                  document.body.style.overflow = "";
              };
          });

          // NÚT LÙI VỀ (BACK) CHO CÁC SUBPAGE TRONG CÀI ĐẶT: CHỈ ĐÓNG SUBPAGE, QUAY VỀ CÀI ĐẶT CHÍNH
          var subHolder = dr.querySelector("#SettingsSubPageHolder");
          if (subHolder) {
              $(subHolder).off("click.subBack").on("click.subBack", "#closeHelpDrawerBtn, #closeAboutDrawerBtn, #closeSecurityDrawer", function(e) {
                  e.preventDefault();
                  e.stopPropagation();
                  var subDrawer = subHolder.querySelector("[id*=''Drawer''], .settings-drawer") || subHolder.firstElementChild;
                  if (subDrawer) {
                      subDrawer.classList.remove("open");
                  }
                  setTimeout(function() {
                      subHolder.innerHTML = "";
                      subHolder.style.display = "none";
                  }, 250);
              });
          }

          // XỬ LÝ CHẾ ĐỘ MÀU & ĐĂNG XUẤT CHO WEB vs MOBILE THEO ISWEB (NẾU ISWEB = 2 LÀ MOBILE, KHÁC LÀ WEB)
          var isMobileApp = (typeof window.isWeb !== "undefined" && window.isWeb === 2);
          if (!isMobileApp) {
              // 1. CHẾ ĐỘ MÀU TRÊN WEB: KHÔNG RELOAD, ĐỔI TỨC THÌ 0MS
              var themeSwitch = dr.querySelector("#toggleThemeOption");
              var themeRow = dr.querySelector("#rowToggleTheme");
              if (themeSwitch && themeRow) {
                  var isDarkNow = document.body.classList.contains("dark-mode") || (localStorage.getItem("theme") === "dark");
                  themeSwitch.checked = isDarkNow;

                  var newThemeSwitch = themeSwitch.cloneNode(true);
                  themeSwitch.parentNode.replaceChild(newThemeSwitch, themeSwitch);

                  var newThemeRow = themeRow.cloneNode(false);
                  while (themeRow.firstChild) newThemeRow.appendChild(themeRow.firstChild);
                  themeRow.parentNode.replaceChild(newThemeRow, themeRow);

                  var doApplyTheme = function(targetDark) {
                      newThemeSwitch.checked = targetDark;
                      var newTheme = targetDark ? ''dark'' : ''light'';
                      if (typeof window.applyTheme === "function") {
                          window.applyTheme(newTheme);
                      }
                      try {
                          localStorage.setItem("theme", newTheme);
                          localStorage.setItem("darkMode", targetDark ? ''enabled'' : ''disabled'');
                      } catch(ex) {}
                  };

                  newThemeSwitch.onchange = function(e) {
                      e.stopPropagation();
                      doApplyTheme(this.checked);
                  };

                  newThemeRow.onclick = function(e) {
                      if (e.target !== newThemeSwitch) {
                          e.preventDefault();
                          e.stopPropagation();
                          doApplyTheme(!newThemeSwitch.checked);
                      }
                  };
              }

              // 2. ĐĂNG XUẤT TRÊN WEB: DÙNG MODAL XÁC NHẬN CHUẨN CỦA WEB
              var logoutBtn = dr.querySelector("#settingsLogoutBtn");
              if (logoutBtn) {
                  var newLogoutBtn = logoutBtn.cloneNode(true);
                  logoutBtn.parentNode.replaceChild(newLogoutBtn, logoutBtn);
                  newLogoutBtn.onclick = function(e) {
                      e.stopPropagation();
                      dr.classList.remove("open");
                      document.body.style.overflow = "";
                      var pLogout = document.getElementById("profileLogout") || document.querySelector(".logout-section");
                      if (pLogout) {
                          pLogout.click();
                      } else {
                          var textNoti = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "<p class=''fs-6 mb-0''>Xác nhận đăng xuất khỏi tài khoản?</p>" : "<p class=''fs-6 mb-0''>Confirm logout of account?</p>";
                          var textConf = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "Đăng xuất" : "Logout";
                          var textCanc = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "Ở lại" : "Cancel";
                          if (typeof showSuccessModalAddNew === "function") {
                              showSuccessModalAddNew(textNoti, textConf, textCanc, function() {
                                  if (typeof LogOut === "function") LogOut();
                                  else window.location.href = (window.APPLICATION_ADDRESS || "") + "/paradisehrm/logout";
                              });
                          } else {
                              if (confirm("Xác nhận đăng xuất?")) {
                                  window.location.href = (window.APPLICATION_ADDRESS || "") + "/paradisehrm/logout";
                              }
                          }
                      }
                  };
              }
          }
      };

      var renderDrawerHtml = async function(html) {
          if (!html) return;
          html = await replaceLanguagePlaceholders(html, curLang);
          container.innerHTML = html;
          var scripts = container.querySelectorAll("script");
          scripts.forEach(function(oldScript) {
              var newScript = document.createElement("script");
              Array.from(oldScript.attributes).forEach(function(attr) {
                  newScript.setAttribute(attr.name, attr.value);
              });
              newScript.appendChild(document.createTextNode(oldScript.innerHTML));
              oldScript.parentNode.replaceChild(newScript, oldScript);
          });
          setTimeout(function() {
              var dr = container.querySelector(drawerSelector);
              setupDrawerUI(dr);
          }, 60);
      };

      // BƯỚC 1: NẠP TỪ BROWSER DISK CACHE / DOM (0MS DELAY)
      if (existingDrawer) {
          setupDrawerUI(existingDrawer);
          if (autoOpen) {
              return;
          }
      }
      if (oldUrlFetch) {
          try {
              var responseOld = await $.ajax({ url: oldUrlFetch, cache: true, global: false });
              var cachedHtml = "";
              if (typeof responseOld === "string") {
                  try { cachedHtml = JSON.parse(responseOld).data[0][0].bytes; } catch(e) { cachedHtml = responseOld; }
              } else if (responseOld && responseOld.data && responseOld.data[0] && responseOld.data[0][0] && responseOld.data[0][0].bytes) {
                  cachedHtml = responseOld.data[0][0].bytes;
              }
              if (cachedHtml && !existingDrawer) {
                  await renderDrawerHtml(cachedHtml);
              }
              renderedFromCache = true;
          } catch(e) {}
      }

      // BƯỚC 2: CHECK VERSION VỚI SERVER (STALE-WHILE-REVALIDATE Y HỆT BÊN OPENFORM LOADLIVEDATA)
      var checkAndFetchServer = async function() {
          if (navigator.onLine === false) return;
          try {
              var currentVersion = "-1";
              try {
                  var verData = await AjaxHPAParadiseAsync({
                      showLoading: false,
                      data: {
                          name: "paradisepublic",
                          param: ["paradisepublic", TableName, "LanguageID", curLang, "ParadiseVersion", "-1"]
                      }
                  });
                  var parsedVer = typeof verData === "string" ? JSON.parse(verData) : verData;
                  if (parsedVer && parsedVer.data && parsedVer.data[0] && parsedVer.data[0][0]) {
                      currentVersion = parsedVer.data[0][0].ParadiseVersion;
                  }
              } catch(e) {
                  return;
              }

              if (currentVersion && currentVersion !== "-1") {
                  var baseUrl = appAddress.startsWith("http") ? "" : window.location.origin;
                  var newUrlFetch = baseUrl + appAddress + "/api/hpa/paradise?&name=paradisepublic&param=[\"paradisepublic\",\"" + TableName + "\",\"LanguageID\",\"" + curLang + "\",\"ParadiseVersion\"," + currentVersion + "]&user=paradisepublic&password=3C9909AFEC25354D551DAE21590BB26E38D53F2173B8D3DC3EEE4C047E7AB1C1EB8B85103E3BE7BA613B31BB5C9C36214DC9F14A42FD7A2FDB84856BCA5C44C2&_cb=" + curLang + "_" + currentVersion;

                  if (newUrlFetch !== oldUrlFetch || !container.querySelector(drawerSelector)) {
                      var response = await $.ajax({ url: newUrlFetch, cache: true, global: false });
                      var newHtmlContent = "";
                      if (typeof response === "string") {
                          try { newHtmlContent = JSON.parse(response).data[0][0].bytes; } catch(e) { newHtmlContent = response; }
                      } else if (response && response.data && response.data[0] && response.data[0][0] && response.data[0][0].bytes) {
                          newHtmlContent = response.data[0][0].bytes;
                      }
                      if (newHtmlContent) {
                          try { localStorage.setItem(cacheKeyLink, newUrlFetch); } catch(e) {}
                          await renderDrawerHtml(newHtmlContent);
                          renderedFromCache = true;
                      }
                  }
              }
          } catch(err) {
              console.warn("Lỗi kiểm tra cache paradisepublic cho " + TableName + ":", err);
          }

          // BƯỚC 3: FALLBACK TRỰC TIẾP CHỈ KHI CHƯA CÓ TRONG CACHE VÀ ĐANG ONLINE
          if (!renderedFromCache && !container.querySelector(drawerSelector) && navigator.onLine !== false) {
              try {
                  var res = await AjaxHPAParadiseAsync({
                      data: {
                          name: procName,
                          param: [
                              "@LoginID", window.LoginID || LoginID || 0,
                              "@LanguageID", curLang,
                              "@isWeb", 1
                          ]
                      }
                  });
                  var parsed = typeof res === "string" ? JSON.parse(res) : res;
                  var fallbackHtml = "";
                  if (parsed && parsed.data && parsed.data[0] && parsed.data[0][0]) {
                      fallbackHtml = parsed.data[0][0].html || "";
                  } else if (typeof parsed === "string") {
                      fallbackHtml = parsed;
                  }
                  if (fallbackHtml) {
                      await renderDrawerHtml(fallbackHtml);
                  }
              } catch(err) {
                  console.error("Lỗi khi mở fallback " + procName + ":", err);
              }
          }
      };

      if (procName.indexOf("Notification") !== -1 && typeof window.loadDataNotification === "function") {
          try { window.loadDataNotification(false); } catch(e) {}
      }

      checkAndFetchServer();
  };

  // Nạp component con trong Settings (Bảo mật, Trợ giúp, Ngôn ngữ, Giới thiệu)
  window.loadCachedComponent = async function(componentName, containerId) {
      var container = document.getElementById(containerId);
      if (!container) return;
      try {
          var curLang = window.LanguageID || (typeof LanguageID !== "undefined" ? LanguageID : "VN");
          var res = await AjaxHPAParadiseAsync({
              data: {
                  name: componentName,
                  param: [
                      "@LoginID", window.LoginID || LoginID || 0,
                      "@LanguageID", curLang,
                      "@isWeb", 1
                  ]
              }
          });
          var parsed = typeof res === "string" ? JSON.parse(res) : res;
          var html = "";
          if (parsed && parsed.data && parsed.data[0] && parsed.data[0][0]) {
              html = parsed.data[0][0].html || "";
          } else if (typeof parsed === "string") {
              html = parsed;
          }
          if (html) {
              // Tự động sửa lỗi cú pháp nếu có trong component con
              html = html.replace(/localStorage\.removeItem\(k\);\s*\}\);/g, "keysToRemove.push(k); } } keysToRemove.forEach(function(k){ localStorage.removeItem(k); });");
              // Tự động chuẩn hóa luồng đổi ngôn ngữ trên Web (lưu cookie, cập nhật DB, gọi changeLanguage và delay reload)
              html = html.replace("if (typeof changeLanguage === \"function\") {", "document.cookie = \"LanguageID=\" + selectedLang + \"; path=/\"; document.cookie = \"Language=\" + selectedLang + \"; path=/\"; try { AjaxHPAParadise({ data: { name: \"tblCommonSettingEditable_UpdateLanguage\", param: [\"@LoginID\", window.LoginID || window.UserID || 0, \"@LanguageID\", selectedLang] } }); } catch(e) {} if (typeof changeLanguage === \"function\") { changeLanguage(selectedLang); } setTimeout(function() { window.location.reload(); }, 800); return; if (false) {");
              html = await replaceLanguagePlaceholders(html, curLang);
              if (containerId === "SettingsSubPageHolder" || container.id === "SettingsSubPageHolder") {
                  container.style.display = "flex";
              }
              container.innerHTML = html;
              var scripts = container.querySelectorAll("script");
              scripts.forEach(function(oldScript) {
                  var newScript = document.createElement("script");
                  Array.from(oldScript.attributes).forEach(function(attr) {
                      newScript.setAttribute(attr.name, attr.value);
                  });
                  newScript.appendChild(document.createTextNode(oldScript.innerHTML));
                  oldScript.parentNode.replaceChild(newScript, oldScript);
              });
              setTimeout(function() {
                  var subDrawer = container.querySelector(".settings-drawer, .notification-drawer, [id*=''Drawer'']");
                  if (!subDrawer) return;
                  var isSubPage = (containerId === "SettingsSubPageHolder" || container.id === "SettingsSubPageHolder" || (typeof container.closest === "function" && container.closest("#mainSettingsDrawer, #dashboard_mobile_Settings_html")));
                  if (isSubPage) {
                      subDrawer.style.setProperty("position", "absolute", "important");
                      subDrawer.style.setProperty("top", "0px", "important");
                      subDrawer.style.setProperty("height", "100%", "important");
                      subDrawer.style.setProperty("width", "100%", "important");
                      subDrawer.style.setProperty("left", "0px", "important");
                      subDrawer.style.setProperty("right", "0px", "important");
                      subDrawer.style.setProperty("z-index", "200", "important");
                  } else if (window.innerWidth >= 768) {
                      var nav = document.querySelector(".navbar-home");
                      var navH = nav ? nav.offsetHeight : 59;
                      subDrawer.style.setProperty("top", navH + "px", "important");
                      subDrawer.style.setProperty("height", "calc(100vh - " + navH + "px)", "important");
                      subDrawer.style.setProperty("width", "450px", "important");
                      subDrawer.style.setProperty("left", "auto", "important");
                      subDrawer.style.setProperty("right", "0px", "important");
                      subDrawer.style.setProperty("z-index", "99999", "important");
                      subDrawer.style.setProperty("box-shadow", "none", "important");
                  }
              }, 60);
          }
      } catch(err) {
          console.error("loadCachedComponent error:", componentName, err);
      }
  };

  // MODAL CŨ ĐÃ LOẠI BỎ HOÀN TOÀN THEO YÊU CẦU ĐỒNG BỘ MOBILE
  window.openParadiseSettingsModal = function() {
      var oldModal = document.getElementById("paradiseSettingsModal");
      if (oldModal) {
          try {
              if (typeof bootstrap !== "undefined" && bootstrap.Modal) {
                  var inst = bootstrap.Modal.getInstance(oldModal);
                  if (inst) inst.hide();
              }
              $(oldModal).modal("hide");
          } catch(e) {}
          oldModal.remove();
      }
      var bds = document.querySelectorAll(".modal-backdrop");
      bds.forEach(function(b) { b.remove(); });
      if (typeof window.openSettingsDrawerMobile === "function") {
          window.openSettingsDrawerMobile();
      }
  };

  if (viewSetting) {
    viewSetting.addEventListener("click", function(e) {
        e.stopPropagation();
        if (userDetails) userDetails.classList.remove(''active'');
        window.openSettingsDrawerMobile();
    });
  }

  if (viewHelp) {
    viewHelp.addEventListener("click", function(e) {
        e.stopPropagation();
        if (userDetails) userDetails.classList.remove(''active'');
        openMobileDrawerComponent("dashboard_mobile_Settings_HelpSupport_html", "#dashboard_mobile_Settings_HelpSupportDrawer", "mobileHelpContainer");
    });
  }

  // =========================================================================
  // 1. HÀM MỞ POPUP GOOGLE AUTHENTICATOR (2FA) TOÀN CỤC
  // =========================================================================
  window.openGoogle2FAModal = async function() {
      try {
          if (typeof otplib === "undefined" || !otplib.authenticator) {
              if (typeof window.Buffer === "undefined") {
                  await $.getScript("https://unpkg.com/@otplib/preset-browser@^12.0.0/buffer.js");
              }
              await $.getScript("https://unpkg.com/@otplib/preset-browser@^12.0.0/index.js");
          }
      } catch (err) {
          console.warn("Lỗi tải otplib CDN:", err);
      }

      var popup = $("<div>");
      var qrImage = $("<img>");

      $("body").append(popup);

      popup.dxPopup({
          visible: true,
          hideOnOutsideClick: true,
          showCloseButton: true,
          showTitle: true,
          title: (typeof LanguageID !== "undefined" && LanguageID === "VN") ? "Cấu hình Google Authenticator (2FA)" : "Google Authenticator (2FA) Setup",
          resizeEnabled: false,
          dragEnabled: false,
          fullScreen: false,
          width: "auto",
          height: "auto",
          wrapperAttr: {
              class: "dx-popup-google-2fa",
              style: "z-index: 25000 !important;"
          },
          onHidden: function (arg) {
              arg.component.dispose();
              arg.element.remove();
          },
          contentTemplate: function (template) {
              var isVN = (typeof LanguageID !== "undefined" && LanguageID === "VN");
              var div = $("<div>")
                  .addClass("p-3 d-flex flex-column align-items-center justify-content-center")
                  .append(
                      $("<p>")
                          .addClass("fs-5 fw-bold text-success text-center mb-2")
                          .text(isVN ? "Quét mã QR bằng ứng dụng Google Authenticator:" : "Scan this QR code with Google Authenticator:"),
                      qrImage.css({"max-width": "15rem", "min-height": "15rem", "object-fit": "contain"}),
                      $("<div class=''mt-2 text-center''>").append(
                          $("<button type=''button'' class=''btn btn-sm btn-link text-muted text-decoration-none'' id=''btnToggleSecretKey''>")
                              .html(''<i class="fas fa-eye me-1"></i> '' + (isVN ? "Hiển thị mã khóa dự phòng" : "Show backup secret key")),
                          $("<div id=''otpSecretDisplay'' style=''display:none;'' class=''text-muted small mt-1 font-monospace''>")
                      )
                  );

              return div;
          },
          onShown: async function (arg) {
              var empId = window.EmployeeID || window.employeeID || "";
              var logId = window.LoginID || (typeof LoginID !== "undefined" ? LoginID : 0);
              var secret = "";

              // 1. Luôn đọc mã cũ đã lưu từ Database trước
              try {
                  var googleAuthenSecret = await AjaxHPAParadiseAsync({
                      data: {
                          name: "sp_GetEmployeeAuthenticatorID",
                          param: ["@LoginID", logId, "@EmployeeID", empId],
                      },
                      success: function (result) {},
                  });

                  googleAuthenSecret = typeof googleAuthenSecret === "string"
                          ? JSON.parse(googleAuthenSecret)
                          : googleAuthenSecret;
                  if (googleAuthenSecret && googleAuthenSecret.data && googleAuthenSecret.data[0] && googleAuthenSecret.data[0][0]) {
                      var dbKey = googleAuthenSecret.data[0][0].GoogleAuthenticatorID;
                      if (dbKey && typeof dbKey === "string" && dbKey.trim() !== "") {
                          secret = dbKey.trim();
                      }
                  }
              } catch(err) {
                  console.warn("sp_GetEmployeeAuthenticatorID error:", err);
              }

              // 2. Chỉ khi tài khoản CHƯA TỪNG có mã mới sinh lần đầu và lưu vào DB
              if (!secret) {
                  if (typeof otplib !== "undefined" && otplib.authenticator) {
                      secret = otplib.authenticator.generateSecret();
                  } else {
                      secret = "JBSWY3DPEHPK3PXP" + Math.random().toString(36).substring(2, 10).toUpperCase();
                  }
                  try {
                      await AjaxHPAParadiseAsync({
                          data: {
                              name: "sp_SetEmployeeAuthenticatorID",
                              param: ["@LoginID", logId, "@EmployeeID", empId, "@GoogleAuthenticatorSecretKey", secret],
                          }
                      });
                  } catch(e) {
                      console.warn("sp_SetEmployeeAuthenticatorID error:", e);
                  }
              }

              var otpauth = "otpauth://totp/ParadiseHR:" + (window.LoginName || "user") + "?secret=" + secret + "&issuer=ParadiseHR";

              $("#btnToggleSecretKey").off("click").on("click", function() {
                  var $disp = $("#otpSecretDisplay");
                  var isVN = (typeof LanguageID !== "undefined" && LanguageID === "VN");
                  if ($disp.is(":visible")) {
                      $disp.hide();
                      $(this).html(''<i class="fas fa-eye me-1"></i> '' + (isVN ? "Hiển thị mã khóa dự phòng" : "Show backup secret key"));
                  } else {
                      $disp.html("Secret Key: <code>" + secret + "</code>").show();
                      $(this).html(''<i class="fas fa-eye-slash me-1"></i> '' + (isVN ? "Ẩn mã khóa dự phòng" : "Hide backup secret key"));
                  }
              });

              var qrSrc = "";
              try {
                  if (typeof AjaxHPAParadiseParadiseAsync === "function") {
                      var qrBase64 = await AjaxHPAParadiseParadiseAsync({
                          data: {
                              name: "ToQRCodeByte",
                              param: [otpauth, "jpg"],
                          }
                      });

                      qrBase64 = typeof qrBase64 === "string" ? JSON.parse(qrBase64) : qrBase64;
                      if (qrBase64 && qrBase64.data) {
                          qrSrc = "data:image/jpeg;base64," + qrBase64.data;
                      }
                  }
              } catch(e) {
                  console.warn("ToQRCodeByte failed:", e);
              }

              if (!qrSrc) {
                  qrSrc = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + encodeURIComponent(otpauth);
              }
              qrImage.attr("src", qrSrc);
          },
      });
  };

  // =========================================================================
  // 2. BỘ ĐIỀU KHIỂN DRAWER CÀI ĐẶT & THÔNG BÁO MOBILE ĐỒNG BỘ (NHÚNG SẴN 0MS)
  // =========================================================================

  // HÀM ĐÓNG DRAWER THÔNG BÁO TOÀN CỤC (MUTUALLY EXCLUSIVE VỚI CÀI ĐẶT)
  // HÀM ĐÓNG DRAWER THÔNG BÁO TOÀN CỤC (MUTUALLY EXCLUSIVE VỚI CÀI ĐẶT - TRIỆT TIÊU BÓNG & ẨN HOÀN TOÀN)
  window.closeNotificationDrawerMobile = function() {
      var notiDrawers = document.querySelectorAll("#dashboard_mobile_Notification_html .notification-drawer, #mobileNotificationContainer .notification-drawer, .notification-drawer, #mainNotificationDrawer");
      notiDrawers.forEach(function(dr) {
          dr.classList.remove("open");
          dr.style.setProperty("transform", "translateX(100%)", "important");
          dr.style.setProperty("visibility", "hidden", "important");
          dr.style.setProperty("pointer-events", "none", "important");
          dr.style.setProperty("box-shadow", "none", "important");
          dr.style.setProperty("z-index", "-1", "important");
      });
      var notiContainer = document.getElementById("mobileNotificationContainer");
      if (notiContainer) {
          notiContainer.style.setProperty("visibility", "hidden", "important");
          notiContainer.style.setProperty("pointer-events", "none", "important");
          notiContainer.style.setProperty("z-index", "-1", "important");
          var innerDrawers = notiContainer.querySelectorAll(".notification-drawer");
          innerDrawers.forEach(function(dr) {
              dr.classList.remove("open");
              dr.style.setProperty("transform", "translateX(100%)", "important");
              dr.style.setProperty("visibility", "hidden", "important");
              dr.style.setProperty("pointer-events", "none", "important");
              dr.style.setProperty("box-shadow", "none", "important");
              dr.style.setProperty("z-index", "-1", "important");
          });
      }
      var anyOpen = document.querySelector(".settings-drawer.open, #mainSettingsDrawer.open");
      if (!anyOpen) {
          document.body.style.overflow = "";
      }
  };

  window.openSettingsDrawerMobile = function() {
      var drawer = document.getElementById("mainSettingsDrawer");
      var overlay = document.getElementById("mobileSettingsOverlay");
      if (!drawer) return;

      // 0. ĐÓNG THÔNG BÁO NGAY LẬP TỨC ĐỂ KHÔNG BỊ THÔNG BÁO ĐÈ LÊN CÀI ĐẶT
      if (typeof window.closeNotificationDrawerMobile === "function") {
          window.closeNotificationDrawerMobile();
      }

      // Đảm bảo đóng LanguageDrawer và reset SubPageHolder khi mở menu Cài đặt chính
      var langDrawer = document.getElementById("dashboard_mobile_Settings_LanguageDrawer");
      if (langDrawer) langDrawer.classList.remove("open");
      var subHolder = document.getElementById("SettingsSubPageHolder");
      if (subHolder) {
          subHolder.innerHTML = "";
          subHolder.style.display = "none";
      }

      // 1. Đóng menu desktop cũ nếu đang mở
      var ud = document.getElementById("userDetails");
      if (ud) ud.classList.remove("active");

      // 2. Điền Avatar tức thì
      var setAvatar = document.getElementById("settingsUserAvatar");
      var randAvt = document.getElementById("randomAvatar") || document.querySelector(".avatar-trigger img");
      if (setAvatar) {
          if (randAvt && randAvt.src && randAvt.src.indexOf("data:image/svg") === -1) {
              setAvatar.src = randAvt.src;
          } else if (typeof window.GlobalEmployeeAvatarCache !== "undefined") {
              var empId = window.EmployeeID || "";
              if (empId && window.GlobalEmployeeAvatarCache[empId]) {
                  setAvatar.src = window.GlobalEmployeeAvatarCache[empId];
              }
          }
      }

      // 3. Điền Tên và Chức vụ tức thì từ DOM có sẵn
      var setName = document.getElementById("settingsUserName");
      var setCode = document.getElementById("settingsUserCode");
      var curUser = document.getElementById("userName");
      var curPos = document.getElementById("positionuser");
      if (setName && curUser && curUser.innerText.trim()) {
          setName.innerText = curUser.innerText.replace(/^Xin chào,?\s*/i, "").trim();
      }
      if (setCode && curPos && curPos.innerText.trim()) {
          setCode.innerText = curPos.innerText.trim();
      }

      // Tự động gọi API ngầm cập nhật đầy đủ FullName + Dept . Position theo chuẩn Mobile
      try {
          if (typeof AjaxHPAParadise === "function") {
              AjaxHPAParadise({
                  data: {
                      name: "sp_dashboardMobileSetting_loadInfo",
                      param: ["LoginID", window.UserID || window.LoginID || 0, "LanguageID", window.LanguageID || "VN"]
                  },
                  success: function(res) {
                      var json = typeof res === "string" ? JSON.parse(res) : res;
                      if (json && json.data && json.data[0] && json.data[0].length > 0) {
                          var data = json.data[0][0];
                          if (setName && data.FullName) setName.innerText = data.FullName;
                          var dept = data.DepartmentName || "";
                          var pos = data.PositionName || "";
                          var fullTitle = dept;
                          if (dept && pos) fullTitle += " . " + pos;
                          else if (!dept && pos) fullTitle = pos;
                          if (setCode && fullTitle) setCode.innerText = fullTitle;
                      }
                  }
              });
          }
      } catch(e) {}

      // 4. Đồng bộ nút switch Dark Mode
      var themeToggle = document.getElementById("toggleThemeOption");
      if (themeToggle) {
          var isDark = document.body.classList.contains("dark-mode") || (localStorage.getItem("theme") === "dark");
          themeToggle.checked = isDark;
      }

      // 5. Hiển thị Drawer và Overlay trượt mượt mà 0ms
      drawer.classList.add("open");
      if (overlay) overlay.classList.add("show");
      document.body.style.overflow = "hidden";
  };

  window.closeSettingsDrawerMobile = function() {
      var drawer = document.getElementById("mainSettingsDrawer");
      var overlay = document.getElementById("mobileSettingsOverlay");
      if (drawer) drawer.classList.remove("open");
      if (overlay) overlay.classList.remove("show");
      document.body.style.overflow = "";

      var langDrawer = document.getElementById("dashboard_mobile_Settings_LanguageDrawer");
      if (langDrawer) langDrawer.classList.remove("open");

      var subHolder = document.getElementById("SettingsSubPageHolder");
      if (subHolder) {
          subHolder.innerHTML = "";
          subHolder.style.display = "none";
      }

      // Đảm bảo đóng popup xác nhận nếu còn sót
      if (typeof hideConfirmPopup === "function") hideConfirmPopup();
      if (window.uiManager && typeof window.uiManager.hideConfirmPopup === "function") {
          window.uiManager.hideConfirmPopup();
      }
      var cfOverlay = document.getElementById("vc-vu-confirm-popup");
      if (cfOverlay) cfOverlay.classList.remove("active");
      $(".modal-backdrop").remove();
  };

  // Nút đóng & Overlay
  $(document).off("click.closeSettingsMobile").on("click.closeSettingsMobile", "#closeSettingsDrawerBtn, #mobileSettingsOverlay", function(e) {
      e.preventDefault();
      e.stopPropagation();
      window.closeSettingsDrawerMobile();
  });

  // Nút Google 2FA trên menu Cài đặt và desktop
  $(document).off("click.openGoogle2FAMobile").on("click.openGoogle2FAMobile", "#btnOpenGoogle2FASettings, #setup-google-auth", function(e) {
      e.preventDefault();
      e.stopPropagation();
      window.openGoogle2FAModal();
  });

  // Nút Bảo mật (Đổi mật khẩu)
  $(document).off("click.openSecurityMobile").on("click.openSecurityMobile", "#btnOpenSecuritySettings", function(e) {
      e.preventDefault();
      e.stopPropagation();
      openMobileDrawerComponent("dashboard_mobile_Settings_ChangePassword_html", "#dashboard_mobile_Settings_ChangePasswordDrawer", "mobileChangePWContainer");
  });

  // NÚT LOẠI NGÔN NGỮ: MỞ DRAWER NGÔN NGỮ ĐỒNG BỘ MOBILE (0MS)
  $(document).off("click.openLangMobile").on("click.openLangMobile", "#btnOpenLanguageSettings", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var langDrawer = document.getElementById("dashboard_mobile_Settings_LanguageDrawer");
      if (!langDrawer) return;

      // Cập nhật checkmark theo ngôn ngữ hiện tại
      var curLang = window.LanguageID || (typeof LanguageID !== "undefined" ? LanguageID : "VN");
      var optVN = document.getElementById("langOption_VN");
      var optEN = document.getElementById("langOption_EN");
      if (optVN && optEN) {
          if (curLang === "VN") {
              optVN.classList.add("selected");
              optEN.classList.remove("selected");
          } else {
              optEN.classList.add("selected");
              optVN.classList.remove("selected");
          }
      }

      langDrawer.classList.add("open");
  });

  // Nút quay lại từ Drawer Ngôn ngữ Mobile (chỉ đóng LanguageDrawer, giữ nguyên menu Cài đặt)
  $(document).off("click.closeLangDrawer").on("click.closeLangDrawer", "#closeLanguageDrawer", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var langDrawer = document.getElementById("dashboard_mobile_Settings_LanguageDrawer");
      if (langDrawer) langDrawer.classList.remove("open");
  });

  // Sự kiện chọn ngôn ngữ trong Drawer Ngôn ngữ Mobile
  $(document).off("click.selectLanguageMobile").on("click.selectLanguageMobile", "#dashboard_mobile_Settings_LanguageDrawer .language-option", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var selectedLang = $(this).attr("data-lang");
      var curLang = window.LanguageID || (typeof LanguageID !== "undefined" ? LanguageID : "VN");
      if (!selectedLang || selectedLang === curLang) return;

      var doChangeLang = function() {
          if (typeof showLoadingByClassOrID === "function") showLoadingByClassOrID("body", "Updating Language...");
          // 1. Quét tìm và xóa toàn bộ link cache trong localStorage như mobile
          var keysToRemove = [];
          for (var i = 0; i < localStorage.length; i++) {
              var k = localStorage.key(i);
              if (k && (k.indexOf("_link_") !== -1 || k.indexOf("paradise_cachedFormLinks") !== -1 || k.indexOf("Link") !== -1 || k.indexOf("URL") !== -1)) {
                  keysToRemove.push(k);
              }
          }
          keysToRemove.forEach(function(k){ localStorage.removeItem(k); });

          // 2. Cập nhật cookie
          document.cookie = "LanguageID=" + selectedLang + "; path=/; max-age=31536000";
          document.cookie = "Language=" + selectedLang + "; path=/; max-age=31536000";
          try {
              localStorage.setItem("ManualLangChange_Target", selectedLang);
              localStorage.setItem("ManualLangChange_Step", "1");
          } catch(e) {}

          // 3. Cập nhật Database
          try {
              if (typeof AjaxHPAParadise === "function") {
                  AjaxHPAParadise({
                      data: {
                          name: "tblCommonSettingEditable_UpdateLanguage",
                          param: ["@LoginID", window.LoginID || window.UserID || 0, "@LanguageID", selectedLang]
                      }
                  });
              }
          } catch(e) {}

          // 4. Chuyển đổi ngôn ngữ và reload
          if (typeof changeLanguage === "function") {
              window.LanguageID = "";
              var res = changeLanguage(selectedLang);
              if (res && typeof res.then === "function") {
                  res.then(function() { window.location.reload(); });
              } else {
                  setTimeout(function() { window.location.reload(); }, 300);
              }
          } else if (typeof window.ChangeLanguageIDParadise === "function") {
              window.ChangeLanguageIDParadise(selectedLang);
              setTimeout(function() { window.location.reload(); }, 300);
          } else {
              setTimeout(function() { window.location.reload(); }, 300);
          }
      };

      // Nâng z-index của popup xác nhận lên trước mọi Drawer và Overlay
      var confirmOverlay = document.getElementById("vc-vu-confirm-popup");
      if (confirmOverlay) {
          confirmOverlay.style.setProperty("z-index", "200000", "important");
      }

      if (typeof window.showConfirmPopup === "function") {
          window.showConfirmPopup({
              title: "%ConfirmChangeLanguage_Title%",
              message: "%ConfirmChangeLanguage_Message%",
              content: "%ConfirmChangeLanguage_Message%",
              YesText: "%ConfirmYes%",
              NoText: "%ConfirmNo%",
              yesText: "%ConfirmYes%",
              noText: "%ConfirmNo%",
              confirmText: "%ConfirmYes%",
              cancelText: "%ConfirmNo%",
              onYes: function () {
                  doChangeLang();
              },
              onNo: function () {}
          });
      } else if (window.uiManager && typeof window.uiManager.showConfirmPopup === "function") {
          window.uiManager.showConfirmPopup({
              title: "%ConfirmChangeLanguage_Title%",
              content: "%ConfirmChangeLanguage_Message%",
              confirmText: "%ConfirmYes%",
              cancelText: "%ConfirmNo%",
              onConfirm: function() {
                  doChangeLang();
              }
          });
      } else {
          if (confirm("%ConfirmChangeLanguage_Message%")) {
              doChangeLang();
          }
      }
  });

  // Nút Chỉnh sửa / Hồ sơ
  $(document).off("click.openProfileMobile").on("click.openProfileMobile", "#btnOpenProfileSettings", function(e) {
      e.preventDefault();
      e.stopPropagation();
      window.closeSettingsDrawerMobile();
      openFormParam("HR_StaffInformation_List_2", {
          EmployeeID: window.EmployeeID,
          LoginID: LoginID,
          LanguageID: LanguageID,
          TableName: "-1",
          Isweb: 1
      });
  });

  // Nút Trợ giúp & Hỗ trợ
  $(document).off("click.openHelpMobile").on("click.openHelpMobile", "#btnOpenHelpSettings", function(e) {
      e.preventDefault();
      e.stopPropagation();
      openMobileDrawerComponent("dashboard_mobile_Settings_HelpSupport_html", "#dashboard_mobile_Settings_HelpSupportDrawer", "mobileHelpContainer");
  });


  // Switch Theme tức thì 0ms: Hỗ trợ click vào toàn bộ vùng dòng rowToggleTheme hoặc click thẳng vào switch toggle
  $(document).off("click.rowToggleThemeMobile").on("click.rowToggleThemeMobile", "#rowToggleTheme", function(e) {
      var sw = document.getElementById("toggleThemeOption");
      if (!sw) return;

      // Nếu người dùng click vào chính thẻ input switch thì để trình duyệt tự đảo checked
      var isDirectInput = (e.target === sw);
      if (!isDirectInput) {
          e.preventDefault();
          sw.checked = !sw.checked;
          $(sw).trigger("change");
      }
  });

  $(document).off("change.toggleThemeMobile").on("change.toggleThemeMobile", "#toggleThemeOption", function(e) {
      var targetDark = this.checked;
      var newTheme = targetDark ? ''dark'' : ''light'';
      if (typeof window.applyTheme === "function") {
          window.applyTheme(newTheme);
      } else {
          if (targetDark) document.body.classList.add("dark-mode");
          else document.body.classList.remove("dark-mode");
      }
      try {
          localStorage.setItem("theme", newTheme);
          localStorage.setItem("darkMode", targetDark ? ''enabled'' : ''disabled'');
      } catch(ex) {}
  });

  // SỰ KIỆN CLICK AVATAR: BẬT/TẮT DRAWER CÀI ĐẶT MOBILE ĐỒNG BỘ 0MS (ĐÓNG THÔNG BÁO NẾU ĐANG MỞ)
  $(document).off("click.avatarToggleDesktop").on("click.avatarToggleDesktop", "#avatarTrigger, .avatar-trigger, .profile-pic-container", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var drawer = document.getElementById("mainSettingsDrawer");
      if (drawer && drawer.classList.contains("open")) {
          window.closeSettingsDrawerMobile();
      } else {
          if (typeof window.closeNotificationDrawerMobile === "function") {
              window.closeNotificationDrawerMobile();
          }
          window.openSettingsDrawerMobile();
      }
  });

  // =========================================================================
  // 3. ĐIỀU KHIỂN CÁC SỰ KIỆN HỆ THỐNG KHÁC (BELL, LOGOUT, CLICK OUTSIDE)
  // =========================================================================
  // Handle bell icon click -> mở mobile notification drawer kế thừa từ mobile (ĐÓNG CÀI ĐẶT NẾU ĐANG MỞ)
  $(document).off("click.mobileNoti").on("click.mobileNoti", ".notifications", function(e) {
      e.stopPropagation();
      if (typeof window.closeSettingsDrawerMobile === "function") {
          window.closeSettingsDrawerMobile();
      }
      var notiDrawer = document.querySelector("#dashboard_mobile_Notification_html .notification-drawer, #mobileNotificationContainer .notification-drawer, .notification-drawer");
      if (notiDrawer && notiDrawer.classList.contains("open")) {
          if (typeof window.closeNotificationDrawerMobile === "function") {
              window.closeNotificationDrawerMobile();
          } else {
              notiDrawer.classList.remove("open");
              document.body.style.overflow = "";
          }
          return;
      }
      var notiContainer = document.getElementById("mobileNotificationContainer");
      if (notiContainer) {
          notiContainer.style.removeProperty("visibility");
          notiContainer.style.removeProperty("pointer-events");
          notiContainer.style.removeProperty("z-index");
      }
      if (notiDrawer) {
          notiDrawer.style.removeProperty("visibility");
          notiDrawer.style.removeProperty("pointer-events");
          notiDrawer.style.removeProperty("z-index");
          notiDrawer.style.removeProperty("transform");
      }
      openMobileDrawerComponent("dashboard_mobile_Notification_html", "#dashboard_mobile_Notification_html .notification-drawer", "mobileNotificationContainer");
  });

  // Global delegation cho Cài đặt trên Web: Đăng xuất dùng flow Web
  $(document).off("click.webSettingsLogout").on("click.webSettingsLogout", "#settingsLogoutBtn", function(e) {
      if (typeof window.isWeb !== "undefined" && window.isWeb === 2) return; // Mobile app giữ nguyên
      e.preventDefault();
      e.stopPropagation();
      window.closeSettingsDrawerMobile();

      var pLogout = document.getElementById("profileLogout") || document.querySelector(".logout-section");
      if (pLogout) {
          pLogout.click();
      } else if (typeof showSuccessModalAddNew === "function") {
          var textNoti = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "<p class=''fs-6 mb-0''>Xác nhận đăng xuất khỏi tài khoản?</p>" : "<p class=''fs-6 mb-0''>Confirm logout of account?</p>";
          var textConf = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "Đăng xuất" : "Logout";
          var textCanc = (window.LanguageID === "VN" || typeof LanguageID === "undefined" || LanguageID === "VN") ? "Ở lại" : "Cancel";
          showSuccessModalAddNew(textNoti, textConf, textCanc, function() {
              if (typeof LogOut === "function") LogOut();
              else window.location.href = (window.APPLICATION_ADDRESS || "") + "/paradisehrm/logout";
          });
      }
  });

  // Handle logout button click -> show logout confirmation modal
  if (profileLogout) {
    profileLogout.addEventListener(''click'', function(e) {
      e.stopPropagation();
      window.closeSettingsDrawerMobile();
      var textNotification = LanguageID === "VN" ? "<p class=''fs-6 mb-0''>Xác nhận đăng xuất khỏi tài khoản?</p>" : "<p class=''fs-6 mb-0''>Confirm logout of account?</p>";
      var textConfirm = LanguageID === "VN" ? "Đăng xuất" : "Logout";
      var textCancel = LanguageID === "VN" ? "Ở lại" : "Cancel";

      if (typeof showSuccessModalAddNew === "function") {
        showSuccessModalAddNew(
          textNotification,
          textConfirm,
          textCancel,
          function() {
            if (window.ParadiseOption && ParadiseOption.AppInfoPackageName === "com.vietinsoft.onshiftparadisehr") {
              LogOut();
              return;
            }
            logOutNewLayOut();
          },
          function() {},
          { textColor: "#fff", bgColor: "#dc3545" },
          { textColor: "#fff", bgColor: "#0d6efd" }
        );
      } else if (typeof showConfirmDeleteModal === "function") {
        showConfirmDeleteModal(textNotification, textConfirm, textCancel)
          .then(function() {
            if (window.ParadiseOption && ParadiseOption.AppInfoPackageName === "com.vietinsoft.onshiftparadisehr") {
              LogOut();
              return;
            }
            logOutNewLayOut();
          })
          .catch(function() {});
      } else {
        if (confirm(LanguageID === "VN" ? "Xác nhận đăng xuất?" : "Confirm logout?")) {
          logOutNewLayOut();
        }
      }
    });
  }

  // Close notification container when clicking outside
  document.addEventListener(''click'', function(event) {
    if (notificationContainer && notificationContainer.style.display === ''block'') {
      if (bellIcon && !bellIcon.contains(event.target) && !notificationContainer.contains(event.target)) {
        notificationContainer.style.display = ''none'';
      }
    }
  });

  function logOutNewLayOut() {
    window.location.href = (window.APPLICATION_ADDRESS || window.APPLICATIONADDRESS || "") + "/paradisehrm/logout";
  }

  var avatarTrigger = document.getElementById(''avatarTrigger'');
  var userDetails = document.getElementById(''userDetails'');
  var randomAvatar = document.getElementById(''randomAvatar'');
  var userName = document.getElementById(''userName'');
  var positionuser = $("#positionuser");

  // NÚT ĐÓNG THÔNG BÁO (NÚT MŨI TÊN BACK HOẶC NÚT CLOSE TRONG DRAWER THÔNG BÁO)
  $(document).off("click.closeNotificationMobile").on("click.closeNotificationMobile", "#closeNotificationDrawerBtn, #closeNotificationDrawer, #dashboard_mobile_Notification_html .back-btn, .notification-drawer .back-btn", function(e) {
      e.preventDefault();
      e.stopPropagation();
      if (typeof window.closeNotificationDrawerMobile === "function") {
          window.closeNotificationDrawerMobile();
      } else {
          var notiDrawers = document.querySelectorAll("#dashboard_mobile_Notification_html .notification-drawer, #mobileNotificationContainer .notification-drawer, .notification-drawer, #mainNotificationDrawer");
          notiDrawers.forEach(function(dr) { dr.classList.remove("open"); });
          document.body.style.overflow = "";
      }
  });

  // CLICK RA NGOAI (CLICK OUTSIDE): DONG SETTINGS DRAWER HOAC THONG BAO
  $(document).off("click.closeDrawersOutside").on("click.closeDrawersOutside", function(e) {
      // 1. Dong settings drawer neu click ra ngoai
      var drawer = document.getElementById("mainSettingsDrawer");
      if (drawer && drawer.classList.contains("open")) {
          var isInside = drawer.contains(e.target);
          var isAvatar = e.target.closest("#avatarTrigger, .avatar-trigger, .profile-pic-container");
          var isModal = e.target.closest(".modal, .dx-overlay-wrapper, .swal2-container, #confirmDeleteModal, #customSuccessModal, #paradiseSettingsModal, #vc-vu-confirm-popup, .VC-Vu-popup, .VC-Vu-component-overlay");
          if (!isInside && !isAvatar && !isModal) {
              window.closeSettingsDrawerMobile();
          }
      }

      // 2. Dong userDetails cu neu con
      var ud = document.getElementById("userDetails");
      if (ud && ud.classList.contains("active")) {
          var isClickInsideUser = ud.contains(e.target);
          var isClickAvatar = e.target.closest("#avatarTrigger, .avatar-trigger, .profile-pic-container");
          var isClickModal = e.target.closest(".modal, .dx-overlay-wrapper, .swal2-container, #confirmDeleteModal, #customSuccessModal, #paradiseSettingsModal");
          if (!isClickInsideUser && !isClickAvatar && !isClickModal) {
              ud.classList.remove("active");
          }
      }

      // 3. Dong Thong bao neu click ra ngoai
      var notiDrawer = document.querySelector("#dashboard_mobile_Notification_html .notification-drawer, #mobileNotificationContainer .notification-drawer, .notification-drawer, #mainNotificationDrawer");
      if (notiDrawer && notiDrawer.classList.contains("open")) {
          var isClickInsideNoti = notiDrawer.contains(e.target);
          var isClickBell = e.target.closest(".notifications");
          var isModalNoti = e.target.closest(".modal, .dx-overlay-wrapper, .swal2-container, #confirmDeleteModal, #customSuccessModal, #paradiseSettingsModal, #vc-vu-confirm-popup, .VC-Vu-popup, .VC-Vu-component-overlay");
          if (!isClickInsideNoti && !isClickBell && !isModalNoti) {
              if (typeof window.closeNotificationDrawerMobile === "function") {
                  window.closeNotificationDrawerMobile();
              } else {
                  notiDrawer.classList.remove("open");
                  document.body.style.overflow = "";
              }
          }
      }
  });

        function showNotification(title, message, type, direction = "up-push", position = "bottom right") {
            DevExpress.ui.notify(
                {
                    message: message,
                    type: type,
                    displayTime: 2500,
                },
                {
                    position,
                    direction,
                }
            );
        }
</script>

<script>
(() => {
  window.ParadiseOption = window.ParadiseOption || {};
  var toggleButton = document.getElementById(''theme-toggle'');
  var themeIcon = document.getElementById(''themeIcon'');
  var htmlElement = document.documentElement;
  var body = document.body;
  window.isDarkMode = true;

  var savedTheme = localStorage.getItem(''theme'') || ''dark'';

  function applyTheme(theme) {
    if (theme === ''dark'') {
      window.isDarkMode = true;
      body.classList.add(''dark-mode'', ''bg-dark'', ''text-light'');
      body.classList.remove(''bg-light'', ''text-dark'');
      if (themeIcon) themeIcon.classList.replace(''bi-sun'', ''bi-moon-stars-fill'');

      try {
        if (typeof ChangeThemeParadise === "function") {
          ChangeThemeParadise("dx.fluent.saas.dark");
        }
      } catch(e) {}
      try {
        if (typeof DevExpress !== "undefined" && DevExpress.ui && DevExpress.ui.themes) {
          DevExpress.ui.themes.current("fluent.saas.dark");
        }
      } catch(e) {}
    } else {
      window.isDarkMode = false;
      body.classList.remove(''dark-mode'', ''bg-dark'', ''text-light'');
      body.classList.add(''bg-light'', ''text-dark'');
      if (themeIcon) themeIcon.classList.replace(''bi-moon-stars-fill'', ''bi-sun'');

      try {
        if (typeof ChangeThemeParadise === "function") {
          ChangeThemeParadise("dx.fluent.blue.light");
        }
      } catch(e) {}
      try {
        if (typeof DevExpress !== "undefined" && DevExpress.ui && DevExpress.ui.themes) {
          DevExpress.ui.themes.current("fluent.blue.light");
        }
      } catch(e) {}
    }
    htmlElement.setAttribute(''data-bs-theme'', theme);
    body.setAttribute(''data-bs-theme'', theme);

    // Đồng bộ switch trong Cài đặt nếu đang mở
    var swOpt = document.getElementById("toggleThemeOption");
    if (swOpt) swOpt.checked = (theme === "dark");
  }

  window.applyTheme = applyTheme;
  // Apply dark theme immediately on boot
  applyTheme(savedTheme);

  // Delegation cho nút theme-toggle trên Header Bar
  $(document).off("click.navThemeToggle").on("click.navThemeToggle", "#theme-toggle", function(e) {
      e.preventDefault();
      e.stopPropagation();
      var isDark = document.body.classList.contains("dark-mode");
      var newTheme = isDark ? "light" : "dark";
      savedTheme = newTheme;
      applyTheme(newTheme);
      try {
          localStorage.setItem("theme", newTheme);
          localStorage.setItem("darkMode", newTheme === "dark" ? "enabled" : "disabled");
      } catch(ex) {}
  });

  if (window.dotNetReadyPromise) {
    window.dotNetReadyPromise.then(() => {
      applyTheme(savedTheme);
    });
  }
})();
</script>

<script>
var tabList = document.getElementById(''tabList'');
			var dropdown = tabList.querySelector(''.dropdown'');
			var dropdownMenu = dropdown.querySelector(''.dropdown-menu'');

			var currentOverflowTab = [];

			function createTabHead(menuId, menuName) {

			  if (document.getElementById(`tab-${menuId}`)) {
				
				return null;
			}

			var tabId = `dynamic-tab-${menuId}`;
			var paneId = `dynamic-pane-${menuId}`;

			// Create <li> element
			const li = document.createElement(''li'');
			li.classList.add(''nav-item'');
			li.setAttribute(''role'', ''presentation'');
			li.id = `tab-${menuId}`;

			// Create <button> element
			const button = document.createElement(''button'');
			button.classList.add(''nav-link'');
			button.id = tabId;
			button.setAttribute(''data-bs-toggle'', ''tab'');
			button.setAttribute(''data-bs-target'', `#${paneId}`);
			button.type = ''button'';
			button.setAttribute(''role'', ''tab'');
			button.setAttribute(''aria-controls'', paneId);
			button.setAttribute(''aria-selected'', ''false'');
			button.setAttribute(''onclick'', `onTabClick(''${menuId}'')`);

			// Add menuName text to button
			const buttonText = document.createTextNode(menuName);
			button.appendChild(buttonText);

			// Create <span> element for the close icon
			const span = document.createElement(''span'');
			span.classList.add(''ms-1'');
			span.setAttribute(''onclick'', `removeTab(''${menuId}'', ''${menuName}'')`);
			span.innerHTML = ''&times;'';

			// Append the span to the button
			button.appendChild(span);

			// Append the button to the li element
			li.appendChild(button);

			return li;
		}


		function deleteListItemByHref(hrefValue) {
			// Find the <a> element with the specified href
			const anchor = document.querySelector(`a[href="${hrefValue}"]`);

			// If the anchor is found, remove the parent <li> element
			if (anchor) {
				const li = anchor.closest(''li''); // Find the closest <li> ancestor
				if (li) {
					li.remove(); // Remove the <li> element from the DOM
				}
			}
		}


			function updateTabs() {

			 currentOverflowTab.slice().reverse().forEach(item => {
			
				  const newTab = createTabHead(item.id, item.name);
					if (newTab) {
						tabList.insertBefore(newTab, dropdown);
						addRightClickEventForTab(item.id);
						deleteListItemByHref(`#tab-${item.id}`);
					}
			  });

			  currentOverflowTab = [];

			//dropdownMenu.innerHTML = '''';
			const tabItems = Array.from(tabList.querySelectorAll('':scope > li.nav-item:not(.dropdown)''));
			
		
			const availableWidth = tabList.clientWidth - dropdown.offsetWidth;
			let totalWidth = 1;
			let lastVisibleIndex = tabItems.length - 1;

			for (let i = 0; i < tabItems.length; i++) {

				totalWidth += tabItems[i].offsetWidth;
				 if (totalWidth > availableWidth) {
				  lastVisibleIndex = i - 1;
				  break;
				}
			
			 }
			
			 if (lastVisibleIndex < tabItems.length - 1) {
				 for (let i = tabItems.length - 1; i > lastVisibleIndex; i--) {
				
				  prependDropdownItem(`${extractDesiredText(tabItems[i].innerText)}`, `#${tabItems[i].id}`);
				
				  tabItems[i].dataset.inDropdown = ''true'';
				}

			tabItems.forEach(item => {
				if (item.dataset.inDropdown) {
				  $(`#tab-${item.id.replace(''tab-'', '''')}`).remove();
				
				  delete item.dataset.inDropdown;
				}
			  });
				
		
			 }

			 if(currentOverflowTab.length > 0){
				 dropdown.classList.remove(''d-none'');
			 }else{
				dropdown.classList.add(''d-none'');
			 }

			}
			  // Function to create and prepend a new dropdown item
			  function prependDropdownItem(text, href) {
				// Create the <li> element
				const li = document.createElement(''li'');
				
				// Create the <a> element
				const a = document.createElement(''a'');
				a.classList.add(''dropdown-item'');
				a.href = href;
				a.setAttribute(''data-bs-toggle'', ''tab'');
				a.textContent = text;

				 const menuId = href.replace(''#tab-'', '''');

				currentOverflowTab.push({id: menuId, name: text })
				
				a.addEventListener(''click'', function(event) {

				ChangePositionRecent(menuId);
				document.querySelector(`#point-${menuId}`).style.display = ''block'';
				highLightApp(menuId);

				 const tabId = `dynamic-tab-${menuId}`;
				 const paneId = `dynamic-pane-${menuId}`;
				 const menuName = text;


				
					if (!$(''#tab-'' + menuId).length) {
					
					  const tabNavItem = `
					  <li class="nav-item" role="presentation" id="tab-${menuId}">
						<button
						  class="nav-link"
						  id="${tabId}"
						  data-bs-toggle="tab"
						  data-bs-target="#${paneId}"
						  type="button"
						  role="tab"
						  aria-controls="${paneId}"
						  aria-selected="false"
						  onclick="onTabClick(''${menuId}'')"
						>
						   ${menuName}
						  <span class="ms-1" onclick="removeTab(''${menuId}'',''${menuName}'')">&times;</span>
						</button>
					  </li>
					`;
					$(''#tabList'').prepend(tabNavItem);
					 currentOverflowTab = currentOverflowTab.filter(item => item.id !== menuId);
					 addRightClickEventForTab(menuId);
					 li.remove();
					 const appToAdd = findAppById(menuId);
			      	 OpenFormContent(appToAdd.className);
					}

					const existingTab = new bootstrap.Tab(document.getElementById(`dynamic-tab-${menuId}`));
					existingTab.show();
					 updateTabs();
				
				
				});

				// Append the <a> to the <li>
				li.appendChild(a);

			
				// Prepend the new <li> to the <ul>
				dropdownMenu.insertBefore(li, dropdownMenu.firstChild);
			
			  }


			  // Get the dropdown toggle element
			var dropdownToggle = document.getElementById(''dropdownToggle'');

			// Add a click event listener
			dropdownToggle.addEventListener(''click'', function(event) {
			  event.preventDefault(); // Prevent the default link behavior

			  // Get the associated dropdown menu
			  const dropdownMenu = document.querySelector(''.dropdown-menu[aria-labelledby="dropdownToggle"]'');

			  // Toggle the ''show'' class
			  dropdownMenu.classList.toggle(''show'');
			});


			function closeDropdown(event) {
			  // Check if the dropdown menu is open
			  if (dropdownMenu.classList.contains(''show'')) {
				// Check if the click is outside the dropdown menu and the toggle button
				if (!dropdownMenu.contains(event.target) && !dropdownToggle.contains(event.target)) {
				  // Hide the dropdown menu
				  dropdownMenu.classList.remove(''show'');
				}
			  }
			}

			function extractDesiredText(innerText) {
			  // Step 1: Trim leading and trailing whitespace
			  let trimmedText = innerText.trim();

			  // Step 2: Split the string at the ''×'' character
			  let parts = trimmedText.split(''×'');

			  // Step 3: Trim the first part to remove any extra whitespace
			  let desiredText = parts[0].trim();

			  // Return the desired text
			  return desiredText;
			}

			document.addEventListener(''click'', closeDropdown);
			window.addEventListener(''resize'', updateTabs);
			updateTabs();
</script>

<script>
function extractIdsAndHrefs() {
				// Get all <li> elements inside the <ul> with id "tabList"
				const tabList = document.querySelectorAll(''#tabList > li'');
				const extractedArray = [];

				tabList.forEach(li => {
					// Extract the id of the <li> if present and remove ''tab-'' prefix
					if (li.id) {
						const cleanedId = li.id.replace(''tab-'', '''');
						extractedArray.push(cleanedId);
					}

					// If the <li> has the class "dropdown", extract all href values from <a> tags within it
					if (li.classList.contains(''dropdown'')) {
						const links = li.querySelectorAll(''a'');
						links.forEach(link => {
							  const hrefValue = link.getAttribute(''href'');
								// Only add the href if it is not just "#" or an empty string
								if (hrefValue && hrefValue !== "#") {
									const cleanedHref = hrefValue.replace(''#tab-'', '''');
									extractedArray.push(cleanedHref);
								}
						});
					}
				});

				return extractedArray;
			}

			function CloseAllTab() {
			  if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
			  showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab?</p>`)
				  .then((result) => {
					
			      	const listDelete = extractIdsAndHrefs();
					listDelete.forEach(item =>{
						//document.querySelector(`#point-${item}`).style.display = ''none'';
						deleteTab(`${item}`);
					});
					 currentOverflowTab = [];
					 updateTabs();
					 CloseTabs();
				  })
				  .catch((error) => {
					
				  });
			
			}

			function CloseOtherTab(){
				 if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
				 showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab khác?</p>`)
				  .then((result) => {
					const listTabLeft = getLeftElements(extractIdsAndHrefs(),currentSelectedMenu);
					const listTabRight = getRightElements(extractIdsAndHrefs(),currentSelectedMenu);
			      	currentOverflowTab = [];
			      	CloseTab([...listTabLeft,...listTabRight]);
				  })
				  .catch((error) => {
					
				  });
			
			}


			function CloseAllTabOnLeft(){
				 if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
				 showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab bên trái?</p>`)
				  .then((result) => {
					const listDelete = getLeftElements(extractIdsAndHrefs(),currentSelectedMenu);
			      	CloseTab(listDelete);
				  })
				  .catch((error) => {
					
				  });
			
			}

			function CloseAllTabOnRight(){
				 if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
				 showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab bên phải?</p>`)
				  .then((result) => {
					const listDelete = getRightElements(extractIdsAndHrefs(),currentSelectedMenu);
					//console.log(`Close Right tab`);
					 currentOverflowTab = [];
			      	CloseTab(listDelete);
				  })
				  .catch((error) => {
					
				  });

			}

			function CloseThisTab(){
				   if (typeof hideMenuContextTab === ''function'') { hideMenuContextTab(); }
				   showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tab "${currentSelectedMenuName}"?</p>`)
					  .then((result) => {
						const listDelete = [currentSelectedMenu];
			      		CloseTab(listDelete);
						if(getTabCount() === 0){
						 CloseTabs();
						}
					  })
					  .catch((error) => {
						
					  });
			}

			function RemoveHighLightApp(){
			   console.log(`Delete highlight`);
				const element = document.querySelector(`.highLightApp`);
				if (element) {
					element.classList.remove(`highLightApp`);
				}

			}

			function CloseTab(listTab){
				listTab.forEach(item =>{
					deleteTab(`${item}`);
                    // Xóa tab khỏi lịch sử khi tab bị đóng
                    if(typeof tabHistory !== ''undefined'') {
                        tabHistory = tabHistory.filter(id => id !== `dynamic-tab-${item}`);
                    }
				});
				updateTabs();
                // Kiểm tra lịch sử để mở lại tab gần nhất
                if (typeof tabHistory !== ''undefined'' && tabHistory.length > 0) {
                    const lastActiveTabId = tabHistory[tabHistory.length - 1];
                    const lastTabEl = document.getElementById(lastActiveTabId);
                    if (lastTabEl) {
                        const lastTab = new bootstrap.Tab(lastTabEl);
                        lastTab.show();
                        return;
                    }
                }
				// Fallback: Activate the first available tab nếu lịch sử bị trống
				const firstTabEl = document.querySelector(''#tabList button.nav-link'');
				if (firstTabEl) {
					const firstTab = new bootstrap.Tab(firstTabEl);
					firstTab.show();
				} else {
					// No tabs left, clear content
					$(''#tabContent'').empty();
				}
			}



			function deleteTab(menuId) {

			const elementApp = document.querySelector(`.dock .icon.${menuId}`);
			if(elementApp){
	        elementApp.classList.remove(`highLightApp`);
			}

			const tabId = `dynamic-tab-${menuId}`;
			// Select the tab element (button in the <li> element)
			const tabElement = document.getElementById(tabId);

			if (tabElement) {
				// Find the corresponding tab pane by extracting its target ID
				const tabTarget = tabElement.getAttribute(''data-bs-target'');
				const tabPane = document.querySelector(tabTarget);

				// Remove the tab button and the tab pane from the DOM
				tabElement.parentElement.remove(); // Remove the entire <li> element

				if (tabPane) {
					tabPane.remove(); // Remove the corresponding tab pane
				}

			} else {
				deleteListItemByHref(`#tab-${menuId}`);
				
			}
			const smallCircle = document.querySelector(`#point-${menuId}`);
			if(smallCircle){
				smallCircle.style.display = ''none'';
			}
			//document.querySelector(`#point-${menuId}`).style.display = ''none'';
		}


		function getLeftElements(array, char) {
			// Find the index of the character
			const indexOfChar = array.indexOf(char);

			// Slice the array to get all elements on the left of the character
			const leftElements = array.slice(0, indexOfChar);

			return leftElements;
		}

		function getRightElements(array, char) {
			// Find the index of the character
			const indexOfChar = array.indexOf(char);

			// Slice the array to get all elements on the right of the character
			const rightElements = array.slice(indexOfChar + 1);

			return rightElements;
		}

//LuongNQ
/*
		   function showLoadingOverlayIn() {
      document.getElementById(''loading-overlay'').style.display = ''flex'';

    }

    function hideLoadingOverlayIn() {
      document.getElementById(''loading-overlay'').style.display = ''none'';
    } */

	//Thang
		function closepopup(IDNamePopup) {
			$(IDNamePopup).closest(".dx-overlay-content").find(".dx-icon-close").click();
		}
</script>

<script>
function observeChildAddition(parentElement, timeoutDuration = 5000) {
			const observer = new MutationObserver(function (mutationsList, observerInstance) {
			for (const mutation of mutationsList) {
				if (mutation.type === ''childList'' && mutation.addedNodes.length > 0) {
				// Node(s) have been added
				// Clear the timeout since a node was added
				clearTimeout(timeoutId);

				// Stop observing further changes (optional)
				observerInstance.disconnect();
				

				// Hide the loader or perform any other action
				const loader = parentElement.querySelector(''.tab-loader'');
				if (loader) {
					loader.classList.add(''d-none'');
				}

				// Optionally, handle the added nodes
				// onChildAdded(mutation.addedNodes, observerInstance, parentElement);

				break; // Exit the loop since we''ve handled the addition
				}
			}
			});

			// Start observing the parent element
			observer.observe(parentElement, {
			childList: true,
			subtree: true,
			});

			// Set a timeout to handle the case where no node is added within the specified duration
			const timeoutId = setTimeout(() => {
		

			// Disconnect the observer to prevent further monitoring
			observer.disconnect();
			
			// Hide the loader or perform any other action
			const loader = parentElement.querySelector(''.tab-loader'');
			if (loader) {
				loader.classList.add(''d-none'');
			}

			// Optionally, perform additional actions, such as displaying a message to the user
			// e.g., alert(''No content loaded. Please try again later.'');

			}, timeoutDuration);
		}
</script>

<script>
window.TypeLayout = 0;

  function openFormParam(className, param, isPopup = false) {

   const appList = (typeof apps !== "undefined" && Array.isArray(apps)) ? apps : (window.apps || []);
   const appConfig = appList.find(x => (x.className && x.className.toLowerCase() ===
     className.toLowerCase().replace("datasetting.", "")) ||
     x.id == className);
   const showDialog = appConfig?.showDialog;

   if(isPopup || (showDialog && showDialog !== "0")) {
    openFormParamPopup(className, param, showDialog);
    return;
   }
   if (typeof stackOpenForm !== "undefined" && stackOpenForm.open) {
       stackOpenForm.open(`${className}`);
   }
   const openApp = appList.filter(
    (item) =>
     (item.className && item.className.toLowerCase() ===
      className.toLowerCase().replace("datasetting.", "")) ||
     item.id == className
   )[0];

   if (!openApp) {
       console.warn("openFormParam: Menu không tồn tại hoặc chưa được phân quyền:", className);
       return;
   }

   const listDelete = [openApp.id];
   if (typeof CloseTab === "function") {
       try { CloseTab(listDelete); } catch(e) {}
   }

   // const paramJson = convertObjectToStringWithPrefixedKeys(param);

   if (typeof addNewTab === "function") {
       addNewTab(openApp.id, openApp.name, openApp.className, param);
   }
   // taidang: Đã loại bỏ openMenu(openApp) gọi đúp addNewTab
   if (typeof onTabClick === "function") { try { onTabClick(openApp.id); } catch(e) {} }
   if (typeof appsDock !== "undefined" && !appsDock.some((appItem) => appItem.id === openApp.id)) {
    if (typeof currentAppIdOpen !== "undefined") currentAppIdOpen.add(openApp.id);
   }
   if (typeof ChangePositionRecent === "function") ChangePositionRecent(openApp.id);
   if (openApp.className) {
    try {
        let pt = document.querySelector(`#point-${openApp.id}`);
        if (pt) pt.style.display = "block";
    } catch(e) {}
   }
  }


  function openFormParamPopup(className, param, showDialog) {
   const appList = (typeof apps !== "undefined" && Array.isArray(apps)) ? apps : (window.apps || []);
   const openApp = appList.filter(
    (item) =>
     (item.className && item.className.toLowerCase() ===
      className.toLowerCase().replace("datasetting.", "")) ||
     item.id == className
   )[0];

   if (!openApp) {
       console.warn("openFormParamPopup: Menu không tồn tại hoặc chưa được phân quyền:", className);
       return;
   }

   let popupOptions = {
    title: openApp.name,
    visible: true,
    shading: true,
    showCloseButton: true,
    closeOnOutsideClick: true,
     onHiding: function (e) {
         if (typeof e.component.customCloseAction === "function" && !e.component._isForceClosing) {
             e.cancel = true; // Chặn mọi hành động đóng (X, Esc, Click outside)
             e.component.customCloseAction(e.component);
         }
     },
    onHidden: function (arg) {
     arg.component.dispose();
    },
  onShown: function (arg) {
    const $overlayContent = $(arg.component.content())
        .closest(''.dx-overlay-content'');

    // Title bar background & color
    $overlayContent
        .find(''.dx-popup-title'')
        .addClass(''bg-success'')
        .css(''color'', ''white'');

    // Close button: đổi màu trắng + bỏ hover effect
    $overlayContent
        .find(''.dx-closebutton'')
        .css(''background'', ''transparent'')
        .on(''mouseenter mouseleave'', function(e) {
            e.stopImmediatePropagation();
        });

    $overlayContent
        .find(''.dx-closebutton .dx-icon'')
        .css(''color'', ''white'');
},
    contentTemplate: async function (contentElement) {
    let id = uuidv4();
    contentElement.attr("id", id);

    contentElement.css({
        ''overflow''  : ''auto'',
        ''height''    : ''100%''
    });

    loadLiveData(openApp.className, id, param, true);
},
   };

   if (showDialog == "1") {
    popupOptions.width = "70%";
    popupOptions.height = "auto";
    popupOptions.maxHeight = "80%";
   } else if (showDialog === "2") {
    popupOptions.fullScreen = true;
   } else if (showDialog === "10") {
    popupOptions.width = "50%";
    popupOptions.height = "100%";
    popupOptions.position = { my: "left", at: "left", of: window };
   } else if (showDialog === "11") {
    popupOptions.width = "50%";
    popupOptions.height = "100%";
    popupOptions.position = { my: "right", at: "right", of: window };
   } else if (showDialog === "12") {
    popupOptions.width = "100%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "top", at: "top", of: window };
   } else if (showDialog === "13") {
    popupOptions.width = "100%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "bottom", at: "bottom", of: window };
   } else if (showDialog === "14") {
    popupOptions.width = "50%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "left top", at: "left top", of: window };
   } else if (showDialog === "15") {
    popupOptions.width = "50%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "left bottom", at: "left bottom", of: window };
   } else if (showDialog === "16") {
    popupOptions.width = "50%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "right top", at: "right top", of: window };
   } else if (showDialog === "17") {
    popupOptions.width = "50%";
    popupOptions.height = "50%";
    popupOptions.position = { my: "right bottom", at: "right bottom", of: window };
   } else {
    popupOptions.fullScreen = true;
   }

   let popup = $("<div>");
   $("body").append(popup);

   // Khởi tạo popup và lưu instance vào window để truy cập từ bên ngoài
   window.activePopupInstance = popup.dxPopup(popupOptions).dxPopup("instance");
  }

  /**
   * Hàm hỗ trợ thay đổi sự kiện nút tắt (nút X) của Popup từ bên ngoài
   * @param {Function} customCallback - Hàm xử lý logic tùy chỉnh khi nhấn nút X
   */
  window.alterPopupCloseButton = function (customCallback) {
      if (!window.activePopupInstance) return;

      const instance = window.activePopupInstance;
      // Tìm element nút close trong overlay của popup
      const $overlay = $(instance.content()).closest(''.dx-overlay-content'');
      const $closeBtn = $overlay.find(''.dx-closebutton'');

      if ($closeBtn.length) {
          $closeBtn.off("click").on("click", function (e) {
              // Chặn hành động đóng mặc định của DevExtreme
              e.stopImmediatePropagation();

              if (typeof customCallback === "function") {
                  customCallback(instance);
              } else {
                  instance.hide();
              }
          });
      }
  };



  function convertObjectToStringWithPrefixedKeys(obj) {
   // Step 1: Prefix each key with "@"
   let newObj = {};
   for (let key in obj) {
    if (obj.hasOwnProperty(key)) {
     newObj["@" + key] = obj[key];
    }
   }

   // Step 2: Convert the new object to a formatted string
   let entries = Object.entries(newObj).map(([key, value]) => `    "${key}": "${value}"`);
   let result = entries.join(",") ;
   return result;
  }
  function OpenFormParamMobile(className, param = {}) {
    // Tìm menu item từ className
    const menuItem = MenuJson.find(item => item.ClassName === className);
    if (!menuItem) {
        console.error("Không tìm thấy menu với className:", className);
        return;
    }
    stackOpenForm.open(`${className}`)
    const menuId = menuItem.MenuID;
    const targetClassName = className;

    // Ẩn tất cả menu và trang đang hiển thị
    Object.keys(createdMenuContainers).forEach(cn => {
        createdMenuContainers[cn].header.style.display = "none";
        createdMenuContainers[cn].content.style.display = "none";
    });
    $(".page").hide();
    $("#homePage").hide();

    // Ẩn header/back button gốc nếu có
    if (document.getElementById("backBtn")) {
        document.getElementById("backBtn").style.display = "none";
    }
    if (document.getElementById("contentContainer")) {
        document.getElementById("contentContainer").style.display = "none";
    }
    if (document.querySelector(".mobile-header")) {
        let originalHeader = document.querySelector(".mobile-header");
        if (!originalHeader.id || originalHeader.id === "headerTitle") {
            originalHeader.style.display = "none";
        }
    }

    // Tạo menu container nếu chưa có
    createMenuContainer(className, menuItem.Content || "");

    // Hiển thị menu mới
    if (createdMenuContainers[className]) {
        createdMenuContainers[className].header.style.display = "flex";
        createdMenuContainers[className].content.style.display = "block";
    }

    // Cập nhật trạng thái
    currentActiveMenuId = menuId;
    currentActiveMenu = className;
    isShowingContent = true;

    // Cập nhật nav
    $(".nav-item").removeClass("active");

    // Parse param
    let obj;
    if (typeof param === "object") {
        obj = param;
    } else {
        let jsonString = /{.*}/.test(param) ? param : "{" + param + "}";
        obj = JSON.parse(jsonString);
    }
     obj.isWeb = window.isWeb
     obj.LanguageID = window.LanguageID
     obj.LoginID = window.UserID

    // Lưu param toàn cục
    window[className + "_param"] = obj;

    // Lấy địa chỉ API
    let address;
    if (ParadiseOption.AppInfoPackageName === "com.vietinsoft.onshiftparadisehr" && ParadiseOption.ParadiseAPlurl) {
        address = APPLICATION_ADDRESS;
    } else {
        address = window.APPLICATION_ADDRESS;
    }

    // Nếu content đã được load, hiển thị luôn
    if (loadedContents[menuId]) {
        $("#dynamicContent_" + className).html(loadedContents[menuId]);
        return;
    }

    // Hiển thị loading
    //showLoadingMobile();
    console.log(obj)
    // Gọi dữ liệu và render
    fetchHtmlString(`${address}/hpamasterdata/datasetting?tablename=${className}&paradise_hrm=${encodeURIComponent(JSON.stringify({ ParamControls: obj }))}`)
        .then(htmlString => {
            loadedContents[menuId] = htmlString;

            if (createdMenuContainers[targetClassName]) {
                $(createdMenuContainers[targetClassName].menuContent).html(htmlString);
                $(createdMenuContainers[targetClassName].menuContent).show();

                $("html").css("scroll-behavior", "auto");
                document.documentElement.scrollTop = 0;
                document.body.scrollTop = 0;
                setTimeout(() => {
                    $("html").css("scroll-behavior", "");
                }, 10);
                setTimeout(() => {
                    if($(`#header_${targetClassName}`).hasClass("d-none"))
    $(`#contentContainer_${targetClassName}`).css("height", "calc(100vh - 65px)");
                }, 1200);

            }

            // iOSSwipeNav.bindEvents(".content-container:visible");

            hideLoadingMobile();
        })
        .catch(error => {
            console.error("Lỗi khi tải dữ liệu:", error);
            //alert(error)
            hideLoadingMobile();
            showErrorContent("Lỗi khi tải dữ liệu. Vui lòng thử lại.", targetClassName);
        });
}

function loadMenuContent(menuId, className, param = {}) {
    const menuItem = MenuJson.find(item => item.MenuID === menuId);
    if (!menuItem) {
         alert("Menu item not found:", menuId);
        return;
    }

    let obj;
    if (typeof param == "object") {
        obj = param;
    } else {
        let jsonString = /{.*}/.test(param) ? param : "{" + param + "}";
        obj = JSON.parse(jsonString);
    }
     obj.isWeb = window.isWeb
     obj.LanguageID =  window.LanguageID
     obj.LoginID = window.UserID;

    window[className + "_param"] = obj;

   if (loadedContents[menuId]) {
        $("#dynamicContent_" + className).html(loadedContents[menuId]);

        return;
    }


    loadLiveDataMobile(menuId, menuItem.ClassName, {}, className);
}

function loadLiveDataMobile(menuId, className, param = {}, targetClassName) {

    let obj;
    if (typeof param == "object") {
        obj = param;
    } else {
        let jsonString = /{.*}/.test(param) ? param : "{" + param + "}";
        obj = JSON.parse(jsonString);
    }
    obj.isWeb = window.isWeb
    obj.LanguageID = window.LanguageID
    obj.LoginID = window.UserID

    let address;
    if (ParadiseOption.AppInfoPackageName == "com.vietinsoft.onshiftparadisehr" && ParadiseOption.ParadiseAPlurl) {
        address = APPLICATION_ADDRESS;
 } else {
        address = window.APPLICATION_ADDRESS;
    }

    window[className + "_param"] = obj;

   console.log(`${address}/hpamasterdata/datasetting?tablename=${className}&paradise_hrm=${encodeURIComponent(JSON.stringify({ ParamControls: obj }))}`)

    fetchHtmlString(`${address}/hpamasterdata/datasetting?tablename=${className}&paradise_hrm=${encodeURIComponent(JSON.stringify({ ParamControls: obj }))}`)
        .then(htmlString => {
            // console.log(htmlString);

            loadedContents[menuId] = htmlString;


            if (createdMenuContainers[targetClassName]) {
                $(createdMenuContainers[targetClassName].menuContent).html(htmlString);
                $(createdMenuContainers[targetClassName].menuContent).show();
                $("html").css("scroll-behavior", "auto");
                document.documentElement.scrollTop = 0;
                document.body.scrollTop = 0;
                setTimeout(function() {
                    $("html").css("scroll-behavior", "");
                }, 10);
                setTimeout(() => {
                    if($(`#header_${targetClassName}`).hasClass("d-none"))
                        $(`#contentContainer_${targetClassName}`).css("height", "calc(100vh - 65px)");
                }, 1200);

                // iOSSwipeNav.bindEvents(".content-container:visible");
            }

            hideLoadingMobile();
        })
        .catch(error => {
            console.error("Error fetching HTML:", error);
            hideLoadingMobile();
            showErrorContent("Lỗi khi tải dữ liệu. Vui lòng thử lại.", targetClassName);
        });
}



window.EnableInstantCacheView = 1;
// Quản lý link cache theo từng Key độc lập trong Local Storage
window.getCacheFormLink = function(key) { try { return localStorage.getItem(key) || ""; } catch(e) { return ""; } };
window.setCacheFormLink = function(key, val) { try { localStorage.setItem(key, val); } catch(e) {} };
window.removeCacheFormLink = function(key) { try { localStorage.removeItem(key); } catch(e) {} };

function fetchHtmlString(url) {
    return new Promise(async (resolve, reject) => {
        try {
            if (!url.trim().startsWith("http"))
                url = window.origin + url.trim();

            let urlObj = new URL(url);
            let urlParams = urlObj.searchParams;
            let rawTableName = urlParams.get("tablename") || urlParams.get("TableName") || "";
            let TableName = rawTableName.replace("_html", "");
            let lang = window.LanguageID || "VN";
            let isWebLocal = window.isWeb || 1;
            let appAddress = window.APPLICATION_ADDRESS || "";
            let serverName = appAddress.replace(/\//g, "") || "root";
            let cacheKeyLink = serverName + "_link_" + TableName;
            let oldUrlFetch = localStorage.getItem(cacheKeyLink) || "";

            if (oldUrlFetch && oldUrlFetch.indexOf(appAddress) === -1) {
                oldUrlFetch = "";
            }

            let resolvedFromCache = false;

            // BƯỚC 1: Lấy từ Browser HTTP Disk Cache ngay lập tức (0ms delay)
            if (window.EnableInstantCacheView === 1 && oldUrlFetch) {
                try {
                    let responseOld = await $.ajax({ url: oldUrlFetch, cache: true, global: false });
                    let cachedHtml = "";
                    if (typeof responseOld === "string") {
                        try { cachedHtml = JSON.parse(responseOld).data[0][0].bytes; } catch(e) { cachedHtml = responseOld; }
                    } else if (responseOld?.data?.[0]?.[0]?.bytes) {
                        cachedHtml = responseOld.data[0][0].bytes;
                    }
                    if (cachedHtml) {
                        resolvedFromCache = true;
                        resolve(cachedHtml);
                    }
                } catch(e) { }
            }

            // BƯỚC 2: Kiểm tra phiên bản ngầm với Server (Stale-While-Revalidate)
            const checkAndFetchServer = async () => {
                try {
                    let currentVersion = "-1";
                    let verData = await AjaxHPAParadiseAsync({
                        showLoading: false,
                        data: {
                            name: "paradisepublic",
                            param: ["paradisepublic", TableName, "LanguageID", lang, "IsWeb", isWebLocal, "ParadiseVersion", "-1"]
                        }
                    });
                    let parsed = typeof verData === "string" ? JSON.parse(verData) : verData;
                    if (parsed?.data?.[0]?.[0]) currentVersion = parsed.data[0][0].ParadiseVersion;

                    if (currentVersion && currentVersion !== "-1") {
                        let baseUrl = appAddress.startsWith("http") ? "" : window.location.origin;
                        let newUrlFetch = `${baseUrl}${appAddress}/api/hpa/paradise?&name=paradisepublic&param=["paradisepublic","${TableName}","LanguageID","${lang}","ParadiseVersion",${currentVersion}]&user=paradisepublic&password=3C9909AFEC25354D551DAE21590BB26E38D53F2173B8D3DC3EEE4C047E7AB1C1EB8B85103E3BE7BA613B31BB5C9C36214DC9F14A42FD7A2FDB84856BCA5C44C2&_cb=${lang}_${currentVersion}`;

                        if (newUrlFetch !== oldUrlFetch || !resolvedFromCache) {
                            let response = await $.ajax({ url: newUrlFetch, cache: true, global: false });
                            let newHtmlContent = "";
                            if (typeof response === "string") {
                                try { newHtmlContent = JSON.parse(response).data[0][0].bytes; } catch (e) { newHtmlContent = response; }
                            } else if (response?.data?.[0]?.[0]?.bytes) {
                                newHtmlContent = response.data[0][0].bytes;
                            }

                            if (newHtmlContent) {
                                try { localStorage.setItem(cacheKeyLink, newUrlFetch); } catch(e) {}

                                if (!resolvedFromCache) {
                                    resolve(newHtmlContent);
                                } else {
                                    // Cập nhật lại UI nếu server vừa đổi code
                                    let activePane = document.querySelector(`[id*="${TableName}"]`) ||
                                                     document.querySelector(`[id*="${TableName.toLowerCase()}"]`) ||
                                                     document.querySelector(`.tab-pane.active`);
                                    if (activePane) {
                                        $(activePane).html(newHtmlContent);
                                        setTimeout(() => { requestAnimationFrame(() => window.dispatchEvent(new Event("resize"))); }, 50);
                                    }
                                }
                                return;
                            }
                        }
                    }
                } catch(e) {
                    console.error("Lỗi check version paradisepublic:", e);
                }

                // Fallback cũ nếu paradisepublic chưa có table này
                if (!resolvedFromCache) {
                    let paramsDataCloud = { data: {
                        name: "ssGetConfigMobileHTMLLayout",
                        param: [
                            "TableName", TableName,
                            "LanguageID", lang,
                            "LoginID", window.LoginID,
                            "IsWeb", window.isWeb,
                            "TypeLayout", -1,
                        ]
                    }};
                    paramsDataCloud.success = function (resultData) {
                        let jsonObj = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                        let jsonData;
                        if (jsonObj.data && jsonObj.data.length > 0) jsonData = jsonObj.data[0][0];
                        if (jsonData && jsonData.Html) {
                            resolve(jsonData.Html);
                        } else {
                            reject("htmlGet attribute not found");
                        }
                    };
                    paramsDataCloud.error = function (xhr, status, error) {
                        reject("AJAX error: " + status + " - " + error);
                    };
                    AjaxHPAParadise(paramsDataCloud);
                }
            };

            if (resolvedFromCache) {
                checkAndFetchServer(); // Chạy ngầm 0ms delay
            } else {
                await checkAndFetchServer();
            }
        } catch (err) {
            reject(err);
        }
    });
}

</script>

<script>
// Get references to the modal and buttons
		  var confirmDeleteModal = document.getElementById(''confirmDeleteModal'');
		  var confirmDeleteButton = document.getElementById(''confirmDeleteButton'');
		  var cancelButton = document.getElementById(''cancelButton'');

		  function handleKeyDown(event) {
			// Check if the modal is the active element
			if (!confirmDeleteModal.classList.contains(''show'')) {
			  return;
			}

			switch (event.key) {
			  case ''Enter'':
				event.preventDefault();
				if(document.activeElement === cancelButton){
				 cancelButton.click();
				}else{
					confirmDeleteButton.click();
				}
				break;
			  case ''Escape'':
				event.preventDefault();
				cancelButton.click();
				break;
			  case ''ArrowLeft'':
				event.preventDefault();
				// Move focus to the previous button or option
				confirmDeleteButton.focus();
				break;
			  case ''ArrowRight'':
				event.preventDefault();
				// Move focus to the next button or option
				cancelButton.focus();
				break;
			  case ''Y'':
			  case ''y'':
				event.preventDefault();
				confirmDeleteButton.click();
				break;
			  case ''N'':
			  case ''n'':
				event.preventDefault();
				cancelButton.click();
				break;
			  default:
				// Handle other keys if necessary
				break;
			}
		  }

		  // Add event listener when the modal is shown
		  confirmDeleteModal.addEventListener(''shown.bs.modal'', function () {
			document.addEventListener(''keydown'', handleKeyDown);
			// Optionally set focus to the confirm button or another element
			confirmDeleteButton.focus();
		  });

		  // Remove event listener when the modal is hidden
		  confirmDeleteModal.addEventListener(''hidden.bs.modal'', function () {
			document.removeEventListener(''keydown'', handleKeyDown);
		  });
</script>

<script>
var orderDockApp = [`MnuHRS238`,`MnuHRS000`,`MnuTAD000`,`MnuPRL000`,`MnuSCR000`,`MnuMDT000`,`MnuTN000`,`MnuWPT000`,`MnuCSM000`,`MnuKPI000`,`MnuREC001`,`MnuTAD361`,`MnuPRL105`,`MnuWPT315`,`MnuWPT316`,`MnuMDT7001`,``];

 var itemsPerPage = 28;
 var firtHrElement = 10;
    var secondHrElement = 16;
    var currentPage = 1;
    var filteredApps = apps;
    var totalPages = 0;
 var currentSelectedMenu = null;
 var currentSelectedMenuName = null;
 var currentAppIdOpen = new Set();

   // const prevButton = document.querySelector(''.prev-button'');
  //  const nextButton = document.querySelector(''.next-button'');


  // Right click to desktop
     document.onclick = hideMenu;

  function shortenString(str, maxLength = 20) {
    // Check if the string is already shorter than or equal to the maxLength
  if (str.length <= maxLength) {
   return str;
  }

  // Split the string into words
  //let words = str.split(" ");

  // Take the first two words and the last word, and join them with "..."
  //let shortenedStr = `${words[0]} ${words[1]}...${words[words.length - 1]}`;
  let shortenedStr = `${str.slice(0,17)}...`;

  return shortenedStr;
 }



    function hideMenu() {
      hideMenuLaunchPad();
      hideMenuDock();
      hideMenuContextTab();
    }

    function hideMenuContextTab() {
      var menu = document.getElementById("contextMenuTab");
        if(menu){
          menu.style.zIndex = "-1";
          menu.style.opacity = "0";
          menu.style.display = "none";
       }
    }

    function hideMenuLaunchPad() {
       var menu = document.getElementById("contextMenu");
       if(menu){
          menu.style.zIndex = "-1";
          menu.style.opacity = "0";
          menu.style.display = "none";
       }
    }

    function hideMenuDock() {
      var menu = document.getElementById("contextMenuDock");
      if(menu){
          menu.style.zIndex = "-1";
          menu.style.opacity = "0";
          menu.style.display = "none";

          var containerWindow = document.querySelector(".container__Window");
          if(containerWindow){
              containerWindow.style.display = "none";
          }
      }
    }

   // Right click to app desktop

 // Handle right-click for both desktop and dock
 function handleRightClick(e, appId, menuId) {
   e.preventDefault();

   const menu = document.getElementById(menuId);

   if (menu.style.opacity === "1") {
  hideMenu();
   } else {
  menu.style.zIndex = "25000";
  menu.style.opacity = "1";
  menu.style.left = `${e.pageX}px`;
  menu.style.top = `${e.pageY}px`;
  currentSelectedMenu = appId;
   }
 }

   // Right-click handlers for context tab menu
 function rightClickTab(e, appId, appName) {
    e.preventDefault();
    currentSelectedMenuName = appName;

    var menu = document.getElementById("contextMenuTab");
    if (menu) {
        menu.style.display = "block";
    }
    handleRightClick(e, appId, "contextMenuTab");
}

 // Right-click handlers for app desktop and dock
 function rightClick(e, appId) {
   handleRightClick(e, appId, "contextMenu");
 }

 function rightClickDock(e, appId) {
   handleRightClick(e, appId, "contextMenuDock");
 }


    function findAppLaunchPad(id){

      return apps.find(app => app.id === id);
    }

    function findAppDock(id){
      return appsDock.find(app => app.id === id);
    }

    function findAppById(id) {
      let app = findAppLaunchPad(id);
      if (app === undefined){
app = findAppDock(id);
  }



        return app;
    }

  function removeButtonAtIndex(index) {
   const container = document.querySelector(''.dock'');
   const buttons = container.getElementsByTagName(''button'');

   if (index >= 0 && index < buttons.length) {
     container.removeChild(buttons[index]);
   } else {
     console.log("Invalid index");
   }
  }

 function openAppContext(){
   OpenAppInSidebar(currentSelectedMenu);
 }
 function handleUnpinToTaskbarClick(isUpdateLayout){
   const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
      appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
      removeButtonAtIndex(indexAppDock);
   secondHrElement--;

    updateStyleDock();

   if(isUpdateLayout){

   //UpdateLayOutApi(''EndIndexPin'',`${secondHrElement}`);
   //const DockOrder = appsDock.map(app => app.id);
  // const arrayString = ''[`'' + DockOrder.map(item => item).join(''`, `'') + ''`]'';
   //UpdateLayOutApi(''DockOrder'', arrayString);
   UpdateDockOrderApp();

   console.log(''Get response'');

   }

    }


    function handlePinToTaskbarClick(isInsertAtTheEnd) {
    const appToAdd = findAppById(currentSelectedMenu);
    const appsDockContainer = document.querySelector(''.dock'');

    if (!appToAdd) return;

    const existsInPinned = appsDock.slice(0, secondHrElement).some(app => app.id === appToAdd.id);
    const indexInDock = appsDock.findIndex(app => app.id === appToAdd.id);


    if (indexInDock >= secondHrElement && isInsertAtTheEnd) {
        // Không làm gì cả, giữ nguyên vị trí trong recent
        return;
    }


    if (!existsInPinned) {
        if (indexInDock !== -1) {

            appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
            removeButtonAtIndex(indexInDock);
        }

        if (isInsertAtTheEnd) {
            appsDock.splice(secondHrElement, 0, appToAdd);
        } else {
            if (currentAppIdOpen.has(appToAdd.id)) {
                currentAppIdOpen.delete(appToAdd.id);
            }
            insertAppAtIndex(findSecondHrIndex(appsDockContainer) - 1, appToAdd);
        }
    } else {
        return;
    }


    var appButton = document.createElement(''button'');
    appButton.classList.add(''icon'', appToAdd.id);
    appButton.innerHTML = `
        ${appToAdd.img}
        <span class="point" id="point-${appToAdd.id}"></span>
    `;
    appButton.classList.add(`open-${appToAdd.id}`);


    if (!appButton._hasClickListener) {
        appButton.addEventListener(''click'', function(e) {
            insertEmployeeWindow(appToAdd.id, appToAdd.name, appToAdd.className);
            openMenu(appToAdd);
            if (appToAdd.className) {
                document.querySelector(`#point-${appToAdd.id}`).style.display = ''block'';
            }
            const appsDockContainer2 = document.querySelector(''.dock'');
            const indexOfApp = Array.prototype.indexOf.call(appsDockContainer2.children, this);
            const indexOfHr = Array.prototype.indexOf.call(appsDockContainer2.children, appsDockContainer2.children[secondHrElement + 1]);

            if (indexOfApp < indexOfHr) {
                ChangePositionRecent(appToAdd.id);

                return;
            }
            highLightApp(appToAdd.id);

        });
        appButton._hasClickListener = true;
    }


    if (!appButton._hasContextMenuListener) {
        appButton.addEventListener(''contextmenu'', function(event) {
            if (isInsertAtTheEnd) {
                rightClick(event, appToAdd.id);
            } else {
                rightClickDock(event, appToAdd.id);
            }
        });
        appButton._hasContextMenuListener = true;
    }


    const allHrElements = appsDockContainer.querySelectorAll(''hr'');
    const secondHr = allHrElements[1];
    if (isInsertAtTheEnd) {
        appButton.classList.add(''dock-recent-app'');
        appsDockContainer.insertBefore(appButton, secondHr.nextSibling);
    } else {
        appButton.classList.add(''dock-pinned-app'');
        appsDockContainer.insertBefore(appButton, secondHr);
        secondHrElement++;
    }

    updateStyleDock();
    limitAppInDock();
    UpdateDockOrderApp();
}

   function updateStyleDock(){
      const existingStyle = document.querySelector(''#dockStyles'');
      if (existingStyle) {
          existingStyle.remove();
      }

      const style = document.createElement(''style'');
      style.id = ''dockStyles'';
      let styleDock = ''.dock .icon::before { display: none !important; } '';

      appsDock.forEach(app => {
          const topOffset = -3;
          styleDock += `
              .dock .icon.${app.id}:hover::after {
                  content: "${app.name}";
                  top: ${-topOffset}vh;
              }
              .dock .icon.${app.id}::before {
                  display: none !important;
              }
          `;
      });

      style.innerHTML = styleDock;
      document.head.append(style);
   }


   function limitAppInDock(){
      const numberOfApp = 5;
      limitAppPinInDock(numberOfApp);
      limitAppRecentInDock(numberOfApp);
    }

    function limitAppPinInDock(numberOfApp){
      if((secondHrElement - (firtHrElement + 1)) > numberOfApp ){
        currentSelectedMenu = appsDock[(firtHrElement + 1)].id;
        handleUnpinToTaskbarClick(true);
      }

   }

   function limitAppRecentInDock(numberOfApp){
      if((appsDock.length - secondHrElement) > numberOfApp ){
          currentSelectedMenu = appsDock[(appsDock.length- 1)].id;
          handleRemoveAppEndInDock();
   // secondHrElement++;
        }

    }

  function ChangePositionRecent(menu_id){
  //const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
  //appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
  //removeButtonAtIndex(indexAppDock);

  currentSelectedMenu = menu_id;
  console.log(currentSelectedMenu)
        handlePinToTaskbarClick(true);
  highLightApp(menu_id);

  }

  function highLightApp(menu_id){
  const elementApp = document.querySelector(`.dock .icon.${menu_id}`);
  if(elementApp){
     elementApp.classList.add(`highLightApp`);
  }


  const allElements = document.querySelectorAll(''.dock .icon.highLightApp'');
  allElements.forEach((element) => {

   if (!element.closest(`.icon.${menu_id}`)) {
    element.classList.remove(''highLightApp'');
   }
  });
  }

  function handleRemoveAppEndInDock(){
 const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
  appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
  removeButtonAtIndex(indexAppDock);
 }

 function insertAppAtIndex(index, appToAdd) {
     if (index < 0 || index > appsDock.length) {
console.error(''Index out of bounds'');
   return;
      }

      // Insert the item at the specified index
      appsDock.splice(index, 0, appToAdd);
  }



  function findSecondHrIndex(container) {
      const hrElements = container.querySelectorAll(''hr'');
      if (hrElements.length >= 2) {
          const secondHr = hrElements[1];
          let btnCount = 0;
          let sib = secondHr.previousElementSibling;
          while (sib) {
              if (sib.tagName === ''BUTTON'') btnCount++;
              sib = sib.previousElementSibling;
          }
          return btnCount;
      } else {
          return -1;
      }
  }

  function insertStyle(id, cssdata, append = false) {
  const existingStyle = document.querySelector(`#${id}`);
  if (existingStyle) {
   if (append) {
    existingStyle.innerHTML += cssdata; // Append the new styles
   } else {
    existingStyle.innerHTML = cssdata; // Replace with new styles
   }
  } else {
   const style = document.createElement(''style'');
   style.id = `${id}`;
   style.innerHTML = cssdata;
   document.head.append(style);
  }
 }



function renderAppsCarousel(){
   var appsList = window.filteredApps || window.apps || [];
   const carouselContainer = document.querySelector(''.carousel'');
   if (!carouselContainer) return;
   carouselContainer.innerHTML = '''';

   const existingStyle = document.querySelector(''#appHoverStyles'');
   if(existingStyle){
       existingStyle.innerHTML = '''';
   }

   const numberPageOfApp = Math.ceil(appsList.length / itemsPerPage);

   for(let i = 1; i <= numberPageOfApp ; i++){
       renderApps(i);
   }

   firstImg = carouselContainer.querySelectorAll(".Apps-container")[0];
   if (typeof showHideIcons === "function") showHideIcons();
}

function renderApps(page) {
    var appsList = window.filteredApps || window.apps || [];
    const start = (page - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    const carouselContainer = document.querySelector(''.carousel'');
    if (!carouselContainer) return;

    const appsContainerParent = document.createElement(''div'');
    appsContainerParent.classList.add(''Apps-container'');
    appsContainerParent.innerHTML = '''';

    const appsContainer = document.createElement(''div'');
    appsContainer.classList.add(''Apps-page-container'');
    appsContainer.innerHTML = '''';

    const paginatedApps = appsList.slice(start, end);
    if (totalPages != Math.ceil(appsList.length / itemsPerPage)){
        totalPages = Math.ceil(appsList.length / itemsPerPage);
        currentPage = 1;
    }
    let styleApp = '''';
    paginatedApps.forEach(app => {
        if(app.isShowLayOutWeb === ''1'' || app.isShowLayOutWeb === 1){return;}
        const appDiv = document.createElement(''div'');
        appDiv.classList.add(''child-launchpad'',''hover-span'',`${app.id}`);
        appDiv.setAttribute(''data-keywords'', app.keywords || app.name);

        let iconHtml = app.img;
        if (!iconHtml || iconHtml.trim() === '''') {
            iconHtml = ''<i class="bi bi-grid-fill"></i>'';
        }

        appDiv.innerHTML = `
${iconHtml}
<span>${shortenString(app.name)}</span>
        `;

        styleApp += `
        .launchpad .${app.id}.hover-span::after {
            content: "${app.name}";
        }
        `;
        if (app.IconForeColor) {
            styleApp += `
        .launchpad .${app.id} i { color: ${app.IconForeColor}; }
        `;
        }
        if (app.IconBackColor) {
            styleApp += `
        .launchpad .${app.id} i { background: ${app.IconBackColor}; }
        `;
        }

        appDiv.classList.add(`open-${app.id}`);
        appDiv.addEventListener(''click'', (e) => {
            e.preventDefault();
            e.stopPropagation();
            handleAppLaunchPadInteraction(e, app);
        });

        appDiv.addEventListener(''contextmenu'', function(event) {
            if (typeof rightClick === "function") rightClick(event, app.id);
        });

        appsContainer.appendChild(appDiv);
    });

    appsContainerParent.appendChild(appsContainer);
    carouselContainer.appendChild(appsContainerParent);

    if (typeof insertStyle === "function") insertStyle(''appHoverStyles'', styleApp, true);
}

function handleAppLaunchPadInteraction(e, app) {
    insertEmployeeWindow(`${app.id}`, `${app.name}`, `${app.className}`);
    openMenu(app);
    if (!appsDock.some(appItem => appItem.id === app.id)) {
        currentAppIdOpen.add(app.id);
    }
    ChangePositionRecent(app.id);
    if (app.className) {
        var pt = document.querySelector(`#point-${app.id}`);
        if (pt) pt.style.display = ''block'';
    }

    var lp = document.getElementById("launchpad") || document.querySelector(".launchpad");
    if (lp) lp.style.display = "none";
    var masterTabs = document.querySelector(".master-tabs");
    if (masterTabs) masterTabs.style.display = "block";
    var homeSidebar = document.querySelector(".home-sidebar");
    if (homeSidebar) homeSidebar.style.display = "block";
    var MainSideBar = document.getElementById("MainSideBar");
    if (MainSideBar) MainSideBar.style.display = "block";
    var containerWindow = document.querySelector(".container__Window");
    if (containerWindow) containerWindow.style.display = "block";
    if (typeof removeSmallTextDockStyle === "function") removeSmallTextDockStyle();
}


function OpenAppInSidebar(menuId, param = ``){
  const app = findAppById(menuId);
  openMenu(`${app.className}`)
  insertEmployeeWindow(`${app.id}`,`${app.name}`,`${app.className}`, param);
  if(!appsDock.some(appItem => appItem.id === app.id)){
        currentAppIdOpen.add(app.id);
        }
  ChangePositionRecent(app.id);
  if(app.className){
  document.querySelector(`#point-${app.id}`).style.display = ''block'';
  }
 }



function renderAppsDock(){
    const appsDockContainer = document.querySelector(''.dock'');
    if (!appsDockContainer) return;

    // 1. Tao Style Responsive co dinh vinh vien (khong bao gio bi updateStyleDock xoa hay ghi de)
    let permStyle = document.querySelector(''#dockResponsivePermanentStyles'');
    if (!permStyle) {
        permStyle = document.createElement(''style'');
        permStyle.id = ''dockResponsivePermanentStyles'';
        document.head.appendChild(permStyle);
    }
    permStyle.innerHTML = `
    /* Triet tieu chu shortenString de len icon */
    .dock .icon::before {
        display: none !important;
    }

    .dock-hamburger-wrap {
        display: none !important;
    }
    .dock-combobox-dropdown {
        display: none !important;
    }

    @media (max-width: 1200px) {
        /* An tat ca cac icon ung dung sau hr dau tien tren man hinh nho */
        .dock > hr:first-of-type ~ button.icon {
            display: none !important;
        }

        /* Hien thi 2 thanh Hamburger trigger */
        .dock-hamburger-wrap {
            display: inline-flex !important;
            position: relative !important;
            align-items: center !important;
            justify-content: center !important;
            margin: 0 4px !important;
        }
        .dock-hamburger-btn {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            cursor: pointer !important;
            width: 36px !important;
            height: 36px !important;
            border-radius: 10px !important;
            border: 1.5px solid rgba(255, 255, 255, 0.25) !important;
            background: rgba(255, 255, 255, 0.08) !important;
            color: inherit !important;
            transition: all 0.2s ease !important;
            font-size: 18px !important;
            user-select: none !important;
        }
        .dock-hamburger-btn:hover,
        .dock-hamburger-wrap:hover .dock-hamburger-btn,
        .dock-hamburger-wrap.show-dropdown .dock-hamburger-btn {
            background: rgba(46, 204, 113, 0.25) !important;
            border-color: #2ecc71 !important;
            color: #2ecc71 !important;
            transform: scale(1.06) !important;
        }

        /* Menu hover dang Combobox dai, hien ca Icon + Ten ung dung */
        .dock-combobox-dropdown {
            display: none !important;
            position: absolute !important;
            top: 100% !important;
            margin-top: 4px !important;
            left: 50% !important;
            transform: translateX(-50%) !important;
            min-width: 250px !important;
            max-width: 320px !important;
            background: var(--paradise-card-bg, #1e293b) !important;
            border: 1px solid var(--paradise-border-color, rgba(255, 255, 255, 0.18)) !important;
            border-radius: 12px !important;
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.5) !important;
            backdrop-filter: blur(12px) !important;
            padding: 8px !important;
            z-index: 25000 !important;
            overflow-x: hidden !important;
            box-sizing: border-box !important;
        }

        /* CAU NOI VO HINH (HOVER BRIDGE) NGAN CAN CHUOT BI OUT KHI RE TREN KHOANG TRONG */
        .dock-combobox-dropdown::before {
            content: "" !important;
            position: absolute !important;
            top: -14px !important;
            left: 0 !important;
            right: 0 !important;
            height: 16px !important;
            background: transparent !important;
            display: block !important;
            pointer-events: auto !important;
        }

        body:not(.dark-mode) .dock-combobox-dropdown {
            background: #ffffff !important;
            border: 1px solid rgba(0, 0, 0, 0.12) !important;
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.2) !important;
        }

        /* Hien thi khi hover hoac khi co class show-dropdown (click) */
        .dock-hamburger-wrap:hover .dock-combobox-dropdown,
        .dock-hamburger-wrap.show-dropdown .dock-combobox-dropdown {
            display: block !important;
            animation: dockComboboxFade 0.2s cubic-bezier(0.16, 1, 0.3, 1) !important;
        }

        .dock-combobox-title {
            font-size: 11.5px !important;
            font-weight: 700 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            color: var(--paradise-text-muted, #94a3b8) !important;
            padding: 4px 8px 6px 8px !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
            margin-bottom: 4px !important;
            user-select: none !important;
            overflow: hidden !important;
            text-overflow: ellipsis !important;
            white-space: nowrap !important;
        }
        body:not(.dark-mode) .dock-combobox-title {
            border-bottom: 1px solid rgba(0, 0, 0, 0.08) !important;
            color: #64748b !important;
        }
        .dock-combobox-list {
            display: flex !important;
            flex-direction: column !important;
            gap: 4px !important;
            max-height: 360px !important;
            overflow-y: auto !important;
            overflow-x: hidden !important;
            width: 100% !important;
            box-sizing: border-box !important;
        }
        .dock-combobox-list::-webkit-scrollbar {
            width: 4px !important;
        }
        .dock-combobox-list::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.2) !important;
            border-radius: 4px !important;
        }
        .dock-combobox-item {
            display: flex !important;
            align-items: center !important;
            gap: 12px !important;
            padding: 8px 12px !important;
            border-radius: 8px !important;
            cursor: pointer !important;
            transition: background 0.15s ease, color 0.15s ease !important;
            color: var(--paradise-text-title, #f8fafc) !important;
            user-select: none !important;
            text-decoration: none !important;
            width: 100% !important;
            box-sizing: border-box !important;
        }
        body:not(.dark-mode) .dock-combobox-item {
            color: #1e293b !important;
        }
        .dock-combobox-item:hover {
            background: rgba(11, 159, 87, 0.22) !important;
            color: #34d399 !important;
        }
        body:not(.dark-mode) .dock-combobox-item:hover {
            background: rgba(11, 159, 87, 0.12) !important;
            color: #0B9F57 !important;
        }
        .dock-combobox-icon {
            width: 24px !important;
            height: 24px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 17px !important;
            flex-shrink: 0 !important;
        }
        .dock-combobox-icon img,
        .dock-combobox-icon svg {
            width: 22px !important;
            height: 22px !important;
            object-fit: contain !important;
        }
        .dock-combobox-text {
            font-size: 13.5px !important;
            font-weight: 500 !important;
            white-space: nowrap !important;
            overflow: hidden !important;
            text-overflow: ellipsis !important;
            flex-grow: 1 !important;
            text-align: left !important;
        }
        .dock-combobox-empty {
            padding: 12px !important;
            font-size: 12.5px !important;
            color: var(--paradise-text-muted, #94a3b8) !important;
            text-align: center !important;
            font-style: italic !important;
        }
    }
    @keyframes dockComboboxFade {
        from { opacity: 0; transform: translateX(-50%) translateY(-6px); }
        to { opacity: 1; transform: translateX(-50%) translateY(0); }
    }
    `;

    appsDockContainer.innerHTML = '''';
    let appIndex = 0;
    let elementIndex = 0;

    var dockList = window.appsDock || [];
    var firstHr = typeof window.firtHrElement !== ''undefined'' ? window.firtHrElement : (typeof firtHrElement !== ''undefined'' ? firtHrElement : 2);
    var secondHr = typeof window.secondHrElement !== ''undefined'' ? window.secondHrElement : (typeof secondHrElement !== ''undefined'' ? secondHrElement : 12);

    const topOffset = -3;

    // 1. Tao Wrap Hamburger cho Nhom Ghim
    const pinnedWrap = document.createElement(''div'');
    pinnedWrap.className = ''dock-hamburger-wrap dock-pinned-wrap'';
    pinnedWrap.id = ''dockHamburgerPinnedWrap'';
    pinnedWrap.innerHTML = `
        <div class="dock-hamburger-btn" title="Ứng dụng đã ghim">
            <i class="bi bi-list"></i>
        </div>
        <div class="dock-combobox-dropdown" id="dockPinnedDropdown">
            <div class="dock-combobox-title">Ứng dụng đã ghim</div>
            <div class="dock-combobox-list" id="dockPinnedList"></div>
        </div>
    `;

    // 2. Tao Wrap Hamburger cho Nhom Gan day
    const recentWrap = document.createElement(''div'');
    recentWrap.className = ''dock-hamburger-wrap dock-recent-wrap'';
    recentWrap.id = ''dockHamburgerRecentWrap'';
    recentWrap.innerHTML = `
        <div class="dock-hamburger-btn" title="Ứng dụng gần đây">
            <i class="bi bi-list"></i>
        </div>
        <div class="dock-combobox-dropdown" id="dockRecentDropdown">
            <div class="dock-combobox-title">Ứng dụng gần đây</div>
            <div class="dock-combobox-list" id="dockRecentList"></div>
        </div>
    `;

    // Ham render dong Combobox khi hover (doc tu DOM cac button tuong ung)
    function refreshComboboxList(listEl, btnClass, emptyText) {
        if (!listEl) return;
        listEl.innerHTML = '''';
        var btns = Array.from(appsDockContainer.querySelectorAll(''button.icon.'' + btnClass));
        if (btns.length === 0) {
            listEl.innerHTML = `<div class="dock-combobox-empty">${emptyText}</div>`;
            return;
        }
        btns.forEach(btn => {
            var appId = Array.from(btn.classList).find(c => c !== ''icon'' && c !== btnClass && c !== ''highLightApp'' && !c.startsWith(''open-''));
            var appObj = (window.appsDock || []).find(a => a.id === appId) || {};
            var name = appObj.name || btn.getAttribute(''title'') || appId;
            var iconNode = btn.querySelector(''svg, img, i'');
            var iconHtml = appObj.img || (iconNode ? iconNode.outerHTML : ''<i class="bi bi-app"></i>'');

            var item = document.createElement(''div'');
            item.className = ''dock-combobox-item'';
            item.innerHTML = `
                <div class="dock-combobox-icon">${iconHtml}</div>
                <div class="dock-combobox-text" title="${name}">${name}</div>
            `;
            item.addEventListener(''click'', function(e) {
                e.preventDefault();
                e.stopPropagation();
                pinnedWrap.classList.remove(''show-dropdown'');
                recentWrap.classList.remove(''show-dropdown'');
                btn.click();
            });
            listEl.appendChild(item);
        });
    }

    let pinnedCloseTimer = null;
    let recentCloseTimer = null;

    // PINNED WRAP: Hover + Grace Period (300ms) + Click Toggle
    pinnedWrap.addEventListener(''mouseenter'', function() {
        if (pinnedCloseTimer) clearTimeout(pinnedCloseTimer);
        refreshComboboxList(document.getElementById(''dockPinnedList''), ''dock-pinned-app'', ''Chưa có ứng dụng ghim'');
        pinnedWrap.classList.add(''show-dropdown'');
    });
    pinnedWrap.addEventListener(''mouseleave'', function() {
        pinnedCloseTimer = setTimeout(function() {
            pinnedWrap.classList.remove(''show-dropdown'');
        }, 300);
    });

    const pinnedBtn = pinnedWrap.querySelector(''.dock-hamburger-btn'');
    pinnedBtn.addEventListener(''click'', function(e) {
        e.stopPropagation();
        recentWrap.classList.remove(''show-dropdown'');
        if (pinnedWrap.classList.contains(''show-dropdown'')) {
            pinnedWrap.classList.remove(''show-dropdown'');
        } else {
            refreshComboboxList(document.getElementById(''dockPinnedList''), ''dock-pinned-app'', ''Chưa có ứng dụng ghim'');
            pinnedWrap.classList.add(''show-dropdown'');
        }
    });

    // RECENT WRAP: Hover + Grace Period (300ms) + Click Toggle
    recentWrap.addEventListener(''mouseenter'', function() {
        if (recentCloseTimer) clearTimeout(recentCloseTimer);
        refreshComboboxList(document.getElementById(''dockRecentList''), ''dock-recent-app'', ''Chưa có ứng dụng gần đây'');
        recentWrap.classList.add(''show-dropdown'');
    });
    recentWrap.addEventListener(''mouseleave'', function() {
        recentCloseTimer = setTimeout(function() {
            recentWrap.classList.remove(''show-dropdown'');
        }, 300);
    });

    const recentBtn = recentWrap.querySelector(''.dock-hamburger-btn'');
    recentBtn.addEventListener(''click'', function(e) {
        e.stopPropagation();
        pinnedWrap.classList.remove(''show-dropdown'');
        if (recentWrap.classList.contains(''show-dropdown'')) {
            recentWrap.classList.remove(''show-dropdown'');
        } else {
            refreshComboboxList(document.getElementById(''dockRecentList''), ''dock-recent-app'', ''Chưa có ứng dụng gần đây'');
            recentWrap.classList.add(''show-dropdown'');
        }
    });

    // Click ra ngoai thi dong dropdown
    $(document).off(''click.closeDockCombobox'').on(''click.closeDockCombobox'', function(e) {
        if (!e.target.closest(''#dockHamburgerPinnedWrap'') && !e.target.closest(''#dockHamburgerRecentWrap'')) {
            var pw = document.getElementById(''dockHamburgerPinnedWrap'');
            var rw = document.getElementById(''dockHamburgerRecentWrap'');
            if (pw) pw.classList.remove(''show-dropdown'');
            if (rw) rw.classList.remove(''show-dropdown'');
        }
    });

    // Lang nghe window resize
    if (!window._hasDockResizeListener) {
        window.addEventListener(''resize'', function() {
            var pw = document.getElementById(''dockHamburgerPinnedWrap'');
            var rw = document.getElementById(''dockHamburgerRecentWrap'');
            if (pw) pw.classList.remove(''show-dropdown'');
            if (rw) rw.classList.remove(''show-dropdown'');
        });
        window._hasDockResizeListener = true;
    }

    const existingStyle = document.querySelector(''#dockStyles'');
    if (existingStyle) existingStyle.remove();

    const style = document.createElement(''style'');
    style.id = ''dockStyles'';
    let styleDock = ''.dock .icon::before { display: none !important; } '';

    dockList.forEach(app => {
        const appButton = document.createElement(''button'');
        appButton.classList.add(''icon'', `${app.id}`);

        if (`${app.id}` === `MnuHRS238`) {
            appButton.classList.add(''open-lunchpad'');
            appButton.addEventListener(''click'', function(e) {
                e.preventDefault();
                e.stopPropagation();
                handleOpenLaunching();
            });
        } else {
            appButton.classList.add(`open-${app.id}`);
            appButton.addEventListener(''click'', function(e) {
                insertEmployeeWindow(`${app.id}`, `${app.name}`, `${app.className}`);
                openMenu(app);
                ChangePositionRecent(app.id);
                if (app.className) {
                    var pt = document.querySelector(`#point-${app.id}`);
                    if (pt) pt.style.display = ''block'';
                }
            });
        }

        let iconHtml = app.img;
        if (!iconHtml || iconHtml.trim() === '''') {
            iconHtml = ''<i class="bi bi-app"></i>'';
        }

        appButton.innerHTML = `
            ${iconHtml}
            <span class="point" id="point-${app.id}"></span>
        `;

        if (elementIndex > firstHr + 1 && elementIndex < secondHr + 1) {
            appButton.addEventListener(''contextmenu'', function(event) {
                if (typeof rightClickDock === ''function'') rightClickDock(event, app.id);
            });
        } else if (elementIndex > secondHr + 1) {
            appButton.addEventListener(''contextmenu'', function(event) {
                if (typeof rightClickRecent === ''function'') rightClickRecent(event, app.id);
            });
        }

        if (elementIndex === firstHr) {
            const hr = document.createElement(''hr'');
            hr.classList.add(''column'', ''hidden'');
            appsDockContainer.appendChild(hr);
            appsDockContainer.appendChild(pinnedWrap);
            elementIndex++;
        } else if (elementIndex === secondHr) {
            const hr = document.createElement(''hr'');
            hr.classList.add(''column'', ''hidden'');
            appsDockContainer.appendChild(hr);
            appsDockContainer.appendChild(recentWrap);
            elementIndex++;
        }

        // Gan class nhom de nhan dien
        if (elementIndex > firstHr && elementIndex <= secondHr) {
            appButton.classList.add(''dock-pinned-app'');
        } else if (elementIndex > secondHr) {
            appButton.classList.add(''dock-recent-app'');
        }

        // Luon append truc tiep vao dockContainer (cau truc phang 100% cua Paradise)
        appsDockContainer.appendChild(appButton);

        styleDock += `
            .dock .icon.${app.id}:hover::after {
                content: "${app.name}";
                top: ${-topOffset}vh;
            }
            .dock .icon.${app.id}::before {
                display: none !important;
            }
        `;
        appIndex++;
        elementIndex++;
    });

    style.innerHTML = styleDock;
    document.head.append(style);
}

function renderPagination() {
        totalPages = Math.ceil(filteredApps.length / itemsPerPage);


   // prevButton.disabled = currentPage === 1;
        // nextButton.disabled = currentPage === totalPages;

       // prevButton.style.display = currentPage === 1 ? ''none'' : ''block'';
       // nextButton.style.display = currentPage === totalPages ? ''none'' : ''block'';

       // if (prevButton) prevButton.addEventListener(''click'', () => {
      //      currentPage = currentPage - 1;
    // renderApps(currentPage);
     //   });

        if (nextButton) nextButton.addEventListener(''click'', () => {
 currentPage = currentPage + 1;
            renderApps(currentPage);

   });

}



    // Debounce function to limit the number of search executions

    function debounce(func, delay) {
        let timeout;
        return function(...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, args), delay);
        };
    }

  // Function to calculate fuzzy match score (Levenshtein distance algorithm)
    function fuzzyMatch(query, keyword) {
        const threshold = 3; // Max number of character differences allowed
        return getLevenshteinDistance(query, keyword) <= threshold;
    }

    // Helper function: Levenshtein distance algorithm
    function getLevenshteinDistance(a, b) {
        const matrix = [];
        for (let i = 0; i <= b.length; i++) {
            matrix[i] = [i];
        }
        for (let j = 0; j <= a.length; j++) {
            matrix[0][j] = j;
        }
     for (let i = 1; i <= b.length; i++) {
            for (let j = 1; j <= a.length; j++) {
                if (b.charAt(i - 1) === a.charAt(j - 1)) {
                    matrix[i][j] = matrix[i - 1][j - 1];
            } else {
                    matrix[i][j] = Math.min(matrix[i - 1][j - 1] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j] + 1);
                }
   }
  }
        return matrix[b.length][a.length];
    }

    // Search function with fuzzy and partial matching

function searchApps(query) {
    var allApps = window.apps || [];
    var q = typeof toLowerCaseNonAccentVietnamese === ''function'' ? toLowerCaseNonAccentVietnamese((query || '''').trim()) : (query || '''').trim().toLowerCase();

    if (q === "") {
        window.filteredApps = allApps;
    } else {
        window.filteredApps = allApps.filter(function(app) {
            var name = typeof toLowerCaseNonAccentVietnamese === ''function'' ? toLowerCaseNonAccentVietnamese(app.name || "") : (app.name || "").toLowerCase();
            var kw = typeof toLowerCaseNonAccentVietnamese === ''function'' ? toLowerCaseNonAccentVietnamese(app.keywords || "") : (app.keywords || "").toLowerCase();
            return name.includes(q) || kw.includes(q);
        });
    }
    filteredApps = window.filteredApps;
    currentPage = 1;
    renderAppsCarousel();
}


function addResultApp(id,name, details, icon, className, app) {
        // Select the result container
        const resultContainer = document.querySelector(''.result'');

        // Create a new div for the result-app
  const resultApp = document.createElement(''div'');
        resultApp.classList.add(''result-app'');
        resultApp.setAttribute(''data-name'', name);

        // Create the app-info section
        const appInfo = document.createElement(''div'');
        appInfo.classList.add(''app-info'');

        const appName = document.createElement(''div'');
        appName.classList.add(''app-name'');
      appName.textContent = name;

    const appDetails = document.createElement(''div'');
        appDetails.classList.add(''app-details'');
        appDetails.textContent = details;

        // Append the app name and details to app-info
        appInfo.appendChild(appName);
        appInfo.appendChild(appDetails);

      // Append the icon and info to result-app
        resultApp.innerHTML = icon;
        resultApp.appendChild(appInfo);

   resultApp.addEventListener(''click'', function(e){
        insertEmployeeWindow(`${id}`,`${name}`,`${className}`);
  openMenu(app);
        const windown = document.querySelector(`.window.${id}`);


  if(!appsDock.some(appItem => appItem.id === id)){
      currentAppIdOpen.add(id);
        }

  ChangePositionRecent(id);
       // currentSelectedMenu = id;
       // handlePinToTaskbarClick(true);
    if(className){
     document.querySelector(`#point-${id}`).style.display = ''block'';
  }
  //open_window(windown, null, null);

        });

        // Append the new result-app to the result container

        resultContainer.appendChild(resultApp);
    }

 var searchInputSpotlight = document.querySelector(''.spotlight_search-bar'');
    searchInputSpotlight.addEventListener(''input'',()=>{

      const resultContainer = document.querySelector(''.result'');
      resultContainer.innerHTML = '''';
      resultContainer.style.display = ''none'';

      const query = event.target.value;
      if (query !== '''') {

             const queryLower = query.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

            const filteredApps = apps.filter(app => {
   const keywords = app.keywords.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").split('','');
                const name = app.name.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

     return (
         keywords.some(keyword => keyword.includes(queryLower)) ||

       name.includes(queryLower) ||
                    fuzzyMatch(queryLower, name)
                );
            });

            if(filteredApps.length > 0){
              resultContainer.style.display = ''block'';
              filteredApps.slice(0, 5).forEach( item => {
            addResultApp(
    `${item.id}`,
              `${item.name}`,
              "5.6 MB · PDF Document · Modified yesterday",
     `${item.img}`,
     `${item.className}`,
     item
            );
          })



        }
        }

    } );



function UpdateLayOutApi(typeSetting, valueSetting){

  //UpdateDockOrderApp();

        $.ajax({
          url: window.APPLICATION_ADDRESS + ''/api/hpa/Paradise'',
          type: ''GET'', // Explicitly specifying the request type
      data: {
            user: UserName,
  PassWord: HashPass,
            name: ''sp_SaveWebLayOutSetting'',
         param: JSON.stringify(["TypeSetting", typeSetting, "NewValueSetting", valueSetting]) // Convert the param array to a string
          },
          success: function (result) {
         //   console.log(valueSetting);
          },
          error: function (error) {
            console.error("Error", error);
          }
        });


    }

 function UpdateDockOrderApp(){
   const DockOrder = appsDock.map(app => app.id);
   const MenuPinList = ''`'' + DockOrder.slice(firtHrElement + 1,secondHrElement).map(item => item).join(''`, `'') + ''`'';
   const MenuRecentList = ''`'' + DockOrder.slice(secondHrElement).map(item => item).join(''`, `'') + ''`'';

   AjaxHPAParadise({
   data: {
    name: "sp_DockOrderApp",
    param: ["LoginID", 3, "MenuPinList", MenuPinList, "MenuRecentList", MenuRecentList]
   },
   success: function (resultData) {

         },
         error: function (xhr, status, error) {
    console.error("Error", error);
         }
  });

    //$.ajax({
          //url: window.APPLICATION_ADDRESS + ''/api/hpa/Paradise'',
          //type: ''GET'',  // Explicitly specifying the request type
          //data: {
          //  user: UserName,
          //  PassWord: HashPass,
          //  name: ''sp_DockOrderApp'',
          //  param: JSON.stringify(["LoginID", 3, "MenuPinList", MenuPinList, "MenuRecentList", MenuRecentList])  // Convert the param array to a string
          //},
        //success: function (result) {
         //   console.log(valueSetting);
          //},
          //error: function (error) {
          //  console.error("Error", error);
  //}
        //});

 }



    // Combine both app arrays
 var combinedApp = [...(Array.isArray(apps) ? apps : Object.values(apps || {})), ...(Array.isArray(appsDock) ? appsDock : Object.values(appsDock || {}))];
  combinedApp = Array.from(new Map(combinedApp.map(app => [app.id, app])).values());
  combinedApp = combinedApp.filter(app =>
  orderDockApp.includes(app.id)
   );

 function sortArrayByOrder(orginalArray, orderDockApp) {

    return orginalArray.sort((a, b) => {
   const indexA = orderDockApp.indexOf(a.id);
   const indexB = orderDockApp.indexOf(b.id);
   return indexA - indexB; // Sort according to order
    });
  }

    appsDock = sortArrayByOrder(combinedApp, orderDockApp);

    // Initial render
    //testApi();
 //UpdateLayOutApi(''DockOrder'',''[`MnuHRS000`, `MnuHRS238`, `MnuHRS245`, `MnuHRS246`, `MnuHRS249`, `MnuMDT000`, `MnuPRL000`, `MnuRPT001`, `MnuSCR000`, `MnuTAD000`, `MnuTM000`, `MnuWPT000`]'');
    renderAppsCarousel();
 //renderApps(currentPage);
 renderAppsDock();
   // renderPagination();

    // Debounced search
    var searchInput = document.querySelector(''.search-input'');
 searchInput.addEventListener(''input'', debounce((event) => {
        searchApps(event.target.value);
    }, 300));


       function insertOrUpdateStyles(styleId, innerHTMLStyle) {
  // Check if the style element with a unique id already exists
  let styleElement = document.getElementById(`${styleId}`);

  // If the style element doesnt exist, create a new one
  if (!styleElement) {
   styleElement = document.createElement(''style'');
   styleElement.id = `${styleId}`;
   document.head.appendChild(styleElement);
  }

  // Update the inner content of the style element
  styleElement.innerHTML = `
   ${innerHTMLStyle}
  `;
 }



   // console.log(''Render firsttime'');

     /********** ELEMENTS **********/
   var elements = {
     body: document.querySelector("body"),
     navbar: document.querySelector(".navbar"),
     open_spotlight: document.querySelector(".open_Search"),
     spotlight_search: document.querySelector(".spotlight_serach"),
     brightness_range: document.getElementById("brightness"),
     sound_range: document.getElementById("sound"),
     clockElement: document.getElementById("clock"),
    clockWrapper: document.querySelector(".clock"),
     widgetsPanel: document.querySelector(".widgets-panel"),
     batteryButton: document.querySelector(".battery"),
  batteryText: document.querySelector(".battery__text"),
     batteryPopup: document.querySelector(".battery__popup"),
     batteryPopupText: document.querySelector(".battery__popup header span"),
     batteryProgress: document.querySelector(".battery__progress"),
     batteryIsChargingLogo: document.querySelector(".is-charging"),

     powerSource: document.querySelector(".power-source"),
   };



   // Launchpad
   var launchpad = {
     container: document.querySelector(".container__Window"),
     window: document.querySelector(".launchpad"),
     searchbox: document.querySelector(".launchpad .searchbox"),
    app_container: document.querySelector(".Apps-container"),
     point: document.querySelector("#point-launchpad"),
     opening: document.querySelector(".open-lunchpad")
   };

   /********** LISTENERS **********/




   // Spotlight
   function handleopen_spotlight() {
     if (elements.spotlight_search.style.display === "none") {
    elements.spotlight_search.style.display = "flex";
    } else {
    elements.spotlight_search.style.display = "none";
     }
   }

     function isMinimized(element) {
    const maxWidth = window.getComputedStyle(element).maxWidth;
    const minWidth = window.getComputedStyle(element).minWidth;

    return maxWidth === "50%" && minWidth === "50%";
     }


    function handleHide(hide) {
   hide.style.transform = ''scale(0.1) translate(0%, 1850%)'';
   hide.style.opacity = ''0'';
   hide.style.width = ''150px'';
   hide.style.height = ''100px'';

   setTimeout(() => {
     hide.style.display = ''none'';
    }, 700);

    }



   function handleMinimize(Minimize) {
     Minimize.style.maxWidth = "50%";
     Minimize.style.minWidth = "50%";
     Minimize.style.height = "430px";


     insertOrUpdateStyles(`sizeWindown_${Minimize.classList[1]}`, `

    .${Minimize.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
         content: "🗖" !important;
    }

    `);
   }

   function handleFullScreen(maximize) {
     maximize.style.maxWidth = "100%";
     maximize.style.minWidth = "100%";
     maximize.style.height = "93.62%";



     insertOrUpdateStyles(`sizeWindown_${maximize.classList[1]}`, `

       .${maximize.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
    content: "🗗" !important;

    }

    `);

   }

   function close_window(close, point, appName) {
     close.style.display = "none";
    // point.style.display = "none";
    // appName.style.display = "none";
   }

  function open_window(open, point, appName) {
     // Ensure the open element is displayed
     document.querySelector(`#point-${open.classList[1]}`).style.display = ''block'';

     open.style.display = "block";
     open.style.position = "absolute"; // Allow absolute positioning
     setTimeout(() => {
    open.style.transform = ''scale(1) translate(0, 0)'';
     open.style.opacity = ''1'';

     }, 1);

     const centerX = 0;
     const centerY = 0;

     // Position the window in the center of the screen
     open.style.left = `${centerX}px`;
     // open.style.top = `${centerY}px`;

     // Show other UI elements
     launchpad.container.style.display = "flex";
     launchpad.window.style.display = "none";
     elements.spotlight_search.style.display = "block";
     elements.widgetsPanel.style.display = "block";

     if(isMinimized(open)){
     insertOrUpdateStyles(`sizeWindown_${open.classList[1]}`, `

    .${open.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
    content: "🗖" !important;

    }

    `);
     } else {

       insertOrUpdateStyles(`sizeWindown_${open.classList[1]}`, `

    .${open.classList[1]} .window__taskbar--actions button:nth-child(3)::after {

    content: "🗗" !important;

    }

    `);

     }




   }



    // Function to insert the style, checking if it already exists
   function insertSmallTextDockStyle() {
    const styleId = ''hide-icon-before-style'';
    // Check if the style element already exists
    if (!document.getElementById(styleId)) {
     const style = document.createElement(''style'');

     style.id = styleId;
     style.textContent = ''.dock .icon::before { display: none !important; }'';

     document.head.appendChild(style);
    }
   }

   // Function to remove the style by id, checking if it exists
   function removeSmallTextDockStyle() {
    const styleId = ''hide-icon-before-style'';
    const style = document.getElementById(styleId);
    if (style) {
     style.parentNode.removeChild(style);
    }
   }

   // Launchpad function start
   // single listener handled in renderAppsDock


function handleOpenLaunching() {
    var lp = document.getElementById("launchpad") || document.querySelector(".launchpad");
    if (!lp) return;

    var masterTabs = document.querySelector(".master-tabs");
    var homeSidebar = document.querySelector(".home-sidebar");
    var MainSideBar = document.getElementById("MainSideBar");
    var containerWindow = document.querySelector(".container__Window");
    var spotlight = document.querySelector(".spotlight_serach");
    var widgets = document.querySelector(".widgets-panel");

    var isHidden = (window.getComputedStyle(lp).display === "none" || lp.style.display === "none" || lp.style.display === "");

    if (isHidden) {
        if (spotlight) spotlight.style.display = "none";
        if (widgets) widgets.style.display = "none";

        lp.style.display = "block";
        if (masterTabs) masterTabs.style.display = "none";
        if (homeSidebar) homeSidebar.style.display = "none";
        if (MainSideBar) MainSideBar.style.display = "none";
        if (containerWindow) containerWindow.style.display = "none";

        if (typeof insertSmallTextDockStyle === "function") insertSmallTextDockStyle();
        if (typeof renderAppsCarousel === "function") renderAppsCarousel();
    } else {
        if (spotlight) spotlight.style.display = "block";
        if (widgets) widgets.style.display = "block";

        lp.style.display = "none";
        if (masterTabs) masterTabs.style.display = "block";
        if (homeSidebar) homeSidebar.style.display = "block";
        if (MainSideBar) MainSideBar.style.display = "block";
        if (containerWindow) containerWindow.style.display = "block";

        if (typeof removeSmallTextDockStyle === "function") removeSmallTextDockStyle();
    }
}
window.handleOpenLaunching = handleOpenLaunching;


function handleLaunchpadSearch(e) {
    for (let app of launchpad.app_container.children) {
    if (e.target.value) {
      app.style.display = "none";
      if (app.dataset.keywords.includes(e.target.value)) {

     app.style.display = "flex";
      }
    } else app.style.display = "flex";
     }
   }


  function toLowerCaseNonAccentVietnamese(str) {
   str = str.toLowerCase();
  //     We can also use this instead of from line 11 to line 17
  //     str = str.replace(/\u00E0|\u00E1|\u1EA1|\u1EA3|\u00E3|\u00E2|\u1EA7|\u1EA5|\u1EAD|\u1EA9|\u1EAB|\u0103|\u1EB1|\u1EAF|\u1EB7|\u1EB3|\u1EB5/g, "a");
   str = (str || '''').toLowerCase();
   // Dùng unicode escape thay vì ký tự tiếng Việt trực tiếp để tránh SyntaxError regex
   // a-variants: à á ạ ả ã â ầ ấ ậ ẩ ẫ ă ằ ắ ặ ẳ ẵ
   str = str.replace(/\u00e0|\u00e1|\u1ea1|\u1ea3|\u00e3|\u00e2|\u1ea7|\u1ea5|\u1ead|\u1ea9|\u1eab|\u0103|\u1eb1|\u1eaf|\u1eb7|\u1eb3|\u1eb5/g, ''a'');
   // e-variants: è é ẹ ẻ ẽ ê ề ế ệ ể ễ
   str = str.replace(/\u00e8|\u00e9|\u1eb9|\u1ebb|\u1ebd|\u00ea|\u1ec1|\u1ebf|\u1ec7|\u1ec3|\u1ec5/g, ''e'');
   // i-variants: ì í ị ỉ ĩ
   str = str.replace(/\u00ec|\u00ed|\u1ecb|\u1ec9|\u0129/g, ''i'');
   // o-variants: ò ó ọ ỏ õ ô ồ ố ộ ổ ỗ ơ ờ ớ ợ ở ỡ
   str = str.replace(/\u00f2|\u00f3|\u1ecd|\u1ecf|\u00f5|\u00f4|\u1ed3|\u1ed1|\u1ed9|\u1ed5|\u1ed7|\u01a1|\u1edd|\u1edb|\u1ee3|\u1edf|\u1ee1/g, ''o'');
   // u-variants: ù ú ụ ủ ũ ư ừ ứ ự ử ữ
   str = str.replace(/\u00f9|\u00fa|\u1ee5|\u1ee7|\u0169|\u01b0|\u1eeb|\u1ee9|\u1ef1|\u1eed|\u1eef/g, ''u'');
   // y-variants: ỳ ý ỵ ỷ ỹ
   str = str.replace(/\u1ef3|\u00fd|\u1ef5|\u1ef7|\u1ef9/g, ''y'');
   // đ
   str = str.replace(/\u0111/g, ''d'');
   // Combining diacritics (NFD decomposed)
   str = str.replace(/[\u0300\u0301\u0303\u0309\u0323]/g, ''''); // Huyền sắc hỏi ngã nặng
   str = str.replace(/[\u02c6\u0306\u031b]/g, ''''); // Â, Ê, Ă, Ơ, Ư
   return str;
  }
  // Alias: paradiseCommon.min gọi tên không có "n" → cần expose cả 2 tên
  window.toLowerCaseNonAccentVietnamese = toLowerCaseNonAccentVietnamese;
  window.toLowerCaseNoAccentVietnamese  = toLowerCaseNonAccentVietnamese;

   // Launchpad function end





   //handleopen_spotlight();
   // handleOpenLaunching removed from initial boot

   document.addEventListener(''keydown'', function (event) {

    if (event.ctrlKey && event.key === ''f'') {
  event.preventDefault();


    setTimeout(function () {
  $(''#launchpad'').fadeIn();
 }, 333);

// Delay 0.5 giây để thực hiện cả hai sự kiện hide
setTimeout(function () {
    $(''#MainSideBar'').hide();
    $(''#master-tabs'').hide();
}, 333);

setTimeout(function () {
  let $searchInput = $(''.search-input'');
    $searchInput.val('''');
 searchApps("");
    $searchInput.focus();
}, 335);


    }
});

   </script>
   <script>
function showLoadingByClassOrID(target, text = "Loading...", spinnerColor = "black", textColor = "white") {



    const targetElement = document.querySelector(target);
    if (targetElement) {
        if (!targetElement.querySelector(".custom-spinner-container")) {
            targetElement.style.position = "relative"; // Đảm bảo phần tử có position để chứa overlay đúng

            const overlay = document.createElement("div");
            overlay.classList.add("custom-overlay");

            const spinnerContainer = document.createElement("div");
            spinnerContainer.classList.add("custom-spinner-container");

            const spinner = document.createElement("div");
            spinner.classList.add("spinner-border");
            spinner.setAttribute("role", "status");
            spinner.style.color = spinnerColor;

            const spinnerText = document.createElement("div");
            spinnerText.classList.add("custom-spinner-text");
            spinnerText.innerText = text;
            spinnerText.style.color = textColor;

            spinnerContainer.appendChild(spinner);
            spinnerContainer.appendChild(spinnerText);

            targetElement.appendChild(overlay);
            targetElement.appendChild(spinnerContainer);
        }
    }
}


        // Hàm ẩn loading
        function HideLoadingByClassOrID(target) {
            const targetElement = document.querySelector(target);
   console.log(targetElement)
            if (targetElement) {

                const spinner = targetElement.querySelector(''.custom-spinner-container'');
                const overlay = targetElement.querySelector(''.custom-overlay'');
                if (spinner) {
                    spinner.remove();
                }
                if (overlay) {
                    overlay.remove();
                }
            }
        }

   </script>

   <script>
    function createDropDownButtonControl(div, config, paramsControl, optionsControl) {
     if (!div) div = $("<div>");
     else div = $(div);
     div[0].option = config;
     div.dxDropDownButton(div[0].option);
     if (paramsControl) {
      paramsControl[config.ControlNameParam] = div.dxDropDownButton("instance");
      if (config.Params)
       paramsControl[config.ControlNameParam].Params = config.Params;
     }
     if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
     return div;
    }

    function runSPActionFunction(
     funcitonName = "",
     funcitonNameParam = "",
     classNameParam = "",
     spObject = {},
     actionSuccess = (a) => { },
     actionError = (a) => { }
    ) {
     if (!funcitonNameParam) {
      funcitonNameParam = Object.keys(spObject).find(
       (x) => x.toLowerCase().replace("_", "") == "functionname"
      );
     }

     if (!classNameParam) {
      classNameParam = Object.keys(spObject).find(
       (x) => x.toLowerCase().replace("_", "") == "classname"
      );
     }

     let className = spObject[classNameParam];

     if (!funcitonName) funcitonName = spObject[funcitonNameParam];

     delete spObject[funcitonNameParam];
     delete spObject[classNameParam];

     CallMethod(funcitonName.toLowerCase()=="runjs" ? "" : className, funcitonName, Object.values(spObject));

     //AjaxHPAParadiseParadise({
     // data: {
     //  name: funcitonName,
     //  param: Object.values(spObject),
     // },

     // success: function (resultData) {
   //  let jsonData =
     //   typeof resultData === "string" ? JSON.parse(resultData) : resultData;
     //  if (actionSuccess) actionSuccess(jsonData);
     // },
     // error: function (xhr, status, error) {
     //  if (actionError) actionError(error);
     // },
     //});
    }

    async function runSPActionFunctionAsync(
     funcitonName = "",
     funcitonNameParam = "",
     classNameParam = "",
     spObject = {},
     actionSuccess = (a) => { },
     actionError = (a) => { }
    ) {
     if (!funcitonNameParam) {
      funcitonNameParam = Object.keys(spObject).find(
       (x) => x.toLowerCase().replace("_", "") == "functionname"
      );
     }

     if (!classNameParam) {
      classNameParam = Object.keys(spObject).find(
       (x) => x.toLowerCase().replace("_", "") == "classname"
      );
     }

     let className = spObject[classNameParam];

     if (!funcitonName) funcitonName = spObject[funcitonNameParam];

     delete spObject[funcitonNameParam];
     delete spObject[classNameParam];

     CallMethod(funcitonName.toLowerCase()=="runjs" ? "" : className, funcitonName, Object.values(spObject));

     //await AjaxHPAParadiseParadiseAsync({
     // data: {
     //  name: funcitonName,
     //  param: Object.values(spObject),
     // },
     // success: function (resultData) {
     //  let jsonData =
     //   typeof resultData === "string" ? JSON.parse(resultData) : resultData;
     //  if (actionSuccess) actionSuccess(jsonData);
     // },
     // error: function (xhr, status, error) {
     //  if (actionError) actionError(error);
     // },
     //});
    }


   </script>
   <script>
    var shortcutMap = {};
    var pressedKeys = new Set();
    function loadShortcuts() {
     shortcutMap = {};
     const list = window.ShortcutKeysList || (typeof ShortcutKeysList !== "undefined" ? ShortcutKeysList : []);
     $.each(list || [], function(index, shortcut) {
      if (shortcut && shortcut.ShortcutKeys) {
        shortcutMap[shortcut.ShortcutKeys.toUpperCase()] = shortcut.ClassName;
      }
     });
    }
    loadShortcuts();

    $(document).on("keydown", function(event) {
      if (event.repeat) return;
      if ($(".modal.show").length > 0 && isShortcutModeActive === true) {
        event.preventDefault();
        event.stopPropagation();
        return;
      }
      if (event.ctrlKey) pressedKeys.add("CONTROL");
      if (event.altKey) pressedKeys.add("ALT");
      if (event.shiftKey) pressedKeys.add("SHIFT");
      pressedKeys.add(event.key.toUpperCase());
      let keyCombination = Array.from(pressedKeys).join("+");

      if (shortcutMap[keyCombination]) {
        event.preventDefault();
        event.stopPropagation();
        openFormParam(shortcutMap[keyCombination], {
          EmployeeID: "-1",
          LoginID: "+cast(@LoginID as varchar(20))+",
          TableName: "-1",
          Isweb: 1
        });
      }
    });

    $(document).on("keyup", function(event) {
      let key = event.key.toUpperCase();
      pressedKeys.delete(key);
      if (key === "CONTROL" || key === "ALT" || key === "SHIFT") {
        pressedKeys.clear();
      }
    });

    function updateShortcuts(newList) {
      ShortcutKeysList = newList;
      loadShortcuts();
    }

    function addStyles() {
        if ($("#style-settingsModal").length === 0) {
            const style = `
                <style id="style-settingsModal">
                    .modal-backdrop {
                        z-index: 1050 !important;
                    }
                    .modal {
                        z-index: 1055 !important;
                    }
                    .modal-dialog {
                        z-index: 1060 !important;
                    }
                    .modal-dialog.ui-draggable {
                        cursor: default;
                    }
                    .modal-dialog.ui-draggable .modal-header {
                        cursor: move;
                        user-select: none;
                    }
                    .custom-list {
                        list-style: none;
                        padding-left: 20px;
                    }
                    .custom-list li {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        margin-bottom: 8px;
                        font-size: 16px;
                        user-select: text;
                    }
                    .custom-list i {
                        color: #007bff;
                        font-size: 16px;
                        flex-shrink: 0;
                        user-select: none;
                    }
                    .api-all {
                        display: flex;
                        gap: 15px;
                        flex-wrap: wrap;
                        max-height: 300px;
                        overflow-y: auto;
                        padding-right: 15px;
                    }
                    .api-list {
                        display: flex;
                        gap: 15px;
                        width: 100%;
                        margin-bottom: 8px;
                    }
                    .api-item {
                        flex: 1;
                    }
                    .shortcut-container {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 10px 0;
                    }
                </style>
            `;
            $("head").append(style);
        }
    }

    function apiName() {
        const scripts = $(".tab-pane.active.show script, .tab-pane.active script").toArray();
        const allContent = scripts
            .map(x => x.innerHTML)
            .filter(content => content.trim() !== "")
            .join("\\p");

        const apiMatches = allContent.match(/AjaxHPAParadise(?:Paradise)?(?:Async)?\s*\([\s\S]*?\)/g);
        if (!apiMatches || apiMatches.length === 0) {
            return [];
        }

        const apiNames = apiMatches.map(api => {
                const nameMatch = api.match(/name\s*:\s*["'']([^"'']+)["'']/);
                return nameMatch ? nameMatch[1] : null;
            })
            .filter(name => name !== null)
            .filter((value, index, self) => self.indexOf(value) === index);

        return apiNames;
    }

    function apiNameWithDescription(apiNames, apiData) {
        if (!apiNames || !apiData) {
            return [];
        }
        return apiNames.map(api => {
            let matchedApi = apiData.find(item => item.ApiName === api);
            return { ApiName: api, Description: matchedApi?.Description || "" };
        });
    }

    var isShortcutModeActive = false;
    var keysPressed = [];

    function saveApiData(menuId) {
        let apiData = [];
        $(`#api-all-${menuId} .api-item input`).each(function () {
            let id = $(this).attr("id") || "";
            let value = $(this).val() || "";
            if (id.startsWith("api-")) {
                apiData.push({ ApiName: id.replace("api-", ""), Description: "" });
            } else if (id.startsWith("func-")) {
                let apiName = id.replace("func-", "");
                let existingApi = apiData.find(api => api.ApiName === apiName);
                if (existingApi) {
                    existingApi.Description = value;
                }
            }
        });

        AjaxHPAParadise({
            data: {
                name: "api_saveApiDecription",
                param: ["MenuID", menuId, "ApiList", JSON.stringify(apiData)]
            },
            success: function (result) {}
        });
    }

    function createModalSetting(menuId, menuName, className) {
        addStyles();

        let shortcut = (ShortcutKeysList || []).find(s => s.MenuID === menuId);
        let shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
        let shortCutCur = shortcut?.ShortcutKeys ?? null;

        if ($(`#settingsModal-${menuId}`).length > 0) {
            $(`#settingsModal-${menuId}`).remove();
        }

        let modalHtml = `
            <div style="background-color: rgba(0, 0, 0, 0.5) !important;" class="modal fade" id="settingsModal-${menuId}"
                tabindex="-1" aria-labelledby="settingsModalLabel-${menuId}" aria-hidden="true" data-bs-backdrop="static"
                data-bs-keyboard="false">
                <div class="modal-dialog modal-dialog-centered ui-draggable" style="max-width: 850px; width: 100%;">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="settingsModalLabel-${menuId}">${menuName}</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <h6>Thông tin menu</h6>
                            <ul class="custom-list">
                                <li>
                                    <i class="bi bi-gear"></i>
                                    <b>Tên menu:</b> <span class="copy-text">${menuName}</span>
                                </li>
                                <li>
                                    <i class="bi bi-card-list"></i>
                                    <b>MenuID:</b> <span class="copy-text">${menuId}</span>
                                </li>
                                <li>
                                    <i class="bi bi-folder"></i>
                                    <b>Tên thủ tục:</b> <span class="copy-text">${className}</span>
                                </li>
                            </ul>

                            <h6>Thiết lập phím tắt</h6>
                            <div class="shortcut-container">
                                <button class="btn btn-primary" id="setShortcutBtn-${menuId}">Nhấn để thiết lập phím tắt</button>
                                <button class="btn btn-danger ms-2" id="delShortcutBtn-${menuId}" data-menu-id="${menuId}">Hủy phím tắt</button>
                                <p class="text-primary mb-0 ms-3" id="shortcutDisplay-${menuId}">
                                    ${shortcutText.toUpperCase()}
                                </p>
                            </div>
                            <div class="alert alert-warning d-flex align-items-center d-none mt-2" id="shortcutWarning-${menuId}">
                                Cảnh báo: Phím tắt này đã được sử dụng!
                            </div>
                            <div class="alert alert-success d-flex align-items-center d-none mt-2" id="shortcutSuccess-${menuId}">
                                Ghi đè thành công!
                            </div>

                            <div class="d-flex align-items-center justify-content-between mb-3 mt-3">
                                <h6 class="mb-0">Danh sách các API được sử dụng</h6>
                                <input type="text" id="apiSearch-${menuId}" class="form-control" style="width: 200px;" placeholder="Tìm kiếm API">
                            </div>
                            <div id="api-all-${menuId}" class="api-all">
                                <span class="text-secondary">Đang tải danh sách API...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        $("body").append(modalHtml);

        const $modal = $(`#settingsModal-${menuId}`);
        const $shortcutDisplay = $(`#shortcutDisplay-${menuId}`);
        const $buttonDel = $(`#delShortcutBtn-${menuId}`);
        const $setBtn = $(`#setShortcutBtn-${menuId}`);
        const $warning = $(`#shortcutWarning-${menuId}`);
        const $success = $(`#shortcutSuccess-${menuId}`);

        if (typeof $.fn.draggable === "function") {
            $modal.find(".modal-dialog").draggable({ handle: ".modal-header" });
        }

        if (!shortcut) {
            $buttonDel.hide();
        } else {
            $buttonDel.show();
        }

        $setBtn.on("click", function () {
            let button = $(this);
            if (!isShortcutModeActive) {
                isShortcutModeActive = true;
                button.addClass("active").text("Đang thiết lập phím tắt...").css("background-color", "red");
                $shortcutDisplay.text("");
                $warning.addClass("d-none").hide();
                keysPressed = [];
                var ShortcutKeys = "";
                $(document).off("keydown.shortcut").on("keydown.shortcut", function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    let key = e.key.toUpperCase();
                    if (key !== "ESCAPE" && !keysPressed.includes(key) && keysPressed.length < 3) {
                        keysPressed.push(key);
                        $shortcutDisplay.text(keysPressed.join(" + "));
                        ShortcutKeys = keysPressed.join("+");
                    } else if (key === "ESCAPE") {
                        keysPressed = [];
                        $shortcutDisplay.text("");
                    }
                    if (keysPressed.length >= 3) {
                        $(document).off("keydown.shortcut");
                    }
                });
            } else {
                isShortcutModeActive = false;
                $(document).off("keydown.shortcut");
                button.removeClass("active").text("Nhấn để thiết lập phím tắt").css("background-color", "#0d6efd");
                let ShortcutKeys = keysPressed.join("+");
                if (ShortcutKeys === shortCutCur) {
                    $shortcutDisplay.text(shortcutText);
                    $warning.html(`Cảnh báo: Phím tắt "${ShortcutKeys}" đã được sử dụng cho menu hiện tại, vui lòng chọn phím khác!`).removeClass("d-none").show();
                    return;
                }
                if (ShortcutKeys === "CONTROL+F" || ShortcutKeys === "F1") {
                    $shortcutDisplay.text(shortcutText);
                    $warning.html(`Cảnh báo: Phím tắt "${ShortcutKeys}" là phím mặc định của hệ thống!`).removeClass("d-none").show();
                    return;
                }
                if (ShortcutKeys) {
                    AjaxHPAParadise({
                        data: {
                            name: "api_saveShortKeys",
                            param: ["MenuID", menuId, "ShortcutKeys", ShortcutKeys]
                        },
                        success: function (result) {
                            var res = typeof result === "string" ? JSON.parse(result) : result;
                            var data = res.data[0];
                            ShortcutKeysList = data;
                            updateShortcuts(ShortcutKeysList);
                            shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
                            shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
                            shortCutCur = shortcut?.ShortcutKeys ?? null;
                            $shortcutDisplay.text(shortcutText);
                            $buttonDel.show();
                            $success.removeClass("d-none").show();
                            setTimeout(() => { $success.addClass("d-none").hide(); }, 3000);
                        }
                    });
                }
            }
        });

        $buttonDel.on("click", function () {
            AjaxHPAParadise({
                data: {
                    name: "api_delShortKeys",
                    param: ["MenuID", menuId]
                },
                success: function (result) {
                    var res = typeof result === "string" ? JSON.parse(result) : result;
                    var data = res.data[0];
                    ShortcutKeysList = data;
                    updateShortcuts(ShortcutKeysList);
                    shortcutText = "CHƯA THIẾT LẬP PHÍM TẮT";
                    shortCutCur = null;
                    $shortcutDisplay.text(shortcutText);
                    $buttonDel.hide();
                }
            });
        });

        $(`#apiSearch-${menuId}`).on("input", function () {
            let searchTerm = $(this).val().toLowerCase();
            $(`#api-all-${menuId} .api-list`).each(function () {
                let apiName = $(this).find(".api-item input").first().val().toLowerCase();
                if (apiName.includes(searchTerm)) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            });
        });

        $modal.find(".custom-list span").on("click", function () {
            let text = $(this).text().trim();
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text);
            }
        });

        $modal.on("hidden.bs.modal", function () {
            isShortcutModeActive = false;
            keysPressed = [];
            $setBtn.removeClass("active").text("Nhấn để thiết lập phím tắt").css("background-color", "#0d6efd");
            saveApiData(menuId);
        });
    }

    $(document).on("keydown", function (e) {
        if (e.key === "F1" || e.keyCode === 112) {
            e.preventDefault();
            e.stopPropagation();

            const activeTab = $(".nav-link.active");
            const activePane = $(".tab-pane.active");
            let menuIdd = "";
            let tabText = "";

            if (activeTab.length > 0) {
                const tabId = activeTab.filter("button").attr("id") || activeTab.attr("id") || "";
                menuIdd = tabId.split("-").pop();
                tabText = activeTab.text().trim();
            }
            if (!menuIdd && activePane.length > 0) {
                const paneId = activePane.attr("id") || "";
                menuIdd = paneId.replace("dynamic-pane-", "").replace("pane-", "");
            }

            if (menuIdd) {
                if (isShortcutModeActive === true) return;

                let menuItem = (window.dataMenuViewHtml || []).find(m => m.Child === menuIdd || m.ClassName === menuIdd);
                let menuName = menuItem ? menuItem.Data : (tabText || menuIdd);
                let className = menuItem ? (menuItem.ClassName || menuItem.Child) : menuIdd;

                if ($(`#settingsModal-${menuIdd}`).length === 0) {
                    createModalSetting(menuIdd, menuName, className);
                }

                const $modal = $(`#settingsModal-${menuIdd}`);
                const $shortcutDisplay = $(`#shortcutDisplay-${menuIdd}`);
                const $btnDel = $(`#delShortcutBtn-${menuIdd}`);

                if (typeof $.fn.draggable === "function") {
                    $modal.find(".modal-dialog").draggable({ handle: ".modal-header" });
                }

                AjaxHPAParadise({
                    data: {
                        name: "api_getShortKeys",
                        param: ["MenuID", menuIdd]
                    },
                    success: function (result) {
                        var res = typeof result === "string" ? JSON.parse(result) : result;
                        var data = res?.data?.[0]?.[0];
                        if (!data) {
                            $btnDel.hide();
                        } else {
                            $btnDel.show();
                        }
                        let shortcut = data;
                        let shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
                        $(`#shortcutWarning-${menuIdd}`).addClass("d-none").hide();
                        $shortcutDisplay.text(shortcutText);

                        AjaxHPAParadise({
                            data: {
                                name: "api_getApiDecription",
                                param: ["MenuID", menuIdd]
                            },
                            success: function (resultDesc) {
                                let APIListCur = "[]";
                                try {
                                    let parsedResult = typeof resultDesc === "string" ? JSON.parse(resultDesc) : resultDesc;
                                    if (parsedResult?.data?.length > 0 && parsedResult.data[0]?.length > 0 && parsedResult.data[0][0]?.ApiList) {
                                        APIListCur = parsedResult.data[0][0].ApiList;
                                    }
                                } catch (error) {
                                    console.error("Lỗi khi parse JSON:", error);
                                }
                                let apiNames = apiName();
                                let APIListFull = apiNameWithDescription(apiNames, JSON.parse(APIListCur));

                                let apiListHtml = "";
                                if (APIListFull.length > 0) {
                                    APIListFull.forEach((api) => {
                                        apiListHtml += `
                                        <div class="api-list">
                                            <div class="api-item">
                                                <input style="width: 100%;" type="text" class="form-control" id="api-${api.ApiName}" value="${api.ApiName}" readonly>
                                            </div>
                                            <div class="api-item">
                                                <input style="width: 100%;" type="text" class="form-control" id="func-${api.ApiName}"
                                                    placeholder="Thêm mô tả cho ${api.ApiName}" value="${api.Description || ''''}">
                                            </div>
                                        </div>`;
                                    });
                                } else {
                                    apiListHtml += `<span class="text-secondary">Không có API được sử dụng trong menu</span>`;
                                }

                                $(`#api-all-${menuIdd}`).html(apiListHtml);
                                $modal.modal("show");
                            },
                            error: function() {
                                $modal.modal("show");
                            }
                        });
                    },
                    error: function() {
                        $modal.modal("show");
                    }
                });
            }
        }
    });

window.currentTheme = document.documentElement.getAttribute("data-bs-theme") === "dark" ? "dark" : "light";

   if(UserID != 23)
   {

     $(''#launchpad'').fadeIn();

   }
   $(''#launchpad'').hide();
function checkAndInitOnTabSelect(menuId, initFunction) {
     const tabButton = document.getElementById(''dynamic-tab-'' + menuId);
     if (tabButton) {
         // Tạo MutationObserver để theo dõi thay đổi thuộc tính
         const observer = new MutationObserver(function(mutations) {
       mutations.forEach(function(mutation) {
                if (mutation.type === ''attributes'' && mutation.attributeName === ''aria-selected'') {
                     const isSelected = tabButton.getAttribute(''aria-selected'') === ''true'';
                     if (isSelected) {
                         // Kiểm tra nếu initFunction là string thì chuyển thành function
         if (typeof initFunction === ''string'') {
                       // Kiểm tra function có tồn tại không
                             if (typeof window[initFunction] === ''function'') {
                                 window[initFunction]();
                             }
                         } else if (typeof initFunction === ''function'') {
                             initFunction();
                         }
                     }
                 }
             });
         });
         observer.observe(tabButton, {
             attributes: true,
             attributeFilter: [''aria-selected'']
         });
     }
 }

   </script>


		<script>
			var NS_DashBoard = "Nhân sự";
			var TL_DashBoard = "Tính lương";
			var CC_DashBoard = "Chấm công";
			var btnReminderText = "Nhắc việc";
			var reloadRemainText = "Làm mới dữ liệu";
var btnLeaveEmployeeText = "Nhân viên nghỉ việc";

var btnProbationEmployeeText = "Nhân viên thử việc";
var btnOfficialEmployeeText = "Nhân viên chính thức";
var employeeChangeByYearText = "Số lượng nhân sự biến động theo năm";
var genderRatioText = "Tỷ lệ nam-nữ trong công ty";
var ageStructureText = "Cơ cấu nhân sự theo độ tuổi";
var newContractTrendText = "Xu hướng số lượng hợp đồng mới ký theo thời gian";
var contractDistributionText = "Phân bổ số lượng hợp đồng của nhân viên";
var employeeLeavePerMonthText = "Số lượng nhân viên nghỉ theo tháng";
var leaveByDepartmentText = "Tổng số ngày nghỉ theo từng phòng ban";
var menuSettingsText = "Cài đặt Menu";
var noBirthdayThisMonthText = "Không có sinh nhật trong tháng này";
var sortText = "Sắp xếp";
var displayText = "Hiển thị";
var cancelButtonText = "Hủy";
var saveButtonText = "Lưu";
var maternityStatusText = "Nhân viên thai sản sắp hết hạn";
var contractExpiryText = "Hợp đồng sắp hết hạn";
var contractStatusText = "Hợp đồng sắp hết hạn";

var birthdayText = "Sinh nhật";
var lateStatusText = "Đi trễ";
var pendingLeaveText = "Nghỉ phép chờ duyệt";
var pendingOvertimeText = "Tăng ca chờ duyệt";
var lockStatusAttendanceText = "Trạng thái khóa công tháng";
var lockStatusSalaryText = "Trạng thái khóa lương tháng";
var leaveListText = "Danh sách nhân viên nghỉ phép";
var contractExpiryAndValidText = "Tỉ lệ hợp đồng sắp hết hạn và còn hiệu lực";
var statusText = "Trạng thái";
var lockedEmployeeCountText = "Số lượng nhân viên đã khóa";
var lockedStatusText = "Đã khóa";
var unlockedStatusText = "Chưa khóa";
var shiftLockPageLinkText = "Tới trang khóa công";
var salaryLockPageLinkText = "Tới trang khóa lương";

$(document).on(''input'', ''.launchpad .search-input, .launchpad input[type="search"]'', function(e) {
    searchApps(e.target.value);
});

$(document).on(''click'', ''#launchpad'', function(e) {
    if ($(e.target).closest(''.carousel, .searchbox, .searchContainer, .change-icon, .child-launchpad'').length === 0) {
        handleOpenLaunching();
    }
});

(() => {
    // User Request: nếu window.LoginID undefine thì kiểm tra window.UserID coi còn tồn tại không thì đè lên
    if (typeof window.LoginID === "undefined" || !window.LoginID || (typeof window.UserID !== "undefined" && window.UserID && window.LoginID !== window.UserID)) {
        if (typeof window.UserID !== "undefined" && window.UserID) {
            window.LoginID = window.UserID;
        } else if (typeof UserID !== "undefined" && UserID) {
            window.LoginID = UserID;
        }
    }
    if (typeof window.LanguageID === "undefined") window.LanguageID = "VN";

    var screenHeight = window.innerHeight;
    var screenWidth = window.innerWidth;
    var navbarHeight = screenHeight * 0.065;
    var navbar_leftHeight = navbarHeight * 0.85;
    var SideBarHeight = screenWidth * 0.15;

    var navbar__left = document.getElementById("ID-navbar__left");
    if (navbar__left) navbar__left.style.height = navbar_leftHeight + "px";

    var navbarHome = document.getElementById("ID-navbar-home");
    var actualNavHeight = navbarHeight;
    if (navbarHome) {
        navbarHome.style.height = (navbarHeight + 3) + "px";
        actualNavHeight = navbarHome.offsetHeight || (navbarHeight + 3);
        var masterTabs = document.getElementById("master-tabs");
        if (masterTabs) masterTabs.style.marginTop = actualNavHeight + "px";
    }
    document.documentElement.style.setProperty("--navbar-height", actualNavHeight + "px");

    var MainSideBar = document.getElementById("MainSideBar");
    if (MainSideBar) {
        MainSideBar.style.width = SideBarHeight + "px";
        MainSideBar.style.top = actualNavHeight + "px";
        MainSideBar.style.height = "calc(100vh - " + actualNavHeight + "px)";
    }

    var LogoNavbar = document.querySelector(''.navbar__left'');
    if (LogoNavbar) {
        LogoNavbar.addEventListener(''click'', () => {
            window.location.reload();
        });
    }

    // userDetails popup hoan toan bi vo hieu hoa theo yeu cau, avatarTrigger da duoc delegate mo Mobile Settings Drawer
    var userDetails = document.getElementById(''userDetails'');
    if (userDetails) userDetails.classList.remove(''active'');

    // Helper to call Ajax safely
    function runAjaxHPA(options) {
        if (typeof AjaxHPAParadise === "function" && typeof window.HPA !== "undefined" && window.HPA && window.HPA.HPAClient) {
            AjaxHPAParadise(options);
        } else if (window.dotNetReadyPromise) {
            window.dotNetReadyPromise.then(() => {
                if (typeof AjaxHPAParadise === "function") AjaxHPAParadise(options);
            });
        } else {
            setTimeout(() => runAjaxHPA(options), 100);
        }
    }

    // taidang: [API 1] Gọi sp_GetMacOSMenuData_API TRƯỚC ĐỂ NẠP ĐẦY ĐỦ CÂY MENU, DOCK VÀ LAUNCHPAD
    runAjaxHPA({
        data: {
            name: "sp_GetMacOSMenuData_API",
            param: [
                "LoginID", window.LoginID || window.UserID || (typeof UserID !== "undefined" ? UserID : null),
                "LanguageID", window.LanguageID || "VN"
            ]
        },
        success: function(res) {
            try {
                var json = typeof res === "string" ? JSON.parse(res) : res;
                var menuData = (json && json.data && json.data[0]) || [];
                var shortcuts = (json && json.data && json.data[1]) || [];
                var dockConfig = (json && json.data && json.data[2] && json.data[2][0]) || {};

                window.dataMenuViewHtml = menuData;
                window.ShortcutKeysList = shortcuts;

                // Nạp chỉ số phân cách Dock HR
                window.firtHrElement = typeof dockConfig.firtHrElement !== "undefined" ? dockConfig.firtHrElement : 0;
                firtHrElement = window.firtHrElement;
                window.secondHrElement = typeof dockConfig.secondHrElement !== "undefined" ? dockConfig.secondHrElement : 0;
                secondHrElement = window.secondHrElement;

                // Nạp thứ tự Dock từ cấu hình người dùng
                if (dockConfig.orderDockApp) {
                    try {
                        window.orderDockApp = typeof dockConfig.orderDockApp === "string" ? JSON.parse(dockConfig.orderDockApp) : dockConfig.orderDockApp;
                    } catch(e) {
                        window.orderDockApp = [];
                    }
                }
                orderDockApp = window.orderDockApp;

                // 1. LaunchPad apps: các menu con (Level <> 0)
                window.apps = menuData.filter(function(x) { return x.Level !== 0 && x.Child && x.Child !== ''MnuSCR000'' && x.Child !== ''MnuSCR041'' && x.Child !== ''MnuSCR610''; }).map(function(x) {
                    return {
                        id: x.Child,
                        name: x.Data,
                        keywords: x.Data,
                        img: x.SvgIcon,
                        className: x.ClassName,
                        ParentMenuID: x.Parent,
                        Level: x.Level,
                        showDialog: x.showDialog || 0,
                        isShowLayOutWeb: x.isShowLayOutWeb || 0,
                        IconBackColor: x.IconBackColor || '''',
                        IconForeColor: x.IconForeColor || '''',
                        ObjectID: x.ObjectID || 0
                    };
                });
                window.filteredApps = window.apps;
                filteredApps = window.apps;

                // 2. appsDock: nạp toàn bộ các menu items
                var allDockCandidates = menuData.filter(function(x) { return x.Child; }).map(function(x) {
                    return {
                        id: x.Child,
                        name: x.Data,
                        keywords: x.Data,
                        img: x.SvgIcon,
                        className: x.ClassName,
                        ParentMenuID: x.Parent,
                        Level: x.Level
                    };
                });

                // Sắp xếp appsDock theo thứ tự orderDockApp
                var combinedApp = [...window.apps, ...allDockCandidates];
                combinedApp = Array.from(new Map(combinedApp.map(function(app) { return [app.id, app]; })).values());
                combinedApp = combinedApp.filter(function(app) { return orderDockApp.includes(app.id); });

                function sortArrayByOrder(orginalArray, orderArr) {
                    return orginalArray.sort(function(a, b) {
                        var indexA = orderArr.indexOf(a.id);
                        var indexB = orderArr.indexOf(b.id);
                        return indexA - indexB;
                    });
                }
                window.appsDock = sortArrayByOrder(combinedApp, orderDockApp);
                appsDock = window.appsDock;

                // 3. Render giao diện Dock, Launchpad, Layout
                if (typeof renderAppsCarousel === "function") renderAppsCarousel();
                if (typeof renderAppsDock === "function") renderAppsDock();
                if (typeof adjustLayout === "function") adjustLayout();
                if (typeof loadShortcuts === "function") loadShortcuts();
                // 4. SAU KHI MENU ĐÃ SẴN SÀNG -> GỌI sp_GetMacOSUserInfo_API NẠP PROFILE VÀ MỞ DASHBOARD
                runAjaxHPA({
                    data: {
                        name: "sp_GetMacOSUserInfo_API",
                        param: [
                            "LoginID", window.LoginID || window.UserID || (typeof UserID !== "undefined" ? UserID : null),
                            "LanguageID", window.LanguageID || "VN"
                        ]
                    },
                    success: function(resUser) {
                        try {
                            var jsonUser = typeof resUser === "string" ? JSON.parse(resUser) : resUser;
                            var user = jsonUser && jsonUser.data && jsonUser.data[0] && jsonUser.data[0][0];
                            var rights = (jsonUser && jsonUser.data && jsonUser.data[1]) || [];
                            if (rights.length > 0) {
                                window.fullRightObject = rights;
                                fullRightObject = rights;
                            }
                            if (user) {
                                window.UserID = (user && user.UserID) ? user.UserID : (window.UserID || (typeof UserID !== "undefined" ? UserID : null));
                                window.LoginID = window.UserID;
                                window.EmployeeID_Login = user.EmployeeID;
                                window.EmployeeID = user.EmployeeID;
                                window.SexID = user.Sex;
                                window.LanguageCode = user.LanguageCode;

                                $("#userName").text("Xin chào, " + (user.FullName || user.UserName) + (user.EmployeeID ? " (" + user.EmployeeID + ")" : ""));
                                $("#positionuser").text(user.PositionName || "");

                                var randomAvatar = $("#randomAvatar");
                                randomAvatar.attr("data-employee-id", user.EmployeeID);
                                if (typeof callImg_with_loginID_or_employeeID === "function") {
                                    callImg_with_loginID_or_employeeID(randomAvatar, null, user.EmployeeID);
                                }

                                // 5. NẠP EMPLOYEE TREE VIEW NGAY SAU KHI ĐÃ CÓ USERID/LOGINID HỢP LỆ (TRÁNH LỖI DATA LOADING ERROR DO LOGINID NULL/ÂM)
                                loadEmployeeTreeScriptSafe();

                                if (typeof treeListInstance !== "undefined" && treeListInstance) {
                                    try {
                                        isNewSearch = true;
                                        expandReload = true;
                                        treeListInstance.refresh();
                                    } catch(e) {}
                                }

                                // Mở form mặc định: Nếu không mở được Quản trị nhân sự thì mở sp_dashboard_home_new_customer
                                var targetDashboard = (user.DefaultDashboardForm && user.DefaultDashboardForm.trim() !== "") ? user.DefaultDashboardForm : "sp_dashboard_home_new_customer";
                                if (targetDashboard === "sp_dashboard_humanresource") {
                                    var appListCheck = (typeof apps !== "undefined" && Array.isArray(apps)) ? apps : (window.apps || []);
                                    var hasHRApp = appListCheck.some(function(x) {
                                        return (x.className && x.className.toLowerCase() === "sp_dashboard_humanresource") || x.id === "MnuHRS002";
                                    });
                                    if (!hasHRApp) {
                                        targetDashboard = "sp_dashboard_home_new_customer";
                                    }
                                }
                                if (typeof openFormParam === "function") {
                                    openFormParam(targetDashboard);
                                }
                            } else {
                                loadEmployeeTreeScriptSafe();
                            }
                        } catch(e) {
                            console.error("Error parsing user profile:", e);
                            loadEmployeeTreeScriptSafe();
                        }
                    },
                    error: function(err) {
                        console.error("Error loading sp_GetMacOSUserInfo_API:", err);
                        loadEmployeeTreeScriptSafe();
                    }
                });

                // HÀM NẠP SCRIPT EMPLOYEE TREE VIEW QUA API VỚI LOGINID HỢP LỆ
                function loadEmployeeTreeScriptSafe() {
                    if (window._employeeTreeLoaded) return;
                    window._employeeTreeLoaded = true;
                    var safeLoginID = (window.UserID && window.UserID > 0) ? window.UserID : ((window.LoginID && window.LoginID > 0) ? window.LoginID : 3);
                    if (!window.UserID || window.UserID <= 0) window.UserID = safeLoginID;
                    if (!window.LoginID || window.LoginID <= 0) window.LoginID = safeLoginID;

                    runAjaxHPA({
                        data: {
                            name: "sp_GetEmployeeTreeScript_API",
                            param: [
                                "LoginID", safeLoginID,
                                "LanguageID", window.LanguageID || "VN"
                            ]
                        },
                        success: function(resTree) {
                            try {
                                var jsonTree = typeof resTree === "string" ? JSON.parse(resTree) : resTree;
                                var scriptContent = jsonTree && jsonTree.data && jsonTree.data[0] && jsonTree.data[0][0] && jsonTree.data[0][0].script;
                                if (scriptContent) {
                                    scriptContent = scriptContent.replace(/<\/?script>/gi, "");
                                    var scriptEl = document.createElement("script");
                                    scriptEl.text = scriptContent;
                                    document.body.appendChild(scriptEl);
                                }
                            } catch(e) {
                                console.error("Error loading employee tree script via API:", e);
                            }
                        },
                        error: function(err) {
                            console.error("Error loading sp_GetEmployeeTreeScript_API:", err);
                        }
                    });
                }

                // Fallback nếu API profile chậm quá 2s thì tự kích hoạt nạp cây nhân viên
                setTimeout(loadEmployeeTreeScriptSafe, 2000);


            } catch(e) {
                console.error("Error parsing menu data:", e);
            }
        },
        error: function(err) {
            console.error("Error loading sp_GetMacOSMenuData_API:", err);
        }
    });

    // Utilities
    window.copyViaExcelExport = function(gridInstance, isSelectedRowsOnly, copyWithHeader) {
        let workbook = new ExcelJS.Workbook();
        let sheet = workbook.addWorksheet("dummy");
        let str = "";
        let col = gridInstance.getVisibleColumns().filter(x => x.dataField !== undefined && x.allowExporting);
        let lastColumn = col[col.length - 1]?.dataField;

        DevExpress.excelExporter.exportDataGrid({
            component: gridInstance,
            worksheet: sheet,
            selectedRowsOnly: isSelectedRowsOnly,
            loadPanel: { showPane: false, message: "%copying%" },
            customizeCell: function(options) {
                let { gridCell } = options;
                let field = gridCell.column.dataField;
                if (gridCell.rowType === "data") {
                    str += (gridCell.value ?? "") + "\t";
                    if (field === lastColumn) str += "\r\n";
                }
            }
        }).then(() => {
            navigator.clipboard.writeText(str);
        });
    };

    window.showPopupNotify = function(title, content, btnOKText = "OK", popupWidth = "15vw", closePopupFunction = () => {}) {
        var myDialog = DevExpress.ui.dialog.custom({
            title: title,
            messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
            buttons: [{ text: btnOKText, onClick: () => true }]
        });
        myDialog.show().done(() => closePopupFunction());
    };
})();
</script>
';

    -- GHÉP NỐI: [Style CSS] + [Main Script] + [OpenForm Script] + [MacOS Template HTML]
    -- (Gỡ bỏ StyleCSSParadise và ScriptMainParadise vì sslayoutbody đã nạp sẵn ở layout cha)
    SET @htmlStr = /* ISNULL(@StyleCSSParadise, N'') + N'
    ' + ISNULL(@ScriptMainParadise, N'') + N'
    ' + */ ISNULL(@ScriptOpenForm, N'') + N'
    ' + @htmlStr;

    SELECT @htmlStr AS [html];
--EXEC sp_GenerateHTMLScript_new 'HtmlMacOSLayOut_html'
END
