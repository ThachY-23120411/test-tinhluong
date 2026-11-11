const { test, expect } = require('@playwright/test');

test('DEBUG LIVE UI', async ({ page }) => {
  // Listen to console
  page.on('console', msg => {
    console.log(`[CONSOLE ${msg.type().toUpperCase()}]`, msg.text());
  });

  // Listen to paradise2 network responses
  page.on('response', async resp => {
    if (resp.url().includes('paradise2')) {
      try {
        const text = await resp.text();
        console.log(`[API RESPONSE ${resp.status()}]`, text.substring(0, 300));
      } catch(e) {}
    }
  });

  console.log('🌐 Opening site...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);

  // Login
  console.log('🔑 Logging in as Tai.Dang...');
  await page.locator('#username').fill('Tai.Dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(2000);

  // Open Quản trị nhân sự -> Hồ sơ nhân viên
  console.log('📂 Opening Quản trị nhân sự...');
  const hrsIcon = page.locator('.dock .icon.MnuHRS000, .dock .open-MnuHRS000, .dock .icon.MnuHRS002, .dock .open-MnuHRS002').first();
  await hrsIcon.click();
  await page.waitForTimeout(1500);

  console.log('👤 Opening Hồ sơ nhân viên...');
  const hosoItem = page.locator('#sidebar, .sidebar, #menu, body').locator('text="Hồ sơ nhân viên"').first();
  await hosoItem.click();
  await page.waitForTimeout(4000);

  // Evaluate browser state
  console.log('🔍 Checking browser window state...');
  const state = await page.evaluate(async () => {
    return {
      Employee: window.Employee,
      UserID: window.UserID,
      LoginID: window.LoginID,
      LanguageID: window.LanguageID,
      paradiseparadise: window.paradiseparadise,
      OriginalStaffData: window.OriginalStaffData
    };
  });
  console.log('Window State:', JSON.stringify(state, null, 2));

  // Test calling sp_StaffInformation_PopupInfoBank_LoadDataDetail directly via AjaxHPAParadise inside page
  console.log('🧪 Testing AjaxHPAParadise call inside browser...');
  const apiTestResult = await page.evaluate(() => {
    return new Promise((resolve) => {
      if (typeof AjaxHPAParadise !== 'function') {
        resolve({ error: 'AjaxHPAParadise is not a function' });
        return;
      }
      AjaxHPAParadise({
        data: {
          name: "sp_StaffInformation_PopupInfoBank_LoadDataDetail",
          param: [
            "LoginID", window.UserID || 62,
            "LanguageID", "VN",
            "EmployeeID", "046"
          ]
        },
        success: function(res) {
          resolve({ success: true, res: res });
        },
        error: function(err) {
          resolve({ success: false, err: err ? err.toString() : 'Unknown error' });
        }
      });
    });
  });
  console.log('Direct API Test Result (EmployeeID=046):', JSON.stringify(apiTestResult, null, 2));

  // Also test with window.Employee
  const apiTestWithVar = await page.evaluate(() => {
    return new Promise((resolve) => {
      AjaxHPAParadise({
        data: {
          name: "sp_StaffInformation_PopupInfoBank_LoadDataDetail",
          param: [
            "LoginID", window.UserID || 62,
            "LanguageID", "VN",
            "EmployeeID", window.Employee
          ]
        },
        success: function(res) {
          resolve({ success: true, res: res });
        },
        error: function(err) {
          resolve({ success: false, err: err ? err.toString() : 'Unknown error' });
        }
      });
    });
  });
  console.log('API Test with window.Employee:', JSON.stringify(apiTestWithVar, null, 2));

  // Click edit button
  console.log('💳 Clicking edit button...');
  const editBtns = page.locator('button.sec-edit-btn');
  const count = await editBtns.count();
  console.log('Edit buttons count:', count);
  for (let i = 0; i < count; i++) {
    const text = await editBtns.nth(i).evaluate(el => el.closest('.section, .card, div, tr')?.innerText || '');
    if (text.includes('Thông tin Ngân hàng')) {
      console.log(`Clicking edit button #${i}...`);
      await editBtns.nth(i).click();
      break;
    }
  }

  await page.waitForTimeout(2500);

  // Read inputs inside popup
  const popup = page.locator('.dx-overlay-content').filter({ hasText: 'Thông tin ngân hàng' });
  const isPopupVisible = await popup.isVisible();
  console.log('Is popup visible:', isPopupVisible);
  if (isPopupVisible) {
    const inputs = popup.locator('input.dx-texteditor-input');
    const inputCount = await inputs.count();
    console.log('Inputs count:', inputCount);
    for (let i = 0; i < inputCount; i++) {
      const val = await inputs.nth(i).inputValue();
      console.log(`Input #${i} value: "${val}"`);
    }
  }

  await page.screenshot({ path: 'test-evidence/debug_result.png', fullPage: true });
  console.log('📸 Screenshot saved to test-evidence/debug_result.png');
});
