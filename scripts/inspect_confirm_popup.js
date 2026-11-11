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

  const card = page.locator('.getcardregisteredOA[data-value="01A1A773-EE5B-743E-9EA5-9301674793A4" i]').first();
  if (await card.isVisible()) {
    await card.click();
    await page.waitForTimeout(3000);

    const approveLeaveBtn = page.locator('#dynamic-pane-MnuWPT315 .btnApprove, #sp_ResignationLeave .btnApprove').first();
    await approveLeaveBtn.click();
    await page.waitForTimeout(1500);

    // Inspect the entire popup container
    const popupText = await page.evaluate(() => {
      const popups = document.querySelectorAll('.modal.show, .swal2-modal, [class*="popup" i], [id*="popup" i]');
      return Array.from(popups).map(p => ({
        id: p.id,
        className: p.className,
        text: p.innerText
      }));
    });
    console.log('Popup containers:', JSON.stringify(popupText, null, 2));
  }

  await browser.close();
})();
