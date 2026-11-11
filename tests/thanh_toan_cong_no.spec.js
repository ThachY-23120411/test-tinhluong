const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

const PAGE_NAME = 'thanh_toan_cong_no';

// Helper di chuyển chuột Neon mượt mà, dừng ngắm và click
async function moveAndClick(page, locator, options = {}) {
  await locator.waitFor({ state: 'visible', timeout: options.timeout || 12000 }).catch(() => {});
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  const box = await locator.boundingBox();
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 10 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: options.force || false });
}

// Chụp ảnh từng bước tuần tự (Step-by-Step Evidence)
async function captureStep(page, testInfo, { tcId, step, desc }) {
  const safeDesc = desc
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${PAGE_NAME}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);
  await page.screenshot({ path: filePath, fullPage: false });
  await testInfo.attach(`Bước ${step}: ${desc}`, {
    path: filePath,
    contentType: 'image/png'
  });
  console.log(`📸 [${tcId}] Đã chụp Bước ${step}: ${desc} -> ${fileName}`);
}

// Helper mở menu Thanh toán công nợ an toàn
async function navigateToDebtMenu(page) {
  // 1. Kiểm tra tab đã mở trên thanh điều hướng chưa
  const existingTab = page.locator('#dynamic-tab-MnuPRL409, .nav-tabs button:has-text("Thanh toán công nợ"), .nav-tabs li:has-text("Thanh toán công nợ") button').first();
  if (await existingTab.isVisible({ timeout: 2000 }).catch(() => false)) {
    await existingTab.click({ force: true });
    await page.waitForTimeout(1000);
    return;
  }

  // 2. Mở qua icon Dock hoặc gọi openMenu('MnuPRL409')
  await page.evaluate(() => {
    const el = document.querySelector('.icon.MnuPRL409, [class*="MnuPRL409"], a[href*="MnuPRL409"]');
    if (el) {
      el.click();
    } else if (typeof window.openMenu === 'function') {
      window.openMenu('MnuPRL409');
    }
  });
  await page.waitForTimeout(2000);
}

// Helper lấy thông số các cột DataGrid từ DOM
async function getGridColumns(page) {
  return await page.evaluate(() => {
    const cols = [];
    $('.dx-datagrid-headers .dx-header-row > td').each(function () {
      cols.push({
        text: $(this).text().trim(),
        width: Math.round($(this).outerWidth() * 10) / 10,
        cssWidth: $(this).css('width')
      });
    });
    return cols;
  });
}

