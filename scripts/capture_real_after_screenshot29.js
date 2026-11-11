const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');

async function captureAfterScreenshots() {
  console.log('🚀 Launching Chrome for After Fix screenshot...');
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

  console.log('🔑 Logging in via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(3000);

  // 1. Force close any existing tab to guarantee fresh HTML from tblHtmlScriptCache
  console.log('🔄 Checking for existing Lịch sử nhập kho tab to ensure fresh DB reload...');
  const existingTabClose = page.locator('#dynamic-tab-MnuKPI019 .close, .nav-tabs button:has-text("Lịch sử nhập kho") .close, .nav-tabs li:has-text("Lịch sử nhập kho") .bi-x').first();
  if (await existingTabClose.isVisible().catch(() => false)) {
    console.log('Closing existing tab...');
    await existingTabClose.click().catch(() => {});
    await page.waitForTimeout(1000);
  }

  // 2. Open MnuKPI019
  console.log('📂 Opening MnuKPI019 (Lịch sử nhập kho)...');
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI019');
    }
  });

  console.log('⏳ Waiting for #gridInventoryImport to render...');
  await page.waitForSelector('#gridInventoryImport', { timeout: 20000 });
  await page.waitForTimeout(4000);

  const outDir = path.resolve(__dirname, '../fix-bug/lich_su_nhap_kho/screenshot');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  // 3. Desktop Screenshot (1440px)
  const mainAfterPath = path.join(outDir, 'screenshot-29-after.png');
  await page.screenshot({ path: mainAfterPath });
  console.log('✅ Saved screenshot-29-after.png');

  // 4. Crop toolbar & header area
  const toolbarEl = await page.$('#gridInventoryImport');
  if (toolbarEl) {
    const cropPath = path.join(outDir, 'screenshot-29-after-crop.png');
    await toolbarEl.screenshot({ path: cropPath });
    console.log('✅ Saved screenshot-29-after-crop.png');
  }

  // 5. Tablet Responsive (1024px)
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1500);
  const respPath = path.join(outDir, 'screenshot-29-after-responsive-1024.png');
  await page.screenshot({ path: respPath });
  console.log('✅ Saved screenshot-29-after-responsive-1024.png');

  // 6. Inspect DOM to verify column widths and values
  const metrics = await page.evaluate(() => {
    const grid = document.querySelector('#gridInventoryImport');
    if (!grid) return null;
    const headers = Array.from(grid.querySelectorAll('.dx-datagrid-headers td')).map(td => ({
      caption: td.innerText?.trim().replace(/\n/g, ' '),
      width: td.offsetWidth,
      styleWidth: td.style.width
    }));
    const rowCount = grid.querySelectorAll('.dx-datagrid-rowsview .dx-data-row').length;
    const placeholderDisplay = window.getComputedStyle(grid.querySelector('.dx-searchbox .dx-placeholder') || document.body).display;
    return { headers, rowCount, placeholderDisplay };
  });

  console.log('📊 Actual DOM Metrics after DB exec:');
  console.log(JSON.stringify(metrics, null, 2));

  await browser.close();
  console.log('🎉 Done capturing real live screenshots!');
}

captureAfterScreenshots().catch(console.error);
