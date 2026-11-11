const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');

async function debugLine2() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

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

  const details = await page.evaluate(() => {
    const addBtn = document.querySelector('#gridInventoryImport button[title="Thêm mới"]');
    if (!addBtn) return 'no add button';

    // Walk up parents and collect their computed styles
    const chain = [];
    let curr = addBtn;
    while (curr && curr.id !== 'gridInventoryImport') {
      const cs = window.getComputedStyle(curr);
      chain.push({
        tag: curr.tagName,
        class: curr.className,
        display: cs.display,
        flex: cs.flex,
        justifyContent: cs.justifyContent,
        marginLeft: cs.marginLeft,
        width: cs.width,
        position: cs.position,
        left: curr.getBoundingClientRect().left
      });
      curr = curr.parentElement;
    }
    return chain;
  });

  console.log('AddBtn parent chain:', JSON.stringify(details, null, 2));
  await browser.close();
}

debugLine2().catch(console.error);
