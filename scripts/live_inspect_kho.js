const { chromium } = require('playwright');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

async function liveInspect() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Open MnuKPI019
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('MnuKPI019');
    }
  });

  await page.waitForSelector('#gridInventoryImport', { timeout: 15000 });
  await page.waitForTimeout(3000);

  // 1. Check initial state
  const state1 = await page.evaluate(() => {
    const rows = Array.from(document.querySelectorAll('#gridInventoryImport .dx-datagrid-rowsview .dx-data-row')).map(r => r.innerText.replace(/\t/g, ' | '));
    const isViewAll = document.querySelector('.toolbar-view-all')?.checked;
    const onlyUser = document.querySelector('.toolbar-only-user')?.checked;
    const empVal = window.InstanceEmployeeIDSelectedEmployeesp_CRM_CustomerList?.option('value');
    return { rowsCount: rows.length, rowsPreview: rows.slice(0, 3), isViewAll, onlyUser, empVal };
  });
  console.log('--- Initial State ---', state1);

  // 2. Uncheck "Xem tất cả" (so date filter applies: 01/10/2026 - 31/10/2026)
  await page.click('.toolbar-view-all');
  await page.waitForTimeout(2000);

  const state2 = await page.evaluate(() => {
    const rows = Array.from(document.querySelectorAll('#gridInventoryImport .dx-datagrid-rowsview .dx-data-row')).map(r => r.innerText.replace(/\t/g, ' | '));
    const isViewAll = document.querySelector('.toolbar-view-all')?.checked;
    return { rowsCount: rows.length, isViewAll, msg: 'Unchecked Xem tất cả -> October range applies' };
  });
  console.log('--- After unchecking Xem tat ca ---', state2);

  // 3. Set FromDate to 01/01/2026 in the datebox
  await page.evaluate(() => {
    const fromInstance = $('.filter-from-date').dxDateBox('instance');
    fromInstance.option('value', new Date(2026, 0, 1)); // 01/01/2026
  });
  await page.click('.btn-add-inventory:has-text("Tìm kiếm")');
  await page.waitForTimeout(2000);

  const state3 = await page.evaluate(() => {
    const rows = Array.from(document.querySelectorAll('#gridInventoryImport .dx-datagrid-rowsview .dx-data-row')).map(r => r.innerText.replace(/\t/g, ' | '));
    return { rowsCount: rows.length, rowsPreview: rows.slice(0, 5), msg: 'FromDate changed to 01/01/2026' };
  });
  console.log('--- After setting FromDate to 01/01/2026 ---', state3);

  // 4. Now test "Chỉ xem của tôi" with FromDate = 01/01/2026
  await page.click('.toolbar-only-user');
  await page.waitForTimeout(2000);

  const state4 = await page.evaluate(() => {
    const rows = Array.from(document.querySelectorAll('#gridInventoryImport .dx-datagrid-rowsview .dx-data-row')).map(r => r.innerText.replace(/\t/g, ' | '));
    const empVal = window.InstanceEmployeeIDSelectedEmployeesp_CRM_CustomerList?.option('value');
    return { rowsCount: rows.length, rowsPreview: rows, empVal, msg: 'Checked Chi xem cua toi with FromDate=01/01/2026' };
  });
  console.log('--- Chi xem cua toi with FromDate=01/01/2026 ---', state4);

  await browser.close();
}

liveInspect().catch(console.error);
