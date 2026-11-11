const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');

async function captureRealScreenshots() {
  console.log('Launching browser...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  
  page.on('console', msg => {
    if (msg.type() === 'error') console.log('[BROWSER CONSOLE ERROR]:', msg.text());
  });
  page.on('pageerror', err => {
    console.log('[BROWSER PAGE ERROR]:', err.message);
  });

  console.log('Logging in via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(3000);

  console.log('Navigating to MnuKPI005 (Nội dung đăng tải)...');
  // 1. Try to see if tab already exists, if so close it to force fresh reload from DB
  const existingTabClose = page.locator('#dynamic-tab-MnuKPI005 .close, .nav-tabs button:has-text("Nội dung đăng tải") .close, .nav-tabs li:has-text("Nội dung đăng tải") .bi-x').first();
  if (await existingTabClose.isVisible().catch(() => false)) {
    console.log('Closing existing tab to force fresh reload from cache...');
    await existingTabClose.click().catch(() => {});
    await page.waitForTimeout(1000);
  }

  // 2. Open via OpenAppInSidebar or click
  const opened = await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI005');
      return 'called OpenAppInSidebar';
    }
    const target = Array.from(document.querySelectorAll('a, button, span, div')).find(
      e => e.textContent && e.textContent.trim() === 'Nội dung đăng tải'
    );
    if (target) {
      target.click();
      return 'clicked text';
    }
    return false;
  });
  console.log('Navigation trigger result:', opened);

  // Wait for #GridContentPost
  console.log('Waiting for #GridContentPost to render...');
  await page.waitForSelector('#GridContentPost', { timeout: 20000 });
  await page.waitForTimeout(4000);

  const outDir = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/screenshot');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  // 1. Desktop Screenshot (1440px)
  const desktopPath = path.join(outDir, 'screenshot-27-after-desktop.png');
  const mainAfterPath = path.join(outDir, 'screenshot-27-after.png');
  await page.screenshot({ path: desktopPath });
  fs.copyFileSync(desktopPath, mainAfterPath);
  console.log(' Saved screenshot-27-after-desktop.png and screenshot-27-after.png');

  // 2. Component Crop
  const comp = await page.$('#contentComponent');
  if (comp) {
    await comp.screenshot({ path: path.join(outDir, 'screenshot-27-after-crop.png') });
    console.log(' Saved screenshot-27-after-crop.png');
  }

  // 3. Responsive 1200px
  await page.setViewportSize({ width: 1200, height: 900 });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after-responsive-1200.png') });
  console.log(' Saved screenshot-27-after-responsive-1200.png');

  // 4. Responsive 992px
  await page.setViewportSize({ width: 992, height: 900 });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after-responsive-992.png') });
  console.log(' Saved screenshot-27-after-responsive-992.png');

  await browser.close();
  console.log(' All real live after screenshots captured successfully!');
}

captureRealScreenshots().catch(console.error);
