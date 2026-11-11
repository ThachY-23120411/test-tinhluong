const { chromium } = require('playwright');

async function measure1024() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1024, height: 900 } });
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  if (await page.locator('#username').isVisible()) {
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuKPI005');
    if (el) el.click();
  });
  await page.waitForTimeout(4000);
  await page.evaluate(() => {
    const cFilter = document.querySelector('.c-filter');
    if (cFilter) {
      cFilter.style.display = 'flex';
      cFilter.style.flexDirection = 'row';
      cFilter.style.alignItems = 'center';
      cFilter.style.gap = '8px';
      cFilter.style.flexWrap = 'wrap';
      cFilter.style.width = 'auto';
    }
    const tbBefore = document.querySelector('#GridContentPost .dx-toolbar-before');
    if (tbBefore) {
      tbBefore.style.display = 'flex';
      tbBefore.style.flexWrap = 'wrap';
      tbBefore.style.alignItems = 'center';
    }
  });
  await page.waitForTimeout(1000);
  const items = await page.evaluate(() => {
    const cFilter = document.querySelector('.c-filter');
    return Array.from(cFilter.children).filter(c => c.offsetWidth > 0).map(c => ({
      text: (c.innerText || '').trim().split('\n')[0],
      x: Math.round(c.getBoundingClientRect().x),
      y: Math.round(c.getBoundingClientRect().y),
      w: Math.round(c.getBoundingClientRect().width),
      h: Math.round(c.getBoundingClientRect().height)
    }));
  });
  console.log('1024px filter items:');
  console.log(JSON.stringify(items, null, 2));
  await browser.close();
}

measure1024().catch(console.error);
