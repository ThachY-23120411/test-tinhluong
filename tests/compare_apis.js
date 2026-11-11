const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome' });
  const page = await browser.newPage();
  
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('Tai.Dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(2000);

  const results = await page.evaluate(async () => {
    function callApi(name, param) {
      return new Promise(resolve => {
        AjaxHPAParadise({
          data: { name, param },
          success: res => resolve({ success: true, res }),
          error: err => resolve({ success: false, err })
        });
      });
    }

    const uid = window.UserID || 62;
    const r1 = await callApi("sp_StaffInformation_CheckPermissionsWithLoginID", ["LoginID", uid]);
    const r2 = await callApi("sp_GetEmployeeLogin", ["LoginID", uid]);
    const r3 = await callApi("sp_StaffInformation_LoadDataDetail", ["LoginID", uid, "LanguageID", "VN", "EmployeeID", "046"]);
    const r4 = await callApi("sp_StaffInformation_PopupInfoBank_LoadDataDetail", ["LoginID", uid, "LanguageID", "VN", "EmployeeID", "046"]);
    const r5 = await callApi("sp_StaffInformation_PopupInfoBank_LoadDataDetail", ["EmployeeID", "046"]);

    return { r1, r2, r3, r4, r5 };
  });

  console.log('API Comparison Results:');
  console.log(JSON.stringify(results, null, 2));
  await browser.close();
})();
