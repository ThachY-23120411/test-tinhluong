const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function inspectScreen(menuCode, menuName, actionFn) {
  console.log(`\n==================================================`);
  console.log(`OPENING SCREEN: ${menuCode} - ${menuName}`);
  console.log(`==================================================`);

  const browser = await chromium.launch({
    headless: true,
    channel: 'chrome',
    args: ['--window-size=1440,900']
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 }
  });

  const page = await context.newPage();
  const screenDir = path.resolve(__dirname, `../debug_screens/screens`);
  fs.mkdirSync(screenDir, { recursive: true });

  try {
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle', timeout: 45000 });
    await page.waitForTimeout(2000);

    // Login as cuong.vu
    const userInput = page.locator('#username, #txtUsername, input[name="username"]').first();
    if (await userInput.isVisible()) {
      await userInput.fill('cuong.vu');
      const passInput = page.locator('input[type="password"]').first();
      await passInput.fill('123');
      const submitBtn = page.locator('#submitLogin, #btnLogin, button[type="submit"]').first();
      await submitBtn.click();
      await page.waitForTimeout(3000);
    }

    console.log(`Opening menu ${menuCode}...`);
    await page.evaluate((code) => {
      if (typeof window.OpenAppInSidebar === 'function') {
        window.OpenAppInSidebar(code);
      } else if (typeof window.openTab === 'function') {
        window.openTab(code, code);
      }
    }, menuCode);

    await page.waitForTimeout(4000);
    const screenPath = path.join(screenDir, `${menuCode}_opened.png`);
    await page.screenshot({ path: screenPath });
    console.log(`Saved screenshot to ${screenPath}`);

    // If custom action
    if (actionFn) {
      await actionFn(page, screenDir, menuCode);
    }

  } catch (err) {
    console.error(`Error opening ${menuCode}:`, err);
  } finally {
    await browser.close();
  }
}

async function run() {
  // 1. MnuHRS151: Hợp đồng lao động
  await inspectScreen('MnuHRS151', 'Quản lý hợp đồng lao động', async (page, dir, code) => {
    // Search 046
    const search = page.locator('input[type="search"], .dx-texteditor-input, input[placeholder*="Tìm"], input[placeholder*="tìm"]').first();
    if (await search.isVisible()) {
      await search.fill('046');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(dir, `${code}_search_046.png`) });
    }
  });

  // 2. MnuHRS157: Thông tin gia đình
  await inspectScreen('MnuHRS157', 'Thông tin gia đình', async (page, dir, code) => {
    const search = page.locator('input[type="search"], .dx-texteditor-input, input[placeholder*="Tìm"], input[placeholder*="tìm"]').first();
    if (await search.isVisible()) {
      await search.fill('046');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(dir, `${code}_search_046.png`) });
    }
  });

  // 3. MnuHRS225: Xem dữ liệu chấm công hằng ngày
  await inspectScreen('MnuHRS225', 'Xem dữ liệu chấm công hằng ngày', async (page, dir, code) => {
    const search = page.locator('input[type="search"], .dx-texteditor-input, input[placeholder*="Tìm"], input[placeholder*="tìm"]').first();
    if (await search.isVisible()) {
      await search.fill('046');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(dir, `${code}_search_046.png`) });
    }
  });

  // 4. MnuHRS226: Tổng hợp công tháng
  await inspectScreen('MnuHRS226', 'Tổng hợp công tháng', async (page, dir, code) => {
    const search = page.locator('input[type="search"], .dx-texteditor-input, input[placeholder*="Tìm"], input[placeholder*="tìm"]').first();
    if (await search.isVisible()) {
      await search.fill('046');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(dir, `${code}_search_046.png`) });
    }
  });

  // 5. MnuHRS0102: Hồ sơ nhân viên
  await inspectScreen('MnuHRS0102', 'Hồ sơ nhân viên', async (page, dir, code) => {
    const search = page.locator('input[type="search"], .dx-texteditor-input, input[placeholder*="Tìm"], input[placeholder*="tìm"]').first();
    if (await search.isVisible()) {
      await search.fill('046');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(dir, `${code}_search_046.png`) });
    }
  });
}

run();
