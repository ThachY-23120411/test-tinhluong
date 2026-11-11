const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/');
  await page.locator('#username').fill('ThanhLong');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForSelector('.dock, .navbar', { timeout: 20000 });

  // Open MnuWPT037
  const btn = page.locator('button.open-MnuWPT037, button.MnuWPT037, [onclick*="MnuWPT037"]').first();
  await btn.click();
  await page.waitForTimeout(3000);

  const cards = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.getcardregisteredOA, .card')).map(c => ({
      className: c.className,
      text: c.innerText.trim().slice(0, 100),
      dataVal: c.getAttribute('data-value'),
      dataGroup: c.getAttribute('data-group')
    }));
  });
  console.log('Cards in MnuWPT037 for ThanhLong:', cards);

  await browser.close();
})();
