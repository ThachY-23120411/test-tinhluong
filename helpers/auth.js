const fs = require('fs');
const path = require('path');

/**
 * Đọc cấu hình website và tài khoản từ test.env.json
 */
function getEnvConfig() {
  const envPath = path.resolve(__dirname, '../test.env.json');
  if (fs.existsSync(envPath)) {
    try {
      return JSON.parse(fs.readFileSync(envPath, 'utf8'));
    } catch (_) {}
  }
  return {
    baseUrl: 'https://paradisehrm.com/Tai3/#',
    auth: {
      username: 'Chien.nguyen',
      password: '123',
      usernameSelector: '#username',
      passwordSelector: 'input[type="password"]',
      submitSelector: '#submitLogin'
    }
  };
}

/**
 * Trợ lý Đăng nhập Tự động đa năng cho bất kỳ website nào
 */
async function loginAsAdmin(page, customCredentials = null) {
  const config = getEnvConfig();
  const credentials = customCredentials || config.auth;
  const targetUrl = config.baseUrl;
  const AUTH_FILE = path.resolve(__dirname, '../.auth/storageState.json');

  const currentUrl = page.url();
  if (!currentUrl.includes(targetUrl.replace(/^https?:\/\//, '').split('/')[0])) {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
  }

  // Dismiss any lingering overlay/popup
  const okBtn = page.locator('.VC-Vu-btn-ok:visible, .vc-btn-ok:visible').first();
  if (await okBtn.isVisible().catch(() => false)) {
    await okBtn.click({ force: true, timeout: 2000 }).catch(() => {});
    await page.waitForTimeout(500);
  }

  // Chờ 1 trong 2 xuất hiện: hoặc là .dock/.navbar (đã đăng nhập), hoặc là ô nhập login (chưa đăng nhập)
  const userSelector = credentials.usernameSelector || '#username';
  const readyElement = await Promise.race([
    page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 15000 }).then(() => 'dock').catch(() => null),
    page.locator(userSelector).first().waitFor({ state: 'visible', timeout: 15000 }).then(() => 'login').catch(() => null)
  ]);

  if (readyElement === 'dock') {
    console.log('⚡ [AUTH]: Phiên làm việc (Token/Cookies) hợp lệ. Bỏ qua màn hình đăng nhập, vào thẳng chức năng!');
    return;
  }

  // Nếu hiện ô login, tiến hành nhập thông tin
  const userInput = page.locator(userSelector).first();
  await userInput.waitFor({ state: 'visible', timeout: 8000 }).catch(() => {});

  if (await userInput.isVisible().catch(() => false)) {
    console.log(`🔑 [AUTH]: Thực hiện đăng nhập với tài khoản ${credentials.username}...`);
    await userInput.click();
    await userInput.fill('');
    await userInput.pressSequentially(credentials.username, { delay: 35 });
    await page.waitForTimeout(300);

    const passSelector = credentials.passwordSelector || 'input[type="password"]';
    const passInput = page.locator(passSelector).first();
    await passInput.click();
    await passInput.fill('');
    await passInput.pressSequentially(credentials.password, { delay: 35 });
    await page.waitForTimeout(300);

    const submitSelector = credentials.submitSelector || '#submitLogin';
    const submitBtn = page.locator(submitSelector).first();
    await submitBtn.click();

    // Dismiss any modal popup that might block after login submit
    await page.waitForTimeout(1000);
    const okBtnAfter = page.locator('.VC-Vu-btn-ok:visible, .vc-btn-ok:visible, .modal .btn-primary:visible').first();
    if (await okBtnAfter.isVisible().catch(() => false)) {
      await okBtnAfter.click({ force: true, timeout: 2000 }).catch(() => {});
    }

    // Chờ dock hoặc menu xuất hiện với thời gian chờ an toàn
    const dockNav = page.locator('.dock, .navbar').first();
    const hasDock = await dockNav.waitFor({ state: 'visible', timeout: 15000 }).then(() => true).catch(() => false);
    if (!hasDock) {
      await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
      await dockNav.waitFor({ state: 'visible', timeout: 20000 }).catch(() => {});
    }
    await page.waitForTimeout(1500);

    // Lưu phiên đăng nhập (Cookies, Token, LocalStorage) vào file
    try {
      fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });
      await page.context().storageState({ path: AUTH_FILE });
      console.log(`💾 [AUTH]: Đã lưu phiên đăng nhập (storageState) vào ${AUTH_FILE}. Lần sau sẽ vào thẳng không cần đăng nhập!`);
    } catch (e) {
      console.log('⚠️ [AUTH]: Không thể lưu storageState:', e.message);
    }
  } else {
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  }
}

module.exports = { loginAsAdmin, getEnvConfig };
