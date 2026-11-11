const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

async function captureRealContentPostAfter() {
  console.log('🚀 Launching Google Chrome for REAL After-Fix screenshots of Nội dung đăng tải...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('🔑 Authenticating via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if present to force fresh load from tblHtmlScriptCache
  console.log('🔄 Checking for existing Nội dung đăng tải tab to force fresh cache reload...');
  const closeBtn = page.locator('#dynamic-tab-MnuKPI005 .close, .nav-tabs button:has-text("Nội dung đăng tải") .close, .nav-tabs li:has-text("Nội dung đăng tải") .close').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    console.log('Closing existing Nội dung đăng tải tab...');
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1500);
  }

  // Navigate to Nội dung đăng tải
  console.log('📂 Navigating to Nội dung đăng tải via OpenAppInSidebar("MnuKPI005")...');
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI005');
    }
  });

  console.log('⏳ Waiting for #contentComponent #GridContentPost to render from Database...');
  await page.waitForSelector('#contentComponent #GridContentPost', { timeout: 30000 });
  await page.waitForTimeout(4000);

  // Helper to extract DOM measurements
  async function inspectDOM(label) {
    return await page.evaluate((lbl) => {
      const container = document.querySelector('#GridContentPost .dx-toolbar-items-container');
      const employee = document.querySelector('#contentFilterEmployeeToolbar');
      const from = document.querySelector('#cFilterFromDate');
      const to = document.querySelector('#cFilterToDate');
      const filterBtn = document.querySelector('#cFilterSearchBtn');
      const checkRow = document.querySelector('.c-checkbox-group') || document.querySelector('#cFilterViewAll')?.parentElement?.parentElement;
      const checkAll = document.querySelector('#cFilterViewAll');
      const checkMy = document.querySelector('#cFilterMyData');
      const addBtn = document.querySelector('#btnOpenContentModal');
      const chooser = document.querySelector('#GridContentPost .dx-datagrid-column-chooser-button');
      const search = document.querySelector('#GridContentPost .dx-searchbox, #GridContentPost .dx-datagrid-search-panel');
      const after = document.querySelector('#GridContentPost .dx-toolbar-after');

      function rect(el) {
        if (!el) return null;
        const r = el.getBoundingClientRect();
        return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) };
      }

      const searchInput = document.querySelector('#GridContentPost .dx-datagrid-search-panel .dx-texteditor-input, #GridContentPost .dx-searchbox .dx-texteditor-input');
      const searchPaddingLeft = searchInput ? window.getComputedStyle(searchInput).paddingLeft : null;

      return {
        label: lbl,
        container: rect(container),
        employee: rect(employee),
        from: rect(from),
        to: rect(to),
        filterBtn: rect(filterBtn),
        checkRow: rect(checkRow),
        checkAll: rect(checkAll),
        checkMy: rect(checkMy),
        addBtn: rect(addBtn),
        chooser: rect(chooser),
        search: rect(search),
        after: rect(after),
        searchPaddingLeft: searchPaddingLeft
      };
    }, label);
  }

  const screenshotDir = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/screenshot');
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
  const toolbarEl = page.locator('#GridContentPost .dx-toolbar');
  if (await toolbarEl.isVisible().catch(() => false)) {
    await toolbarEl.screenshot({ path: toolbarCropPath });
  }

  // Close-up zoom of searchbox
  const searchboxCropPath = path.join(screenshotDir, 'screenshot-searchbox-zoom.png');
  const searchEl = page.locator('#GridContentPost .dx-datagrid-search-panel, #GridContentPost .dx-searchbox').first();
  if (await searchEl.isVisible().catch(() => false)) {
    await searchEl.screenshot({ path: searchboxCropPath });
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

  fs.writeFileSync(path.join(__dirname, 'last_content_post_metrics.json'), JSON.stringify({
    metrics1440,
    metrics1024,
    metrics768
  }, null, 2));
}

captureRealContentPostAfter().catch(console.error);
