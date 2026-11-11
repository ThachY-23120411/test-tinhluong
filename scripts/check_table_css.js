const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.waitForTimeout(2000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }
  await page.evaluate(() => {
    localStorage.clear();
    location.reload();
  });
  await page.waitForTimeout(3000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }
  await page.evaluate(() => {
    const el = document.querySelector('.icon.MnuPRL451, [class*="MnuPRL451"]');
    if (el) el.click();
    else if (typeof window.openMenu === 'function') window.openMenu('MnuPRL451');
  });
  await page.waitForTimeout(4000);

  const cssInfo = await page.evaluate(() => {
    const rowsTable = window.$('#hist_grid .dx-datagrid-rowsview table')[0];
    const headerTable = window.$('#hist_grid .dx-datagrid-headers table')[0];
    const firstRow = window.$('#hist_grid .dx-datagrid-rowsview .dx-data-row:first')[0];

    return {
      headerTableLayout: window.getComputedStyle(headerTable).tableLayout,
      rowsTableLayout: window.getComputedStyle(rowsTable).tableLayout,
      firstRowDisplay: window.getComputedStyle(firstRow).display,
      rowTdDisplays: Array.from(firstRow.children).map(td => ({
        display: window.getComputedStyle(td).display,
        width: window.getComputedStyle(td).width,
        boxSizing: window.getComputedStyle(td).boxSizing
      }))
    };
  });

  console.log('CSS INFO:\n', JSON.stringify(cssInfo, null, 2));
  await browser.close();
})();
