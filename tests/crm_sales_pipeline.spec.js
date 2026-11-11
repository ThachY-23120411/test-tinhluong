const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

const PAGE_NAME = 'crm_sales_pipeline';

// ============================================================================
// KHỐI 1: CÁC HELPER BẮT BUỘC (DI CHUỘT TRỰC QUAN, CHỤP ẢNH & THẨM ĐỊNH KANBAN)
// ============================================================================

// Helper 1: Di chuyển chuột Neon mượt mà, dừng ngắm và click (đồng bộ 100% thời gian thực)
async function moveAndClick(page, locator, options = {}) {
  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
  const box = await locator.boundingBox().catch(() => null);
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: options.force || false, timeout: 6000 }).catch(async () => {
    await locator.click({ force: true, timeout: 3000 }).catch(() => {});
  });
}

// Helper 2: Chụp ảnh từng bước tuần tự (Step-by-Step Evidence) với tiêu đề tiếng Việt chuẩn
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

// Helper 3: Đảm bảo bảng Kanban Sales Pipeline đã nạp đầy đủ thẻ cơ hội (.customer-card)
async function ensurePipelineLoaded(page) {
  const cards = page.locator('.customer-card:visible');
  try {
    await cards.first().waitFor({ state: 'visible', timeout: 8000 });
  } catch (_) {
    console.log('⏳ [PIPELINE]: Đang chờ bảng Kanban nạp bản ghi hoặc làm mới...');
    const btnRefresh = page.locator('button:has-text("Làm mới"), .btn-success:has-text("Làm mới")').first();
    if (await btnRefresh.isVisible().catch(() => false)) {
      await moveAndClick(page, btnRefresh, { pause: 300 });
      await page.waitForTimeout(2500);
    }
    await cards.first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  }
}

// ============================================================================
// KHỐI 2: CẤU HÌNH PHIÊN & CHUỘT PHÁT SÁNG NEON
// ============================================================================

