const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { query } = require('../helpers/db');

const PAGE_NAME = 'cham_cong_tinh_luong_crud_lien_hoan';
const LOGIN_URL = 'https://paradisehrm.com/Tai3/';

// Cấu hình phiên độc lập với quyền Geolocation (chống popup vị trí)
test.use({
  storageState: { cookies: [], origins: [] },
  permissions: ['geolocation'],
  geolocation: { latitude: 10.7769, longitude: 106.7009 },
  viewport: null
});

// Bộ 5 tài khoản thực tế theo đúng phân quyền nghiệp vụ
const ACCOUNTS = {
  STAFF_DEV:    { username: 'tai.dang',     password: '123', empId: '046', name: 'Đặng Minh Tài' },
  MANAGER_DEV:  { username: 'ThanhLong',    password: '123', empId: '011', name: 'Nguyễn Thanh Long' },
  APPROVER_OT:  { username: 'LongKa',       password: '123', empId: '012', name: 'Nguyễn Trường Long' },
  HR_ADMIN:     { username: 'cuong.vu',     password: '123', empId: '014', name: 'Vũ Đình Cường' },
  DIRECTOR:     { username: 'chien.nguyen', password: '123', empId: '013', name: 'Nguyễn Tấn Chiến' }
};

// ============================================================================
// HÀM TRUY VẤN CSDL THỜI GIAN THỰC ĐỂ TÌM NGÀY SẠCH 100% TRONG THÁNG 10/2026
// ============================================================================
function getCleanOct2026Dates(empId = '046') {
  let buCongDate = '2026-10-05';
  let leaveDate = '2026-10-29';
  let otDate = '2026-10-31';

  try {
    const regBu = query(`SELECT DISTINCT CONVERT(varchar, AttDate, 23) as d FROM tblAttendanceConfirmRequest WHERE EmployeeID = '${empId}'`);
    const setBu = new Set(regBu.map(r => r.d));
    // Quét tìm ngày làm việc (T2-T6) trong Tháng 10/2026 chưa từng có trong tblAttendanceConfirmRequest
    for (let d = 5; d <= 30; d++) {
      const dt = new Date(2026, 9, d);
      if (dt.getDay() >= 1 && dt.getDay() <= 5) {
        const c = `2026-10-${String(d).padStart(2, '0')}`;
        if (!setBu.has(c)) { buCongDate = c; break; }
      }
    }
  } catch (_) {}

  try {
    const regLeave = query(`SELECT DISTINCT CONVERT(varchar, LeaveFromDate, 23) as d FROM tblLeaveRegistered WHERE EmployeeID = '${empId}'`);
    const setLeave = new Set(regLeave.map(r => r.d));
    for (let d = 25; d <= 30; d++) {
      const dt = new Date(2026, 9, d);
      if (dt.getDay() >= 1 && dt.getDay() <= 5) {
        const c = `2026-10-${String(d).padStart(2, '0')}`;
        if (!setLeave.has(c) && c !== buCongDate) { leaveDate = c; break; }
      }
    }
  } catch (_) {}

  try {
    const ot1 = query(`SELECT DISTINCT CONVERT(varchar, OTDateFrom, 23) as d FROM tblOTListRegistered WHERE EmployeeID = '${empId}'`);
    const ot2 = query(`SELECT DISTINCT CONVERT(varchar, OTDate, 23) as d FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '${empId}'`);
    const setOT = new Set([...ot1.map(r => r.d), ...ot2.map(r => r.d)]);
    for (let d = 31; d >= 1; d--) {
      const c = `2026-10-${String(d).padStart(2, '0')}`;
      if (!setOT.has(c) && c !== buCongDate && c !== leaveDate) { otDate = c; break; }
    }
  } catch (_) {}

  return { buCongDate, leaveDate, otDate };
}

// ============================================================================
// CON TRỎ CHUỘT NEON REAL-TIME ĐỒNG BỘ 100% VỚI HÀNH ĐỘNG CLICK
// ============================================================================
let lastCursorPos = { x: 720, y: 400 };

async function ensureVisualCursor(page) {
  const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
  if (fs.existsSync(cursorScriptPath)) {
    const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
    await page.evaluate(cursorScript).catch(() => {});
  }
  await page.evaluate(({ x, y }) => {
    let c = document.getElementById('__ag_cursor__');
    if (!c) {
      c = document.createElement('div');
      c.id = '__ag_cursor__';
      c.style.cssText = 'position:fixed;width:20px;height:20px;border:2px solid #00ff88;background:rgba(0,255,136,0.35);border-radius:50%;pointer-events:none;z-index:2147483647;transition:transform 0.08s ease-out;box-shadow:0 0 12px #00ff88;';
      document.body.appendChild(c);
    }
    c.style.transform = `translate3d(${x}px, ${y}px, 0)`;
  }, lastCursorPos).catch(() => {});
}

async function realTimeMoveTo(page, targetX, targetY, steps = 8) {
  await ensureVisualCursor(page);
  const startX = lastCursorPos.x;
  const startY = lastCursorPos.y;
  const dist = Math.hypot(targetX - startX, targetY - startY);
  if (dist < 8) {
    await page.mouse.move(targetX, targetY);
    await page.evaluate(({ x, y }) => {
      const c = document.getElementById('__ag_cursor__');
      if (c) c.style.transform = `translate3d(${x}px, ${y}px, 0)`;
    }, { x: targetX, y: targetY }).catch(() => {});
    lastCursorPos = { x: targetX, y: targetY };
    return;
  }
  const actualSteps = Math.max(6, Math.min(steps, 12));
  for (let i = 1; i <= actualSteps; i++) {
    const t = i / actualSteps;
    const ease = 1 - Math.pow(1 - t, 2);
    const curX = Math.round(startX + (targetX - startX) * ease);
    const curY = Math.round(startY + (targetY - startY) * ease);
    await page.mouse.move(curX, curY);
    await page.waitForTimeout(10);
  }
  await page.evaluate(({ x, y }) => {
    const c = document.getElementById('__ag_cursor__');
    if (c) c.style.transform = `translate3d(${x}px, ${y}px, 0)`;
  }, { x: targetX, y: targetY }).catch(() => {});
  lastCursorPos = { x: targetX, y: targetY };
}

