const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);

  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  const res = await page.evaluate(() => {
    if (!window.dataMenuViewHtml) return 'No dataMenuViewHtml';
    return window.dataMenuViewHtml.filter(x => {
      const s = (x.ClassName + ' ' + x.MenuID + ' ' + x.MenuName).toLowerCase();
      return s.includes('labour') || s.includes('contract') || s.includes('hrs151') || s.includes('hợp đồng');
    });
  });

  console.log('Contract menus in dataMenuViewHtml:', res);
  await browser.close();
}

main().catch(e => console.error('Error:', e.message));
