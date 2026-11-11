const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  // Check current OT request 01A1A79E-A990-7E0D-8061-10A04F43AFA4
  const id = '01A1A79E-A990-7E0D-8061-10A04F43AFA4';
  const historyBefore = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${id}'`);
  console.log('History before:', historyBefore);

  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Click MnuWPT037 dock button
  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037').first();
  await dockBtn.click();
  await page.waitForTimeout(3000);

  const card = page.locator(`.getcardregisteredOA[data-value="${id}" i]`).first();
  console.log('Card exists for cuong.vu?', await card.isVisible());

  if (await card.isVisible()) {
    console.log('Clicking card...');
    await card.click();
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'test-evidence/cuong_ot_opened.png' });

    // Check visible buttons
    const buttons = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('button')).map(b => ({
        text: b.innerText.trim(),
        id: b.id,
        className: b.className,
        visible: b.offsetParent !== null
      })).filter(b => b.visible && (b.text.includes('Duyệt') || b.className.includes('btnApprove')));
    });
    console.log('Approval buttons:', buttons);

    // Click Duyet
    const approveBtn = page.locator('#sp_Overtime_Assignment .btnApprove, button:has-text("Duyệt"):visible').first();
    if (await approveBtn.isVisible()) {
      console.log('Clicking approve button...');
      await page.evaluate(() => {
        document.querySelectorAll('form').forEach(f => { f.onsubmit = e => { e.preventDefault(); return false; }; });
        document.querySelectorAll('button:not([type])').forEach(b => b.setAttribute('type', 'button'));
      });
      await approveBtn.click();
      await page.waitForTimeout(1500);

      await page.screenshot({ path: 'test-evidence/cuong_ot_modal.png' });

      // Check modal
      const modalBtn = page.locator('#btnActionModalRemakeOT:visible, #modalApproveRemakeForOT button.btn-success:visible').first();
      console.log('Modal confirm button visible?', await modalBtn.isVisible());
      if (await modalBtn.isVisible()) {
        await modalBtn.click();
        await page.waitForTimeout(3000);
      }
    }
  }

  const historyAfter = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${id}'`);
  console.log('History after:', historyAfter);

  await browser.close();
})();
