/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-8
  MÀN HÌNH / MENU    : Nhân sự -> Hợp đồng lao động (MnuSCR011)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/3]: [dbo].[LabourContract_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[LabourContract_html]

(

    @LoginID INT = 3,

    @LanguageID VARCHAR(2) = 'VN',

    @isWeb INT = 1

)

AS

BEGIN

    SET NOCOUNT ON;



    DECLARE @html NVARCHAR(MAX);



    SET @html = N'

<style>
#labourContractSegmentPage {
    width: 100%;
    padding: 6px 10px;
    box-sizing: border-box;
    position: relative;
}

#labourContractSegmentBar {
    position: absolute;
    top: 4px;
    left: 10px;
    z-index: 20;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px;
    border: 1px solid var(--bs-border-color, rgba(255, 255, 255, 0.15));
    border-radius: 999px;
    background: var(--bs-tertiary-bg, rgba(255, 255, 255, 0.06));
    max-width: calc(100% - 450px);
    overflow-x: auto;
    overflow-y: hidden;
    white-space: nowrap;
}

.labour-seg-btn {
    border: 0;
    background: transparent;
    border-radius: 999px;
    padding: 5px 14px;
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
}

#lazyLoadContainer {
    min-height: 420px;
    width: 100%;
}

#lazyLoadContainer .dx-toolbar {
    background: transparent !important;
    min-height: 44px !important;
    height: 44px !important;
    margin-bottom: 6px !important;
    padding: 0 !important;
    position: relative !important;
}

#lazyLoadContainer .dx-toolbar-after {
    position: absolute !important;
    right: 0px !important;
    top: -10px !important;
    z-index: 21 !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
}

#lazyLoadContainer .dx-datagrid {
    width: 100% !important;
}
</style>

<div id="labourContractSegmentPage">

  <div id="labourContractSegmentBar"></div>

  <div id="lazyLoadContainer"><div style="padding:12px;color:#999">Đang khởi tạo...</div></div>

</div>

<script>

(function(){

  var isEN = (window.LanguageID || "VN") === "EN";

  function ajaxSP(name, param, ok, fail){

    AjaxHPAParadise({ data:{ name:name, param:param||[] }, success:ok, error:fail||function(){} });

  }

  function rows(res){

    var j = typeof res === "string" ? JSON.parse(res) : res;

    return (j && j.data && j.data[0]) || [];

  }

  function renderTabs(list){

    var bar = $("#labourContractSegmentBar").empty();

    var defaultTab = list[0] ? (list[0].ID || list[0].Id || list[0].id) : null;
    try {
      var af = JSON.parse(sessionStorage.getItem(''__pendingAlertFilter''));
      if (af && (af.alertId === ''recalc_contract_expired'' || af.alertId === ''contract_expired'')) {
        var hasUpcoming = list.some(function(x) { return (x.ID || x.Id || x.id) === ''LabourContract_Upcoming''; });
        if (hasUpcoming) defaultTab = ''LabourContract_Upcoming'';
      }
    } catch(e) {}

    list.forEach(function(x, i){

      var id = x.ID || x.Id || x.id;

      var name = x.Name || x.Text || x.name || id;

      var btn = $("<button type=\"button\" class=\"labour-seg-btn\"></button>").text(name).attr("data-id", id);

      btn.on("click", function(){ selectTab(id); });

      bar.append(btn);

      if(id === defaultTab) setTimeout(function(){ selectTab(id); }, 0);

    });

  }

  function selectTab(tableName){

    $(".labour-seg-btn").removeClass("active");

    $(".labour-seg-btn[data-id=''" + tableName + "'']").addClass("active");

    var c = $("#lazyLoadContainer").html("<div style=\"padding:12px;color:#006b45;font-weight:600\">" + (isEN ? "Loading data..." : "Đang tải dữ liệu...") + "</div>");

    ajaxSP("ssGetConfigMobileHTMLLayout", [

      "TableName", tableName,

      "LanguageID", window.LanguageID || "VN",

      "LoginID", window.LoginID || 3,

      "TypeLayout", window.TypeLayout || 0,

      "IsWeb", true

    ], function(res){

      try{

        var j = typeof res === "string" ? JSON.parse(res) : res;

        var h = j && j.data && j.data[0] && j.data[0][0];

        c.empty().append((h && (h.Html || h.html)) || "<div style=\"padding:12px;color:#999\">" + (isEN ? "No data to display" : "Không có dữ liệu để hiển thị") + "</div>");

      }catch(e){ c.html("<div style=\"padding:12px;color:red\">" + e.message + "</div>"); }

    }, function(){ c.html("<div style=\"padding:12px;color:red\">" + (isEN ? "Data loading error." : "Lỗi tải dữ liệu.") + "</div>"); });

  }

  ajaxSP("sp_LoadLabourContract_SegmentTabs", ["LoginID", window.LoginID || 3, "LanguageID", window.LanguageID || "VN"], function(res){

    var list = rows(res);

    if(!list.length){ $("#lazyLoadContainer").html("<div style=\"padding:12px;color:#999\">" + (isEN ? "No tabs to display" : "Không có tab để hiển thị") + "</div>"); return; }

    renderTabs(list);

  }, function(){ $("#lazyLoadContainer").html("<div style=\"padding:12px;color:red\">" + (isEN ? "Error loading tab list." : "Lỗi tải danh sách tab.") + "</div>"); });

})();

