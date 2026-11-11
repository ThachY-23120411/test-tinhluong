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

  const histCells = await page.evaluate(() => {
    const rows = [];
    window.$('#hist_grid .dx-datagrid-rowsview .dx-data-row').each(function(i) {
      if (i < 3) {
        const cells = [];
        window.$(this).find('> td').each(function() {
          cells.push({
            text: window.$(this).text().trim(),
            textAlign: window.$(this).css('text-align'),
            classes: window.$(this).attr('class'),
            html: window.$(this).html()
          });
        });
        rows.push(cells);
      }
    });
    return rows;
  });

  console.log('Hist Grid Rows (first 3):', JSON.stringify(histCells, null, 2));

  await page.screenshot({ path: 'scripts/hist_grid_actual.png' });
  await browser.close();
})();
