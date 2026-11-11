const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);

  // Login
  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  const clientInfo = await page.evaluate(() => {
    // Check localStorage keys
    const lsKeys = Object.keys(localStorage);
    const ssKeys = Object.keys(sessionStorage);
    
    // Check how Paradise loads menus
    const funcs = {
      has_fLoadTabMenu: typeof window.fLoadTabMenu,
      has_AjaxHPAParadise: typeof window.AjaxHPAParadise,
      has_openMenu: typeof window.openMenu,
      has_fLoadData: typeof window.fLoadData
    };

    // Find any key related to MnuPRL409 or Debt
    const relevantLs = {};
    for (const k of lsKeys) {
      if (k.includes('409') || k.includes('Debt') || k.includes('HTML') || k.includes('Menu') || k.includes('Version')) {
        relevantLs[k] = localStorage.getItem(k).substring(0, 100);
      }
    }

    return { lsKeysCount: lsKeys.length, relevantLs, ssKeys, funcs };
  });

  console.log('Client Info:');
  console.log(JSON.stringify(clientInfo, null, 2));

  await browser.close();
}

main().catch(console.error);
