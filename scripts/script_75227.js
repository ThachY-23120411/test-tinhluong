
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
        .closest('.dx-overlay-content');

    // Title bar background & color
    $overlayContent
        .find('.dx-popup-title')
        .addClass('bg-success')
        .css('color', 'white');

    // Close button: đổi màu trắng + bỏ hover effect
    $overlayContent
        .find('.dx-closebutton')
        .css('background', 'transparent')
        .on('mouseenter mouseleave', function(e) {
            e.stopImmediatePropagation();
        });

    $overlayContent
        .find('.dx-closebutton .dx-icon')
        .css('color', 'white');
},
    contentTemplate: async function (contentElement) {
    let id = uuidv4();
    contentElement.attr("id", id);

    contentElement.css({
        'overflow'  : 'auto',
        'height'    : '100%'
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
      const $overlay = $(instance.content()).closest('.dx-overlay-content');
      const $closeBtn = $overlay.find('.dx-closebutton');

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
                        let trimmedOld = responseOld.trim();
                        if (trimmedOld.startsWith("{") && trimmedOld.endsWith("}")) {
                            try {
                                let parsedOld = JSON.parse(trimmedOld);
                                if (parsedOld && parsedOld.data && parsedOld.data[0] && parsedOld.data[0][0] && parsedOld.data[0][0].bytes) {
                                    cachedHtml = parsedOld.data[0][0].bytes;
                                }
                            } catch(e) {}
                        } else {
                            cachedHtml = responseOld;
                        }
                    } else if (responseOld && responseOld.data && responseOld.data[0] && responseOld.data[0][0] && responseOld.data[0][0].bytes) {
                        cachedHtml = responseOld.data[0][0].bytes;
                    }
                    if (cachedHtml) {
                        resolvedFromCache = true;
                        resolve(cachedHtml);
                    } else {
                        try { localStorage.removeItem(cacheKeyLink); } catch(e) {}
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
                                let trimmedNew = response.trim();
                                if (trimmedNew.startsWith("{") && trimmedNew.endsWith("}")) {
                                    try {
                                        let parsedNew = JSON.parse(trimmedNew);
                                        if (parsedNew && parsedNew.data && parsedNew.data[0] && parsedNew.data[0][0] && parsedNew.data[0][0].bytes) {
                                            newHtmlContent = parsedNew.data[0][0].bytes;
                                        }
                                    } catch(e) {}
                                } else {
                                    newHtmlContent = response;
                                }
                            } else if (response && response.data && response.data[0] && response.data[0][0] && response.data[0][0].bytes) {
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
                            } else {
                                try { localStorage.removeItem(cacheKeyLink); } catch(e) {}
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

