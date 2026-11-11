const { chromium } = require('playwright');

async function captureCompanyAndCRM() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  // 1. Open launchpad and click MnuKPI449 (Danh sách công ty CRM) -> Screenshot 6
  console.log('Opening MnuKPI449...');
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuKPI449');
    if (el) el.click();
  });
  await page.waitForTimeout(5000);
  await page.screenshot({ path: 'scripts/shot_sc6_fixed.png' });
  console.log('Saved scripts/shot_sc6_fixed.png');

  // 2. Open launchpad and click MnuKPI001 (Tổng quan CRM) -> Screenshot 3 & 4
  console.log('Opening MnuKPI001...');
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuKPI001');
    if (el) el.click();
  });
  await page.waitForTimeout(5000);
  await page.screenshot({ path: 'scripts/shot_sc3_sc4_fixed.png' });
  console.log('Saved scripts/shot_sc3_sc4_fixed.png');

  await browser.close();
  console.log('Done company & CRM captures.');
}

captureCompanyAndCRM().catch(console.error);
