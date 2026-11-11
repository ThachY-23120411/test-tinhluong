const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  
  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  // Mở menu Quản lý đào tạo nếu đang đóng, hoặc click trực tiếp MnuSCR612
  console.log('Clicking MnuSCR612...');
  await page.evaluate(() => {
    if (typeof openMenu === 'function') {
      openMenu('MnuSCR612');
    } else {
      const el = document.querySelector('.open-MnuSCR612');
      if (el) el.click();
    }
  });

  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'scripts/live_opened_MnuSCR612.png' });
  console.log('Saved scripts/live_opened_MnuSCR612.png');

  // Lấy HTML content của tab active
  const tabContent = await page.evaluate(() => {
    const activeTab = document.querySelector('.tab-pane.active') || document.querySelector('#tab-content') || document.querySelector('.content-body');
    return activeTab ? activeTab.innerHTML.substring(0, 1000) : 'Not found';
  });

  console.log('Tab content preview:', tabContent);

  await browser.close();
}

main().catch(console.error);
