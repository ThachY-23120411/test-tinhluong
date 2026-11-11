const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function capture() {
  const screenshotDir = path.resolve('fix-bug/crm_quan_ly_phan_he/screenshot');
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }

  const browser = await chromium.launch({
    headless: false,
    channel: 'chrome',
    args: ['--start-maximized', '--window-size=1440,900']
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 }
  });

  const page = await context.newPage();

  console.log('Navigating to login page...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle', timeout: 60000 });

  // Auto login if on login screen
  const loginInput = page.locator('#txtUsername, input[name="username"], #username');
  if (await loginInput.count() > 0 && await loginInput.first().isVisible()) {
    console.log('Logging in...');
    await loginInput.first().fill('admin');
    const pwdInput = page.locator('#txtPassword, input[name="password"], #password');
    if (await pwdInput.count() > 0) {
      await pwdInput.first().fill('123456');
    }
    const btnLogin = page.locator('#btnLogin, button[type="submit"], .btn-login');
    if (await btnLogin.count() > 0) {
      await btnLogin.first().click();
      await page.waitForTimeout(5000);
    }
  }

  console.log('Opening menu Quản lý phân hệ (sp_Sub_SubProduct)...');
  await page.evaluate(() => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar('sp_Sub_SubProduct');
    } else if (typeof window.openTab === 'function') {
      window.openTab('sp_Sub_SubProduct', 'Quản lý phân hệ');
    }
  });

  // Wait for grid to render
  console.log('Waiting for #gridSubProductList...');
  await page.waitForSelector('#gridSubProductList', { timeout: 30000 });
  await page.waitForTimeout(4000);

  // Take screenshot at Desktop (1440px)
  console.log('Capturing Desktop 1440px...');
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(screenshotDir, 'screenshot-33-after-1440px.png'), fullPage: false });

  // Take screenshot at Snap / Tablet (1024px)
  console.log('Capturing Snap 1024px...');
  await page.setViewportSize({ width: 1024, height: 900 });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(screenshotDir, 'screenshot-33-after-1024px.png'), fullPage: false });

  // Take screenshot at Responsive (768px)
  console.log('Capturing Responsive 768px...');
  await page.setViewportSize({ width: 768, height: 900 });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(screenshotDir, 'screenshot-after.png'), fullPage: false });
  await page.screenshot({ path: path.join(screenshotDir, 'screenshot-33-after-768px.png'), fullPage: false });

  // Measure DOM metrics
  const metrics = await page.evaluate(() => {
    const searchInput = document.querySelector('#gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input');
    const searchPanel = document.querySelector('#gridSubProductList .dx-datagrid-search-panel');
    const searchIcon = document.querySelector('#gridSubProductList .dx-datagrid-search-panel .dx-icon-search');
    const btnAdd = document.querySelector('#sp_Sub_SubProduct_html .btn-add-SubProduct');

    return {
      searchInputPaddingLeft: searchInput ? window.getComputedStyle(searchInput).paddingLeft : null,
      searchPanelWidth: searchPanel ? window.getComputedStyle(searchPanel).width : null,
      searchIconWidth: searchIcon ? window.getComputedStyle(searchIcon).width : null,
      btnAddVisible: btnAdd ? (btnAdd.offsetWidth > 0 && btnAdd.offsetHeight > 0) : false,
      btnText: btnAdd ? btnAdd.innerText.trim() : null
    };
  });

  console.log('DOM Metrics:', JSON.stringify(metrics, null, 2));

  await browser.close();
  console.log('Capture completed successfully!');
}

capture().catch(err => {
  console.error('Capture error:', err);
  process.exit(1);
});
