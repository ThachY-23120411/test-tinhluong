const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');
const fs = require('fs');
const path = require('path');

async function captureAfterFix() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  console.log('Logging in...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Reload page to ensure clean cache from DB
  console.log('Reloading page for clean cache...');
  await page.reload();
  await page.waitForTimeout(2000);

  // Open menu MnuKPI019
  console.log('Opening menu MnuKPI019 (Lịch sử nhập kho)...');
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI019');
    }
  });

  // Wait for #gridInventoryImport to be visible
  await page.waitForSelector('#gridInventoryImport:not([style*="display: none"])', { timeout: 20000 });
  console.log('Grid is visible, waiting for data load...');
  await page.waitForTimeout(3000);

  // Ensure screenshot folder exists
  const screenshotDir = path.resolve('fix-bug/lich_su_nhap_kho/screenshot');
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }

  // 1. Capture Desktop 1440px
  const after1440Path = path.join(screenshotDir, 'screenshot-29-after.png');
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: after1440Path });
  console.log('Saved Desktop after-fix screenshot to:', after1440Path);

  // 2. Capture Snap Layout 1024px
  const after1024Path = path.join(screenshotDir, 'screenshot-29-after-1024.png');
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: after1024Path });
  console.log('Saved Snap Layout 1024px after-fix screenshot to:', after1024Path);

  // Measure element positions from real DB render
  const analysis = await page.evaluate(() => {
    const ms = document.querySelector('#gridInventoryImport .ms-filter-toolbar');
    const rg = document.querySelector('#gridInventoryImport .toolbar-right-actions');
    const headers = document.querySelector('#gridInventoryImport .dx-datagrid-headers');
    const emp = document.querySelector('#gridInventoryImport #multilselectedEmployeeInventoryImport');
    const search = document.querySelector('#gridInventoryImport .filter-search-box input');

    return {
      msHeight: ms ? Math.round(ms.getBoundingClientRect().height) : null,
      isOverlapping: (headers && ms) ? (headers.getBoundingClientRect().top < ms.getBoundingClientRect().bottom) : false,
      empWidth: emp ? Math.round(emp.getBoundingClientRect().width) : null,
      searchWidth: search ? Math.round(search.getBoundingClientRect().width) : null,
      searchPlaceholder: search ? search.placeholder : null,
      rightActionsRight: rg ? Math.round(rg.getBoundingClientRect().right) : null,
      containerRight: ms ? Math.round(ms.getBoundingClientRect().right) : null
    };
  });

  console.log('Live DB Render Analysis:', JSON.stringify(analysis, null, 2));

  await browser.close();
}

captureAfterFix().catch(console.error);
