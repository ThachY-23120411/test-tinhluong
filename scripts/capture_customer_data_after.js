const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

async function captureRealCustomerDataAfter() {
  console.log('🚀 Launching Google Chrome for REAL After-Fix screenshots of Dữ liệu khách hàng...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('🔑 Authenticating via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if present to force fresh load from tblHtmlScriptCache
  console.log('🔄 Checking for existing Dữ liệu khách hàng tab to force fresh cache reload...');
  const closeBtn = page.locator('#dynamic-tab-MnuKPI003 .close, .nav-tabs button:has-text("Dữ liệu khách hàng") .close, .nav-tabs li:has-text("Dữ liệu khách hàng") .close').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    console.log('Closing existing Dữ liệu khách hàng tab...');
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1500);
  }

  // Navigate to Dữ liệu khách hàng
  console.log('📂 Navigating to Dữ liệu khách hàng via navigateToCrmMenu...');
  await navigateToCrmMenu(page, 'Dữ liệu khách hàng');

  console.log('⏳ Waiting for #dataCollectionComponent / #GridKC to render from Database...');
  await page.waitForSelector('#dataCollectionComponent #GridKC', { timeout: 30000 });
  await page.waitForTimeout(4000);

  // Inspect live DOM measurements of Toolbar
  const domInfo = await page.evaluate(() => {
    const comp = document.querySelector('#dataCollectionComponent');
    const container = document.querySelector('#GridKC .dx-toolbar-items-container');
    const before = document.querySelector('#GridKC .dx-toolbar-before');
    const after = document.querySelector('#GridKC .dx-toolbar-after');
    const capsule = document.querySelector('#dataCollectionComponent .crm-status-row');
    const filter = document.querySelector('#dataCollectionComponent .dc-filter');
    const myData = document.querySelector('#dataCollectionComponent .dc-quick-mydata-row');
    const search = document.querySelector('#GridKC .dx-searchbox, #GridKC .dx-datagrid-search-panel');

    function getRect(el) {
      if (!el) return null;
      const r = el.getBoundingClientRect();
      return {
        top: Math.round(r.top),
        left: Math.round(r.left),
        width: Math.round(r.width),
        height: Math.round(r.height)
      };
    }

    return {
      hasContainer: !!container,
      containerRect: getRect(container),
      beforeRect: getRect(before),
      afterRect: getRect(after),
      capsuleRect: getRect(capsule),
      filterRect: getRect(filter),
      myDataRect: getRect(myData),
      searchRect: getRect(search)
    };
  });

  console.log('Live DOM Toolbar measurements:', JSON.stringify(domInfo, null, 2));

  const outDir = path.resolve(__dirname, '../fix-bug/crm_customer_data/screenshot');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const viewports = [
    { name: '1440', filename: 'screenshot-customer-data-after.png', w: 1440, h: 900 },
    { name: '1920', filename: 'screenshot-customer-data-1920-after.png', w: 1920, h: 1080 },
    { name: '1091', filename: 'screenshot-customer-data-1091-after.png', w: 1091, h: 911 },
    { name: '1024', filename: 'screenshot-customer-data-snap1024-after.png', w: 1024, h: 768 },
    { name: '768', filename: 'screenshot-customer-data-snap768-after.png', w: 768, h: 600 }
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.w, height: vp.h });
    await page.waitForTimeout(1200);

    const shotPath = path.join(outDir, vp.filename);
    await page.screenshot({ path: shotPath });
    console.log(`📸 Saved real after-fix screenshot (${vp.w}x${vp.h}): ${shotPath}`);
  }

  // Also crop the toolbar area specifically at 1440px
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(800);
  const toolbarEl = await page.$('#GridKC .dx-toolbar');
  if (toolbarEl) {
    const cropPath = path.join(outDir, 'screenshot-customer-data-toolbar-crop.png');
    await toolbarEl.screenshot({ path: cropPath });
    console.log(`📸 Saved toolbar crop: ${cropPath}`);
  }

  await browser.close();
  console.log('🎉 100% SUCCESS: All real after-fix screenshots captured from live website!');
}

captureRealCustomerDataAfter().catch(err => {
  console.error('❌ Error during capture:', err);
  process.exit(1);
});
