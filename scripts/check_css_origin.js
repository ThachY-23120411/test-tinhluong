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

  const cssOrigin = await page.evaluate(() => {
    const table = window.$('#hist_grid .dx-datagrid-rowsview table')[0];
    const rules = [];
    for (const sheet of document.styleSheets) {
      try {
        for (const rule of sheet.cssRules) {
          if (rule.selectorText && table.matches(rule.selectorText)) {
            if (rule.style.tableLayout) {
              rules.push({ selector: rule.selectorText, tableLayout: rule.style.tableLayout, href: sheet.href });
            }
          }
        }
      } catch (e) {}
    }
    return rules;
  });

  console.log('CSS ORIGIN FOR TABLE-LAYOUT:\n', JSON.stringify(cssOrigin, null, 2));
  await browser.close();
})();
