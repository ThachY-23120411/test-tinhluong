const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('tai.dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(4000);

  // Lấy tất cả button trên .dock
  const dockButtons = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.dock button')).map((btn, idx) => {
      const cls = btn.className;
      const title = btn.getAttribute('title') || '';
      const icon = btn.querySelector('i') ? btn.querySelector('i').className : '';
      const onclick = btn.getAttribute('onclick') || '';
      return { index: idx, cls, title, icon, onclick };
    });
  });

  console.log('📌 DANH SÁCH BUTTON TRÊN THANH DOCK:');
  console.log(JSON.stringify(dockButtons, null, 2));

  await browser.close();
})();
