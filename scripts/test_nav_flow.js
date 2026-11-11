const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(3000);

  // Test opening MnuWPT037 via clicking MnuWPT000 first, then sidebar
  console.log('Clicking button.open-MnuWPT000...');
  await page.click('button.open-MnuWPT000');
  await page.waitForTimeout(1500);

  const sidebarItems = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('#sidebar a, .sidebar a, .sidebar-nav a, a[onclick*="OpenAppInSidebar"]')).map(a => ({
      text: a.innerText.trim(),
      onclick: a.getAttribute('onclick')
    }));
  });
  console.log('WPT Sidebar items:', JSON.stringify(sidebarItems, null, 2));

  await browser.close();
})();
