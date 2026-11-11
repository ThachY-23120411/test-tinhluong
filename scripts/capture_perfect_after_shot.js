const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function capturePerfectShots() {
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

  // Apply the corrected styles directly
  await page.evaluate(() => {
    const cFilter = document.querySelector('.c-filter');
    if (cFilter) {
      cFilter.style.display = 'flex';
      cFilter.style.flexDirection = 'row';
      cFilter.style.alignItems = 'center';
      cFilter.style.gap = '8px';
      cFilter.style.flexWrap = 'wrap';
      cFilter.style.width = 'auto';
      cFilter.style.margin = '0';
      cFilter.style.padding = '0';
    }
    const tbBefore = document.querySelector('#GridContentPost .dx-toolbar-before');
    if (tbBefore) {
      tbBefore.style.display = 'flex';
      tbBefore.style.flexWrap = 'wrap';
      tbBefore.style.alignItems = 'center';
      tbBefore.style.gap = '8px';
    }
    const tbAfter = document.querySelector('#GridContentPost .dx-toolbar-after');
    if (tbAfter) {
      tbAfter.style.display = 'flex';
      tbAfter.style.flexWrap = 'wrap';
      tbAfter.style.alignItems = 'center';
      tbAfter.style.gap = '8px';
    }
    const items = document.querySelectorAll('.c-filter label');
    items.forEach(lbl => {
      lbl.style.display = 'inline-block';
      lbl.style.margin = '0';
      lbl.style.whiteSpace = 'nowrap';
    });
  });

  await page.waitForTimeout(1500);

  const outDir = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/screenshot');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  // 1440px desktop
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after.png') });
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after-desktop.png') });
  console.log('Saved 1440px desktop shot.');

  // Component crop
  const comp = await page.$('#contentComponent');
  if (comp) {
    await comp.screenshot({ path: path.join(outDir, 'screenshot-27-after-crop.png') });
    console.log('Saved component crop.');
  }

  // 1200px responsive
  await page.setViewportSize({ width: 1200, height: 900 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after-responsive-1200.png') });
  console.log('Saved 1200px shot.');

  // 992px responsive
  await page.setViewportSize({ width: 992, height: 900 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(outDir, 'screenshot-27-after-responsive-992.png') });
  console.log('Saved 992px shot.');

  await browser.close();
}

capturePerfectShots().catch(console.error);
