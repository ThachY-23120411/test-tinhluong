const { chromium } = require('playwright');

async function captureProfileAndOT() {
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

  // Open launchpad and click MnuPRL451 to get the Cổng thông tin nhân sự sidebar
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuPRL451');
    if (el) el.click();
  });
  await page.waitForTimeout(4000);

  // 1. Click "Hồ sơ cá nhân" -> Screenshot 3
  console.log('Clicking Hồ sơ cá nhân...');
  await page.locator('.sidebar >> text="Hồ sơ cá nhân"').first().click();
  await page.waitForTimeout(5000);
  await page.screenshot({ path: 'scripts/shot_sc3_ho_so_ca_nhan.png' });
  console.log('Saved scripts/shot_sc3_ho_so_ca_nhan.png');

  // 2. Click "Xin tăng ca" -> Screenshot 4
  console.log('Clicking Xin tăng ca...');
  await page.locator('.sidebar >> text="Xin tăng ca"').first().click();
  await page.waitForTimeout(5000);
  await page.screenshot({ path: 'scripts/shot_sc4_xin_tang_ca.png' });
  console.log('Saved scripts/shot_sc4_xin_tang_ca.png');

  await browser.close();
}

captureProfileAndOT().catch(console.error);
