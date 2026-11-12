
var tabHistory = window.tabHistory || [];
    // Lắng nghe sự kiện chuyển tab của bootstrap để lưu lại lịch sử
    $(document).on('shown.bs.tab', 'button[data-bs-toggle="tab"], a[data-bs-toggle="tab"]', function (e) {
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
    OpenFormContent(appToAdd.className || appToAdd.id);
    const existsInDock = appsDock.slice(0, secondHrElement).some(app => app.id === appToAdd.id);
    load_tab();

    if(existsInDock) {

    return;}
     const appIcon = document.querySelector(`.dock .${menu_id}`);
     if(!appIcon){ ChangePositionRecent(menu_id);  document.querySelector(`#point-${appToAdd.id}`).style.display = 'block';}
     else{

      const appsDockContainer2 = document.querySelector('.dock');
     if(appIcon !== appsDockContainer2.children[secondHrElement+2]){

     appsDockContainer2.insertBefore(appIcon, appsDockContainer2.children[secondHrElement+2]);
     appsDock = appsDock.filter(app => app.id !== appToAdd.id);
     appsDock.splice(secondHrElement,0,appToAdd);
     updateStyleDock();
     }
      //const DockOrder = appsDock.map(app => app.id);
      //const arrayString = '[`' + DockOrder.map(item => item).join('`, `') + '`]';
      //UpdateLayOutApi('DockOrder', arrayString);
      UpdateDockOrderApp();
    }

    }
    function getTabCount() {
     return $('#tabList .nav-item').length - 1;
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
     if (!$('#dynamic-tab-' + menuId).length && $('#dynamic-pane-' + menuId).length) {

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
        onclick="onTabClick('${menuId}')"
      >
         ${menuName}
        <span class="ms-1" onclick="removeTab('${menuId}','${menuName}')"><i class="bi bi-x-lg text-secondary"></i></span>
      </button>
       </li>
     `;
     $('#tabList').prepend(tabNavItem);
     addRightClickEventForTab(menuId,menuName);
      currentOverflowTab = currentOverflowTab.filter(item => item.id !== menuId);
      deleteListItemByHref(`#tab-${menuId}`);
      updateTabs();
     }

     if ($('#dynamic-tab-' + menuId).length) {
       // Tab exists, activate it
       const existingTabEl = document.getElementById(`dynamic-tab-${menuId}`);
       if (existingTabEl) {
         try {
           const existingTab = new bootstrap.Tab(existingTabEl);
           existingTab.show();
         } catch (e) {}
       }

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
        onclick="onTabClick('${menuId}')"
      >
       <div>
         ${menuName}
        <span class="ms-1" onclick="removeTab('${menuId}','${menuName}')"><i class="bi bi-x-lg text-secondary"></i></span>
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
     $('#tabList').prepend(tabNavItem);
     $('#tabContent').prepend(tabContentPane);

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
     $('a[data-bs-toggle="tab"]').on("shown.bs.tab", function (e) {
       const targetTabId = $(e.target).attr("href").substring(1);

       const savedScrollPos = tabScrollPositions[targetTabId] || 0;
       $(`#${targetTabId}`).scrollTop(savedScrollPos);

       $(`#backToTop-${targetTabId}`).hide();
     });
     addRightClickEventForTab(menuId,menuName);
     // Activate the new tab
     const newTabEl = document.getElementById(tabId);
     if (newTabEl) {
       try {
         const newTab = new bootstrap.Tab(newTabEl);
         newTab.show();
       } catch (e) {}
     }
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






        let afterContent = computedStyle ? computedStyle.content.replace(/['"]/g, "").trim() : "";
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
      newTabElement.addEventListener('contextmenu', function (event) {
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
                            let trimmed = response.trim();
                            if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
                                try {
                                    let parsed = JSON.parse(trimmed);
                                    if (parsed && parsed.data && parsed.data[0] && parsed.data[0][0] && parsed.data[0][0].bytes) {
                                        newHtmlContent = parsed.data[0][0].bytes;
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

                            let $target = $(`#${paneId}`);
                            if ($target.length) {
                                $target.html(newHtmlContent);
                                if (!isPopup) {
                                    if (typeof observeChildAddition === "function") observeChildAddition($target[0]);
                                    if (typeof validateRequiredFields === "function") validateRequiredFields(className);
                                }
                                setTimeout(() => { requestAnimationFrame(() => window.dispatchEvent(new Event("resize"))); }, 50);
                            }
                        } else {
                            try { localStorage.removeItem(cacheKeyLink); } catch(e) {}
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
      // $('#addTab').click(function() {
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
     if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
     const modalElement = document.getElementById('confirmDeleteModal');

     if(LanguageID === "VN"){
      $("#confirmDeleteModal .modal-title").text("Thông báo");
     }else if(LanguageID === "EN"){
      $("#confirmDeleteModal .modal-title").text("Notification");

     }
     const modal = new bootstrap.Modal(modalElement);

     modalElement.querySelector('.modal-body').innerHTML = itemName;

     updateModalButtonText(modalElement,'.modal-footer #confirmDeleteButton span', textConfirm, 'Đóng');
     updateModalButtonText(modalElement,'.modal-footer #cancelButton span', textReject, 'Ở lại');

     const handleResult = (isConfirmed) => {
       modal.hide();
       var test = document.getElementById("addEmployeeModal");

       isConfirmed ? resolve("User confirmed deletion.") : reject("User canceled the action.");
     };

     modalElement.querySelector('#confirmDeleteButton').addEventListener('click', () => handleResult(true), { once: true });
     modalElement.querySelectorAll('[data-bs-dismiss="modal"]').forEach(button =>
       button.addEventListener('click', () => handleResult(false), { once: true })
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