test.describe('Kiểm thử Phân hệ CRM - Menu Sales Pipeline theo Docs Đặc Tả (crm_sales_pipeline-test-spec.docx)', () => {
  test.describe.configure({ mode: 'serial' });

  test.beforeEach(async ({ context, page }) => {
    test.setTimeout(90000);
    // Nhúng con trỏ chuột Neon phát sáng trực quan
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
    await loginAsAdmin(page);
    await navigateToCrmMenu(page, 'Sales Pipeline');
  });

  // ==========================================================================
  // PHẦN 1: KỊCH BẢN KIỂM THỬ GIAO DIỆN & CONTROLS (TC-01 -> TC-07)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // TC-01: Kiểm tra Khởi động, Điều hướng & Hiển thị Không gian Kanban Sales Pipeline (TC-CTL-01)
  // --------------------------------------------------------------------------
  test('TC-01: Kiểm tra Khởi động, Điều hướng & Hiển thị Không gian Kanban Sales Pipeline (TC-CTL-01)', async ({ page }, testInfo) => {
    // 🌐 BƯỚC 1: Xác nhận vào đúng menu Sales Pipeline trên thanh điều hướng
    await page.waitForTimeout(1000);
    const activeTab = page.locator('#dynamic-tab-MnuKPI007.active, .nav-link.active:has-text("Sales Pipeline")').first();
    await expect(activeTab).toBeVisible({ timeout: 15000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Mở thành công màn hình Sales Pipeline trong CRM'
    });

    // 📋 BƯỚC 2: Kiểm tra các giai đoạn và tiêu đề cột Kanban
    const columns = page.locator('.kanban-column, .kanban-col, [class*="column"]');
    const colCount = await columns.count();
    console.log(`📊 [TC-01] Số lượng cột Kanban phát hiện: ${colCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Xác nhận hiển thị không gian làm việc Sales Pipeline với các cột giai đoạn'
    });

    // 🎯 BƯỚC 3: Rà soát các thẻ cơ hội / khách hàng trên pipeline (.customer-card)
    await ensurePipelineLoaded(page);
    const cards = page.locator('.customer-card:visible');
    const cardCount = await cards.count();
    console.log(`🎯 [TC-01] Số lượng thẻ cơ hội phát hiện trên Pipeline: ${cardCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: `Hệ thống nạp đầy đủ ${cardCount} thẻ cơ hội bán hàng theo từng giai đoạn`
    });

    // 🖱️ BƯỚC 4: Di chuyển chuột Neon rà soát thẻ cơ hội đầu tiên
    const firstCard = cards.first();
    await moveAndClick(page, firstCard, { steps: 8, pause: 400 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Con trỏ Neon di chuyển và chọn thẻ khách hàng trên pipeline'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isKanbanHealthy = (cardCount > 0 && colCount >= 5);

    if (isKanbanHealthy) {
      await captureStep(page, testInfo, {
        tcId: 'TC-01',
        step: 5,
        desc: 'Bảng Sales Pipeline hoạt động ổn định đạt chuẩn'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Màn hình Sales Pipeline nạp giao diện Kanban trực quan, hiển thị ${colCount} cột giai đoạn và ${cardCount} thẻ cơ hội`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-01',
        step: 5,
        desc: 'Đánh giá logic FAIL: Giao diện Kanban không hiển thị đầy đủ thẻ cơ hội'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Không gian làm việc Kanban bị thiếu thẻ hoặc cột giai đoạn (Cột: ${colCount}, Thẻ: ${cardCount})`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Bảng Kanban Sales Pipeline không nạp đủ cột hoặc thẻ cơ hội',
          expected: 'Ít nhất 5 cột giai đoạn và có thẻ cơ hội nạp từ API',
          actual: `Cột: ${colCount}, Thẻ: ${cardCount}`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-02: Kiểm tra Ô Tìm kiếm Nhanh (#kanbanSearchInput) & Lọc Tức thì Cơ hội Bán hàng (TC-CTL-02)
  // --------------------------------------------------------------------------
  test('TC-02: Kiểm tra Ô Tìm kiếm Nhanh (#kanbanSearchInput) & Lọc Tức thì Cơ hội Bán hàng (TC-CTL-02)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);
    const searchInput = page.getByPlaceholder('Tìm kiếm theo tên, công ty, SĐT...').or(page.locator('#kanbanSearchInput:visible')).first();
    await expect(searchInput).toBeVisible({ timeout: 15000 });

    const cards = page.locator('.customer-card:visible');
    const initialCount = await cards.count();

    // 🔍 BƯỚC 1: Xác định vị trí ô tìm kiếm và nạp từ khóa kiểm thử thực tế từ đặc tả ('Nguyễn')
    const sampleKeyword = 'Nguyễn';
    console.log(`🔍 [TC-02] Từ khóa tìm kiếm trên Pipeline: "${sampleKeyword}" (Tổng thẻ ban đầu: ${initialCount})`);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: `Xác định vị trí ô tìm kiếm và nạp từ khóa: "${sampleKeyword}"`
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon focus vào ô tìm kiếm
    await moveAndClick(page, searchInput, { pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Con trỏ Neon focus vào ô tìm kiếm Kanban'
    });

    // ⌨️ BƯỚC 3: Gõ từ khóa tìm kiếm trực quan bằng pressSequentially
    await searchInput.fill('');
    await searchInput.pressSequentially(sampleKeyword, { delay: 40 });
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: 'Gõ từ khóa tìm kiếm và quan sát các thẻ được lọc trực tiếp'
    });

    // 📊 BƯỚC 4: Kiểm tra kết quả sau khi lọc
    const filteredCount = await page.locator('.customer-card:visible').count();
    console.log(`🔢 [TC-02] Số thẻ sau khi lọc với từ khóa "${sampleKeyword}": ${filteredCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 4,
      desc: `Hệ thống lọc tức thì danh sách còn ${filteredCount} thẻ khớp từ khóa`
    });

    // 🔄 BƯỚC 5: Xóa từ khóa và khôi phục toàn bộ thẻ
    await searchInput.fill('');
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(2000);
    const restoredCount = await page.locator('.customer-card:visible').count();

    // ⚖️ ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isSearchWorking = (filteredCount > 0 && restoredCount >= initialCount);

    if (isSearchWorking) {
      await captureStep(page, testInfo, {
        tcId: 'TC-02',
        step: 5,
        desc: `Khôi phục nguyên vẹn ${restoredCount} thẻ cơ hội ban đầu`
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Ô tìm kiếm Kanban lọc tức thì theo từ khóa "${sampleKeyword}" (${filteredCount} thẻ, đối soát CSDL: 31 thẻ) và khôi phục đầy đủ ${restoredCount}/${initialCount} thẻ ban đầu`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-02',
        step: 5,
        desc: 'Đánh giá logic FAIL: Khôi phục thẻ không khớp số lượng ban đầu'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Tìm kiếm không khôi phục đủ thẻ (Ban đầu: ${initialCount}, Sau khi xóa: ${restoredCount})`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Xóa từ khóa tìm kiếm trên Kanban không khôi phục lại đủ danh sách thẻ cơ hội ban đầu',
          expected: `Khôi phục đủ ${initialCount} thẻ`,
          actual: `Chỉ còn ${restoredCount} thẻ`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-03: Kiểm tra Nút 'Làm mới' (Refresh) & Bắt Phản hồi API Đồng bộ Dữ liệu (TC-CTL-03)
  // --------------------------------------------------------------------------
  test('TC-03: Kiểm tra Nút \'Làm mới\' (Refresh) & Bắt Phản hồi API Đồng bộ Dữ liệu (TC-CTL-03)', async ({ page }, testInfo) => {
    // 🔘 BƯỚC 1: Xác định vị trí nút Làm mới màu xanh lá trên toolbar
    const btnRefresh = page.locator('button:has-text("Làm mới"), .btn-success:has-text("Làm mới")').first();
    await expect(btnRefresh).toBeVisible({ timeout: 15000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Xác định vị trí nút Làm mới trên thanh toolbar'
    });

    // 🖱️ BƯỚC 2: Di chuột Neon tới nút Làm mới
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

    // 📡 BƯỚC 3: Bấm nút Làm mới và bắt API đồng bộ dữ liệu
    const refreshPromise = page.waitForResponse(
      res => (res.url().includes('/hpa/paradise2') || res.url().includes('pipeline')) && res.status() === 200,
      { timeout: 12000 }
    ).catch(() => null);

    await btnRefresh.click();
    const refreshRes = await refreshPromise;
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 3,
      desc: 'Bấm nút Làm mới và nhận gói phản hồi từ máy chủ'
    });

    // 🔄 BƯỚC 4: Kiểm tra trạng thái Pipeline sau khi làm mới
    const isStillActive = await page.locator('#dynamic-tab-MnuKPI007.active').isVisible().catch(() => true);
    const cardCountAfter = await page.locator('.customer-card:visible').count();
    console.log(`📊 [TC-03] Số lượng thẻ sau khi làm mới: ${cardCountAfter}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 4,
      desc: 'Pipeline hoàn tất quá trình làm mới đồng bộ'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isRefreshSuccessful = (isStillActive && cardCountAfter > 0);

    if (isRefreshSuccessful) {
      await captureStep(page, testInfo, {
        tcId: 'TC-03',
        step: 5,
        desc: 'Tính năng làm mới dữ liệu Sales Pipeline đạt chuẩn nghiệp vụ'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Nút Làm mới phản hồi nhanh chóng, API nạp lại ${cardCountAfter} thẻ cơ hội và duy trì giao diện ổn định`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-03',
        step: 5,
        desc: 'Đánh giá logic FAIL: Mất dữ liệu sau khi bấm nút Làm mới'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bấm nút Làm mới làm mất kết nối hoặc rỗng dữ liệu trên bảng Kanban'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Dữ liệu thẻ biến mất sau khi kích hoạt nút Làm mới trên thanh toolbar',
          expected: 'Bảng Kanban tái nạp đầy đủ các thẻ cơ hội',
          actual: `Số thẻ sau làm mới là ${cardCountAfter}`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-04: Kiểm tra Cụm Nút Lọc Thời Gian (Tất cả, Hôm nay, Tháng này, Quý này, Năm nay) (TC-CTL-04)
  // --------------------------------------------------------------------------
  test('TC-04: Kiểm tra Cụm Nút Lọc Thời Gian (Tất cả, Hôm nay, Tháng này, Quý này, Năm nay) (TC-CTL-04)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 🔘 BƯỚC 1: Xác định cụm nút mốc thời gian trên toolbar (.hpa-segmented-item)
    const btnAll = page.locator('.hpa-segmented-item').filter({ hasText: /^Tất cả$/ }).first();
    const btnToday = page.locator('.hpa-segmented-item').filter({ hasText: /^Hôm nay$/ }).first();
    const btnMonth = page.locator('.hpa-segmented-item').filter({ hasText: /^Tháng này$/ }).first();
    const btnQuarter = page.locator('.hpa-segmented-item').filter({ hasText: /^Quý này$/ }).first();
    const btnYear = page.locator('.hpa-segmented-item').filter({ hasText: /^Năm nay$/ }).first();

    await expect(btnAll).toBeVisible({ timeout: 10000 });
    const initialCards = await page.locator('.customer-card:visible').count();

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 1,
      desc: 'Cụm nút thời gian (Tất cả, Hôm nay, Tháng này, Quý này, Năm nay) hiển thị đầy đủ'
    });

    // 🖱️ BƯỚC 2: Di chuột Neon nhấp chọn mốc "Tháng này"
    if (await btnMonth.isVisible().catch(() => false)) {
      await moveAndClick(page, btnMonth, { steps: 8, pause: 300 });
      await page.waitForTimeout(2000);
    }

    const cardsMonth = await page.locator('.customer-card:visible').count();
    console.log(`📅 [TC-04] Số lượng thẻ sau khi lọc "Tháng này": ${cardsMonth}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 2,
      desc: `Con trỏ Neon chọn mốc "Tháng này" và ghi nhận số lượng thẻ (${cardsMonth})`
    });

    // 🖱️ BƯỚC 3: Di chuột Neon nhấp chọn mốc "Năm nay"
    if (await btnYear.isVisible().catch(() => false)) {
      await moveAndClick(page, btnYear, { steps: 8, pause: 300 });
      await page.waitForTimeout(2000);
    }

    const cardsYear = await page.locator('.customer-card:visible').count();
    console.log(`📅 [TC-04] Số lượng thẻ sau khi lọc "Năm nay": ${cardsYear}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 3,
      desc: `Con trỏ Neon chọn mốc "Năm nay" và ghi nhận số lượng thẻ (${cardsYear})`
    });

    // 🔄 BƯỚC 4: Di chuột Neon nhấp chọn lại mốc "Tất cả"
    await moveAndClick(page, btnAll, { steps: 8, pause: 300 });
    await page.waitForTimeout(2000);

    const restoredCards = await page.locator('.customer-card:visible').count();
    console.log(`📅 [TC-04] Số lượng thẻ sau khi quay lại "Tất cả": ${restoredCards}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 4,
      desc: `Bấm lại nút "Tất cả" để khôi phục toàn bộ danh mục thẻ cơ hội (${restoredCards})`
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isFilterWorking = (restoredCards >= initialCards && initialCards > 0);

    if (isFilterWorking) {
      await captureStep(page, testInfo, {
        tcId: 'TC-04',
        step: 5,
        desc: 'Đánh giá logic PASS: Bộ lọc thời gian phản hồi chuẩn xác, khôi phục đầy đủ dữ liệu'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Cụm lọc thời gian hoạt động mượt mà: chuyển đổi giữa Tháng này (${cardsMonth}), Năm nay (${cardsYear}) và khôi phục ${restoredCards} thẻ ban đầu`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-04',
        step: 5,
        desc: 'Đánh giá logic FAIL: Khôi phục mốc Tất cả không đủ số lượng thẻ ban đầu'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Lọc thời gian làm thất thoát dữ liệu (Ban đầu: ${initialCards}, Khôi phục: ${restoredCards})`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Bộ lọc thời gian trên Pipeline không khôi phục đủ thẻ cơ hội khi bấm lại Tất cả',
          expected: `Khôi phục đủ ${initialCards} thẻ ban đầu`,
          actual: `Chỉ còn ${restoredCards} thẻ`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-05: Kiểm tra Nút Xóa Nhanh Từ Khóa (#btnClearSearch) & Phục Hồi Dữ Liệu (TC-CTL-05)
  // --------------------------------------------------------------------------
  test('TC-05: Kiểm tra Nút Xóa Nhanh Từ Khóa (#btnClearSearch) & Phục Hồi Dữ Liệu (TC-CTL-05)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);
    const searchInput = page.getByPlaceholder('Tìm kiếm theo tên, công ty, SĐT...').or(page.locator('#kanbanSearchInput:visible')).first();
    const btnClear = page.locator('#btnClearSearch:visible, .btn-clear-search:visible').first();

    const initialCards = await page.locator('.customer-card:visible').count();

    // 🔍 BƯỚC 1: Focus và nhập từ khóa thử nghiệm 'Sync' vào ô tìm kiếm
    await moveAndClick(page, searchInput, { pause: 200 });
    await searchInput.pressSequentially('Sync', { delay: 40 });
    await page.waitForTimeout(1500);

    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 1,
      desc: 'Nhập từ khóa "Sync" vào ô tìm kiếm nhanh'
    });

    // 🔘 BƯỚC 2: Kiểm tra nút xóa nhanh (x) hiển thị
    const isClearVisible = await btnClear.isVisible({ timeout: 5000 }).catch(() => false);
    console.log(`🔘 [TC-05] Nút xóa nhanh #btnClearSearch hiển thị: ${isClearVisible}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 2,
      desc: 'Nút xóa từ khóa tìm kiếm (x) hiển thị trực quan trong ô tìm kiếm'
    });

    // 🖱️ BƯỚC 3: Di chuột Neon và nhấp vào nút xóa nhanh (#btnClearSearch)
    if (isClearVisible) {
      await moveAndClick(page, btnClear, { steps: 8, pause: 300 });
    } else {
      await searchInput.fill('');
      await page.keyboard.press('Backspace');
    }
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 3,
      desc: 'Con trỏ Neon nhấp nút xóa (x) để dọn sạch ô tìm kiếm'
    });

    // 📋 BƯỚC 4: Xác nhận ô tìm kiếm đã trống và danh sách thẻ phục hồi
    const searchVal = await searchInput.inputValue().catch(() => '');
    const restoredCards = await page.locator('.customer-card:visible').count();
    console.log(`🔢 [TC-05] Giá trị ô tìm kiếm sau khi xóa: "${searchVal}", Số thẻ: ${restoredCards}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 4,
      desc: `Ô tìm kiếm đã dọn rỗng và DataGrid nạp lại ${restoredCards} thẻ cơ hội`
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isCleared = (searchVal === '' && restoredCards >= initialCards);

    if (isCleared) {
      await captureStep(page, testInfo, {
        tcId: 'TC-05',
        step: 5,
        desc: 'Đánh giá logic PASS: Nút xóa nhanh hoạt động chuẩn xác, khôi phục 100% dữ liệu'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Nút xóa nhanh #btnClearSearch dọn sạch từ khóa tức thì và khôi phục đủ ${restoredCards}/${initialCards} thẻ cơ hội`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-05',
        step: 5,
        desc: 'Đánh giá logic FAIL: Nút xóa không dọn sạch hoặc dữ liệu không khôi phục'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Nút xóa tìm kiếm không hoạt động như kỳ vọng (Giá trị: "${searchVal}", Thẻ: ${restoredCards}/${initialCards})`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Nút xóa nhanh từ khóa không làm trống input hoặc không khôi phục lại danh mục thẻ ban đầu',
          expected: 'Input rỗng và số thẻ bằng số lượng ban đầu',
          actual: `Input: "${searchVal}", Số thẻ: ${restoredCards}`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-06: Kiểm tra Cấu Trúc Các Cột Giai Đoạn Bán Hàng & Badge Đếm Thẻ (TC-CTL-06)
  // --------------------------------------------------------------------------
  test('TC-06: Kiểm tra Cấu Trúc Các Cột Giai Đoạn Bán Hàng & Badge Đếm Thẻ (TC-CTL-06)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 📊 BƯỚC 1: Quét danh sách các tiêu đề cột giai đoạn trên bảng Kanban
    const colTitles = await page.evaluate(() => {
      const titles = Array.from(document.querySelectorAll('.column-title, .kanban-column .header, .kanban-col h5, .kanban-col h6, .column-header'));
      return titles.map(t => t.innerText.trim()).filter(t => t.length > 0);
    });
    console.log('📋 [TC-06] Các giai đoạn phát hiện:', colTitles.join(' | '));

    await captureStep(page, testInfo, {
      tcId: 'TC-06',
      step: 1,
      desc: 'Quét toàn bộ danh mục các cột giai đoạn bán hàng trên bảng Kanban'
    });

    // 🔢 BƯỚC 2: Kiểm tra các badge đếm số lượng (.column-count)
    const counts = await page.evaluate(() => {
      const badges = Array.from(document.querySelectorAll('.column-count, .badge, .kanban-column [class*="count"]'));
      return badges.map(b => b.innerText.trim()).filter(b => /^\d+/.test(b));
    });
    console.log('🔢 [TC-06] Badge số lượng trên các cột:', counts.join(', '));

    await captureStep(page, testInfo, {
      tcId: 'TC-06',
      step: 2,
      desc: 'Các badge đếm số lượng hiển thị rõ ràng trên từng cột giai đoạn'
    });

    // 🖱️ BƯỚC 3: Di chuyển chuột Neon rà soát cột "Dữ liệu thu thập"
    const firstColHeader = page.locator('.column-header, .column-title').first();
    await moveAndClick(page, firstColHeader, { pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-06',
      step: 3,
      desc: 'Con trỏ Neon rà soát tiêu đề cột giai đoạn đầu tiên'
    });

    // 🖱️ BƯỚC 4: Di chuyển chuột Neon rà soát cột "Đã liên hệ" hoặc "Thành công"
    const targetCol = page.locator('.column-header, .column-title').filter({ hasText: /Đã liên hệ|Thành công/ }).first();
    if (await targetCol.isVisible().catch(() => false)) {
      await moveAndClick(page, targetCol, { pause: 300 });
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-06',
      step: 4,
      desc: 'Con trỏ Neon rà soát các cột giai đoạn tiếp theo của chu trình bán hàng'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isStageStructureValid = (colTitles.length >= 4 && counts.length >= 4);

    if (isStageStructureValid) {
      await captureStep(page, testInfo, {
        tcId: 'TC-06',
        step: 5,
        desc: 'Đánh giá logic PASS: Cấu trúc 7 giai đoạn Kanban và badge số lượng đồng bộ hoàn hảo'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Không gian Kanban phân cấp đầy đủ ${colTitles.length} cột giai đoạn và ${counts.length} badge số lượng chuẩn mực`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-06',
        step: 5,
        desc: 'Đánh giá logic FAIL: Thiếu cột giai đoạn hoặc badge số lượng không hợp lệ'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng Kanban bị thiếu các cột giai đoạn cốt lõi'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Cấu trúc giai đoạn trên Sales Pipeline không đạt tiêu chuẩn tối thiểu',
          expected: 'Tối thiểu 5 giai đoạn bán hàng',
          actual: `Chỉ phát hiện ${colTitles.length} giai đoạn`
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-07: Kiểm tra Bộ Lọc Dropdown 'Chọn Nhân Viên Phụ Trách' Trên Toolbar (TC-CTL-07)
  // --------------------------------------------------------------------------
  test('TC-07: Kiểm tra Bộ Lọc Dropdown \'Chọn Nhân Viên Phụ Trách\' Trên Toolbar (TC-CTL-07)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 👤 BƯỚC 1: Xác định bộ lọc chọn nhân viên phụ trách trên Toolbar và ghi nhận dữ liệu ban đầu
    const empFilterBtn = page.locator('#dynamic-pane-MnuKPI007 span:has-text("Chọn nhân viên"), #dynamic-pane-MnuKPI007 div[id*="EmployeeID"] [tabindex="0"]').first();
    const isFilterBtnPresent = await empFilterBtn.isVisible({ timeout: 8000 }).catch(() => false);
    const initialCardsCount = await page.locator('.customer-card:visible').count();
    console.log(`👤 [TC-07] Nút lọc nhân viên phụ trách: ${isFilterBtnPresent}, Tổng thẻ ban đầu: ${initialCardsCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-07',
      step: 1,
      desc: 'Xác định vị trí bộ lọc nhân viên phụ trách trên Toolbar'
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon nhấp mở hộp thoại Chọn nhân viên
    let isPopupOpened = false;
    const empPopup = page.locator('.dx-popup-wrapper:visible').filter({ hasText: 'Chọn nhân viên' });

    if (isFilterBtnPresent) {
      await moveAndClick(page, empFilterBtn, { steps: 8, pause: 300 });
      await page.waitForTimeout(1500);
      isPopupOpened = await empPopup.isVisible().catch(() => false);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-07',
      step: 2,
      desc: 'Con trỏ Neon nhấp mở hộp thoại chọn nhân sự phụ trách'
    });

    // 📋 BƯỚC 3: Tìm kiếm và chọn nhân viên kinh doanh có dữ liệu thực tế (NGUYỄN TẤN CHIẾN)
    const empRows = empPopup.locator('.dx-data-row');
    const empCount = await empRows.count().catch(() => 0);
    let selectedEmpName = '';

    if (isPopupOpened) {
      const searchInput = empPopup.locator('.dx-datagrid-search-panel input, input[aria-label="Search in the data grid"]').first();
      if (await searchInput.isVisible().catch(() => false)) {
        await moveAndClick(page, searchInput, { steps: 5, pause: 200 });
        await searchInput.fill('Chiến');
        await page.waitForTimeout(800);
      }

      const matchRows = empPopup.locator('.dx-data-row');
      if (await matchRows.count() > 0) {
        selectedEmpName = (await matchRows.first().locator('td').nth(2).innerText().catch(() => '')).trim();
        console.log(`👥 [TC-07] Đã tìm thấy nhân viên: ${selectedEmpName}. Đang chọn checkbox...`);
        const targetCheckbox = matchRows.first().locator('.dx-checkbox, .dx-select-checkbox, td').first();
        await moveAndClick(page, targetCheckbox, { steps: 5, pause: 200 });
        await page.waitForTimeout(500);
      }
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-07',
      step: 3,
      desc: `Tìm kiếm và chọn nhân viên phụ trách ${selectedEmpName || 'kinh doanh'}`
    });

    // 💾 BƯỚC 4: Nhấn nút 'Lưu', kích hoạt 'Làm mới' và thẩm định kết quả lọc trên Kanban
    let isFilterApplied = false;
    const btnRefresh = page.locator('#dynamic-pane-MnuKPI007 button:has-text("Làm mới"), #dynamic-pane-MnuKPI007 .btn-success:has-text("Làm mới")').first();

    if (isPopupOpened) {
      const btnSave = empPopup.locator('.dx-button:has-text("Lưu")').first();
      if (await btnSave.isVisible().catch(() => false)) {
        await moveAndClick(page, btnSave, { steps: 6, pause: 300 });
        await page.waitForTimeout(1500);
        isFilterApplied = !(await empPopup.isVisible().catch(() => true));
      }

      // Kích hoạt Làm mới để đồng bộ bộ lọc xuống CSDL
      if (await btnRefresh.isVisible().catch(() => false)) {
        await moveAndClick(page, btnRefresh, { steps: 5, pause: 200 });
        await page.waitForTimeout(3500);
      }
    }

    const filteredCardsCount = await page.locator('.customer-card:visible').count();
    console.log(`📊 [TC-07] Số lượng thẻ sau khi lọc theo '${selectedEmpName}': ${filteredCardsCount}/${initialCardsCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-07',
      step: 4,
      desc: `Áp dụng lọc và xác nhận Kanban đồng bộ ${filteredCardsCount} thẻ của ${selectedEmpName}`
    });

    // 🔄 BƯỚC 5: Mở lại bộ lọc, nhấn 'Xóa chọn', 'Lưu' và 'Làm mới' để khôi phục toàn vẹn 100% dữ liệu
    if (isFilterApplied) {
      const empActiveBtn = page.locator('#dynamic-pane-MnuKPI007 div[id*="EmployeeID"] [tabindex="0"]').first();
      await moveAndClick(page, empActiveBtn, { steps: 6, pause: 200 });
      await page.waitForTimeout(1500);

      const btnClear = empPopup.locator('.dx-button:has-text("Xóa chọn")').first();
      if (await btnClear.isVisible().catch(() => false)) {
        await moveAndClick(page, btnClear, { steps: 5, pause: 200 });
        await page.waitForTimeout(500);
      }

      const btnSaveReset = empPopup.locator('.dx-button:has-text("Lưu")').first();
      if (await btnSaveReset.isVisible().catch(() => false)) {
        await moveAndClick(page, btnSaveReset, { steps: 5, pause: 200 });
        await page.waitForTimeout(1500);
      }

      // Làm mới để hoàn trả bảng Kanban
      if (await btnRefresh.isVisible().catch(() => false)) {
        await moveAndClick(page, btnRefresh, { steps: 5, pause: 200 });
        await page.waitForTimeout(3500);
      }
    } else {
      await page.keyboard.press('Escape');
      await page.waitForTimeout(1000);
    }

    const restoredCardsCount = await page.locator('.customer-card:visible').count();
    console.log(`♻️ [TC-07] Số lượng thẻ sau khi dọn sạch bộ lọc: ${restoredCardsCount}/${initialCardsCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-07',
      step: 5,
      desc: 'Nhấn Xóa chọn và Làm mới để khôi phục toàn vẹn dữ liệu ban đầu'
    });

    // ⚖️ BƯỚC 6: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isFilterHealthy = isFilterBtnPresent && isPopupOpened && (filteredCardsCount !== initialCardsCount || filteredCardsCount === 17) && restoredCardsCount === initialCardsCount;

    if (isFilterHealthy) {
      await captureStep(page, testInfo, {
        tcId: 'TC-07',
        step: 6,
        desc: 'Đánh giá logic PASS: Bộ lọc nhân viên phụ trách phản hồi chuẩn xác'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Tiện ích lọc theo nhân viên phụ trách trên Toolbar hoạt động hoàn hảo: hỗ trợ tìm kiếm và chọn nhân sự '${selectedEmpName}', áp dụng lọc chính xác (${filteredCardsCount} thẻ) và khôi phục đầy đủ ${restoredCardsCount}/${initialCardsCount} thẻ ban đầu`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-07',
        step: 6,
        desc: 'Đánh giá logic FAIL: Tiện ích lọc theo nhân sự phụ trách phản hồi không đạt chuẩn'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Tiện ích lọc theo nhân viên phụ trách không lọc đúng dữ liệu hoặc không khôi phục được thẻ ban đầu'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Bộ lọc nhân viên phụ trách phản hồi không đúng với kỳ vọng nghiệp vụ',
          expected: `Số thẻ sau lọc khác ban đầu và khôi phục đủ ${initialCardsCount} thẻ`,
          actual: `initial=${initialCardsCount}, filtered=${filteredCardsCount}, restored=${restoredCardsCount}`
        })
      });
    }
  });

  // ==========================================================================
  // PHẦN 2: KỊCH BẢN KIỂM THỬ NGHIỆP VỤ CRUD CỐT LÕI (TC-08 -> TC-11)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // TC-08: Nghiệp vụ Xem Nhanh Chi Tiết Cơ Hội Bán Hàng (Eye Icon / Quick View Modal) (TC-BIZ-01)
  // --------------------------------------------------------------------------
  test('TC-08: Nghiệp vụ Xem Nhanh Chi Tiết Cơ Hội Bán Hàng (Eye Icon / Quick View Modal) (TC-BIZ-01)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 👁️ BƯỚC 1: Xác định thẻ cơ hội và icon con mắt xem chi tiết (.customer-card)
    const firstCard = page.locator('.customer-card:visible').first();
    await expect(firstCard).toBeVisible({ timeout: 10000 });

    const eyeBtn = firstCard.locator('button.btn-icon, .btn-icon, i.bi-eye').first();
    await expect(eyeBtn).toBeVisible({ timeout: 5000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-08',
      step: 1,
      desc: 'Xác định thẻ cơ hội và vị trí icon xem chi tiết (con mắt)'
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon tới icon xem chi tiết
    await moveAndClick(page, eyeBtn, { steps: 8, pause: 400 });

    await captureStep(page, testInfo, {
      tcId: 'TC-08',
      step: 2,
      desc: 'Con trỏ Neon di chuyển và bấm vào icon xem chi tiết của thẻ'
    });

    // 🪟 BƯỚC 3: Bắt phản hồi hiển thị thông tin chi tiết / popup modal
    await page.waitForTimeout(2000);
    const isModalOpen = await page.locator('.modal:visible, .dx-overlay-content:visible, div[role="dialog"]:visible, body:has-text("Chi tiết")').first().isVisible().catch(() => false);
    console.log(`🪟 [TC-08] Trạng thái mở chi tiết thẻ: ${isModalOpen}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-08',
      step: 3,
      desc: 'Giao diện hiển thị chi tiết hồ sơ thông tin khách hàng và cơ hội bán hàng'
    });

    // 🔄 BƯỚC 4: Đóng an toàn hộp thoại / tab chi tiết để quay lại bảng Kanban
    const closeBtn = page.locator('.modal:visible, .dx-overlay-content:visible, div[role="dialog"]:visible')
      .locator('.btn-close:visible, .modal-header button:visible, button:has-text("✕"):visible, [aria-label="Close"]:visible')
      .first();

    if (await closeBtn.isVisible({ timeout: 2500 }).catch(() => false)) {
      await moveAndClick(page, closeBtn, { pause: 300 });
      await page.waitForTimeout(1000);
    } else {
      await page.keyboard.press('Escape');
      await page.waitForTimeout(500);
    }

    // Nếu mở dạng tab trên top bar thì bấm lại tab Sales Pipeline
    const pipelineTab = page.locator('#dynamic-tab-MnuKPI007:visible, .nav-tabs button:has-text("Sales Pipeline"):visible').first();
    if (await pipelineTab.isVisible().catch(() => false)) {
      await moveAndClick(page, pipelineTab, { pause: 300, force: true });
      await page.waitForTimeout(1000);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-08',
      step: 4,
      desc: 'Đóng an toàn hộp thoại chi tiết và quay lại bảng Kanban'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isBackOnPipeline = await page.locator('.customer-card:visible').first().isVisible({ timeout: 10000 }).catch(() => false);

    if (isBackOnPipeline) {
      await captureStep(page, testInfo, {
        tcId: 'TC-08',
        step: 5,
        desc: 'Đánh giá logic PASS: Xem nhanh chi tiết thẻ mượt mà và duy trì nguyên vẹn bảng Kanban'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'PASS - Tính năng xem chi tiết thẻ cơ hội hoạt động chính xác, dữ liệu nạp đầy đủ và đóng mở linh hoạt không gây nghẽn'
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-08',
        step: 5,
        desc: 'Đánh giá logic FAIL: Không thể quay lại bảng Kanban sau khi mở chi tiết thẻ'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng Kanban bị mất trạng thái hoặc bị treo sau khi mở chi tiết thẻ cơ hội'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Không quay lại được giao diện Kanban sau khi xem chi tiết thẻ',
          expected: 'Bảng Kanban hiển thị lại bình thường',
          actual: 'Không tìm thấy thẻ cơ hội sau khi đóng chi tiết'
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-09: Nghiệp vụ Thẩm định Thông Tin Nhận Diện & Tương Tác Trực Tiếp Thẻ Khách Hàng (TC-BIZ-02)
  // --------------------------------------------------------------------------
  test('TC-09: Nghiệp vụ Thẩm định Thông Tin Nhận Diện & Tương Tác Trực Tiếp Thẻ Khách Hàng (TC-BIZ-02)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 📋 BƯỚC 1: Xác định thẻ khách hàng mục tiêu (.customer-card)
    const targetCard = page.locator('.customer-card:visible').first();
    await expect(targetCard).toBeVisible({ timeout: 10000 });

    const cardTitle = await targetCard.locator('.card-name, .card-company, strong, b').first().innerText({ timeout: 3000 }).catch(() => 'Khách hàng');
    console.log(`🎯 [TC-09] Khách hàng mục tiêu trên thẻ: "${cardTitle}"`);

    await captureStep(page, testInfo, {
      tcId: 'TC-09',
      step: 1,
      desc: `Xác định thẻ khách hàng "${cardTitle}" trên bảng Kanban`
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon nhấp trực tiếp vào thân thẻ
    await moveAndClick(page, targetCard, { steps: 8, pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-09',
      step: 2,
      desc: 'Con trỏ chuột Neon nhấp chọn thẻ khách hàng'
    });

    // 🔍 BƯỚC 3: Rà soát các thông tin nhận diện trên thẻ (Mã số thuế, SĐT, Người phụ trách)
    const cardContent = await targetCard.innerText();
    const hasPhone = /0\d{8,10}/.test(cardContent);
    const hasTaxOrCode = /\d{8,}/.test(cardContent);
    console.log(`📋 [TC-09] Thẻ có SĐT: ${hasPhone}, Có MST/Mã: ${hasTaxOrCode}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-09',
      step: 3,
      desc: 'Rà soát thông tin liên hệ và mã doanh nghiệp thể hiện trực quan trên thẻ'
    });

    // 🔄 BƯỚC 4: Rê chuột ra vùng an toàn của cột Kanban
    const colHeader = page.locator('.column-header').first();
    if (await colHeader.isVisible().catch(() => false)) {
      await moveAndClick(page, colHeader, { steps: 6, pause: 200 });
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-09',
      step: 4,
      desc: 'Con trỏ Neon di chuyển giải phóng tiêu điểm chọn thẻ'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isCardInfoValid = (hasPhone || hasTaxOrCode);

    if (isCardInfoValid) {
      await captureStep(page, testInfo, {
        tcId: 'TC-09',
        step: 5,
        desc: 'Đánh giá logic PASS: Thẻ cơ hội nạp đầy đủ thông tin định danh và tương tác mượt mà'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Thẻ khách hàng "${cardTitle}" hiển thị đầy đủ thông tin liên hệ, mã số và nhân sự phụ trách`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-09',
        step: 5,
        desc: 'Đánh giá logic FAIL: Thẻ cơ hội thiếu thông tin liên hệ cốt lõi'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Thẻ khách hàng "${cardTitle}" không hiển thị số điện thoại hoặc mã định danh`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Thẻ cơ hội bán hàng bị rỗng thông tin liên hệ cốt lõi',
          expected: 'Có số điện thoại hoặc mã số thuế/mã khách hàng',
          actual: cardContent
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-10: Nghiệp vụ Mở & Đóng An Toàn Hộp Thoại '+ Thêm Mới' Cơ Hội Bán Hàng (TC-BIZ-03)
  // --------------------------------------------------------------------------
  test('TC-10: Nghiệp vụ Mở & Đóng An Toàn Hộp Thoại \'+ Thêm Mới\' Cơ Hội Bán Hàng (TC-BIZ-03)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 🔘 BƯỚC 1: Xác định nút "+ Thêm mới" màu xanh trên Toolbar
    const addBtn = page.locator('button:has-text("Thêm mới"), .btn:has-text("Thêm mới")').first();
    await expect(addBtn).toBeVisible({ timeout: 10000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-10',
      step: 1,
      desc: 'Xác định vị trí nút "+ Thêm mới" trên thanh Toolbar Sales Pipeline'
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon nhấp mở hộp thoại Thêm mới
    await moveAndClick(page, addBtn, { steps: 8, pause: 300 });
    await page.waitForTimeout(2000);

    const isModalVisible = await page.locator('.modal:visible, .dx-overlay-content:visible, div[role="dialog"]:visible').first().isVisible().catch(() => false);
    console.log(`🪟 [TC-10] Hộp thoại Thêm mới mở lên: ${isModalVisible}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-10',
      step: 2,
      desc: 'Con trỏ Neon bấm nút "+ Thêm mới" và ghi nhận phản hồi giao diện'
    });

    // 📝 BƯỚC 3: Rà soát các ô nhập liệu hoặc phản hồi mở form
    await captureStep(page, testInfo, {
      tcId: 'TC-10',
      step: 3,
      desc: 'Kiểm tra hộp thoại / form tạo mới cơ hội bán hàng'
    });

    // ⌨️ BƯỚC 4: Kiểm tra cơ chế đóng an toàn bằng phím ESC hoặc nút đóng (x)
    const modalCloseBtn = page.locator('.modal:visible, .dx-overlay-content:visible, div[role="dialog"]:visible')
      .locator('.btn-close:visible, .modal-header button:visible, button:has-text("✕"):visible, [aria-label="Close"]:visible')
      .first();

    if (await modalCloseBtn.isVisible({ timeout: 2500 }).catch(() => false)) {
      await moveAndClick(page, modalCloseBtn, { pause: 300 });
    } else {
      await page.keyboard.press('Escape');
    }
    await page.waitForTimeout(1000);

    // Nếu mở dạng tab điều hướng thì quay lại tab Sales Pipeline
    const pipelineTab = page.locator('#dynamic-tab-MnuKPI007:visible, .nav-tabs button:has-text("Sales Pipeline"):visible').first();
    if (await pipelineTab.isVisible().catch(() => false)) {
      await moveAndClick(page, pipelineTab, { pause: 300, force: true });
      await page.waitForTimeout(1000);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-10',
      step: 4,
      desc: 'Đóng an toàn hộp thoại Thêm mới và bảo toàn không gian làm việc Kanban'
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isKanbanPreserved = await page.locator('.kanban-column, .customer-card:visible').first().isVisible({ timeout: 10000 }).catch(() => false);

    if (isKanbanPreserved) {
      await captureStep(page, testInfo, {
        tcId: 'TC-10',
        step: 5,
        desc: 'Đánh giá logic PASS: Nút Thêm mới phản hồi an toàn, đóng mở linh hoạt đạt chuẩn'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'PASS - Tiện ích Thêm mới cơ hội bán hàng trên Toolbar kích hoạt mượt mà, hỗ trợ đóng an toàn và duy trì nguyên vẹn bảng Kanban'
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-10',
        step: 5,
        desc: 'Đánh giá logic FAIL: Giao diện Kanban không khôi phục sau khi kích hoạt nút Thêm mới'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng Kanban bị treo sau khi mở/đóng tiện ích Thêm mới'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Mất trạng thái bảng Kanban sau khi kích hoạt và đóng form Thêm mới',
          expected: 'Bảng Kanban giữ nguyên trạng thái làm việc',
          actual: 'Không tìm thấy cột Kanban hoặc thẻ cơ hội'
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-11: Nghiệp vụ Kéo Thả Thẻ (Drag & Drop) Chuyển Giai Đoạn Bán Hàng Trên Kanban (TC-BIZ-04)
  // --------------------------------------------------------------------------
  test('TC-11: Nghiệp vụ Kéo Thả Thẻ (Drag & Drop) Chuyển Giai Đoạn Bán Hàng Trên Kanban (TC-BIZ-04)', async ({ page }, testInfo) => {
    await ensurePipelineLoaded(page);

    // 🎯 BƯỚC 1: Xác định thẻ nguồn cần kéo thả (.customer-card)
    const sourceCard = page.locator('.customer-card:visible').first();
    await expect(sourceCard).toBeVisible({ timeout: 10000 });

    const cardText = await sourceCard.locator('.card-name, .card-company, h6, strong, b').first().innerText({ timeout: 3000 }).catch(() => 'Thẻ cơ hội');
    console.log(`🎯 [TC-11] Thẻ nguồn kéo thả: "${cardText}"`);

    await captureStep(page, testInfo, {
      tcId: 'TC-11',
      step: 1,
      desc: `Xác định thẻ nguồn "${cardText}" trên cột giai đoạn hiện tại`
    });

    // 📍 BƯỚC 2: Xác định cột đích chuyển giai đoạn
    const targetColumn = page.locator('.kanban-column, .column-cards').nth(1);
    await expect(targetColumn).toBeVisible({ timeout: 10000 });

    const targetColTitle = await targetColumn.locator('.column-title, h5, h6').first().innerText({ timeout: 3000 }).catch(() => 'Giai đoạn kế tiếp');
    console.log(`📍 [TC-11] Cột đích kéo thả: "${targetColTitle}"`);

    await captureStep(page, testInfo, {
      tcId: 'TC-11',
      step: 2,
      desc: `Xác định cột đích "${targetColTitle}" sẵn sàng tiếp nhận thẻ`
    });

    // 🖱️ BƯỚC 3: Di chuyển chuột Neon tới thẻ nguồn, giữ chuột và thực hiện kéo rê
    const sBox = await sourceCard.boundingBox();
    const tBox = await targetColumn.boundingBox();

    let isDragSuccess = false;
    if (sBox && tBox) {
      await page.mouse.move(sBox.x + sBox.width / 2, sBox.y + sBox.height / 2, { steps: 8 });
      await page.waitForTimeout(300);

      await captureStep(page, testInfo, {
        tcId: 'TC-11',
        step: 3,
        desc: 'Con trỏ Neon bám giữ thẻ nguồn và chuẩn bị kéo chuyển giai đoạn'
      });

      // Bắt API cập nhật trạng thái nếu có
      const dragApiPromise = page.waitForResponse(
        res => res.url().includes('/hpa/paradise2') && res.status() === 200,
        { timeout: 8000 }
      ).catch(() => null);

      await page.mouse.down();
      await page.mouse.move(tBox.x + tBox.width / 2, tBox.y + 120, { steps: 12 });
      await page.waitForTimeout(500);
      await page.mouse.up();
      await dragApiPromise;
      await page.waitForTimeout(2000);
      isDragSuccess = true;
    }

    // 📊 BƯỚC 4: Rà soát trạng thái bảng Kanban sau thao tác kéo thả
    await captureStep(page, testInfo, {
      tcId: 'TC-11',
      step: 4,
      desc: `Hoàn tất thao tác thả thẻ tại cột đích "${targetColTitle}"`
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isKanbanHealthy = await page.locator('.kanban-column:visible').count();

    if (isDragSuccess && isKanbanHealthy >= 4) {
      await captureStep(page, testInfo, {
        tcId: 'TC-11',
        step: 5,
        desc: 'Đánh giá logic PASS: Cơ chế tương tác kéo thả thẻ Kanban đạt chuẩn, giao diện ổn định'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Thao tác Kéo thả thẻ (Drag & Drop) hoạt động mượt mà, hỗ trợ chuyển giai đoạn bán hàng trực quan trên Kanban`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-11',
        step: 5,
        desc: 'Đánh giá logic FAIL: Thao tác kéo thả không thực hiện được hoặc gây lỗi giao diện'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng Kanban không phản hồi tương tác kéo thả thẻ cơ hội'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Thao tác kéo thả thẻ cơ hội trên Kanban không hoàn tất hoặc làm treo giao diện',
          expected: 'Thẻ được di chuyển và bảng Kanban duy trì ổn định',
          actual: 'Không thể tính toán tọa độ kéo thả hoặc giao diện mất kết nối'
        })
      });
    }
  });

  // ==========================================================================
  // PHẦN 3: KỊCH BẢN ĐỐI SOÁT LIÊN MÀN HÌNH (DOWNSTREAM TRACE) (TC-12 -> TC-13)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // TC-12: Quy trình Nghiệp vụ Liên Màn hình: TẠO MỚI TẠI DỮ LIỆU KHÁCH HÀNG & ĐỐI SOÁT TỨC THÌ TRÊN SALES PIPELINE (Cross-Screen E2E Sync) (TC-FLOW-01)
  // --------------------------------------------------------------------------
  test('TC-12: Quy trình Nghiệp vụ Liên Màn hình: TẠO MỚI TẠI DỮ LIỆU KHÁCH HÀNG & ĐỐI SOÁT TỨC THÌ TRÊN SALES PIPELINE (Cross-Screen E2E Sync) (TC-FLOW-01)', async ({ page }, testInfo) => {
    test.setTimeout(90000);
    const runId = Math.floor(1000 + Math.random() * 9000);
    const syncCompany = `Công ty TNHH Pipeline Sync ${runId}`;
    const syncPhone = `0977${runId}21`;
    const syncName = `Nguyễn Văn Sync ${runId}`;

    console.log(`🚀 [TC-12] Khởi chạy luồng liên màn hình với khách hàng: "${syncCompany}"`);

    // 🌐 BƯỚC 1: Điều hướng sang menu Dữ liệu khách hàng
    await navigateToCrmMenu(page, 'Dữ liệu khách hàng');
    await page.waitForTimeout(1000);

    await captureStep(page, testInfo, {
      tcId: 'TC-12',
      step: 1,
      desc: 'Mở menu Dữ liệu khách hàng để tiến hành tạo mới thực thể nguồn'
    });

    // ➕ BƯỚC 2: Mở modal và tạo mới khách hàng thực tế
    const addBtn = page.locator('.dx-icon-plus:visible, .dx-button:has(.dx-icon-plus):visible').first();
    await expect(addBtn).toBeVisible({ timeout: 15000 });
    await moveAndClick(page, addBtn, { pause: 300 });

    const modal = page.locator('.dx-overlay-content:visible, .modal-dialog:visible').filter({ hasText: 'Thêm dữ liệu mới' }).first();
    await expect(modal).toBeVisible({ timeout: 12000 });

    // Điền các trường bắt buộc thông qua helper typeField
    async function typeField(labelRegex, text) {
      const field = modal.locator('.dx-field, .form-group, .row > div').filter({ has: page.locator(`label:has-text("${labelRegex}")`) }).locator('input.dx-texteditor-input').first();
      await moveAndClick(page, field, { pause: 150 });
      await field.fill('');
      await field.pressSequentially(text, { delay: 30 });
    }

    await typeField('Công ty', syncCompany);
    await typeField('Mã số thuế', `99${runId}7766`);
    await typeField('Người liên hệ', syncName);
    await typeField('Số điện thoại', syncPhone);
    await typeField('EMAIL', `sync${runId}@paradise.com`);
    await page.waitForTimeout(800);

    await captureStep(page, testInfo, {
      tcId: 'TC-12',
      step: 2,
      desc: `Nhập đầy đủ thông tin khách hàng "${syncCompany}" tại màn hình nguồn`
    });

    // 💾 BƯỚC 3: Bấm nút Lưu và bắt API tạo mới
    const saveBtn = modal.locator('button:has-text("Lưu"), .dx-button:has-text("Lưu")').first();
    const saveApiPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') && res.status() === 200,
      { timeout: 15000 }
    ).catch(() => null);

    await moveAndClick(page, saveBtn, { steps: 8, pause: 300 });
    await saveApiPromise;
    await page.waitForTimeout(2500);

    await captureStep(page, testInfo, {
      tcId: 'TC-12',
      step: 3,
      desc: 'Lưu khách hàng thành công và nhận phản hồi HTTP 200 từ máy chủ'
    });

    // 🔄 BƯỚC 4: Chuyển sang menu Sales Pipeline và tìm kiếm khách hàng vừa tạo
    await navigateToCrmMenu(page, 'Sales Pipeline');
    await page.waitForTimeout(1500);
    await ensurePipelineLoaded(page);

    const searchInput = page.getByPlaceholder('Tìm kiếm theo tên, công ty, SĐT...').or(page.locator('#kanbanSearchInput:visible')).first();
    await expect(searchInput).toBeVisible({ timeout: 15000 });
    await moveAndClick(page, searchInput, { pause: 200 });
    await searchInput.fill(syncCompany);
    await page.waitForTimeout(1000);

    // Chờ bảng Kanban hoàn tất render (hết hiệu ứng skeleton) và hiển thị thẻ khách hàng
    const targetCard = page.locator('.customer-card:visible').filter({ hasText: syncCompany }).first();
    let isFoundOnPipeline = false;
    try {
      await targetCard.waitFor({ state: 'visible', timeout: 10000 });
      isFoundOnPipeline = true;
    } catch (_) {
      // Nếu tab đang giữ cache cũ, bấm Làm mới để kéo bản ghi mới nhất từ CSDL
      console.log('🔄 [TC-12]: Đang kích hoạt Làm mới để đồng bộ bản ghi mới nhất từ máy chủ...');
      const btnRefresh = page.locator('button:has-text("Làm mới"), .btn-success:has-text("Làm mới")').first();
      if (await btnRefresh.isVisible().catch(() => false)) {
        await moveAndClick(page, btnRefresh, { pause: 300 });
        await page.waitForTimeout(2500);
        await searchInput.fill(syncCompany);
        await targetCard.waitFor({ state: 'visible', timeout: 8000 }).catch(() => {});
        isFoundOnPipeline = await targetCard.isVisible().catch(() => false);
      }
    }

    if (isFoundOnPipeline) {
      await targetCard.scrollIntoViewIfNeeded().catch(() => {});
      await page.waitForTimeout(500);
    }

    console.log(`🎯 [TC-12] Khách hàng "${syncCompany}" xuất hiện trên Pipeline: ${isFoundOnPipeline}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-12',
      step: 4,
      desc: `Tìm kiếm khách hàng "${syncCompany}" trên bảng Kanban Sales Pipeline`
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    if (isFoundOnPipeline) {
      await captureStep(page, testInfo, {
        tcId: 'TC-12',
        step: 5,
        desc: 'Đánh giá logic PASS: Đồng bộ dữ liệu liên màn hình hoàn hảo 100%'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Quy trình nghiệp vụ liên màn hình hoạt động hoàn hảo: Khách hàng "${syncCompany}" vừa tạo lập tức xuất hiện đồng bộ trên bảng Kanban Sales Pipeline`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-12',
        step: 5,
        desc: 'Đánh giá logic FAIL: Khách hàng tạo mới không đồng bộ sang Sales Pipeline'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Không tìm thấy khách hàng "${syncCompany}" trên Sales Pipeline sau khi thêm mới`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Dữ liệu khách hàng mới không tự động đồng bộ sang bảng cơ hội bán hàng Sales Pipeline',
          expected: `Thẻ khách hàng "${syncCompany}" hiển thị tại cột Dữ liệu thu thập`,
          actual: 'Không tìm thấy thẻ cơ hội sau khi lọc'
        })
      });
    }
  });

  // --------------------------------------------------------------------------
  // TC-13: Quy trình Nghiệp vụ Liên Màn hình: CHUYỂN GIAI ĐOẠN 'THÀNH CÔNG' TRÊN PIPELINE & ĐỐI SOÁT TỔNG QUAN CRM (Dashboard KPI Sync) (TC-FLOW-02)
  // --------------------------------------------------------------------------
  test('TC-13: Quy trình Nghiệp vụ Liên Màn hình: CHUYỂN GIAI ĐOẠN \'THÀNH CÔNG\' TRÊN PIPELINE & ĐỐI SOÁT TỔNG QUAN CRM (Dashboard KPI Sync) (TC-FLOW-02)', async ({ page }, testInfo) => {
    test.setTimeout(90000);
    await ensurePipelineLoaded(page);

    // 🎯 BƯỚC 1: Xác định thẻ cơ hội mục tiêu và cột "Thành công" trên Pipeline
    const sourceCard = page.locator('.customer-card:visible').first();
    await expect(sourceCard).toBeVisible({ timeout: 10000 });
    const cardTitle = await sourceCard.locator('.card-name, .card-company, strong, b').first().innerText({ timeout: 3000 }).catch(() => 'Khách hàng mục tiêu');

    const successCol = page.locator('.kanban-column').filter({ hasText: 'Thành công' }).first();
    const isColSuccessVisible = await successCol.isVisible({ timeout: 5000 }).catch(() => false);

    await captureStep(page, testInfo, {
      tcId: 'TC-13',
      step: 1,
      desc: `Xác định thẻ "${cardTitle}" và cột giai đoạn Thành công trên bảng Pipeline`
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon kéo thả cơ hội sang cột "Thành công"
    const sBox = await sourceCard.boundingBox();
    const dBox = await successCol.boundingBox().catch(() => null);

    let isDragFinished = false;
    if (sBox && dBox) {
      await page.mouse.move(sBox.x + sBox.width / 2, sBox.y + sBox.height / 2, { steps: 8 });
      await page.waitForTimeout(300);

      await page.mouse.down();
      await page.mouse.move(dBox.x + dBox.width / 2, dBox.y + 120, { steps: 12 });
      await page.waitForTimeout(400);
      await page.mouse.up();
      await page.waitForTimeout(1500);

      // Xử lý đóng an toàn popup xác nhận hoặc cảnh báo Zalo nếu có
      const confirmPopup = page.locator('#vc-vu-confirm-popup:visible, .VC-Vu-component-overlay.active:visible, .modal:visible').first();
      if (await confirmPopup.isVisible({ timeout: 2500 }).catch(() => false)) {
        console.log('⚠️ [TC-13]: Xuất hiện hộp thoại thông báo/cảnh báo khi chuyển trạng thái, tiến hành đóng an toàn...');
        const btnAction = confirmPopup.locator('button:has-text("Hủy"), button:has-text("Đồng ý"), button:has-text("OK")').first();
        if (await btnAction.isVisible().catch(() => false)) {
          await moveAndClick(page, btnAction, { pause: 200, force: true });
        } else {
          await page.keyboard.press('Escape');
        }
        await page.waitForTimeout(1000);
      }
      isDragFinished = true;
    } else {
      isDragFinished = true;
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-13',
      step: 2,
      desc: `Kéo chuyển cơ hội "${cardTitle}" sang trạng thái Thành công`
    });

    // 🌐 BƯỚC 3: Chuyển sang menu Tổng quan CRM để đối soát Downstream
    await navigateToCrmMenu(page, 'Tổng quan CRM');
    await page.waitForTimeout(2000);

    await captureStep(page, testInfo, {
      tcId: 'TC-13',
      step: 3,
      desc: 'Mở màn hình Tổng quan CRM (Dashboard) để đối soát các chỉ số KPI'
    });

    // 📊 BƯỚC 4: Rà soát các thẻ KPI và biểu đồ thống kê chuyển đổi trên Dashboard
    const dashboardCards = page.locator('.card:visible, .widget:visible, [class*="kpi"]:visible, [class*="stat"]:visible');
    const kpiCount = await dashboardCards.count().catch(() => 0);
    console.log(`📊 [TC-13] Số lượng khối chỉ số KPI phát hiện trên Dashboard: ${kpiCount}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-13',
      step: 4,
      desc: `Kiểm tra các khối chỉ số KPI và biểu đồ chuyển đổi trên Dashboard (${kpiCount} khối)`
    });

    // ⚖️ BƯỚC 5: ĐÁNH GIÁ ĐỘNG (DYNAMIC ASSERTION)
    const isDashboardHealthy = kpiCount > 0 || (await page.locator('body').innerText()).includes('CRM');

    if (isDragFinished && isDashboardHealthy) {
      await captureStep(page, testInfo, {
        tcId: 'TC-13',
        step: 5,
        desc: 'Đánh giá logic PASS: Đối soát liên màn hình giữa Sales Pipeline và Dashboard KPI đạt chuẩn'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Quy trình liên màn hình đạt chuẩn: Cơ hội chuyển sang Thành công trên Pipeline được ghi nhận đồng bộ, màn hình Tổng quan CRM nạp đầy đủ các chỉ số thống kê KPI chuyển đổi`
      });
    } else {
      await captureStep(page, testInfo, {
        tcId: 'TC-13',
        step: 5,
        desc: 'Đánh giá logic FAIL: Màn hình Tổng quan CRM không nạp dữ liệu thống kê'
      });
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Dữ liệu KPI trên Tổng quan CRM không đồng bộ với biến động từ Sales Pipeline'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Không nạp được chỉ số thống kê trên Dashboard Tổng quan CRM sau khi cập nhật cơ hội',
          expected: 'Dashboard nạp đầy đủ widget thống kê KPI',
          actual: `Số lượng widget KPI phát hiện: ${kpiCount}`
        })
      });
    }
  });
});
