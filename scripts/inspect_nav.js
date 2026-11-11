const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(4000);

  const dockApps = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.dock button, .navbar-nav button, #ID-navbar-home button')).map(b => ({
      cls: b.className,
      id: b.id,
      text: b.innerText,
      title: b.title
    }));
  });
  console.log('Dock apps:', JSON.stringify(dockApps));

  await browser.close();
})();
