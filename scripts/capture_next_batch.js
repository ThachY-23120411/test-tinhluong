const { chromium } = require('playwright');
const fs = require('fs');

async function captureNextBatch() {
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
    // Ensure launchpad open
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

  // 1. MnuKPI006 (Các cuộc họp CRM) -> Screenshot 15
  await openFromLaunchpad('.open-MnuKPI006', 'scripts/shot_sc15_fixed.png');

  // 2. MnuKPI010 (Các email theo dõi KPI) -> Screenshot 14
  await openFromLaunchpad('.open-MnuKPI010', 'scripts/shot_sc14_fixed.png');

  // 3. MnuSCR612 (Tạo mật khẩu) -> Screenshot 5
  await openFromLaunchpad('.open-MnuSCR612', 'scripts/shot_sc5_fixed.png');

  // 4. Find CRM / Company
  const crmApps = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.child-launchpad')).map(el => ({
      class: el.className,
      text: el.innerText.trim(),
      keywords: el.getAttribute('data-keywords') || ''
    })).filter(x => x.keywords.includes('Công ty') || x.keywords.includes('CRM') || x.keywords.includes('Tổng quan'));
  });
  console.log('CRM apps in launchpad:', crmApps);

  await browser.close();
}

captureNextBatch().catch(console.error);
