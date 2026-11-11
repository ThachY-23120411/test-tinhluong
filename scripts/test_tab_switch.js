const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: false, slowMo: 100 });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(3000);

  const btnWPT = page.locator('button.open-MnuWPT000, button.MnuWPT000').first();
  console.log('Is button.open-MnuWPT000 visible?', await btnWPT.isVisible());

  if (await btnWPT.isVisible()) {
    await btnWPT.click();
    await page.waitForTimeout(2000);
    const item = page.locator('a[onclick*="MnuWPT316"], a:has-text("Xin tăng ca"):visible').first();
    console.log('Is Xin tang ca visible in sidebar?', await item.isVisible());
    if (await item.isVisible()) {
      await item.click();
      await page.waitForTimeout(2000);
      console.log('Clicked! Is content-MnuWPT316 visible?', await page.locator('#content-MnuWPT316, #sp_Overtime_Assignment').isVisible());
    }
  }

  await browser.close();
})();
