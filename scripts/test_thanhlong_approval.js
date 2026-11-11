const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'ThanhLong');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  await dockBtn.click();
  await page.waitForTimeout(2500);

  const identityId = '01A1A773-EE5B-743E-9EA5-9301674793A4';
  const cardSelector = `.getcardregisteredOA[data-value="${identityId}" i]`;
  console.log('Card exists?', await page.locator(cardSelector).count());

  if (await page.locator(cardSelector).count() > 0) {
    console.log('Clicking card...');
    await page.locator(cardSelector).first().click();
    await page.waitForTimeout(3000);

    const approveLeaveBtn = page.locator('#dynamic-pane-MnuWPT315 .btnApprove, #sp_ResignationLeave .btnApprove, button:has-text("Duyệt"):visible').first();
    console.log('approveLeaveBtn visible?', await approveLeaveBtn.isVisible());
    if (await approveLeaveBtn.isVisible()) {
      await approveLeaveBtn.click();
      await page.waitForTimeout(1500);

      console.log('Dispatching click to Dong y button...');
      await page.evaluate(() => {
        const btn = Array.from(document.querySelectorAll('.VC-Vu-btn-ok, .vc-btn-ok, button')).find(b => b.innerText.trim() === 'Đồng ý' && b.offsetParent !== null);
        if (btn) btn.click();
      });
      await page.waitForTimeout(2000);

      // Check for subsequent OK button
      await page.evaluate(() => {
        const okBtn = Array.from(document.querySelectorAll('.VC-Vu-btn-ok, .vc-btn-ok, button')).find(b => b.innerText.trim() === 'OK' && b.offsetParent !== null);
        if (okBtn) okBtn.click();
      });
      await page.waitForTimeout(2000);
    }
  }

  const dbResult = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${identityId}'`);
  console.log('DB result after approval:', JSON.stringify(dbResult, null, 2));

  await browser.close();
})();