</script>';



    SET @html = REPLACE(@html, N'Đang khởi tạo...', CASE WHEN @LanguageID = 'EN' THEN N'Initializing...' ELSE N'Đang khởi tạo...' END);

    SELECT @html AS html;

/*

EXEC sptblCommonControlType_Signed_DUC 'LabourContract_html';

EXEC sp_GenerateHTMLScript_new 'LabourContract_html';

*/

END
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/3]: [dbo].[sp_LabourContractHistory_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_LabourContractHistory_html]
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @html NVARCHAR(MAX) = N'';
    DECLARE @gridHtml NVARCHAR(MAX) = N'';
    DECLARE @gridLoadUI NVARCHAR(MAX) = N'';
    DECLARE @gridLoadData NVARCHAR(MAX) = N'';

    SELECT @gridHtml = ISNULL(html, N'')
    FROM dbo.tblCommonControlType_Signed
    WHERE UID = 'PA428B9149B444F7E954ADA09B94AAEE4';

    SET @gridLoadUI = N''
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA428B9149B444F7E954ADA09B94AAEE4'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P520306BA4D5241A4A672CCECACAA7F7B'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PE2EB1A62F9F944088587719DB2117441'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P73948779FC4B4A6A94E9B0577096134C'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P44977B169A95494BBD2744C1689DCA16'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P1ACEAA3E6BDE4516AC5A17413432A53B'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P99A71C1780D14DEC86D1BE4866AE768D'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PADEC361E32C24C8BA1200DD0002832E5'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PABF3CD40106C427C9DC9DFB2AFDD20F1'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PC9836391AD6045ED91F1550F54DDFD29'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PBFE4397D12D645AFA2C279B6D32DF7FF'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P1D78A392D49E4169B1B4914DD7EDA091'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA98A5EB11EFF4277B1F40D0CC5E0EE07'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'P75DCEA2547B84CD6AC16C7F829CD1C98'), N'')
        + ISNULL((SELECT loadUI FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA650878AFC624823B3FE561D03129056'), N'');

    SET @gridLoadData = N''
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA428B9149B444F7E954ADA09B94AAEE4'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P520306BA4D5241A4A672CCECACAA7F7B'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PE2EB1A62F9F944088587719DB2117441'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P73948779FC4B4A6A94E9B0577096134C'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P44977B169A95494BBD2744C1689DCA16'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P1ACEAA3E6BDE4516AC5A17413432A53B'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P99A71C1780D14DEC86D1BE4866AE768D'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PADEC361E32C24C8BA1200DD0002832E5'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PABF3CD40106C427C9DC9DFB2AFDD20F1'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PC9836391AD6045ED91F1550F54DDFD29'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PBFE4397D12D645AFA2C279B6D32DF7FF'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P1D78A392D49E4169B1B4914DD7EDA091'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA98A5EB11EFF4277B1F40D0CC5E0EE07'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'P75DCEA2547B84CD6AC16C7F829CD1C98'), N'')
        + ISNULL((SELECT loadData FROM dbo.tblCommonControlType_Signed WHERE UID = 'PA650878AFC624823B3FE561D03129056'), N'');

    SET @html = N'
<div id="lcHistoryRoot" class="lc-history-page">
  <section class="lc-grid-card">' + @gridHtml + N'</section>
</div>
<style>
.lc-history-page{font-family:var(--paradise-font-family-base);color:var(--paradise-text-body);height:100%;display:flex;flex-direction:column;gap:4px}.lc-search-row{display:grid;grid-template-columns:minmax(180px,1fr) auto minmax(220px,1fr);gap:6px;align-items:center}.lc-refresh-top{height:24px;border:0;border-radius:var(--paradise-border-radius-sm);background:#218c2f;color:#f7fff8;font-weight:700;cursor:pointer}.lc-search-input{height:24px;border:1px solid rgba(127,127,127,.4);border-radius:var(--paradise-border-radius-sm);background:var(--paradise-bg-surface);color:var(--paradise-text-body);padding:0 8px}.lc-grid-card{flex:1;min-height:0;background:var(--paradise-card-bg);overflow:hidden}.lc-grid-card #GridLabourContractHistory{height:100%;min-height:0}.lc-grid-card .dx-datagrid{border:0}.lc-grid-card .dx-datagrid-headers{border-top:0}.lc-toolbar-actions{margin-left:0;margin-right:8px;float:left}.lc-toolbar-action{display:inline-flex;align-items:center;justify-content:center;height:28px;min-width:30px;padding:0 8px;border:1px solid rgba(255,255,255,.45);font-size:13px;font-weight:600;cursor:pointer;border-radius:4px;background:#007a4d;color:#fff}.lc-toolbar-action:hover{background:#006b43;color:#fff}.lc-toolbar-print{min-width:132px}.lc-toolbar-sign{min-width:82px}.lc-toolbar-cancel{min-width:58px}
</style>
<script>(async function(){
' + @gridLoadUI + N'
' + @gridLoadData + N'
const grid=window.InstanceGridLabourContractHistoryPA428B9149B444F7E954ADA09B94AAEE4;
let selectedLabourContractHistoryRow=null;
window.selectedLabourContractHistoryRow=null;
window.currentRecordID_ContractID=null;
function lcSetSelectedRow(row){
  selectedLabourContractHistoryRow=row||null;
  window.selectedLabourContractHistoryRow=selectedLabourContractHistoryRow;
  window.currentRecordID_ContractID=row&&row.ContractID?row.ContractID:null;
}
function lcCallSp(spName, params){
  return new Promise(function(resolve,reject){
    AjaxHPAParadise({data:{name:spName,param:params},success:function(res){try{resolve(typeof res==="string"?JSON.parse(res):res);}catch(e){reject(e);}},error:function(err){reject(err);}});
  });
}
async function printSelectedLabourContractHistory(){
  /*LC_PRINT_FIX_V2*/
  const isEN=window.LanguageID==="EN";
  const row=selectedLabourContractHistoryRow||(grid&&grid.getSelectedRowsData?grid.getSelectedRowsData()[0]:null);
  if(!row||!row.ContractID){uiManager.showAlert({type:"warning",message:(isEN?"Please select a contract row first.":"Vui long chon dong hop dong can in.")});return;}
  try{
    if(typeof ShowWaitingPanel==="function") ShowWaitingPanel();
    const loginId=window.UserID||window.LoginID||3;
    const resultData=await AjaxHPAParadiseParadiseAsync({data:{name:"sp_LabourContractHistory_ExportAction",param:["LoginID",loginId,"LanguageID",window.LanguageID||"VN","ContractID",row.ContractID,"IPWan",window.IPWan||"255.255.255.255","ComputerName",window.ComputerName||"Web"]}});
    const json=typeof resultData==="string"?JSON.parse(resultData):resultData;
    const outRow=(json&&json.data||[]).flatMap(function(ds){return Array.isArray(ds)?ds:[];}).find(function(r){return r&&(r.Result||r.result||r.TemplateFileName||r.templateFileName);})||{};
    if((outRow.Result||outRow.result)==="error") throw new Error(outRow.Message||outRow.message||(isEN?"Export failed.":"Xuat file that bai."));
    const exportName=outRow.ExportName||outRow.exportName;
    const fileName=outRow.TemplateFileName||outRow.FileName||outRow.fileName;
    if(!exportName||!fileName) throw new Error(isEN?"Missing export template information.":"Thieu thong tin mau xuat file.");
    const outData=await AjaxHPAParadiseParadiseAsync({data:{name:"ExportLocationFolder",param:["",exportName,fileName,"@LoginID",loginId]}});
    let out=typeof outData==="string"?JSON.parse(outData):outData;
    if(out&&out.result==="error") throw new Error(out.reason||(isEN?"Cannot create export file.":"Khong tao duoc file xuat."));
    out=(out&&typeof out.data==="string")?JSON.parse(out.data):(out?out.data:null);
    if(!out||!out.FilePath) throw new Error(isEN?"Export file path is empty.":"Duong dan file xuat bi trong.");
    const bytesData=await AjaxHPAParadiseParadiseAsync({data:{name:"ReadPathFileToByte",param:[out.FilePath]}});
    const bytes=typeof bytesData==="string"?JSON.parse(bytesData):bytesData;
    if(typeof saveAsFile!=="function") throw new Error(isEN?"Browser does not support file download.":"Trinh duyet khong ho tro tai file.");
    saveAsFile(((row.EmployeeID||"")+"_"+(out.FileName||fileName)),bytes.data);
    if(window.uiManager&&uiManager.showAlert){uiManager.showAlert({type:"success",message:(isEN?"Contract exported.":"Da xuat hop dong.")});}
  }catch(e){console.error(e);uiManager.showAlert({type:"error",message:e.message||(isEN?"Print contract failed.":"In hop dong that bai.")});}
  finally{if(typeof HideWaitingPanel==="function") HideWaitingPanel();}
}

function lcNormalizeGridRows(rows){
  (rows||[]).forEach(function(r){
    if(r && String(r.NextContractCode || "").trim() === "-1") r.NextContractCode = "";
    if(r && /\.docx?$/i.test(String(r.ContractTemplateName || "").trim())) r.ContractTemplateName = "";
  });
  return rows;
}
const lcColumnOrder=["EmployeeID","FullName","ContractNo","LabourName","ContractStartDay","ContractEndDay","LBIssueDate","NextContractCode","ContractTemplateName","InsuranceStatusID","IsLock","PITStatus","SalaryHistoryID","Note"];
function lcApplyColumnOrder(){
  if(!grid||!grid.option)return;
  try{
    if(grid.state){grid.state(null);}
    grid.option("stateStoring.enabled",false);
    const current=grid.option("columns")||[];
    const byField={};
    current.forEach(function(c){if(c&&(c.dataField||c.name)){byField[c.dataField||c.name]=c;}});
    const ordered=lcColumnOrder.map(function(f,i){
      const c=$.extend(true,{},byField[f]||{dataField:f});
      c.dataField=c.dataField||f;
      c.visible=true;
      c.visibleIndex=i;
      return c;
    });
    grid.option("columns",ordered);
  }catch(e){console.warn("lcApplyColumnOrder error",e);}
}
function updateGridHeight(){try{if(grid){var top=$("#GridLabourContractHistory").offset()?.top||0;var h=Math.max(260, window.innerHeight-top-44);grid.option("height",h);grid.updateDimensions();}}catch(e){console.warn("updateGridHeight error",e);}}
if (grid && window.DevExpress && DevExpress.data && DevExpress.data.CustomStore) {
  grid.option("remoteOperations", false);
  grid.option("paging.enabled", false);
  grid.option("pager.visible", false);
  grid.option("scrolling.mode", "virtual");
  grid.option("scrolling.rowRenderingMode", "virtual");
  grid.option("dataSource", new DevExpress.data.CustomStore({
    key: "ContractID",
    load: function() {
      const d = $.Deferred();
      AjaxHPAParadise({
        data: { name: "sp_LabourContractHistory", param: ["LoginID", window.UserID || 3, "EmployeeID", "-1", "LanguageID", window.LanguageID || "VN"] },
        success: function(res) {
          const json = typeof res === "string" ? JSON.parse(res) : res;
          const rows = lcNormalizeGridRows(Array.isArray(json?.data?.[0]) ? json.data[0] : []);
          d.resolve(rows, { totalCount: rows.length });
        },
        error: function() { d.resolve([], { totalCount: 0 }); }
      });
      return d.promise();
    }
  }));
  lcApplyColumnOrder();
  updateGridHeight();
  grid.refresh();
}
setTimeout(updateGridHeight,100);setTimeout(updateGridHeight,500);$(window).off("resize.gridLabourContractHistory").on("resize.gridLabourContractHistory",updateGridHeight);
const refreshGrid=function(){if(grid&&typeof grid.refresh==="function"){updateGridHeight();grid.refresh();}};
function lcOpenContractForm(row, mode){
  const title = mode === "edit"
    ? (window.LanguageID === "EN" ? "Labour contract detail" : "Chi tiết hợp đồng lao động")
    : (window.LanguageID === "EN" ? "Add labour contract" : "Thêm hợp đồng lao động");
  AjaxHPAParadise({
    data:{name:"sp_LabourContract_Add",param:["LoginID",window.UserID||window.LoginID||3,"LanguageID",window.LanguageID||"VN"]},
    success:function(res){
      const json=typeof res==="string"?JSON.parse(res):res;
      const html=(json&&json.data&&json.data[0]&&json.data[0][0]&&(json.data[0][0].html||json.data[0][0].HTML||json.data[0][0].Column1))||"";
      if(!html){lcAlert("error", window.LanguageID === "EN" ? "Cannot load contract form." : "Không tải được form hợp đồng.");return;}
      const openWithObj=function(detailObj){
        window.__lcEditObj = detailObj || {};
        window.currentRecordID_ContractID = detailObj && detailObj.ContractID ? detailObj.ContractID : null;
        const $host=$("<div id=\"popupLabourContractAddHost\"></div>").appendTo("body");
        $host.dxPopup({
          title:title,
          width:720,
          maxWidth:"96vw",
          height:"auto",
          maxHeight:"92vh",
          showCloseButton:true,
          dragEnabled:true,
          resizeEnabled:true,
          contentTemplate:function(){return $("<div></div>").html(html);},
          onShown:function(){
            if(mode==="edit"&&detailObj&&detailObj.ContractID){
              $("#sp_LabourContract_Add_html").removeClass("contract-add-mode").addClass("contract-edit-mode");
            }
          },
          onHidden:function(){window.__lcEditObj={};setTimeout(function(){$host.remove();},0);}
        }).dxPopup("instance").show();
      };
      if(mode==="edit"&&row&&row.ContractID){
        lcCallSp("sp_LabourContract_Add_GetDetail",["LoginID",window.UserID||window.LoginID||3,"ContractID",row.ContractID])
          .then(function(detailJson){
            const detail=(detailJson&&detailJson.data&&detailJson.data[0]&&detailJson.data[0][0])||row;
            openWithObj(detail);
          })
          .catch(function(){openWithObj(row);});
      } else {
        openWithObj({});
      }
    },
    error:function(){lcAlert("error","Không tải được form hợp đồng.");}
  });
}
if(grid&&grid.option){
  grid.option("selection.mode","single");
  grid.option("focusedRowEnabled",true);
  grid.option("onRowClick",function(e){
    if(e&&e.data){
      lcSetSelectedRow(e.data);
      if(grid.selectRows) grid.selectRows([e.data.ContractID],false);
    }
  });
  grid.option("onRowDblClick",function(e){
    if(e&&e.data){
      lcSetSelectedRow(e.data);
      lcOpenContractForm(e.data,"edit");
    }
  });
}
const $gridRoot = $("#GridLabourContractHistory");
if ($gridRoot.length && !$gridRoot.find(".lc-toolbar-actions").length) {
  const $toolbarBefore = $gridRoot.find(".dx-datagrid-header-panel .dx-toolbar-before");
  const $toolbar = $gridRoot.find(".dx-datagrid-header-panel .dx-toolbar-after");
  const $chooser = $toolbar.find(".dx-datagrid-column-chooser-button").first();
  const $refresh = $("<div class=\"dx-item dx-toolbar-item dx-toolbar-button lc-grid-refresh-icon\"><div class=\"dx-item-content dx-toolbar-item-content\"><div role=\"button\" aria-label=\"Làm mới\" class=\"dx-widget dx-button dx-button-mode-text dx-button-normal dx-button-has-icon\"><div class=\"dx-button-content\"><i class=\"dx-icon dx-icon-refresh\"></i></div></div></div></div>");
  $refresh.on("click", refreshGrid);
  const $actionHost = $chooser.length ? $chooser.closest(".dx-toolbar-item") : null;
  const $actions = $(`
    <div class="dx-item dx-toolbar-item dx-toolbar-button lc-toolbar-actions">
      <div class="dx-item-content dx-toolbar-item-content">
        <button type="button" id="btnLcPrint" class="lc-toolbar-action lc-toolbar-print" title="${window.LanguageID === "EN" ? "Print labour contract" : "In hợp đồng lao động"}">${window.LanguageID === "EN" ? "Print labour contract" : "In hợp đồng lao động"}</button>
        <button type="button" id="btnLcSign" class="lc-toolbar-action lc-toolbar-sign" title="${window.LanguageID === "EN" ? "Sign via VNeID" : "Ký trên VNeID"}">${window.LanguageID === "EN" ? "Sign via VNeID" : "Ký trên VNeID"}</button>
        <button type="button" id="btnLcCancelSign" class="lc-toolbar-action lc-toolbar-cancel" title="${window.LanguageID === "EN" ? "Cancel signing" : "Hủy ký"}">${window.LanguageID === "EN" ? "Cancel signing" : "Hủy ký"}</button>
      </div>
    </div>`);
  const $addBtn = $(`
    <div class="dx-item dx-toolbar-item dx-toolbar-button lc-add-toolbar-item">
      <div class="dx-item-content dx-toolbar-item-content">
        <div role="button" id="btnLcAdd" class="dx-widget dx-button dx-button-mode-text dx-button-normal dx-button-has-icon" title="${window.LanguageID === "EN" ? "Add new" : "Thêm mới"}" aria-label="${window.LanguageID === "EN" ? "Add new" : "Thêm mới"}">
          <div class="dx-button-content">
            <i class="dx-icon dx-icon-add"></i>
          </div>
        </div>
      </div>
    </div>`);
  if ($toolbarBefore.length) $toolbarBefore.append($actions); else $gridRoot.find(".dx-datagrid-header-panel .dx-toolbar").prepend($actions);
  if (!$gridRoot.find(".lc-grid-refresh-icon").length) {
    if ($actionHost && $actionHost.length) {
      $addBtn.insertBefore($actionHost);
      $refresh.insertAfter($addBtn);
    } else {
      $toolbar.prepend($refresh);
      $toolbar.prepend($addBtn);
    }
  }
}

function lcSelectedRow(){
  if(selectedLabourContractHistoryRow&&selectedLabourContractHistoryRow.ContractID) return selectedLabourContractHistoryRow;
  if(!grid) return null;
  const rows=grid.getSelectedRowsData&&grid.getSelectedRowsData();
  if(rows&&rows.length){lcSetSelectedRow(rows[0]);return rows[0];}
  const visible=grid.getVisibleRows&&grid.getVisibleRows();
  const idx=grid.option&&grid.option("focusedRowIndex");
  if(visible&&visible.length&&idx>=0&&visible[idx]){lcSetSelectedRow(visible[idx].data);return visible[idx].data;}
  return null;
}
function lcAlert(type,msg){if(window.uiManager&&uiManager.showAlert){uiManager.showAlert({type:type,message:msg});}else if(window.DevExpress&&DevExpress.ui){DevExpress.ui.notify(msg,type,2200);}else{alert(msg);}}
function lcCall(name,param,okMsg){
  AjaxHPAParadise({data:{name:name,param:param},success:function(){lcAlert("success",okMsg||"%lc_action_success%");refreshGrid();},error:function(){lcAlert("error","%lc_action_failed%");}});
}
function lcVal(v){return v==null?"":v;}
function lcDate(v){if(!v)return null;const d=new Date(v);if(isNaN(d))return v;return d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,"0")+"-"+String(d.getDate()).padStart(2,"0")+" 00:00:00";}
$("#btnLcSign").off("click.lc").on("click.lc",function(){
  const r=lcSelectedRow(); if(!r){lcAlert("warning","%lc_select_contract%");return;}
  const param=[
    "ContractID",r.ContractID,
    "EmployeeID","-1",
    "ContractNo",lcVal(r.ContractNo),
    "ContractCode",lcVal(r.ContractCode),
    "ContractStartDay",lcDate(r.ContractStartDay),
    "ContractEndDay",lcDate(r.ContractEndDay),
    "LBIssueDate",lcDate(r.LBIssueDate),
    "Duration",r.Duration||0,
    "CommitmentKind",lcVal(r.CommitmentKind)||"HDLD",
    "NextContractCode",lcVal(r.NextContractCode),
    "ContractTemplateName",lcVal(r.ContractTemplateName)||"LabourContractDefinite",
    "InsuranceStatusID",r.InsuranceStatusID??-1,
    "PITStatus",r.PITStatus??1,
    "SalaryHistoryID",r.SalaryHistoryID||0,
    "FullName",lcVal(r.FullName),
    "ContractCountType",lcVal(r.ContractCountType),
    "IsLock",r.IsLock?1:0
  ];
  console.log("[VNeID][Create] row",r);
  console.log("[VNeID][Create] exec sp_vContract_CreateContract",param);
  lcCall("sp_vContract_CreateContract",param,"%lc_vneid_sign_sent%");
});
$("#btnLcCancelSign").off("click.lc").on("click.lc",function(){
  const r=lcSelectedRow(); if(!r){lcAlert("warning","%lc_select_contract%");return;}
  const param=["ContractID",r.ContractID,"EmployeeID","-1","ContractNo",lcVal(r.ContractNo),"ContractCode",lcVal(r.ContractCode)];
  console.log("[VNeID][Cancel] row",r);
  console.log("[VNeID][Cancel] exec sp_vContract_CancelContract",param);
  lcCall("sp_vContract_CancelContract",param,"%lc_vneid_cancel_done%");
});
$("#btnLcStatus").off("click.lc").on("click.lc",function(){lcCall("sp_vContract_SyncStatusAndDownload",[],"%lc_status_updated%");});
$("#btnLcPrint").off("click.lc").on("click.lc",function(){
  const r=lcSelectedRow(); if(!r){lcAlert("warning","%lc_select_contract%");return;}
  AjaxHPAParadise({
    data:{name:"sp_printlaborcontractblock",param:["loginID",window.UserID||3,"MenuID","MnuHRS169","ContractID",r.ContractID]},
    success:async function(res){
      const json=typeof res==="string"?JSON.parse(res):res;
      const row=json?.data?.[0]?.[0]||{};
      const exportName=row.ExportName||row.exportName||"LabourContractDefinite";
      let fileName="";
      await AjaxHPAParadiseAsync({data:{name:"sp_getTaskExport",param:["@ExportName",exportName]},success:function(x){
        const j=typeof x==="string"?JSON.parse(x):x;
        fileName=j?.data?.[0]?.[0]?.TemplateFileName||"";
      }});
      console.log("Dữ liệu r.ContractID: ", r.ContractID)
      await AjaxHPAParadiseParadiseAsync({data:{name:"ExportLocationFolder",param:["",exportName,fileName,"@ContractID",r.ContractID]},success:async function(x){
        let out=typeof x==="string"?JSON.parse(x):x;
        out=typeof out?.data==="string"?JSON.parse(out.data):out.data;
        if(out?.FilePath){
          await AjaxHPAParadiseParadiseAsync({data:{name:"ReadPathFileToByte",param:[out.FilePath]},success:function(bytes){
            const b=typeof bytes==="string"?JSON.parse(bytes):bytes;
            saveAsFile(out.FileName||fileName,b.data);
          }});
        }
      }});
      lcAlert("success","%lc_export_done%");
    },
    error:function(){lcAlert("error","%lc_print_failed%");}
  });
});
var addEl=document.getElementById("btnLcAdd");if(addEl){
  $(addEl).off("mousedown.lc pointerdown.lc click.lc").on("mousedown.lc pointerdown.lc",function(e){e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();return false;}).on("click.lc",function(e){
    if(e){e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();}
    lcOpenContractForm(null,"add");
    return false;
  });
}
})();</script>';

    SELECT @html AS html;
        /*
EXEC sptblCommonControlType_Signed_DUC 'sp_LabourContractHistory_html'
EXEC sp_GenerateHTMLScript_new 'sp_LabourContractHistory_html'
*/
END;
GO

/*--------------------------------------------------------------------------------------------------
  [dbo].[LabourContract]
  TRẠNG THÁI GỐC: Thủ tục này CHƯA TỒN TẠI trên CSDL gốc [Vietinsoft_ForTest_Tai].
  GHI CHÚ: Thủ tục này được tạo mới trong quá trình sửa lỗi để làm thủ tục điều phối nạp cache.
--------------------------------------------------------------------------------------------------*/

