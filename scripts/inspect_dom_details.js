const { chromium } = require('playwright');

async function inspectDomDetails() {
  const browser = await chromium.launch({ headless: true, channel: 'chrome' });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(4000);

  // 1. Quản lý hợp đồng lao động
  await page.evaluate(() => {
    const el = document.querySelector('a:has-text("Quản lý hợp đồng"), [onclick*="MnuHRS151"]');
    if (el) el.click();
    else if (window.openApp) window.openApp('MnuHRS151');
  });
  await page.waitForTimeout(3000);

  // Check columns / tabs in MnuHRS151
  const contractInfo = await page.evaluate(() => {
    const tabs = Array.from(document.querySelectorAll('.nav-tabs a, .nav-tabs button, .tab-pane')).map(t => t.innerText.trim()).filter(Boolean);
    const headers = Array.from(document.querySelectorAll('th, .dx-header-row td')).map(h => h.innerText.trim()).filter(Boolean);
    const btns = Array.from(document.querySelectorAll('button, .btn')).map(b => b.innerText.trim()).filter(b => b && b.length < 40);
    return { tabs, headers: headers.slice(0, 20), btns: btns.slice(0, 20) };
  });
  console.log('--- CONTRACT INFO (MnuHRS151) ---');
  console.log(JSON.stringify(contractInfo, null, 2));

  // 2. Thông tin gia đình
  await page.evaluate(() => {
    if (window.openApp) window.openApp('MnuHRS157');
  });
  await page.waitForTimeout(3000);

  const familyInfo = await page.evaluate(() => {
    const tabs = Array.from(document.querySelectorAll('.nav-tabs a, .nav-tabs button')).map(t => t.innerText.trim()).filter(Boolean);
    const headers = Array.from(document.querySelectorAll('th, .dx-header-row td')).map(h => h.innerText.trim()).filter(Boolean);
    const btns = Array.from(document.querySelectorAll('button, .btn')).map(b => b.innerText.trim()).filter(b => b && b.length < 40);
    return { tabs, headers: headers.slice(0, 20), btns: btns.slice(0, 20) };
  });
  console.log('--- FAMILY INFO (MnuHRS157) ---');
  console.log(JSON.stringify(familyInfo, null, 2));

  // 3. Chấm công hàng ngày
  await page.evaluate(() => {
    if (window.openApp) window.openApp('MnuHRS225');
  });
  await page.waitForTimeout(3000);

  const dailyInfo = await page.evaluate(() => {
    const headers = Array.from(document.querySelectorAll('th, .dx-header-row td')).map(h => h.innerText.trim()).filter(Boolean);
    const filters = Array.from(document.querySelectorAll('input, select, label')).map(f => f.placeholder || f.innerText || f.id).filter(Boolean);
    return { headers: headers.slice(0, 20), filters: filters.slice(0, 20) };
  });
  console.log('--- DAILY ATTENDANCE (MnuHRS225) ---');
  console.log(JSON.stringify(dailyInfo, null, 2));

  // 4. Tổng hợp công cả tháng
  await page.evaluate(() => {
    if (window.openApp) window.openApp('MnuTAD1000');
  });
  await page.waitForTimeout(3000);

  const monthInfo = await page.evaluate(() => {
    const headers = Array.from(document.querySelectorAll('th, .dx-header-row td')).map(h => h.innerText.trim()).filter(Boolean);
    const btns = Array.from(document.querySelectorAll('button, .btn')).map(b => b.innerText.trim()).filter(b => b && b.length < 40);
    return { headers: headers.slice(0, 20), btns: btns.slice(0, 20) };
  });
  console.log('--- MONTHLY ATTENDANCE (MnuTAD1000) ---');
  console.log(JSON.stringify(monthInfo, null, 2));

  await browser.close();
}

inspectDomDetails().catch(console.error);
