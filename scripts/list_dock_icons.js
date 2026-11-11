const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  const icons = await page.evaluate(() => {
    // Find all icons in the dock
    const dockEl = document.querySelector('.dock') || document.querySelector('#dock') || document.body;
    return Array.from(document.querySelectorAll('.dock button, .dock a, .dock .icon, [class*="open-Mnu"]')).map(el => ({
      class: el.className,
      title: el.getAttribute('title') || '',
      id: el.id,
      text: el.innerText.trim(),
      html: el.outerHTML.slice(0, 150)
    }));
  });

  console.log('Dock icons full list:');
  console.log(JSON.stringify(icons, null, 2));
  await browser.close();
})();
