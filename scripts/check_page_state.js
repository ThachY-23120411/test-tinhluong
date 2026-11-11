const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const context = await browser.newContext({
    storageState: path.resolve('.auth/storageState.json'),
    viewport: { width: 1440, height: 900 }
  });
  const page = await context.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);

  console.log('URL after networkidle:', page.url());
  const bodyHtml = await page.evaluate(() => document.body.innerText.substring(0, 500));
  console.log('Body text:', bodyHtml);

  await page.screenshot({ path: 'scripts/page_debug.png' });
  console.log('Saved page_debug.png');

  await browser.close();
  fs.unlinkSync(__filename);
})();
