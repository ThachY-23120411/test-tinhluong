const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.fill('#username', 'ThanhLong');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  await dockBtn.click();
  await page.waitForTimeout(2500);

  const identityId = '01A1A773-EE5B-743E-9EA5-9301674793A4';
  const card = page.locator(`.getcardregisteredOA[data-value="${identityId}" i]`).first();
  console.log('Card exists?', await card.isVisible());

  if (await card.isVisible()) {
    await card.click();
    await page.waitForTimeout(3000);

    // Call HandleApproveLeaveRequest directly or click modal button and log console
    page.on('console', msg => console.log('BROWSER CONSOLE:', msg.type(), msg.text()));

    const approveLeaveBtn = page.locator('#dynamic-pane-MnuWPT315 .btnApprove, #sp_ResignationLeave .btnApprove').first();
    console.log('approveLeaveBtn visible?', await approveLeaveBtn.isVisible());
    await approveLeaveBtn.click();
    await page.waitForTimeout(1500);

    const result = await page.evaluate(async (id) => {
      console.log('data-action on btn:', $('#btnActionModalRemake').attr('data-action'));
      console.log('selectedIdentityID:', typeof selectedIdentityID !== 'undefined' ? selectedIdentityID : 'undefined');
      console.log('LoginID:', typeof LoginID !== 'undefined' ? LoginID : 'undefined');
      console.log('UserID:', typeof UserID !== 'undefined' ? UserID : 'undefined');

      // Click the approve button in modal
      $('#btnActionModalRemake').trigger('click');
    }, identityId);

    await page.waitForTimeout(4000);
  }

  const dbResult = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${identityId}'`);
  console.log('DB result after trigger click:', JSON.stringify(dbResult, null, 2));

  await browser.close();
})();
