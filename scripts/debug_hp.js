const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');

async function debugHeaderPanel() {
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

  const res = await page.evaluate(() => {
    const hp = document.querySelector('#gridInventoryImport .dx-datagrid-header-panel');
    const tb = document.querySelector('#gridInventoryImport .dx-toolbar');
    const headers = document.querySelector('#gridInventoryImport .dx-datagrid-headers');
    const grid = document.querySelector('#gridInventoryImport .dx-datagrid');

    function getRules(el) {
      const styles = [];
      for (const sheet of document.styleSheets) {
        try {
          for (const rule of sheet.cssRules || []) {
            if (el.matches && el.matches(rule.selectorText)) {
              styles.push({ selector: rule.selectorText, cssText: rule.cssText });
            }
          }
        } catch (_) {}
      }
      return styles;
    }

    return {
      hpComputed: {
        height: window.getComputedStyle(hp).height,
        maxHeight: window.getComputedStyle(hp).maxHeight,
        overflow: window.getComputedStyle(hp).overflow,
        position: window.getComputedStyle(hp).position,
        display: window.getComputedStyle(hp).display
      },
      headersComputed: {
        position: window.getComputedStyle(headers).position,
        top: window.getComputedStyle(headers).top,
        transform: window.getComputedStyle(headers).transform,
        marginTop: window.getComputedStyle(headers).marginTop
      },
      hpRules: getRules(hp)
    };
  });

  console.log('Header Panel analysis:', JSON.stringify(res, null, 2));
  await browser.close();
}

debugHeaderPanel().catch(console.error);
