const { chromium } = require('playwright');
const fs = require('fs');

async function testGiftHistory() {
  console.log('🚀 Starting testGiftHistory...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  page.on('response', async res => {
    const url = res.url();
    if (url.includes('paradise') || url.includes('hpa')) {
      try {
        const text = await res.text();
        if (text.includes('hist_grid') || text.includes('sp_gift_history') || text.includes('TotalCoins')) {
          console.log(`\n📥 [NETWORK RESPONSE] ${url.substring(0, 100)}...`);
          console.log(`   Length: ${text.length}`);
          console.log(`   Has text-center: ${text.includes('text-center')}`);
          console.log(`   Has TotalCoins: ${text.includes('TotalCoins')}`);
        }
      } catch (e) {}
    }
  });

  console.log('1. Navigating to Paradise HRM...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  if (await page.locator('#username').isVisible().catch(() => false)) {
    console.log('2. Logging in...');
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  console.log('3. Clearing localStorage and reloading...');
  await page.evaluate(() => {
    localStorage.clear();
    location.reload();
  });
  await page.waitForLoadState('domcontentloaded');
  await page.waitForTimeout(3000);

  if (await page.locator('#username').isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log('2b. Logging in again...');
    await page.fill('#username', 'Chien.nguyen');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  console.log('4. Opening menu MnuPRL451 (Lịch sử đổi quà)...');
  await page.evaluate(() => {
    const el = document.querySelector('.icon.MnuPRL451, [class*="MnuPRL451"], a[href*="MnuPRL451"]');
    if (el) el.click();
    else if (typeof window.openMenu === 'function') window.openMenu('MnuPRL451');
  });

  console.log('5. Waiting for #hist_grid...');
  try {
    await page.waitForFunction(() => {
      const $grid = window.$ && window.$('#hist_grid');
      return $grid && $grid.length && $grid.find('.dx-datagrid-headers td').length > 0;
    }, { timeout: 15000 });
  } catch (e) {
    console.log('Warning waiting for grid:', e.message);
  }

  await page.waitForTimeout(3000);

  // Measure columns and cell alignments
  const gridInfo = await page.evaluate(() => {
    const headers = [];
    window.$('.dx-datagrid-headers .dx-header-row > td').each(function () {
      headers.push({
        text: window.$(this).text().trim(),
        width: window.$(this).outerWidth(),
        textAlign: window.$(this).css('text-align'),
        html: window.$(this).html()
      });
    });

    const firstRowCells = [];
    window.$('.dx-datagrid-rowsview .dx-data-row:first > td').each(function () {
      firstRowCells.push({
        text: window.$(this).text().trim(),
        width: window.$(this).outerWidth(),
        textAlign: window.$(this).css('text-align'),
        classes: window.$(this).attr('class'),
        html: window.$(this).html()
      });
    });

    return { headers, firstRowCells };
  });

  console.log('\n📊 Grid Headers Info:');
  console.log(JSON.stringify(gridInfo.headers, null, 2));

  console.log('\n📊 First Row Cells Info:');
  console.log(JSON.stringify(gridInfo.firstRowCells, null, 2));

  await page.screenshot({ path: 'scripts/live_gift_history_check.png' });
  console.log('\n📸 Screenshot saved to scripts/live_gift_history_check.png');

  await browser.close();
}

testGiftHistory().catch(err => {
  console.error('Test error:', err);
  process.exit(1);
});
