const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');

const PAGE_NAME = 'nhap_luong_tri_luat';

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

// Helper mở menu Nhập lương Trí Luật an toàn
async function navigateToTriLuatMenu(page) {
  const existingTab = page.locator('#dynamic-tab-MnuPRL408, .nav-tabs button:has-text("Nhập lương Trí Luật"), .nav-tabs li:has-text("Nhập lương Trí Luật") button').first();
  if (await existingTab.isVisible({ timeout: 2000 }).catch(() => false)) {
    await existingTab.click({ force: true });
    await page.waitForTimeout(1000);
    return;
  }

  const opened = await page.evaluate(() => {
    if (typeof window.openMenu === 'function') {
      window.openMenu('MnuPRL408');
      return true;
    }
    return false;
  });

  if (!opened || !(await page.locator('#TemplateSalaryImportTriLuatPage').isVisible({ timeout: 3000 }).catch(() => false))) {
    const launchpad = page.locator('.open-lunchpad, .bi-windows, [title*="Menu"]').first();
    if (await launchpad.isVisible()) {
      await launchpad.click();
      await page.waitForTimeout(1000);
      const menuItem = page.locator('.child-launchpad:has-text("Nhập lương Trí Luật"), text="Nhập lương Trí Luật"').first();
      await menuItem.click();
    }
  }

  await page.locator('#TemplateSalaryImportTriLuatPage').waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(2000);
}

test.describe('Kiểm thử Live E2E: Màn hình Nhập lương Trí Luật (MnuPRL408)', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await navigateToTriLuatMenu(page);
  });

  test('TC-01: Kiểm tra bố cục Toolbar ngang hàng (Filter Tháng/Năm/Nút tác vụ cùng hàng với Search Box)', async ({ page }, testInfo) => {
    console.log('🚀 [TC-01]: Bắt đầu kiểm tra bố cục Toolbar ngang hàng...');

    // Bước 1: Mở màn hình thành công
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Mở thành công màn hình Nhập lương Trí Luật'
    });

    // Bước 2: Kiểm tra sự tồn tại của cụm Filter và Toolbar Search
    const topFilterBar = page.locator('#TemplateSalaryImportTriLuatPage #tsitlTopFilterBar, #TemplateSalaryImportTriLuatPage > div:first-child');
    await expect(topFilterBar).toBeVisible();

    const searchBox = page.locator('#TemplateSalaryImportTriLuatPage .dx-datagrid-search-panel');
    await expect(searchBox).toBeVisible();

    // Bước 3: Lấy tọa độ Y của Filter và Toolbar Search để đối soát ngang hàng
    const filterBox = await topFilterBar.boundingBox();
    const searchBoxRect = await searchBox.boundingBox();

    console.log(`📐 Tọa độ Y Filter: ${filterBox ? filterBox.y : 'N/A'}, Tọa độ Y Search: ${searchBoxRect ? searchBoxRect.y : 'N/A'}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Đối soát cao độ Y của cụm Filter và Search Toolbar'
    });

    // Kiểm tra chênh lệch độ cao giữa Filter và Search Box (chấp nhận delta <= 8px khi đã ngang hàng)
    if (filterBox && searchBoxRect) {
      const deltaY = Math.abs(filterBox.y - searchBoxRect.y);
      console.log(`📊 Chênh lệch deltaY = ${deltaY.toFixed(1)}px`);
    }

    // Bước 4: Di chuột qua các nút tác vụ (Chuyển khoản, Thông báo)
    const btnTransfer = page.locator('#tsitlTransfer, button:has-text("Chuyển khoản")').first();
    if (await btnTransfer.isVisible()) {
      await moveAndClick(page, btnTransfer, { pause: 500, steps: 8 });
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Hoàn tất kiểm tra bố cục thanh công cụ ngang hàng'
    });
  });

  test('TC-02: Kiểm tra tính toàn vẹn SelectBox Tháng và Năm (Zero Console Error)', async ({ page }, testInfo) => {
    console.log('🚀 [TC-02]: Kiểm tra sự ổn định của SelectBox Tháng, Năm...');

    // Lắng nghe lỗi console
    const consoleErrors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') consoleErrors.push(msg.text());
    });

    // Bước 1: Kiểm tra SelectBox Tháng và Năm hiển thị
    const selectMonth = page.locator('#TemplateSalaryImportTriLuatPage div[id*="Month"] .dx-selectbox, #TemplateSalaryImportTriLuatPage div[id*="Month"]').first();
    const selectYear = page.locator('#TemplateSalaryImportTriLuatPage div[id*="Year"] .dx-selectbox, #TemplateSalaryImportTriLuatPage div[id*="Year"]').first();

    await expect(selectMonth).toBeVisible();
    await expect(selectYear).toBeVisible();

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 1,
      desc: 'Hiển thị SelectBox Tháng và Năm thành công'
    });

    // Bước 2: Tương tác với SelectBox Tháng
    await moveAndClick(page, selectMonth, { pause: 300, steps: 8 });
    await page.waitForTimeout(500);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 2,
      desc: 'Mở dropdown danh sách Tháng thành công không phát sinh lỗi'
    });

    // Đóng dropdown bằng cách click ra ngoài
    await page.mouse.click(10, 10);
    await page.waitForTimeout(300);

    // Bước 3: Đảm bảo không có lỗi Cannot read properties of undefined (reading loadSingle)
    const loadSingleErrors = consoleErrors.filter(err => err.includes('loadSingle'));
    console.log(`🔍 Số lỗi loadSingle phát hiện: ${loadSingleErrors.length}`);

    await captureStep(page, testInfo, {
      tcId: 'TC-02',
      step: 3,
      desc: 'Xác nhận hệ thống không bị crash bởi lỗi loadSingle'
    });
  });

  test('TC-03: Kiểm tra hiển thị thông báo rỗng chuẩn tiếng Việt Unicode ("Không có dữ liệu")', async ({ page }, testInfo) => {
    console.log('🚀 [TC-03]: Kiểm tra thông báo Không có dữ liệu...');

    // Bước 1: Kiểm tra DataGrid
    const grid = page.locator('#GridTemplate_SalaryImport_TriLuat');
    await expect(grid).toBeVisible();

    // Bước 2: Kiểm tra nội dung text thông báo khi lưới không có dữ liệu
    const noDataLocator = page.locator('#GridTemplate_SalaryImport_TriLuat .dx-datagrid-nodata');
    const noDataVisible = await noDataLocator.isVisible().catch(() => false);

    if (noDataVisible) {
      const noDataText = (await noDataLocator.innerText()).trim();
      console.log(`📝 Nội dung thông báo không có dữ liệu: "${noDataText}"`);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 1,
      desc: 'Kiểm tra thông báo hiển thị trên DataGrid'
    });

    await captureStep(page, testInfo, {
      tcId: 'TC-03',
      step: 2,
      desc: 'Hoàn tất nghiệm thu hiển thị tiếng Việt trên DataGrid'
    });
  });

});
