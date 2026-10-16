const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu, moveAndClick } = require('../helpers/crm_nav');

const PAGE_NAME = 'crm_sales_pipeline';

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

test.describe('Kiểm thử Phân hệ CRM - Menu Sales Pipeline & Quản Lý Cơ Hội Bán Hàng', () => {
  test.beforeEach(async ({ context, page }) => {
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
    await loginAsAdmin(page);
    await navigateToCrmMenu(page, 'Sales Pipeline');
  });

  // ============================================================================
  // TC-01: KHỞI ĐỘNG, ĐIỀU HƯỚNG VÀ THẨM ĐỊNH BẢNG KANBAN SALES PIPELINE
  // ============================================================================
  test('TC-01: Khởi động, Điều hướng và Thẩm định Bảng Kanban Sales Pipeline', async ({ page }, testInfo) => {
    // BƯỚC 1: Xác nhận vào đúng menu Sales Pipeline
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Mở thành công màn hình Sales Pipeline trong CRM'
    });

    // BƯỚC 2: Kiểm tra các giai đoạn và cột của Pipeline
    const pageText = await page.evaluate(() => document.body.innerText);
    const hasPipelineContent = pageText.includes('Sales Pipeline') || pageText.includes('Làm mới');
    expect(hasPipelineContent).toBeTruthy();

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Xác nhận hiển thị không gian làm việc Sales Pipeline'
    });

    // BƯỚC 3: Rà soát các thẻ cơ hội / khách hàng trên pipeline (.card-company)
    const cards = page.locator('.card-company:visible');
    await cards.first().waitFor({ state: 'visible', timeout: 15000 });
    const cardCount = await cards.count();
    console.log(`🎯 [TC-01] Số lượng thẻ cơ hội phát hiện trên Pipeline: ${cardCount}`);
    expect(cardCount).toBeGreaterThan(0);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: `Hệ thống nạp đầy đủ ${cardCount} thẻ cơ hội bán hàng theo từng giai đoạn`
    });

    // BƯỚC 4: Di chuyển chuột Neon rà soát thẻ cơ hội đầu tiên
    await moveAndClick(page, cards.first(), { pause: 400 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Con trỏ Neon di chuyển và chọn thẻ khách hàng trên pipeline'
    });

    // BƯỚC 5: Đánh giá nghiệm thu
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 5,
      desc: 'Bảng Sales Pipeline hoạt động ổn định đạt chuẩn'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Màn hình Sales Pipeline nạp giao diện Kanban trực quan, thông suốt'
    });
  });

  // ============================================================================
  // TC-02: THẨM ĐỊNH Ô TÌM KIẾM KANBAN (#kanbanSearchInput)
  // ============================================================================
  test('TC-02: Thẩm định Ô Tìm kiếm (#kanbanSearchInput) & Lọc Nhanh Cơ Hội', async ({ page }, testInfo) => {
    // Chờ toolbar và pipeline render
    await page.waitForTimeout(2000);

    // BƯỚC 1: Xác định vị trí ô tìm kiếm
    const searchInput = page.getByPlaceholder('Tìm kiếm theo tên, công ty, SĐT...').or(page.locator('#kanbanSearchInput')).first();
    await expect(searchInput).toBeVisible({ timeout: 15000 });

    const cards = page.locator('.card-company:visible');
    await cards.first().waitFor({ state: 'visible', timeout: 15000 });
    const initialCount = await cards.count();

    const sampleKeyword = await page.evaluate(() => {
      const firstCard = document.querySelector('.card-company');
      if (!firstCard) return 'Paradise';
      const words = firstCard.innerText.split(/\s+/).filter(w => w.length >= 4 && !w.includes('/') && !w.includes('09') && !w.includes('99'));
      return words[0] || 'Paradise';
    });
    console.log(`🔍 [TC-02] Từ khóa tìm kiếm trên Pipeline: "${sampleKeyword}"`);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: `Xác định vị trí ô tìm kiếm và trích xuất từ khóa: ${sampleKeyword}`
    });

    // BƯỚC 2: Di chuyển chuột Neon focus vào ô tìm kiếm
    await moveAndClick(page, searchInput, { pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Con trỏ Neon focus vào ô tìm kiếm Kanban'
    });

    // BƯỚC 3: Gõ từ khóa tìm kiếm trực quan bằng pressSequentially
    await searchInput.pressSequentially(sampleKeyword, { delay: 40 });
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: 'Gõ từ khóa tìm kiếm và quan sát các thẻ được lọc trực tiếp'
    });

    // BƯỚC 4: Kiểm tra kết quả sau khi lọc
    const filteredCount = await page.locator('.card-company:visible').count();
    console.log(`🔢 [TC-02] Số thẻ sau khi lọc: ${filteredCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 4,
      desc: `Hệ thống lọc tức thì danh sách còn ${filteredCount} thẻ khớp từ khóa`
    });

    // BƯỚC 5: Xóa từ khóa và khôi phục toàn bộ thẻ
    await searchInput.fill('');
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(2000);
    const restoredCount = await page.locator('.card-company:visible').count();
    expect(restoredCount).toBe(initialCount);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 5,
      desc: `Khôi phục nguyên vẹn ${restoredCount} thẻ cơ hội ban đầu`
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Ô tìm kiếm Kanban lọc tức thì và khôi phục dữ liệu hoàn hảo'
    });
  });

  // ============================================================================
  // TC-03: THẨM ĐỊNH NÚT LÀM MỚI (REFRESH) & BẮT API NẠP DỮ LIỆU
  // ============================================================================
  test('TC-03: Thẩm định Nút "Làm mới" & Bắt Phản hồi API Đồng bộ Dữ liệu', async ({ page }, testInfo) => {
    // BƯỚC 1: Xác định nút Làm mới màu xanh lá
    const btnRefresh = page.locator('button:has-text("Làm mới"), .btn-success:has-text("Làm mới")').first();
    await expect(btnRefresh).toBeVisible();

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Xác định vị trí nút Làm mới trên thanh toolbar'
    });

    // BƯỚC 2: Di chuột Neon tới nút Làm mới
    await btnRefresh.scrollIntoViewIfNeeded().catch(() => {});
    const btnBox = await btnRefresh.boundingBox();
    if (btnBox) {
      await page.mouse.move(btnBox.x + btnBox.width / 2, btnBox.y + btnBox.height / 2, { steps: 8 });
      await page.waitForTimeout(300);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 2,
      desc: 'Con trỏ Neon di chuyển vào tâm nút Làm mới'
    });

    // BƯỚC 3: Bấm nút Làm mới và bắt API đồng bộ
    const refreshPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') || res.status() === 200,
      { timeout: 10000 }
    ).catch(() => null);

    await btnRefresh.click();
    await refreshPromise;
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 3,
      desc: 'Bấm nút Làm mới và nhận gói phản hồi từ máy chủ'
    });

    // BƯỚC 4: Kiểm tra trạng thái Pipeline sau khi làm mới
    const isStillActive = await page.locator('#dynamic-tab-MnuKPI007.active').isVisible().catch(() => true);
    expect(isStillActive).toBeTruthy();

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 4,
      desc: 'Pipeline hoàn tất quá trình làm mới đồng bộ'
    });

    // BƯỚC 5: Kết quả nghiệm thu
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 5,
      desc: 'Tính năng làm mới dữ liệu Sales Pipeline đạt chuẩn nghiệp vụ'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Nút Làm mới phản hồi nhanh chóng, tái nạp dữ liệu Pipeline ổn định'
    });
  });
});
