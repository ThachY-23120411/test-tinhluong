const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Click MnuWPT315
  const dockBtn = page.locator('.dock button.open-MnuWPT315, .dock button.MnuWPT315').first();
  await dockBtn.click();
  await page.waitForTimeout(3000);

  // Fill form
  await page.evaluate(() => {
    try {
      const fromBox = $('#LeaveFromDate').dxDateBox('instance');
      if (fromBox) fromBox.option('value', new Date('2026-12-02T08:00:00'));
      const toBox = $('#LeaveToDate').dxDateBox('instance');
      if (toBox) toBox.option('value', new Date('2026-12-02T12:00:00'));
      const el = document.getElementById('lyDo');
      if (el) {
        el.value = 'Nghỉ việc riêng kiểm thử debug';
        el.dispatchEvent(new Event('input', { bubbles: true }));
        el.dispatchEvent(new Event('change', { bubbles: true }));
      }
    } catch (_) {}
  });
  await page.waitForTimeout(1000);

  // Click Submit
  const submitBtn = page.locator('#sp_ResignationLeave .btnRegister').first();
  console.log('Submit button visible?', await submitBtn.isVisible());
  await submitBtn.click();
  await page.waitForTimeout(1500);

  // Check confirm popup elements
  const popupInfo = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button')).map(b => ({
      text: b.innerText.trim(),
      id: b.id,
      className: b.className,
      rect: b.getBoundingClientRect(),
      visible: b.offsetParent !== null
    })).filter(b => b.visible && (b.text === 'Đồng ý' || b.text === 'Hủy' || b.text.includes('Yes')));
    return btns;
  });
  console.log('Confirm buttons found:', popupInfo);

  // Try clicking Đồng ý via evaluate
  const clickRes = await page.evaluate(() => {
    const btn = Array.from(document.querySelectorAll('button')).find(b => b.innerText.trim() === 'Đồng ý');
    if (btn) {
      console.log('Clicking Đồng ý button:', btn);
      btn.click();
      return true;
    }
    return false;
  });
  console.log('Clicked Đồng ý?', clickRes);
  await page.waitForTimeout(3000);

  // Check if popup closed or error shown
  const statusAfter = await page.evaluate(() => {
    return {
      alerts: Array.from(document.querySelectorAll('.swal2-title, .ui-manager-alert, .toast, .alert, .validate_error_date')).map(el => el.innerText.trim()),
      modals: Array.from(document.querySelectorAll('.modal.show, .swal2-show')).map(el => el.innerText.trim().slice(0, 100))
    };
  });
  console.log('Status after clicking Đồng ý:', statusAfter);

  await browser.close();
})();
