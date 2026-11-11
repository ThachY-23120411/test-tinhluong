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

  const debugInfo = await page.evaluate(() => {
    const headers = [];
    window.$('#hist_grid .dx-datagrid-headers .dx-header-row > td').each(function(i) {
      const rect = this.getBoundingClientRect();
      const textDiv = window.$(this).find('.dx-datagrid-text-content')[0];
      const textRect = textDiv ? textDiv.getBoundingClientRect() : null;
      headers.push({
        index: i,
        text: window.$(this).text().trim(),
        cellLeft: rect.left,
        cellRight: rect.right,
        cellWidth: rect.width,
        textLeft: textRect ? textRect.left : null,
        textWidth: textRect ? textRect.width : null,
        textAlign: window.$(this).css('text-align'),
        html: window.$(this).html()
      });
    });

    const firstRow = [];
    window.$('#hist_grid .dx-datagrid-rowsview .dx-data-row:first > td').each(function(i) {
      const rect = this.getBoundingClientRect();
      const child = this.firstElementChild;
      const childRect = child ? child.getBoundingClientRect() : null;
      firstRow.push({
        index: i,
        text: window.$(this).text().trim(),
        cellLeft: rect.left,
        cellRight: rect.right,
        cellWidth: rect.width,
        childTag: child ? child.tagName : null,
        childClass: child ? child.className : null,
        childLeft: childRect ? childRect.left : null,
        childWidth: childRect ? childRect.width : null,
        textAlign: window.$(this).css('text-align'),
        classes: window.$(this).attr('class'),
        html: window.$(this).html()
      });
    });

    return { headers, firstRow };
  });

  console.log('DEBUG INFO:\n', JSON.stringify(debugInfo, null, 2));
  await browser.close();
})();
