const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function captureScreens() {
  const browser = await chromium.launch({
    headless: true,
    channel: 'chrome',
    args: ['--window-size=1440,900']
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 }
  });

  const page = await context.newPage();
  const outDir = path.resolve(__dirname, '../debug_screens/user_guide');
  fs.mkdirSync(outDir, { recursive: true });

  console.log('Navigating to login page...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle', timeout: 45000 });
  await page.waitForTimeout(2000);

  // Login as cuong.vu
  console.log('Logging in as cuong.vu (123)...');
  const userInput = page.locator('#username, #txtUsername, input[name="username"]').first();
  await userInput.fill('cuong.vu');
  const passInput = page.locator('input[type="password"]').first();
  await passInput.fill('123');
  const submitBtn = page.locator('#submitLogin, #btnLogin, button[type="submit"]').first();
  await submitBtn.click();
  await page.waitForTimeout(4000);

  await page.screenshot({ path: path.join(outDir, '01_dock_overview.png') });

  // 1. Nhấp icon Quản trị nhân sự (MnuHRS000)
  console.log('Clicking Quản trị nhân sự (MnuHRS000)...');
  const hrsIcon = page.locator('button.open-MnuHRS000, button.MnuHRS000, .dock button:has(.fa-users), .dock button[title*="nhân sự"]').first();
  if (await hrsIcon.isVisible()) {
    await hrsIcon.click();
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outDir, '02_sidebar_HRS.png') });

    // Click "Quản lý hợp đồng lao động"
    const contractLink = page.locator('a:has-text("Quản lý hợp đồng"), span:has-text("Quản lý hợp đồng"), .child-launchpad:has-text("hợp đồng")').first();
    if (await contractLink.isVisible()) {
      console.log('Clicking Quản lý hợp đồng lao động...');
      await contractLink.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: path.join(outDir, '03_screen_hop_dong.png') });
    }

    // Click "Thông tin gia đình"
    const familyLink = page.locator('a:has-text("Thông tin gia đình"), span:has-text("Thông tin gia đình"), .child-launchpad:has-text("gia đình")').first();
    if (await familyLink.isVisible()) {
      console.log('Clicking Thông tin gia đình...');
      await familyLink.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: path.join(outDir, '04_screen_gia_dinh_NPT.png') });
    }
  }

  // 2. Nhấp icon Quản lý chấm công (MnuTAD000)
  console.log('Clicking Quản lý chấm công (MnuTAD000)...');
  const tadIcon = page.locator('button.open-MnuTAD000, button.MnuTAD000, .dock button:has(.fa-clock), .dock button[title*="chấm công"]').first();
  if (await tadIcon.isVisible()) {
    await tadIcon.click();
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outDir, '05_sidebar_TAD.png') });

    // Click "Xem dữ liệu chấm công hằng ngày"
    const dailyAttLink = page.locator('a:has-text("Xem dữ liệu chấm công hằng ngày"), span:has-text("Xem dữ liệu chấm công hằng ngày"), .child-launchpad:has-text("Xem dữ liệu chấm")').first();
    if (await dailyAttLink.isVisible()) {
      console.log('Clicking Xem dữ liệu chấm công hằng ngày...');
      await dailyAttLink.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: path.join(outDir, '06_screen_cham_cong_ngay.png') });
    }

    // Click "Tổng hợp công cả tháng"
    const monthAttLink = page.locator('a:has-text("Tổng hợp công cả tháng"), span:has-text("Tổng hợp công cả tháng"), a:has-text("Tổng hợp công tháng"), .child-launchpad:has-text("Tổng hợp công")').first();
    if (await monthAttLink.isVisible()) {
      console.log('Clicking Tổng hợp công cả tháng...');
      await monthAttLink.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: path.join(outDir, '07_screen_tong_hop_cong.png') });
    }
  }

  console.log('All screenshots captured successfully!');
  await browser.close();
}

captureScreens().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
