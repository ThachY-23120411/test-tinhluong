const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

async function captureRealEmailManualAfter() {
  console.log('🚀 Launching Google Chrome for REAL After-Fix screenshots of Email gửi thủ công...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('🔑 Authenticating via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if present to force fresh load from tblHtmlScriptCache
  console.log('🔄 Checking for existing Email gửi thủ công tab to force fresh cache reload...');
  const closeBtn = page.locator('#dynamic-tab-MnuKPI002 .close, .nav-tabs button:has-text("Email gửi thủ công") .close, .nav-tabs li:has-text("Email gửi thủ công") .close').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    console.log('Closing existing Email gửi thủ công tab...');
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1500);
  }

  // Navigate to Email gửi thủ công
  console.log('📂 Navigating to Email gửi thủ công via navigateToCrmMenu...');
  await navigateToCrmMenu(page, 'Email gửi thủ công');

  console.log('⏳ Waiting for #sp_KPIListEmailManual #GridEmailKPI to render from Database...');
  await page.waitForSelector('#sp_KPIListEmailManual #GridEmailKPI', { timeout: 30000 });
  await page.waitForTimeout(4000);

  // Helper to extract DOM measurements
  async function inspectDOM(label) {
    return await page.evaluate((lbl) => {
      const container = document.querySelector('#GridEmailKPI .dx-toolbar-items-container');
      const employee = document.querySelector('#emailFilterEmployeeToolbar');
      const from = document.querySelector('#toolbarFilterFromDate');
      const to = document.querySelector('#toolbarFilterToDate');
      const filterBtn = document.querySelector('.data-filter-email-view button.btn-success:not(:has(.bi-envelope-fill))');
      const composeBtn = document.querySelector('.data-filter-email-view button.btn-success:has(.bi-envelope-fill)');
      const checkRow = document.querySelector('.email-checkbox-group') || document.querySelector('#toolbarFilterViewAll')?.parentElement;
      const checkAll = document.querySelector('#toolbarFilterViewAll');
      const checkMy = document.querySelector('#toolbarFilterMyData');
      const after = document.querySelector('#GridEmailKPI .dx-toolbar-after');
      const search = document.querySelector('#GridEmailKPI .dx-searchbox, #GridEmailKPI .dx-datagrid-search-panel');
      const chooser = document.querySelector('#GridEmailKPI .dx-datagrid-column-chooser-button');

      function rect(el) {
        if (!el) return null;
        const r = el.getBoundingClientRect();
        return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) };
      }

      return {
        label: lbl,
        container: rect(container),
        employee: rect(employee),
        from: rect(from),
        to: rect(to),
        filterBtn: rect(filterBtn),
        composeBtn: rect(composeBtn),
        checkRow: rect(checkRow),
        checkAll: rect(checkAll),
        checkMy: rect(checkMy),
        chooser: rect(chooser),
        search: rect(search),
        after: rect(after)
      };
    }, label);
  }

  const screenshotDir = path.resolve(__dirname, '../fix-bug/crm_email_manual/screenshot');
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }

  // 1. Measure and capture Desktop 1440px
  console.log('📸 1. Capturing Desktop 1440px...');
  const metrics1440 = await inspectDOM('Desktop 1440px');
  console.log('Metrics 1440px:', JSON.stringify(metrics1440, null, 2));

  const afterShotPath = path.join(screenshotDir, 'screenshot-after.png');
  await page.screenshot({ path: afterShotPath, fullPage: false });

  // Crop toolbar zoom
  const toolbarCropPath = path.join(screenshotDir, 'screenshot-toolbar-crop.png');
  const toolbarEl = page.locator('#sp_KPIListEmailManual #GridEmailKPI .dx-toolbar');
  if (await toolbarEl.isVisible().catch(() => false)) {
    await toolbarEl.screenshot({ path: toolbarCropPath });
  }

  // 2. Measure and capture Snap 1024px
  console.log('📸 2. Capturing Snap 1024px...');
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1500);

  const metrics1024 = await inspectDOM('Snap 1024px');
  console.log('Metrics 1024px:', JSON.stringify(metrics1024, null, 2));

  const after1024Path = path.join(screenshotDir, 'screenshot-1024-after.png');
  await page.screenshot({ path: after1024Path, fullPage: false });

  // 3. Measure and capture Snap 768px
  console.log('📸 3. Capturing Snap 768px...');
  await page.setViewportSize({ width: 768, height: 600 });
  await page.waitForTimeout(1500);

  const metrics768 = await inspectDOM('Snap 768px');
  console.log('Metrics 768px:', JSON.stringify(metrics768, null, 2));

  const after768Path = path.join(screenshotDir, 'screenshot-768-after.png');
  await page.screenshot({ path: after768Path, fullPage: false });

  await browser.close();
  console.log('🎉 REAL After-Fix screenshots and DOM metrics captured successfully!');

  // Save metrics to JSON for report incorporation
  fs.writeFileSync(path.join(__dirname, 'last_email_metrics.json'), JSON.stringify({
    metrics1440,
    metrics1024,
    metrics768
  }, null, 2));
}

captureRealEmailManualAfter().catch(console.error);
