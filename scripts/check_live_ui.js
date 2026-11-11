const { chromium } = require('playwright');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

async function checkLiveUI() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if open to force reload
  const existingTabClose = page.locator('#dynamic-tab-MnuKPI019 .close, .nav-tabs button:has-text("Lịch sử nhập kho") .close, .nav-tabs li:has-text("Lịch sử nhập kho") .bi-x').first();
  if (await existingTabClose.isVisible().catch(() => false)) {
    await existingTabClose.click().catch(() => {});
    await page.waitForTimeout(1000);
  }

  // Open MnuKPI019
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI019');
    }
  });

  await page.waitForTimeout(4000);

  // Take a high-res screenshot of the toolbar area
  const toolbar = page.locator('#gridInventoryImport .dx-toolbar').first();
  if (await toolbar.isVisible()) {
    await toolbar.screenshot({ path: 'scripts/live_toolbar.png' });
    console.log('Saved scripts/live_toolbar.png');
  }

  // Inspect the exact DOM and computed styles around from-date, to-date, employee, and toolbar items
  const domInfo = await page.evaluate(() => {
    const grid = document.querySelector('#gridInventoryImport');
    if (!grid) return 'Grid not found';

    const before = grid.querySelector('.dx-toolbar-before');
    const items = before ? Array.from(before.children).map(c => ({
      tagName: c.tagName,
      className: c.className,
      id: c.id,
      innerHTML: c.innerHTML.substring(0, 300)
    })) : [];

    const fromDateEl = grid.querySelector('.filter-from-date');
    const fromDateComputed = fromDateEl ? {
      border: window.getComputedStyle(fromDateEl).border,
      outline: window.getComputedStyle(fromDateEl).outline,
      boxShadow: window.getComputedStyle(fromDateEl).boxShadow,
      childBorders: Array.from(fromDateEl.querySelectorAll('*')).map(el => ({
        cls: el.className,
        border: window.getComputedStyle(el).border,
        borderColor: window.getComputedStyle(el).borderColor
      })).filter(x => x.border && !x.border.startsWith('0px'))
    } : null;

    return {
      beforeChildrenCount: items.length,
      items,
      fromDateComputed
    };
  });

  console.log('DOM info:\n', JSON.stringify(domInfo, null, 2));

  await browser.close();
}

checkLiveUI().catch(console.error);
