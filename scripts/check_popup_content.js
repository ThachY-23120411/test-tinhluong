const { chromium } = require('playwright');

async function checkPopupContent() {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  page.on('response', async res => {
    const url = res.url();
    if (url.includes('AttendanceConfirm') || url.includes('Submit') || url.includes('hpa')) {
      try {
        const text = await res.text();
        console.log(`[HTTP ${res.status()}] ${url}\n-> ${text.substring(0, 300)}`);
      } catch (e) {}
    }
  });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('tai.dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(3000);

  const dockIcon = page.locator('.open-MnuWPT000, .MnuWPT000').first();
  if (await dockIcon.isVisible({ timeout: 5000 }).catch(() => false)) {
    await dockIcon.click();
    await page.waitForTimeout(1000);
  }
  await page.locator('a:has-text("Xin bù công")').first().click();
  await page.waitForTimeout(3000);

  // Take screenshot before click
  await page.screenshot({ path: 'scripts/shot_before_click_dangky.png' });

  console.log('--- Clicking Dang ky ---');
  await page.locator('button:has-text("Đăng ký")').first().click();
  await page.waitForTimeout(1000);

  // Look at popup content before clicking Dong y
  const confirmPopupText = await page.evaluate(() => {
    const el = document.querySelector('#vc-vu-confirm-popup');
    return el ? el.innerText : 'NO CONFIRM POPUP';
  });
  console.log('CONFIRM POPUP TEXT:', confirmPopupText);

  console.log('--- Clicking Dong y ---');
  await page.locator('.VC-Vu-btn-ok, .vc-btn-ok').first().click({ force: true });
  await page.waitForTimeout(3000);

  // Look at all popups now!
  const allPopups = await page.evaluate(() => {
    const list = document.querySelectorAll('.VC-Vu-component-overlay, .modal.show, div[role="dialog"]');
    return Array.from(list).map(el => ({
      id: el.id,
      className: el.className,
      style: el.getAttribute('style'),
      text: el.innerText
    }));
  });
  console.log('ALL POPUPS AFTER DONG Y:', JSON.stringify(allPopups, null, 2));

  await page.screenshot({ path: 'scripts/shot_after_click_dongy.png' });

  await browser.close();
}

checkPopupContent().catch(console.error);
