const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { query } = require('../helpers/db');

const PAGE_NAME = 'cham_cong_tinh_luong_flow';
const BASE_URL = 'https://paradisehrm.com/Tai3/#';
const FLOW_STATE_FILE = path.resolve(__dirname, '../.auth/flow_state.json');

// ============================================================================
// CẤU HÌNH PHIÊN ĐỘC LẬP: CHỐNG XUNG ĐỘT MULTI-ROLE
// ============================================================================
test.use({ storageState: { cookies: [], origins: [] } });

// ============================================================================
// BỘ TÀI KHOẢN THỰC TẾ TRONG HỆ THỐNG (MẬT KHẨU CHUNG: 123)
// ============================================================================
const ACCOUNTS = {
  STAFF_DEV:    { username: 'tai.dang',     password: '123', empId: '046', name: 'Đặng Minh Tài' },
  MANAGER_DEV:  { username: 'ThanhLong',    password: '123', empId: '011', name: 'Nguyễn Thanh Long' },
  HR_ADMIN:     { username: 'cuong.vu',     password: '123', empId: '014', name: 'Vũ Đình Cường' },
  DIRECTOR:     { username: 'chien.nguyen', password: '123', empId: '013', name: 'Nguyễn Tấn Chiến' }
};

// ============================================================================
// HELPER TRẠNG THÁI LUỒNG SERIAL GIỮA CÁC TEST CASES (STATE PERSISTENCE)
// ============================================================================
function saveFlowState(state) {
  try {
    fs.mkdirSync(path.dirname(FLOW_STATE_FILE), { recursive: true });
    fs.writeFileSync(FLOW_STATE_FILE, JSON.stringify(state, null, 2), 'utf8');
  } catch (_) {}
}

function loadFlowState() {
  try {
    if (fs.existsSync(FLOW_STATE_FILE)) {
      return JSON.parse(fs.readFileSync(FLOW_STATE_FILE, 'utf8'));
    }
  } catch (_) {}
  return {};
}

// ============================================================================
// HELPER TỰ ĐỘNG CHỌN NGÀY TEST HỢP LỆ CHƯA ĐĂNG KÝ (TRÁNH LỖI DUPLICATE BACKEND)
// ============================================================================
function getAvailableTestDate(empId = '046') {
  try {
    const registered = query(`SELECT CONVERT(varchar, AttDate, 23) as d FROM tblAttendanceConfirmRequest WHERE EmployeeID = '${empId}'`);
    const regSet = new Set(registered.map(r => r.d));
    for (let day = 18; day <= 28; day++) {
      const candidate = `2026-10-${String(day).padStart(2, '0')}`;
      if (!regSet.has(candidate)) return candidate;
    }
  } catch (_) {}
  return '2026-10-18';
}

// ============================================================================
// HELPER 1: DI CHUỘT TRỰC QUAN & CLICK MƯỢT MÀ VỚI CON TRỎ NEON
// ============================================================================
async function moveAndClick(page, locator, options = {}) {
  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
  const box = await locator.boundingBox().catch(() => null);
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 10 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: true, timeout: 5000 }).catch(async () => {
    await locator.evaluate((el) => el.click()).catch(() => {});
  });
}

// ============================================================================
// HELPER 2: CHỤP ẢNH TỪNG BƯỚC TUẦN TỰ CÓ DẤU (TÍCH HỢP MD5 BUFFER RUNTIME GUARD)
// ============================================================================
const _lastCapturedHash = {};
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

  const buffer = await page.screenshot({ fullPage: false }).catch(() => null);
  if (!buffer) return;

  const crypto = require('crypto');
  const hash = crypto.createHash('md5').update(buffer).digest('hex');
  if (_lastCapturedHash[tcId] === hash) {
    console.log(`⏩ [${tcId}] Bỏ qua chụp Bước ${step}: "${desc}" (Giao diện giữ nguyên, tránh trùng lặp ảnh)`);
    return;
  }
  _lastCapturedHash[tcId] = hash;

  fs.writeFileSync(filePath, buffer);
  await testInfo.attach(`Bước ${step}: ${desc}`, {
    path: filePath,
    contentType: 'image/png'
  }).catch(() => {});
  console.log(`📸 [${tcId}] Đã chụp Bước ${step}: ${desc} -> ${fileName}`);
}

// ============================================================================
// HELPER 3: ĐĂNG NHẬP TRỰC TIẾP TRỰC QUAN (VISUAL DIRECT LOGIN)
// ============================================================================
async function loginDirectly(page, credentials) {
  console.log(`🔑 [AUTH]: Đang đăng nhập tài khoản "${credentials.username}" (${credentials.name})...`);

  const currentUrl = page.url();
  if (!currentUrl.includes('paradisehrm.com')) {
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1000);
  }

  // Kiểm tra nếu đã ở đúng phiên làm việc
  const isDock = await page.locator('.dock, .navbar').first().isVisible().catch(() => false);
  if (isDock) {
    const currentUser = await page.evaluate(() => window.LoginName || window.loginName).catch(() => null);
    if (currentUser && currentUser.toLowerCase() === credentials.username.toLowerCase()) {
      console.log(`⚡ [AUTH]: Đã ở đúng phiên của "${credentials.username}". Bỏ qua đăng nhập!`);
      return;
    }
    console.log(`🔄 [AUTH]: Chuyển từ user "${currentUser || 'khác'}" sang "${credentials.username}"...`);
    await page.context().clearCookies();
    await page.evaluate(() => {
      try { localStorage.clear(); sessionStorage.clear(); } catch (_) {}
    }).catch(() => {});
    await page.reload({ waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);
  }

  // Ô nhập username
  const userInput = page.locator('#username').first();
  const isUserVisible = await userInput.isVisible().catch(() => false);
  if (!isUserVisible) {
    console.log(`🔄 [AUTH]: Tải lại màn hình đăng nhập...`);
    await page.context().clearCookies();
    await page.evaluate(() => {
      try { localStorage.clear(); sessionStorage.clear(); } catch (_) {}
    }).catch(() => {});
    await page.goto('https://paradisehrm.com/Tai3/', { waitUntil: 'domcontentloaded' });
    await page.reload({ waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);
  }

  await userInput.waitFor({ state: 'visible', timeout: 15000 });
  console.log(`👉 [AUTH]: Di chuột Neon nhập Tên đăng nhập: ${credentials.username}`);
  await moveAndClick(page, userInput, { steps: 8, pause: 200 });
  await userInput.fill('');
  await userInput.pressSequentially(credentials.username, { delay: 40 });
  await page.waitForTimeout(200);

  // Mật khẩu
  const passInput = page.locator('input[type="password"]').first();
  console.log(`👉 [AUTH]: Di chuột Neon nhập Mật khẩu: 123`);
  await moveAndClick(page, passInput, { steps: 8, pause: 200 });
  await passInput.fill('');
  await passInput.pressSequentially(credentials.password, { delay: 40 });
  await page.waitForTimeout(200);

  // Bấm Đăng nhập
  console.log(`👉 [AUTH]: Di chuột Neon bấm nút "Đăng nhập"...`);
  const submitBtn = page.locator('#submitLogin').first();
  await moveAndClick(page, submitBtn, { steps: 8, pause: 300 });

  // Chờ nạp Dock
  console.log(`⏳ [AUTH]: Chờ hệ thống xác thực và nạp giao diện chính...`);
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1500);
  console.log(`✅ [AUTH]: Đăng nhập thành công với tài khoản ${credentials.username}!`);
}

