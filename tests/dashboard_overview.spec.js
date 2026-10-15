const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const { loginAsAdmin } = require('../helpers/auth');

test.describe('Kiểm thử Bảng điều khiển (Dashboard) Paradise HRM', () => {
  test.beforeEach(async ({ context, page }) => {
    // Nhúng con trỏ chuột Neon trực quan để người dùng theo dõi
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }

    // Đảm bảo phiên đăng nhập (tự động nạp Token/Cookies từ storageState)
    await loginAsAdmin(page);
  });

  test('TC-01: Kiểm tra nạp bảng điều khiển & Menu hệ thống', async ({ page }) => {
    console.log('⏳ 1. Chờ tải xong giao diện Dashboard chính...');
    await page.waitForTimeout(2000);

    // Chụp ảnh bằng chứng vào thư mục phân cấp
    const ssPath = 'test-evidence/dashboard_overview/TC-01/screenshots/TC-01-dashboard-menu.png';
    fs.mkdirSync(path.dirname(ssPath), { recursive: true });
    await page.screenshot({ path: ssPath, fullPage: false });

    // Kiểm tra các phần tử menu hoặc navbar
    const hasNavOrHeader = await page.evaluate(() => {
      return document.querySelector('.navbar') !== null || 
             document.querySelector('#appapp') !== null ||
             document.querySelector('.sidebar') !== null ||
             document.body.innerText.includes('Paradise') ||
             document.body.innerText.includes('Chien.nguyen');
    });

    console.log(`✅ Kết quả: Giao diện Dashboard nạp thành công (hasNavOrHeader = ${hasNavOrHeader})`);
    expect(hasNavOrHeader).toBeTruthy();
  });
});
