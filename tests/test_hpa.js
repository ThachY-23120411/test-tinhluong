const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome' });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('Tai.Dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  
  const hpaInfo = await page.evaluate(async () => {
    return {
      hpaKeys: window.HPA ? Object.keys(window.HPA) : null,
      clientKeys: window.HPA?.HPAClient ? Object.keys(window.HPA.HPAClient) : null,
      clientProto: window.HPA?.HPAClient ? Object.getOwnPropertyNames(Object.getPrototypeOf(window.HPA.HPAClient)) : null,
      AjaxHPAParadiseAsyncStr: window.HPA?.HPAClient?.AjaxHPAParadiseAsync?.toString()
    };
  });
  console.log('HPA info:', JSON.stringify(hpaInfo, null, 2));
  await browser.close();
})();
