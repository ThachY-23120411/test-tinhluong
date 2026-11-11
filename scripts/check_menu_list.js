const { chromium } = require('playwright');

async function checkMenuList() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  const menus = await page.evaluate(() => {
    const list = [];
    const mc = window.MenuClient || [];
    const lmc = window.LeftMenuClient || [];
    return {
      MenuClientCount: mc.length,
      LeftMenuClientCount: lmc.length,
      sampleLeft: lmc.slice(0, 15).map(m => ({ id: m.id || m.MenuID, name: m.name || m.MenuName, className: m.className })),
      sampleMenu: mc.slice(0, 15).map(m => ({ id: m.id || m.MenuID, name: m.name || m.MenuName, className: m.className }))
    };
  });

  console.log('Menus result:', JSON.stringify(menus, null, 2));
  await browser.close();
}

checkMenuList().catch(console.error);
