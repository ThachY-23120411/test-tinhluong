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

  const dockButtons = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.dock button')).map(b => ({
      class: b.className,
      title: b.getAttribute('title') || b.getAttribute('data-original-title') || b.innerText.trim(),
      onclick: b.getAttribute('onclick')
    }));
  });
  console.log('Dock buttons for cuong.vu:', dockButtons);

  // Click MnuWPT037
  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  if (await dockBtn.isVisible()) {
    console.log('Clicking dock button...');
    await dockBtn.click();
  } else {
    console.log('No dock button found for MnuWPT037');
  }
  await page.waitForTimeout(4000);

  const cardCount = await page.locator('.getcardregisteredOA').count();
  console.log('Card count after dock click:', cardCount);

  const cardTexts = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.getcardregisteredOA')).map(c => ({
      val: c.getAttribute('data-value'),
      group: c.getAttribute('data-group'),
      text: c.innerText.replace(/\s+/g, ' ').trim()
    }));
  });
  console.log('Cards:', cardTexts);

  await browser.close();
})();