test.describe('Kiểm thử Giao diện & Độ rộng DataGrid Menu Thanh Toán Công Nợ (MnuPRL409)', () => {
  test.beforeEach(async ({ context, page }) => {
    // 1. Nhúng con trỏ chuột Neon trực quan
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }

    // 2. Đăng nhập hệ thống (sử dụng tài khoản ThanhLong để có sẵn 3 bản ghi công nợ)
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);
    if (await page.locator('#username').isVisible().catch(() => false)) {
      await page.fill('#username', 'ThanhLong');
      await page.fill('input[type="password"]', '123');
      await page.click('#submitLogin');
      await page.waitForTimeout(3000);
    }
  });

  test('TC-01: Kiểm tra cấu trúc tỷ lệ các cột DataGrid sau khi mở menu (Responsive Grid)', async ({ page }, testInfo) => {
    // Bước 1: Xóa localStorage để bảo đảm tải bản HTML mới nhất từ Server
    console.log('🧹 [TC-01] Bước 1: Thực thi xóa sạch localStorage và reload...');
    await page.evaluate(() => {
      localStorage.clear();
      location.reload();
    });
    await page.waitForLoadState('domcontentloaded');
    await page.waitForTimeout(3000);

    // Đăng nhập lại nếu bị đưa về màn hình login
    if (await page.locator('#username').isVisible().catch(() => false)) {
      await page.fill('#username', 'ThanhLong');
      await page.fill('input[type="password"]', '123');
      await page.click('#submitLogin');
      await page.waitForTimeout(3000);
    }

    // Bước 2: Điều hướng vào menu "Thanh toán công nợ"
    console.log('📂 [TC-01] Bước 2: Điều hướng tới menu Thanh toán công nợ...');
    await navigateToDebtMenu(page);
    await page.locator('#dp_grid, #dp_grid_container').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(3000);
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 1, desc: 'Mo menu Thanh toan cong no lan dau' });

    // Bước 3: Đo và kiểm tra tỷ lệ độ rộng các cột
    console.log('📏 [TC-01] Bước 3: Bóc tách kích thước thực tế các cột từ DOM...');
    const cols = await getGridColumns(page);
    console.log('📊 Thông số cột:', JSON.stringify(cols, null, 2));

    const colKhachHang = cols.find(c => c.text.includes('Khách hàng'));
    const colLoaiCongNo = cols.find(c => c.text.includes('Loại Công Nợ'));
    const colTongCongNo = cols.find(c => c.text.includes('Tổng công nợ'));

    expect(colKhachHang).toBeDefined();
    expect(colLoaiCongNo).toBeDefined();
    expect(colTongCongNo).toBeDefined();

    // Xác minh cột Khách hàng không bị phình to bất thường (> 500px là lỗi cũ)
    console.log(`🔍 [TC-01] Độ rộng cột Khách hàng: ${colKhachHang.width}px`);
    expect(colKhachHang.width).toBeLessThan(450);

    // Xác minh tiêu đề các cột hiển thị trọn vẹn (không chứa dấu ba chấm ...)
    expect(colTongCongNo.text).not.toContain('...');
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 2, desc: 'Kiem tra do rong 8 cot DataGrid can doi' });
  });

  test('TC-02: Bấm nút "Làm mới" (loadDebtPaymentData) và xác minh độ rộng các cột không bị vỡ layout', async ({ page }, testInfo) => {
    // Bước 1: Mở menu Thanh toán công nợ
    console.log('📂 [TC-02] Bước 1: Mở menu Thanh toán công nợ...');
    await navigateToDebtMenu(page);
    await page.locator('#dp_grid, #dp_grid_container').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(2000);
    await captureStep(page, testInfo, { tcId: 'TC-02', step: 1, desc: 'Giao dien truoc khi bam nut Lam moi' });

    // Bước 2: Rê chuột Neon ngắm và click nút "Làm mới"
    console.log('🔄 [TC-02] Bước 2: Rê chuột tới nút "Làm mới" và click...');
    const refreshBtn = page.locator('button:has-text("Làm mới"), button[onclick*="loadDebtPaymentData"]').first();
    await expect(refreshBtn).toBeVisible({ timeout: 5000 });
    await moveAndClick(page, refreshBtn, { pause: 800 });
    await page.waitForTimeout(3000);
    await captureStep(page, testInfo, { tcId: 'TC-02', step: 2, desc: 'Sau khi bam nut Lam moi' });

    // Bước 3: Đo lại kích thước các cột sau khi làm mới
    console.log('📏 [TC-02] Bước 3: Đo lại kích thước cột sau khi click Làm mới...');
    const colsAfter = await getGridColumns(page);
    console.log('📊 Thông số cột sau Làm mới:', JSON.stringify(colsAfter, null, 2));

    const colKhachHangAfter = colsAfter.find(c => c.text.includes('Khách hàng'));
    const colLoaiCongNoAfter = colsAfter.find(c => c.text.includes('Loại Công Nợ'));
    const colTongCongNoAfter = colsAfter.find(c => c.text.includes('Tổng công nợ'));

    expect(colKhachHangAfter).toBeDefined();
    // Khẳng định cột Khách hàng không bị nuốt màn hình (phải < 450px)
    console.log(`🔍 [TC-02] Độ rộng Khách hàng sau Làm mới: ${colKhachHangAfter.width}px`);
    expect(colKhachHangAfter.width).toBeLessThan(450);

    // Khẳng định tiêu đề Tổng công nợ không bị cắt cụt
    expect(colTongCongNoAfter.text).not.toContain('...');
    await captureStep(page, testInfo, { tcId: 'TC-02', step: 3, desc: 'Doi chieu va ket luan DataGrid on dinh' });
  });

  test('TC-03: Chuyển đổi tab / Bấm lại menu ở Sidebar và xác minh độ ổn định giao diện', async ({ page }, testInfo) => {
    // Bước 1: Mở menu Thanh toán công nợ
    console.log('📂 [TC-03] Bước 1: Đảm bảo tab Thanh toán công nợ đang mở...');
    await navigateToDebtMenu(page);
    await page.locator('#dp_grid, #dp_grid_container').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(2000);

    // Bước 2: Bấm lại vào menu ở sidebar (kích hoạt addNewTab khi tab đã có sẵn)
    console.log('🔄 [TC-03] Bước 2: Bấm lại vào menu "Thanh toán công nợ" ở sidebar...');
    await navigateToDebtMenu(page);
    await page.waitForTimeout(2500);
    await captureStep(page, testInfo, { tcId: 'TC-03', step: 1, desc: 'Sau khi click lai menu o sidebar' });

    // Bước 3: Xác minh kích thước cột
    const cols = await getGridColumns(page);
    const colKhachHang = cols.find(c => c.text.includes('Khách hàng'));
    expect(colKhachHang).toBeDefined();
    expect(colKhachHang.width).toBeLessThan(450);
    await captureStep(page, testInfo, { tcId: 'TC-03', step: 2, desc: 'Xac minh cac cot van giu nguyen ty le can doi' });
  });
});
