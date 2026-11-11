const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  const dockBtn = page.locator('.dock button.open-MnuWPT037, .dock button.MnuWPT037').first();
  await dockBtn.click();
  await page.waitForTimeout(3000);

  const card = page.locator('.getcardregisteredOA[data-group="6"]').first();
  await card.click();
  await page.waitForTimeout(3000);

  // Check what click listener is on btnApprove
  const info = await page.evaluate(() => {
    const btn = document.querySelector('#sp_Overtime_Assignment .btnApprove');
    return {
      btnExists: !!btn,
      btnClass: btn ? btn.className : '',
      modals: Array.from(document.querySelectorAll('.modal')).map(m => ({ id: m.id, class: m.className }))
    };
  });
  console.log('Info before click:', info);

  // Click Duyệt
  await page.evaluate(() => {
    document.querySelectorAll('form').forEach(f => { f.onsubmit = e => { e.preventDefault(); return false; }; });
    document.querySelectorAll('button:not([type])').forEach(b => b.setAttribute('type', 'button'));
  });

  const approveBtn = page.locator('#sp_Overtime_Assignment .btnApprove').first();
  await approveBtn.click();
  await page.waitForTimeout(1000);

  const modalsAfter = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.modal, .swal2-container')).map(m => ({
      id: m.id,
      class: m.className,
      style: m.getAttribute('style'),
      visible: m.offsetParent !== null || m.classList.contains('show'),
      buttons: Array.from(m.querySelectorAll('button')).map(b => ({ text: b.innerText.trim(), id: b.id, class: b.className }))
    }));
  });
  console.log('Modals after click:', modalsAfter);

  await browser.close();
})();