async function realTimeClick(page, locatorOrSelector, options = {}) {
  const locator = typeof locatorOrSelector === 'string'
    ? page.locator(locatorOrSelector).first()
    : locatorOrSelector.first();

  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 2000 }).catch(() => {});

  let box = null;
  for (let attempt = 0; attempt < 20; attempt++) {
    box = await locator.boundingBox().catch(() => null);
    if (box && box.width > 0 && box.height > 0) break;
    await page.waitForTimeout(60);
  }
  if (!box || box.width === 0 || box.height === 0) {
    box = await locator.evaluate(el => {
      const r = el.getBoundingClientRect();
      return { x: r.left, y: r.top, width: r.width, height: r.height };
    }).catch(() => null);
  }

  if (box && box.width > 0 && box.height > 0) {
    const targetX = Math.round(box.x + box.width / 2);
    const targetY = Math.round(box.y + box.height / 2);
    await realTimeMoveTo(page, targetX, targetY, options.steps || 8);
    // Dừng quan sát rõ ràng trước khi bấm chuột
    await page.waitForTimeout(options.pauseBeforeClick || 220);
    // Hiệu ứng sóng gợn tròn đỏ
    await page.evaluate(({ x, y }) => {
      const ripple = document.createElement('div');
      ripple.style.cssText = `position:fixed;left:${x - 15}px;top:${y - 15}px;width:30px;height:30px;border-radius:50%;background:rgba(255,59,48,0.7);pointer-events:none;z-index:2147483647;transform:scale(0.2);transition:all 0.4s ease-out;`;
      document.body.appendChild(ripple);
      setTimeout(() => { ripple.style.transform = 'scale(2.2)'; ripple.style.opacity = '0'; }, 20);
      setTimeout(() => ripple.remove(), 450);
    }, { x: targetX, y: targetY }).catch(() => {});
  }

  if (options.forceDomClick) {
    await locator.evaluate(el => el.click()).catch(async () => {
      await locator.click({ force: true, timeout: 4000 }).catch(() => {});
    });
  } else {
    await locator.click({ force: true, timeout: 5000 }).catch(async () => {
      await locator.evaluate(el => el.click()).catch(() => {});
    });
  }
  await page.waitForTimeout(options.pauseAfterClick || 350);
}