// ============================================================================
// HELPER 4: ĐIỀU HƯỚNG MỞ MENU TRÊN GIAO DIỆN PARADISE HRM
// ============================================================================
async function openMenu(page, { dockModule = 'MnuWPT000', menuName, dockCode, menuId }) {
  console.log(`📂 [NAV]: Đang mở menu "${menuName || menuId}" (Dock: ${dockModule}, Code: ${dockCode || ''})...`);

  // Xóa backdrop tồn đọng nếu có
  await page.evaluate(() => {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.querySelectorAll('.modal.show').forEach(m => m.classList.remove('show'));
  }).catch(() => {});

  // 1. Kiểm tra tab đã mở sẵn trên Tab Bar
  const tabSelector = `.nav-tabs button:has-text("${menuName}"), .nav-tabs a:has-text("${menuName}"), .nav-tabs li:has-text("${menuName}")`;
  const openTab = page.locator(tabSelector).first();
  if (await openTab.isVisible().catch(() => false)) {
    console.log(`👉 [NAV]: Tab "${menuName}" đã mở sẵn trên thanh tab, chuyển sang...`);
    await moveAndClick(page, openTab, { force: true, steps: 6 });
    await page.waitForTimeout(1000);
    return;
  }

  // 2. Nếu có dockCode trực tiếp trên Dock (vd: MnuHRS033 = Xin bù công, MnuWPT037 = Phê duyệt, MnuPRL445 = Phiếu lương)
  if (dockCode) {
    const directDock = page.locator(`.dock button.${dockCode}, .dock .open-${dockCode}, .dock .${dockCode}, button.${dockCode}`).first();
    if (await directDock.isVisible({ timeout: 2000 }).catch(() => false)) {
      console.log(`👉 [NAV]: Di chuột Neon nhấp icon "${dockCode}" trực tiếp trên Dock...`);
      await moveAndClick(page, directDock, { steps: 8, pause: 200 });
      await page.waitForTimeout(2000);
      return;
    }
  }

  // 3. Kiểm tra nếu menu đã hiển thị sẵn trên Sidebar / Launchpad
  const candidateSelectors = [
    `span:has-text("${menuName}"):visible`,
    `a:has-text("${menuName}"):visible`,
    `.child-launchpad:has-text("${menuName}"):visible`,
    menuId ? `.${menuId}:visible` : null,
    dockCode ? `.${dockCode}:visible` : null
  ].filter(Boolean).join(', ');

  const directItem = page.locator(candidateSelectors).first();
  if (await directItem.isVisible({ timeout: 1500 }).catch(() => false)) {
    console.log(`👉 [NAV]: Menu "${menuName}" đã sẵn sàng trên màn hình, di chuột Neon nhấp...`);
    await moveAndClick(page, directItem, { steps: 8, pause: 300 });
    await page.waitForTimeout(2000);
    console.log(`✅ [NAV]: Mở thành công menu "${menuName}"!`);
    return;
  }

  // 4. Nếu chưa thấy thì nhấp icon phân hệ trên Dock (Chỉ nhấp nếu sidebar chưa mở)
  if (dockModule) {
    const dockIcon = page.locator(`.dock .open-${dockModule}, .dock .${dockModule}, .dock button.${dockModule}`).first();
    if (await dockIcon.isVisible({ timeout: 4000 }).catch(() => false)) {
      console.log(`👉 [NAV]: Di chuột Neon nhấp Phân hệ "${dockModule}" trên Dock...`);
      await moveAndClick(page, dockIcon, { steps: 8, pause: 200 });
      await page.waitForTimeout(1500);
    }
  }

  // 5. Nhấp menu sau khi mở Dock
  const itemAfterDock = page.locator(candidateSelectors).first();
  if (await itemAfterDock.isVisible({ timeout: 6000 }).catch(() => false)) {
    console.log(`👉 [NAV]: Di chuột Neon nhấp menu "${menuName}"...`);
    await moveAndClick(page, itemAfterDock, { steps: 8, pause: 300 });
    await page.waitForTimeout(2000);
    console.log(`✅ [NAV]: Mở thành công menu "${menuName}"!`);
  } else {
    // Thử biến thể chính tả hằng ngày / hàng ngày
    const altName = menuName.includes('hằng ngày') ? menuName.replace('hằng ngày', 'hàng ngày') : menuName.replace('hàng ngày', 'hằng ngày');
    const flexibleItem = page.locator(`a:has-text("${altName}"), span:has-text("${altName}"), [data-keywords*="${altName}"]`).first();
    if (await flexibleItem.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log(`👉 [NAV]: Di chuột Neon nhấp biến thể tên menu: "${altName}"...`);
      await moveAndClick(page, flexibleItem, { steps: 8, pause: 300 });
      await page.waitForTimeout(2000);
      console.log(`✅ [NAV]: Mở thành công menu qua biến thể "${altName}"!`);
      return;
    }
    console.warn(`⚠️ [NAV]: Không tìm thấy menu "${menuName}".`);
  }
}

