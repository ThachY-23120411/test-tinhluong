
function extractIdsAndHrefs() {
				// Get all <li> elements inside the <ul> with id "tabList"
				const tabList = document.querySelectorAll('#tabList > li');
				const extractedArray = [];

				tabList.forEach(li => {
					// Extract the id of the <li> if present and remove 'tab-' prefix
					if (li.id) {
						const cleanedId = li.id.replace('tab-', '');
						extractedArray.push(cleanedId);
					}

					// If the <li> has the class "dropdown", extract all href values from <a> tags within it
					if (li.classList.contains('dropdown')) {
						const links = li.querySelectorAll('a');
						links.forEach(link => {
							  const hrefValue = link.getAttribute('href');
								// Only add the href if it is not just "#" or an empty string
								if (hrefValue && hrefValue !== "#") {
									const cleanedHref = hrefValue.replace('#tab-', '');
									extractedArray.push(cleanedHref);
								}
						});
					}
				});

				return extractedArray;
			}

			function CloseAllTab() {
			  if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
			  showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab?</p>`)
				  .then((result) => {
					
			      	const listDelete = extractIdsAndHrefs();
					listDelete.forEach(item =>{
						//document.querySelector(`#point-${item}`).style.display = 'none';
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
				 if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
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
				 if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
				 showConfirmDeleteModal(`<p class=fs-6>Xác nhận đóng tất cả các tab bên trái?</p>`)
				  .then((result) => {
					const listDelete = getLeftElements(extractIdsAndHrefs(),currentSelectedMenu);
			      	CloseTab(listDelete);
				  })
				  .catch((error) => {
					
				  });
			
			}

			function CloseAllTabOnRight(){
				 if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
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
				   if (typeof hideMenuContextTab === 'function') { hideMenuContextTab(); }
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
                    if(typeof tabHistory !== 'undefined') {
                        tabHistory = tabHistory.filter(id => id !== `dynamic-tab-${item}`);
                    }
				});
				updateTabs();
                // Kiểm tra lịch sử để mở lại tab gần nhất
                if (typeof tabHistory !== 'undefined' && tabHistory.length > 0) {
                    const lastActiveTabId = tabHistory[tabHistory.length - 1];
                    const lastTabEl = document.getElementById(lastActiveTabId);
                    if (lastTabEl) {
                        const lastTab = new bootstrap.Tab(lastTabEl);
                        lastTab.show();
                        return;
                    }
                }
				// Fallback: Activate the first available tab nếu lịch sử bị trống
				const firstTabEl = document.querySelector('#tabList button.nav-link');
				if (firstTabEl) {
					const firstTab = new bootstrap.Tab(firstTabEl);
					firstTab.show();
				} else {
					// No tabs left, clear content
					$('#tabContent').empty();
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
				const tabTarget = tabElement.getAttribute('data-bs-target');
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
				smallCircle.style.display = 'none';
			}
			//document.querySelector(`#point-${menuId}`).style.display = 'none';
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
      document.getElementById('loading-overlay').style.display = 'flex';

    }

    function hideLoadingOverlayIn() {
      document.getElementById('loading-overlay').style.display = 'none';
    } */

	//Thang
		function closepopup(IDNamePopup) {
			$(IDNamePopup).closest(".dx-overlay-content").find(".dx-icon-close").click();
		}
