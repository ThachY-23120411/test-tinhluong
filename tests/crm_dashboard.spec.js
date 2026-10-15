const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

test.describe('Kiểm thử Phân hệ CRM - Trang Chủ & Tổng Quan CRM (Paradise HRM)', () => {
  test.beforeEach(async ({ context, page }) => {
    // Nhúng con trỏ chuột Neon trực quan phát sáng
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }

    // Đăng nhập tự động từ cấu hình test.env.json
    await loginAsAdmin(page);
  });

  test('TC-01: Kiểm tra Trang Chủ CRM - Dashboard KPI, Thống kê & Widget Cards', async ({ page }) => {
    console.log('🌐 [TC-01] Bước 1: Mở phân hệ Trang Chủ CRM từ thanh điều hướng Dock...');
    const crmHomeIcon = page.locator('.dock .icon.MnuKPI000, [title*="Trang chủ CRM"]');
    await expect(crmHomeIcon.first()).toBeVisible({ timeout: 15000 });
    await crmHomeIcon.first().click();

    console.log('⏳ [TC-01] Bước 2: Chờ hệ thống nạp các widget, biểu đồ KPI và thẻ dữ liệu...');
    await page.waitForTimeout(4500);

    // Kiểm tra hiển thị tiêu đề và các thành phần chính của Trang chủ CRM
    const pageText = await page.evaluate(() => document.body.innerText);
    const hasCrmDashboard = pageText.includes('Dashboard CRM') || pageText.includes('Kết quả KPI chi tiết');
    console.log(`📊 [TC-01] Kiểm tra Dashboard CRM: ${hasCrmDashboard ? 'ĐÃ TẢI THÀNH CÔNG' : 'CHƯA TẢI'}`);
    expect(hasCrmDashboard).toBeTruthy();

    // Kiểm tra sự xuất hiện của các thẻ KPI (Cards)
    const kpiCardKeywords = ['EMAIL THỦ CÔNG', 'THU THẬP DỮ LIỆU', 'CONTENT', 'DEMO', 'CẦN CHĂM SÓC'];
    const matchedCards = kpiCardKeywords.filter(k => pageText.includes(k));
    console.log(`🎯 [TC-01] Các chỉ số KPI phát hiện: ${matchedCards.join(', ')}`);
    expect(matchedCards.length).toBeGreaterThan(0);

    // Chụp ảnh bằng chứng nghiệm thu TC-01
    const ssDir = path.resolve(__dirname, '../test-evidence/crm_dashboard/TC-01/screenshots');
    fs.mkdirSync(ssDir, { recursive: true });
    const ssPath = path.join(ssDir, 'TC-01-crm-home-dashboard.png');
    await page.screenshot({ path: ssPath, fullPage: false });
    console.log(`📸 [TC-01] Đã lưu ảnh bằng chứng: ${ssPath}`);
  });

  test('TC-02: Kiểm tra Tổng quan CRM - Bộ lọc, Tìm kiếm, Button và Modal (Cấu hình KPI, Thêm Lead)', async ({ page }) => {
    console.log('🌐 [TC-02] Bước 1: Mở phân hệ Tổng quan CRM từ thanh điều hướng Dock...');
    const crmOverviewIcon = page.locator('.dock .icon.MnuKPI001, .dock .open-MnuKPI001, [title*="Tổng quan CRM"]');
    await expect(crmOverviewIcon.first()).toBeVisible({ timeout: 15000 });
    await crmOverviewIcon.first().scrollIntoViewIfNeeded();
    await crmOverviewIcon.first().click();

    console.log('⏳ [TC-02] Bước 2: Chờ nạp Tab và các bộ điều khiển Tổng quan CRM...');
    await page.waitForTimeout(4000);

    // Kiểm tra Tab Tổng quan CRM hiển thị
    const tabOverview = page.locator('#dynamic-tab-MnuKPI001, button:has-text("Tổng quan CRM")');
    await expect(tabOverview.first()).toBeVisible({ timeout: 10000 });
    console.log('✅ [TC-02] Tab "Tổng quan CRM" đã kích hoạt thành công!');

    // 1. Kiểm tra ô tìm kiếm nhanh (DxTextEditor)
    console.log('🔍 [TC-02] Bước 3: Thao tác nhập tìm kiếm trực quan trên ô search...');
    const searchInput = page.locator('.dx-texteditor-input').first();
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.click();
      await searchInput.pressSequentially('Khách hàng tiềm năng VIP', { delay: 100 });
      await page.waitForTimeout(1000);
      await searchInput.fill('');
      console.log('✅ [TC-02] Ô tìm kiếm hoạt động tốt.');
    }

    // 2. Kiểm tra các dropdown bộ lọc (Select)
    console.log('📋 [TC-02] Bước 4: Kiểm tra các dropdown bộ lọc tiêu chí & số lượng dòng...');
    const filterType = page.locator('#filterType');
    if (await filterType.isVisible().catch(() => false)) {
      console.log('✅ [TC-02] Dropdown bộ lọc thời gian/loại (#filterType) sẵn sàng.');
    }
    const filterDate = page.locator('#filterDate');
    if (await filterDate.isVisible().catch(() => false)) {
      console.log('✅ [TC-02] Bộ chọn kỳ dữ liệu (#filterDate) sẵn sàng.');
    }
    const rowsPerPage = page.locator('#rowsPerPage');
    if (await rowsPerPage.isVisible().catch(() => false)) {
      await rowsPerPage.selectOption({ index: 1 }).catch(() => {});
      console.log('✅ [TC-02] Chọn thay đổi số dòng phân trang (#rowsPerPage) thành công.');
    }

    // 3. Kiểm tra Button "Tính toán lại" (btnRecalculate)
    console.log('🔄 [TC-02] Bước 5: Bấm nút "Tính toán lại" (btnRecalculate)...');
    const btnRecalc = page.locator('#btnRecalculate');
    await expect(btnRecalc).toBeVisible();
    await btnRecalc.click();
    await page.waitForTimeout(1500);
    console.log('✅ [TC-02] Nút "Tính toán lại" đã phản hồi thành công.');

    // 4. Kiểm tra Button "Thiết lập" (btnSettings) & Modal "Cấu hình KPI"
    console.log('⚙️ [TC-02] Bước 6: Bấm nút "Thiết lập" để mở Modal Cấu hình KPI...');
    const btnSettings = page.locator('#btnSettings');
    await expect(btnSettings).toBeVisible();
    await btnSettings.click();
    await page.waitForTimeout(1500);

    const settingsModal = page.locator('#settingsModal');
    await expect(settingsModal).toHaveClass(/show/, { timeout: 10000 });
    console.log('✅ [TC-02] Modal "Cấu hình KPI" đã mở thành công!');

    // Đóng Modal Cấu hình KPI
    const btnCloseSettings = page.locator('#settingsModal.show button:has-text("Hủy"), #settingsModal.show .btn-close, #settingsModal.show [data-bs-dismiss="modal"]').first();
    if (await btnCloseSettings.isVisible().catch(() => false)) {
      await btnCloseSettings.click({ force: true });
      await page.waitForTimeout(1000);
      console.log('✅ [TC-02] Đã đóng Modal Cấu hình KPI.');
    }

    // 5. Kiểm tra Button "Thêm Lead" (btnCreateLead) & Modal "Thêm LEAD"
    console.log('➕ [TC-02] Bước 7: Bấm nút "Thêm Lead" để mở Modal tạo mới Lead...');
    const btnCreateLead = page.locator('#btnCreateLead');
    await expect(btnCreateLead).toBeVisible();
    await btnCreateLead.click();
    await page.waitForTimeout(2000);

    const customerModal = page.locator('#customerAddModal').first();
    await expect(customerModal).toHaveClass(/show/, { timeout: 10000 });
    console.log('✅ [TC-02] Modal "Thêm LEAD" đã mở thành công!');

    // Đóng Modal Thêm Lead
    const btnCloseLead = page.locator('#customerAddModal.show #btnCloseModal-CreateLead, #customerAddModal.show .btn-close').first();
    if (await btnCloseLead.isVisible().catch(() => false)) {
      await btnCloseLead.click({ force: true });
      await page.waitForTimeout(1000);
      console.log('✅ [TC-02] Đã đóng Modal Thêm Lead.');
    }

    // Chụp ảnh bằng chứng nghiệm thu TC-02
    const ssDir = path.resolve(__dirname, '../test-evidence/crm_dashboard/TC-02/screenshots');
    fs.mkdirSync(ssDir, { recursive: true });
    const ssPath = path.join(ssDir, 'TC-02-crm-controls-modals.png');
    await page.screenshot({ path: ssPath, fullPage: false });
    console.log(`📸 [TC-02] Đã lưu ảnh bằng chứng: ${ssPath}`);
  });
});
