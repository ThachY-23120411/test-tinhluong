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

  const currentUrl = page.url();
  if (!currentUrl.includes(targetUrl.replace(/^https?:\/\//, '').split('/')[0])) {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);
  }

  // Kiểm tra xem đã đăng nhập chưa
  const isAlreadyLoggedIn = await page.evaluate(() => {
    return (typeof window.LoginID !== 'undefined' && window.LoginID !== null) ||
           (document.querySelector('.dock') !== null && !document.querySelector('#username'));
  });

const AUTH_FILE = path.resolve(__dirname, '../.auth/storageState.json');

  if (isAlreadyLoggedIn) {
    console.log('⚡ [AUTH]: Phiên làm việc (Token/Cookies) hợp lệ từ storageState. Bỏ qua màn hình đăng nhập, vào thẳng chức năng!');
    return;
  }

  // Nếu chưa đăng nhập, tiến hành đăng nhập trực quan và lưu lại storageState
  const userSelector = credentials.usernameSelector || '#username';
  const passSelector = credentials.passwordSelector || 'input[type="password"]';
  const submitSelector = credentials.submitSelector || '#submitLogin';

  const userInput = page.locator(userSelector);
  if (await userInput.isVisible({ timeout: 5000 }).catch(() => false)) {
    console.log(`🔑 [AUTH]: Thực hiện đăng nhập lần đầu với tài khoản ${credentials.username}...`);
    await userInput.click();
    await userInput.fill(credentials.username);
    await page.waitForTimeout(200);

    const passInput = page.locator(passSelector);
    await passInput.click();
    await passInput.fill(credentials.password);
    await page.waitForTimeout(200);

    const submitBtn = page.locator(submitSelector);
    await submitBtn.click();

    // Chờ dock hoặc menu xuất hiện
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
    await page.waitForTimeout(2000);

    // Lưu phiên đăng nhập (Cookies, Token, LocalStorage) vào file để các lần test sau không phải đăng nhập lại
    try {
      fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });
      await page.context().storageState({ path: AUTH_FILE });
      console.log(`💾 [AUTH]: Đã lưu phiên đăng nhập (storageState) vào ${AUTH_FILE}. Lần sau sẽ vào thẳng không cần đăng nhập!`);
    } catch (e) {
      console.log('⚠️ [AUTH]: Không thể lưu storageState:', e.message);
    }
  }
}

module.exports = { loginAsAdmin, getEnvConfig };
