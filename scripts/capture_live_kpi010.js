const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();

  console.log('Navigating to https://paradisehrm.com/Tai3/# ...');

  page.on('console', msg => {
    const text = msg.text();
    if (text.includes('dataObject') || text.includes('SyntaxError') || text.includes('MnuKPI010')) {
      console.log(`[CONSOLE]:`, text);
    }
  });

  page.on('pageerror', err => {
    console.error(`[PAGE ERROR]:`, err.message);
  });

  // Bắt tất cả response từ ParadiseParadise
  page.on('response', async res => {
    const url = res.url();
    if (url.includes('ParadiseParadise')) {
      try {
        const text = await res.text();
        if (text.includes('GridEmailKPIList') || text.includes('sp_CRM_EmailKPIFollow') || text.includes('MnuKPI010')) {
          console.log(`🎯 CAPTURED KPI010 API RESPONSE! Size: ${text.length}`);
          fs.writeFileSync('scripts/captured_kpi010_payload.json', text, 'utf8');
        }
      } catch(e) {}
    }
  });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle', timeout: 30000 });

  // Login
  const userInp = page.locator('#username, input[type="text"]').first();
  await userInp.fill('Chien.nguyen');
  const passInp = page.locator('input[type="password"]').first();
  await passInp.fill('123');
  const submitBtn = page.locator('#submitLogin, button[type="submit"]').first();
  await submitBtn.click();

  await page.waitForTimeout(4000);

  // Mở menu MnuKPI010
  console.log('Triggering openMenu(MnuKPI010)...');
  await page.evaluate(() => {
    if (typeof window.openMenu === 'function') {
      window.openMenu('MnuKPI010');
    }
  });

  await page.waitForTimeout(5000);

  await browser.close();
  console.log('Done test.');
})();
