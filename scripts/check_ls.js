const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const context = await browser.newContext();
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
    const el = document.querySelector('.icon.MnuPRL451, [class*="MnuPRL451"]');
    if (el) el.click();
    else if (typeof window.openMenu === 'function') window.openMenu('MnuPRL451');
  });
  await page.waitForTimeout(3000);
  const link = await page.evaluate(() => localStorage.getItem('Tai3_link_sp_gift_history_gift'));
  console.log('Tai3_link_sp_gift_history_gift value:\n', link);

  // Also print all keys
  const allKeys = await page.evaluate(() => Object.keys(localStorage));
  console.log('All localStorage keys:\n', allKeys);

  await browser.close();
})();
