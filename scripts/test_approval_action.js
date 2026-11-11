const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/');
  await page.locator('#username').fill('ThanhLong');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForSelector('.dock, .navbar', { timeout: 20000 });

  // Open MnuWPT037
  const btn = page.locator('button.open-MnuWPT037, button.MnuWPT037, [onclick*="MnuWPT037"]').first();
  await btn.click();
  await page.waitForTimeout(2000);

  // Click card for 046 (data-group = 1)
  const card = page.locator('.getcardregisteredOA[data-group="1"]').first();
  const identityId = await card.getAttribute('data-value');
  console.log('Clicking card with identityId:', identityId);
  await card.click();
  await page.waitForTimeout(2500);

  // Check approve button on form
  const approveBtn = page.locator('#sp_ResignationLeave .btnApprove, button.btnApprove').first();
  const isApproveVis = await approveBtn.isVisible({ timeout: 5000 }).catch(() => false);
  console.log('isApproveVis:', isApproveVis);

  if (isApproveVis) {
    console.log('Clicking approveBtn...');
    await approveBtn.click();
    await page.waitForTimeout(1500);

    // Check modal or confirm popup
    const modalBtn = page.locator('#btnActionModalRemake, button:has-text("Đã duyệt"), button:has-text("Đồng ý")').first();
    const isModalVis = await modalBtn.isVisible({ timeout: 3000 }).catch(() => false);
    console.log('isModalVis:', isModalVis);
    if (isModalVis) {
      await modalBtn.click();
      await page.waitForTimeout(3000);
    }
  }

  // Check DB status of identityId
  const dbCheck = query(`SELECT IdentityID, EmployeeID, Approve_Status, Current_Approve_Level FROM tblLeaveRegistered WHERE IdentityID = '${identityId}'`);
  console.log('DB check after approval:', dbCheck);

  await browser.close();
})();
