const { chromium } = require('playwright');

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

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037, button.open-MnuWPT037, button[onclick*="MnuWPT037"]').first();
  await dockBtn.click();
  await page.waitForTimeout(2500);

  // Check what cards exist
  const card = page.locator('.getcardregisteredOA').first();
  if (await card.isVisible()) {
    console.log('Clicking first card...');
    await card.click();
    await page.waitForTimeout(3000);

    const approveOtBtn = page.locator('#sp_Overtime_Assignment .btnApprove').first();
    console.log('Approve btn visible:', await approveOtBtn.isVisible());
    if (await approveOtBtn.isVisible()) {
      await approveOtBtn.click();
      await page.waitForTimeout(1500);

      const confirmBtn = page.locator('#btnActionModalRemakeOT').first();
      console.log('Confirm modal btn visible:', await confirmBtn.isVisible());
      if (await confirmBtn.isVisible()) {
        await confirmBtn.click();
        await page.waitForTimeout(3000);

        // Check active tab and visible elements right after approval
        const afterState = await page.evaluate(() => {
          const activeTab = document.querySelector('.nav-tabs .nav-link.active, .nav-tabs button.active');
          const visiblePanes = Array.from(document.querySelectorAll('.tab-pane.active, .tab-pane.show')).map(p => ({
            id: p.id,
            className: p.className
          }));
          return {
            activeTab: activeTab ? activeTab.innerText.trim() : null,
            visiblePanes
          };
        });
        console.log('After state:', JSON.stringify(afterState, null, 2));

        await page.screenshot({ path: 'test-evidence/after_ot_approval_screen.png' });
      }
    }
  }

  await browser.close();
})();
