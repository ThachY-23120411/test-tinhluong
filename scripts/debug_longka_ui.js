const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'LongKa');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Click dock button for MnuWPT037
  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  if (await dockBtn.isVisible()) {
    console.log('Clicking dock button...');
    await dockBtn.click();
  } else {
    console.log('Calling openApp...');
    await page.evaluate(() => {
      if (typeof openApp === 'function') openApp('MnuWPT037');
    });
  }

  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'test-evidence/debug_longka_dock.png' });

  const cardCount = await page.locator('.getcardregisteredOA').count();
  console.log('Total .getcardregisteredOA count:', cardCount);

  const cards = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.getcardregisteredOA')).map(c => ({
      val: c.getAttribute('data-value'),
      text: c.innerText.replace(/\n+/g, ' ').trim()
    }));
  });
  console.log('Cards found:', cards);

  const identityId = '01A1A75E-EEBB-7EB7-BACF-133AD64EB3BA';
  const cardSelector = `.getcardregisteredOA[data-value="${identityId}" i]`;
  console.log('Card exists?', await page.locator(cardSelector).count());

  if (await page.locator(cardSelector).count() > 0) {
    console.log('Clicking card...');
    await page.locator(cardSelector).first().click();
    await page.waitForTimeout(3000);

    await page.screenshot({ path: 'test-evidence/debug_ot_opened.png' });

    const buttons = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('button')).map(b => ({
        text: b.innerText.trim(),
        id: b.id,
        className: b.className,
        visible: b.offsetParent !== null
      })).filter(b => b.visible && (b.text.includes('Duyệt') || b.className.includes('btnApprove') || b.id.includes('Approve')));
    });
    console.log('Visible approval buttons:', buttons);

    const approveOtBtn = page.locator('#sp_Overtime_Assignment .btnApprove, button.btnApprove:visible').first();
    console.log('approveOtBtn isVisible:', await approveOtBtn.isVisible());
    if (await approveOtBtn.isVisible()) {
      await approveOtBtn.click();
      await page.waitForTimeout(1500);

      const modalInfo = await page.evaluate(() => {
        const modal = document.querySelector('#modalApproveRemakeForOT');
        const btn = document.querySelector('#btnActionModalRemakeOT');
        return {
          modalClass: modal ? modal.className : null,
          btnVisible: btn ? btn.offsetParent !== null : false,
          btnText: btn ? btn.innerText : null
        };
      });
      console.log('Modal info:', modalInfo);
      await page.screenshot({ path: 'test-evidence/debug_ot_modal.png' });

      const confirmBtn = page.locator('#btnActionModalRemakeOT').first();
      console.log('confirmBtn isVisible:', await confirmBtn.isVisible());
      if (await confirmBtn.isVisible()) {
        await confirmBtn.click();
        await page.waitForTimeout(3000);
      }
    }
  }

  const dbResult = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${identityId}'`);
  console.log('DB result after approval attempt:', dbResult);

  await browser.close();
})();
