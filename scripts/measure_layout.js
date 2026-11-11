const { chromium } = require('playwright');

async function measureLayout() {
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
  await page.click('.open-lunchpad');
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const el = document.querySelector('.open-MnuKPI005');
    if (el) el.click();
  });
  await page.waitForTimeout(4000);

  // Apply the corrected styles directly to verify layout
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

  const getMetrics = async (w) => {
    await page.setViewportSize({ width: w, height: 900 });
    await page.waitForTimeout(1000);
    return await page.evaluate(() => {
      const tb = document.querySelector('#GridContentPost .dx-toolbar');
      const cFilter = tb.querySelector('.c-filter');
      const before = tb.querySelector('.dx-toolbar-before');
      const after = tb.querySelector('.dx-toolbar-after');
      const items = cFilter ? Array.from(cFilter.children).filter(c => c.offsetWidth > 0).map(c => {
        const r = c.getBoundingClientRect();
        return {
          text: (c.innerText || '').trim().split('\n')[0],
          x: Math.round(r.x),
          y: Math.round(r.y),
          w: Math.round(r.width),
          h: Math.round(r.height)
        };
      }) : [];
      const afterItems = after ? Array.from(after.children).map(c => {
        const r = c.getBoundingClientRect();
        return {
          text: (c.innerText || '').trim().split('\n')[0] || c.className,
          x: Math.round(r.x),
          y: Math.round(r.y),
          w: Math.round(r.width),
          h: Math.round(r.height)
        };
      }) : [];
      return {
        beforeRect: before ? { x: Math.round(before.getBoundingClientRect().x), y: Math.round(before.getBoundingClientRect().y), w: Math.round(before.getBoundingClientRect().w), h: Math.round(before.getBoundingClientRect().h) } : null,
        afterRect: after ? { x: Math.round(after.getBoundingClientRect().x), y: Math.round(after.getBoundingClientRect().y), w: Math.round(after.getBoundingClientRect().w), h: Math.round(after.getBoundingClientRect().h) } : null,
        filterItems: items,
        afterItems: afterItems
      };
    });
  };

  const m1440 = await getMetrics(1440);
  console.log('--- 1440px ---');
  console.log(JSON.stringify(m1440, null, 2));

  const m1200 = await getMetrics(1200);
  console.log('--- 1200px ---');
  console.log(JSON.stringify(m1200, null, 2));

  await browser.close();
}

measureLayout().catch(console.error);
