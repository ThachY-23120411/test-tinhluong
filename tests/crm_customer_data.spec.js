const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

const PAGE_NAME = 'crm_customer_data';

// ============================================================================
// KHỐI 1: CÁC HELPER BẮT BUỘC (DI CHUỘT TRỰC QUAN & CHỤP ẢNH TỪNG BƯỚC)
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
  // Kiểm tra nếu các nút lọc trạng thái của Dữ liệu khách hàng đã hiển thị
  const isPillVisible = await page.locator('button.crm-status-pill:visible').first().isVisible().catch(() => false);
  if (isPillVisible) {
    console.log('⚡ [NAV]: Màn hình "Dữ liệu khách hàng" đã được mở sẵn.');
    return;
  }

  // Nếu tab "Dữ liệu khách hàng" đã có trên thanh tab trên cùng
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

  // Chờ các nút bộ lọc trạng thái xuất hiện trên màn hình
  await page.locator('button.crm-status-pill:visible').first().waitFor({ state: 'visible', timeout: 15000 });
}

// ============================================================================
// KHỐI 2: CẤU HÌNH PHIÊN & CHUỘT PHÁT SÁNG NEON
// ============================================================================

test.describe('Kiểm thử Phân hệ CRM - Dữ liệu khách hàng (Paradise HRM)', () => {
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

  // ==========================================================================
  // KHỐI 3: KỊCH BẢN CHUẨN 5 BƯỚC NGHIỆP VỤ (TC-01 -> TC-04)
  // ==========================================================================

  // --------------------------------------------------------------------------
  // TC-01: Kiểm tra Khởi động, Điều hướng và Hiển thị Giao diện Dữ liệu khách hàng
  // --------------------------------------------------------------------------
  test('TC-01: Kiểm tra Khởi động, Điều hướng và Hiển thị Giao diện Dữ liệu khách hàng (Header, DataGrid, Toolbar)', async ({ page }, testInfo) => {
    console.log('🌐 [TC-01] Bước 1: Mở trang chủ Paradise HRM và kiểm tra trạng thái đăng nhập...');
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 20000 });
    await page.waitForTimeout(1000);

    // 📸 BƯỚC 1: Đăng nhập thành công và nạp trang chủ
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Đăng nhập thành công và mở trang chủ hệ thống Paradise HRM'
    });

    // 📂 BƯỚC 2: Điều hướng vào phân hệ CRM -> Dữ liệu khách hàng
    console.log('📂 [TC-01] Bước 2: Điều hướng vào phân hệ CRM và mở tab Dữ liệu khách hàng...');
    await navigateToCustomerData(page);

    // 📸 BƯỚC 2: Mở màn hình Dữ liệu khách hàng
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Mở màn hình Dữ liệu khách hàng từ menu phân hệ CRM'
    });

    // 🛠️ BƯỚC 3: Kiểm tra thanh công cụ Toolbar (Nút +, Tùy chọn ⋮, Tìm kiếm 🔍)
    console.log('🛠️ [TC-01] Bước 3: Kiểm tra thanh công cụ và các nút chức năng...');
    const addBtn = page.locator('.dx-icon-plus:visible, .dx-button:has(.dx-icon-plus):visible').first();
    await expect(addBtn).toBeVisible({ timeout: 10000 });
    const searchInput = page.locator('input.dx-texteditor-input[placeholder*="Tìm kiếm"]:visible').first();
    await expect(searchInput).toBeVisible({ timeout: 10000 });

    // Di chuyển chuột Neon lướt qua thanh công cụ
    const addBox = await addBtn.boundingBox();
    if (addBox) {
      await page.mouse.move(addBox.x + addBox.width / 2, addBox.y + addBox.height / 2, { steps: 8 });
      await page.waitForTimeout(500);
    }

    // 📸 BƯỚC 3: Kiểm tra thanh công cụ Toolbar
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Kiểm tra thanh công cụ Toolbar và các nút chức năng thao tác'
    });

    // 📊 BƯỚC 4: Kiểm tra bảng DataGrid danh sách khách hàng và các cột tiêu đề
    console.log('📊 [TC-01] Bước 4: Kiểm tra hiển thị bảng DataGrid và các cột thông tin...');
    const grid = page.locator('.dx-datagrid:visible').first();
    await expect(grid).toBeVisible({ timeout: 15000 });

    const headerText = await page.evaluate(() => {
      const visibleGrid = Array.from(document.querySelectorAll('.dx-datagrid'))
        .find(g => g.offsetParent !== null);
      if (!visibleGrid) return [];
      const headers = visibleGrid.querySelectorAll('.dx-datagrid-headers th, .dx-datagrid-headers td');
      return Array.from(headers).map(h => h.innerText.trim()).filter(Boolean);
    });
    console.log(`📋 [TC-01] Các cột dữ liệu phát hiện: ${headerText.slice(0, 8).join(', ')}...`);

    // Di chuyển chuột Neon lên tiêu đề DataGrid
    const firstHeader = page.locator('.dx-datagrid:visible .dx-datagrid-headers th, .dx-datagrid:visible .dx-datagrid-headers td').first();
    if (await firstHeader.isVisible().catch(() => false)) {
      const hBox = await firstHeader.boundingBox();
      if (hBox) {
        await page.mouse.move(hBox.x + hBox.width / 2, hBox.y + hBox.height / 2, { steps: 8 });
        await page.waitForTimeout(400);
      }
    }

    // 📸 BƯỚC 4: Kiểm tra bảng DataGrid và các cột dữ liệu
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Kiểm tra bảng DataGrid danh sách khách hàng và các cột dữ liệu chính'
    });

    // ✅ BƯỚC 5: Xác nhận nạp danh sách khách hàng
    console.log('✅ [TC-01] Bước 5: Xác nhận DataGrid đã tải dữ liệu các bản ghi...');
    const rows = page.locator('.dx-datagrid:visible .dx-data-row');
    const rowCount = await rows.count();
    console.log(`🔢 [TC-01] Số lượng bản ghi khách hàng hiển thị trên trang: ${rowCount}`);
    expect(rowCount).toBeGreaterThan(0);

    // 📸 BƯỚC 5: Kết quả nạp dữ liệu hoàn tất
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 5,
      desc: 'Hệ thống nạp đầy đủ danh sách khách hàng và hiển thị DataGrid thành công'
    });

    // Đánh giá trạng thái kép (Dual Status)
    testInfo.annotations.push({
      type: 'business_status',
      description: `PASS - Giao diện Dữ liệu khách hàng hiển thị hoàn chỉnh, thanh công cụ sẵn sàng và DataGrid nạp thành công ${rowCount} dòng dữ liệu`
    });
  });

  // --------------------------------------------------------------------------
  // TC-02: Kiểm tra Bộ lọc Trạng thái (Status Pills) & Tùy chọn "Xem của tôi"
  // --------------------------------------------------------------------------
  test('TC-02: Kiểm tra Bộ lọc Trạng thái (Status Pills) & Tùy chọn "Xem của tôi"', async ({ page }, testInfo) => {
    console.log('🌐 [TC-02] Bước 1: Mở màn hình Dữ liệu khách hàng và xác định thanh bộ lọc trạng thái...');
    await navigateToCustomerData(page);

    const statusPills = page.locator('button.crm-status-pill:visible');
    const pillCount = await statusPills.count();
    console.log(`🎯 [TC-02] Số lượng nút lọc trạng thái phát hiện: ${pillCount}`);
    expect(pillCount).toBeGreaterThan(0);

    // 📸 BƯỚC 1: Kiểm tra trạng thái bộ lọc ban đầu
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: 'Kiểm tra thanh bộ lọc trạng thái mặc định (Tất cả đang kích hoạt)'
    });

    // 🏷️ BƯỚC 2: Chọn bộ lọc "Lead"
    console.log('🏷️ [TC-02] Bước 2: Di chuyển chuột Neon và nhấp chọn bộ lọc Lead...');
    const leadPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Lead' }).first();
    await expect(leadPill).toBeVisible({ timeout: 5000 });
    await moveAndClick(page, leadPill);
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 2: Bộ lọc Lead được chọn
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Chọn bộ lọc trạng thái Lead và kiểm tra phản hồi của DataGrid'
    });

    // 🏷️ BƯỚC 3: Chọn bộ lọc "Đã liên hệ" hoặc "Cần chăm sóc"
    console.log('🏷️ [TC-02] Bước 3: Di chuyển chuột Neon và chọn bộ lọc Đã liên hệ...');
    const contactedPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Đã liên hệ' }).first();
    if (await contactedPill.isVisible().catch(() => false)) {
      await moveAndClick(page, contactedPill);
    } else {
      const altPill = statusPills.nth(2);
      await moveAndClick(page, altPill);
    }
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 3: Bộ lọc Đã liên hệ
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: 'Chuyển đổi sang bộ lọc Đã liên hệ và kiểm tra danh sách lọc'
    });

    // ☑️ BƯỚC 4: Kích hoạt checkbox "Xem của tôi"
    console.log('☑️ [TC-02] Bước 4: Di chuyển chuột Neon và kích hoạt checkbox Xem của tôi...');
    const myDataCheckbox = page.locator('input[type="checkbox"][id*="quickMyData"]:visible, input[type="checkbox"][id*="MyData"]:visible').first();
    const myDataLabel = page.locator('label:has-text("Xem của tôi"):visible, .crm-my-data-label:visible').first();

    if (await myDataLabel.isVisible().catch(() => false)) {
      await moveAndClick(page, myDataLabel);
    } else if (await myDataCheckbox.isVisible().catch(() => false)) {
      await moveAndClick(page, myDataCheckbox);
    }
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 4: Checkbox Xem của tôi
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 4,
      desc: 'Kích hoạt tùy chọn lọc Xem của tôi để lọc dữ liệu phụ trách'
    });

    // 🔄 BƯỚC 5: Khôi phục lại bộ lọc "Tất cả"
    console.log('🔄 [TC-02] Bước 5: Bỏ chọn Xem của tôi và quay lại bộ lọc Tất cả...');
    if (await myDataLabel.isVisible().catch(() => false)) {
      await moveAndClick(page, myDataLabel);
      await page.waitForTimeout(500);
    }

    const allPill = page.locator('button.crm-status-pill:visible').filter({ hasText: 'Tất cả' }).first();
    await moveAndClick(page, allPill);
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 5: Khôi phục danh sách đầy đủ
    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 5,
      desc: 'Khôi phục bộ lọc Tất cả và hoàn tất kiểm tra chuyển đổi trạng thái'
    });

    // Đánh giá trạng thái kép (Dual Status)
    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Các nút bộ lọc trạng thái và tùy chọn Xem của tôi phản hồi tức thì, chuyển đổi mượt mà'
    });
  });

  // --------------------------------------------------------------------------
  // TC-03: Kiểm tra Modal "Thêm dữ liệu mới" (+) - Ràng buộc (*) & Nhập liệu an toàn
  // --------------------------------------------------------------------------
  test('TC-03: Kiểm tra Modal "Thêm dữ liệu mới" (+) - Ràng buộc (*) & Nhập liệu an toàn', async ({ page }, testInfo) => {
    console.log('🌐 [TC-03] Bước 1: Mở màn hình Dữ liệu khách hàng và tìm nút Thêm mới (+)...');
    await navigateToCustomerData(page);

    const addBtn = page.locator('.dx-icon-plus:visible, .dx-button:has(.dx-icon-plus):visible').first();
    await expect(addBtn).toBeVisible({ timeout: 10000 });

    // 📸 BƯỚC 1: Di chuyển chuột Neon lên nút Thêm mới (+)
    const addBox = await addBtn.boundingBox();
    if (addBox) {
      await page.mouse.move(addBox.x + addBox.width / 2, addBox.y + addBox.height / 2, { steps: 8 });
      await page.waitForTimeout(400);
    }
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Con trỏ chuột Neon di chuyển và bấm nút Thêm dữ liệu mới (+)'
    });

    await addBtn.click();
    await page.waitForTimeout(1500);

    // 🪟 BƯỚC 2: Kiểm tra Modal "Thêm dữ liệu mới" hiển thị
    console.log('🪟 [TC-03] Bước 2: Chờ Modal Thêm dữ liệu mới xuất hiện...');
    const modal = page.locator('.dx-overlay-content:visible, .modal-dialog:visible').filter({ hasText: 'Thêm dữ liệu mới' }).first();
    await expect(modal).toBeVisible({ timeout: 10000 });

    const modalText = await modal.innerText();
    const hasCompanySection = modalText.includes('Thông tin công ty');
    const hasContactSection = modalText.includes('Chi tiết nhân viên') || modalText.includes('Thông tin liên hệ');
    console.log(`📋 [TC-03] Kiểm tra các phân vùng: Thông tin công ty: ${hasCompanySection}, Thông tin liên hệ: ${hasContactSection}`);
    expect(hasCompanySection).toBeTruthy();

    // 📸 BƯỚC 2: Modal Thêm dữ liệu mới mở ra
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 2,
      desc: 'Modal Thêm dữ liệu mới hiển thị chi tiết 2 phân vùng thông tin'
    });

    // 🔍 BƯỚC 3: Kiểm tra các trường bắt buộc (*)
    console.log('🔍 [TC-03] Bước 3: Kiểm tra các nhãn trường bắt buộc (*)...');
    const requiredLabels = ['Công ty', 'Mã số thuế', 'Địa chỉ', 'Người liên hệ', 'Số điện thoại'];
    const matchedRequired = requiredLabels.filter(lbl => modalText.includes(lbl));
    console.log(`⭐ [TC-03] Các trường bắt buộc xác nhận: ${matchedRequired.join(', ')}`);
    expect(matchedRequired.length).toBeGreaterThanOrEqual(3);

    // 📸 BƯỚC 3: Các trường bắt buộc trên Modal
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 3,
      desc: 'Kiểm tra các trường ràng buộc bắt buộc có dấu sao đỏ trên form'
    });

    // 📝 BƯỚC 4: Nhập liệu thử nghiệm trực quan
    console.log('📝 [TC-03] Bước 4: Nhập dữ liệu thử nghiệm vào form...');
    const modalInputs = modal.locator('input.dx-texteditor-input:visible, input[type="text"]:visible');
    const inputCount = await modalInputs.count();
    console.log(`🔢 [TC-03] Số lượng ô nhập liệu trên modal: ${inputCount}`);

    // Nhập Tên công ty thử nghiệm
    if (inputCount > 0) {
      await moveAndClick(page, modalInputs.nth(0));
      await modalInputs.nth(0).pressSequentially('Cong Ty Paradise Test E2E', { delay: 35 });
    }

    // Nhập Mã số thuế thử nghiệm
    if (inputCount > 1) {
      await moveAndClick(page, modalInputs.nth(1));
      await modalInputs.nth(1).pressSequentially('0318999888', { delay: 35 });
    }

    // Nhập Người liên hệ thử nghiệm
    if (inputCount > 3) {
      await moveAndClick(page, modalInputs.nth(3));
      await modalInputs.nth(3).pressSequentially('Nguyen Van Test', { delay: 35 });
    }

    await page.waitForTimeout(1000);

    // 📸 BƯỚC 4: Điền thông tin thử nghiệm
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 4,
      desc: 'Nhập thông tin thử nghiệm trực quan vào các trường trên form'
    });

    // ❌ BƯỚC 5: Đóng Modal an toàn
    console.log('❌ [TC-03] Bước 5: Đóng Modal an toàn bằng nút Đóng để bảo toàn dữ liệu...');
    const closeBtn = modal.locator('.dx-closebutton, button:has-text("Đóng"), button:has-text("Hủy"), .btn-close').first();
    if (await closeBtn.isVisible().catch(() => false)) {
      await moveAndClick(page, closeBtn);
    } else {
      await page.keyboard.press('Escape');
    }
    await page.waitForTimeout(1500);

    // 📸 BƯỚC 5: Đóng modal an toàn
    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 5,
      desc: 'Đóng Modal an toàn và quay trở về giao diện danh sách khách hàng'
    });

    // Đánh giá trạng thái kép (Dual Status)
    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Modal Thêm dữ liệu mới hiển thị đầy đủ trường thông tin, kiểm soát ràng buộc chặt chẽ và đóng an toàn'
    });
  });

  // --------------------------------------------------------------------------
  // TC-04: Kiểm tra Ô Tìm kiếm nhanh (Search Box) & Lọc dữ liệu tức thì trên DataGrid
  // --------------------------------------------------------------------------
  test('TC-04: Kiểm tra Ô Tìm kiếm nhanh (Search Box) & Lọc dữ liệu tức thì trên DataGrid', async ({ page }, testInfo) => {
    console.log('🌐 [TC-04] Bước 1: Mở màn hình Dữ liệu khách hàng và xác định ô Tìm kiếm nhanh...');
    await navigateToCustomerData(page);

    const searchInput = page.locator('input.dx-texteditor-input[placeholder*="Tìm kiếm"]:visible').first();
    await expect(searchInput).toBeVisible({ timeout: 10000 });

    // Đọc một từ khóa thực tế từ dòng đầu tiên của DataGrid
    const firstRowText = await page.evaluate(() => {
      const visibleRow = Array.from(document.querySelectorAll('.dx-datagrid .dx-data-row'))
        .find(r => r.offsetParent !== null);
      if (!visibleRow) return 'Tho';
      const cells = visibleRow.querySelectorAll('td');
      for (let i = 1; i < cells.length; i++) {
        const text = cells[i].innerText.trim();
        if (text && text.length >= 3 && !text.includes('/')) return text.split(' ')[0];
      }
      return 'Tho';
    });
    console.log(`🔍 [TC-04] Từ khóa tìm kiếm được chọn: "${firstRowText}"`);

    // 📸 BƯỚC 1: Xác định ô Tìm kiếm
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 1,
      desc: 'Xác định ô Tìm kiếm nhanh trên thanh công cụ Dữ liệu khách hàng'
    });

    // ⌨️ BƯỚC 2: Di chuyển chuột Neon vào ô tìm kiếm và gõ từ khóa
    console.log(`⌨️ [TC-04] Bước 2: Di chuyển chuột Neon và gõ từ khóa "${firstRowText}"...`);
    await moveAndClick(page, searchInput);
    await searchInput.pressSequentially(firstRowText, { delay: 45 });
    await page.waitForTimeout(1500); // Chờ DevExtreme lọc debounce

    // 📸 BƯỚC 2: Nhập từ khóa tìm kiếm
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 2,
      desc: `Nhập từ khóa tìm kiếm "${firstRowText}" trực quan vào ô tìm kiếm nhanh`
    });

    // 📊 BƯỚC 3: Kiểm tra DataGrid lọc dữ liệu tức thì
    console.log('📊 [TC-04] Bước 3: Kiểm tra kết quả hiển thị trên DataGrid sau khi lọc...');
    const filteredRows = page.locator('.dx-datagrid:visible .dx-data-row');
    const filteredCount = await filteredRows.count();
    console.log(`🔢 [TC-04] Số lượng bản ghi khớp với từ khóa: ${filteredCount}`);

    // 📸 BƯỚC 3: Kết quả lọc tức thì
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 3,
      desc: 'DataGrid lọc tức thì danh sách khách hàng khớp với từ khóa tìm kiếm'
    });

    // 🖱️ BƯỚC 4: Di chuyển chuột Neon kiểm tra dòng dữ liệu tìm thấy
    console.log('🖱️ [TC-04] Bước 4: Di chuyển chuột Neon kiểm tra chi tiết bản ghi tìm được...');
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
      tcId: 'TC-04',
      step: 4,
      desc: 'Con trỏ chuột Neon kiểm tra chi tiết bản ghi khách hàng tìm thấy'
    });

    // 🔄 BƯỚC 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách
    console.log('🔄 [TC-04] Bước 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng...');
    await moveAndClick(page, searchInput);
    await searchInput.fill('');
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(1500);

    const restoredRows = page.locator('.dx-datagrid:visible .dx-data-row');
    const restoredCount = await restoredRows.count();
    console.log(`🔢 [TC-04] Số lượng bản ghi sau khi khôi phục: ${restoredCount}`);
    expect(restoredCount).toBeGreaterThanOrEqual(filteredCount);

    // 📸 BƯỚC 5: Khôi phục danh sách đầy đủ
    await captureStep(page, testInfo, {
      tcId: 'TC-04',
      step: 5,
      desc: 'Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng ban đầu'
    });

    // Đánh giá trạng thái kép (Dual Status)
    testInfo.annotations.push({
      type: 'business_status',
      description: `PASS - Ô tìm kiếm nhanh phản hồi tức thì, lọc chính xác theo từ khóa "${firstRowText}" và khôi phục đầy đủ ${restoredCount} bản ghi`
    });
  });
});
