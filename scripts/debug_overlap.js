const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');

async function debugOverlap() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab
  const closeBtn = page.locator('#dynamic-tab-MnuKPI019 .close, .nav-tabs button:has-text("Lịch sử nhập kho") .close, .nav-tabs li:has-text("Lịch sử nhập kho") .bi-x').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1000);
  }

  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') window.OpenAppInSidebar('MnuKPI019');
  });

  await page.waitForSelector('#gridInventoryImport:not([style*="display: none"])', { timeout: 15000 });
  await page.waitForTimeout(3000);

  // Measure current positioning of header-panel vs headers
  const positions = await page.evaluate(() => {
    const hp = document.querySelector('#gridInventoryImport .dx-datagrid-header-panel');
    const headers = document.querySelector('#gridInventoryImport .dx-datagrid-headers');
    const tb = document.querySelector('#gridInventoryImport .dx-toolbar');
    const ms = document.querySelector('#gridInventoryImport .ms-filter-toolbar');

    const hpRect = hp ? hp.getBoundingClientRect() : null;
    const hRect = headers ? headers.getBoundingClientRect() : null;
    const tbRect = tb ? tb.getBoundingClientRect() : null;
    const msRect = ms ? ms.getBoundingClientRect() : null;

    const hpStyle = hp ? window.getComputedStyle(hp) : null;
    const hStyle = headers ? window.getComputedStyle(headers) : null;

    return {
      hpRect,
      hRect,
      tbRect,
      msRect,
      hpPosition: hpStyle ? hpStyle.position : null,
      hpHeight: hpStyle ? hpStyle.height : null,
      hPosition: hStyle ? hStyle.position : null,
      hTop: hStyle ? hStyle.top : null,
      hMarginTop: hStyle ? hStyle.marginTop : null,
      isOverlapping: hpRect && hRect ? (hRect.top < hpRect.bottom) : false,
      overlapPx: hpRect && hRect ? (hpRect.bottom - hRect.top) : 0
    };
  });

  console.log('Positioning analysis:', JSON.stringify(positions, null, 2));
  await browser.close();
}

debugOverlap().catch(console.error);
