const { chromium } = require('playwright');

const ACCOUNTS = [
  { username: 'tai.dang', password: '123' },
  { username: 'ThanhLong', password: '123' },
  { username: 'cuong.vu', password: '123' },
  { username: 'chien.nguyen', password: '123' }
];

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });

  for (const acc of ACCOUNTS) {
    const page = await browser.newPage();
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
    await page.locator('#username').fill(acc.username);
    await page.locator('input[type="password"]').fill(acc.password);
    await page.locator('#submitLogin').click();
    await page.waitForTimeout(3000);

    // Lấy tất cả text trên toàn bộ trang
    const result = await page.evaluate(() => {
      const allText = document.body.innerText;
      const hasPheDuyet = allText.includes('Danh sách phê duyệt');
      const tabs = Array.from(document.querySelectorAll('.dock button, .sidebar a, .sidebar span')).map(el => (el.innerText || el.title || el.className).trim()).filter(Boolean);
      return { hasPheDuyet, tabsCount: tabs.length, sampleTabs: tabs.slice(0, 10) };
    });

    console.log(`👤 Tài khoản ${acc.username}: hasPheDuyet = ${result.hasPheDuyet}`);
    await page.close();
  }

  await browser.close();
})();
