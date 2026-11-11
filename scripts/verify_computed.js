const { chromium } = require('playwright');

async function inspectComputed() {
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

  // Apply the 3 fixes to DOM
  await page.evaluate(() => {
    // 1. Hide resetBtn
    const resetBtn = document.querySelector('#cFilterResetBtn');
    if (resetBtn) resetBtn.style.setProperty('display', 'none', 'important');

    // 2. Style date inputs to match dark theme
    const dateInputs = document.querySelectorAll('.c-filter input[type="date"]');
    dateInputs.forEach(inp => {
      inp.style.setProperty('background-color', '#1e293b', 'important');
      inp.style.setProperty('border', '1px solid #334155', 'important');
      inp.style.setProperty('color', '#ffffff', 'important');
      inp.style.setProperty('color-scheme', 'dark', 'important');
    });

    // 3. Style search panel & placeholder & shift left
    const searchPanel = document.querySelector('#GridContentPost .dx-datagrid-search-panel');
    if (searchPanel) {
      searchPanel.style.setProperty('margin-right', '16px', 'important');
    }
    const tbAfter = document.querySelector('#GridContentPost .dx-toolbar-after');
    if (tbAfter) {
      tbAfter.style.setProperty('padding-right', '16px', 'important');
    }
    const searchInput = document.querySelector('#GridContentPost .dx-datagrid-search-panel input');
    if (searchInput) {
      searchInput.style.removeProperty('-webkit-text-fill-color');
    }
    const ph = document.querySelector('#GridContentPost .dx-datagrid-search-panel .dx-placeholder');
    if (ph) {
      ph.style.setProperty('color', '#94a3b8', 'important');
      ph.style.setProperty('-webkit-text-fill-color', '#94a3b8', 'important');
    }
  });

  const check = await page.evaluate(() => {
    const dateInput = document.querySelector('.c-filter input[type="date"]');
    const resetBtn = document.querySelector('#cFilterResetBtn');
    const searchPanel = document.querySelector('#GridContentPost .dx-datagrid-search-panel');
    const ph = document.querySelector('#GridContentPost .dx-datagrid-search-panel .dx-placeholder');
    const gridBox = document.querySelector('#GridContentPost').getBoundingClientRect();
    const searchBox = searchPanel ? searchPanel.getBoundingClientRect() : null;

    return {
      dateInputBg: dateInput ? window.getComputedStyle(dateInput).backgroundColor : null,
      dateInputBorder: dateInput ? window.getComputedStyle(dateInput).borderColor : null,
      dateInputColor: dateInput ? window.getComputedStyle(dateInput).color : null,
      resetBtnDisplay: resetBtn ? window.getComputedStyle(resetBtn).display : null,
      searchRightGapToGridEdge: searchBox ? Math.round(gridBox.right - searchBox.right) : null,
      placeholderColor: ph ? window.getComputedStyle(ph).color : null,
      placeholderFill: ph ? window.getComputedStyle(ph).webkitTextFillColor : null
    };
  });

  console.log('Verification Check:', JSON.stringify(check, null, 2));
  await browser.close();
}

inspectComputed().catch(console.error);
