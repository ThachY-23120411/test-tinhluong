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

  const colgroups = await page.evaluate(() => {
    const headerCols = [];
    window.$('#hist_grid .dx-datagrid-headers colgroup col').each(function() {
      headerCols.push({ widthAttr: window.$(this).attr('width'), styleWidth: this.style.width });
    });

    const rowsCols = [];
    window.$('#hist_grid .dx-datagrid-rowsview colgroup col').each(function() {
      rowsCols.push({ widthAttr: window.$(this).attr('width'), styleWidth: this.style.width });
    });

    const headerTable = {
      style: window.$('#hist_grid .dx-datagrid-headers table').attr('style'),
      class: window.$('#hist_grid .dx-datagrid-headers table').attr('class'),
      width: window.$('#hist_grid .dx-datagrid-headers table').width()
    };
    const rowsTable = {
      style: window.$('#hist_grid .dx-datagrid-rowsview table').attr('style'),
      class: window.$('#hist_grid .dx-datagrid-rowsview table').attr('class'),
      width: window.$('#hist_grid .dx-datagrid-rowsview table').width()
    };

    return { headerCols, rowsCols, headerTable, rowsTable };
  });

  console.log('COLGROUPS:\n', JSON.stringify(colgroups, null, 2));
  await browser.close();
})();
