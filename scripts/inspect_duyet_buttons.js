const { chromium } = require('playwright');

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

  const identityId = '01A1A77D-8D8F-791D-87DC-DB09C546ADD3';
  const card = page.locator(`.getcardregisteredOA[data-value="${identityId}" i]`).first();
  if (await card.isVisible()) {
    await card.click();
    await page.waitForTimeout(3000);

    const matches = await page.evaluate(() => {
      const sel = '#dynamic-pane-MnuWPT315 .btnApprove, #sp_ResignationLeave .btnApprove, button:has-text("Duyệt"):visible';
      const els = document.querySelectorAll('#dynamic-pane-MnuWPT315 .btnApprove, #sp_ResignationLeave .btnApprove, button');
      return Array.from(els).filter(e => e.innerText && e.innerText.includes('Duyệt') && e.offsetParent !== null).map(e => ({
        id: e.id,
        className: e.className,
        text: e.innerText.trim(),
        parent: e.parentElement ? e.parentElement.id || e.parentElement.className : null
      }));
    });
    console.log('Matching buttons:', JSON.stringify(matches, null, 2));
  }

  await browser.close();
})();