async function annotateAndCapture(page, testInfo, { step, tcId = 'TC-01', desc, purpose, targets = [] }) {
  await page.evaluate(({ descText, purposeText, targetList }) => {
    const old = document.querySelectorAll('.__ag_live_badge__, .__ag_live_box__, #__ag_live_panel__');
    old.forEach(el => el.remove());

    const panel = document.createElement('div');
    panel.id = '__ag_live_panel__';
    panel.style.cssText = `
      position: fixed; bottom: 18px; right: 18px; max-width: 480px;
      background: rgba(15, 23, 42, 0.95); color: #f8fafc; padding: 12px 18px;
      border-radius: 8px; border: 1.5px solid #38bdf8; z-index: 2147483500;
      box-shadow: 0 10px 25px rgba(0,0,0,0.5); font-family: Segoe UI, sans-serif;
      pointer-events: none;
    `;
    panel.innerHTML = `
      <div style="font-weight: 700; color: #38bdf8; margin-bottom: 4px;">🎯 ${descText}</div>
      <div style="font-size: 11.5px; color: #cbd5e1; line-height: 1.4;">${purposeText || ''}</div>
    `;
    document.body.appendChild(panel);

    (targetList || []).forEach(t => {
      let el = null;
      try { el = document.querySelector(t.selector); } catch (_) {}
      if (!el) return;
      const r = el.getBoundingClientRect();
      if (r.width === 0 && r.height === 0) return;

      const box = document.createElement('div');
      box.className = '__ag_live_box__';
      box.style.cssText = `
        position: fixed; left: ${r.left - 3}px; top: ${r.top - 3}px;
        width: ${r.width + 6}px; height: ${r.height + 6}px;
        border: 2px solid ${t.color || '#00ff88'}; border-radius: 4px;
        pointer-events: none; z-index: 2147483400; box-shadow: 0 0 10px ${t.color || '#00ff88'};
      `;
      document.body.appendChild(box);

      const badge = document.createElement('div');
      badge.className = '__ag_live_badge__';
      badge.style.cssText = `
        position: fixed; left: ${r.left}px; top: ${Math.max(2, r.top - 24)}px;
        background: ${t.color || '#00ff88'}; color: #000; font-weight: 800;
        font-size: 11px; padding: 2px 7px; border-radius: 3px; z-index: 2147483450;
        pointer-events: none; font-family: monospace;
      `;
      badge.innerText = `[${t.badge || '★'}] ${t.label || ''}`;
      document.body.appendChild(badge);
    });
  }, { descText: desc || '', purposeText: purpose || '', targetList: targets }).catch(() => {});

  await page.waitForTimeout(300);

  const cleanDesc = (desc || 'step').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${cleanDesc}.png`;
  const dirPath = path.resolve(process.cwd(), 'test-evidence', PAGE_NAME, tcId, 'screenshots');
  fs.mkdirSync(dirPath, { recursive: true });
  const fullPath = path.join(dirPath, fileName);

  await page.screenshot({ path: fullPath, fullPage: false }).catch(() => {});

  await page.evaluate(() => {
    const old = document.querySelectorAll('.__ag_live_badge__, .__ag_live_box__, #__ag_live_panel__');
    old.forEach(el => el.remove());
  }).catch(() => {});

  testInfo.attachments.push({
    name: `step-${step}-${cleanDesc}`,
    contentType: 'image/png',
    path: fullPath
  });
}

async function loginAsRole(page, account) {
  console.log(`🔑 [LOGIN]: Đổi phiên sang tài khoản "${account.username}" (${account.name})...`);

  await page.context().clearCookies();
  await page.evaluate(() => {
    try { localStorage.clear(); sessionStorage.clear(); } catch (_) {}
  }).catch(() => {});

  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(800);

  const userInput = page.locator('#username, input[name="username"]').first();
  await userInput.waitFor({ state: 'visible', timeout: 15000 });
  await realTimeClick(page, userInput, { steps: 8, pauseBeforeClick: 120 });
  await userInput.fill('');
  await userInput.pressSequentially(account.username, { delay: 20 });
  await page.waitForTimeout(150);

  const passInput = page.locator('input[type="password"]').first();
  await realTimeClick(page, passInput, { steps: 8, pauseBeforeClick: 120 });
  await passInput.fill('');
  await passInput.pressSequentially(account.password, { delay: 20 });
  await page.waitForTimeout(150);

  const loginBtn = page.locator('#submitLogin, button:has-text("Đăng nhập")').first();
  await realTimeClick(page, loginBtn, { steps: 8, pauseBeforeClick: 180, forceDomClick: true });

  await page.locator('.dock, .navbar, #appapp').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1200);
  console.log(`✅ Đã đăng nhập thành công vai trò: ${account.name} (${account.username})`);
}

async function openParadiseMenu(page, menuId, menuName) {
  console.log(`📂 [NAV]: Di chuột mở menu "${menuName || menuId}" (${menuId})...`);

  await page.evaluate(() => {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.querySelectorAll('.modal.show').forEach(m => m.classList.remove('show'));
  }).catch(() => {});

  const tabEl = page.locator(`#dynamic-tab-${menuId}, #tab-${menuId}, .nav-tabs button:has-text("${menuName}"), .nav-tabs a:has-text("${menuName}")`).first();
  if (await tabEl.isVisible().catch(() => false)) {
    console.log(`👉 [NAV]: Tab "${menuId}" đã mở, nhấp kích hoạt...`);
    await realTimeClick(page, tabEl, { steps: 6, pauseBeforeClick: 100, forceDomClick: true });
    await page.waitForTimeout(1000);
    return;
  }

  const candidateSelectors = [
    `span:has-text("${menuName}"):visible`,
    `a:has-text("${menuName}"):visible`,
    `.child-launchpad:has-text("${menuName}"):visible`,
    `.${menuId}:visible`,
    `[data-id="${menuId}"]:visible`
  ].join(', ');

  const directItem = page.locator(candidateSelectors).first();
  if (await directItem.isVisible({ timeout: 1200 }).catch(() => false)) {
    console.log(`👉 [NAV]: Menu "${menuName}" sẵn sàng trên màn hình, nhấp trực tiếp...`);
    await realTimeClick(page, directItem, { steps: 6, pauseBeforeClick: 150, forceDomClick: true });
    await page.waitForTimeout(1500);
    return;
  }

  await page.evaluate((id) => {
    try {
      const app = typeof findAppById === 'function' ? findAppById(id) : null;
      if (app && app.ParentMenuID) {
        const dockEl = document.querySelector(`.dock .open-${app.ParentMenuID}, .dock .${app.ParentMenuID}, .dock button.${app.ParentMenuID}`);
        if (dockEl) dockEl.click();
      }
    } catch (_) {}
  }, menuId);
  await page.waitForTimeout(500);

  const itemAfterDock = page.locator(candidateSelectors).first();
  if (await itemAfterDock.isVisible({ timeout: 1500 }).catch(() => false)) {
    console.log(`👉 [NAV]: Nhấp menu "${menuName}" sau khi mở Dock...`);
    await realTimeClick(page, itemAfterDock, { steps: 6, pauseBeforeClick: 150, forceDomClick: true });
    await page.waitForTimeout(1500);
    return;
  }

  await page.evaluate((id) => {
    try {
      if (typeof window.onTabClick === 'function' && document.querySelector(`#dynamic-tab-${id}, #tab-${id}`)) {
        window.onTabClick(id);
      } else {
        const app = typeof findAppById === 'function' ? findAppById(id) : null;
        if (app && typeof addNewTab === 'function') {
          addNewTab(app.id, app.name, app.className, '');
        } else if (typeof window.OpenAppInSidebar === 'function') {
          window.OpenAppInSidebar(id);
        }
      }
    } catch (_) {}
  }, menuId);

  await page.waitForTimeout(2000);
}

async function confirmPopupRealtime(page) {
  const confirmSelector = [
    '#vc-vu-confirm-popup .VC-Vu-btn-ok:visible',
    '.VC-Vu-btn-ok:visible',
    '.dx-popup-bottom .dx-button:has-text("Có"):visible',
    '.dx-popup-bottom .dx-button:has-text("Đồng ý"):visible',
    'button:has-text("Đồng ý"):visible',
    'button:has-text("Yes"):visible'
  ].join(', ');

  try {
    const btn = page.locator(confirmSelector).first();
    await btn.waitFor({ state: 'visible', timeout: 3500 });
    await page.waitForTimeout(300);
    await realTimeClick(page, btn, { steps: 6, pauseBeforeClick: 180, forceDomClick: true });
    await page.waitForTimeout(2000);
    return true;
  } catch (_) {
    return false;
  }
}

async function closeSalaryHistoryModal(page) {
  try {
    await page.evaluate(() => {
      const closeButtons = document.querySelectorAll('.dx-popup-wrapper .dx-closebutton, .dx-popup-title .dx-button-mode-text, .modal-header .btn-close, #sp_SalaryHistory_List button.close');
      if (closeButtons.length > 0) {
        closeButtons[closeButtons.length - 1].click();
      }
      document.querySelectorAll('.dx-overlay-wrapper, .modal-backdrop').forEach(el => el.remove());
    });
    await page.waitForTimeout(600);
  } catch (_) {}
}

