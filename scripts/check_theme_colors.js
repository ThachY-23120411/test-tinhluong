const { chromium } = require('playwright');

async function checkThemeColors() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuKPI005');
    if (el) el.click();
  });
  await page.waitForTimeout(4000);

  const colors = await page.evaluate(() => {
    const grid = document.querySelector('#GridContentPost');
    const comp = document.querySelector('#contentComponent');
    const body = document.body;
    const empInput = document.querySelector('#contentFilterEmployeeToolbar');
    const searchPanel = document.querySelector('.dx-datagrid-search-panel');
    const searchInput = document.querySelector('.dx-datagrid-search-panel input');
    const placeholder = document.querySelector('.dx-datagrid-search-panel .dx-placeholder');
    return {
      bodyBg: window.getComputedStyle(body).backgroundColor,
      compBg: comp ? window.getComputedStyle(comp).backgroundColor : null,
      gridBg: grid ? window.getComputedStyle(grid).backgroundColor : null,
      empBg: empInput ? window.getComputedStyle(empInput).backgroundColor : null,
      searchBg: searchPanel ? window.getComputedStyle(searchPanel).backgroundColor : null,
      searchBorder: searchPanel ? window.getComputedStyle(searchPanel).borderColor : null,
      searchColor: searchInput ? window.getComputedStyle(searchInput).color : null,
      placeholderColor: placeholder ? window.getComputedStyle(placeholder).color : null
    };
  });

  console.log('Theme Colors:', JSON.stringify(colors, null, 2));
  await browser.close();
}

checkThemeColors().catch(console.error);
