const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function captureTabs() {
  console.log('Launching browser...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('Navigating to portal...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  if (await page.locator('#username').isVisible()) {
    console.log('Logging in...');
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  console.log('Opening MnuHRS151...');
  await page.evaluate(() => window.openMenu('MnuHRS151'));
  await page.waitForTimeout(3000);
  await page.locator('text="Quản lý hợp đồng lao động"').first().click();
  await page.waitForTimeout(4000);

  // Tab 2: Danh sách tới hạn ký hợp đồng
  console.log('Clicking Danh sách tới hạn ký hợp đồng...');
  await page.locator('text="Danh sách tới hạn ký hợp đồng"').first().click();
  await page.waitForTimeout(4000);

  const shot8Path = path.resolve('fix-bug/screenshot-8/screenshots/8_fixed.png');
  await page.screenshot({ path: shot8Path });
  console.log('Captured 8_fixed.png successfully at', shot8Path);

  // Tab 3: Danh sách ký phụ lục hợp đồng
  console.log('Clicking Danh sách ký phụ lục hợp đồng...');
  await page.locator('text="Danh sách ký phụ lục hợp đồng"').first().click();
  await page.waitForTimeout(4000);

  const shot9Path = path.resolve('fix-bug/screenshot-8/screenshots/9_fixed.png');
  await page.screenshot({ path: shot9Path });
  console.log('Captured 9_fixed.png successfully at', shot9Path);

  await browser.close();
  console.log('Finished capturing both tabs!');
}

captureTabs().catch(console.error);
