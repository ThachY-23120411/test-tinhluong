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

  // Click on MnuWPT316 via dock button
  console.log('Moving to dock button MnuWPT316...');
  const dockBtn = page.locator('button.open-MnuWPT316, button.MnuWPT316').first();
  await dockBtn.waitFor({ state: 'visible', timeout: 5000 });
  await dockBtn.click();
  await page.waitForTimeout(2000);

  const otToken = `OT_${Date.now().toString().slice(-6)}`;
  const reason = `Lam them gio hoan thien du an ${otToken}`;

  console.log('Filling NoteOT...');
  const noteInput = page.locator('#qlrl-NoteOT').first();
  await noteInput.waitFor({ state: 'visible', timeout: 5000 });
  await noteInput.fill(reason);
  await page.waitForTimeout(500);

  console.log('Clicking btnAddRequestOT...');
  const addBtn = page.locator('#btnAddRequestOT').first();
  await addBtn.click();
  await page.waitForTimeout(1500);

  console.log('Clicking btnRegister...');
  const regBtn = page.locator('button.btnRegister').first();
  await regBtn.click();
  await page.waitForTimeout(1000);

  // Check confirm popup
  const confirmPopup = page.locator('#vc-vu-confirm-popup .VC-Vu-btn-ok').first();
  if (await confirmPopup.isVisible({ timeout: 4000 }).catch(() => false)) {
    console.log('Confirm popup appeared, clicking Dong y...');
    await confirmPopup.click();
    await page.waitForTimeout(2000);
  }

  // Check info popup
  const infoPopup = page.locator('#vc-vu-info-popup .VC-Vu-btn-ok').first();
  if (await infoPopup.isVisible({ timeout: 3000 }).catch(() => false)) {
    console.log('Info popup appeared, clicking OK...');
    await infoPopup.click();
    await page.waitForTimeout(1000);
  }

  console.log('Checking database...');
  const rows = query(`
    SELECT TOP 3 IdentityID, EmployeeID, OTDate, TotalHours, Note, Approve_Status
    FROM tblOvertime_Assignment 
    WHERE EmployeeID = '046'
    ORDER BY IdentityID DESC
  `);
  console.log('DB Overtime records:', JSON.stringify(rows, null, 2));

  await browser.close();
})();
