const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

async function debugError() {
  console.log('🚀 Launching Chrome to inspect console errors on Dữ liệu khách hàng...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  page.on('console', msg => {
    if (msg.type() === 'error' || msg.text().includes('toUpperCase') || msg.text().includes('TypeError')) {
      console.log(`[PAGE CONSOLE ${msg.type().toUpperCase()}]:`, msg.text());
      const location = msg.location();
      console.log('  Location:', location);
    }
  });

  page.on('pageerror', err => {
    console.log('🔥 [PAGE ERROR]:', err.message);
    console.log(err.stack);
  });

  console.log('Logging in...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if present to force fresh load
  const closeBtn = page.locator('#dynamic-tab-MnuKPI003 .close, .nav-tabs button:has-text("Dữ liệu khách hàng") .close').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    console.log('Closing existing Dữ liệu khách hàng tab...');
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1500);
  }

  console.log('Navigating to Dữ liệu khách hàng...');
  await navigateToCrmMenu(page, 'Dữ liệu khách hàng');
  await page.waitForTimeout(5000);

  // Trigger click on document or grid to see if error triggers on click/keypress/etc.
  console.log('Interacting with page...');
  await page.click('body');
  await page.waitForTimeout(1000);
  await page.click('#dataCollectionComponent');
  await page.waitForTimeout(1000);

  // Check what event listeners are on $(document)
  const listenersInfo = await page.evaluate(() => {
    // If jQuery is available
    if (window.$ && $._data) {
      const docEvents = $._data(document, 'events');
      if (!docEvents) return 'No events on document';
      const summary = {};
      for (const evt in docEvents) {
        summary[evt] = docEvents[evt].map(h => ({
          selector: h.selector,
          namespace: h.namespace,
          handlerStr: h.handler.toString().slice(0, 300)
        }));
      }
      return summary;
    }
    return 'jQuery $._data not available';
  });

  console.log('Document event listeners:');
  console.dir(listenersInfo, { depth: 4 });

  await browser.close();
}

debugError().catch(console.error);
