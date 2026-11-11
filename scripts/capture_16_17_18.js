const { chromium } = require('playwright');

async function captureCRM16_17_18() {
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

  async function openFromLaunchpad(selector, outPath) {
    console.log(`Opening ${selector}...`);
    const isLaunchpadVisible = await page.locator('.child-launchpad').first().isVisible().catch(() => false);
    if (!isLaunchpadVisible) {
      await page.click('.open-lunchpad');
      await page.waitForTimeout(1000);
    }
    await page.evaluate((sel) => {
      const el = document.querySelector(sel);
      if (el) el.click();
    }, selector);
    await page.waitForTimeout(5000);
    await page.screenshot({ path: outPath });
    console.log(`Saved ${outPath}`);
  }

  // 1. MnuKPI012: Theo dõi dịch vụ (Screenshot 16)
  await openFromLaunchpad('.open-MnuKPI012', 'scripts/shot_sc16_fixed.png');

  // 2. MnuKPI002: Email gửi thủ công (Screenshot 17)
  await openFromLaunchpad('.open-MnuKPI002', 'scripts/shot_sc17_fixed.png');

  // 3. MnuKPI003: Dữ liệu khách hàng (Screenshot 18)
  await openFromLaunchpad('.open-MnuKPI003', 'scripts/shot_sc18_fixed.png');

  await browser.close();
  console.log('All 16, 17, 18 captured successfully!');
}

captureCRM16_17_18().catch(console.error);
