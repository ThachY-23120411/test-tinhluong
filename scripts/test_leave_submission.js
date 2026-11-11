const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Click MnuWPT315
  const dockBtn = page.locator('.dock button.open-MnuWPT315, .dock button.MnuWPT315').first();
  await dockBtn.click();
  await page.waitForTimeout(3000);

  // Fill form with AL
  const evalRes = await page.evaluate(() => {
    try {
      if (typeof InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D !== 'undefined' && InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D) {
        InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D.option('value', 'AL');
      }
      var instanceFrom = getControlInstance("LeaveFromDate");
      if (instanceFrom) instanceFrom.option("value", new Date('2026-12-02T08:00:00'));
      var instanceTo = getControlInstance("LeaveToDate");
      if (instanceTo) instanceTo.option("value", new Date('2026-12-02T12:00:00'));
      const el = document.getElementById('lyDo');
      if (el) {
        el.value = 'Nghỉ việc riêng debug test Playwright';
        el.dispatchEvent(new Event('input', { bubbles: true }));
        el.dispatchEvent(new Event('change', { bubbles: true }));
      }
      return {
        from: instanceFrom ? instanceFrom.option('value') : null,
        to: instanceTo ? instanceTo.option('value') : null,
        type: typeof InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D !== 'undefined' ? InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D.option('value') : 'undefined',
        reason: el ? el.value : null
      };
    } catch (e) {
      return { error: e.message };
    }
  });
  console.log('Eval form state:', evalRes);
  await page.waitForTimeout(1000);

  // Click btnRegister
  const submitBtn = page.locator('#sp_ResignationLeave .btnRegister').first();
  await submitBtn.click();
  await page.waitForTimeout(1500);

  // Click Đồng ý
  const confirmBtn = page.locator('.VC-Vu-btn-ok, button:has-text("Đồng ý")').first();
  console.log('Confirm button visible?', await confirmBtn.isVisible());
  if (await confirmBtn.isVisible()) {
    await confirmBtn.click();
    await page.waitForTimeout(3000);
  }

  // Check DB
  const recent = query("SELECT TOP 1 IdentityID, EmployeeID, LeaveFromDate, LeaveToDate, Reason, Approve_Status FROM tblLeaveRegistered WHERE EmployeeID = '046' ORDER BY LeaveFromDate DESC");
  console.log('Most recent leave in DB:', recent);

  await browser.close();
})();
