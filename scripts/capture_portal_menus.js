const { chromium } = require('playwright');
const fs = require('fs');

async function captureSidebarMenus() {
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

  // 1. Screenshot 1 & 23: Lịch sử đổi quà
  await page.screenshot({ path: 'scripts/shot_sc1_sc23_fixed.png' });
  console.log('Saved shot_sc1_sc23_fixed.png');

  async function clickSidebar(text, outPath) {
    console.log(`Clicking ${text}...`);
    const loc = page.locator(`.sidebar >> text="${text}"`).first();
    if (await loc.count() > 0) {
      await loc.click();
    } else {
      await page.locator(`text="${text}"`).first().click();
    }
    await page.waitForTimeout(4000);
    await page.screenshot({ path: outPath });
    console.log(`Saved ${outPath}`);
  }

  // 2. Click "Đổi quà tặng" -> Screenshot 22
  await clickSidebar('Đổi quà tặng', 'scripts/shot_sc22_fixed.png');

  // 3. Click "Thanh toán công nợ" -> Screenshot 2
  await clickSidebar('Thanh toán công nợ', 'scripts/shot_sc2_fixed.png');

  // 4. Click "Danh sách công nợ" -> Screenshot 13
  await clickSidebar('Danh sách công nợ', 'scripts/shot_sc13_fixed.png');

  // 5. Click "Xin nghỉ phép" -> Screenshot 21
  await clickSidebar('Xin nghỉ phép', 'scripts/shot_sc21_fixed.png');

  await browser.close();
  console.log('All portal captures done!');
}

captureSidebarMenus().catch(console.error);
