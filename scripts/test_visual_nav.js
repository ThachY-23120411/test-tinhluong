const { chromium } = require('@playwright/test');

async function checkNavbar() {
  const browser = await chromium.launch({ headless: true, channel: 'chrome' });
  const page = await browser.newPage();
  
  await page.goto('https://paradisehrm.com/Tai3/', { waitUntil: 'domcontentloaded' });
  await page.locator('#username').fill('cuong.vu');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(3000);

  const items = await page.evaluate(() => {
    const els = Array.from(document.querySelectorAll('#ID-navbar-home *'));
    const res = [];
    for (const e of els) {
      const onclick = e.getAttribute('onclick');
      const title = e.getAttribute('title') || e.getAttribute('data-title');
      const text = (e.innerText || '').trim();
      const id = e.id || '';
      const cls = typeof e.className === 'string' ? e.className : '';
      if (onclick || title || id.includes('Mnu') || cls.includes('Mnu')) {
        res.push({
          tag: e.tagName,
          id,
          cls,
          onclick,
          title,
          text
        });
      }
    }
    return res;
  });

  console.log(`Navbar items with Mnu or onclick (${items.length}):`);
  console.log(JSON.stringify(items.slice(0, 30), null, 2));

  await browser.close();
}

checkNavbar().catch(console.error);
