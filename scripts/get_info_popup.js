const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.locator('#username').fill('tai.dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(3000);
  const dock = page.locator('.open-MnuWPT000, .MnuWPT000').first();
  if (await dock.isVisible({ timeout: 5000 }).catch(() => false)) await dock.click();
  await page.locator('a:has-text("Xin bù công")').first().click();
  await page.waitForTimeout(3000);

  // Read current date and inputs
  const formHtml = await page.evaluate(() => {
    return document.querySelector('#AttDate') ? document.querySelector('#AttDate').parentElement.parentElement.outerHTML : 'NO ATTDATE';
  });
  console.log('FORM HTML SNIPPET:\n', formHtml.substring(0, 1000));

  await page.locator('#AttDate').fill('2026-10-25');
  await page.locator('#Note').fill('Test ly do hop le ngay 25-10');
  await page.locator('button:has-text("Đăng ký")').first().click();
  await page.waitForTimeout(1000);

  // Click Dong Y
  await page.locator('#vc-vu-confirm-popup .VC-Vu-btn-ok').first().click({ force: true });
  await page.waitForTimeout(2000);

  const infoPopup = await page.evaluate(() => {
    const el = document.querySelector('#vc-vu-info-popup');
    return el ? { innerHTML: el.innerHTML, innerText: el.innerText, display: window.getComputedStyle(el).display } : null;
  });
  console.log('INFO POPUP DETAILS:', JSON.stringify(infoPopup, null, 2));

  // Check network calls made or errors
  await page.screenshot({ path: 'scripts/info_popup_shot.png' });

  await browser.close();
})();
