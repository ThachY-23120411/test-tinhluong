const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

test.describe('Kiểm thử Đăng nhập Paradise HRM', () => {
  test.beforeEach(async ({ context }) => {
    // Nhúng con trỏ chuột Neon trực quan để người dùng theo dõi livestream
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
  });

  test('TC-01: Đăng nhập thành công với tài khoản Chien.nguyen', async ({ page }) => {
    // 1. Mở trang web
    console.log('🌐 1. Mở website: https://paradisehrm.com/Tai3/#');
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);

    // 2. Di chuột đến ô Tên đăng nhập và click
    const userInput = page.locator('#username');
    await expect(userInput).toBeVisible({ timeout: 15000 });
    console.log('👉 2. Di chuyển chuột đến ô Tên đăng nhập...');
    await userInput.click();

    // 3. Gõ từng ký tự với độ trễ để quan sát trực quan
    console.log('⌨️ 3. Nhập Tên đăng nhập: Chien.nguyen (pressSequentially)');
    await userInput.fill('');
    await userInput.pressSequentially('Chien.nguyen', { delay: 150 });
    await page.waitForTimeout(400);

    // 4. Di chuột đến ô Mật khẩu và click
    const passInput = page.locator('input[type="password"]');
    await expect(passInput).toBeVisible();
    console.log('👉 4. Di chuyển chuột đến ô Mật khẩu...');
    await passInput.click();

    // 5. Gõ từng ký tự mật khẩu
    console.log('⌨️ 5. Nhập Mật khẩu: 123 (pressSequentially)');
    await passInput.fill('');
    await passInput.pressSequentially('123', { delay: 150 });
    await page.waitForTimeout(400);

    // 6. Click nút Đăng nhập
    const loginBtn = page.locator('#submitLogin');
    await expect(loginBtn).toBeVisible();
    console.log('👉 6. Di chuyển chuột đến nút "Đăng nhập" và click...');
    
    // Đợi phản hồi điều hướng sau khi submit
    await Promise.all([
      page.waitForNavigation({ timeout: 20000 }).catch(() => {}),
      loginBtn.click()
    ]);

    console.log('⏳ 7. Chờ bảng điều khiển nạp dữ liệu...');
    await page.waitForTimeout(5000);

    // Chụp ảnh bằng chứng
    const ss1 = 'test-evidence/login/TC-01/screenshots/TC-01-dashboard.png';
    fs.mkdirSync(path.dirname(ss1), { recursive: true });
    await page.screenshot({ path: ss1, fullPage: false });

    // 8. Kiểm tra trạng thái đã đăng nhập
    const isAppLoaded = await page.evaluate(() => {
      return (typeof window.LoginID !== 'undefined' && window.LoginID !== null) ||
             (typeof window.UserID !== 'undefined' && window.UserID !== null) ||
             document.querySelector('#appapp') !== null;
    });

    console.log(`✅ Kết quả: Đăng nhập thành công (isAppLoaded = ${isAppLoaded})`);
    expect(isAppLoaded).toBeTruthy();
  });

  test('TC-02: Đăng nhập thất bại khi nhập sai mật khẩu', async ({ page }) => {
    console.log('🌐 1. Mở website: https://paradisehrm.com/Tai3/#');
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1000);

    // 2. Nhập username hợp lệ
    const userInput = page.locator('#username');
    await expect(userInput).toBeVisible({ timeout: 15000 });
    console.log('👉 2. Nhập Tên đăng nhập: Chien.nguyen');
    await userInput.fill('');
    await userInput.pressSequentially('Chien.nguyen', { delay: 100 });

    // 3. Nhập mật khẩu sai
    const passInput = page.locator('input[type="password"]');
    console.log('👉 3. Nhập Mật khẩu sai: wrong_pass_123');
    await passInput.fill('');
    await passInput.pressSequentially('wrong_pass_123', { delay: 100 });

    // 4. Bấm đăng nhập
    const loginBtn = page.locator('#submitLogin');
    console.log('👉 4. Bấm Đăng nhập...');
    await loginBtn.click();
    await page.waitForTimeout(3000);

    // 5. Chụp ảnh bằng chứng
    const ss2 = 'test-evidence/login/TC-02/screenshots/TC-02-wrong-password.png';
    fs.mkdirSync(path.dirname(ss2), { recursive: true });
    await page.screenshot({ path: ss2, fullPage: false });

    // 6. Kiểm tra: Hệ thống chặn không cho vào trong (vẫn ở màn hình đăng nhập)
    const isStillOnLogin = await userInput.isVisible();
    console.log(`✅ Kết quả: Hệ thống chặn đăng nhập khi sai mật khẩu (isStillOnLogin = ${isStillOnLogin})`);
    expect(isStillOnLogin).toBeTruthy();
  });
});