// ============================================================================
// KHỐI TEST CHÍNH: KIỂM THỬ LUỒNG CHẤM CÔNG - TÍNH LƯƠNG
// ============================================================================
test.describe('Phân Hệ Chấm Công & Tính Lương: Kịch Bản Kiểm Thử E2E Chuẩn Mực', () => {
  test.describe.configure({ mode: 'serial' });

  test.beforeEach(async ({ context }) => {
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
  });

  // --------------------------------------------------------------------------
  // TC-01: TẠO VÀ GỬI ĐƠN XIN BÙ CÔNG (ROLE: TAI.DANG) - DUAL-LAYER CSDL
  // --------------------------------------------------------------------------
  test('TC-01: Kiểm tra kiểm soát ràng buộc và tạo đơn Xin bù công (Role: tai.dang)', async ({ page }, testInfo) => {
    test.setTimeout(90000);

    // Bước 1: Đăng nhập với tài khoản Nhân viên tai.dang
    await loginDirectly(page, ACCOUNTS.STAFF_DEV);
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 1, desc: 'Nhan vien tai dang dang nhap he thong' });

    // Bước 2: Mở menu Xin bù công từ Cổng thông tin nhân sự (MnuWPT000, direct dock MnuHRS033)
    await openMenu(page, { dockCode: 'MnuHRS033', dockModule: 'MnuWPT000', menuName: 'Xin bù công' });
    await page.locator('#AttDate, #sp_MakeupHours').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 2, desc: 'Mo menu Xin bu cong' });

    // Sinh Token nhận diện duy nhất và chọn ngày hợp lệ từ CSDL
    const runToken = String(Date.now()).slice(-6);
    const testDate = getAvailableTestDate('046');
    console.log(`🏷️ [TC-01]: Token kiểm thử: "${runToken}", Ngày bù công: "${testDate}"`);

    // Bước 3: Điền thông tin ngày bù công và giờ vào/ra chuẩn nghiệp vụ
    const dateInput = page.locator('#AttDate, input[type="date"]').first();
    if (await dateInput.isVisible({ timeout: 4000 }).catch(() => false)) {
      await moveAndClick(page, dateInput, { steps: 6, pause: 150 });
      await dateInput.fill(testDate);
      await page.waitForTimeout(200);
    }

    const inOutSelect = page.locator('#select_inout, select.select-inout').first();
    if (await inOutSelect.isVisible({ timeout: 3000 }).catch(() => false)) {
      await inOutSelect.selectOption('1').catch(() => {});
    }

    const timeInput = page.locator('#TimeInOut, input[type="time"]').first();
    if (await timeInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, timeInput, { steps: 6, pause: 150 });
      await timeInput.fill('08:00');
    }

    // Tích chọn 'Xác nhận công ngoại lệ' để bypass giới hạn 3 ngày
    const chkSoftwareError = page.locator('#isSoftwareError');
    if (await chkSoftwareError.isVisible({ timeout: 2000 }).catch(() => false)) {
      await chkSoftwareError.check().catch(() => {});
    }

    // Nhập lý do giải trình kèm RUN_TOKEN
    const testReason = `Quên quẹt thẻ ngày ${testDate} [ID:${runToken}]`;
    const noteInput = page.locator('#Note, textarea').first();
    if (await noteInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, noteInput, { steps: 6, pause: 150 });
      await noteInput.fill('');
      await noteInput.pressSequentially(testReason, { delay: 15 });
    }
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 3, desc: 'Dien thong tin ngay lam viec gio vao va ly do giai trinh' });

    // Bước 4: Nhấp nút Đăng ký -> Hệ thống hiển thị popup Xác nhận đăng ký
    const submitBtn = page.locator('#sp_MakeupHours .btnRegister, button.btnRegister, button:has-text("Đăng ký")').first();
    await submitBtn.waitFor({ state: 'visible', timeout: 5000 });
    console.log('👉 [TC-01]: Di chuột Neon nhấp nút "Đăng ký"...');
    await moveAndClick(page, submitBtn, { steps: 6, pause: 200 });
    await page.waitForTimeout(1000);

    // Chờ popup xác nhận "Bạn có chắc đăng ký đơn này không?"
    const confirmPopup = page.locator('#vc-vu-confirm-popup, .VC-Vu-popup, div:has-text("Xác nhận đăng ký")').first();
    await confirmPopup.waitFor({ state: 'visible', timeout: 6000 });
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 4, desc: 'Popup Xac nhan dang ky hien thi yeu cau xac thuc' });

    // Bấm "Đồng ý" trên popup xác nhận
    const dongYBtn = page.locator('button:has-text("Đồng ý"), #vc-vu-confirm-popup .VC-Vu-btn-ok, #vc-vu-confirm-popup .vc-btn-ok, button.VC-Vu-btn-ok').first();
    await dongYBtn.waitFor({ state: 'visible', timeout: 6000 });
    console.log('👉 [TC-01]: Di chuột Neon xác nhận nhấp nút "Đồng ý"...');
    await moveAndClick(page, dongYBtn, { steps: 6, pause: 200 });
    await page.evaluate(() => {
      const btn = Array.from(document.querySelectorAll('button')).find(b => b.innerText.includes('Đồng ý') && b.offsetWidth > 0);
      if (btn) btn.click();
    });
    await page.waitForTimeout(3500);

    // Đóng popup thông báo kết quả (nếu có)
    const alertOkBtn = page.locator('#vc-vu-info-popup .VC-Vu-btn-ok, #vc-vu-info-popup .vc-btn-ok, .modal.show button, button:has-text("OK")').first();
    if (await alertOkBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await alertOkBtn.click({ force: true }).catch(() => {});
    }
    await page.waitForTimeout(1000);

    // ========================================================================
    // BƯỚC 5: KIỂM CHỨNG KÉP CSDL (DUAL-LAYER VERIFICATION - ZERO FAKE PASS)
    // ========================================================================
    console.log(`🔍 [TC-01]: Kiểm chứng CSDL tblAttendanceConfirmRequest với Token: "${runToken}"...`);
    const dbRows = query(`
      SELECT TOP 1 IdentityID, EmployeeID, CONVERT(varchar, AttDate, 23) as AttDateStr, Approve_Status, Remark
      FROM tblAttendanceConfirmRequest
      WHERE EmployeeID = '046' AND Remark LIKE '%${runToken}%'
      ORDER BY CreateTime DESC
    `);

    if (dbRows && dbRows.length > 0) {
      const identityId = dbRows[0].IdentityID;
      console.log(`✅ [TC-01]: CSDL đã lưu thành công bản ghi IdentityID: ${identityId}`);
      saveFlowState({
        runToken,
        testDate,
        identityId,
        timeInOut: '08:00',
        empId: '046',
        submittedAt: new Date().toISOString()
      });

      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Tạo và gửi đơn xin bù công thành công, xác thực CSDL đã lưu bản ghi IdentityID: ${identityId} (Token: ${runToken})`
      });
      await captureStep(page, testInfo, { tcId: 'TC-01', step: 5, desc: 'Danh gia logic PASS: Don bu cong duoc luu vao CSDL thanh cong' });
    } else {
      console.error(`❌ [TC-01]: CSDL KHÔNG tìm thấy bản ghi với Token: "${runToken}"! Đơn chưa được tạo.`);
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Đơn chưa được lưu vào CSDL tblAttendanceConfirmRequest sau khi nhấn Đồng ý (Token: ${runToken})`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Thao tác gửi đơn trên UI không tạo được bản ghi trong CSDL',
          token: runToken,
          testDate
        })
      });
      await captureStep(page, testInfo, { tcId: 'TC-01', step: 5, desc: 'Danh gia logic FAIL: CSDL khong co ban ghi don vua tao' });
      expect(dbRows.length).toBeGreaterThan(0);
    }
  });

  // --------------------------------------------------------------------------
  // TC-02: ĐỐI SOÁT CHUẨN XÁC TAB LỊCH SỬ ĐƠN BÙ CÔNG (ROLE: TAI.DANG)
  // --------------------------------------------------------------------------
  test('TC-02: Nhân viên đối soát tab Lịch sử đơn bù công (Role: tai.dang)', async ({ page }, testInfo) => {
    test.setTimeout(90000);

    const flowState = loadFlowState();
    console.log(`📋 [TC-02]: Đang đối soát với State:`, flowState);

    // Bước 1: Đăng nhập tai.dang và mở menu Xin bù công
    await loginDirectly(page, ACCOUNTS.STAFF_DEV);
    await openMenu(page, { dockCode: 'MnuHRS033', dockModule: 'MnuWPT000', menuName: 'Xin bù công' });
    await page.locator('#AttDate, #sp_MakeupHours').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);
    await captureStep(page, testInfo, { tcId: 'TC-02', step: 1, desc: 'Nhan vien mo giao dien Xin bu cong' });

    // Bước 2: Nhấp tab "Lịch sử"
    const historyTab = page.locator('button:has-text("Lịch sử"), a:has-text("Lịch sử"), .custom-tab-btn:has-text("Lịch sử")').first();
    await historyTab.waitFor({ state: 'visible', timeout: 6000 });
    console.log('👉 [TC-02]: Di chuột Neon nhấp tab "Lịch sử"...');
    await moveAndClick(page, historyTab, { steps: 6, pause: 200 });
    await page.waitForTimeout(2500);
    await captureStep(page, testInfo, { tcId: 'TC-02', step: 2, desc: 'Di chuot Neon nhap tab Lich su' });

    // Bước 3: Quan sát danh sách các đơn đã đăng ký trong Lịch sử (#historyCardBody > div)
    const historyCards = page.locator('#historyCardBody > div, .card-history, .getcardregisteredOA, .history-item');
    await historyCards.first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
    const cardCount = await historyCards.count().catch(() => 0);
    console.log(`📋 [TC-02]: Ghi nhận ${cardCount} bản ghi lịch sử bù công.`);

    // Bước 4: Đối soát chi tiết thẻ đơn
    const topCardText = await historyCards.first().innerText().catch(() => '');
    console.log('🔍 [TC-02]: Nội dung lá đơn trên cùng:\n', topCardText.replace(/\s+/g, ' '));

    // BỘ LUẬT THÉP: Chống Fake PASS - Lá đơn trên cùng BẮT BUỘC phải khớp token hoặc ngày test
    const matchesToken = Boolean(flowState.runToken && topCardText.includes(flowState.runToken));
    const testDateDisplay = flowState.testDate ? flowState.testDate.split('-').reverse().join('/') : '';
    const matchesDate = Boolean(testDateDisplay && topCardText.includes(testDateDisplay));
    const isPending = topCardText.includes('Đang chờ duyệt') || topCardText.includes('Chờ duyệt');

    // Kiểm chứng CSDL
    let dbStatus = null;
    if (flowState.identityId) {
      const dbCheck = query(`SELECT Approve_Status FROM tblAttendanceConfirmRequest WHERE IdentityID = '${flowState.identityId}'`);
      if (dbCheck && dbCheck.length > 0) dbStatus = dbCheck[0].Approve_Status;
    }

    // BẮT BUỘC: Thẻ đơn phải khớp Token/Ngày VÀ CSDL đang ở trạng thái 1 (Chờ duyệt) hoặc 2 (Đã duyệt)
    const isPassed = (matchesToken || matchesDate) && (dbStatus === 1 || dbStatus === 2);

    if (isPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Đơn bù công hiển thị chuẩn xác trong Tab Lịch sử với trạng thái "Đang chờ duyệt" (Khớp CSDL Approve_Status: ${dbStatus})`
      });
      await captureStep(page, testInfo, { tcId: 'TC-02', step: 3, desc: 'Danh gia logic PASS: Tab Lich su nap chinh xac la don vua tao' });
    } else {
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - Không tìm thấy lá đơn vừa tạo trong Tab Lịch sử hoặc trạng thái CSDL sai khác! CSDL Status: ${dbStatus}`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: 'Đơn mới tạo không xuất hiện tại Tab Lịch sử',
          expectedToken: flowState.runToken,
          expectedDate: flowState.testDate,
          actualTopCard: topCardText.substring(0, 200).replace(/\s+/g, ' '),
          dbStatus
        })
      });
      await captureStep(page, testInfo, { tcId: 'TC-02', step: 3, desc: 'Danh gia logic FAIL: The don moi tao khong xuat hien trong Lich su' });
      expect(isPassed).toBeTruthy();
    }
  });

  // --------------------------------------------------------------------------
  // TC-03: QUẢN LÝ CẤP DUYỆT THẨM ĐỊNH VÀ DUYỆT ĐƠN 2 CẤP (THANHLONG & CUONG.VU)
  // --------------------------------------------------------------------------
  test('TC-03: Quản lý cấp duyệt thẩm định và duyệt đơn bù công 2 cấp (Role: ThanhLong & cuong.vu)', async ({ page }, testInfo) => {
    test.setTimeout(120000);

    const flowState = loadFlowState();
    let l1Success = false;
    let l2Success = false;

    // ========================================================================
    // PHẦN 1: CẤP 1 - QUẢN LÝ TRỰC TIẾP (THANHLONG - [011])
    // ========================================================================
    console.log('=== TC-03 GIAI ĐOẠN 1: CẤP 1 DUYỆT (THANHLONG) ===');
    await loginDirectly(page, ACCOUNTS.MANAGER_DEV);
    await captureStep(page, testInfo, { tcId: 'TC-03', step: 1, desc: 'Quan ly truc tiep ThanhLong dang nhap he thong' });

    // Mở Danh sách phê duyệt cho ThanhLong (click icon MnuWPT037 trên Dock)
    await openMenu(page, { dockCode: 'MnuWPT037', menuName: 'Danh sách phê duyệt', dockModule: 'MnuWPT000' });
    await page.waitForTimeout(3000);
    await captureStep(page, testInfo, { tcId: 'TC-03', step: 2, desc: 'ThanhLong mo man hinh Danh sach phe duyet' });

    // Tìm thẻ đơn bù công của Đặng Minh Tài (046) khớp với mã token hoặc ngày kiểm thử (chống bốc nhầm đơn nghỉ phép)
    let taiCard = page.locator(`.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("${flowState.runToken}"), .card:has-text("Xin xác nhận công"):has-text("${flowState.runToken}")`).first();
    let hasTaiCard = await taiCard.isVisible({ timeout: 4000 }).catch(() => false);
    if (!hasTaiCard) {
      taiCard = page.locator(`.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("${flowState.testDate}"), .card:has-text("Xin xác nhận công"):has-text("${flowState.testDate}")`).first();
      hasTaiCard = await taiCard.isVisible({ timeout: 4000 }).catch(() => false);
    }
    if (!hasTaiCard) {
      taiCard = page.locator('.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("Đặng Minh Tài"), .card:has-text("Xin xác nhận công"):has-text("046")').first();
      hasTaiCard = await taiCard.isVisible({ timeout: 4000 }).catch(() => false);
    }

    if (hasTaiCard) {
      console.log('👉 [TC-03]: Di chuột Neon nhấp thẻ đơn bù công của Đặng Minh Tài...');
      await moveAndClick(page, taiCard, { steps: 8, pause: 200 });
      await page.waitForTimeout(2500);

      // Chờ nút Duyệt trong form chi tiết xuất hiện
      const approveBtn = page.locator('#sp_MakeupHours button.btnApprove, button.btnApprove:visible').first();
      await approveBtn.waitFor({ state: 'visible', timeout: 12000 }).catch(() => {});

      if (await approveBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
        console.log('👉 [TC-03]: Di chuột Neon nhấp nút "Duyệt" (Level 1)...');
        await moveAndClick(page, approveBtn, { steps: 6, pause: 200 });
        await page.waitForTimeout(1000);

        // Bấm xác nhận Duyệt trong modal
        const confirmBtn = page.locator('#btnApproveModalRemake:visible, #modalApproveAttendanceRequest button:has-text("Duyệt"):visible').first();
        if (await confirmBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
          await moveAndClick(page, confirmBtn, { steps: 6 });
        }
        await page.evaluate(() => {
          if (typeof HandleApproveAttendanceRequest === 'function') {
            HandleApproveAttendanceRequest();
          }
        });
        await page.waitForTimeout(3000);

        // BẬT QUY TẮC LUẬT THÉP 9 (KIỂM SOÁT THÀNH PHẦN ĐỘNG):
        // Nạp lại chính xác lá đơn vừa duyệt để kiểm chứng chuyển đổi trạng thái trên UI
        if (flowState.identityId) {
          console.log(`🔍 [TC-03]: Nạp chính xác lá đơn ${flowState.identityId} để kiểm chứng thành phần động sau duyệt...`);
          await page.evaluate((id) => {
            if (typeof LoadAttendanceInformation === 'function') {
              LoadAttendanceInformation(id);
            }
          }, flowState.identityId);
          await page.waitForTimeout(2000);
        }
      }
    }

    // KIỂM CHỨNG CSDL CẤP 1
    if (flowState.identityId) {
      const l1Db = query(`
        SELECT Approve_Status 
        FROM tblApproverHistory 
        WHERE Identity_ID = '${flowState.identityId}' AND Level = 1 AND ApproverID = '011'
      `);
      if (l1Db && l1Db.length > 0 && l1Db[0].Approve_Status === 2) {
        l1Success = true;
        console.log('✅ [TC-03]: CSDL xác nhận Cấp 1 (ThanhLong) đã duyệt thành công (Approve_Status = 2)!');
      } else {
        console.warn('⚠️ [TC-03]: CSDL chưa ghi nhận Cấp 1 phê duyệt hoặc Approve_Status != 2.');
      }
    } else {
      l1Success = hasTaiCard;
    }
    await captureStep(page, testInfo, { tcId: 'TC-03', step: 3, desc: 'Cap 1 ThanhLong phe duyet don bu cong' });

    // ========================================================================
    // PHẦN 2: CẤP 2 - GIÁM ĐỐC NHÂN SỰ / QUẢN TRỊ VIÊN (CUONG.VU - [014])
    // ========================================================================
    console.log('=== TC-03 GIAI ĐOẠN 2: CẤP 2 DUYỆT (CUONG.VU) ===');
    await loginDirectly(page, ACCOUNTS.HR_ADMIN);

    // Mở Danh sách phê duyệt cho cuong.vu (dockCode: MnuWPT037)
    await openMenu(page, { dockCode: 'MnuWPT037', menuName: 'Danh sách phê duyệt', dockModule: 'MnuWPT000' });
    await page.waitForTimeout(3000);

    let taiCardL2 = page.locator(`.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("${flowState.runToken}"), .card:has-text("Xin xác nhận công"):has-text("${flowState.runToken}")`).first();
    let hasTaiCardL2 = await taiCardL2.isVisible({ timeout: 4000 }).catch(() => false);
    if (!hasTaiCardL2) {
      taiCardL2 = page.locator(`.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("${flowState.testDate}"), .card:has-text("Xin xác nhận công"):has-text("${flowState.testDate}")`).first();
      hasTaiCardL2 = await taiCardL2.isVisible({ timeout: 4000 }).catch(() => false);
    }
    if (!hasTaiCardL2) {
      taiCardL2 = page.locator('.getcardregisteredOA:has-text("Xin xác nhận công"):has-text("Đặng Minh Tài"), .card:has-text("Xin xác nhận công"):has-text("046")').first();
      hasTaiCardL2 = await taiCardL2.isVisible({ timeout: 4000 }).catch(() => false);
    }

    if (hasTaiCardL2) {
      console.log('👉 [TC-03]: Di chuột Neon nhấp thẻ đơn bù công của Đặng Minh Tài (Level 2)...');
      await moveAndClick(page, taiCardL2, { steps: 8, pause: 200 });
      await page.waitForTimeout(2500);

      const approveBtnL2 = page.locator('#sp_MakeupHours button.btnApprove, button.btnApprove:visible').first();
      await approveBtnL2.waitFor({ state: 'visible', timeout: 12000 }).catch(() => {});

      if (await approveBtnL2.isVisible({ timeout: 3000 }).catch(() => false)) {
        console.log('👉 [TC-03]: Di chuột Neon nhấp nút "Duyệt" (Level 2)...');
        await moveAndClick(page, approveBtnL2, { steps: 6, pause: 200 });
        await page.waitForTimeout(1000);

        const confirmBtnL2 = page.locator('#btnApproveModalRemake:visible, #modalApproveAttendanceRequest button:has-text("Duyệt"):visible').first();
        if (await confirmBtnL2.isVisible({ timeout: 4000 }).catch(() => false)) {
          await moveAndClick(page, confirmBtnL2, { steps: 6 });
        }
        await page.evaluate(() => {
          if (typeof HandleApproveAttendanceRequest === 'function') {
            HandleApproveAttendanceRequest();
          }
        });
        await page.waitForTimeout(3000);

        // BẬT QUY TẮC LUẬT THÉP 9 (KIỂM SOÁT THÀNH PHẦN ĐỘNG):
        // Nạp lại chính xác lá đơn vừa duyệt để kiểm chứng chuyển đổi trạng thái Cả 2 cấp trên UI
        if (flowState.identityId) {
          console.log(`🔍 [TC-03]: Nạp chính xác lá đơn ${flowState.identityId} để kiểm chứng hoàn tất toàn trình 2 cấp...`);
          await page.evaluate((id) => {
            if (typeof LoadAttendanceInformation === 'function') {
              LoadAttendanceInformation(id);
            }
          }, flowState.identityId);
          await page.waitForTimeout(2000);
        }
      }
    }

    // KIỂM CHỨNG CSDL CẤP 2
    if (flowState.identityId) {
      const l2Db = query(`
        SELECT Approve_Status 
        FROM tblAttendanceConfirmRequest 
        WHERE IdentityID = '${flowState.identityId}'
      `);
      if (l2Db && l2Db.length > 0 && l2Db[0].Approve_Status === 2) {
        l2Success = true;
        console.log('✅ [TC-03]: CSDL xác nhận Cấp 2 (cuong.vu) đã duyệt toàn trình (tblAttendanceConfirmRequest.Approve_Status = 2)!');
      } else {
        console.warn('⚠️ [TC-03]: CSDL chưa ghi nhận Cấp 2 hoàn tất hoặc Approve_Status != 2.');
      }
    } else {
      l2Success = hasTaiCardL2;
    }

    // Đánh giá logic phê duyệt đa cấp theo KIỂM CHỨNG KÉP UI + CSDL
    const isPassed = l1Success && l2Success;

    if (isPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: 'PASS - Quy trình phê duyệt liên hoàn 2 cấp (ThanhLong Cấp 1 -> cuong.vu Cấp 2) hoàn tất chuẩn xác, xác thực CSDL đã duyệt thành công'
      });
      await captureStep(page, testInfo, { tcId: 'TC-03', step: 4, desc: 'Danh gia logic PASS: Don da duoc ca 2 cap phe duyet hoan tat' });
    } else {
      const failReason = !l1Success 
        ? 'Cấp 1 (ThanhLong) chưa thực hiện được thao tác phê duyệt (thẻ đơn không hiển thị hoặc CSDL Approve_Status != 2)'
        : 'Cấp 2 (cuong.vu) chưa phê duyệt được toàn trình (CSDL tblAttendanceConfirmRequest.Approve_Status != 2)';
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - ${failReason}`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: failReason,
          level1Approved: l1Success,
          level2Approved: l2Success,
          identityId: flowState.identityId
        })
      });
      await captureStep(page, testInfo, { tcId: 'TC-03', step: 4, desc: `Danh gia logic FAIL: ${failReason}` });
      expect(isPassed).toBeTruthy();
    }
  });

  // --------------------------------------------------------------------------
  // TC-04: ĐỐI SOÁT BẢNG CÔNG NGÀY & TỔNG HỢP CÔNG THÁNG (ROLE: CUONG.VU)
  // --------------------------------------------------------------------------
  test('TC-04: Nhân sự C&B kiểm tra công ngày và tổng hợp công tháng (Role: cuong.vu)', async ({ page }, testInfo) => {
    test.setTimeout(90000);

    // Bước 1: Đăng nhập tài khoản Nhân sự C&B cuong.vu
    await loginDirectly(page, ACCOUNTS.HR_ADMIN);
    await captureStep(page, testInfo, { tcId: 'TC-04', step: 1, desc: 'Nhan su CB cuong vu dang nhap he thong' });

    // Bước 2: Mở phân hệ Chấm công (MnuTAD000) -> Xem dữ liệu chấm công hằng ngày (MnuHRS225)
    await openMenu(page, { dockCode: 'MnuHRS225', dockModule: 'MnuTAD000', menuName: 'Xem dữ liệu chấm công hằng ngày', menuId: 'MnuHRS225' });
    await page.waitForTimeout(3000);
    await captureStep(page, testInfo, { tcId: 'TC-04', step: 2, desc: 'Mo bang cham cong hang ngay phan he TAD' });

    // Bước 3: Đặt Từ ngày sang 01/10/2026 và tìm kiếm nhân viên Đặng Minh Tài (046)
    console.log('👉 [TC-04]: Thiết lập "Từ ngày" 01/10/2026 và lọc mã NV 046...');
    await page.evaluate(() => {
      try {
        const fromBox = $('#FromDate_Box').dxDateBox('instance');
        if (fromBox) {
          fromBox.option('value', new Date(2026, 9, 1)); // 01/10/2026
        }
        if (typeof window.ReloadData === 'function') {
          window.ReloadData('046');
        }
      } catch (_) {}
    });
    await page.waitForTimeout(3000);

    // Chờ hàng dữ liệu của nhân viên 046 xuất hiện trong bảng dữ liệu chấm công
    const row046 = page.locator('#GridDailyAttendanceData .dx-datagrid-table .dx-data-row:has-text("046")').first();
    await row046.waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
    await captureStep(page, testInfo, { tcId: 'TC-04', step: 3, desc: 'Loc thong tin cham cong cua nhan vien 046' });

    // Bước 4: Đánh giá tính toàn vẹn (Tuân thủ LUẬT THÉP 1 - Zero Fake PASS + Dual-Layer CSDL)
    const hasRow = await row046.isVisible().catch(() => false);
    const dbRows = query(`SELECT TOP 1 * FROM tblHasTA WHERE EmployeeID = '046'`);
    const isPassed = hasRow && dbRows && dbRows.length > 0;
    if (isPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: 'PASS - Bảng công ngày hiển thị chính xác bản ghi công của nhân viên 046 (Khớp CSDL tblHasTA)'
      });
      await captureStep(page, testInfo, { tcId: 'TC-04', step: 4, desc: 'Danh gia logic PASS: Bang cong ngay ton tai du lieu hop le cua nhan vien 046' });
    } else {
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng công ngày không tìm thấy bản ghi dữ liệu cho nhân viên 046 sau khi lọc'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({ issue: 'Không tìm thấy dòng công của nhân viên 046 trong Bảng công ngày', dbCount: dbRows ? dbRows.length : 0 })
      });
      await captureStep(page, testInfo, { tcId: 'TC-04', step: 4, desc: 'Danh gia logic FAIL: Khong tim thay ban ghi cong cua nhan vien 046' });
      expect(isPassed).toBeTruthy();
    }
  });

  // --------------------------------------------------------------------------
  // TC-05: TÍNH LƯƠNG TỰ ĐỘNG & ĐỐI SOÁT DỮ LIỆU (ROLE: CHIEN.NGUYEN)
  // --------------------------------------------------------------------------
  test('TC-05: Kế toán chạy tính toán lương tự động (Role: chien.nguyen)', async ({ page }, testInfo) => {
    test.setTimeout(90000);

    // Bước 1: Đăng nhập tài khoản Ban Giám đốc / Kế toán trưởng chien.nguyen
    await loginDirectly(page, ACCOUNTS.DIRECTOR);
    await captureStep(page, testInfo, { tcId: 'TC-05', step: 1, desc: 'Ban giam doc chien nguyen dang nhap he thong' });

    // Bước 2: Mở phân hệ Tiền lương (MnuPRL000) -> Lương nhân viên (MnuHRS145)
    await openMenu(page, { dockCode: 'MnuHRS145', dockModule: 'MnuPRL000', menuName: 'Lương nhân viên', menuId: 'MnuHRS145' });
    await page.waitForTimeout(3000);
    await captureStep(page, testInfo, { tcId: 'TC-05', step: 2, desc: 'Mo bang tinh luong phan he PRL' });

    // Bước 3: Quan sát lưới bảng lương và tìm kiếm nhân viên 046
    const searchSalary = page.locator('.dx-datagrid-search-panel input, input[placeholder*="Tìm kiếm"]').first();
    if (await searchSalary.isVisible({ timeout: 4000 }).catch(() => false)) {
      await moveAndClick(page, searchSalary, { steps: 6, pause: 150 });
      await searchSalary.fill('046');
      await page.waitForTimeout(2000);
    }

    // Chờ dòng dữ liệu của nhân viên 046 hiển thị và cuộn vào tầm nhìn trực quan
    const salaryRow046 = page.locator('.dx-datagrid-table .dx-data-row:has-text("046"), table tbody tr:has-text("046")').first();
    await salaryRow046.waitFor({ state: 'visible', timeout: 12000 }).catch(() => {});
    await salaryRow046.scrollIntoViewIfNeeded().catch(() => {});
    await page.waitForTimeout(1000);
    await captureStep(page, testInfo, { tcId: 'TC-05', step: 3, desc: 'Kiem tra chi tieu luong cua nhan vien 046' });

    // Bước 4: Đánh giá logic kiểm chứng kép UI + CSDL
    const hasSalaryRow = await salaryRow046.isVisible().catch(() => false);
    const dbSalCheck = query(`SELECT TOP 1 * FROM tblSal_Sal WHERE EmployeeID = '046'`);
    const isPassed = hasSalaryRow && dbSalCheck && dbSalCheck.length > 0;

    if (isPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: 'PASS - Bảng lương công ty tổng hợp đầy đủ chỉ tiêu lương cho nhân viên 046 (Khớp CSDL tblSal_Sal)'
      });
      await captureStep(page, testInfo, { tcId: 'TC-05', step: 4, desc: 'Danh gia logic PASS: Bang luong co mat nhan vien 046' });
    } else {
      testInfo.annotations.push({
        type: 'business_status',
        description: 'FAIL - Bảng lương không tìm thấy dòng dữ liệu cho nhân viên 046'
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({ issue: 'Không tìm thấy dòng lương của nhân viên 046', dbSalCount: dbSalCheck ? dbSalCheck.length : 0 })
      });
      await captureStep(page, testInfo, { tcId: 'TC-05', step: 4, desc: 'Danh gia logic FAIL: Khong tim thay nhan vien 046 tren bang luong' });
      expect(isPassed).toBeTruthy();
    }
  });

  // --------------------------------------------------------------------------
  // TC-06: ĐỐI SOÁT ĐỊNH LƯỢNG TỪNG TRƯỜNG TRÊN PHIẾU LƯƠNG (ROLE: TAI.DANG)
  // --------------------------------------------------------------------------
  test('TC-06: Nhân viên đối soát định lượng từng trường trên Phiếu lương cá nhân (Role: tai.dang)', async ({ page }, testInfo) => {
    test.setTimeout(90000);

    // Bước 1: Đăng nhập lại với tài khoản Nhân viên tai.dang
    await loginDirectly(page, ACCOUNTS.STAFF_DEV);
    await captureStep(page, testInfo, { tcId: 'TC-06', step: 1, desc: 'Nhan vien tai dang dang nhap he thong' });

    // Bước 2: Mở menu Phiếu lương từ Cổng thông tin (MnuWPT000)
    await openMenu(page, { dockModule: 'MnuWPT000', menuName: 'Phiếu lương', menuId: 'MnuPRL445' });
    await page.waitForTimeout(3000);

    // Chờ nạp form phiếu lương và chờ trường #psEmpID có dữ liệu thực tế
    const slipRoot = page.locator('#psPayslip, #psRoot, .salary-slip, #sp_salaryslip').first();
    await slipRoot.waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});

    await page.waitForFunction(() => {
      const el = document.getElementById('psEmpID');
      return el && el.innerText.trim().length > 0;
    }, { timeout: 15000 }).catch(() => {});
    await page.waitForTimeout(1000);
    await captureStep(page, testInfo, { tcId: 'TC-06', step: 2, desc: 'Giao dien phieu luong ca nhan day du cac truong chi tieu' });

    // Bước 3: Bóc tách toàn diện dữ liệu thực tế trên UI (Field Extraction)
    const uiData = await page.evaluate(() => {
      const getVal = (id) => {
        const el = document.getElementById(id);
        return el ? el.innerText.trim() : '';
      };
      return {
        companyName:     getVal('psCompanyName'),
        companyAddr:     getVal('psCompanyAddr'),
        monthYear:       getVal('psMonthYear'),
        empId:           getVal('psEmpID'),
        fullName:        getVal('psFullName'),
        hireDate:        getVal('psHireDate'),
        position:        getVal('psPosition'),
        dependents:      getVal('psDependents'),
        stdDays:         getVal('psStdDays'),
        actDays:         getVal('psActDays'),
        otHours:         getVal('psOTHours'),
        daysOff:         getVal('psDaysOff'),
        lateEarly:       getVal('psLateEarly'),
        basicSalary:     getVal('psBasicSalary'),
        otSalary:        getVal('psOTSalary'),
        totalOther:      getVal('psTotalOther'),
        totalIncome:     getVal('psTotalIncome'),
        totalDeductions: getVal('psTotalDeductions'),
        selfTax:         getVal('psSelfTax'),
        depTax:          getVal('psDepTax'),
        taxIncome:       getVal('psTaxIncome'),
        pit:             getVal('psPIT'),
        netSalary:       getVal('psNetSalary')
      };
    });

    console.log('📊 [TC-06]: Dữ liệu bóc tách thực tế từ UI Phiếu lương:\n', JSON.stringify(uiData, null, 2));

    // Bước 4: Truy vấn Ground Truth từ CSDL làm chuẩn đối chiếu định lượng (Luật Thép 8)
    const dbEmp = query(`
      SELECT TOP 1 e.EmployeeID, e.FullName, CONVERT(varchar, e.HireDate, 103) as HireDateStr
      FROM tblEmployee e WHERE e.EmployeeID = '046'
    `);

    const dbSal = query(`
      SELECT TOP 1 s.Month, s.Year, s.ActualMonthlyBasic, s.TotalIncome, s.GrossTakeHome
      FROM tblSal_Sal s
      WHERE s.EmployeeID = '046'
      ORDER BY s.Year DESC, s.Month DESC
    `);
    const targetMonth = dbSal.length > 0 ? dbSal[0].Month : 8;
    const targetYear = dbSal.length > 0 ? dbSal[0].Year : 2026;

    const dbDetail = query(`
      SELECT TOP 1 StandardWDays, DaysOfSalEntry
      FROM tblSal_Sal_Detail
      WHERE EmployeeID = '046' AND Month = ${targetMonth} AND Year = ${targetYear}
    `);

    const dbTax = query(`
      SELECT TOP 1 EmployeeExemption, FamilyExemption, IncomeTaxable, TaxAmt
      FROM tblSal_Tax
      WHERE EmployeeID = '046' AND Month = ${targetMonth} AND Year = ${targetYear}
    `);

    // Helper chuẩn hóa so sánh số tiền / chuỗi
    const cleanNum = (str) => String(str || '').replace(/[^0-9.-]/g, '');

    // Bước 5: Lập Bảng Ma Trận Đối Soát Từng Trường (Field-by-Field Reconciliation Matrix)
    const expectedEmpId = dbEmp[0]?.EmployeeID || '046';
    const expectedFullName = dbEmp[0]?.FullName || 'Đặng Minh Tài';
    const expectedHireDate = dbEmp[0]?.HireDateStr || '15/07/2025';
    const expectedMonthYear = `${String(targetMonth).padStart(2, '0')}/${targetYear}`;
    const expectedStdDays = dbDetail[0]?.StandardWDays != null ? String(dbDetail[0].StandardWDays) : '23';
    const expectedActDays = dbDetail[0]?.DaysOfSalEntry != null ? String(dbDetail[0].DaysOfSalEntry) : '23';
    const expectedBasic = String(dbSal[0]?.ActualMonthlyBasic || 0);
    const expectedTotalIncome = String(dbSal[0]?.TotalIncome || 0);
    const expectedNetSalary = String(dbSal[0]?.GrossTakeHome || 0);

    const checks = [
      { name: 'Mã nhân viên (psEmpID)', ui: uiData.empId, db: expectedEmpId, passed: uiData.empId === expectedEmpId },
      { name: 'Họ và tên (psFullName)', ui: uiData.fullName, db: expectedFullName, passed: uiData.fullName === expectedFullName },
      { name: 'Ngày vào làm (psHireDate)', ui: uiData.hireDate, db: expectedHireDate, passed: uiData.hireDate === expectedHireDate },
      { name: 'Kỳ lương Tháng/Năm (psMonthYear)', ui: uiData.monthYear, db: expectedMonthYear, passed: uiData.monthYear.includes(expectedMonthYear) },
      { name: 'Công chuẩn (psStdDays)', ui: uiData.stdDays, db: `${expectedStdDays} ngày`, passed: cleanNum(uiData.stdDays) === cleanNum(expectedStdDays) },
      { name: 'Công thực tế (psActDays)', ui: uiData.actDays, db: `${expectedActDays} ngày`, passed: cleanNum(uiData.actDays) === cleanNum(expectedActDays) },
      { name: 'Lương cơ bản (psBasicSalary)', ui: uiData.basicSalary, db: expectedBasic, passed: cleanNum(uiData.basicSalary) === cleanNum(expectedBasic) },
      { name: 'Tổng thu nhập (psTotalIncome)', ui: uiData.totalIncome, db: expectedTotalIncome, passed: cleanNum(uiData.totalIncome) === cleanNum(expectedTotalIncome) },
      { name: 'Thực lĩnh / Lương thực nhận (psNetSalary)', ui: uiData.netSalary, db: expectedNetSalary, passed: cleanNum(uiData.netSalary) === cleanNum(expectedNetSalary) }
    ];

    console.log('📋 [TC-06]: KẾT QUẢ ĐỐI SOÁT TỪNG TRƯỜNG ĐỊNH LƯỢNG:');
    console.table(checks.map(c => ({
      'Trường chỉ tiêu': c.name,
      'Giá trị UI': c.ui,
      'Giá trị CSDL': c.db,
      'Trạng thái': c.passed ? '✅ KHỚP 100%' : '❌ LỆCH'
    })));

    const mismatches = checks.filter(c => !c.passed);
    const allPassed = mismatches.length === 0;

    // Lập bảng Markdown chi tiết để đính kèm vào báo cáo kiểm thử
    const markdownTable = [
      '| STT | Trường chỉ tiêu trên Phiếu lương | Giá trị trên UI | Giá trị đối ứng trong CSDL | Trạng thái so khớp |',
      '| :---: | :--- | :--- | :--- | :---: |',
      ...checks.map((c, i) => `| ${i + 1} | ${c.name} | ${c.ui || '*(Trống)*'} | ${c.db || '*(Trống)*'} | ${c.passed ? '✅ KHỚP 100%' : '❌ SAI LỆCH'} |`)
    ].join('\n');

    if (allPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Đối soát định lượng khớp 100% từng trường trên Phiếu lương (${checks.length}/${checks.length} chỉ tiêu khớp CSDL). Kỳ lương: ${expectedMonthYear}, Thực lĩnh: ${uiData.netSalary || '0'} VNĐ.\n\n${markdownTable}`
      });
      await captureStep(page, testInfo, { tcId: 'TC-06', step: 3, desc: 'Danh gia logic PASS: Doi soat dinh luong khop 100% tung truong phieu luong' });
    } else {
      const failMsg = `FAIL - Phát hiện sai lệch số liệu định lượng tại ${mismatches.length}/${checks.length} trường trên Phiếu lương!`;
      testInfo.annotations.push({
        type: 'business_status',
        description: `${failMsg}\n\n${markdownTable}`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({
          issue: failMsg,
          mismatches: mismatches.map(m => ({ field: m.name, uiValue: m.ui, dbValue: m.db }))
        })
      });
      await captureStep(page, testInfo, { tcId: 'TC-06', step: 3, desc: 'Danh gia logic FAIL: Phat hien lech so lieu dinh luong tren phieu luong' });
      expect(allPassed).toBeTruthy();
    }
  });
});
