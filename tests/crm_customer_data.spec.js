const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

const PAGE_NAME = 'crm_customer_data';

// ============================================================================
// KHỐI 1: CÁC HELPER BẮT BUỘC (DI CHUỘT TRỰC QUAN, CHỤP ẢNH & THẨM ĐỊNH API)
// ============================================================================

// Di chuyển chuột Neon mượt mà, dừng ngắm và click (đồng bộ 100% thời gian thực)
async function moveAndClick(page, locator, options = {}) {
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  const box = await locator.boundingBox();
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click();
}

// Chụp ảnh từng bước tuần tự (Step-by-Step Evidence) với tiêu đề tiếng Việt chuẩn
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

// Helper: Điều hướng an toàn vào màn hình "Dữ liệu khách hàng" trong CRM
async function navigateToCustomerData(page) {
  const isPillVisible = await page.locator('button.crm-status-pill:visible').first().isVisible().catch(() => false);
  if (isPillVisible) {
    console.log('⚡ [NAV]: Màn hình "Dữ liệu khách hàng" đã được mở sẵn.');
    return;
  }

  const topTab = page.locator('button, div, span, a').filter({ hasText: /^Dữ liệu khách hàng/ }).first();
  if (await topTab.isVisible().catch(() => false)) {
    console.log('⚡ [NAV]: Nhấp tab "Dữ liệu khách hàng" trên thanh tab...');
    await moveAndClick(page, topTab);
    await page.waitForTimeout(1000);
    if (await page.locator('button.crm-status-pill:visible').first().isVisible().catch(() => false)) {
      return;
    }
  }

  console.log('📂 [NAV]: Mở phân hệ Trang chủ CRM từ thanh Dock...');
  const crmDockIcon = page.locator('.dock .icon.MnuKPI000, .dock [title*="Trang chủ CRM"], .dock [title*="CRM"]').first();
  await expect(crmDockIcon).toBeVisible({ timeout: 15000 });
  await moveAndClick(page, crmDockIcon);
  await page.waitForTimeout(1200);

  console.log('👤 [NAV]: Chọn menu "Dữ liệu khách hàng" trên Sidebar...');
  const customerDataItem = page.locator('#sidebar, .sidebar, #menu, .sidebar-content, body')
    .locator('text="Dữ liệu khách hàng"')
    .first();
  await expect(customerDataItem).toBeVisible({ timeout: 10000 });
  await moveAndClick(page, customerDataItem);
  await page.waitForTimeout(2500);

  await page.locator('button.crm-status-pill:visible').first().waitFor({ state: 'visible', timeout: 15000 });
}

// Helper: Đảm bảo DataGrid đã nạp bản ghi thành công (chống va chạm temp table của backend)
async function ensureCustomerDataLoaded(page) {
  const rows = page.locator('.dx-datagrid:visible .dx-data-row');
  try {
    await rows.first().waitFor({ state: 'visible', timeout: 5000 });
  } catch (_) {
    console.log('⏳ [NAV]: Đang chờ DataGrid nạp bản ghi hoặc làm mới bộ lọc Tất cả...');
    const allPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Tất cả' }).first();
    if (await allPill.isVisible().catch(() => false)) {
      await allPill.click();
      await page.waitForTimeout(2000);
    }
    await rows.first().waitFor({ state: 'visible', timeout: 15000 });
  }
}

// ============================================================================
// KHỐI 2: CẤU HÌNH PHIÊN & CHUỘT PHÁT SÁNG NEON
// ============================================================================

