const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'LongKa');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  await dockBtn.click();
  await page.waitForTimeout(2500);

  const card = page.locator('.getcardregisteredOA').first();
  if (await card.isVisible()) {
    console.log('Card text:', await card.innerText());
    await card.click();
    await page.waitForTimeout(3000);

    const domInfo = await page.evaluate(() => {
      // Find all elements with id containing 'overtime' or 'sp_' or 'pane' or 'content'
      const els = Array.from(document.querySelectorAll('[id*="overtime" i], [id*="sp_" i], [id*="pane" i]'));
      return els.map(e => ({
        id: e.id,
        tagName: e.tagName,
        className: e.className,
        visible: e.offsetParent !== null,
        rect: e.getBoundingClientRect()
      }));
    });
    console.log('DOM elements with overtime/sp_/pane:', JSON.stringify(domInfo, null, 2));
  }

  await browser.close();
})();
