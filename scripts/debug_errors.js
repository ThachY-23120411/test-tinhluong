const { chromium } = require('playwright');

async function debugErrors() {
  const browser = await chromium.launch({
    headless: false,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  page.on('console', msg => {
    if (msg.type() === 'error') {
      console.log('🔴 CONSOLE ERROR:', msg.text(), msg.location());
    }
  });

  page.on('pageerror', err => {
    console.log('🔥 PAGE ERROR STACK:', err.stack);
  });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  // Open launchpad and click menu
  const launchpad = page.locator('.open-lunchpad, .bi-windows, [title*="Menu"]').first();
  await launchpad.click();
  await page.waitForTimeout(1000);
  const searchBox = page.locator('#searchMenu, input[placeholder*="Tìm"], input[type="search"]').first();
  await searchBox.fill('Trí Luật');
  await page.waitForTimeout(1000);
  await page.locator('text="Nhập lương Trí Luật"').first().click();

  await page.waitForTimeout(5000);
  await browser.close();
}

debugErrors().catch(console.error);