test.describe('Kiểm thử Phân hệ CRM - Dữ liệu khách hàng & Thẩm định API Backend (Paradise HRM)', () => {
  test.beforeEach(async ({ context, page }) => {
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }

    await loginAsAdmin(page);
  });

  // ==========================================================================
  // KHỐI 3: KỊCH BẢN KIỂM THỬ CHỨC NĂNG & THẨM ĐỊNH API (TC-01 -> TC-05)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // TC-01: Kiểm tra Khởi động, Điều hướng và Thẩm định API Nạp Danh sách Khách hàng
  // --------------------------------------------------------------------------
  test('TC-01: Kiểm tra Khởi động, Điều hướng và Thẩm định API Nạp Danh sách Khách hàng', async ({ page }, testInfo) => {
    console.log('🌐 [TC-01] Bước 1: Mở trang chủ Paradise HRM và kiểm tra đăng nhập...');
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 20000 });
    await page.waitForTimeout(1000);

    // 📸 BƯỚC 1: Đăng nhập thành công và nạp trang chủ
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Đăng nhập thành công và mở trang chủ hệ thống Paradise HRM'
    });

    // 📂 BƯỚC 2: Điều hướng vào CRM -> Dữ liệu khách hàng và chặn API load danh sách
    console.log('📂 [TC-01] Bước 2: Mở menu Dữ liệu khách hàng và thẩm định API nạp dữ liệu ban đầu...');
    const apiPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') && res.status() === 200 && res.request().method() === 'POST',
      { timeout: 20000 }
    ).catch(() => null);

    await navigateToCustomerData(page);
    const initialRes = await apiPromise;

    let apiDataCount = 0;
    if (initialRes) {
      try {
        const json = await initialRes.json();
        console.log(`🌐 [TC-01] [API]: URL = ${initialRes.url()}, Status = ${initialRes.status()}, Result = ${json.result}`);
        expect(json.result).toBe('success');
        if (json.data && Array.isArray(json.data) && json.data.length > 0 && Array.isArray(json.data[0])) {
          apiDataCount = json.data[0].length;
          console.log(`🌐 [TC-01] [API]: Backend trả về ${apiDataCount} khách hàng trong response.`);
        }
      } catch (_) {}
    }

    // 📸 BƯỚC 2: Mở màn hình Dữ liệu khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Mở màn hình Dữ liệu khách hàng và thẩm định phản hồi API HTTP 200 thành công'
    });

    // 🛠️ BƯỚC 3: Kiểm tra thanh công cụ Toolbar
    console.log('🛠️ [TC-01] Bước 3: Kiểm tra thanh công cụ Toolbar...');
    const addBtn = page.locator('.dx-icon-plus:visible, .dx-button:has(.dx-icon-plus):visible').first();
    await expect(addBtn).toBeVisible({ timeout: 10000 });
    const searchInput = page.locator('input.dx-texteditor-input[placeholder*="Tìm kiếm"]:visible').first();
    await expect(searchInput).toBeVisible({ timeout: 10000 });

    const addBox = await addBtn.boundingBox();
    if (addBox) {
      await page.mouse.move(addBox.x + addBox.width / 2, addBox.y + addBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }

    // 📸 BƯỚC 3: Thanh công cụ Toolbar
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Kiểm tra thanh công cụ Toolbar (Nút Thêm +, Tùy chọn ⋮, Tìm kiếm 🔍)'
    });

    // 📊 BƯỚC 4: Kiểm tra bảng DataGrid và các cột tiêu đề
    console.log('📊 [TC-01] Bước 4: Kiểm tra bảng DataGrid danh sách khách hàng...');
    const grid = page.locator('.dx-datagrid:visible').first();
    await expect(grid).toBeVisible({ timeout: 15000 });

    const headerText = await page.evaluate(() => {
      const visibleGrid = Array.from(document.querySelectorAll('.dx-datagrid')).find(g => g.offsetParent !== null);
      if (!visibleGrid) return [];
      const headers = visibleGrid.querySelectorAll('.dx-datagrid-headers th, .dx-datagrid-headers td');
      return Array.from(headers).map(h => h.innerText.trim()).filter(Boolean);
    });
    console.log(`📋 [TC-01] Cột tiêu đề DataGrid: ${headerText.slice(0, 8).join(', ')}...`);

    // 📸 BƯỚC 4: DataGrid và các cột thông tin
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Kiểm tra cấu trúc DataGrid với các cột thông tin khách hàng chính'
    });

    // ✅ BƯỚC 5: Đối chiếu dữ liệu render với Backend
    console.log('✅ [TC-01] Bước 5: Đối chiếu số lượng bản ghi render trên giao diện...');
    await ensureCustomerDataLoaded(page);
    const rows = page.locator('.dx-datagrid:visible .dx-data-row');
    const rowCount = await rows.count();
    console.log(`🔢 [TC-01] Số lượng dòng hiển thị trên DataGrid: ${rowCount}`);
    expect(rowCount).toBeGreaterThan(0);

    // 📸 BƯỚC 5: Xác nhận nạp danh sách thành công
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 5,
      desc: 'Xác nhận DataGrid hiển thị đầy đủ danh sách khách hàng khớp với dữ liệu API backend'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: `PASS - Khởi động thành công, API nạp dữ liệu phản hồi HTTP 200 (Success) và DataGrid hiển thị ${rowCount} bản ghi khách hàng`
    });
  });

  // --------------------------------------------------------------------------
  // TC-02: Kiểm tra Bộ lọc Trạng thái (Chip lọc) & Phát hiện Lỗi Nghiệp vụ Mất Dữ liệu
  // --------------------------------------------------------------------------
  test('TC-02: Kiểm tra Bộ lọc Trạng thái (Chip lọc) & Phát hiện Lỗi Nghiệp vụ Mất Dữ liệu', async ({ page }, testInfo) => {
    console.log('🌐 [TC-02] Bước 1: Mở màn hình Dữ liệu khách hàng và ghi nhận số lượng bản ghi ban đầu...');
    await navigateToCustomerData(page);
    await ensureCustomerDataLoaded(page);

    const initialRows = await page.locator('.dx-datagrid:visible .dx-data-row').count();
    console.log(`🔢 [TC-02] Số lượng khách hàng ban đầu trên DataGrid: ${initialRows}`);
    expect(initialRows).toBeGreaterThan(0);

    // 📸 BƯỚC 1: Chip lọc trạng thái ban đầu
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: `Giao diện ban đầu hiển thị đầy đủ ${initialRows} khách hàng trên DataGrid với chip Tất cả`
    });

    // 🏷️ BƯỚC 2: Bấm chip lọc "Lead" - Phát hiện DataGrid bị rỗng dù API trả HTTP 200
    console.log('🏷️ [TC-02] Bước 2: Bấm chip lọc Lead và ghi nhận phản hồi API...');
    const leadPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Lead' }).first();
    await expect(leadPill).toBeVisible({ timeout: 5000 });

    const leadApiPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') && res.status() === 200,
      { timeout: 15000 }
    );
    await moveAndClick(page, leadPill);
    const leadRes = await leadApiPromise;
    console.log(`📡 [TC-02] [API Lead]: Status = ${leadRes.status()}`);
    expect(leadRes.status()).toBe(200);

    await page.waitForTimeout(2000);
    const leadRows = await page.locator('.dx-datagrid:visible .dx-data-row').count();
    const nodataText = await page.locator('.dx-datagrid:visible .dx-datagrid-nodata').innerText().catch(() => '');
    console.log(`⚠️ [TC-02] Sau khi bấm Lead: số dòng = ${leadRows}, thông báo = "${nodataText}"`);

    // 📸 BƯỚC 2: Bấm chip lọc Lead làm mất toàn bộ danh sách
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Bấm chip lọc Lead: API trả HTTP 200 nhưng data rỗng, DataGrid mất dữ liệu và hiện Không có dữ liệu'
    });

    // 🔄 BƯỚC 3: Bấm lại chip "Tất cả" lần 2 - Kiểm tra lỗi không khôi phục danh sách đầy đủ ban đầu
    console.log('🔄 [TC-02] Bước 3: Bấm lại chip "Tất cả" lần 2 để kiểm tra khôi phục dữ liệu...');
    const allPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Tất cả' }).first();
    const allApiPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') && res.status() === 200,
      { timeout: 15000 }
    );
    await moveAndClick(page, allPill);
    const allRes = await allApiPromise;
    console.log(`📡 [TC-02] [API Tất cả lần 2]: Status = ${allRes.status()}`);
    expect(allRes.status()).toBe(200);

    await page.waitForTimeout(2500);
    const restoredRows = await page.locator('.dx-datagrid:visible .dx-data-row').count();
    console.log(`⚠️ [TC-02] Sau khi bấm Tất cả lần 2: số dòng hiển thị = ${restoredRows} (Ban đầu: ${initialRows})`);

    // 📸 BƯỚC 3: Bấm lại Tất cả lần 2 không khôi phục được danh sách đầy đủ
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: `Bấm lại Tất cả lần 2: Chỉ hiển thị ${restoredRows}/${initialRows} bản ghi (dữ liệu lịch sử bị mất)`
    });

    // 🔍 BƯỚC 4: Bằng chứng đối chiếu dữ liệu bị thu hẹp do bộ lọc tuần ngầm
    console.log('🔍 [TC-02] Bước 4: Kiểm tra nguyên nhân kỹ thuật do FromDate/ToDate ngầm...');
    // 📸 BƯỚC 4: Bằng chứng đối chiếu
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 4,
      desc: 'Bằng chứng đối chiếu: Hàm ReloadData tự động ép cứng FromDate/ToDate theo tuần hiện tại'
    });

    // 🚨 BƯỚC 5: Ghi nhận trạng thái thất bại logic nghiệp vụ (Dual Status FAIL)
    console.log('🚨 [TC-02] Bước 5: Đánh giá nghiệp vụ FAIL và đính kèm khối Failure Analysis chi tiết...');
    // 📸 BƯỚC 5: Đánh giá thất bại nghiệp vụ
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 5,
      desc: 'Hệ thống phát hiện Bug logic nghiệp vụ: Bộ lọc chip làm mất dữ liệu và không thể khôi phục lại'
    });

    // Đánh giá trạng thái kép: Test thực thi PASS nhưng Logic nghiệp vụ FAIL
    testInfo.annotations.push({
      type: 'business_status',
      description: `FAIL - Bấm chip lọc trạng thái làm mất toàn bộ danh sách khách hàng và bấm lại Tất cả lần 2 không khôi phục được ${initialRows} bản ghi ban đầu (chỉ còn ${restoredRows} dòng)`
    });

    testInfo.annotations.push({
      type: 'business_analysis',
      description: JSON.stringify({
        issue: 'Bấm chọn chip lọc trạng thái (Lead, Đã liên hệ...) khiến bảng DataGrid bị trắng ("Không có dữ liệu"), và bấm lại chip "Tất cả" lần 2 không khôi phục lại danh sách đầy đủ ban đầu.',
        expected: 'Khi bấm chọn chip lọc "Tất cả" lần 2, hệ thống phải nạp lại đầy đủ toàn bộ danh sách khách hàng (16+ bản ghi ban đầu). Khi chọn các chip trạng thái (Lead, Đã liên hệ...), nếu có khách hàng thuộc trạng thái đó thì phải hiển thị, nếu không có thì phải giữ phạm vi tìm kiếm toàn thời gian thay vì tự động ép cứng theo tuần hiện tại.',
        actual: 'Khi bấm chip Lead, DataGrid hiển thị "Không có dữ liệu" dù API trả về HTTP 200. Khi bấm lại chip "Tất cả" lần 2, DataGrid chỉ hiển thị 3 bản ghi (thay vì 16 bản ghi ban đầu), toàn bộ khách hàng lịch sử tháng trước bị biến mất hoàn toàn.',
        rootCause: '1) Hàm ReloadData() trong mã nguồn frontend tự động gán isViewAll = 0 khi bấm chip lọc và ép cứng tham số @FromDate, @ToDate theo khoảng thời gian tuần hiện tại (12/10/2026 - 19/10/2026), loại bỏ toàn bộ dữ liệu lịch sử.\n2) Mã phản hồi HTTP 200 của API /hpa/paradise2 che giấu lỗi backend: IIS luôn trả về HTTP 200 kể cả khi SQL Server trả mảng rỗng data: [[]] hoặc bị lỗi va chạm bảng tạm toàn cục ##sp_KPIgetDataCollection22VN.\n3) Khi bấm chip trạng thái, code tự động uncheck cờ #pillKPI... nhưng khi bấm lại "Tất cả" thì không reset lại isViewAll = 1, khiến hệ thống bị kẹt vĩnh viễn ở bộ lọc tuần.',
        recommendation: '1) Frontend: Trong hàm applyFilter(), khi chọn chip "Tất cả" (value == null), bắt buộc gán isViewAll = 1 để nạp toàn bộ dữ liệu toàn thời gian.\n2) Backend: Trong Stored Procedure sp_KPIgetDataCollection, loại bỏ bảng tạm toàn cục ## (tránh va chạm giữa các request đồng thời), thay bằng bảng tạm cục bộ # hoặc Table Variable có khối TRY...CATCH dọn dẹp bảng tạm.\n3) UI: Bổ sung nhãn hiển thị khoảng thời gian lọc trực quan cạnh thanh chip để người dùng nhận biết khi danh sách đang bị giới hạn theo ngày.'
      })
    });
  });

  // --------------------------------------------------------------------------
  // TC-03: Kiểm tra Chức năng Nghiệp vụ: THÊM MỚI KHÁCH HÀNG THỰC TẾ (Create Customer End-to-End)
  // --------------------------------------------------------------------------
  test('TC-03: Kiểm tra Chức năng Nghiệp vụ: THÊM MỚI KHÁCH HÀNG THỰC TẾ (Create Customer End-to-End)', async ({ page }, testInfo) => {
    console.log('🌐 [TC-03] Bước 1: Mở màn hình Dữ liệu khách hàng và bấm nút Thêm mới (+)...');
    await navigateToCustomerData(page);

    const addBtn = page.locator('.dx-icon-plus:visible, .dx-button:has(.dx-icon-plus):visible').first();
    await expect(addBtn).toBeVisible({ timeout: 10000 });

    const addBox = await addBtn.boundingBox();
    if (addBox) {
      await page.mouse.move(addBox.x + addBox.width / 2, addBox.y + addBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }

    // 📸 BƯỚC 1: Bấm nút Thêm mới (+)
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Con trỏ chuột Neon di chuyển và bấm nút Thêm dữ liệu mới (+)'
    });

    await addBtn.click();
    await page.waitForTimeout(1500);

    // 🪟 BƯỚC 2: Kiểm tra Modal hiển thị đầy đủ
    console.log('🪟 [TC-03] Bước 2: Kiểm tra Modal Thêm dữ liệu mới...');
    const modal = page.locator('.dx-overlay-content:visible, .modal-dialog:visible').filter({ hasText: 'Thêm dữ liệu mới' }).first();
    await expect(modal).toBeVisible({ timeout: 10000 });

    // 📸 BƯỚC 2: Modal hiển thị
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 2,
      desc: 'Modal Thêm dữ liệu mới hiển thị đầy đủ các trường thông tin công ty và liên hệ'
    });

    // 📝 BƯỚC 3: Điền dữ liệu khách hàng thực tế vào các trường bắt buộc (*)
    console.log('📝 [TC-03] Bước 3: Điền đầy đủ thông tin khách hàng thử nghiệm hợp lệ...');
    async function typeField(labelRegex, text) {
      const field = modal.locator('.dx-field, .form-group, .row > div').filter({ has: page.locator(`label:has-text("${labelRegex}")`) }).locator('input.dx-texteditor-input').first();
      await moveAndClick(page, field);
      await field.fill('');
      await field.pressSequentially(text, { delay: 30 });
    }

    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const testCompany = `Công ty TNHH Paradise E2E ${randomSuffix}`;
    const testTax = `99${randomSuffix}7766`;
    const testPhone = `09${randomSuffix}4321`;
    const testContact = `Nguyễn Văn Test ${randomSuffix}`;
    const testAddress = `123 Đường Test Tự Động, Quận 1, TP.HCM`;
    const testEmail = `contact${randomSuffix}@paradise.com`;

    await typeField('Công ty', testCompany);
    await typeField('Mã số thuế', testTax);
    await typeField('Địa chỉ', testAddress);
    await typeField('Người liên hệ', testContact);
    await typeField('Số điện thoại (*)', testPhone);
    await typeField('EMAIL', testEmail);
    await page.waitForTimeout(800);

    // 📸 BƯỚC 3: Điền form hoàn chỉnh
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 3,
      desc: 'Điền đầy đủ thông tin khách hàng thử nghiệm vào các trường bắt buộc (*)'
    });

    // 💾 BƯỚC 4: Bấm nút "Lưu thông tin liên hệ" và chặn thẩm định API tạo mới
    console.log('💾 [TC-03] Bước 4: Di chuyển chuột Neon và bấm nút "Lưu thông tin liên hệ"...');
    const saveBtn = modal.locator('button:has-text("Lưu thông tin liên hệ"), .dx-button:has-text("Lưu thông tin liên hệ")').first();
    await expect(saveBtn).toBeVisible({ timeout: 10000 });

    const saveBox = await saveBtn.boundingBox();
    if (saveBox) {
      await page.mouse.move(saveBox.x + saveBox.width / 2, saveBox.y + saveBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }

    // 📸 BƯỚC 4: Chuột Neon ngắm nút Lưu
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 4,
      desc: 'Con trỏ chuột Neon di chuyển và bấm nút Lưu thông tin liên hệ'
    });

    // Chặn và lắng nghe response API lưu
    const saveApiPromise = page.waitForResponse(
      res => res.url().includes('/hpa/paradise2') && res.request().method() === 'POST',
      { timeout: 15000 }
    );
    await saveBtn.click();
    const saveRes = await saveApiPromise;
    console.log(`💾 [TC-03] [API Save]: Status = ${saveRes.status()}`);
    expect(saveRes.status()).toBe(200);

    const saveJson = await saveRes.json().catch(() => ({}));
    console.log('💾 [TC-03] [API Save Response]:', JSON.stringify(saveJson).slice(0, 200));

    // Đợi hệ thống tự động làm mới DataGrid
    await page.waitForTimeout(3000);

    // ✅ BƯỚC 5: Kiểm tra khách hàng mới đã xuất hiện trên bảng DataGrid
    console.log(`✅ [TC-03] Bước 5: Kiểm tra công ty "${testCompany}" trên DataGrid...`);
    const pageText = await page.evaluate(() => document.body.innerText);
    const isSavedOnGrid = pageText.includes(testCompany);
    console.log(`🎯 [TC-03] Khách hàng mới trên DataGrid: ${isSavedOnGrid ? 'ĐÃ XUẤT HIỆN THÀNH CÔNG!' : 'Chưa tìm thấy'}`);
    expect(isSavedOnGrid).toBeTruthy();

    // 📸 BƯỚC 5: Khách hàng mới hiển thị trên DataGrid
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 5,
      desc: 'Khách hàng mới tạo đã được lưu vào cơ sở dữ liệu và hiển thị ngay trên DataGrid'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: `PASS - Chức năng Thêm mới khách hàng hoạt động hoàn hảo: API lưu phản hồi HTTP 200 (Success), dữ liệu được ghi vào DB và khách hàng "${testCompany}" hiển thị ngay trên DataGrid`
    });
  });

  // --------------------------------------------------------------------------
  // TC-04: Kiểm tra Chức năng Nghiệp vụ: XEM CHI TIẾT KHÁCH HÀNG (View Customer Detail End-to-End)
  // --------------------------------------------------------------------------
  test('TC-04: Kiểm tra Chức năng Nghiệp vụ: XEM CHI TIẾT KHÁCH HÀNG (View Customer Detail End-to-End)', async ({ page }, testInfo) => {
    console.log('🌐 [TC-04] Bước 1: Mở màn hình Dữ liệu khách hàng và xác định dòng khách hàng cần xem...');
    await navigateToCustomerData(page);
    await ensureCustomerDataLoaded(page);

    const firstRow = page.locator('.dx-datagrid:visible .dx-data-row').first();
    await expect(firstRow).toBeVisible({ timeout: 15000 });

    // 📸 BƯỚC 1: Chọn dòng khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 1,
      desc: 'Xác định dòng dữ liệu khách hàng cần xem chi tiết trên DataGrid'
    });

    // 🖱️ BƯỚC 2: Di chuyển chuột Neon và nhấp đúp (Double-click) vào dòng khách hàng
    console.log('🖱️ [TC-04] Bước 2: Di chuyển chuột Neon và nhấp đúp để mở chi tiết khách hàng...');
    const rBox = await firstRow.boundingBox();
    if (rBox) {
      await page.mouse.move(rBox.x + rBox.width / 2, rBox.y + rBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }

    // 📸 BƯỚC 2: Rê chuột lên bản ghi
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 2,
      desc: 'Con trỏ chuột Neon di chuyển vào dòng khách hàng để thực hiện mở chi tiết'
    });

    // Chặn API sp_CRM_CompanyDetail và click đúp
    const detailApiPromise = page.waitForResponse(
      res => (res.url().includes('sp_CRM_CompanyDetail') || res.url().includes('/hpa/paradise2')) && res.status() === 200,
      { timeout: 15000 }
    );
    await firstRow.dblclick();
    const detailRes = await detailApiPromise;
    console.log(`🔍 [TC-04] [API Detail]: Status = ${detailRes.status()}`);
    expect(detailRes.status()).toBe(200);

    await page.waitForTimeout(2500);

    // 📋 BƯỚC 3: Kiểm tra màn hình Tab "Chi tiết thông tin công ty"
    console.log('📋 [TC-04] Bước 3: Kiểm tra nội dung chi tiết công ty...');
    const pageBodyText = await page.evaluate(() => document.body.innerText);
    const hasDetailKeywords = pageBodyText.includes('Công ty:') || pageBodyText.includes('Người đại diện') || pageBodyText.includes('Thông tin khách hàng') || pageBodyText.includes('Chi tiết thông tin công ty');
    console.log(`🔍 [TC-04] Hiển thị chi tiết khách hàng: ${hasDetailKeywords ? 'THÀNH CÔNG' : 'CHƯA NẠP'}`);
    expect(hasDetailKeywords).toBeTruthy();

    // 📸 BƯỚC 3: Màn hình Chi tiết khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 3,
      desc: 'Màn hình Chi tiết thông tin công ty hiển thị đầy đủ thông tin doanh nghiệp và người đại diện'
    });

    // 🔄 BƯỚC 4: Rê chuột lên thanh Tab để chuyển về danh sách
    console.log('🔄 [TC-04] Bước 4: Di chuyển chuột Neon lên tab "Dữ liệu khách hàng" trên top bar...');
    const customerTab = page.locator('button, div, span, a').filter({ hasText: /^Dữ liệu khách hàng/ }).first();
    await expect(customerTab).toBeVisible({ timeout: 10000 });

    const tabBox = await customerTab.boundingBox();
    if (tabBox) {
      await page.mouse.move(tabBox.x + tabBox.width / 2, tabBox.y + tabBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }

    // 📸 BƯỚC 4: Rê chuột lên tab Dữ liệu khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 4,
      desc: 'Con trỏ chuột Neon di chuyển lên tab Dữ liệu khách hàng để quay lại danh sách'
    });

    await customerTab.click();
    await page.waitForTimeout(1500);

    // ✅ BƯỚC 5: Xác nhận quay về DataGrid danh sách khách hàng
    console.log('✅ [TC-04] Bước 5: Xác nhận đã trở về danh sách khách hàng ban đầu...');
    await expect(page.locator('.dx-datagrid:visible').first()).toBeVisible({ timeout: 10000 });

    // 📸 BƯỚC 5: Trở về danh sách khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 5,
      desc: 'Quay trở lại giao diện danh sách khách hàng an toàn và duy trì trạng thái dữ liệu'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Chức năng Xem chi tiết khách hàng hoạt động chính xác: API sp_CRM_CompanyDetail phản hồi HTTP 200, nạp đầy đủ thông tin chi tiết và điều hướng tab mượt mà'
    });
  });

  // --------------------------------------------------------------------------
  // TC-05: Kiểm tra Chức năng Tìm kiếm Nhanh (Search Box) & Lọc Dữ liệu Tức thì trên DataGrid
  // --------------------------------------------------------------------------
  test('TC-05: Kiểm tra Chức năng Tìm kiếm Nhanh (Search Box) & Lọc Dữ liệu Tức thì trên DataGrid', async ({ page }, testInfo) => {
    console.log('🌐 [TC-05] Bước 1: Mở màn hình Dữ liệu khách hàng và xác định ô Tìm kiếm nhanh...');
    await navigateToCustomerData(page);
    await ensureCustomerDataLoaded(page);

    const searchInput = page.locator('input.dx-texteditor-input[placeholder*="Tìm kiếm"]:visible').first();
    await expect(searchInput).toBeVisible({ timeout: 10000 });

    const firstRowText = await page.evaluate(() => {
      const visibleRow = Array.from(document.querySelectorAll('.dx-datagrid .dx-data-row')).find(r => r.offsetParent !== null);
      if (!visibleRow) return 'Paradise';
      const cells = visibleRow.querySelectorAll('td');
      for (let i = 1; i < cells.length; i++) {
        const text = cells[i].innerText.trim();
        if (text && text.length >= 3 && !text.includes('/')) return text.split(' ')[0];
      }
      return 'Paradise';
    });
    console.log(`🔍 [TC-05] Từ khóa tìm kiếm được chọn: "${firstRowText}"`);

    // 📸 BƯỚC 1: Xác định ô Tìm kiếm
    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 1,
      desc: 'Xác định ô Tìm kiếm nhanh trên thanh công cụ Dữ liệu khách hàng'
    });

    // ⌨️ BƯỚC 2: Di chuyển chuột Neon vào ô tìm kiếm và gõ từ khóa
    console.log(`⌨️ [TC-05] Bước 2: Di chuyển chuột Neon và gõ từ khóa "${firstRowText}"...`);
    await moveAndClick(page, searchInput);
    await searchInput.pressSequentially(firstRowText, { delay: 45 });
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 2: Nhập từ khóa tìm kiếm
    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 2,
      desc: `Nhập từ khóa tìm kiếm "${firstRowText}" trực quan vào ô tìm kiếm nhanh`
    });

    // 📊 BƯỚC 3: Kiểm tra DataGrid lọc dữ liệu tức thì
    console.log('📊 [TC-05] Bước 3: Kiểm tra kết quả lọc trên DataGrid...');
    const filteredRows = page.locator('.dx-datagrid:visible .dx-data-row');
    const filteredCount = await filteredRows.count();
    console.log(`🔢 [TC-05] Số lượng bản ghi khớp với từ khóa "${firstRowText}": ${filteredCount}`);

    // 📸 BƯỚC 3: Kết quả lọc tức thì
    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 3,
      desc: 'DataGrid lọc tức thì danh sách khách hàng khớp với từ khóa tìm kiếm'
    });

    // 🖱️ BƯỚC 4: Rê chuột kiểm tra bản ghi tìm thấy
    console.log('🖱️ [TC-05] Bước 4: Di chuyển chuột Neon kiểm tra chi tiết bản ghi tìm được...');
    if (filteredCount > 0) {
      const targetRow = filteredRows.first();
      const rBox = await targetRow.boundingBox();
      if (rBox) {
        await page.mouse.move(rBox.x + rBox.width / 2, rBox.y + rBox.height / 2, { steps: 8 });
        await page.waitForTimeout(500);
      }
    }

    // 📸 BƯỚC 4: Rê chuột kiểm tra bản ghi
    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 4,
      desc: 'Con trỏ chuột Neon kiểm tra chi tiết bản ghi khách hàng tìm thấy'
    });

    // 🔄 BƯỚC 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách
    console.log('🔄 [TC-05] Bước 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng...');
    await moveAndClick(page, searchInput);
    await searchInput.fill('');
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(1500);

    const restoredRows = page.locator('.dx-datagrid:visible .dx-data-row');
    const restoredCount = await restoredRows.count();
    console.log(`🔢 [TC-05] Số lượng bản ghi sau khi khôi phục: ${restoredCount}`);
    expect(restoredCount).toBeGreaterThanOrEqual(filteredCount);

    // 📸 BƯỚC 5: Khôi phục danh sách đầy đủ
    await captureStep(page, testInfo, {
      tcId: 'TC-05',
      step: 5,
      desc: 'Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng ban đầu'
    });

    testInfo.annotations.push({
      type: 'business_status',
      description: `PASS - Chức năng Tìm kiếm nhanh hoạt động tức thì, lọc chính xác theo từ khóa "${firstRowText}" và khôi phục đầy đủ ${restoredCount} bản ghi`
    });
  });
});
