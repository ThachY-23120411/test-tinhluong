const { chromium } = require('playwright');
const { query } = require('../helpers/db');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: false, slowMo: 100 });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(3000);

  // Click MnuWPT316
  const dockBtn = page.locator('button.open-MnuWPT316, button.MnuWPT316').first();
  await dockBtn.click();
  await page.waitForTimeout(2000);

  // Let's set a date that has not been registered yet: 2026-10-22
  console.log('Selecting new date...');
  await page.evaluate(() => {
    const dateBox = $('#qlrl-dxOTFromDate').dxDateBox('instance');
    if (dateBox) {
      dateBox.option('value', new Date(2026, 9, 22)); // Month is 0-indexed, so 9 is Oct
    }
  });
  await page.waitForTimeout(1500);

  const isTextareaDisabled = await page.locator('#qlrl-NoteOT').isDisabled();
  console.log('Is NoteOT disabled after changing date:', isTextareaDisabled);

  if (!isTextareaDisabled) {
    await page.fill('#qlrl-NoteOT', 'OT kiem thu tu dong 22/10/2026');
    await page.click('#btnAddRequestOT');
    await page.waitForTimeout(1000);
    console.log('Clicked Add, check grid rows...');
    const gridRows = await page.locator('#appapp table.dx-datagrid-table tbody tr').count();
    console.log('Grid rows:', gridRows);
  }

  await browser.close();
})();
