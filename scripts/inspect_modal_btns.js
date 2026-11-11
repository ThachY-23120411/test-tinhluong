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

  // Click btnApprove
  await page.evaluate(() => {
    document.querySelectorAll('form').forEach(f => { f.onsubmit = e => { e.preventDefault(); return false; }; });
    document.querySelectorAll('button:not([type])').forEach(b => b.setAttribute('type', 'button'));
  });

  const approveBtn = page.locator('#sp_Overtime_Assignment .btnApprove').first();
  await approveBtn.click();
  await page.waitForTimeout(1000);

  const btnDetails = await page.evaluate(() => {
    const modal = document.querySelector('#modalApproveRemakeForOT');
    if (!modal) return null;
    return Array.from(modal.querySelectorAll('button')).map(b => ({
      id: b.id,
      text: b.innerText.trim(),
      className: b.className,
      rect: b.getBoundingClientRect()
    }));
  });
  console.log('Button details inside modalApproveRemakeForOT:', btnDetails);

  await browser.close();
})();
