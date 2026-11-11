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

  const testDecrypt = await page.evaluate(async () => {
    // Test encrypting and calling
    const client = window.HPA.HPAClient;
    const testReq = JSON.stringify({
      data: {
        name: "sp_StaffInformation_PopupInfoBank_LoadDataDetail",
        param: ["LoginID", 62, "LanguageID", "VN", "EmployeeID", "046"]
      }
    });

    const encrypted = await client.EncryptionStringEncryptionCore2(null, null, testReq);
    
    // Send fetch to /Tai3/hpa/paradise2
    const resp = await fetch('https://paradisehrm.com/Tai3/hpa/paradise2', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: encrypted, paradiseType: "2" })
    });
    const respJson = await resp.json();
    return {
      testReq,
      encryptedLength: encrypted.length,
      respJson
    };
  });

  console.log('Test Direct Encrypted Fetch:', JSON.stringify(testDecrypt, null, 2));
  await browser.close();
})();
