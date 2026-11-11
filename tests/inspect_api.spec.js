const { test } = require('@playwright/test');

test('INSPECT EXACT REQUEST & RESPONSE', async ({ page }) => {
  page.on('request', req => {
    if (req.url().includes('paradise2') || req.url().includes('LoadDataDetail')) {
      console.log('>>> REQ URL:', req.url());
      console.log('>>> REQ POST DATA:', req.postData());
    }
  });

  page.on('response', async resp => {
    if (resp.url().includes('paradise2') || resp.url().includes('LoadDataDetail')) {
      console.log('<<< RESP STATUS:', resp.status());
      try {
        console.log('<<< RESP BODY:', await resp.text());
      } catch(e) {}
    }
  });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('Tai.Dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });

  // Test calling the exact API from page
  const res = await page.evaluate(async () => {
    return new Promise(resolve => {
      AjaxHPAParadise({
        data: {
          name: "sp_StaffInformation_PopupInfoBank_LoadDataDetail",
          param: [
            "LoginID", window.UserID,
            "LanguageID", "VN",
            "EmployeeID", "046"
          ]
        },
        success: function(data) {
          resolve({ success: true, data });
        },
        error: function(err) {
          resolve({ success: false, err });
        }
      });
    });
  });

  console.log('RESULT OF DIRECT CALL:', res);
});
