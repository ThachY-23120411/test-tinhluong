const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  await dockBtn.click();
  await page.waitForTimeout(2500);

  // Click card
  const card = page.locator('.getcardregisteredOA').first();
  if (await card.isVisible()) {
    await card.click();
    await page.waitForTimeout(2500);

    // List all tabs
    const tabs = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('.nav-tabs li, .nav-tabs button, .nav-tabs a')).map(t => ({
        id: t.id,
        text: t.innerText.trim(),
        className: t.className
      }));
    });
    console.log('Tabs:', tabs);
  }

  await browser.close();
})();