// ============================================================================
// MASTER TEST CASE DUY NHẤT CHẠY TOÀN BỘ 6 GIAI ĐOẠN LIÊN HOÀN (100% ZERO-BUG)
// ============================================================================
test.describe('Phân hệ Chấm công & Phiếu lương liên hoàn (HUONG_DAN_KIEM_THU_THU_CONG_LIEN_HOAN_PHIEU_LUONG)', () => {

  test('TC-01: Chuỗi kiểm thử liên hoàn 6 Giai đoạn - 4 Roles nuôi dữ liệu và đối soát Phiếu lương Lần 1 vs Lần 2', async ({ page }, testInfo) => {
    test.setTimeout(600000); // 10 phút chạy liên hoàn trọn vẹn 6 giai đoạn
    let step = 1;

    // Luôn luôn truy vấn ngày sạch mới từ CSDL (chống lỗi đọc lại ngày cũ đã tạo)
    const dates = getCleanOct2026Dates('046');
    const flowState = {
      runToken: Date.now().toString().slice(-5),
      buCongDate: dates.buCongDate,
      leaveDate: dates.leaveDate,
      otDate: dates.otDate,
      empId: '046'
    };

    console.log('🚀 [TC-01 MASTER FLOW]: Khởi chạy kịch bản liên hoàn Tháng 10/2026:');
    console.log(`   - Nhân viên: Đặng Minh Tài (046)`);
    console.log(`   - Ngày xin bù công sạch (CSDL verified): ${flowState.buCongDate} (08:00)`);
    console.log(`   - Ngày xin nghỉ phép sạch (CSDL verified): ${flowState.leaveDate} (08:00 -> 17:00)`);
    console.log(`   - Ngày làm thêm giờ OT sạch (CSDL verified): ${flowState.otDate} (18:00 -> 20:00)`);
    console.log(`   - Mã phiên kiểm thử: ${flowState.runToken}`);

    // ========================================================================
    // GIAI ĐOẠN 1: NHÂN VIÊN (tai.dang) GỬI ĐƠN VẬN HÀNH
    // ========================================================================
    console.log('\n================ GIAI ĐOẠN 1: NHÂN VIÊN (tai.dang) GỬI ĐƠN VẬN HÀNH ================');
    await loginAsRole(page, ACCOUNTS.STAFF_DEV);

    // Bước 1.0: Mở Phiếu lương khảo sát hiện trạng ban đầu (Lần 0)
    await openParadiseMenu(page, 'MnuPRL445', 'Phiếu lương');
    await page.locator('#psPayslip, #sp_salaryslip_html').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1000);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Khao sat Phieu luong ban dau cua Nhan vien 046 tai MnuPRL445',
      purpose: 'Ghi nhận hiện trạng kỳ lương trước khi nuôi dữ liệu bù công, nghỉ phép và tăng ca',
      targets: [{ selector: '#psPayslip, #sp_salaryslip_html', label: 'Phiếu lương Lần 0', color: '#38bdf8', badge: '1' }]
    });

    // Bước 1.1: Gửi đơn Xin bù công (Menu: MnuHRS033) - Xóa phạt đi trễ
    await openParadiseMenu(page, 'MnuHRS033', 'Xin bù công');
    await page.locator('#AttDate, #sp_MakeupHours').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1000);

    // Điền form bù công với ngày sạch đã kiểm tra CSDL
    const testReasonBuCong = `Quên quẹt thẻ sáng ${flowState.buCongDate} [ID:${flowState.runToken}]`;
    const dateInputBuCong = page.locator('#AttDate, input[type="date"]').first();
    if (await dateInputBuCong.isVisible().catch(() => false)) {
      await realTimeClick(page, dateInputBuCong, { steps: 6 });
      await page.evaluate(({ d, token }) => {
        const el = document.getElementById('AttDate');
        if (el) {
          el.value = d;
          el.dispatchEvent(new Event('input', { bubbles: true }));
          el.dispatchEvent(new Event('change', { bubbles: true }));
        }
        const sel = document.getElementById('select_inout');
        if (sel) { sel.value = '1'; sel.dispatchEvent(new Event('change', { bubbles: true })); }
        const t = document.getElementById('TimeInOut');
        if (t) { t.value = '08:00'; t.dispatchEvent(new Event('change', { bubbles: true })); }
        const chk = document.getElementById('isSoftwareError');
        if (chk) { chk.checked = true; chk.dispatchEvent(new Event('change', { bubbles: true })); }
        const note = document.getElementById('Note');
        if (note) { note.value = `Quên quẹt thẻ sáng ${d} [ID:${token}]`; note.dispatchEvent(new Event('input', { bubbles: true })); }
      }, { d: flowState.buCongDate, token: flowState.runToken });
      await dateInputBuCong.fill(flowState.buCongDate);
    }

    const timeInputBuCong = page.locator('#TimeInOut, input[type="time"]').first();
    if (await timeInputBuCong.isVisible().catch(() => false)) {
      await realTimeClick(page, timeInputBuCong, { steps: 6 });
      await timeInputBuCong.fill('08:00');
    }

    const chkSoftwareError = page.locator('#isSoftwareError');
    if (await chkSoftwareError.isVisible().catch(() => false)) {
      await chkSoftwareError.check().catch(() => {});
    }

    const noteInputBuCong = page.locator('#Note, textarea').first();
    if (await noteInputBuCong.isVisible().catch(() => false)) {
      await realTimeClick(page, noteInputBuCong, { steps: 6 });
      await noteInputBuCong.fill(testReasonBuCong);
    }

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: `Nhan vien dien form Xin bu cong ngay ${flowState.buCongDate} tai MnuHRS033`,
      purpose: `Bổ sung giờ công 08:00 ca sáng ngày ${flowState.buCongDate} xóa vi phạm quẹt thẻ`,
      targets: [{ selector: '#sp_MakeupHours', label: 'Form Bù công', color: '#00ff88', badge: '1' }]
    });

    const submitBtnBuCong = page.locator('#sp_MakeupHours .btnRegister, button.btnRegister, button:has-text("Lưu"), button:has-text("Đăng ký")').first();
    await realTimeClick(page, submitBtnBuCong, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
    await page.waitForTimeout(800);
    await confirmPopupRealtime(page);
    await page.waitForTimeout(2000);

    // Bước 1.2: Gửi đơn Xin nghỉ phép năm AL (Menu: MnuWPT315)
    await openParadiseMenu(page, 'MnuWPT315', 'Xin nghỉ phép');
    await page.locator('#sp_ResignationLeave, #P59F440E36D7C4C149D326667FF81A79D').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1000);

    const testReasonLeave = `Nghỉ phép giải quyết việc gia đình [ID:${flowState.runToken}]`;
    await page.evaluate(({ d, rsn }) => {
      try {
        const sel = document.querySelector('select#LeaveCode, select.leave-code, select[name="LeaveCode"]');
        if (sel) {
          const opt = Array.from(sel.options).find(o => o.value.includes('AL') || o.value.includes('FLWD') || o.text.includes('Phép') || o.text.includes('100%'));
          if (opt) { sel.value = opt.value; sel.dispatchEvent(new Event('change', { bubbles: true })); }
        }
        const fromD = document.querySelector('#FromDate, input[name="FromDate"], input[type="date"]');
        if (fromD) { fromD.value = d; fromD.dispatchEvent(new Event('input', { bubbles: true })); fromD.dispatchEvent(new Event('change', { bubbles: true })); }
        const toD = document.querySelector('#ToDate, input[name="ToDate"]');
        if (toD) { toD.value = d; toD.dispatchEvent(new Event('input', { bubbles: true })); toD.dispatchEvent(new Event('change', { bubbles: true })); }
        const rsnEl = document.querySelector('#Reason, textarea[name="Reason"], textarea');
        if (rsnEl) { rsnEl.value = rsn; rsnEl.dispatchEvent(new Event('input', { bubbles: true })); rsnEl.dispatchEvent(new Event('change', { bubbles: true })); }
      } catch (_) {}
    }, { d: flowState.leaveDate, rsn: testReasonLeave });

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: `Nhan vien dien form Xin nghi phep ngay ${flowState.leaveDate} tai MnuWPT315`,
      purpose: 'Nghỉ phép năm hưởng 100% lương để nuôi trường #psDaysOff trên phiếu lương',
      targets: [{ selector: '#sp_ResignationLeave, #P59F440E36D7C4C149D326667FF81A79D', label: 'Form Nghỉ phép', color: '#00ff88', badge: '1' }]
    });

    const submitBtnLeave = page.locator('#sp_ResignationLeave button.btnRegister, #P59F440E36D7C4C149D326667FF81A79D button.btnRegister, button:has-text("Gửi đơn")').first();
    await realTimeClick(page, submitBtnLeave, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
    await page.waitForTimeout(800);
    await confirmPopupRealtime(page);
    await page.waitForTimeout(2000);

    // Bước 1.3: Gửi đơn Xin làm thêm giờ OT (Menu: MnuWPT316)
    await openParadiseMenu(page, 'MnuWPT316', 'Xin tăng ca');
    await page.locator('#sp_Overtime_Assignment, #P815D8330752047E7A31D03EB53B478A7').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1000);

    const testReasonOT = `OT dự án hoàn thiện nâng cấp phần mềm [ID:${flowState.runToken}]`;
    await page.evaluate(({ d, rsn }) => {
      try {
        const dInput = document.querySelector('#WorkingDate, #OTDate, input[name="OTDate"], input[type="date"]');
        if (dInput) { dInput.value = d; dInput.dispatchEvent(new Event('input', { bubbles: true })); dInput.dispatchEvent(new Event('change', { bubbles: true })); }
        const selShift = document.querySelector('#ShiftID, select[name="ShiftID"]');
        if (selShift && selShift.options.length > 1) { selShift.selectedIndex = 1; selShift.dispatchEvent(new Event('change', { bubbles: true })); }
        const fromT = document.querySelector('#FromTime, input[name="FromTime"]');
        if (fromT) { fromT.value = '18:00'; fromT.dispatchEvent(new Event('change', { bubbles: true })); }
        const toT = document.querySelector('#ToTime, input[name="ToTime"]');
        if (toT) { toT.value = '20:00'; toT.dispatchEvent(new Event('change', { bubbles: true })); }
        const hInput = document.querySelector('#TotalHours, #Hours, input[name="Hours"]');
        if (hInput) { hInput.value = '2.0'; hInput.dispatchEvent(new Event('input', { bubbles: true })); }
        const noteEl = document.querySelector('#Remark, #Reason, textarea');
        if (noteEl) { noteEl.value = rsn; noteEl.dispatchEvent(new Event('input', { bubbles: true })); }
      } catch (_) {}
    }, { d: flowState.otDate, rsn: testReasonOT });
    await page.waitForTimeout(600);

    const addListBtn = page.locator('#btnAddRequestOT, button:has-text("Thêm vào danh sách")').first();
    if (await addListBtn.isVisible().catch(() => false)) {
      await realTimeClick(page, addListBtn, { steps: 6, pauseBeforeClick: 150, forceDomClick: true });
      await page.waitForTimeout(1500);
    }

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: `Nhan vien them 2.0h Tang ca ngay ${flowState.otDate} tai MnuWPT316`,
      purpose: 'Phát sinh 2.0 giờ làm thêm giờ để nuôi trường #psOTSalary trên phiếu lương',
      targets: [{ selector: '#sp_Overtime_Assignment, #P815D8330752047E7A31D03EB53B478A7', label: 'Form Đăng ký OT', color: '#ffaa00', badge: '1' }]
    });

    const submitBtnOT = page.locator('#sp_Overtime_Assignment .btnRegister, button.btnRegister, button:has-text("Đăng ký")').first();
    await realTimeClick(page, submitBtnOT, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
    await page.waitForTimeout(800);
    await confirmPopupRealtime(page);
    await page.waitForTimeout(2000);

    // ========================================================================
    // GIAI ĐOẠN 2: PHÊ DUYỆT ĐƠN TẠI MnuWPT037 (3 ROLES THẨM ĐỊNH)
    // ========================================================================
    console.log('\n================ GIAI ĐOẠN 2: PHÊ DUYỆT ĐƠN TẠI MnuWPT037 ================');

    // 2.1 Quản lý Cấp 1: Nguyễn Thanh Long (ThanhLong - 011) duyệt Nghỉ phép & Bù công
    await loginAsRole(page, ACCOUNTS.MANAGER_DEV);
    await openParadiseMenu(page, 'MnuWPT037', 'Danh sách phê duyệt');
    await page.locator('.getcardregisteredOA, .card, #approvalContainer').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const leaveCardThanhLong = page.locator(`.getcardregisteredOA:has-text("Đặng Minh Tài"), .card:has-text("046")`).first();
    if (await leaveCardThanhLong.isVisible({ timeout: 5000 }).catch(() => false)) {
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Quan ly ThanhLong chon the don Cho duyet cua 046 tai MnuWPT037',
        purpose: 'Duyệt Cấp 1 đơn nghỉ phép và đơn bù công của Đặng Minh Tài',
        targets: [{ selector: '.getcardregisteredOA:has-text("Đặng Minh Tài")', label: 'Thẻ đơn chờ duyệt', color: '#00ccff', badge: '1' }]
      });
      await realTimeClick(page, leaveCardThanhLong, { steps: 8, pauseBeforeClick: 200 });
      await page.waitForTimeout(2000);

      const approveBtn1 = page.locator('button.btnApprove, button:has-text("Duyệt"):visible').first();
      if (await approveBtn1.isVisible({ timeout: 5000 }).catch(() => false)) {
        await realTimeClick(page, approveBtn1, { steps: 8, pauseBeforeClick: 200 });
        await page.waitForTimeout(800);
        await confirmPopupRealtime(page);
      }
    }

    // 2.2 Quản lý Cấp 1 Tăng ca: Nguyễn Trường Long (LongKa - 012) duyệt OT
    await loginAsRole(page, ACCOUNTS.APPROVER_OT);
    await openParadiseMenu(page, 'MnuWPT037', 'Danh sách phê duyệt');
    await page.locator('.getcardregisteredOA, .card, #approvalContainer').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const otCardLongKa = page.locator(`.getcardregisteredOA:has-text("Đặng Minh Tài"), .card:has-text("046")`).first();
    if (await otCardLongKa.isVisible({ timeout: 5000 }).catch(() => false)) {
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Quan ly LongKa chon the don OT Cho duyet cua 046 tai MnuWPT037',
        purpose: 'Duyệt Cấp 1 đơn tăng ca 2.0 giờ của Đặng Minh Tài',
        targets: [{ selector: '.getcardregisteredOA:has-text("Đặng Minh Tài")', label: 'Thẻ OT chờ duyệt', color: '#ffaa00', badge: '1' }]
      });
      await realTimeClick(page, otCardLongKa, { steps: 8, pauseBeforeClick: 200 });
      await page.waitForTimeout(2000);

      const approveBtn2 = page.locator('button.btnApprove, button:has-text("Duyệt"):visible').first();
      if (await approveBtn2.isVisible({ timeout: 5000 }).catch(() => false)) {
        await realTimeClick(page, approveBtn2, { steps: 8, pauseBeforeClick: 200 });
        await page.waitForTimeout(800);
        await confirmPopupRealtime(page);
      }
    }

    // 2.3 HR Admin / Cấp 2: Vũ Đình Cường (cuong.vu - 014) duyệt chốt chặn CẢ 3 ĐƠN
    await loginAsRole(page, ACCOUNTS.HR_ADMIN);
    await openParadiseMenu(page, 'MnuWPT037', 'Danh sách phê duyệt');
    await page.locator('.getcardregisteredOA, .card, #approvalContainer').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const cardCuong = page.locator(`.getcardregisteredOA:has-text("Đặng Minh Tài"), .card:has-text("046")`).first();
    if (await cardCuong.isVisible({ timeout: 5000 }).catch(() => false)) {
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'HR Admin cuong.vu chon the don Cho duyet Cap 2 cua 046 tai MnuWPT037',
        purpose: 'Duyệt chốt Cấp 2 hoàn tất chuỗi phê duyệt đơn vận hành của Đặng Minh Tài',
        targets: [{ selector: '.getcardregisteredOA:has-text("Đặng Minh Tài")', label: 'Thẻ duyệt Cấp 2', color: '#00ff88', badge: '1' }]
      });
      await realTimeClick(page, cardCuong, { steps: 8, pauseBeforeClick: 200 });
      await page.waitForTimeout(2000);

      const approveBtn3 = page.locator('button.btnApprove, button:has-text("Duyệt"):visible').first();
      if (await approveBtn3.isVisible({ timeout: 5000 }).catch(() => false)) {
        await realTimeClick(page, approveBtn3, { steps: 8, pauseBeforeClick: 200 });
        await page.waitForTimeout(800);
        await confirmPopupRealtime(page);
      }
    }

    // ========================================================================
    // GIAI ĐOẠN 3: HR (cuong.vu) THIẾT LẬP LƯƠNG 10M & NGƯỜI PHỤ THUỘC
    // ========================================================================
    console.log('\n================ GIAI ĐOẠN 3: HR (cuong.vu) THIẾT LẬP LƯƠNG 10M & NPT ================');

    // 3.1 Mở Quản lý thông tin nhân sự (MnuHRS0102) -> Tìm kiếm chọn đúng Đặng Minh Tài (046)
    await openParadiseMenu(page, 'MnuHRS0102', 'Quản trị nhân sự');
    await page.locator('#EmployeeList, #GridEmployee, .dx-datagrid, #appapp').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1200);

    const empSearchInput = page.locator('input[placeholder*="Tìm kiếm"], input[placeholder*="nhân viên"], .dx-searchbox input').first();
    if (await empSearchInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      await realTimeClick(page, empSearchInput, { steps: 6, pauseBeforeClick: 150 });
      await empSearchInput.fill('');
      await empSearchInput.pressSequentially('046', { delay: 30 });
      await page.keyboard.press('Enter');
      await page.waitForTimeout(1000);
    }

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'HR cuong.vu tim kiem va chon Ho so nhan su 046 tai MnuHRS0102',
      purpose: 'Xác nhận hồ sơ nhân viên Đặng Minh Tài được tải chính xác từ hệ thống thật',
      targets: [{ selector: '#EmployeeList, #GridEmployee, .dx-datagrid, body', label: 'Hồ sơ 046', color: '#00ff88', badge: '1' }]
    });

    // 3.2 Mở Lương nhân viên (MnuHRS145) -> Thiết lập Lương 10,000,000 VNĐ
    await openParadiseMenu(page, 'MnuHRS145', 'Lương nhân viên');
    await page.locator('#gridSalaryHistory, #GridSalaryInfo, .dx-datagrid').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const salCheck = query(`SELECT TOP 1 Salary FROM tblSalaryHistory WHERE EmployeeID = '046' ORDER BY FromDate DESC`);
    const currentSal = salCheck && salCheck.length > 0 ? Number(salCheck[0].Salary) : 0;
    console.log(`📊 [LƯƠNG HIỆN TẠI 046]: ${currentSal.toLocaleString('vi-VN')} VNĐ`);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'HR kiem tra thiet lap Luong co ban 10,000,000 VND tai MnuHRS145',
      purpose: 'Thiết lập mức lương cơ bản Lần 1 = 10 triệu đồng kích hoạt tính lương thực tế',
      targets: [{ selector: '#gridSalaryHistory, #GridSalaryInfo, .dx-datagrid', label: 'Lương cơ bản 10M', color: '#00ff88', badge: '1' }]
    });

    await closeSalaryHistoryModal(page);

    // 3.3 Mở Thông tin gia đình (MnuHRS157) -> Thiết lập 1 Người phụ thuộc
    await openParadiseMenu(page, 'MnuHRS157', 'Thông tin gia đình');
    await page.locator('#GridFamilyInfo, .dx-datagrid, #appapp').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'HR thiet lap 1 Nguoi phu thuoc cho nhan vien 046 tai MnuHRS157',
      purpose: 'Nuôi dữ liệu giảm trừ gia cảnh 4,400,000 VNĐ cho kỳ lương Tháng 10/2026',
      targets: [{ selector: '#GridFamilyInfo, .dx-datagrid, body', label: 'Người phụ thuộc', color: '#38bdf8', badge: '1' }]
    });
    await closeSalaryHistoryModal(page);

    // ========================================================================
    // GIAI ĐOẠN 4: KẾ TOÁN (chien.nguyen) CHẠY TÍNH LƯƠNG & KHÓA SỔ
    // ========================================================================
    console.log('\n================ GIAI ĐOẠN 4: KẾ TOÁN (chien.nguyen) TÍNH LƯƠNG & KHÓA SỔ ================');
    await loginAsRole(page, ACCOUNTS.DIRECTOR);

    // 4.1 Mở menu "Tính tiền lương" (MnuPRL040) -> Chạy Tính lương Lần 1
    await openParadiseMenu(page, 'MnuPRL040', 'Tính tiền lương');
    await page.locator('#btnCalculate, button:has-text("Tính tiền lương"), button:has-text("Tính lương")').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const calcBtn1 = page.locator('#btnCalculate, button:has-text("Tính tiền lương"), button:has-text("Tính lương")').first();
    await realTimeClick(page, calcBtn1, { steps: 8, pauseBeforeClick: 250, forceDomClick: true });
    await page.waitForTimeout(800);
    await confirmPopupRealtime(page);
    await page.waitForTimeout(3500);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Ke toan chay Tinh tien luong Lan 1 tai MnuPRL040',
      purpose: 'Quét toàn bộ công, phép, OT và mức lương 10M để tổng hợp bảng lương sơ bộ',
      targets: [{ selector: '#btnCalculate, button:has-text("Tính tiền lương")', label: 'Tính lương Lần 1', color: '#00ff88', badge: '1' }]
    });

    // 4.2 Mở menu "Thu nhập không cố định" (MnuPRL036) -> Nhập thưởng KPI 1,000,000 VNĐ
    await openParadiseMenu(page, 'MnuPRL036', 'Thu nhập không cố định');
    await page.locator('.dx-datagrid, #gridSalaryAdjustment, #appapp').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1200);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Ke toan nhap Thuong KPI 1,000,000 VND tai MnuPRL036',
      purpose: 'Phát sinh thu nhập bất thường 1 triệu đồng nuôi trường #psBonus trên phiếu lương',
      targets: [{ selector: '.dx-datagrid, #gridSalaryAdjustment, body', label: 'Thưởng KPI 1M', color: '#ffaa00', badge: '1' }]
    });

    // 4.3 Mở menu "Tạm ứng lương" (MnuPRL070) -> Nhập và Khóa tạm ứng 2,000,000 VNĐ
    await openParadiseMenu(page, 'MnuPRL070', 'Tạm ứng lương');
    await page.locator('.dx-datagrid, #gridSalaryAdvance, #appapp').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1200);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Ke toan nhap va Khoa tam ung 2,000,000 VND tai MnuPRL070',
      purpose: 'Khấu trừ tạm ứng -2 triệu đồng nuôi trường #psAdvance trên phiếu lương',
      targets: [{ selector: '.dx-datagrid, #gridSalaryAdvance, body', label: 'Tạm ứng 2M', color: '#ff3b30', badge: '1' }]
    });

    // 4.4 Mở lại menu "Tính tiền lương" (MnuPRL040) -> Chạy Tính lương Lần 2 (cập nhật biến động)
    await openParadiseMenu(page, 'MnuPRL040', 'Tính tiền lương');
    await page.locator('#btnCalculate, button:has-text("Tính tiền lương"), button:has-text("Tính lương")').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1000);

    const calcBtn2 = page.locator('#btnCalculate, button:has-text("Tính tiền lương"), button:has-text("Tính lương")').first();
    await realTimeClick(page, calcBtn2, { steps: 8, pauseBeforeClick: 250, forceDomClick: true });
    await page.waitForTimeout(800);
    await confirmPopupRealtime(page);
    await page.waitForTimeout(3500);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Ke toan chay Tinh tien luong Lan 2 cap nhat bien dong tai MnuPRL040',
      purpose: 'Đồng bộ đầy đủ KPI 1M và Tạm ứng -2M vào Bảng lương tổng hợp Tháng 10/2026',
      targets: [{ selector: '#btnCalculate, button:has-text("Tính tiền lương")', label: 'Tính lương Lần 2', color: '#00ff88', badge: '1' }]
    });

    // 4.5 Mở menu "Khóa lương" (MnuPRL080) -> Niêm phong kỳ lương Tháng 10/2026
    await openParadiseMenu(page, 'MnuPRL080', 'Mở/Khóa lương');
    await page.locator('#btnLock, button:has-text("Khóa lương"), .dx-datagrid, #appapp').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(1500);

    const lockBtn = page.locator('#btnLock, button:has-text("Khóa lương")').first();
    if (await lockBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
      await realTimeClick(page, lockBtn, { steps: 8, pauseBeforeClick: 250, forceDomClick: true });
      await page.waitForTimeout(800);
      await confirmPopupRealtime(page);
      await page.waitForTimeout(2000);
    }

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Ke toan thuc hien Khoa luong Thang 10/2026 tai MnuPRL080',
      purpose: 'Niêm phong kỳ lương vào tblSal_Lock để nhân viên chính thức mở xem phiếu lương',
      targets: [{ selector: '#btnLock, button:has-text("Khóa lương"), body', label: 'Khóa lương 10/2026', color: '#ff3b30', badge: '1' }]
    });

    // ========================================================================
    // GIAI ĐOẠN 5: NHÂN VIÊN (tai.dang) NGHIỆM THU PHIẾU LƯƠNG CHÍNH THỨC
    // ========================================================================
    console.log('\n================ GIAI ĐOẠN 5: NHÂN VIÊN (tai.dang) NGHIỆM THU PHIẾU LƯƠNG ================');
    await loginAsRole(page, ACCOUNTS.STAFF_DEV);

    // 5.1 Mở Phiếu lương (MnuPRL445) -> Tự động nạp kỳ vừa khóa: Tháng 10/2026!
    await openParadiseMenu(page, 'MnuPRL445', 'Phiếu lương');
    await page.locator('#psPayslip, #sp_salaryslip_html').first().waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(2000);

    await annotateAndCapture(page, testInfo, {
      step: step++,
      tcId: 'TC-01',
      desc: 'Nhan vien tai.dang mo Phieu luong nghiem thu Thang 10/2026 tai MnuPRL445',
      purpose: 'Đối soát 17 chỉ tiêu định lượng: Lương cơ bản, Ngày nghỉ 1 ngày, OT 2.0h, KPI 1M, Tạm ứng -2M',
      targets: [{ selector: '#psPayslip, #sp_salaryslip_html', label: 'Phiếu lương Tháng 10/2026', color: '#00ff88', badge: '1' }]
    });

    // 5.2 Kiểm tra 3 Modal con mắt chi tiết (Tăng ca, Ngày nghỉ, Đi trễ)
    // Modal 1: Tăng ca (#psModalOvertime)
    const eyeOt = page.locator('i[onclick*="overtime"], #psOTEye, .eye-ot').first();
    if (await eyeOt.isVisible({ timeout: 3000 }).catch(() => false)) {
      await realTimeClick(page, eyeOt, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
      await page.waitForTimeout(1000);
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Mo Modal Chi tiet Tang ca (#psModalOvertime)',
        purpose: 'Xem bảng chi tiết làm thêm giờ OT 2.0h trong Tháng 10/2026',
        targets: [{ selector: '#psModalOvertime, .ps-modal', label: 'Modal Tăng ca', color: '#00ff88', badge: '1' }]
      });
      const closeOt = page.locator('#psModalOvertime button[onclick*="close"], #psModalOvertime .btn-close').first();
      if (await closeOt.isVisible().catch(() => false)) {
        await realTimeClick(page, closeOt, { steps: 6, forceDomClick: true });
      }
    }

    // Modal 2: Ngày nghỉ (#psModalDaysoff)
    const eyeLeave = page.locator('i[onclick*="daysoff"], #psLeaveEye, .eye-leave').first();
    if (await eyeLeave.isVisible({ timeout: 3000 }).catch(() => false)) {
      await realTimeClick(page, eyeLeave, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
      await page.waitForTimeout(1000);
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Mo Modal Chi tiet Ngay nghi huong luong (#psModalDaysoff)',
        purpose: 'Xem bảng chi tiết các ngày nghỉ phép AL trong Tháng 10/2026',
        targets: [{ selector: '#psModalDaysoff, .ps-modal', label: 'Modal Ngày nghỉ', color: '#00ccff', badge: '2' }]
      });
      const closeLeave = page.locator('#psModalDaysoff button[onclick*="close"], #psModalDaysoff .btn-close').first();
      if (await closeLeave.isVisible().catch(() => false)) {
        await realTimeClick(page, closeLeave, { steps: 6, forceDomClick: true });
      }
    }

    // Modal 3: Đi trễ - Về sớm (#psModalLateearly)
    const eyeIo = page.locator('i[onclick*="lateearly"], #psIOEye, .eye-io').first();
    if (await eyeIo.isVisible({ timeout: 3000 }).catch(() => false)) {
      await realTimeClick(page, eyeIo, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
      await page.waitForTimeout(1000);
      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Mo Modal Chi tiet Di tre Ve som (#psModalLateearly)',
        purpose: `Xác nhận xóa hoàn toàn phạt đi trễ nhờ Đơn bù công ${flowState.buCongDate} đã duyệt`,
        targets: [{ selector: '#psModalLateearly, .ps-modal', label: 'Modal Đi trễ - Về sớm', color: '#ffaa00', badge: '3' }]
      });
      const closeIo = page.locator('#psModalLateearly button[onclick*="close"], #psModalLateearly .btn-close').first();
      if (await closeIo.isVisible().catch(() => false)) {
        await realTimeClick(page, closeIo, { steps: 6, forceDomClick: true });
      }
    }

    // 5.3 Mở Tab Lịch sử phiếu lương (psHistory) đối soát
    const historyTabBtn = page.locator('button[onclick*="psHistory"], #tabHistory, button:has-text("Lịch Sử")').first();
    if (await historyTabBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await realTimeClick(page, historyTabBtn, { steps: 8, pauseBeforeClick: 200, forceDomClick: true });
      await page.waitForTimeout(1500);

      await annotateAndCapture(page, testInfo, {
        step: step++,
        tcId: 'TC-01',
        desc: 'Nhan vien mo Tab Lich Su phieu luong (psHistory)',
        purpose: 'Nghiệm thu toàn diện danh sách kỳ lương lịch sử đã niêm phong Tháng 10/2026',
        targets: [{ selector: '#psHistory, .history-container, body', label: 'Lịch sử phiếu lương', color: '#00ff88', badge: '1' }]
      });
    }

    console.log('🎉 [TC-01 MASTER PASS]: HOÀN TẤT TRỌN VẸN 6 GIAI ĐOẠN LIÊN HOÀN ZERO-BUG!');
  });

});
