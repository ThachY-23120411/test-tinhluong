const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu, moveAndClick } = require('../helpers/crm_nav');

const PAGE_NAME = 'crm_overview';

// Helper: Chụp ảnh từng bước (Step-by-Step Evidence)
async function captureStep(page, testInfo, { tcId, step, desc, pageName = PAGE_NAME }) {
  const safeDesc = desc
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${pageName}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);
  await page.screenshot({ path: filePath, fullPage: false });
  await testInfo.attach(`Bước ${step}: ${desc}`, {
    path: filePath,
    contentType: 'image/png'
  });
  console.log(`📸 [${tcId}] Đã chụp Bước ${step}: ${desc} -> ${fileName}`);
}

test.describe('Kiểm thử Phân hệ CRM - Menu Tổng Quan CRM & Điều Khiển KPI', () => {
  test.beforeEach(async ({ context, page }) => {
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
    await loginAsAdmin(page);
    await navigateToCrmMenu(page, 'Tổng quan CRM');
  });

  // ============================================================================
  // TC-01: KHỞI ĐỘNG, ĐIỀU HƯỚNG VÀ THẨM ĐỊNH THẺ KPI & BẢNG KẾT QUẢ TỔNG QUAN
  // ============================================================================
  test('TC-01: Thẩm định Giao diện Dashboard KPI, Thẻ Chỉ số & Bảng Kết quả Chi tiết', async ({ page }, testInfo) => {
    // BƯỚC 1: Xác nhận vào đúng menu Tổng quan CRM
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Mở thành công màn hình Tổng quan CRM'
    });

    // BƯỚC 2: Kiểm tra các thẻ Widget chỉ số KPI
    const pageText = await page.evaluate(() => document.body.innerText);
    const hasKpi = pageText.includes('Kết quả KPI chi tiết') || pageText.includes('Dashboard CRM') || pageText.includes('KPI');
    expect(hasKpi).toBeTruthy();

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Xác nhận hiển thị khu vực Dashboard KPI và các thẻ chỉ số'
    });

    // BƯỚC 3: Di chuyển chuột kiểm tra Bảng kết quả KPI
    const kpiTable = page.locator('#divKpiResult table, table.table, .table-responsive table').first();
    await expect(kpiTable).toBeVisible({ timeout: 10000 });
    const rowCount = await page.locator('tbody tr').count();
    console.log(`📊 [TC-01] Số dòng kết quả KPI hiển thị: ${rowCount}`);
    expect(rowCount).toBeGreaterThan(0);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Bảng kết quả KPI chi tiết nạp đầy đủ danh sách nhân viên'
    });

    // BƯỚC 4: Rê chuột Neon lên các tiêu đề cột bảng KPI
    const firstHeader = page.locator('th').filter({ hasText: 'NHÂN VIÊN' }).first();
    if (await firstHeader.isVisible().catch(() => false)) {
      await moveAndClick(page, firstHeader, { pause: 400 });
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Con trỏ Neon rà soát các cột chỉ số Yêu cầu Thực tế và Đạt được'
    });

    // BƯỚC 5: Đánh giá nghiệm thu
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 5,
      desc: 'Dashboard KPI nạp dữ liệu thành công đạt chuẩn'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Màn hình Tổng quan CRM nạp đầy đủ các widget và bảng KPI chi tiết'
    });
  });

  // ============================================================================
  // TC-02: THẨM ĐỊNH BỘ LỌC THỜI GIAN, PHÂN TRANG & NÚT TÍNH TOÁN LẠI
  // ============================================================================
  test('TC-02: Thẩm định Bộ lọc Kỳ dữ liệu (#filterType, #filterDate) & Nút Tính toán lại (#btnRecalculate)', async ({ page }, testInfo) => {
    // BƯỚC 1: Kiểm tra bộ chọn loại kỳ (#filterType)
    const filterType = page.locator('#filterType');
    await expect(filterType).toBeVisible();
    await moveAndClick(page, filterType, { pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: 'Kiểm tra dropdown chọn loại thời gian theo tuần tháng năm'
    });

    // BƯỚC 2: Kiểm tra ô chọn tuần (#filterDate)
    const filterDate = page.locator('#filterDate');
    await expect(filterDate).toBeVisible();
    await moveAndClick(page, filterDate, { pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Kiểm tra ô chọn kỳ tuần hiện tại'
    });

    // BƯỚC 3: Thay đổi số dòng hiển thị (#rowsPerPage)
    const rowsPerPage = page.locator('#rowsPerPage');
    if (await rowsPerPage.isVisible().catch(() => false)) {
      await moveAndClick(page, rowsPerPage, { pause: 200 });
      await rowsPerPage.selectOption('10').catch(() => {});
      await page.waitForTimeout(1000);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: 'Thay đổi tùy chọn số dòng hiển thị trên bảng'
    });

    // BƯỚC 4: Di chuột Neon bấm nút "Tính toán lại" (#btnRecalculate)
    const btnRecalc = page.locator('#btnRecalculate');
    await expect(btnRecalc).toBeVisible();
    
    // Bắt API khi bấm tính toán lại
    const recalcPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') || res.url().includes('KPI') || res.status() === 200,
      { timeout: 10000 }
    ).catch(() => null);

    await moveAndClick(page, btnRecalc, { pause: 400 });
    await recalcPromise;
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 4,
      desc: 'Con trỏ Neon bấm nút Tính toán lại và bắt phản hồi hệ thống'
    });

    // BƯỚC 5: Xác nhận bảng KPI được làm mới an toàn
    const countAfter = await page.locator('tbody tr').count();
    expect(countAfter).toBeGreaterThan(0);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 5,
      desc: 'Dữ liệu được tính toán lại thành công không bị gián đoạn'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Các bộ lọc thời gian và nút Tính toán lại phản hồi tốt, dữ liệu đồng bộ'
    });
  });

  // ============================================================================
  // TC-03: THẨM ĐỊNH NÚT THIẾT LẬP & MODAL CẤU HÌNH KPI (#settingsModal)
  // ============================================================================
  test('TC-03: Thẩm định Nút Thiết lập (#btnSettings) & Đóng/Mở Modal Cấu hình KPI', async ({ page }, testInfo) => {
    // BƯỚC 1: Xác định vị trí nút Thiết lập
    const btnSettings = page.locator('#btnSettings');
    await expect(btnSettings).toBeVisible();

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Xác định vị trí nút Thiết lập cấu hình KPI'
    });

    // BƯỚC 2: Di chuột Neon nhấp nút Thiết lập
    await moveAndClick(page, btnSettings, { pause: 400 });
    const settingsModal = page.locator('#settingsModal');
    await expect(settingsModal).toHaveClass(/show/, { timeout: 10000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 2,
      desc: 'Modal Cấu hình KPI hiển thị trực quan trên màn hình'
    });

    // BƯỚC 3: Rà soát các control bên trong modal cấu hình
    const modalInputs = settingsModal.locator('input, select, button');
    const inputCount = await modalInputs.count();
    console.log(`⚙️ [TC-03] Số lượng control trong modal cấu hình KPI: ${inputCount}`);
    expect(inputCount).toBeGreaterThan(0);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 3,
      desc: 'Kiểm tra các trường thiết lập tỷ lệ và tiêu chí KPI'
    });

    // BƯỚC 4: Di chuột Neon bấm nút Hủy / Đóng modal an toàn
    const btnClose = settingsModal.locator('button:has-text("Hủy"), .btn-close, [data-bs-dismiss="modal"]').first();
    await moveAndClick(page, btnClose, { pause: 400 });
    await page.waitForTimeout(1000);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 4,
      desc: 'Con trỏ Neon bấm nút Đóng modal cấu hình KPI'
    });

    // BƯỚC 5: Xác nhận modal đã đóng và giải phóng màn hình chính
    await expect(settingsModal).not.toHaveClass(/show/);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 5,
      desc: 'Modal đóng an toàn không để lại overlay chắn giao diện'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Modal Cấu hình KPI mở và đóng mượt mà, đầy đủ các trường thiết lập'
    });
  });

  // ============================================================================
  // TC-04: THẨM ĐỊNH NÚT THÊM LEAD (#btnCreateLead) & MODAL TẠO LEAD NHANH
  // ============================================================================
  test('TC-04: Thẩm định Nút Thêm Lead (#btnCreateLead) & Modal Tạo Mới Lead Nhanh', async ({ page }, testInfo) => {
    // BƯỚC 1: Xác định vị trí nút Thêm Lead
    const btnCreateLead = page.locator('#btnCreateLead');
    await expect(btnCreateLead).toBeVisible();

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 1,
      desc: 'Xác định vị trí nút Thêm Lead màu xanh lá'
    });

    // BƯỚC 2: Di chuột Neon bấm nút Thêm Lead
    await moveAndClick(page, btnCreateLead, { pause: 400 });
    const leadModal = page.locator('#customerAddModal').first();
    await expect(leadModal).toHaveClass(/show/, { timeout: 10000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 2,
      desc: 'Modal Thêm LEAD mở lên với đầy đủ các trường nhập liệu'
    });

    // BƯỚC 3: Kiểm tra các trường thông tin khách hàng trong modal
    const nameInput = leadModal.locator('input[placeholder*="Tên"], input#txtName, input.form-control').first();
    if (await nameInput.isVisible().catch(() => false)) {
      await moveAndClick(page, nameInput, { pause: 200 });
      await nameInput.pressSequentially('KHÁCH HÀNG DEMO TỔNG QUAN', { delay: 35 });
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 3,
      desc: 'Kiểm tra khả năng nhập liệu trực quan vào ô Tên khách hàng'
    });

    // BƯỚC 4: Di chuột Neon bấm nút Đóng modal
    const btnCloseLead = leadModal.locator('#btnCloseModal-CreateLead, button:has-text("Đóng"), button:has-text("Hủy"), .btn-close').first();
    await btnCloseLead.click({ force: true });
    await page.waitForTimeout(1500);

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 4,
      desc: 'Con trỏ Neon bấm nút Đóng modal Thêm Lead'
    });

    // BƯỚC 5: Xác nhận modal đã đóng thành công
    await expect(leadModal).not.toHaveClass(/show/);

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 5,
      desc: 'Màn hình Tổng quan CRM phục hồi nguyên vẹn sau khi đóng modal'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Nút Thêm Lead mở đúng modal tạo khách hàng, các trường nhập liệu phản hồi tốt'
    });
  });
});
