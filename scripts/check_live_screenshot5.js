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

  // Click menu MnuSCR612 (Tạo mật khẩu)
  await page.evaluate(() => {
    const el = document.querySelector('.icon.MnuSCR612, [class*="MnuSCR612"], a[href*="MnuSCR612"]');
    if (el) el.click();
    else if (typeof window.openMenu === 'function') window.openMenu('MnuSCR612');
  });
  await page.waitForTimeout(4000);

  await page.screenshot({ path: 'scripts/live_screenshot5_check.png' });
  console.log('Saved scripts/live_screenshot5_check.png');
  await browser.close();
})();
