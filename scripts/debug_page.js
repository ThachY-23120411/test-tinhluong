const { chromium } = require('playwright');
const { loginAsAdmin } = require('../helpers/auth');

async function debug() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  
  await loginAsAdmin(page);
  await page.waitForTimeout(3000);
  console.log('URL after login:', page.url());
  await page.screenshot({ path: 'scripts/debug_login.png' });
  
  const hasDock = await page.locator('.dock, .navbar').first().isVisible().catch(() => false);
  console.log('Has dock/navbar:', hasDock);

  // Try OpenAppInSidebar
  const opened = await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI005');
      return true;
    }
    return false;
  });
  console.log('OpenAppInSidebar MnuKPI005 called:', opened);
  await page.waitForTimeout(4000);
  await page.screenshot({ path: 'scripts/debug_app.png' });
  
  const hasGrid = await page.locator('#GridContentPost').isVisible().catch(() => false);
  console.log('Has GridContentPost:', hasGrid);

  await browser.close();
}

debug().catch(console.error);
