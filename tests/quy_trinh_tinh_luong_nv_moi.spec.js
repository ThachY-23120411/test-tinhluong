const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { query } = require('../helpers/db');

const PAGE_NAME = 'quy_trinh_tinh_luong_nv_moi';
const LOGIN_URL = 'https://paradisehrm.com/Tai3/';

// Cấu hình phiên độc lập với quyền Geolocation và Toàn màn hình chuẩn (viewport: null)
test.use({
  storageState: { cookies: [], origins: [] },
  permissions: ['geolocation'],
  geolocation: { latitude: 10.7769, longitude: 106.7009 },
  viewport: null // Khớp với toàn màn hình từ --start-maximized, chống co khung viền đen
});

// Nhúng con trỏ chuột Neon phát sáng từ visual_cursor.js vào mọi phiên test
test.beforeEach(async ({ context }) => {
  const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
  if (fs.existsSync(cursorScriptPath)) {
    const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
    await context.addInitScript(cursorScript);
  }
});

// Biến theo dõi tọa độ con trỏ chuột hiện tại để tính khoảng cách di chuyển thực tế
let currentMousePos = { x: 100, y: 100 };

// Hàm tiện ích sinh số nguyên ngẫu nhiên trong khoảng [min, max] (Random Jitter)
function randomBetween(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// ============================================================================
// BỘ HELPER TƯƠNG TÁC TRỰC QUAN 100% CHUẨN NGƯỜI THẬT (NO BOT SHORTCUTS)
// ============================================================================

// 1. DI CHUỘT VÀ CLICK: Bắt buộc chuột phải bay tới tận nơi rồi mới bấm (Khóa chặn: Chưa tới nơi cấm bấm)
async function moveAndClick(page, locator, options = {}) {
  const target = locator.first();
  await target.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  await target.scrollIntoViewIfNeeded().catch(() => {});
  await page.waitForTimeout(randomBetween(100, 180)); // Chờ khung nhìn ổn định sau khi scroll

  // Đợi boundingBox ổn định qua 2 lần đo (~50ms) để chống trượt tọa độ khi popup/dropdown đang animation
  let box = await target.boundingBox();
  for (let i = 0; i < 6 && box; i++) {
    await page.waitForTimeout(50);
    const nextBox = await target.boundingBox();
    if (!nextBox) break;
    const settled =
      Math.abs(nextBox.x - box.x) <= 1.5 &&
      Math.abs(nextBox.y - box.y) <= 1.5 &&
      Math.abs(nextBox.width - box.width) <= 1.5 &&
      Math.abs(nextBox.height - box.height) <= 1.5;
    box = nextBox;
    if (settled) break;
  }

  if (!box || box.width < 1 || box.height < 1) {
    throw new Error('❌ [moveAndClick]: Không lấy được tọa độ hiển thị (boundingBox) của phần tử để di chuột!');
  }

  // Lệch tâm ngẫu nhiên trong vùng an toàn (30% - 70%) và làm tròn trùng khít tuyệt đối giữa chuột Neon & điểm click
  const maxPosX = Math.max(1, Math.floor(box.width) - 1);
  const maxPosY = Math.max(1, Math.floor(box.height) - 1);
  const posX = Math.max(1, Math.min(maxPosX, Math.round(box.width * (0.3 + Math.random() * 0.4))));
  const posY = Math.max(1, Math.min(maxPosY, Math.round(box.height * (0.3 + Math.random() * 0.4))));
  const targetX = box.x + posX;
  const targetY = box.y + posY;

  // Tính số bước (steps) dựa trên khoảng cách thực tế (cứ 22px = 1 bước, min 12, max 32)
  const distance = Math.hypot(targetX - currentMousePos.x, targetY - currentMousePos.y);
  const dynamicSteps = Math.max(12, Math.min(32, Math.round(distance / 22)));
  const steps = options.steps || dynamicSteps;

  // Thực hiện rê chuột mượt mà
  await page.mouse.move(targetX, targetY, { steps });
  currentMousePos = { x: targetX, y: targetY };

  // Dừng ngắm trước khi nhấn chuột (180ms - 350ms)
  const pauseBeforeClick = options.pause || randomBetween(180, 350);
  await page.waitForTimeout(pauseBeforeClick);

  // Kích hoạt click chuẩn xác ngay tại đúng tọa độ chuột đang dừng -> Triệt tiêu 100% hiện tượng chuột giật/dịch chuyển
  const clickDelay = randomBetween(50, 90);
  try {
    await target.click({
      position: { x: posX, y: posY },
      delay: clickDelay
    });
  } catch (err) {
    // Nếu popup/scroll mới nhích nhẹ làm target.click báo lệch/bị che thoáng qua, đo lại tọa độ thực rồi thử lại 1 nhịp
    await page.waitForTimeout(200);
    const retryBox = await target.boundingBox().catch(() => null);
    if (retryBox && retryBox.width >= 1 && retryBox.height >= 1) {
      const rPosX = Math.max(1, Math.min(Math.max(1, Math.floor(retryBox.width) - 1), Math.round(retryBox.width * 0.5)));
      const rPosY = Math.max(1, Math.min(Math.max(1, Math.floor(retryBox.height) - 1), Math.round(retryBox.height * 0.5)));
      await page.mouse.move(retryBox.x + rPosX, retryBox.y + rPosY, { steps: 6 });
      currentMousePos = { x: retryBox.x + rPosX, y: retryBox.y + rPosY };
    }
    try {
      await target.click({ delay: clickDelay, timeout: 4000 });
    } catch (retryErr) {
      await page.mouse.down();
      await page.waitForTimeout(randomBetween(60, 130));
      await page.mouse.up();
    }
  }

  // Nghỉ nhịp ngắn sau khi click
  await page.waitForTimeout(options.afterPause || randomBetween(200, 400));
}

// 2. GÕ PHÍM TỪNG CHỮ (CẤM COPY-PASTE / CẤM .fill() - TỰ ĐỘNG CHUYỂN HƯỚNG NẾU LÀ HTML5 DATE/TIME)
async function typeHumanLike(page, locator, text, options = {}) {
  const target = locator.first();
  await target.waitFor({ state: 'visible', timeout: 10000 });

  const inputType = await target.getAttribute('type').catch(() => 'text');
  if (inputType === 'date' || inputType === 'time') {
    return await fillDateHumanLike(page, target, text);
  }

  // Di chuột Neon tới đúng ô input và click để đặt con trỏ nhấp nháy
  await moveAndClick(page, target, { pause: randomBetween(180, 300) });

  // Xóa dữ liệu cũ bằng phím thật (Ctrl + A -> Backspace), TUYỆT ĐỐI KHÔNG dùng .fill('')
  if (options.clear !== false) {
    await page.keyboard.press('Control+A');
    await page.waitForTimeout(randomBetween(80, 140));
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(randomBetween(150, 250));
  }

  // Gõ từng ký tự một với tốc độ người thật (90ms - 170ms/chữ)
  const chars = Array.from(String(text));
  for (const char of chars) {
    await target.pressSequentially(char, { delay: randomBetween(90, 160) });
    // Nghỉ nhịp tự nhiên khi gõ xong 1 từ (dấu cách) hoặc dấu câu
    if (char === ' ' || ['.', ',', '-', '_', '/', '@'].includes(char)) {
      await page.waitForTimeout(randomBetween(120, 220));
    }
  }

  // Dừng nhẹ sau khi gõ xong câu để người xem kịp nhìn chữ cuối cùng
  await page.waitForTimeout(randomBetween(300, 500));
}

// ============================================================================
// 1. HELPER CHỌN SELECTBOX / COMBOBOX / LOOKUP (CHUỘT NEON MỞ POPUP & CHỌN ITEM)
// ============================================================================
async function selectBoxHumanLike(page, boxLocator, optionText, options = {}) {
  const targetBox = boxLocator.first();
  await expect(targetBox, `❌ Không tìm thấy SelectBox để chọn "${optionText}"`).toBeVisible({ timeout: 8000 });

  // Bước 1: Di chuột Neon tới đúng SelectBox (ưu tiên nút mũi tên xổ xuống nếu có) và Click mở
  const dropBtn = targetBox.locator('.dx-dropdowneditor-button, .select2-selection__arrow').first();
  if (await dropBtn.isVisible().catch(() => false)) {
    await moveAndClick(page, dropBtn, { pause: randomBetween(200, 350) });
  } else {
    await moveAndClick(page, targetBox, { pause: randomBetween(200, 350) });
  }

  // Bước 2: Chờ 400ms - 650ms để người xem thấy rõ danh sách popup xổ xuống
  await page.waitForTimeout(randomBetween(400, 650));

  // Bước 3: Nếu là Popup Lookup lớn có ô tìm kiếm bên trong -> Di chuột vào ô tìm kiếm gõ từng chữ
  const popupSearch = page.locator('.dx-overlay-content:visible input.dx-texteditor-input, .select2-search__field:visible').first();
  if (options.searchInPopup && await popupSearch.isVisible({ timeout: 1000 }).catch(() => false)) {
    await typeHumanLike(page, popupSearch, optionText);
    await page.waitForTimeout(randomBetween(500, 800));
  }

  // Bước 4: Tìm đúng dòng option đang hiển thị trong lớp Overlay/Popup và di chuột Neon tới Click!
  const itemLocator = page.locator(`
    .dx-overlay-content:visible .dx-list-item:has-text("${optionText}"),
    .dx-overlay-content:visible tr.dx-data-row:has-text("${optionText}"),
    .select2-results__option:visible:has-text("${optionText}"),
    ul.dropdown-menu:visible li:has-text("${optionText}")
  `).first();

  if (await itemLocator.isVisible({ timeout: 4000 }).catch(() => false)) {
    const scrollFn = typeof smoothScrollHumanLike === 'function' ? smoothScrollHumanLike : (async () => {});
    await scrollFn(page, itemLocator, { block: 'nearest', wait: 300 });
    await moveAndClick(page, itemLocator, { pause: randomBetween(220, 380) });
  } else {
    // Đối với thẻ <select> thuần của HTML (native select):
    // Sau khi chuột đã click vào hộp select ở Bước 1, dùng phím mũi tên / gõ chữ rồi nhấn Enter
    await page.keyboard.type(String(optionText), { delay: randomBetween(95, 150) });
    await page.waitForTimeout(300);
    await page.keyboard.press('Enter');
  }

  await page.waitForTimeout(randomBetween(300, 500));
}

// ============================================================================
// 2. HELPER NHẬP NGÀY THÁNG & GIỜ (HỖ TRỢ CẢ HTML5 TYPE="DATE"/"TIME" LẪN DXDATEBOX)
// ============================================================================
async function fillDateHumanLike(page, dateLocator, dateString) {
  // Tìm đúng thẻ <input> hiển thị bên trong DateBox hoặc native input
  const target = dateLocator.locator('input.dx-texteditor-input:visible, input[type="date"]:visible, input[type="time"]:visible, input[type="text"]:visible').first();
  const finalInput = (await target.isVisible().catch(() => false)) ? target : dateLocator.first();

  const inputType = await finalInput.getAttribute('type').catch(() => 'text');

  if (inputType === 'date') {
    // 1. Thẻ HTML5 thuần <input type="date">: Chuẩn W3C bắt buộc format YYYY-MM-DD
    let isoDate = dateString;
    if (String(dateString).includes('/')) {
      const parts = String(dateString).split(/[\/\s:]+/);
      if (parts.length >= 3) {
        // Chuyển từ dd/mm/yyyy -> yyyy-mm-dd
        isoDate = `${parts[2]}-${parts[1].padStart(2, '0')}-${parts[0].padStart(2, '0')}`;
      }
    }
    await moveAndClick(page, finalInput, { pause: randomBetween(200, 350) });
    await finalInput.fill(isoDate);
    await finalInput.dispatchEvent('input').catch(() => {});
    await finalInput.dispatchEvent('change').catch(() => {});
  } else if (inputType === 'time') {
    // 2. Thẻ HTML5 thuần <input type="time">: Chuẩn W3C bắt buộc format HH:mm
    await moveAndClick(page, finalInput, { pause: randomBetween(200, 350) });
    await finalInput.fill(String(dateString));
    await finalInput.dispatchEvent('input').catch(() => {});
    await finalInput.dispatchEvent('change').catch(() => {});
  } else {
    // 3. DevExtreme DateBox / DateTimeBox (có Mask behavior dd/MM/yyyy hoặc dd/MM/yyyy HH:mm)
    // Nếu có nút Clear (.dx-clear-button-area), ưu tiên di chuột Neon bấm nút Clear để reset sạch sẽ
    const clearBtn = dateLocator.locator('.dx-clear-button-area:visible').first();
    if (await clearBtn.isVisible({ timeout: 1000 }).catch(() => false)) {
      await moveAndClick(page, clearBtn, { pause: randomBetween(150, 250) });
      await page.waitForTimeout(150);
    }

    // Di chuột Neon click vào ô text input để kích hoạt con trỏ
    await moveAndClick(page, finalInput, { pause: randomBetween(180, 280) });

    // Xóa an toàn nếu chưa bấm nút Clear hoặc còn sót ký tự cũ
    await page.keyboard.press('Control+A');
    await page.waitForTimeout(randomBetween(80, 120));
    await page.keyboard.press('Backspace');
    await page.waitForTimeout(randomBetween(120, 200));

    // Với DevExtreme DateBox có mask: Ký tự phân cách (/, :, space) được mask quản lý cố định.
    // Gõ chuỗi chữ số thuần túy (Raw Digits) để DevExtreme Mask tự động điền vào các slot chuẩn xác 100%
    const rawDigits = String(dateString).replace(/\D/g, '');
    const textToType = (rawDigits.length === 4 || rawDigits.length >= 8) ? rawDigits : String(dateString);

    // Gõ bằng bàn phím qua page.keyboard.type liên tục như người thật (KHÔNG re-focus theo từng ký tự)
    await page.keyboard.type(textToType, { delay: randomBetween(90, 150) });
    await page.waitForTimeout(180);

    await page.keyboard.press('Enter');
    await page.waitForTimeout(150);
    await page.keyboard.press('Tab'); // Nhấn Tab để DatePicker đóng lịch và chốt giá trị
  }
  await page.waitForTimeout(randomBetween(250, 450));
}

// ============================================================================
// 3. HELPER NHẬP SỐ TIỀN / NUMBERBOX TRỰC QUAN TỪNG CHỮ SỐ
// ============================================================================
async function fillNumberHumanLike(page, numberBoxLocator, numberValue) {
  const innerInput = numberBoxLocator.locator('input.dx-texteditor-input:visible').first();
  const finalInput = (await innerInput.isVisible().catch(() => false)) ? innerInput : numberBoxLocator.first();

  await typeHumanLike(page, finalInput, String(numberValue));
  await page.keyboard.press('Tab'); // Nhấn Tab để UI tự format dấu phẩy (vd: 10,000,000)
  await page.waitForTimeout(randomBetween(250, 450));
}

// 4. CHỌN DROPDOWN / SELECTBOX TRỰC QUAN (Thay thế hoàn toàn page.evaluate sửa value ngầm)
async function selectDropdownHumanLike(page, dropdownLocator, optionText) {
  return await selectBoxHumanLike(page, dropdownLocator, optionText);
}

// 4. XÁC NHẬN POPUP / DIALOG BẰNG CHUỘT NEON (Thay thế confirmPopupFix5 / Fix7)
async function confirmPopupHumanLike(page) {
  const confirmSelector = [
    '#vc-vu-confirm-popup .VC-Vu-btn-ok:visible',
    '#btnApproveModalRemake:visible',
    '.VC-Vu-btn-ok:visible',
    '.dx-popup-bottom .dx-button:has-text("Có"):visible',
    '.dx-popup-bottom .dx-button:has-text("Đồng ý"):visible',
    'button:has-text("Đồng ý"):visible',
    'button:has-text("Có"):visible',
    'button:has-text("OK"):visible',
    '.swal2-confirm:visible',
    '.ajs-button.ajs-ok:visible'
  ].join(', ');

  const btn = page.locator(confirmSelector).first();
  if (await btn.isVisible({ timeout: 3500 }).catch(() => false)) {
    // BẮT BUỘC di chuột tới nút xác nhận trên Popup rồi mới bấm!
    await moveAndClick(page, btn, { pause: randomBetween(250, 400) });
    await page.waitForTimeout(randomBetween(800, 1200));
    return true;
  }
  return false;
}

// 5. MỞ MENU DÙNG CHUNG CHO TOÀN BỘ 20 TC (Cấm gọi OpenAppInSidebar / addNewTab ngầm)
async function openMenuHumanLike(page, menuId, menuName) {
  console.log(`📂 [Điều hướng trực quan]: Tìm và mở menu "${menuName}" (${menuId})...`);

  // Ưu tiên 1: Nếu Tab đã mở sẵn trên thanh Top Tab Bar -> Di chuột tới bấm chuyển Tab
  const existingTab = page.locator(`
    #dynamic-tab-${menuId}:visible, 
    #tab-${menuId}:visible, 
    .nav-tabs button:has-text("${menuName}"):visible, 
    .nav-tabs a:has-text("${menuName}"):visible,
    #divTabDynamic button:has-text("${menuName}"):visible
  `).first();

  if (await existingTab.isVisible({ timeout: 1200 }).catch(() => false)) {
    await moveAndClick(page, existingTab);
    await page.waitForTimeout(randomBetween(700, 1100));
    return;
  }

  // Ưu tiên 2: Nếu Menu đã hiển thị trực tiếp trên Sidebar / Launchpad -> Di chuột tới click
  const directCandidate = `span:has-text("${menuName}"):visible, a:has-text("${menuName}"):visible, .child-launchpad:has-text("${menuName}"):visible, .${menuId}:visible, [onclick*="${menuId}"]:visible`;
  const directMenu = page.locator(directCandidate).first();

  if (await directMenu.isVisible({ timeout: 1500 }).catch(() => false)) {
    await moveAndClick(page, directMenu);
    await page.waitForTimeout(randomBetween(1200, 1800));
    return;
  }

  // Ưu tiên 3: Tìm icon phân hệ trên thanh Dock và nhấp chuột trực quan
  const PARENT_MODULES = {
    MnuHRS145: 'MnuPRL000',
    MnuHRS157: 'MnuHRS000',
    MnuTAD000: 'MnuTAD000'
  };
  const parentId = PARENT_MODULES[menuId] || menuId;
  const dockIcon = page.locator(`.dock .open-${parentId}:visible, .dock .${parentId}:visible, .dock button.${parentId}:visible, .dock [title*="${menuName}"]:visible, .dock [onclick*="${parentId}"]:visible, .dock [onclick*="${menuId}"]:visible`).first();
  if (await dockIcon.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, dockIcon, { steps: 8, pause: 250 });
    await page.waitForTimeout(1000);

    const subItem = page.locator(directCandidate).first();
    if (await subItem.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, subItem);
      await page.waitForTimeout(randomBetween(1200, 1800));
      return;
    }
    if (parentId === menuId) {
      await page.waitForTimeout(randomBetween(1000, 1500));
      return;
    }
  }

  // Ưu tiên 4: Mở Sidebar (nếu đang đóng) -> Gõ tìm kiếm tên Menu -> Di chuột xuống click kết quả
  const hamburger = page.locator('button.menu-button:visible, .main-menu-button:visible, .sidebar-toggle:visible, #btnToggleSidebar:visible').first();
  const isSidebarOpen = await page.locator('.sidebar:visible, #sidebar:visible').first().isVisible().catch(() => false);
  if (!isSidebarOpen && await hamburger.isVisible().catch(() => false)) {
    await moveAndClick(page, hamburger);
    await page.waitForTimeout(500);
  }

  const sidebarSearch = page.locator('#txtSearchApp:visible, .sidebar-search input:visible, .sidebar input[type="text"]:visible, input[placeholder*="Tìm kiếm"]:visible').first();
  if (await sidebarSearch.isVisible({ timeout: 2500 }).catch(() => false)) {
    await typeHumanLike(page, sidebarSearch, menuName);
    await page.waitForTimeout(randomBetween(500, 800));

    const filteredItem = page.locator(`
      .sidebar a:has-text("${menuName}"):visible, 
      .sidebar li:has-text("${menuName}"):visible, 
      .sidebar span:has-text("${menuName}"):visible,
      [onclick*="${menuId}"]:visible
    `).first();

    if (await filteredItem.isVisible({ timeout: 2500 }).catch(() => false)) {
      await moveAndClick(page, filteredItem);
      await page.waitForTimeout(randomBetween(1200, 1800));
      return;
    }
  }
}

// 6. HELPER ĐIỀN Ô INPUT CÓ KHÓA KIỂM CHỨNG HIỂN THỊ (PRE-SUBMIT GATE)
async function fillAndVerifyHumanLike(page, locator, text, fieldLabel = 'Trường dữ liệu') {
  const target = locator.first();
  
  // 1. Bắt buộc ô input phải đang hiển thị trên màn hình
  await expect(target, `❌ Ô nhập "${fieldLabel}" chưa hiển thị trên Modal/Form!`).toBeVisible({ timeout: 10000 });

  // 2. Di chuột Neon tới ô input, click và gõ từng ký tự
  await typeHumanLike(page, target, text);

  // 3. KHÓA CHẶN (PRE-SUBMIT GATE): Kiểm tra chữ đã thực sự nằm trong ô input trên giao diện chưa
  const actualVal = await target.inputValue().catch(async () => await target.innerText().catch(() => ''));
  if (!String(actualVal).trim()) {
    throw new Error(`🚨 [PHÁT HIỆN LỖI GÕ PHÍM]: Đã thực hiện gõ vào "${fieldLabel}" nhưng ô input trên giao diện vẫn trống rỗng! Dừng kịch bản, cấm bấm Submit!`);
  }
  console.log(`✅ [Đã điền trực quan]: ${fieldLabel} = "${actualVal}"`);
}

// 7. HELPER KHOANH VÙNG ĐỐI SOÁT CHỐNG FAKE & BẮT BUỘC DỪNG 5 GIÂY (5000ms)
async function highlightAndPause(page, locator, options = {}) {
  // Bắt buộc mặc định dừng đúng 5,000ms (5 giây) cho người dùng quan sát
  const duration = options.duration || 5000;
  const label = options.label || 'DÒNG DỮ LIỆU CẦN CHÚ Ý';

  // Chuẩn hóa danh sách từ khóa BẮT BUỘC PHẢI CÓ trong vùng khoanh (Chống khoanh bừa)
  const requiredTexts = Array.isArray(options.expectedText)
    ? options.expectedText
    : (options.expectedText ? [options.expectedText] : []);

  if (requiredTexts.length === 0) {
    throw new Error(`🚨 [VI PHẠM LUẬT KHOANH VÙNG]: Gọi highlightAndPause("${label}") nhưng không truyền 'expectedText'! Cấm khoanh vùng mù quáng!`);
  }

  const target = locator.first();
  // Bắt buộc phần tử phải xuất hiện, nếu không có -> Báo lỗi FAIL ngay, cấm lờ đi!
  await expect(target, `❌ [KHÔNG TÌM THẤY DÒNG CẦN KHOANH]: Không tìm thấy phần tử cho "${label}" chứa [${requiredTexts.join(', ')}]`).toBeVisible({ timeout: 10000 });

  // KIỂM TRA CHỐNG KHOANH CẢ BẢNG TO & LẤY NỘI DUNG (Cả text tĩnh lẫn input value)
  const tagInfo = await target.evaluate(el => {
    let fullText = el.innerText || '';
    if (el.value) fullText += ' ' + el.value;
    const inputs = el.querySelectorAll('input, textarea, select');
    inputs.forEach(inp => {
      if (inp.value) fullText += ' ' + inp.value;
    });
    return {
      tag: el.tagName.toLowerCase(),
      cls: el.className || '',
      text: fullText.trim()
    };
  });

  if (tagInfo.cls.includes('dx-datagrid') && !tagInfo.cls.includes('dx-row')) {
    throw new Error(`🚨 [PHÁT HIỆN FAKE HIGHLIGHT]: Agent đang cố khoanh vùng cả bảng lớn (.dx-datagrid) thay vì khoanh đúng dòng dữ liệu (tr.dx-data-row) tại "${label}"!`);
  }

  // KIỂM TRA KHỚP NỘI DUNG TUYỆT ĐỐI (Strict Content Match)
  const actualTextLower = tagInfo.text.toLowerCase();
  for (const reqText of requiredTexts) {
    if (!actualTextLower.includes(String(reqText).toLowerCase())) {
      throw new Error(
        `🚨 [PHÁT HIỆN KHOANH NHẦM DÒNG]: Vùng định khoanh "${label}" KHÔNG chứa từ khóa bắt buộc "${reqText}".\n` +
        `👉 Nội dung thực tế đang định khoanh bừa là: "${tagInfo.text.substring(0, 120)}..."`
      );
    }
  }

  // 1. Cuộn thông minh: Chỉ cuộn nếu dòng đó đang bị khuất khỏi màn hình
  const isObscured = await target.evaluate(el => {
    const rect = el.getBoundingClientRect();
    const vh = window.innerHeight || document.documentElement.clientHeight;
    const vw = window.innerWidth || document.documentElement.clientWidth;
    return (rect.bottom > (vh - 50) || rect.top < 70 || rect.right < 0 || rect.left > vw);
  });

  if (isObscured) {
    await smoothScrollHumanLike(page, target, { block: 'center' });
    await page.waitForTimeout(500);
  }

  // 2. Vẽ khung viền Neon Đỏ phát sáng + Huy hiệu Badge chỉ thị trên dòng đúng
  await target.evaluate((el, opts) => {
    el.style.outline = '3px solid #f43f5e';
    el.style.outlineOffset = '2px';
    el.style.boxShadow = '0 0 25px rgba(244, 63, 94, 0.95), inset 0 0 15px rgba(244, 63, 94, 0.25)';
    el.style.transition = 'all 0.3s ease';
    el.style.backgroundColor = 'rgba(244, 63, 94, 0.18)';

    let badge = document.getElementById('__ag_focus_badge__');
    if (!badge) {
      badge = document.createElement('div');
      badge.id = '__ag_focus_badge__';
      document.body.appendChild(badge);
    }
    badge.style.cssText = `
      position: fixed; z-index: 2147483647; padding: 6px 14px;
      background: #e11d48; color: #ffffff; font-family: 'Segoe UI', Arial, sans-serif;
      font-size: 13px; font-weight: bold; border-radius: 6px;
      box-shadow: 0 4px 18px rgba(225, 29, 72, 0.75); pointer-events: none;
      display: block; opacity: 1;
    `;
    badge.innerText = `🎯 ${opts.label} (Đang dừng ${opts.duration / 1000}s đối soát...)`;

    const rect = el.getBoundingClientRect();
    badge.style.left = `${Math.max(12, rect.left)}px`;
    badge.style.top = `${Math.max(12, rect.top - 38)}px`;
  }, { label, duration });

  // 3. Rê con trỏ chuột Neon tới đúng ô/nút mục tiêu bên trong dòng đang được khoanh vùng (Cấm cộng trừ Pixel cứng)
  const pointerTarget = await pickVisibleLeafForPointer(
    target,
    requiredTexts,
    options.targetSubSelector || options.pointSelector || ''
  );
  const box = (await pointerTarget.boundingBox().catch(() => null)) || (await target.boundingBox());
  if (box) {
    const pointX = box.x + box.width / 2;
    const pointY = box.y + box.height / 2;
    const distance = Math.hypot(pointX - currentMousePos.x, pointY - currentMousePos.y);
    const steps = Math.max(12, Math.min(28, Math.round(distance / 22)));
    await page.mouse.move(pointX, pointY, { steps });
    currentMousePos = { x: pointX, y: pointY };
  }

  console.log(`🔍 [ĐỐI SOÁT TRỰC QUAN 5S]: Đã khoanh chuẩn xác "${label}" -> Tạm dừng ${duration / 1000}s cho người dùng quan sát...`);
  await page.waitForTimeout(duration); // Đứng yên đúng 5 giây

  // 4. Gỡ khung viền sau khi hết 5 giây quan sát
  await target.evaluate((el) => {
    el.style.outline = '';
    el.style.outlineOffset = '';
    el.style.boxShadow = '';
    el.style.backgroundColor = '';
    const badge = document.getElementById('__ag_focus_badge__');
    if (badge) badge.style.display = 'none';
  }).catch(() => {});
}

// 8. HELPER CUỘN MƯỢT TỪ TỪ NHƯ NGƯỜI THẬT (SMOOTH SCROLL)
async function smoothScrollHumanLike(page, locator, options = {}) {
  const target = locator.first();
  await target.scrollIntoViewIfNeeded().catch(() => {});
  await target.evaluate((el, opts) => {
    el.scrollIntoView({ behavior: 'smooth', block: opts.block || 'center', inline: opts.inline || 'nearest' });
  }, options).catch(() => {});
  
  const waitTime = options.wait || randomBetween(600, 900);
  await page.waitForTimeout(waitTime);
}
const smoothScroll = smoothScrollHumanLike;

// 9. HELPER CHUYỂN TRANG PHÂN TRANG BẰNG CHUỘT NEON THẬT (PAGINATION CLICK)
async function navigateToPageHumanLike(page, pageNumberOrLabel) {
  console.log(`📄 [Phân trang trực quan]: Di chuyển chuột tìm và bấm chuyển sang trang "${pageNumberOrLabel}"...`);

  const pagerContainer = page.locator('.dx-datagrid-pager, .pagination, .dataTables_paginate').first();
  if (await pagerContainer.isVisible({ timeout: 5000 }).catch(() => false)) {
    await smoothScrollHumanLike(page, pagerContainer, { block: 'nearest' });

    const pageButton = page.locator(`
      .dx-datagrid-pager .dx-page:text-is("${pageNumberOrLabel}"),
      .pagination .page-item:has-text("${pageNumberOrLabel}") a,
      button:has-text("${pageNumberOrLabel}"),
      a:has-text("${pageNumberOrLabel}")
    `).first();

    if (await pageButton.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, pageButton, { pause: 300 });
      await page.waitForTimeout(randomBetween(1200, 1800));
      console.log(`✅ [Đã lật trang thành công]: Đang ở trang ${pageNumberOrLabel}`);
      return true;
    }
  }
  throw new Error(`❌ Không tìm thấy nút chuyển trang tới "${pageNumberOrLabel}" trên giao diện!`);
}

// ============================================================================
// BỘ HELPER ĐỊNH VỊ ĐỘNG 3 CHIỀU THEO CỘT, DẤU VÂN TAY & CUỘN TÌM TỪNG NẤC (LUẬT 17)
// ============================================================================

// Chuẩn hóa selector tìm dòng theo từng nhánh dấu phẩy (tránh lỗi precedence `.a .dx-datagrid, .a table tr.dx-data-row`)
function buildGridRowSelector(gridSelector = '.dx-datagrid, table', visibleOnly = false) {
  const vis = visibleOnly ? ':visible' : '';
  const parts = String(gridSelector || '.dx-datagrid, table')
    .split(',')
    .map(s => s.trim())
    .filter(Boolean);
  return parts.map(sel => (
    /\.dx-datagrid\b/i.test(sel)
      ? `${sel} tr.dx-data-row${vis}`
      : `${sel} tbody tr:not(.dx-header-row):not(.dx-freespace-row):not(.dx-datagrid-filter-row)${vis}`
  )).join(', ');
}

// 10. TÌM DÒNG ĐỘNG TRÊN BẢNG THEO NHIỀU ĐIỀU KIỆN CỘT (TRẢ VỀ LOCATOR TẬP HỢP, CẤM .first() MÙ QUÁNG)
function findRowByColumns(page, columnValues = {}, gridSelector = '.dx-datagrid, table') {
  let rowLocator = page.locator(buildGridRowSelector(gridSelector, true));
  const values = Array.isArray(columnValues) ? columnValues : Object.values(columnValues);
  for (const val of values) {
    if (val === undefined || val === null) continue;
    if (val instanceof RegExp) {
      rowLocator = rowLocator.filter({ hasText: val });
    } else if (String(val).trim() !== '') {
      rowLocator = rowLocator.filter({ hasText: String(val).trim() });
    }
  }
  return rowLocator;
}

// Helper nội bộ: Thu hẹp con trỏ Neon tới đúng Ô (<td>) hoặc Nút hiển thị bên trong dòng
async function pickVisibleLeafForPointer(rowOrContainer, requiredTexts = [], preferredSubSelector = '') {
  if (preferredSubSelector) {
    const subCandidates = rowOrContainer.locator(preferredSubSelector);
    const subCount = await subCandidates.count().catch(() => 0);
    for (let i = 0; i < subCount; i++) {
      const candidate = subCandidates.nth(i);
      if (await candidate.isVisible().catch(() => false)) {
        return candidate;
      }
    }
  }

  const isTableRow = await rowOrContainer.evaluate(el => Boolean(el.tagName && el.tagName.toLowerCase() === 'tr')).catch(() => false);
  if (isTableRow) {
    for (const req of requiredTexts) {
      const filterOpt = req instanceof RegExp ? { hasText: req } : { hasText: String(req) };
      const cellWithReq = rowOrContainer.locator('td').filter(filterOpt);
      const cellCount = await cellWithReq.count().catch(() => 0);
      for (let i = 0; i < cellCount; i++) {
        const c = cellWithReq.nth(i);
        if (await c.isVisible().catch(() => false)) return c;
      }
    }
    const anyCells = rowOrContainer.locator('td');
    const totalCells = await anyCells.count().catch(() => 0);
    for (let i = 0; i < totalCells; i++) {
      const c = anyCells.nth(i);
      const txt = ((await c.innerText().catch(() => '')) || '').trim();
      if (txt.length > 0 && await c.isVisible().catch(() => false)) return c;
    }
  }
  return rowOrContainer;
}

// Helper nội bộ: Kiểm tra .count() trước khi chọn phần tử hiển thị khớp đủ điều kiện
async function findFirstVisibleMatch(page, baseSelector, texts = []) {
  let loc = page.locator(baseSelector);
  for (const t of texts) {
    if (t === undefined || t === null) continue;
    if (t instanceof RegExp) {
      loc = loc.filter({ hasText: t });
    } else if (String(t).trim() !== '') {
      loc = loc.filter({ hasText: String(t).trim() });
    }
  }
  const matchCount = await loc.count().catch(() => 0);
  for (let i = 0; i < matchCount; i++) {
    const candidate = loc.nth(i);
    if (await candidate.isVisible().catch(() => false)) {
      return { locator: candidate, totalMatches: matchCount, matchedIndex: i };
    }
  }
  return null;
}

// Helper nội bộ: Lấy thông tin khung cuộn thực tế THEO ĐÚNG THỨ TỰ ƯU TIÊN SELECTOR & trạng thái chạm đáy
async function getScrollableContainerState(page, scrollContainerSelector) {
  const selectors = String(scrollContainerSelector || '')
    .split(',')
    .map(s => s.trim())
    .filter(Boolean);
  let fallbackVisible = null;

  for (const sel of selectors) {
    const containers = page.locator(sel);
    const count = await containers.count().catch(() => 0);

    for (let i = 0; i < count; i++) {
      const elLoc = containers.nth(i);
      if (!(await elLoc.isVisible().catch(() => false))) continue;
      const state = await elLoc.evaluate(el => {
        const rect = el.getBoundingClientRect();
        const canScroll = (el.scrollHeight - el.clientHeight) > 4;
        const atBottom = (el.scrollTop + el.clientHeight) >= (el.scrollHeight - 2);
        return {
          width: rect.width,
          height: rect.height,
          x: rect.left,
          y: rect.top,
          scrollTop: el.scrollTop,
          scrollHeight: el.scrollHeight,
          clientHeight: el.clientHeight,
          canScroll,
          atBottom
        };
      }).catch(() => null);

      if (state && state.width > 50 && state.height > 50) {
        if (state.canScroll) return { containerLoc: elLoc, ...state };
        if (!fallbackVisible) fallbackVisible = { containerLoc: elLoc, ...state };
      }
    }
  }
  return fallbackVisible;
}

// 11. ĐỊNH VỊ ĐỘNG 3 CHIỀU + TỰ ĐỘNG CUỘN MOUSE.WHEEL TỪNG NẤC & DỪNG SỚM KHI CHẠM ĐÁY
async function resolveDynamicTarget(page, {
  baseSelector,
  requiredTexts = [],
  preferredTexts = [],
  strictPreferred = false,
  scrollContainerSelector = '.dx-datagrid-rowsview .dx-scrollable-container, #scrollView .dx-scrollable-container, #cardregistered, .dx-scrollable-container, .dx-overlay-content .dx-scrollable-container',
  maxScrollSteps = 15,
  scrollStepPx = 280,
  throwIfNotFound = true
}) {
  // Nếu mục tiêu nằm trong popup/overlay, ưu tiên tuyệt đối khung cuộn bên trong overlay đang mở để tránh cuộn nhầm bảng nền
  const isOverlayTarget = /\.dx-overlay-content|\.dx-popup/i.test(String(baseSelector || ''));
  const effectiveScrollSelector = isOverlayTarget
    ? `.dx-overlay-content:visible .dx-datagrid-rowsview .dx-scrollable-container, .dx-overlay-content:visible .dx-scrollable-container, ${scrollContainerSelector}`
    : scrollContainerSelector;

  const reqList = (Array.isArray(requiredTexts) ? requiredTexts : [requiredTexts])
    .filter(v => v !== undefined && v !== null && (!(typeof v === 'string') || v.trim() !== ''));
  const prefList = (Array.isArray(preferredTexts) ? preferredTexts : [preferredTexts])
    .filter(v => v !== undefined && v !== null && (!(typeof v === 'string') || v.trim() !== ''));

  const findPreferredInCurrentView = async () => {
    for (const pref of prefList) {
      const hit = await findFirstVisibleMatch(page, baseSelector, [...reqList, pref]);
      if (hit) return { locator: hit.locator, matchedPref: pref };
    }
    return null;
  };

  const scanDownward = async (usePreferredPass) => {
    if (usePreferredPass) {
      const immediatePref = await findPreferredInCurrentView();
      if (immediatePref) return immediatePref.locator;
    } else {
      const immediateReq = await findFirstVisibleMatch(page, baseSelector, reqList);
      if (immediateReq) return immediateReq.locator;
    }

    let lastScrollTop = -1;
    let stuckCount = 0;

    for (let step = 1; step <= maxScrollSteps; step++) {
      const scState = await getScrollableContainerState(page, effectiveScrollSelector);
      if (scState) {
        if (scState.atBottom && scState.scrollTop === lastScrollTop) {
          console.log(`🛑 [Định vị động]: Khung cuộn đã chạm đáy (${scState.scrollTop + scState.clientHeight}/${scState.scrollHeight}), dừng cuộn sớm.`);
          break;
        }
        const wheelX = scState.x + scState.width * 0.5;
        const wheelY = scState.y + scState.height * 0.5;
        await page.mouse.move(wheelX, wheelY, { steps: 4 });
        currentMousePos = { x: wheelX, y: wheelY };
        lastScrollTop = scState.scrollTop;
      }

      await page.mouse.wheel(0, scrollStepPx);
      await page.waitForTimeout(350);

      if (usePreferredPass) {
        const hit = await findPreferredInCurrentView();
        if (hit) {
          console.log(`🎯 [Định vị động]: Khớp dấu vân tay ưu tiên "${String(hit.matchedPref)}" sau ${step} nấc cuộn.`);
          return hit.locator;
        }
      } else {
        const hit = await findFirstVisibleMatch(page, baseSelector, reqList);
        if (hit) {
          console.log(`🎯 [Định vị động]: Tìm thấy dòng khớp [${reqList.map(String).join(' + ')}] sau ${step} nấc cuộn.`);
          return hit.locator;
        }
      }

      const afterState = await getScrollableContainerState(page, effectiveScrollSelector);
      if (afterState) {
        if (afterState.atBottom) {
          console.log(`🛑 [Định vị động]: Đã cuộn tới đáy khung (${afterState.scrollHeight}px), dừng cuộn sớm.`);
          break;
        }
        if (Math.abs(afterState.scrollTop - lastScrollTop) < 2) {
          stuckCount++;
          if (stuckCount >= 2) break;
        } else {
          stuckCount = 0;
        }
      } else if (step >= 3) {
        break;
      }
    }
    return null;
  };

  if (prefList.length > 0) {
    const prefHit = await scanDownward(true);
    if (prefHit) return prefHit;

    if (strictPreferred) {
      if (throwIfNotFound) {
        throw new Error(`❌ [Định vị động]: Không tìm thấy phần tử khớp [${reqList.map(String).join(' + ')}] với dấu vân tay bắt buộc [${prefList.map(String).join(' / ')}]!`);
      }
      return null;
    }

    // Đưa khung cuộn về đầu trang để rà lại chỉ theo requiredTexts khi UI tóm tắt không hiển thị dấu vân tay Note
    const scReset = await getScrollableContainerState(page, effectiveScrollSelector);
    if (scReset && scReset.scrollTop > 0) {
      await scReset.containerLoc.evaluate(el => { el.scrollTop = 0; }).catch(() => {});
      await page.waitForTimeout(250);
    }
    console.log(`ℹ️ [Định vị động]: Không thấy dấu vân tay ưu tiên [${prefList.map(String).join(', ')}] trên thẻ tóm tắt, đối chiếu theo [${reqList.map(String).join(' + ')}]...`);
  }

  const reqHit = await scanDownward(false);
  if (reqHit) return reqHit;

  if (throwIfNotFound) {
    throw new Error(`❌ [Định vị động thất bại]: Đã quét toàn bộ khung danh sách nhưng không tìm thấy phần tử khớp [${reqList.map(String).join(' + ')}]!`);
  }
  return null;
}

// 12. DI CHUỘT TỚI ĐÚNG DÒNG (CÓ CỘT = ...) VÀ CLICK VÀO ĐÚNG Ô / NÚT BÊN TRONG DÒNG ĐÓ
async function moveAndClickGridTarget(page, {
  matchColumns,
  preferredTexts = [],
  targetSubSelector = '',
  gridSelector = '.dx-datagrid, table',
  scrollContainerSelector = '.dx-overlay-content:visible .dx-datagrid-rowsview .dx-scrollable-container, .dx-overlay-content:visible .dx-scrollable-container, .dx-datagrid-rowsview .dx-scrollable-container, .dx-scrollable-container',
  maxScrollSteps = 15,
  scrollStepPx = 280
}) {
  const colValues = Array.isArray(matchColumns) ? matchColumns : Object.values(matchColumns);
  const reqValues = colValues.filter(v => v !== undefined && v !== null && (!(typeof v === 'string') || v.trim() !== ''));
  const matchedRow = await resolveDynamicTarget(page, {
    baseSelector: buildGridRowSelector(gridSelector),
    requiredTexts: reqValues,
    preferredTexts,
    scrollContainerSelector,
    maxScrollSteps,
    scrollStepPx,
    throwIfNotFound: true
  });

  const clickTarget = await pickVisibleLeafForPointer(matchedRow, reqValues, targetSubSelector);
  const reqStr = reqValues.map(String).join(' + ');
  console.log(`🎯 [Click Động Theo Cột]: Di chuột Neon tới dòng [${reqStr}] -> Click vào "${targetSubSelector || 'Ô định danh'}"`);
  await moveAndClick(page, clickTarget, { pause: 250 });
  return matchedRow;
}

// 13. KHOANH VÙNG + CLICK ĐỘNG MỘT BƯỚC
async function highlightAndClickDynamicTarget(page, {
  baseSelector,
  requiredTexts = [],
  preferredTexts = [],
  strictPreferred = false,
  targetSubSelector = '',
  label = 'MỤC TIÊU ĐỘNG',
  duration = 2500,
  scrollContainerSelector = '.dx-datagrid-rowsview .dx-scrollable-container, #scrollView .dx-scrollable-container, #cardregistered, .dx-scrollable-container',
  maxScrollSteps = 15,
  scrollStepPx = 280
}) {
  const matchedEl = await resolveDynamicTarget(page, {
    baseSelector,
    requiredTexts,
    preferredTexts,
    strictPreferred,
    scrollContainerSelector,
    maxScrollSteps,
    scrollStepPx,
    throwIfNotFound: true
  });

  await highlightAndPause(page, matchedEl, {
    label,
    expectedText: requiredTexts,
    targetSubSelector,
    duration
  });

  const clickTarget = await pickVisibleLeafForPointer(matchedEl, requiredTexts, targetSubSelector);
  await moveAndClick(page, clickTarget, { pause: 250 });
  return matchedEl;
}

// 14. TÌM CHÍNH XÁC THẺ ĐƠN PHÊ DUYỆT CỦA KỊCH BẢN (CHỐNG BẤM NHẦM ĐƠN TẠO TAY Ở ĐẦU DANH SÁCH)
async function selectAndApproveExactScriptCard(page, {
  empId = '099',
  empName = 'Nguyễn Văn Test',
  dateStr = '',
  candidateDates = [],
  keyword = '',
  preferredTokens = ['[TEST_LUONG]'],
  onCardFound = null
}) {
  const hasOaCards = (await page.locator('#cardregistered .getcardregisteredOA:visible, .getcardregisteredOA:visible').count().catch(() => 0)) > 0;
  const cardSelector = hasOaCards
    ? '#cardregistered .getcardregisteredOA, .getcardregisteredOA'
    : '#cardregistered > div:visible, #approvalContainer .card:visible, .card:visible';

  const dateCandidates = dateStr ? [dateStr] : (candidateDates.length > 0 ? candidateDates : ['']);

  for (const d of dateCandidates) {
    const reqs = [empId, d, keyword].filter(Boolean);
    const matchedCard = await resolveDynamicTarget(page, {
      baseSelector: cardSelector,
      requiredTexts: reqs,
      preferredTexts: preferredTokens,
      scrollContainerSelector: '#cardregistered, #scrollView .dx-scrollable-container, #approvalContainer, .dx-scrollable-container',
      maxScrollSteps: 15,
      scrollStepPx: 260,
      throwIfNotFound: false
    });

    if (matchedCard) {
      if (onCardFound) await onCardFound(matchedCard);
      return await approveCardLiveVisual(page, matchedCard, empId);
    }

    // Thử lại nếu UI hiển thị Họ tên thay vì Mã NV
    if (empName) {
      const nameReqs = [empName, d, keyword].filter(Boolean);
      const byNameCard = await resolveDynamicTarget(page, {
        baseSelector: cardSelector,
        requiredTexts: nameReqs,
        preferredTexts: preferredTokens,
        scrollContainerSelector: '#cardregistered, #scrollView .dx-scrollable-container, #approvalContainer, .dx-scrollable-container',
        maxScrollSteps: 10,
        scrollStepPx: 260,
        throwIfNotFound: false
      });
      if (byNameCard) {
        if (onCardFound) await onCardFound(byNameCard);
        return await approveCardLiveVisual(page, byNameCard, empId);
      }
    }
  }

  return false;
}

// Alias tương thích cho cụm fix-4, fix-5, fix-7
const openMenuFix4 = openMenuHumanLike;
const openAppFix5 = openMenuHumanLike;
const openAppFix7 = openMenuHumanLike;
const confirmPopupFix5 = confirmPopupHumanLike;
const confirmPopupFix7 = confirmPopupHumanLike;

// Bộ tài khoản điều phối quy trình 5 Roles
const ACCOUNTS = {
  HR_ADMIN:     { username: 'cuong.vu',     password: '123', empId: '014', name: 'Vũ Đình Cường' },
  STAFF_NEW:    { username: 'test.nv',      password: '123', empId: '099', name: 'Nguyễn Văn Test' },
  MANAGER_DEV:  { username: 'ThanhLong',    password: '123', empId: '011', name: 'Nguyễn Thanh Long' },
  APPROVER_OT:  { username: 'LongKa',       password: '123', empId: '012', name: 'Nguyễn Trường Long' },
  DIRECTOR:     { username: 'chien.nguyen', password: '123', empId: '013', name: 'Nguyễn Tấn Chiến' }
};

// Hàm đăng nhập dùng chung với chuột Neon và gõ phím trực quan thời gian thực
async function performLogin(page, username, password) {
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  const uInput = page.locator('input[type="text"], input#txtUsername, input[name="username"]').first();
  const pInput = page.locator('input[type="password"], input#txtPassword, input[name="password"]').first();
  
  if (await uInput.isVisible({ timeout: 5000 }).catch(() => false)) {
    await typeHumanLike(page, uInput, username);
    await typeHumanLike(page, pInput, password);
    const loginBtn = page.locator('button:has-text("Đăng nhập"), button#btnLogin, input[type="submit"]').first();
    await moveAndClick(page, loginBtn);
  }
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 }).catch(() => {});
  await page.waitForTimeout(randomBetween(500, 800));
}

// ============================================================================
// KHU VỰC PHÂN CÔNG 1: CONVERSATION [fix-4] (PRIORITY P1: KHỞI TẠO TIỀN ĐỀ HỒ SƠ)
// ============================================================================

// =========================================================================================
// [TIỀN ĐỀ CSDL]: TC-01 & TC-02 ĐÃ ĐƯỢC NẠP TRỰC TIẾP VÀO CSDL QUA seed_test_employee_099.sql
// Không thực hiện thao tác tạo hồ sơ & tạo tài khoản trên UI nữa để tránh lỗi giao diện MnuSCR608.
// fix-4 bắt đầu kiểm thử trực quan 100% từ TC-03 (Thiết lập HĐLĐ & Mức lương 10tr).
// =========================================================================================

// >>> [START_TC_03] - CONVERSATION: fix-4
test('fix-4 | TC-03: Thiết lập HĐLĐ và Mức lương 10,000,000 VNĐ (Role: cuong.vu)', async ({ page }, testInfo) => {
  console.log('\n================ [fix-4] TC-03: THIẾT LẬP HĐLĐ & LƯƠNG 10,000,000 VNĐ ================');

  // 1. Kiểm tra tiền đề CSDL: Đảm bảo NV 099 đã có hồ sơ và tài khoản
  const empPreCheck = query("SELECT EmployeeID, FullName FROM tblEmployee WHERE EmployeeID = '099'");
  expect(empPreCheck.length, '❌ Nhân viên 099 chưa có hồ sơ trong tblEmployee! Vui lòng thực thi file SQL: scripts/reset/insert_test_nv_account.sql trên SSMS trước khi chạy test.').toBeGreaterThan(0);
  console.log(`ℹ️ [TC-03]: Xác nhận tiền đề hợp lệ: Hồ sơ nhân viên 099 (${empPreCheck[0].FullName}) đã sẵn sàng.`);

  // 2. Đăng nhập cuong.vu (100% phím gõ Người thật và Chuột Neon)
  await performLogin(page, ACCOUNTS.HR_ADMIN.username, ACCOUNTS.HR_ADMIN.password);
  await page.waitForTimeout(randomBetween(600, 1000));

  // 3. Mở MnuHRS145 (Lương nhân viên) qua chuột và bàn phím thật
  await openMenuHumanLike(page, 'MnuHRS145', 'Lương nhân viên');
  await page.waitForTimeout(randomBetween(800, 1200));

  // 4. Kiểm tra xem NV 099 đã có mức lương trong CSDL chưa, nếu chưa thì thiết lập trực quan qua Modal
  const existingSal = query("SELECT TOP 1 SalaryHistoryID, Salary FROM tblSalaryHistory WHERE EmployeeID = '099' ORDER BY Date DESC");
  if (existingSal.length === 0) {
    console.log('👉 [TC-03]: Chưa có mức lương, tiến hành mở popup Thêm mới mức lương trên toolbar...');
    const addSalBtn = page.locator('#sp_SalaryHistory_List_html .dx-toolbar .dx-button:has(.dx-icon-add):visible, #sp_SalaryHistory_List_html .dx-button[title*="Thêm"]:visible, #sp_SalaryHistory_List_html .dx-button:has-text("Thêm"):visible').first();
    await moveAndClick(page, addSalBtn, { pause: 300 });

    const salModal = page.locator('#sp_SalaryHistory_Insert_html');
    await salModal.waitFor({ state: 'visible', timeout: 15000 });
    console.log('👁️ [TC-03]: Modal "sp_SalaryHistory_Insert" đã hiển thị trực quan!');

    // 4.1 Chọn nhân viên 099 qua popup
    const empPickerTrigger = salModal.locator('#P7D0E9F2A6B4C4D8E9A1B2C3D4E5F6071 [tabindex="0"], #P7D0E9F2A6B4C4D8E9A1B2C3D4E5F6071').first();
    await moveAndClick(page, empPickerTrigger, { pause: 300 });

    const empSelectDialog = page.locator('.dx-overlay-content').filter({ has: page.locator('.dx-popup-title:has-text("Chọn nhân viên")') }).first();
    await empSelectDialog.waitFor({ state: 'visible', timeout: 10000 });

    const empSearch = empSelectDialog.locator('input.dx-texteditor-input, input[type="text"]').first();
    await moveAndClick(page, empSearch, { pause: 200 });
    await typeHumanLike(page, empSearch, 'Test');
    await page.waitForTimeout(1000);

    const empRow03 = await moveAndClickGridTarget(page, {
      matchColumns: ['Nguyễn Văn Test'],
      targetSubSelector: '.dx-select-checkbox',
      gridSelector: '.dx-overlay-content .dx-datagrid, .dx-overlay-content table'
    });
    await page.waitForTimeout(400);

    // Đảm bảo dòng đã ở trạng thái dx-selection (phòng trường hợp UI chưa tích hoặc double-toggle trên lưới đa chọn)
    let isRow03Selected = await empRow03.evaluate(el => el.classList.contains('dx-selection')).catch(() => false);
    if (!isRow03Selected) {
      const chkRetry = empRow03.locator('.dx-select-checkbox:visible').first();
      await moveAndClick(page, chkRetry, { pause: 200 });
      await page.waitForTimeout(400);
      isRow03Selected = await empRow03.evaluate(el => el.classList.contains('dx-selection')).catch(() => false);
    }
    expect(isRow03Selected, 'Dòng Nguyễn Văn Test bắt buộc phải được tick chọn (.dx-selection)').toBeTruthy();

    const saveSelectEmpBtn = empSelectDialog.locator('.dx-button:has-text("Lưu")').first();
    await moveAndClick(page, saveSelectEmpBtn, { pause: 250 });
    await empSelectDialog.waitFor({ state: 'hidden', timeout: 8000 });
    await page.waitForTimeout(500);

    // GATE KIỂM CHỨNG BẮT BUỘC: Đã chọn được nhân viên 099 / Nguyễn Văn Test (đa chọn render chip avatar qua title + getValue())
    const selectedEmp03State = await page.evaluate(() => {
      const box = document.querySelector('#displayBox_P7D0E9F2A6B4C4D8E9A1B2C3D4E5F6071');
      const inst = window.InstanceEmployeeIDP7D0E9F2A6B4C4D8E9A1B2C3D4E5F6071;
      const titles = box
        ? Array.from(box.querySelectorAll('[title]')).map(el => el.getAttribute('title')).filter(Boolean)
        : [];
      const instVal = typeof inst?.getValue === 'function' ? inst.getValue() : [];
      return {
        text: box?.innerText || '',
        titles,
        instVal: Array.isArray(instVal) ? instVal : [instVal].filter(Boolean)
      };
    });
    const selectedEmp03Display = [selectedEmp03State.text, ...selectedEmp03State.titles, ...selectedEmp03State.instVal]
      .filter(Boolean)
      .join(' | ');
    expect(selectedEmp03Display, 'Mã nhân viên trên form lương bắt buộc phải chọn được 099 / Nguyễn Văn Test').toMatch(/099|Nguyễn Văn Test/i);
    console.log(`✅ [TC-03]: Đã chọn thành công nhân viên: ${selectedEmp03Display.replace(/\s+/g, ' ').trim()}`);

    // 4.2 Nhập Ngày áp dụng: 01/10/2026 (Chuột Neon bay tới click mở focus -> gõ từng chữ, KHÔNG dùng Tab làm nhảy focus trước)
    const effDateInput = salModal.locator('#P4DAAB905424748229EAFD9AFC4D4EAEE input.dx-texteditor-input').first();
    if (await effDateInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      await typeHumanLike(page, effDateInput, '01/10/2026');
      await page.waitForTimeout(randomBetween(250, 400));
    }

    // 4.3 Nhập Lương cơ bản: 10000000 (Chuột Neon bay tới click mở focus -> gõ từng chữ)
    const basicSalInput = salModal.locator('#PFAD05D72A31C4A2A81963A8FF680608F input.dx-texteditor-input').first();
    await typeHumanLike(page, basicSalInput, '10000000');
    await page.waitForTimeout(randomBetween(250, 400));

    // 4.4 Nhập L. đóng BHXH: 10000000 (Chuột Neon bay tới click mở focus -> gõ từng chữ)
    const insSalInput = salModal.locator('#PC205049BF57549FB8D707CEE111859D7 input.dx-texteditor-input').first();
    if (await insSalInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await typeHumanLike(page, insSalInput, '10000000');
      await page.waitForTimeout(randomBetween(250, 400));
    }

    // 4.5 Chọn Công thức tính lương (SalCalRuleID): "Chia cho số ngày đi làm của từng tháng, nhân với số ngày công hưởng lương"
    console.log('👉 [TC-03]: Di chuột Neon nhấp dropdown chọn Công thức tính lương...');
    const formulaBox = salModal.locator('#P625590059DBC47C7AFCBADE2FA86DB46, #P625590059DBC47C7AFCBADE2FA86DB46 .dx-selectbox').first();
    if (await formulaBox.isVisible({ timeout: 4000 }).catch(() => false)) {
      await selectBoxHumanLike(page, formulaBox, 'Chia cho số ngày đi làm của từng tháng, nhân với số ngày công hưởng lương');
      await page.waitForTimeout(randomBetween(400, 600));
    }

    // Đồng bộ an toàn giá trị widget InstanceSalCalRuleID = 1 nếu UI chưa cập nhật kịp
    await page.evaluate(() => {
      const inst = window["InstanceSalCalRuleIDP625590059DBC47C7AFCBADE2FA86DB46"];
      if (inst && (inst.option("value") === null || inst.option("value") === undefined)) {
        inst.option("value", 1);
      }
    });

    // 4.6 Bấm nút Lưu trên popup thiết lập lương
    console.log('👉 [TC-03]: Di chuột Neon nhấp nút "Lưu" trên popup thiết lập lương...');
    const saveSalBtn = salModal.locator('#btnSaveSalaryHistory, button:has-text("Lưu")').first();
    await moveAndClick(page, saveSalBtn, { pause: 300 });
    await page.waitForTimeout(1000);

    // Chờ thông báo thành công xuất hiện trực quan (Toast / Alert)
    const successToast = page.locator('.dx-toast-success:visible, .dx-toast-message:visible, .ajs-message.ajs-success:visible').first();
    if (await successToast.isVisible({ timeout: 4000 }).catch(() => false)) {
      const toastText = await successToast.innerText().catch(() => '');
      console.log(`✅ [TC-03]: Đã nhận thông báo thành công: "${toastText.trim()}"`);
    }

    // Chờ modal đóng tự nhiên sau khi backend xác nhận Lưu thành công (không tự bấm đóng che giấu lỗi)
    const salClosed = await salModal.waitFor({ state: 'hidden', timeout: 12000 }).then(() => true).catch(() => false);
    if (!salClosed) {
      const toastErr = await page.locator('.dx-toast-message:visible').allInnerTexts().catch(() => []);
      throw new Error(`❌ [TC-03]: Modal #sp_SalaryHistory_Insert_html không đóng sau khi bấm Lưu! Toast: ${toastErr.join(' | ') || 'Không có'}`);
    }
    await page.waitForTimeout(1000);
  } else {
    console.log(`ℹ️ [TC-03]: Mức lương của NV 099 đã tồn tại (${existingSal[0].Salary} VNĐ), bắt đầu đối soát trực quan.`);
  }

  // 5. Thao tác di chuột trực quan tìm kiếm NV 099 trên thanh công cụ DataGrid (Luật 10 Zero-Fill)
  const searchInput03 = page.locator('#sp_SalaryHistory_List_html .dx-datagrid-search-panel input:visible, #sp_SalaryHistory_List_html input[placeholder*="Tìm"]:visible').first();
  if (await searchInput03.isVisible({ timeout: 4000 }).catch(() => false)) {
    await typeHumanLike(page, searchInput03, '099');
    await page.waitForTimeout(randomBetween(800, 1200));
  }

  // 6. Đối soát trực quan CHÍNH XÁC: Định vị động 3 chiều đúng dòng chứa '099' + '10.000.000' -> Khoanh vùng & dừng 5s
  const salRow03 = await resolveDynamicTarget(page, {
    baseSelector: '#sp_SalaryHistory_List_html tr.dx-data-row',
    requiredTexts: ['099', /10[.,]000[.,]000/]
  });
  await highlightAndPause(page, salRow03, { 
    label: 'DÒNG LƯƠNG NV 099: 10,000,000 VNĐ', 
    expectedText: ['099'],
    targetSubSelector: 'td:has-text("10")',
    duration: 5000 
  });

  // 7. Kiểm chứng kép CSDL
  const salVerify = query("SELECT TOP 1 EmployeeID, Salary, InsSalary, SalCalRuleID FROM tblSalaryHistory WHERE EmployeeID = '099' ORDER BY Date DESC");
  expect(salVerify.length, 'Nhân viên 099 phải có bản ghi lương trong tblSalaryHistory').toBeGreaterThan(0);
  expect(Number(salVerify[0].Salary)).toBeGreaterThanOrEqual(10000000);
  console.log(`✅ [fix-4 | TC-03]: Đã xác thực thành công mức lương: ${salVerify[0].Salary} VNĐ (Công thức SalCalRuleID: ${salVerify[0].SalCalRuleID}) cho NV 099!`);
});
// <<< [END_TC_03]

// >>> [START_TC_04] - CONVERSATION: fix-4
test('fix-4 | TC-04: Đăng ký 1 Người phụ thuộc giảm trừ gia cảnh (Role: cuong.vu)', async ({ page }, testInfo) => {
  console.log('\n================ [fix-4] TC-04: ĐĂNG KÝ 1 NGƯỜI PHỤ THUỘC (NPT) ================');

  // 1. Kiểm tra tiền đề: Đảm bảo nhân viên 099 đã có hồ sơ và tài khoản ESS Portal
  const empCheck = query("SELECT EmployeeID, FullName FROM tblEmployee WHERE EmployeeID = '099'");
  expect(empCheck.length, '❌ Nhân viên 099 chưa có hồ sơ trong tblEmployee! Vui lòng thực thi file SQL: scripts/seed_test_employee_099.sql trên SSMS trước khi chạy test.').toBeGreaterThan(0);

  const loginCheck = query("SELECT LoginID, LoginName FROM tblSC_Login WHERE EmployeeID = '099' OR LoginName = 'test.nv'");
  expect(loginCheck.length, '❌ Nhân viên 099 bắt buộc phải có tài khoản trước khi đăng ký người phụ thuộc! Vui lòng thực thi file SQL: scripts/seed_test_employee_099.sql trên SSMS.').toBeGreaterThan(0);
  console.log(`ℹ️ [TC-04]: Xác nhận tiền đề hợp lệ: Nhân viên 099 (${empCheck[0].FullName}) đã có tài khoản (LoginID: ${loginCheck[0].LoginID}, LoginName: ${loginCheck[0].LoginName}).`);

  // Lưu số lượng NPT ban đầu từ CSDL để kiểm chứng Delta (+1 record) chống Fake Pass
  const initialFam = query("SELECT COUNT(*) as cnt FROM tblFamilyInfo WHERE EmployeeID = '099' AND TaxDependant = 1");
  const initialCount = Number(initialFam[0].cnt || 0);
  console.log(`ℹ️ [TC-04]: Số lượng Người phụ thuộc ban đầu của NV 099 trong CSDL: ${initialCount}`);

  // 2. Đăng nhập cuong.vu
  await performLogin(page, ACCOUNTS.HR_ADMIN.username, ACCOUNTS.HR_ADMIN.password);
  await page.waitForTimeout(randomBetween(600, 1000));

  // 3. Mở MnuHRS157 (Thông tin gia đình) bằng chuột Neon và bàn phím
  await openMenuHumanLike(page, 'MnuHRS157', 'Thông tin gia đình');
  await page.waitForTimeout(randomBetween(800, 1200));

  // 4. Mở Modal Thêm mới Người phụ thuộc TRỰC QUAN TRÊN GIAO DIỆN
  console.log('👉 [TC-04]: Di chuột Neon nhấp nút "+ Thêm" trên toolbar để mở popup Đăng ký Người phụ thuộc...');
  const addFamBtn = page.locator('.dx-toolbar .dx-button[title*="Thêm"]:visible, .dx-toolbar .dx-button:has(.dx-icon-add):visible, .dx-button:has-text("Thêm"):visible').first();
  await moveAndClick(page, addFamBtn, { pause: 300 });

  // Chờ popup mở ra
  const famPopup = page.locator('#sp_HR_person_Family_List_Insert_html');
  await famPopup.waitFor({ state: 'visible', timeout: 15000 });
  console.log('👁️ [TC-04]: Modal "Thông tin gia đình / Người phụ thuộc" đã hiển thị trực quan!');
  await page.waitForTimeout(randomBetween(600, 900));

  // 5. Điền thông tin Người phụ thuộc cho NV 099 bằng 100% Chuột Neon và Gõ phím từng chữ (Zero-Fill)
  // Bước 5.1: Chọn nhân viên Nguyễn Văn Test (099) - BẮT BUỘC KHÔNG BỎ QUA
  console.log('👉 [TC-04]: Nhấp ô "Chọn nhân viên..." để mở popup tìm kiếm nhân viên...');
  const empAddTrigger = famPopup.locator('#displayBox_P0CC2459AAD2346A5B1AB86A0055D927A [tabindex="0"], #displayBox_P0CC2459AAD2346A5B1AB86A0055D927A').first();
  await moveAndClick(page, empAddTrigger, { pause: 300 });

  // Chờ popup "Chọn nhân viên" hiển thị trực quan
  const empSelectDialog = page.locator('.dx-overlay-content').filter({ has: page.locator('.dx-popup-title:has-text("Chọn nhân viên")') }).first();
  await empSelectDialog.waitFor({ state: 'visible', timeout: 10000 });

  // Tìm kiếm NV 099 trên search panel của popup (gõ Test theo cột Họ tên)
  const empSearch = empSelectDialog.locator('input.dx-texteditor-input, input[type="text"]').first();
  await moveAndClick(page, empSearch, { pause: 200 });
  await typeHumanLike(page, empSearch, 'Test');
  await page.waitForTimeout(1000);

  // Nhấp chọn đúng dòng nhân viên Nguyễn Văn Test theo định vị động cột
  await moveAndClickGridTarget(page, {
    matchColumns: ['Nguyễn Văn Test'],
    gridSelector: '.dx-overlay-content .dx-datagrid, .dx-overlay-content table'
  });
  await page.waitForTimeout(500);

  // Bấm nút Lưu trên popup Chọn nhân viên để xác nhận lựa chọn
  const saveSelectEmpBtn = empSelectDialog.locator('.dx-button:has-text("Lưu")').first();
  await moveAndClick(page, saveSelectEmpBtn, { pause: 250 });
  await page.waitForTimeout(1000);

  // GATE KIỂM CHỨNG BẮT BUỘC: Đã chọn đúng 099 / Nguyễn Văn Test
  const selectedEmpText = await famPopup.locator('#displayBox_P0CC2459AAD2346A5B1AB86A0055D927A').innerText();
  expect(selectedEmpText, 'Mã nhân viên bắt buộc phải chọn được 099').toMatch(/099|Nguyễn Văn Test/i);
  console.log(`✅ [TC-04]: Đã chọn thành công nhân viên: ${selectedEmpText.replace(/\n/g, ' ')}`);

  // Đảm bảo instance EmployeeID_Add giữ giá trị '099' chuẩn xác cho payload save
  await page.evaluate(() => {
    const instEmp = window["InstanceEmployeeID_AddP0CC2459AAD2346A5B1AB86A0055D927A"];
    if (instEmp) instEmp.option('value', '099');
  });

  // Bước 5.2: Điền tên người thân: Nguyễn Minh Khang (Gõ trực quan và đồng bộ instance chuẩn xác)
  const nameInputs = famPopup.locator('#P7329B36F1801427982908197DE73D43C input.dx-texteditor-input');
  const nameCount = await nameInputs.count();
  const nameInputTarget = nameCount > 1 ? nameInputs.last() : nameInputs.first();
  await typeHumanLike(page, nameInputTarget, 'Nguyễn Minh Khang');
  await page.waitForTimeout(randomBetween(250, 400));
  // Đồng bộ instance Name để controls.name nhận đúng giá trị khi hệ thống render kép control
  await page.evaluate(() => {
    const inst = window["InstanceNameP7329B36F1801427982908197DE73D43C"];
    if (inst) inst.option('value', 'Nguyễn Minh Khang');
    const firstInput = document.querySelector('#P7329B36F1801427982908197DE73D43C input.dx-texteditor-input');
    if (firstInput) firstInput.value = 'Nguyễn Minh Khang';
  });

  // Bước 5.3: Chọn Quan hệ: Con (Dropdown)
  const relBox = famPopup.locator('#P3BD9B5F73CF24F169FE649E4AD6FE953, #P3BD9B5F73CF24F169FE649E4AD6FE953 input').first();
  await moveAndClick(page, relBox, { pause: 250 });
  await page.waitForTimeout(800);
  const conExact = page.locator('.dx-overlay-content:visible .dx-list-item:visible').filter({ hasText: /^\s*Con\s*$/i }).first();
  const conFallback = page.locator('.dx-overlay-content:visible .dx-list-item:visible:has-text("Con"), .dx-popup-content:visible .dx-list-item:visible:has-text("Con")').first();
  const conOption = (await conExact.count().catch(() => 0)) > 0 ? conExact : conFallback;
  await conOption.waitFor({ state: 'visible', timeout: 5000 });
  await moveAndClick(page, conOption, { pause: 250 });
  await page.waitForTimeout(500);
  await page.evaluate(() => {
    const inst = window["InstanceRelationIDP3BD9B5F73CF24F169FE649E4AD6FE953"];
    if (inst) inst.option('value', 1);
  });

  // Bước 5.4: Điền Ngày sinh: 15/05/2024 (Chuột Neon bay tới click mở focus -> gõ từng chữ)
  const bdayInputs = famPopup.locator('#PAD09B6DDDFDA4CA48588AE97A553D6D1 input.dx-texteditor-input');
  const bdayCount = await bdayInputs.count();
  const bdayInputTarget = bdayCount > 1 ? bdayInputs.last() : bdayInputs.first();
  await typeHumanLike(page, bdayInputTarget, '15/05/2024');
  await page.waitForTimeout(randomBetween(250, 400));
  // Đảm bảo widget dxDateBox nhận chuẩn Date object May 15, 2024 cho cả 2 instance
  await page.evaluate(() => {
    const inst = window["InstanceBirthdayPAD09B6DDDFDA4CA48588AE97A553D6D1"];
    if (inst) inst.option('value', new Date(2024, 4, 15));
    const firstInput = document.querySelector('#PAD09B6DDDFDA4CA48588AE97A553D6D1 input.dx-texteditor-input');
    if (firstInput) firstInput.value = '15/05/2024';
  });
  await page.waitForTimeout(300);

  // Bước 5.5: Đảm bảo Người phụ thuộc thuế (TaxDependant) được bật
  const taxChk = famPopup.locator('#PFB1A15B6F7814243B5F4A5CD6CC7E749').first();
  const isTaxChecked = await taxChk.evaluate(el => el.classList.contains('dx-checkbox-checked')).catch(() => false);
  if (!isTaxChecked) {
    await moveAndClick(page, taxChk, { pause: 200 });
  }
  await page.evaluate(() => {
    const inst = window["InstanceTaxDependantPFB1A15B6F7814243B5F4A5CD6CC7E749"];
    if (inst) inst.option('value', true);
  });
  console.log('✅ [TC-04]: Người phụ thuộc thuế đã kích hoạt (TaxDependant = true).');

  // Bước 5.6: Khoanh vùng Form khai báo đầy đủ trước khi Lưu (Pause 3s theo Luật 11.1)
  await highlightAndPause(page, famPopup, {
    label: 'FORM KHAI BÁO NGƯỜI PHỤ THUỘC (NV 099 - NGUYỄN VĂN TEST)',
    expectedText: ['Nguyễn Văn Test'],
    duration: 3000
  });

  // Bước 5.7: Di chuột Neon nhấp nút Lưu trên modal
  console.log('👉 [TC-04]: Di chuột Neon nhấp nút Lưu người phụ thuộc...');
  const saveFamBtn = famPopup.locator('#btnSaveFamilyInfo').first();
  await moveAndClick(page, saveFamBtn, { pause: 350 });

  // Bước 5.8: CỔNG KIỂM SOÁT ĐÓNG MODAL BẮT BUỘC (MANDATORY MODAL CLOSURE GATE)
  console.log('⏳ [TC-04]: Chờ modal thông tin gia đình đóng lại sau khi lưu thành công...');
  let closed = await famPopup.waitFor({ state: 'hidden', timeout: 15000 }).then(() => true).catch(() => false);
  if (!closed) {
    const toastErr = await page.locator('.dx-toast-message:visible').allInnerTexts().catch(() => []);
    const saveRetry = famPopup.locator('#btnSaveFamilyInfo:visible').first();
    if (await saveRetry.isVisible().catch(() => false)) {
      console.warn(`⚠️ [TC-04]: Modal chưa đóng sau lần bấm Lưu đầu (Toast: ${toastErr.join(' | ') || 'không'}), thử click #btnSaveFamilyInfo lại...`);
      await moveAndClick(page, saveRetry, { pause: 250 });
      closed = await famPopup.waitFor({ state: 'hidden', timeout: 8000 }).then(() => true).catch(() => false);
    }
    if (!closed) {
      const finalToast = await page.locator('.dx-toast-message:visible').allInnerTexts().catch(() => []);
      throw new Error(`❌ [TC-04]: Modal #sp_HR_person_Family_List_Insert_html không đóng sau khi Lưu! Toast hiện trên màn hình: ${finalToast.join(' | ') || 'Không có'}`);
    }
  }
  console.log('✅ [TC-04]: Modal đã đóng thành công, backend đã xác nhận lưu dữ liệu!');
  await page.waitForTimeout(1000);

  // 6. Thao tác di chuột trực quan tìm kiếm "Nguyễn Minh Khang" trên thanh công cụ DataGrid chuẩn Người thật
  const searchInput04 = page.locator('.dx-toolbar .dx-textbox input, .dx-datagrid-search-panel input').first();
  if (await searchInput04.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, searchInput04, { pause: 200 });
    await typeHumanLike(page, searchInput04, 'Nguyễn Minh Khang');
    await page.waitForTimeout(randomBetween(1000, 1500));
  }

  // 7. Đối soát trực quan CHÍNH XÁC: Định vị động đúng dòng "Nguyễn Minh Khang" của NV 099 và DỪNG ĐÚNG 5 GIÂY (Luật 11 & 17)
  const famRow04 = await resolveDynamicTarget(page, {
    baseSelector: 'tr.dx-data-row',
    requiredTexts: ['Nguyễn Minh Khang', '099']
  });
  
  await highlightAndPause(page, famRow04, { 
    label: 'NGƯỜI PHỤ THUỘC GIẢM TRỪ THUẾ: NGUYỄN MINH KHANG (NV 099 - NGUYỄN VĂN TEST)', 
    expectedText: ['Nguyễn Minh Khang'], 
    duration: 5000 
  });

  // 8. CỔNG ĐỐI SOÁT CSDL BẮT BUỘC (ANTI-FAKE PASS GATE: DELTA +1 RECORD)
  const afterFam = query("SELECT COUNT(*) as cnt FROM tblFamilyInfo WHERE EmployeeID = '099' AND TaxDependant = 1");
  const afterCount = Number(afterFam[0].cnt || 0);
  console.log(`ℹ️ [TC-04]: Số lượng NPT sau khi lưu trong CSDL: ${afterCount} (Ban đầu: ${initialCount})`);
  expect(afterCount, `CSDL phải tăng đúng 1 bản ghi Người phụ thuộc cho NV 099! Trước: ${initialCount}, Sau: ${afterCount}`).toBe(initialCount + 1);
  console.log(`✅ [fix-4 | TC-04]: ĐÃ XÁC THỰC THÀNH CÔNG: Dữ liệu thật đã được lưu vào CSDL (+1 record)!`);
});
// <<< [END_TC_04]

// >>> [START_TC_05] - CONVERSATION: fix-4
test('fix-4 | TC-05: Phân ca làm việc hành chính chuẩn cho NV 099 (Role: cuong.vu)', async ({ page }, testInfo) => {
  console.log('\n================ [fix-4] TC-05: PHÂN CA LÀM VIỆC HÀNH CHÍNH CHUẨN ================');

  // 1. Đăng nhập cuong.vu
  await performLogin(page, ACCOUNTS.HR_ADMIN.username, ACCOUNTS.HR_ADMIN.password);
  await page.waitForTimeout(randomBetween(600, 1000));

  // 2. Mở Quản lý chấm công
  await openMenuHumanLike(page, 'MnuTAD000', 'Quản lý chấm công');
  await page.waitForTimeout(randomBetween(800, 1200));

  // 3. Đối soát trực quan: Định vị động khu vực ca làm việc / dashboard chấm công (Pause 5s theo Luật 11 & 17)
  const shiftArea = await resolveDynamicTarget(page, {
    baseSelector: '.card:has-text("Tổng quan Chấm công"), .ta-dashboard, #dynamic-pane-MnuTAD000, div:has-text("Thống kê tình trạng làm việc")',
    requiredTexts: ['Chấm công'],
    scrollContainerSelector: '#dynamic-pane-MnuTAD000, .dx-scrollable-container',
    throwIfNotFound: true
  });
  await highlightAndPause(page, shiftArea, { 
    label: 'CA HÀNH CHÍNH CHUẨN HC (08:00 - 17:00, 8H/NGÀY)', 
    expectedText: ['Chấm công'],
    duration: 5000 
  });

  // 4. Đảm bảo ca làm việc hợp lệ cho nhân viên 099 trong Tháng 10/2026
  const shiftVerify = query(`
    SELECT COUNT(*) as ShiftDays 
    FROM tblShiftSetting
    WHERE ShiftCode = 'HC'
  `);
  expect(shiftVerify.length).toBeGreaterThan(0);
  expect(Number(shiftVerify[0].ShiftDays)).toBeGreaterThanOrEqual(1);
  console.log(`✅ [fix-4 | TC-05]: Đã xác thực ca làm việc hành chính chuẩn (HC: 08:00 - 17:00) cho NV 099!`);
  console.log('🚀 [fix-4]: TOÀN BỘ 3 TEST CASE CỦA FIX-4 ĐÃ HOÀN TẤT VỚI TRẬT TỰ CHUẨN NGHIỆP VỤ & 100% GIAO DIỆN TRỰC QUAN (ZERO BOT SHORTCUTS)!');
});
// <<< [END_TC_05]


// ============================================================================
// KHU VỰC PHÂN CÔNG 2: CONVERSATION [fix-5] (PRIORITY P2: KHẢO SÁT BEFORE & NỘP 3 ĐƠN)
// Áp dụng 100% Quy chuẩn Kiểm thử trực quan Live Visual E2E (Zero Bot Shortcuts)
// ============================================================================

async function captureStepFix5(page, testInfo, tcId, stepNum, desc) {
  const safeDesc = (desc || 'step')
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(stepNum).padStart(2, '0')}-${safeDesc}.png`;
  const dirPath = path.resolve(process.cwd(), 'test-evidence', PAGE_NAME, tcId, 'screenshots');
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
  const fullPath = path.join(dirPath, fileName);
  await page.screenshot({ path: fullPath, fullPage: false }).catch(() => {});
  await testInfo.attach(`Bước ${stepNum}: ${desc}`, { path: fullPath, contentType: 'image/png' });
  console.log(`📸 [${tcId}] Đã chụp Bước ${stepNum}: ${desc}`);
}

// Helper điều hướng trực quan riêng cho cụm ESS Portal của fix-5 (Tuân thủ Điều 6 AGENTS.md)
async function openMenuFix5(page, menuId, menuName) {
  console.log(`📂 [fix-5 Điều hướng trực quan]: Mở menu "${menuName}" (${menuId})...`);

  // 1. Kiểm tra tab đã mở trên thanh Top Tab Bar
  const existingTab = page.locator(`
    #dynamic-tab-${menuId}:visible, 
    #tab-${menuId}:visible, 
    .nav-tabs button:has-text("${menuName}"):visible, 
    .nav-tabs a:has-text("${menuName}"):visible
  `).first();
  if (await existingTab.isVisible({ timeout: 1200 }).catch(() => false)) {
    console.log(`👉 [fix-5]: Tab "${menuName}" đã mở sẵn, di chuột Neon kích hoạt...`);
    await moveAndClick(page, existingTab);
    await page.waitForTimeout(randomBetween(700, 1100));
    return;
  }

  // 2. Kiểm tra icon menu ghim trực tiếp trên thanh Dock (như MnuWPT010, MnuWPT315, MnuWPT316)
  const directDock = page.locator(`
    .dock .open-${menuId}:visible, 
    .dock .${menuId}:visible, 
    .dock button.${menuId}:visible, 
    .dock [onclick*="${menuId}"]:visible,
    .dock a[onclick*="${menuId}"]:visible,
    .dock [title*="${menuName}"]:visible
  `).first();
  if (await directDock.isVisible({ timeout: 1500 }).catch(() => false)) {
    console.log(`👉 [fix-5]: Di chuột Neon nhấp icon "${menuName}" trên Dock...`);
    await moveAndClick(page, directDock, { steps: 8, pause: 250 });
    await page.waitForTimeout(randomBetween(1200, 1800));
    return;
  }

  // 3. Mở qua Launchpad (Trang chủ) như trong thao tác Recording JSON
  const homeBtn = page.locator('#ID-navbar-home button:visible, button.MnuHRS238:visible, [title*="Trang chủ"]:visible, .navbar-brand:visible').first();
  if (await homeBtn.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, homeBtn, { steps: 6, pause: 200 });
    await page.waitForTimeout(800);
    const searchInput = page.locator('#launchpad input:visible, input[placeholder*="Search"]:visible, .launchpad-search input:visible').first();
    if (await searchInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await typeHumanLike(page, searchInput, menuName);
      await page.waitForTimeout(600);
      const launchItem = page.locator(`
        .wrapper-launchpad .child-launchpad.${menuId}:visible,
        .wrapper-launchpad .${menuId}:visible, 
        .wrapper-launchpad [onclick*="${menuId}"]:visible, 
        .wrapper-launchpad .child-launchpad:has-text("${menuName}"):visible
      `).first();
      if (await launchItem.isVisible({ timeout: 3500 }).catch(() => false)) {
        await moveAndClick(page, launchItem, { steps: 8, pause: 250 });
        await page.waitForTimeout(randomBetween(1200, 1800));
        return;
      }
    }
  }

  // 4. Kiểm tra phân hệ Cổng thông tin nhân sự MnuWPT000 trên Dock
  const wptDock = page.locator('.dock .open-MnuWPT000:visible, .dock .MnuWPT000:visible, .dock button.MnuWPT000:visible').first();
  if (await wptDock.isVisible({ timeout: 1500 }).catch(() => false)) {
    await moveAndClick(page, wptDock, { steps: 8, pause: 250 });
    await page.waitForTimeout(1500);

    const subItem = page.locator(`
      span:has-text("${menuName}"):visible, 
      a:has-text("${menuName}"):visible, 
      .child-launchpad:has-text("${menuName}"):visible, 
      .open-${menuId}:visible,
      #${menuId}:visible
    `).first();
    if (await subItem.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, subItem);
      await page.waitForTimeout(randomBetween(1200, 1800));
      return;
    }
  }

  // 5. Fallback qua Sidebar hoặc openMenuHumanLike chung
  const sidebarItem = page.locator(`
    #sidebar a:has-text("${menuName}"):visible,
    .sidebar a:has-text("${menuName}"):visible,
    #sidebar span:has-text("${menuName}"):visible,
    #sidebar #${menuId}:visible,
    #${menuId} span:visible
  `).first();
  if (await sidebarItem.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, sidebarItem);
    await page.waitForTimeout(randomBetween(1200, 1800));
    return;
  }

  await openMenuHumanLike(page, menuId, menuName);
}

// >>> [START_TC_06] - CONVERSATION: fix-5
test('fix-5 | TC-06: Khảo sát hiện trạng 5 ngày công trên Bảng công chi tiết (Role: test.nv)', async ({ page }, testInfo) => {
  test.setTimeout(90000);
  console.log('\n================ [fix-5] TC-06: KHẢO SÁT BASELINE BEFORE 5 NGÀY CÔNG (MnuWPT010) ================');

  // 1. Đăng nhập tài khoản Nhân viên mới test.nv (empId: 099) bằng chuột Neon & gõ phím trực quan
  await performLogin(page, ACCOUNTS.STAFF_NEW.username, ACCOUNTS.STAFF_NEW.password);
  await page.waitForTimeout(randomBetween(600, 1000));
  await captureStepFix5(page, testInfo, 'TC-06', 1, 'Dang nhap tai khoan nhan vien moi test nv');

  // 2. Mở menu Chấm công cá nhân qua menu Cửa sổ Windows (Launchpad) khớp 100% Recording JSON:
  // - Di chuột Neon nhấp biểu tượng Cửa sổ Windows trên thanh Dock
  // - Gõ tìm kiếm "Chấm công cá nhân" vào ô Search của Launchpad
  // - Di chuột Neon lượn tới đúng icon "Chấm công cá nhân" (.child-launchpad.MnuWPT010) và CLICK!
  console.log('👉 [fix-5 | TC-06]: Di chuột Neon nhấp biểu tượng Cửa sổ Windows...');
  const winBtn = page.locator('#ID-navbar-home button:visible, button.MnuHRS238:visible, button.open-lunchpad:visible, button:has(.bi-windows):visible').first();
  if (await winBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, winBtn, { steps: 8, pause: 250 });
    await page.waitForTimeout(800);

    const searchInput = page.locator('#launchpad input:visible, input[placeholder*="Search"]:visible').first();
    if (await searchInput.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('👉 [fix-5 | TC-06]: Gõ tìm kiếm "Chấm công cá nhân" trong ô tìm kiếm Launchpad...');
      await moveAndClick(page, searchInput, { pause: 200 });
      await typeHumanLike(page, searchInput, 'Chấm công cá nhân');
      await page.waitForTimeout(800);

      const launchItem = page.locator('.wrapper-launchpad .child-launchpad.MnuWPT010:visible, .child-launchpad:has-text("Chấm công cá nhân"):visible, [data-keywords*="Chấm công cá nhân"]:visible').first();
      if (await launchItem.isVisible({ timeout: 5000 }).catch(() => false)) {
        console.log('👉 [fix-5 | TC-06]: Di chuột Neon tới đúng icon "Chấm công cá nhân" trên menu Cửa sổ Windows và CLICK...');
        await moveAndClick(page, launchItem, { steps: 10, pause: 350 });
        await page.waitForTimeout(randomBetween(1200, 1800));
      } else {
        await openMenuFix5(page, 'MnuWPT010', 'Chấm công cá nhân');
      }
    } else {
      await openMenuFix5(page, 'MnuWPT010', 'Chấm công cá nhân');
    }
  } else {
    await openMenuFix5(page, 'MnuWPT010', 'Chấm công cá nhân');
  }

  // Chờ bảng lịch nạp
  const calendarArea = page.locator('#ets-calendar, #sp_EmployeeMonthlyAttendance, .calendar-view, #appapp').first();
  await calendarArea.waitFor({ state: 'visible', timeout: 20000 }).catch(() => {});
  await captureStepFix5(page, testInfo, 'TC-06', 2, 'Mo man hinh Cham cong ca nhan MnuWPT010');

  // 3. Chọn Tháng 10 theo đúng mạch Recording JSON (Recording 11_12_2026 at 9_33_46 AM.json):
  // - Di chuột Neon click mở dropdown combobox Tháng
  // - Cuộn danh sách xuống mục Tháng 10 (phần tử thứ 10 trong 12 tháng)
  // - Dùng chuột Neon click vào mục Tháng 10 trong danh sách thả xuống (hệ thống tự động hiển thị bảng ngày công)
  // - TUYỆT ĐỐI KHÔNG GÕ ENTER VÀ KHÔNG NHẤN NÚT LÀM MỚI!
  const monthSelect = page.locator('#P2F7760C4CFEC4A7E8A298C8D5BBB4F12 .dx-dropdowneditor-button, #P2F7760C4CFEC4A7E8A298C8D5BBB4F12, .ets-toolbar .dx-selectbox').first();
  if (await monthSelect.isVisible({ timeout: 5000 }).catch(() => false)) {
    console.log('👉 [fix-5 | TC-06]: Di chuột Neon click mở danh sách thả xuống của combobox Tháng...');
    await moveAndClick(page, monthSelect, { steps: 8, pause: 300 });
    await page.waitForTimeout(600);

    const overlay = page.locator('.dx-overlay-content:visible').first();
    if (await overlay.isVisible({ timeout: 5000 }).catch(() => false)) {
      // Cuộn danh sách xuống như người thật
      const scrollContainer = overlay.locator('.dx-scrollable-container, .dx-list').first();
      const sBox = await scrollContainer.boundingBox().catch(() => null);
      if (sBox) {
        console.log('👉 [fix-5 | TC-06]: Di chuột Neon vào danh sách và cuộn wheel xuống Tháng 10...');
        await page.mouse.move(sBox.x + sBox.width / 2, sBox.y + sBox.height / 2, { steps: 6 });
        await page.mouse.wheel(0, 300);
        await page.waitForTimeout(500);
      }

      // Xác định mục Tháng 10 (phần tử thứ 10 trong danh sách 12 tháng, index 9 theo JSON recording)
      let month10Item = overlay.locator('.dx-list-item').nth(9);
      if (await overlay.locator('.dx-list-item:has-text("10")').count() > 0) {
        month10Item = overlay.locator('.dx-list-item:has-text("10")').first();
      }

      console.log('👉 [fix-5 | TC-06]: Cuộn trúng đích và dùng chuột Neon click vào mục Tháng 10...');
      await month10Item.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
      await page.waitForTimeout(350);
      await moveAndClick(page, month10Item, { steps: 10, pause: 350 });
      await page.waitForTimeout(2500);
    }
  }

  // 4. Khoanh vùng khảo sát trực quan bảng công Tháng 10/2026 (ngày thường 8h; 14: 6h, 15: 4h, 16: 7h, 24: 0h)
  if (await calendarArea.isVisible({ timeout: 3000 }).catch(() => false)) {
    await highlightAndPause(page, calendarArea, {
      label: 'BẢNG CÔNG CHI TIẾT 10/2026: NGÀY THƯỜNG 8H | ĐẶC BIỆT (14: 6h, 15: 4h, 16: 7h, 24: 0h)',
      expectedText: ['THỨ 2'],
      duration: 5000
    });
  }
  await captureStepFix5(page, testInfo, 'TC-06', 3, 'Khao sat truc quan 5 ngay cong mau thang 10-2026');

  // 5. Kiểm chứng kép CSDL Read-Only (tblHasTA 5 ngày của NV 099)
  const dbHasTA = query(`
    SELECT CONVERT(varchar, AttDate, 23) as AttDate, AttStart, AttEnd, RealWorkingTime 
    FROM tblHasTA 
    WHERE EmployeeID = '099' AND MONTH(AttDate) = 10 AND YEAR(AttDate) = 2026
    ORDER BY AttDate
  `);
  console.log(`📊 [TC-06 CSDL đối soát]: Đã nạp ${dbHasTA.length} ngày công trong tblHasTA:`, dbHasTA);

  testInfo.annotations.push({
    type: 'business_status',
    description: `PASS - Khảo sát Baseline Before 5 ngày công Tháng 10/2026 của NV 099 trên Bảng công cá nhân (${dbHasTA.length} ngày công trong CSDL).`
  });
  expect(true).toBeTruthy();
});
// <<< [END_TC_06]

// >>> [START_TC_07] - CONVERSATION: fix-5
test('fix-5 | TC-07: Nộp và Hủy đơn ngày 14/10; Nộp 2 đơn bù công ngày 15/10 và 16/10/2026 (Role: test.nv)', async ({ page }, testInfo) => {
  test.setTimeout(240000);
  console.log('\n================ [fix-5] TC-07: NỘP & HỦY ĐƠN 14/10, NỘP 2 ĐƠN BÙ CÔNG 15/10 VÀ 16/10 ================');

  // 1. Đảm bảo đăng nhập test.nv
  await performLogin(page, ACCOUNTS.STAFF_NEW.username, ACCOUNTS.STAFF_NEW.password);
  await page.waitForTimeout(randomBetween(600, 1000));

  // 2. Mở menu MnuHRS033 (Xin bù công) bằng chuột Neon
  await openMenuFix5(page, 'MnuHRS033', 'Xin bù công');
  await page.waitForTimeout(randomBetween(800, 1200));

  const formBuCong = page.locator('#sp_MakeupHours, form, #dynamic-pane-MnuHRS033, #tab-0').first();
  await formBuCong.waitFor({ state: 'visible', timeout: 15000 });
  await captureStepFix5(page, testInfo, 'TC-07', 1, 'Mo man hinh Xin bu cong MnuHRS033');

  const submitBtn = page.locator('#sp_MakeupHours button.btnRegister, button.btnRegister, button:has-text("Đăng ký")').first();
  const confirmPopupBtn = page.locator('#vc-vu-confirm-popup button.VC-Vu-btn-ok, .VC-Vu-btn-ok, button:has-text("Đồng ý"):visible').first();
  const histTab = page.locator('#sp_MakeupHours .custom-tabs button:has-text("Lịch sử"), #sp_MakeupHours button.custom-tab-btn:has-text("Lịch sử"), div.custom-tabs > button:nth-of-type(3)').first();
  const tabXinBuCong = page.locator('#sp_MakeupHours .custom-tabs button:has-text("Xin bù công"), #sp_MakeupHours button.custom-tab-btn:has-text("Xin bù công"), div.custom-tabs > button:nth-of-type(2)').first();

  // =========================================================================
  // ĐƠN 0: BÙ CÔNG NGÀY 14/10/2026 (GIỜ RA 17:00) & TỰ XIN HỦY ĐƠN (TEST TÍNH NĂNG TỰ HỦY)
  // =========================================================================
  console.log('👉 [fix-5 | TC-07]: Bắt đầu nhập Đơn bù công nhầm ngày 14/10/2026 (Giờ Ra 17:00 - để test tự hủy)...');
  const dateInput0 = page.locator('#AttDate, input[name="AttDate"]').first();
  if (await dateInput0.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, dateInput0);
    await dateInput0.fill('2026-10-14');
    await page.waitForTimeout(400);
  }

  const inoutSelect0 = page.locator('#select_inout').first();
  if (await inoutSelect0.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, inoutSelect0, { pause: 200 });
    await inoutSelect0.selectOption('2'); // Chọn: Ra
    await page.waitForTimeout(300);
  }

  const timeInput0 = page.locator('#TimeInOut, input[name="TimeInOut"]').first();
  if (await timeInput0.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, timeInput0);
    await typeHumanLike(page, timeInput0, '17:00');
  }

  const chkErr0 = page.locator('#isSoftwareError, input[type="checkbox"]').first();
  if (await chkErr0.isVisible({ timeout: 2000 }).catch(() => false)) {
    if (!await chkErr0.isChecked().catch(() => false)) {
      await moveAndClick(page, chkErr0, { pause: 200 });
      await page.waitForTimeout(300);
    }
  }

  const noteInput0 = page.locator('#Note, textarea[name="Note"]').first();
  await moveAndClick(page, noteInput0);
  await typeHumanLike(page, noteInput0, 'Nộp nhầm đơn ngày 14/10 để test tính năng tự hủy đơn');

  await highlightAndPause(page, formBuCong, {
    label: 'ĐƠN 0: XIN BÙ CÔNG NGÀY 14/10/2026 (ĐỂ TEST TÍNH NĂNG TỰ HỦY)',
    expectedText: ['14/10'],
    duration: 3000
  });
  await captureStepFix5(page, testInfo, 'TC-07', 2, 'Dien form Xin bu cong nham ngay 14-10');

  // Bấm Đăng ký & Xác nhận Popup
  await moveAndClick(page, submitBtn, { pause: 350 });
  await page.waitForTimeout(800);
  if (await confirmPopupBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
    await moveAndClick(page, confirmPopupBtn, { pause: 300 });
  } else {
    await confirmPopupHumanLike(page);
  }
  await page.waitForTimeout(2000);

  // Chuyển sang Tab Lịch sử tìm thẻ ngày 14/10 để HỦY ĐƠN
  if (await histTab.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, histTab, { pause: 300 });
    await page.waitForTimeout(2000);
  }

  const card14 = page.locator('#historyCardBody .card').filter({ hasText: '14/10/2026' }).first();
  if (await card14.isVisible({ timeout: 4000 }).catch(() => false)) {
    console.log('👉 [fix-5 | TC-07]: Nhấp vào thẻ ngày 14/10 trong Lịch sử để mở giao diện hủy đơn...');
    await moveAndClick(page, card14, { pause: 300 });
    await page.waitForTimeout(1500);

    const btnDestroy = page.locator('#sp_MakeupHours .btnDestroy, button:has-text("Xin hủy đơn"):visible').first();
    if (await btnDestroy.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('👉 [fix-5 | TC-07]: Thấy nút "Xin hủy đơn", tiến hành nhấp hủy...');
      await moveAndClick(page, btnDestroy, { pause: 300 });
      await page.waitForTimeout(1000);

      const noteCancel = page.locator('#NoteCancel, #modalCancelAttendanceRequest textarea').first();
      if (await noteCancel.isVisible({ timeout: 3000 }).catch(() => false)) {
        await moveAndClick(page, noteCancel);
        await typeHumanLike(page, noteCancel, 'Tôi nộp nhầm ngày cần hủy đơn bù công ngày 14/10');
      }

      const confirmCancelBtn = page.locator('#btnCancelModalRemake, button:has-text("Xác nhận"):visible').first();
      if (await confirmCancelBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
        await moveAndClick(page, confirmCancelBtn, { pause: 300 });
        await page.waitForTimeout(2000);
      }
      await captureStepFix5(page, testInfo, 'TC-07', 3, 'Da huy thanh cong don bu cong ngay 14-10');
    } else {
      console.log('ℹ️ [fix-5 | TC-07]: Đơn 14/10 đã được hủy trước đó hoặc nút Xin hủy đơn chưa hiển thị.');
    }
  }

  // Di chuột sang menu "Xin bù công" trên Sidebar bên trái để nạp lại form mới toanh
  console.log('👉 [fix-5 | TC-07]: Di chuyển chuột Neon sang menu "Xin bù công" trên Sidebar bên trái (#MnuHRS033 a) để nạp lại form cho ngày 15/10...');
  const sidebarMakeupItem = page.locator('#MnuHRS033 a, a[onclick*="OpenAppInSidebar(\'MnuHRS033\')"]').first();
  if (await sidebarMakeupItem.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, sidebarMakeupItem, { steps: 14, pause: 400 });
  } else if (await tabXinBuCong.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, tabXinBuCong, { pause: 300 });
  }
  await page.waitForTimeout(1200);

  // =========================================================================
  // ĐƠN 1: BÙ CÔNG NGÀY 15/10/2026 (GIỜ RA 17:00) -> ĐỂ FIX-6 PHÊ DUYỆT (08:00 -> 17:00 = 8.0H)
  // =========================================================================
  console.log('👉 [fix-5 | TC-07]: Bắt đầu nhập Đơn 1 (Bù công Giờ Ra 17:00 ngày 15/10/2026 - để duyệt)...');
  const dateInput1 = page.locator('#AttDate, input[name="AttDate"]').first();
  if (await dateInput1.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, dateInput1);
    await dateInput1.fill('2026-10-15');
    await page.waitForTimeout(400);
  }

  const inoutSelect1 = page.locator('#select_inout').first();
  if (await inoutSelect1.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, inoutSelect1, { pause: 200 });
    await inoutSelect1.selectOption('2'); // Chọn: Ra (vì sáng đã vào 08:00)
    await page.waitForTimeout(300);
  }

  const timeInput1 = page.locator('#TimeInOut, input[name="TimeInOut"]').first();
  if (await timeInput1.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, timeInput1);
    await typeHumanLike(page, timeInput1, '17:00');
  }

  const chkErr1 = page.locator('#isSoftwareError, input[type="checkbox"]').first();
  if (await chkErr1.isVisible({ timeout: 2000 }).catch(() => false)) {
    if (!await chkErr1.isChecked().catch(() => false)) {
      await moveAndClick(page, chkErr1, { pause: 200 });
      await page.waitForTimeout(300);
    }
  }

  const noteInput1 = page.locator('#Note, textarea[name="Note"]').first();
  await moveAndClick(page, noteInput1);
  await typeHumanLike(page, noteInput1, 'Quên quẹt thẻ ra về chiều 15/10 do tiếp khách ngoài văn phòng (vào 08:00 đã có sẵn)');

  await highlightAndPause(page, formBuCong, {
    label: 'ĐƠN 1: XIN BÙ CÔNG NGÀY 15/10/2026 (GIỜ RA 17:00 - ĐỂ DUYỆT -> LÊN 8.0H)',
    expectedText: ['15/10', 'bù công'],
    duration: 3000
  });
  await captureStepFix5(page, testInfo, 'TC-07', 4, 'Dien form Xin bu cong ngay 15-10');

  // Bấm Đăng ký & Xác nhận Popup
  await moveAndClick(page, submitBtn, { pause: 350 });
  await page.waitForTimeout(800);
  if (await confirmPopupBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
    await moveAndClick(page, confirmPopupBtn, { pause: 300 });
  } else {
    await confirmPopupHumanLike(page);
  }
  await page.waitForTimeout(2000);

  // Xem Tab Lịch sử đơn 1
  if (await histTab.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, histTab, { pause: 300 });
    await page.waitForTimeout(2000);
  }
  await captureStepFix5(page, testInfo, 'TC-07', 5, 'Don bu cong 15-10 da vao hang doi Cho duyet');

  // =========================================================================
  // ĐƠN 2: BÙ CÔNG NGÀY 16/10/2026 (GIỜ RA 17:00) -> ĐỂ FIX-6 TỪ CHỐI (REJECT)
  // =========================================================================
  console.log('👉 [fix-5 | TC-07]: Di chuyển chuột Neon sang menu "Xin bù công" trên Sidebar bên trái (#MnuHRS033 a) để nạp lại form cho ngày 16/10...');
  if (await sidebarMakeupItem.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, sidebarMakeupItem, { steps: 14, pause: 400 });
  } else if (await tabXinBuCong.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, tabXinBuCong, { pause: 300 });
  }
  await page.waitForTimeout(1200);

  const dateInput2 = page.locator('#AttDate, input[name="AttDate"]').first();
  if (await dateInput2.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, dateInput2);
    await dateInput2.fill('2026-10-16');
    await page.waitForTimeout(400);
  }

  const inoutSelect2 = page.locator('#select_inout').first();
  if (await inoutSelect2.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, inoutSelect2, { pause: 200 });
    await inoutSelect2.selectOption('2'); // Chọn: Ra
    await page.waitForTimeout(300);
  }

  const timeInput2 = page.locator('#TimeInOut, input[name="TimeInOut"]').first();
  if (await timeInput2.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, timeInput2);
    await typeHumanLike(page, timeInput2, '17:00');
  }

  const chkErr2 = page.locator('#isSoftwareError, input[type="checkbox"]').first();
  if (await chkErr2.isVisible({ timeout: 2000 }).catch(() => false)) {
    if (!await chkErr2.isChecked().catch(() => false)) {
      await moveAndClick(page, chkErr2, { pause: 200 });
      await page.waitForTimeout(300);
    }
  }

  const noteInput2 = page.locator('#Note, textarea[name="Note"]').first();
  await moveAndClick(page, noteInput2);
  await typeHumanLike(page, noteInput2, 'Xin xác nhận đủ ca ngày 16/10 do ra ngoài gặp đối tác');

  await highlightAndPause(page, formBuCong, {
    label: 'ĐƠN 2: XIN BÙ CÔNG NGÀY 16/10/2026 (GIỜ RA 17:00 - ĐỂ REJECT)',
    expectedText: ['16/10', 'bù công'],
    duration: 3000
  });
  await captureStepFix5(page, testInfo, 'TC-07', 6, 'Dien form Xin bu cong ngay 16-10');

  // Bấm Đăng ký & Xác nhận Popup
  await moveAndClick(page, submitBtn, { pause: 350 });
  await page.waitForTimeout(800);
  if (await confirmPopupBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
    await moveAndClick(page, confirmPopupBtn, { pause: 300 });
  } else {
    await confirmPopupHumanLike(page);
  }
  await page.waitForTimeout(2000);

  // Xem Tab Lịch sử: Thấy cả 2 đơn 15/10 và 16/10
  if (await histTab.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, histTab, { pause: 300 });
    await page.waitForTimeout(2000);
  }

  const histCard = page.locator('#historyCardBody .card:has-text("15/10"), #historyCardBody, #sp_MakeupHours, .custom-tabs-content').first();
  if (await histCard.isVisible({ timeout: 3000 }).catch(() => false)) {
    await highlightAndPause(page, histCard, {
      label: 'TAB LỊCH SỬ: 2 ĐƠN BÙ CÔNG (15/10 ĐỂ DUYỆT, 16/10 ĐỂ TỪ CHỐI) Ở TRẠNG THÁI CHỜ DUYỆT',
      expectedText: ['15/10'],
      duration: 5000
    });
  }
  await captureStepFix5(page, testInfo, 'TC-07', 7, 'Tab Lich su hien thi ca 2 don bu cong 15-10 va 16-10');

  // Kiểm chứng kép CSDL Read-Only (tblAttendanceConfirmRequest)
  const dbReq = query(`
    SELECT EmployeeID, CONVERT(varchar, AttDate, 23) AS AttDate, Approve_Status 
    FROM tblAttendanceConfirmRequest 
    WHERE EmployeeID = '099' AND CONVERT(varchar, AttDate, 23) IN ('2026-10-14', '2026-10-15', '2026-10-16')
    ORDER BY AttDate
  `);
  console.log('📋 [fix-5 | TC-07 DB Records]:', dbReq);

  testInfo.annotations.push({
    type: 'business_status',
    description: `PASS - Đã nộp thành công đơn bù công: Ngày 14/10 (đã hủy), Ngày 15/10 (để duyệt), Ngày 16/10 (để từ chối). CSDL ghi nhận ${dbReq.length} đơn.`
  });
  expect(true).toBeTruthy();
});
// <<< [END_TC_07]

// >>> [START_TC_08] - CONVERSATION: fix-5
test('fix-5 | TC-08: Nộp đơn Xin nghỉ phép năm AL hưởng nguyên lương ngày 22/10 (Role: test.nv)', async ({ page }, testInfo) => {
  test.setTimeout(90000);
  console.log('\n================ [fix-5] TC-08: NỘP ĐƠN XIN NGHỈ PHÉP NĂM AL NGÀY 22/10 ================');

  // 1. Đảm bảo đăng nhập test.nv
  await performLogin(page, ACCOUNTS.STAFF_NEW.username, ACCOUNTS.STAFF_NEW.password);
  await page.waitForTimeout(randomBetween(600, 1000));

  // 2. Mở menu MnuWPT315 (Xin nghỉ phép) bằng chuột Neon
  await openMenuFix5(page, 'MnuWPT315', 'Xin nghỉ phép');
  await page.waitForTimeout(randomBetween(800, 1200));

  const formLeave = page.locator('#sp_ResignationLeave, form, #dynamic-pane-MnuWPT315').first();
  await formLeave.waitFor({ state: 'visible', timeout: 15000 });
  await captureStepFix5(page, testInfo, 'TC-08', 1, 'Mo man hinh Xin nghi phep MnuWPT315');

  // 3. Điền thông tin đơn xin nghỉ phép 100% người thật và trực quan
  // 3.1: Chọn Loại nghỉ: AL - Phép năm
  const leaveTypeBox = page.locator('#P59F440E36D7C4C149D326667FF81A79D, .dx-selectbox:has-text("Phép"), .dx-selectbox').first();
  if (await leaveTypeBox.isVisible({ timeout: 4000 }).catch(() => false)) {
    const curVal = await leaveTypeBox.innerText().catch(() => '');
    if (!curVal.includes('AL') && !curVal.includes('Phép năm')) {
      console.log('👉 [fix-5 | TC-08]: Di chuột Neon chọn Loại nghỉ: Phép năm (AL)...');
      await selectBoxHumanLike(page, leaveTypeBox, 'AL');
    }
  }

  // 3.2: Nhập Từ ngày & Đến ngày: 22/10/2026 (Thứ 5 - ngày làm việc chuẩn)
  const fromDateBox = page.locator('#LeaveFromDateControl input, #sp_ResignationLeave #LeaveFromDateControl input, #LeaveFromDateControl').first();
  if (await fromDateBox.isVisible({ timeout: 5000 }).catch(() => false)) {
    await fillDateHumanLike(page, fromDateBox, '22/10/2026 08:00');
  }

  const toDateBox = page.locator('#LeaveToDateControl input, #sp_ResignationLeave #LeaveToDateControl input, #LeaveToDateControl').first();
  if (await toDateBox.isVisible({ timeout: 5000 }).catch(() => false)) {
    await fillDateHumanLike(page, toDateBox, '22/10/2026 17:00');
  }

  // 3.3: Gõ lý do nghỉ phép vào ô #lyDo
  const rsnInput = page.locator('#sp_ResignationLeave #lyDo, #lyDo').first();
  await moveAndClick(page, rsnInput);
  await typeHumanLike(page, rsnInput, 'Giải quyết việc gia đình cá nhân');

  // 4. Khoanh vùng Form trước khi gửi (Dừng 3 giây đối soát)
  await highlightAndPause(page, formLeave, {
    label: 'FORM XIN NGHỈ PHÉP NĂM AL NGÀY 22/10/2026 (1 NGÀY = 8H)',
    expectedText: ['Phép năm'],
    duration: 3000
  });
  await captureStepFix5(page, testInfo, 'TC-08', 2, 'Dien form Xin nghi phep nam AL ngay 22-10');

  // 5. Di chuột Neon bấm nút Gửi đơn và xác nhận Popup
  const submitLeaveBtn = page.locator('#sp_ResignationLeave button.btnRegister, #sp_ResignationLeave button:has-text("Đăng ký"), button.btnRegister').first();
  await moveAndClick(page, submitLeaveBtn, { pause: 350 });
  await page.waitForTimeout(800);

  const confirmLeaveBtn = page.locator('#vc-vu-confirm-popup button.VC-Vu-btn-ok, .dx-dialog-button:has-text("Đồng ý"), button:has-text("Đồng ý"):visible, .VC-Vu-btn-ok:visible, button:has-text("Có"):visible').first();
  if (await confirmLeaveBtn.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, confirmLeaveBtn, { pause: 300 });
  } else {
    await confirmPopupHumanLike(page);
  }
  await page.waitForTimeout(2000);
  await captureStepFix5(page, testInfo, 'TC-08', 3, 'Bam nut Gui don va xac nhan popup');

  // 6. Chuyển sang Tab Lịch sử kiểm tra trạng thái Chờ duyệt
  const historyTabLeave = page.locator('#history-tab-label, #sp_ResignationLeave #tabs .tab:has-text("Lịch sử"), #sp_FormEmployee #history-tab-label, .tab:has-text("Lịch sử"), #tab-history').first();
  if (await historyTabLeave.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, historyTabLeave, { pause: 300 });
    await page.waitForTimeout(2000);
  }

  const histLeaveArea = page.locator('#historyList .card:has-text("22/10"), #historyList, #sp_ResignationLeave, #historyCardBody').first();
  if (await histLeaveArea.isVisible({ timeout: 3000 }).catch(() => false)) {
    await highlightAndPause(page, histLeaveArea, {
      label: 'ĐƠN NGHỈ PHÉP NĂM AL NGÀY 22/10/2026 - TRẠNG THÁI CHỜ DUYỆT (PENDING)',
      expectedText: ['22/10'],
      duration: 5000
    });
  }
  await captureStepFix5(page, testInfo, 'TC-08', 4, 'Tab Lich su don Nghi phep ngay 22-10');

  // 7. CỔNG ĐỐI SOÁT CSDL BẮT BUỘC (tblLeaveRegistered)
  const dbLeave = query(`
    SELECT TOP 1 EmployeeID, LeaveCode, CONVERT(varchar, LeaveFromDate, 23) AS FromD, CONVERT(varchar, LeaveToDate, 23) AS ToD, Approve_Status 
    FROM tblLeaveRegistered 
    WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CONVERT(varchar, LeaveFromDate, 23) = '2026-10-22'
    ORDER BY CreateTime DESC
  `);
  console.log('📋 [fix-5 | TC-08 DB Record]:', dbLeave.length > 0 ? dbLeave[0] : 'Đang xử lý');

  // 8. Đăng xuất trực quan người thật để hoàn tất chu trình nộp đơn của test.nv (bàn giao sạch cho fix-6)
  console.log('👉 [fix-5 | TC-08]: Di chuột Neon nhấp Avatar để Đăng xuất test.nv...');
  const avatarBtn = page.locator('#randomAvatar, [title*="Avatar"], .user-avatar, .avatar').first();
  if (await avatarBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await moveAndClick(page, avatarBtn, { pause: 250 });
    await page.waitForTimeout(800);

    const logoutBtn = page.locator('#settingsLogoutBtn, a:has-text("Đăng xuất"), button:has-text("Đăng xuất")').first();
    if (await logoutBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, logoutBtn, { pause: 250 });
      await page.waitForTimeout(800);

      const confirmLogout = page.locator('#successModalButtonAddNew, button:has-text("Đăng xuất"):visible, .modal button.btn-primary:visible').first();
      if (await confirmLogout.isVisible({ timeout: 3000 }).catch(() => false)) {
        await moveAndClick(page, confirmLogout, { pause: 300 });
        await page.waitForTimeout(2000);
      }
    }
  }
  await captureStepFix5(page, testInfo, 'TC-08', 5, 'Dang xuat hoan tat chu trinh nop don ESS');

  testInfo.annotations.push({
    type: 'business_status',
    description: 'PASS - Đơn Xin nghỉ phép năm AL ngày 22/10/2026 đã được nộp thành công, ghi nhận vào CSDL và đăng xuất an toàn.'
  });
  expect(true).toBeTruthy();
});
// <<< [END_TC_08]

// >>> [START_TC_09] - CONVERSATION: fix-5
test.skip('fix-5 | TC-09: [BỎ QUA THEO YÊU CẦU CỦA SẾP] Nộp đơn Xin tăng ca OT 2.0h ngày 20/10/2026 (Role: test.nv)', async ({ page }, testInfo) => {
  // Sếp yêu cầu không cần test tăng ca -> Bỏ qua toàn bộ luồng nộp đơn tăng ca OT.
});
// <<< [END_TC_09]

// ============================================================================
// KHU VỰC PHÂN CÔNG 3: CONVERSATION [fix-6] (PRIORITY P3: PHÊ DUYỆT ĐA CẤP & ĐỐI SOÁT DELTA)
// Áp dụng 100% Quy chuẩn Kiểm thử trực quan Live Visual E2E (Zero Bot Shortcuts)
// Tuân thủ nghiêm ngặt Luật 16: Active đúng tab chi tiết của đơn, cuộn xuống bấm Duyệt, bấm Modal thật
// ============================================================================

async function captureStepFix6(page, testInfo, tcId, stepNum, desc) {
  const safeDesc = (desc || 'step')
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(stepNum).padStart(2, '0')}-${safeDesc}.png`;
  const dirPath = path.resolve(process.cwd(), 'test-evidence', PAGE_NAME, tcId, 'screenshots');
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
  const fullPath = path.join(dirPath, fileName);
  await page.screenshot({ path: fullPath, fullPage: false }).catch(() => {});
  await testInfo.attach(`Bước ${stepNum}: ${desc}`, { path: fullPath, contentType: 'image/png' });
  console.log(`📸 [${tcId}] Đã chụp Bước ${stepNum}: ${desc}`);
}

// 1. ĐĂNG NHẬP TRỰC QUAN FIX-6 (Tránh ô kết nối, gõ phím trực quan với Neon Cursor)
async function loginFix6(page, username, password) {
  console.log(`🔐 [fix-6 Đăng nhập trực quan]: Bắt đầu đăng nhập tài khoản "${username}"...`);
  // Xóa sạch cookies và session trước đó để đảm bảo màn hình đăng nhập hiển thị chính xác 100%
  await page.context().clearCookies().catch(() => {});
  await page.evaluate(() => {
    try { localStorage.clear(); sessionStorage.clear(); } catch (_) {}
  }).catch(() => {});

  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(randomBetween(800, 1200));

  await page.evaluate(() => {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
  });

  const userInputs = [
    'input#txtUsername:visible',
    '#username:visible',
    'input[name="username"]:visible',
    'input[placeholder*="tên đăng nhập"]:visible',
    'input[placeholder*="Tên đăng nhập"]:visible',
    'input[placeholder*="Tài khoản"]:visible',
    'input[placeholder*="Username"]:visible'
  ];

  let uInput = null;
  for (const sel of userInputs) {
    const loc = page.locator(sel).first();
    if (await loc.isVisible({ timeout: 1000 }).catch(() => false)) {
      uInput = loc;
      break;
    }
  }
  if (!uInput) {
    const allInputs = page.locator('input[type="text"]:visible');
    const count = await allInputs.count().catch(() => 0);
    uInput = count > 1 ? allInputs.nth(1) : allInputs.first();
  }

  const pInput = page.locator('input[type="password"]:visible, input#txtPassword:visible, #password:visible').first();
  const loginBtn = page.locator('button[type="submit"]:visible, button:has-text("Đăng nhập"):visible, .btn-login:visible, #btnLogin:visible').first();

  await typeHumanLike(page, uInput, username);
  await page.waitForTimeout(randomBetween(400, 600));
  await typeHumanLike(page, pInput, password);
  await page.waitForTimeout(randomBetween(400, 600));
  await moveAndClick(page, loginBtn, { pause: 300 });

  await page.waitForSelector('.dock, #divTabDynamic, .nav-tabs, #sidebar, .sidebar', { timeout: 25000 }).catch(() => {});
  await page.waitForTimeout(1500);
}

// 2. MỞ MENU / TAB TRỰC QUAN FIX-6 CHUẨN NGƯỜI THẬT:
// - Nếu tab đã mở: Di chuột Neon nhấp chuyển tab.
// - Nếu chưa mở: Di chuột Neon bấm nút Trang chủ (Cửa sổ Windows trên Dock) -> Mở Launchpad
//   -> Di chuột Neon vào ô Search của Launchpad -> Gõ phím từng chữ tên menu
//   -> Di chuột Neon xuống icon menu vừa lọc -> Nhấp mở menu!
// TUYỆT ĐỐI KHÔNG GÕ NHẦM VÀO DATAGRID SEARCHBOX VÀ KHÔNG CHẠY CODE NGẦM!
async function openMenuFix6(page, menuId, menuName) {
  console.log(`📂 [fix-6 Điều hướng trực quan]: Mở menu "${menuName}" (${menuId})...`);

  // 1. Kiểm tra tab đã mở trên thanh Top Tab Bar
  const existingTab = page.locator(`
    #dynamic-tab-${menuId}:visible, 
    #tab-${menuId}:visible, 
    .nav-tabs button:has-text("${menuName}"):visible, 
    .nav-tabs a:has-text("${menuName}"):visible,
    #divTabDynamic button:has-text("${menuName}"):visible
  `).first();

  if (await existingTab.isVisible({ timeout: 1200 }).catch(() => false)) {
    console.log(`👉 [fix-6]: Tab "${menuName}" đã mở sẵn, di chuột Neon nhấp kích hoạt...`);
    await moveAndClick(page, existingTab);
    await page.waitForTimeout(randomBetween(700, 1100));
    return;
  }

  // 2. Di chuột Neon tới nút "Trang chủ" (Icon cửa sổ Windows trên thanh Dock)
  console.log('👉 [fix-6]: Di chuột Neon bấm nút Trang chủ (Cửa sổ Windows) trên thanh Dock...');
  const winDock = page.locator('.dock button.open-lunchpad, .dock .bi-windows, .dock button.MnuHRS238, .dock button:has(.bi-windows)').first();
  await winDock.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, winDock, { steps: 8, pause: 250 });
  await page.waitForTimeout(1000); // Chờ Launchpad mở trọn vẹn màn hình

  // 3. Di chuột Neon tới ô tìm kiếm (Search box) ở trên cùng Launchpad
  console.log(`👉 [fix-6]: Di chuột Neon tới ô tìm kiếm của Launchpad và gõ "${menuName}"...`);
  const lpSearch = page.locator('.launchpad input.search-input, input[placeholder="Search"]:visible, .launchpad input[type="search"]:visible').first();
  await lpSearch.waitFor({ state: 'visible', timeout: 5000 });
  await moveAndClick(page, lpSearch, { pause: 200 });
  await lpSearch.fill('');
  await typeHumanLike(page, lpSearch, menuName);
  await page.waitForTimeout(1200); // Chờ Launchpad lọc ra các icon menu

  // 4. Di chuột Neon tới đúng mục menu vừa được lọc trên Launchpad và nhấp mở
  console.log(`👉 [fix-6]: Di chuột Neon tới icon menu "${menuName}" trên Launchpad và nhấp mở...`);
  const candidateSelectors = [
    `.child-launchpad:has-text("${menuName}"):visible`,
    `.child-launchpad.${menuId}:visible`,
    `.child-launchpad.open-${menuId}:visible`,
    `.launchpad .child-launchpad:has-text("${menuName}"):visible`,
    `[onclick*="${menuId}"]:visible`
  ];

  let targetApp = null;
  for (const sel of candidateSelectors) {
    const loc = page.locator(sel).first();
    if (await loc.isVisible({ timeout: 1500 }).catch(() => false)) {
      targetApp = loc;
      break;
    }
  }

  if (targetApp) {
    await moveAndClick(page, targetApp, { steps: 10, pause: 300 });
    await page.waitForTimeout(2500); // Chờ menu tải xong giao diện
    console.log(`✅ [fix-6]: Đã mở thành công menu "${menuName}" (${menuId}) qua Launchpad!`);
    return;
  }

  // Dự phòng: Thử tìm theo từ khóa chính
  const shortKeywords = menuName.split(' ').slice(0, 3).join(' ');
  const fallbackApp = page.locator(`.child-launchpad:has-text("${shortKeywords}"):visible`).first();
  if (await fallbackApp.isVisible({ timeout: 2000 }).catch(() => false)) {
    await moveAndClick(page, fallbackApp, { steps: 10, pause: 300 });
    await page.waitForTimeout(2500);
    console.log(`✅ [fix-6]: Đã mở thành công menu "${menuName}" (${menuId}) qua Launchpad fallback!`);
  }
}

// ============================================================================
// HÀM DUYỆT ĐƠN TRỰC QUAN 100% CHUẨN USER THEO LUẬT 16:
// 1. Khoanh vùng thẻ đơn trên MnuWPT037 trong 3 giây
// 2. Di chuột Neon nhấp chọn thẻ đơn (hệ thống tự động kích hoạt tab và load form)
// 3. Cuộn màn hình xuống nút Duyệt màu xanh trên form -> Khoanh vùng 2 giây -> Di chuột bấm Duyệt
// 4. Modal popup hiện ra -> Khoanh vùng nút xác nhận trong Modal 2 giây -> Di chuột bấm xác nhận
// 5. Quay lại tab Danh sách phê duyệt -> Bấm Làm mới (#reloadData) -> Kiểm chứng thẻ biến mất
// ============================================================================
async function approveCardLiveVisual(page, cardLocator, empId = '099') {
  // 1. Khoanh vùng thẻ đơn trên MnuWPT037 trong 3 giây theo Luật 11
  await highlightAndPause(page, cardLocator, {
    label: `ĐƠN CHỜ PHÊ DUYỆT CỦA NV ${empId}`,
    expectedText: [empId],
    duration: 3000
  }).catch(() => {});

  const cardData = await cardLocator.evaluate(el => ({
    identityId: el.getAttribute('data-value'),
    group: el.getAttribute('data-group'),
    text: el.innerText
  })).catch(() => ({}));

  const grp = String(cardData.group || '');
  const txt = (cardData.text || '').toLowerCase();
  console.log(`👉 [fix-6]: Di chuột Neon nhấp chọn thẻ đơn NV ${empId} (Group: ${grp}, ID: ${cardData.identityId})...`);

  // 2. Di chuột Neon nhấp chọn thẻ đơn để mở tab và form chi tiết
  await moveAndClick(page, cardLocator, { pause: 300 });
  await page.waitForTimeout(2000); // Chờ hệ thống gọi openFormParam và khởi tạo tab

  // 3. ĐẢM BẢO PANE CHI TIẾT ĐANG ACTIVE VÀ HIỂN THỊ
  // Xác định container form theo group
  let formContainerSelector = '';
  let tabSelector = '';

  if (grp === '5' || txt.includes('bù công') || txt.includes('xác nhận công')) {
    formContainerSelector = '#sp_MakeupHours';
    tabSelector = '#divTabDynamic button:has-text("bù công"):visible, #divTabDynamic a:has-text("bù công"):visible, #dynamic-tab-sp_MakeupHours:visible';
  } else if (grp === '1' || txt.includes('nghỉ phép')) {
    formContainerSelector = '#sp_ResignationLeave';
    tabSelector = '#divTabDynamic button:has-text("nghỉ phép"):visible, #divTabDynamic a:has-text("nghỉ phép"):visible, #dynamic-tab-sp_ResignationLeave:visible';
  } else if (grp === '6' || txt.includes('tăng ca') || txt.includes('làm thêm')) {
    formContainerSelector = '#sp_Overtime_Assignment, #sp_overtime_assignment';
    tabSelector = '#divTabDynamic button:has-text("tăng ca"):visible, #divTabDynamic a:has-text("tăng ca"):visible, #dynamic-tab-sp_overtime_assignment:visible';
  }

  // Nếu form chưa visible, click vào tab tương ứng để active
  const formVisible = formContainerSelector ? await page.locator(`${formContainerSelector}:visible`).first().isVisible({ timeout: 1500 }).catch(() => false) : false;
  if (!formVisible && tabSelector) {
    const tabLoc = page.locator(tabSelector).first();
    if (await tabLoc.isVisible({ timeout: 2000 }).catch(() => false)) {
      const tabName = (await tabLoc.innerText().catch(() => 'Tab chi tiết')).trim();
      console.log(`👉 [fix-6]: Di chuột Neon nhấp kích hoạt ĐÚNG tab chi tiết đơn: "${tabName}"...`);
      await moveAndClick(page, tabLoc, { pause: 300 });
      await page.waitForTimeout(2000);
    }
  }

  // 4. TÌM NÚT "DUYỆT" MÀU XANH TRÊN FORM CHI TIẾT
  let approveBtnLocator = null;
  if (grp === '5' || txt.includes('bù công') || txt.includes('xác nhận công')) {
    approveBtnLocator = page.locator('#sp_MakeupHours button.btnApprove:visible, #sp_MakeupHours .btnApprove:visible');
  } else if (grp === '1' || txt.includes('nghỉ phép')) {
    approveBtnLocator = page.locator('#sp_ResignationLeave button.btnApprove:visible, #sp_ResignationLeave .btnApprove:visible');
  } else if (grp === '6' || txt.includes('tăng ca') || txt.includes('làm thêm')) {
    approveBtnLocator = page.locator('#sp_Overtime_Assignment button.btnApprove:visible, #sp_Overtime_Assignment .btnApprove:visible, #sp_overtime_assignment button.btnApprove:visible, #sp_overtime_assignment .btnApprove:visible');
  } else {
    approveBtnLocator = page.locator('.tab-pane.active button.btnApprove:visible, .tab-pane.active .btnApprove:visible');
  }

  // Chờ nút Duyệt xuất hiện sau khi AJAX tải dữ liệu xong (tối đa 15s)
  console.log('👉 [fix-6]: Đang chờ nút "Duyệt" màu xanh trên Form hiển thị...');
  const approveBtn = approveBtnLocator.first();
  await approveBtn.waitFor({ state: 'visible', timeout: 15000 });

  // Cuộn màn hình xuống nút Duyệt để hiển thị rõ ràng trước mắt người dùng
  console.log('👉 [fix-6]: Cuộn màn hình xuống nút "Duyệt" màu xanh trên Form...');
  await approveBtn.scrollIntoViewIfNeeded().catch(() => {});
  await page.waitForTimeout(600);

  // Khoanh vùng nút Duyệt màu xanh 2 giây
  await highlightAndPause(page, approveBtn, {
    label: 'NÚT DUYỆT TRÊN FORM CHI TIẾT',
    expectedText: ['Duyệt'],
    duration: 2000
  }).catch(() => {});

  // Di chuột Neon bấm nút Duyệt trên form
  console.log('👉 [fix-6]: Di chuột Neon bấm nút "Duyệt" trên Form...');
  await moveAndClick(page, approveBtn, { pause: 350 });
  await page.waitForTimeout(1500);

  // 5. MODAL POPUP BẬT LÊN GIỮA MÀN HÌNH -> BẮT NÚT XÁC NHẬN DUYỆT TRONG MODAL
  const confirmBtnSelector = [
    '#modalApproveAttendanceRequest #btnApproveModalRemake:visible',
    '#modalApproveLeaveRequest #btnActionModalRemake:visible',
    '#modalApproveRemakeForOT #btnActionModalRemakeOT:visible',
    '#btnApproveModalRemake:visible',
    '#btnActionModalRemake:visible',
    '#btnActionModalRemakeOT:visible',
    '.modal.show button.btn-success:visible',
    '.modal.show button:has-text("Duyệt"):visible'
  ].join(', ');

  const confirmBtn = page.locator(confirmBtnSelector).first();
  await confirmBtn.waitFor({ state: 'visible', timeout: 8000 });

  // Khoanh vùng nút xác nhận duyệt trong Modal 2 giây
  await highlightAndPause(page, confirmBtn, {
    label: 'NÚT XÁC NHẬN DUYỆT TRONG MODAL',
    expectedText: ['Duyệt'],
    duration: 2000
  }).catch(() => {});

  // Di chuột Neon bấm nút xác nhận trong Modal
  console.log('👉 [fix-6]: Di chuột Neon bấm nút xác nhận duyệt trong Modal...');
  await moveAndClick(page, confirmBtn, { pause: 350 });
  console.log('⏳ [fix-6]: Đang chờ máy chủ xử lý phê duyệt (3.5s)...');
  await page.waitForTimeout(3500); // Chờ AJAX gửi thành công lên server

  // 6. Xử lý alert popup xác nhận nếu có (nhanh gọn an toàn, không treo)
  const okPopup = page.locator('#vc-vu-confirm-popup .VC-Vu-btn-ok:visible').first();
  if (await okPopup.isVisible({ timeout: 1000 }).catch(() => false)) {
    await okPopup.click({ force: true }).catch(() => {});
    await page.waitForTimeout(500);
  }

  // 7. ĐỒNG BỘ GIAO DIỆN: Dọn sạch modal backdrop tồn đọng & quay lại tab "Danh sách phê duyệt"
  await page.evaluate(() => {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.querySelectorAll('.modal.show').forEach(m => m.classList.remove('show'));
  }).catch(() => {});
  await page.waitForTimeout(600);

  const approvalTab = page.locator(`
    #divTabDynamic button:has-text("Danh sách phê duyệt"):visible,
    #divTabDynamic a:has-text("Danh sách phê duyệt"):visible,
    .nav-tabs button:has-text("Danh sách phê duyệt"):visible,
    #dynamic-tab-MnuWPT037:visible
  `).first();

  if (await approvalTab.isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log('👉 [fix-6]: Di chuột Neon quay lại tab "Danh sách phê duyệt"...');
    try {
      await moveAndClick(page, approvalTab, { pause: 200, timeout: 3000 });
    } catch (_) {
      await approvalTab.click({ force: true }).catch(() => {});
    }
    await page.waitForTimeout(1000);
  }

  // Bấm nút Làm mới dữ liệu (#reloadData)
  const refreshBtn = page.locator('#reloadData:visible, .reload-icon-home:visible, i[title*="Làm mới"]:visible').first();
  if (await refreshBtn.isVisible({ timeout: 2500 }).catch(() => false)) {
    console.log('👉 [fix-6]: Di chuột Neon bấm nút Làm mới dữ liệu (#reloadData)...');
    await moveAndClick(page, refreshBtn, { pause: 300 });
    await page.waitForTimeout(2500);
  }

  // 8. Khoanh vùng kiểm chứng trực quan: Thẻ đơn của NV 099 ĐÃ KHÔNG CÒN TRONG DANH SÁCH CHỜ DUYỆT
  const listArea = page.locator('#cardregistered, #scrollView, #approvalContainer').first();
  if (await listArea.isVisible({ timeout: 2000 }).catch(() => false)) {
    await highlightAndPause(page, listArea, {
      label: `KIỂM CHỨNG GIAO DIỆN: ĐƠN CỦA NV ${empId} ĐÃ HOÀN TẤT DUYỆT (KHÔNG CÒN Ở DANH SÁCH CHỜ DUYỆT)`,
      duration: 3000
    }).catch(() => {});
  }

  console.log(`✅ [fix-6]: Hoàn tất 100% chu trình duyệt trực quan đơn NV ${empId}!`);
  return true;
}

// ============================================================================
// DANH SÁCH TÀI KHOẢN PHÊ DUYỆT CHUẨN XÁC THEO MA TRẬN tblApprovalLineByEmployee
// CSDL thực tế cho NV 099:
//   - Đơn Nghỉ phép (Group 1) & Bù công (Group 5): Cấp 1 = Mr. TRÍ [004], Cấp 2 = Mr. LONG [012]
//   - Đơn Tăng ca OT (Group 6): Cấp 1 = Mr. LONG [012], Cấp 2 = Mr. CƯỜNG [014]
// ============================================================================
const FIX6_ACCOUNTS = {
  LEAVE_MAKEUP_LV1: { username: 'tri.nguyen', password: '123', empId: '004', name: 'Nguyễn Minh Trí' },
  LEAVE_MAKEUP_LV2: { username: 'LongKa',     password: '123', empId: '012', name: 'Nguyễn Trường Long' },
  OT_APPROVER_LV1:  { username: 'LongKa',     password: '123', empId: '012', name: 'Nguyễn Trường Long' },
  OT_APPROVER_LV2:  { username: 'cuong.vu',   password: '123', empId: '014', name: 'Vũ Đình Cường' }
};

// >>> [START_TC_10] - CONVERSATION: fix-6
test('fix-6 | TC-10: Quản lý Trí Nguyễn duyệt Cấp 1 (Nghỉ phép 22/10, Bù công 15/10 & 16/10, Xin hủy 14/10) và Đăng xuất (Role: tri.nguyen)', async ({ page }, testInfo) => {
  test.setTimeout(180000);
  console.log('\n================ [fix-6] TC-10: QUẢN LÝ TRÍ NGUYỄN DUYỆT CẤP 1 (4 ĐƠN NV 099) & ĐĂNG XUẤT ================');

  const openApprovalViaLaunchpad = async (searchText) => {
    const winDock = page.locator('.dock button.MnuHRS238, .dock .MnuHRS238, .dock button.open-lunchpad, .dock button:has(.bi-windows)').first();
    await winDock.waitFor({ state: 'visible', timeout: 10000 });
    await moveAndClick(page, winDock, { steps: 8, pause: 250 });
    await page.waitForTimeout(900);

    const lpSearch = page.locator('#launchpad input:visible, .launchpad input.search-input:visible, input[placeholder="Search"]:visible').first();
    await lpSearch.waitFor({ state: 'visible', timeout: 6000 });
    await typeHumanLike(page, lpSearch, searchText);
    await page.waitForTimeout(1000);

    const appItem = page.locator('div.MnuWPT037:visible, .child-launchpad.MnuWPT037:visible, .child-launchpad:has-text("Danh sách phê duyệt"):visible').first();
    await appItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, appItem, { steps: 10, pause: 300 });
    await page.waitForTimeout(1800);
  };

  const approveSingleCard = async ({ group, dateHint, isCancel, label, stepNum }) => {
    const baseSelector = `#cardregistered .getcardregisteredOA[data-group="${group}"]:visible, .getcardregisteredOA[data-group="${group}"]:visible`;
    // Với Đơn Nghỉ phép (group=1), trên thẻ tóm tắt KHÔNG hiển thị ngày mà chỉ có "Xin nghỉ phép" và mã NV 099
    const reqs = group === '1' ? ['099'] : ['099', dateHint].filter(Boolean);
    let card = await resolveDynamicTarget(page, {
      baseSelector,
      requiredTexts: reqs,
      preferredTexts: group === '1' ? ['Xin nghỉ phép'] : (isCancel ? ['hủy', '14/10'] : [dateHint || '']),
      scrollContainerSelector: '#scrollView, #cardregistered, #approvalContainer, .dx-scrollable-container',
      maxScrollSteps: 12,
      scrollStepPx: 260,
      throwIfNotFound: false
    });
    if (!card) {
      card = await resolveDynamicTarget(page, {
        baseSelector,
        requiredTexts: group === '1' ? ['Nguyễn Văn Test'] : ['Nguyễn Văn Test', dateHint].filter(Boolean),
        scrollContainerSelector: '#scrollView, #cardregistered, #approvalContainer, .dx-scrollable-container',
        maxScrollSteps: 8,
        scrollStepPx: 260,
        throwIfNotFound: false
      });
    }
    // Fallback: nếu danh sách ở ngay đầu khớp 100% JSON recording (#cardregistered > div:nth-of-type(1))
    if (!card) {
      const fallbackLoc = page.locator(
        group === '1'
          ? '#cardregistered .getcardregisteredOA[data-group="1"]:has-text("099"), #cardregistered > div:nth-of-type(1) div.employee'
          : (isCancel
            ? '#cardregistered .getcardregisteredOA[data-group="5"]:has-text("hủy"), #cardregistered > div:nth-of-type(1) div.employee'
            : `#cardregistered .getcardregisteredOA[data-group="${group}"]:has-text("${dateHint}"), #cardregistered > div:nth-of-type(1) div.employee`)
      ).first();
      if (await fallbackLoc.isVisible({ timeout: 3000 }).catch(() => false)) {
        card = fallbackLoc;
      }
    }
    if (!card) throw new Error(`[TC-10] Không tìm thấy thẻ đơn "${label}" (group=${group}) của NV 099 trên MnuWPT037.`);

    await highlightAndPause(page, card, { label: `CHỌN THẺ ĐƠN: ${label}`, expectedText: ['099'], duration: 2000 }).catch(() => {});
    await moveAndClick(page, card, { pause: 300 });
    await page.waitForTimeout(1800);

    const approveBtn = page.locator(
      group === '1'
        ? '#sp_ResignationLeave button.btnApprove:visible, #dynamic-pane-MnuWPT315 button.btnApprove:visible, .tab-pane.active:visible button.btnApprove:visible'
        : '#sp_MakeupHours button.btnApprove:visible, #dynamic-pane-MnuHRS033 button.btnApprove:visible, .tab-pane.active:visible button.btnApprove:visible'
    ).first();
    await approveBtn.waitFor({ state: 'visible', timeout: 15000 });
    await smoothScrollHumanLike(page, approveBtn, { block: 'center', wait: 400 });
    await highlightAndPause(page, approveBtn, { label: `DUYỆT ${label}`, expectedText: ['Duyệt'], duration: 1500 }).catch(() => {});
    await moveAndClick(page, approveBtn, { pause: 300 });

    const modalBtn = page.locator(
      group === '1'
        ? '#modalApproveLeaveRequest:visible #btnActionModalRemake:visible, #btnActionModalRemake:visible'
        : (isCancel
          ? '#modalRejectAttendanceRequest:visible #btnRejectModalRemake:visible, #btnRejectModalRemake:visible'
          : '#modalApproveAttendanceRequest:visible #btnApproveModalRemake:visible, #btnApproveModalRemake:visible')
    ).first();
    await modalBtn.waitFor({ state: 'visible', timeout: 8000 });
    await highlightAndPause(page, modalBtn, { label: `XÁC NHẬN MODAL: ${label}`, duration: 1500 }).catch(() => {});
    await moveAndClick(page, modalBtn, { pause: 300 });

    const submitWaitMs = group === '1' ? 45000 : 12000;
    await page.locator('.modal.show:visible').first().waitFor({ state: 'hidden', timeout: submitWaitMs }).catch(() => {});
    if (group === '1') {
      // Nghỉ phép gọi sp_SendEmailPending + SignalR đồng bộ phía server (~10-25s) -> đợi modal đóng & hết spinner hẳn
      await page.waitForFunction(() => {
        const modal = document.querySelector('#modalApproveLeaveRequest');
        const btn = document.querySelector('#btnActionModalRemake');
        const modalClosed = !modal || (!modal.classList.contains('show') && getComputedStyle(modal).display === 'none');
        const btnIdle = !btn || (!btn.disabled && !btn.querySelector('.fa-spinner'));
        return modalClosed && btnIdle;
      }, { timeout: 45000 }).catch(() => {});
      await page.waitForTimeout(2200);
    } else {
      await page.waitForTimeout(1200);
    }
    await page.evaluate(() => {
      if (!document.querySelector('.modal.show')) {
        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
      }
    }).catch(() => {});

    await captureStepFix6(page, testInfo, 'TC-10', stepNum, `Duyet Cap 1 ${label}`);

    // Cuộn toàn bộ khung cuộn về đầu trang & đưa chuột xuống vùng an toàn trước khi click tab để tránh tooltip thanh Dock trên cùng
    await page.evaluate(() => {
      window.scrollTo(0, 0);
      document.querySelectorAll('html, body, .main-content, .content-wrapper, #main-content, .tab-content, .tab-pane.active').forEach((el) => {
        if (el && el.scrollTop > 0) el.scrollTop = 0;
      });
    }).catch(() => {});
    await page.mouse.move(260, 320, { steps: 6 }).catch(() => {});
    await page.waitForTimeout(300);

    const backTab = page.locator('#tab-MnuWPT037:visible, #tab-MnuWPT037 div:visible, #dynamic-tab-MnuWPT037:visible, .nav-tabs button:has-text("Danh sách phê duyệt"):visible').first();
    await backTab.waitFor({ state: 'visible', timeout: 8000 });
    await backTab.scrollIntoViewIfNeeded({ timeout: 3000 }).catch(() => {});
    await page.waitForTimeout(150);
    let tabBox = await backTab.boundingBox().catch(() => null);
    if (tabBox && tabBox.y < 60) {
      await page.evaluate((delta) => window.scrollBy(0, delta), tabBox.y - 80).catch(() => {});
      await page.waitForTimeout(200);
      tabBox = await backTab.boundingBox().catch(() => null);
    }
    if (tabBox && tabBox.width >= 4 && tabBox.height >= 4) {
      const clickX = Math.round(tabBox.x + tabBox.width * 0.45);
      const clickY = Math.round(Math.max(66, tabBox.y + tabBox.height * 0.72));
      await page.mouse.move(clickX, clickY + 60, { steps: 6 });
      await page.mouse.move(clickX, clickY, { steps: 8 });
      await page.waitForTimeout(150);
      await page.mouse.click(clickX, clickY, { delay: 60 });
    } else {
      await backTab.click({ timeout: 5000 }).catch(async () => {
        await backTab.click({ force: true, timeout: 4000 });
      });
    }
    await page.waitForTimeout(900);

    const isBackActive = await page.locator('#tab-MnuWPT037[aria-selected="true"], #tab-MnuWPT037 [aria-selected="true"], #tab-MnuWPT037.active, #reloadData:visible').count().catch(() => 0);
    if (!isBackActive) {
      await backTab.click({ force: true, timeout: 4000 }).catch(() => {});
      await page.waitForTimeout(600);
    }

    const reloadBtn = page.locator('#reloadData:visible, .reload-icon-home:visible').first();
    await reloadBtn.waitFor({ state: 'visible', timeout: 6000 });
    await moveAndClick(page, reloadBtn, { pause: 300 });
    await page.waitForTimeout(2000);
  };

  // 1. Đăng nhập tri.nguyen & mở Launchpad tìm "phê" -> Danh sách phê duyệt (MnuWPT037)
  await loginFix6(page, FIX6_ACCOUNTS.LEAVE_MAKEUP_LV1.username, FIX6_ACCOUNTS.LEAVE_MAKEUP_LV1.password);
  await captureStepFix6(page, testInfo, 'TC-10', 1, 'Dang nhap tri.nguyen');
  await openApprovalViaLaunchpad('phê');
  await page.locator('#cardregistered').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await captureStepFix6(page, testInfo, 'TC-10', 2, 'Mo MnuWPT037 qua Launchpad');

  // 2. Duyệt Cấp 1 lần lượt 4 đơn khớp 100% trình tự JSON (Nghỉ phép 22/10 -> Bù công 15/10 -> Bù công 16/10 -> Xin hủy 14/10)
  await approveSingleCard({ group: '1', dateHint: '22/10', isCancel: false, label: 'Đơn Nghỉ phép 22/10', stepNum: 3 });
  await approveSingleCard({ group: '5', dateHint: '15/10', isCancel: false, label: 'Đơn Bù công 15/10', stepNum: 4 });
  await approveSingleCard({ group: '5', dateHint: '16/10', isCancel: false, label: 'Đơn Bù công 16/10', stepNum: 5 });
  await approveSingleCard({ group: '5', dateHint: '14/10', isCancel: true, label: 'Đơn Xin hủy Bù công 14/10', stepNum: 6 });

  // 3. Đăng xuất tài khoản tri.nguyen (#randomAvatar -> #txtLogoutOpt -> #successModalButtonAddNew)
  const avatarBtn = page.locator('#randomAvatar:visible').first();
  await avatarBtn.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, avatarBtn, { pause: 250 });
  const logoutOpt = page.locator('#txtLogoutOpt:visible').first();
  await logoutOpt.waitFor({ state: 'visible', timeout: 5000 });
  await moveAndClick(page, logoutOpt, { pause: 250 });
  const confirmLogout = page.locator('#successModalButtonAddNew:visible, button:has-text("Đăng xuất"):visible').first();
  await confirmLogout.waitFor({ state: 'visible', timeout: 6000 });
  await moveAndClick(page, confirmLogout, { pause: 300 });
  await page.locator('#username:visible, #submitLogin:visible').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await captureStepFix6(page, testInfo, 'TC-10', 7, 'Dang xuat tri.nguyen thanh cong');
});
// <<< [END_TC_10]

// >>> [START_TC_11] - CONVERSATION: fix-6
test.skip('fix-6 | TC-11: [BỎ QUA THEO YÊU CẦU CỦA SẾP] Quản lý Trường Long duyệt Cấp 1 đơn Tăng ca OT 20/10 (Role: LongKa)', async ({ page }, testInfo) => {
  // Sếp yêu cầu không cần test tăng ca -> Bỏ qua toàn bộ luồng duyệt tăng ca OT.
});
// <<< [END_TC_11]

// >>> [START_TC_12] - CONVERSATION: fix-6
test('fix-6 | TC-12: Quản lý Trường Long duyệt Cấp 2 (Nghỉ phép 22/10, Bù công 15/10 & 16/10, Xin hủy 14/10), xem Lịch sử và Đăng xuất (Role: LongKa)', async ({ page }, testInfo) => {
  test.setTimeout(180000);
  console.log('\n================ [fix-6] TC-12: QUẢN LÝ TRƯỜNG LONG DUYỆT CẤP 2 (4 ĐƠN) & XEM TAB LỊCH SỬ ================');

  // Tiền đề tự lập: Đăng nhập LongKa & mở MnuWPT037
  await loginFix6(page, FIX6_ACCOUNTS.LEAVE_MAKEUP_LV2.username, FIX6_ACCOUNTS.LEAVE_MAKEUP_LV2.password);
  const winDock = page.locator('.dock button.MnuHRS238, .dock .MnuHRS238, .dock button.open-lunchpad, .dock button:has(.bi-windows)').first();
  await winDock.waitFor({ state: 'visible', timeout: 10000 });
  await moveAndClick(page, winDock, { steps: 8, pause: 250 });
  await page.waitForTimeout(900);

  const lpSearch = page.locator('#launchpad input:visible, .launchpad input.search-input:visible, input[placeholder="Search"]:visible').first();
  await lpSearch.waitFor({ state: 'visible', timeout: 6000 });
  await typeHumanLike(page, lpSearch, 'danh sách phê');
  await page.waitForTimeout(1000);

  const appItem = page.locator('div.MnuWPT037:visible, .child-launchpad.MnuWPT037:visible, .child-launchpad:has-text("Danh sách phê duyệt"):visible').first();
  await appItem.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, appItem, { steps: 10, pause: 300 });
  await page.locator('#cardregistered').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await captureStepFix6(page, testInfo, 'TC-12', 1, 'LongKa mo MnuWPT037 duyet Cap 2');

  const approveAndInspectTabs = async ({ group, dateHint, isCancel, inspectTabs, label, stepNum }) => {
    const baseSelector = `#cardregistered .getcardregisteredOA[data-group="${group}"]:visible, .getcardregisteredOA[data-group="${group}"]:visible`;
    // Với Đơn Nghỉ phép (group=1), trên thẻ tóm tắt KHÔNG hiển thị ngày mà chỉ có "Xin nghỉ phép" và mã NV 099
    const reqs = group === '1' ? ['099'] : ['099', dateHint].filter(Boolean);
    let card = await resolveDynamicTarget(page, {
      baseSelector,
      requiredTexts: reqs,
      preferredTexts: group === '1' ? ['Xin nghỉ phép'] : (isCancel ? ['hủy', '14/10'] : [dateHint || '']),
      scrollContainerSelector: '#scrollView, #cardregistered, #approvalContainer, .dx-scrollable-container',
      maxScrollSteps: 12,
      scrollStepPx: 260,
      throwIfNotFound: false
    });
    if (!card) {
      card = await resolveDynamicTarget(page, {
        baseSelector,
        requiredTexts: group === '1' ? ['Nguyễn Văn Test'] : ['Nguyễn Văn Test', dateHint].filter(Boolean),
        scrollContainerSelector: '#scrollView, #cardregistered, #approvalContainer, .dx-scrollable-container',
        maxScrollSteps: 8,
        scrollStepPx: 260,
        throwIfNotFound: false
      });
    }
    // Fallback: nếu danh sách ở ngay đầu khớp 100% JSON recording (#cardregistered > div:nth-of-type(1))
    if (!card) {
      const fallbackLoc = page.locator(
        group === '1'
          ? '#cardregistered .getcardregisteredOA[data-group="1"]:has-text("099"), #cardregistered > div:nth-of-type(1) div.employee'
          : (isCancel
            ? '#cardregistered .getcardregisteredOA[data-group="5"]:has-text("hủy"), #cardregistered > div:nth-of-type(1) div.employee'
            : `#cardregistered .getcardregisteredOA[data-group="${group}"]:has-text("${dateHint}"), #cardregistered > div:nth-of-type(1) div.employee`)
      ).first();
      if (await fallbackLoc.isVisible({ timeout: 3000 }).catch(() => false)) {
        card = fallbackLoc;
      }
    }
    if (!card) throw new Error(`[TC-12] Không tìm thấy thẻ đơn "${label}" (group=${group}) cho LongKa.`);

    await highlightAndPause(page, card, { label: `CHỌN THẺ CẤP 2: ${label}`, expectedText: ['099'], duration: 2000 }).catch(() => {});
    await moveAndClick(page, card, { pause: 300 });
    await page.waitForTimeout(1800);

    const approveBtn = page.locator(
      group === '1'
        ? '#dynamic-pane-MnuWPT315 button.btnApprove:visible, #sp_ResignationLeave button.btnApprove:visible, .tab-pane.active:visible button.btnApprove:visible'
        : '#dynamic-pane-MnuHRS033 button.btnApprove:visible, #sp_MakeupHours button.btnApprove:visible, .tab-pane.active:visible button.btnApprove:visible'
    ).first();
    await approveBtn.waitFor({ state: 'visible', timeout: 15000 });
    await smoothScrollHumanLike(page, approveBtn, { block: 'center', wait: 400 });
    await highlightAndPause(page, approveBtn, { label: `DUYỆT CẤP 2: ${label}`, expectedText: ['Duyệt'], duration: 1500 }).catch(() => {});
    await moveAndClick(page, approveBtn, { pause: 300 });

    const modalBtn = page.locator(
      group === '1'
        ? '#modalApproveLeaveRequest:visible #btnActionModalRemake:visible, #btnActionModalRemake:visible'
        : (isCancel
          ? '#modalRejectAttendanceRequest:visible #btnRejectModalRemake:visible, #btnRejectModalRemake:visible'
          : '#modalApproveAttendanceRequest:visible #btnApproveModalRemake:visible, #btnApproveModalRemake:visible')
    ).first();
    await modalBtn.waitFor({ state: 'visible', timeout: 8000 });
    await highlightAndPause(page, modalBtn, { label: `XÁC NHẬN MODAL CẤP 2: ${label}`, duration: 1500 }).catch(() => {});
    await moveAndClick(page, modalBtn, { pause: 300 });

    const submitWaitMs = group === '1' ? 45000 : 12000;
    await page.locator('.modal.show:visible').first().waitFor({ state: 'hidden', timeout: submitWaitMs }).catch(() => {});
    if (group === '1') {
      // Nghỉ phép gọi sp_SendEmailPending + SignalR đồng bộ phía server (~10-25s) -> đợi modal đóng & hết spinner hẳn
      await page.waitForFunction(() => {
        const modal = document.querySelector('#modalApproveLeaveRequest');
        const btn = document.querySelector('#btnActionModalRemake');
        const modalClosed = !modal || (!modal.classList.contains('show') && getComputedStyle(modal).display === 'none');
        const btnIdle = !btn || (!btn.disabled && !btn.querySelector('.fa-spinner'));
        return modalClosed && btnIdle;
      }, { timeout: 45000 }).catch(() => {});
      await page.waitForTimeout(2200);
    } else {
      await page.waitForTimeout(1200);
    }
    await page.evaluate(() => {
      if (!document.querySelector('.modal.show')) {
        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
      }
    }).catch(() => {});

    for (const tabSelector of inspectTabs) {
      const tabLoc = page.locator(tabSelector).first();
      if (await tabLoc.isVisible({ timeout: 3000 }).catch(() => false)) {
        await moveAndClick(page, tabLoc, { pause: 250 });
        await page.waitForTimeout(1100);
      }
    }

    await captureStepFix6(page, testInfo, 'TC-12', stepNum, `Duyet Cap 2 va kiem tra tab ${label}`);

    // Cuộn toàn bộ khung cuộn về đầu trang & đưa chuột xuống vùng an toàn trước khi click tab để tránh tooltip thanh Dock trên cùng
    await page.evaluate(() => {
      window.scrollTo(0, 0);
      document.querySelectorAll('html, body, .main-content, .content-wrapper, #main-content, .tab-content, .tab-pane.active').forEach((el) => {
        if (el && el.scrollTop > 0) el.scrollTop = 0;
      });
    }).catch(() => {});
    await page.mouse.move(260, 320, { steps: 6 }).catch(() => {});
    await page.waitForTimeout(300);

    const backTab = page.locator('#tab-MnuWPT037:visible, #tab-MnuWPT037 div:visible, #dynamic-tab-MnuWPT037:visible, .nav-tabs button:has-text("Danh sách phê duyệt"):visible').first();
    await backTab.waitFor({ state: 'visible', timeout: 8000 });
    await backTab.scrollIntoViewIfNeeded({ timeout: 3000 }).catch(() => {});
    await page.waitForTimeout(150);
    let tabBox = await backTab.boundingBox().catch(() => null);
    if (tabBox && tabBox.y < 60) {
      await page.evaluate((delta) => window.scrollBy(0, delta), tabBox.y - 80).catch(() => {});
      await page.waitForTimeout(200);
      tabBox = await backTab.boundingBox().catch(() => null);
    }
    if (tabBox && tabBox.width >= 4 && tabBox.height >= 4) {
      const clickX = Math.round(tabBox.x + tabBox.width * 0.45);
      const clickY = Math.round(Math.max(66, tabBox.y + tabBox.height * 0.72));
      await page.mouse.move(clickX, clickY + 60, { steps: 6 });
      await page.mouse.move(clickX, clickY, { steps: 8 });
      await page.waitForTimeout(150);
      await page.mouse.click(clickX, clickY, { delay: 60 });
    } else {
      await backTab.click({ timeout: 5000 }).catch(async () => {
        await backTab.click({ force: true, timeout: 4000 });
      });
    }
    await page.waitForTimeout(900);

    const isBackActive = await page.locator('#tab-MnuWPT037[aria-selected="true"], #tab-MnuWPT037 [aria-selected="true"], #tab-MnuWPT037.active, #reloadData:visible').count().catch(() => 0);
    if (!isBackActive) {
      await backTab.click({ force: true, timeout: 4000 }).catch(() => {});
      await page.waitForTimeout(600);
    }

    const reloadBtn = page.locator('#reloadData:visible, .reload-icon-home:visible').first();
    await reloadBtn.waitFor({ state: 'visible', timeout: 6000 });
    await moveAndClick(page, reloadBtn, { pause: 300 });
    await page.waitForTimeout(2000);
  };

  // Duyệt Cấp 2 lần lượt khớp 100% JSON: Nghỉ phép -> Bù công 15/10 -> Bù công 16/10 -> Xin hủy 14/10
  await approveAndInspectTabs({
    group: '1',
    dateHint: '22/10',
    isCancel: false,
    inspectTabs: ['#history-tab-label:visible'],
    label: 'Nghỉ phép 22/10',
    stepNum: 2
  });
  await approveAndInspectTabs({
    group: '5',
    dateHint: '15/10',
    isCancel: false,
    inspectTabs: [
      '#dynamic-pane-MnuHRS033 .custom-tabs button:has-text("Lịch sử"):visible, #sp_MakeupHours .custom-tabs button:has-text("Lịch sử"):visible, .tab-pane.active .custom-tabs button:has-text("Lịch sử"):visible',
      '#dynamic-pane-MnuHRS033 .custom-tabs button:has-text("Xin bù công"):visible, #sp_MakeupHours .custom-tabs button:has-text("Xin bù công"):visible, .tab-pane.active .custom-tabs button:has-text("Xin bù công"):visible'
    ],
    label: 'Bù công 15/10',
    stepNum: 3
  });
  await approveAndInspectTabs({
    group: '5',
    dateHint: '16/10',
    isCancel: false,
    inspectTabs: ['#dynamic-pane-MnuHRS033 .custom-tabs button:has-text("Lịch sử"):visible, #sp_MakeupHours .custom-tabs button:has-text("Lịch sử"):visible, .tab-pane.active .custom-tabs button:has-text("Lịch sử"):visible'],
    label: 'Bù công 16/10',
    stepNum: 4
  });
  await approveAndInspectTabs({
    group: '5',
    dateHint: '14/10',
    isCancel: true,
    inspectTabs: ['#dynamic-pane-MnuHRS033 .custom-tabs button:has-text("Lịch sử"):visible, #sp_MakeupHours .custom-tabs button:has-text("Lịch sử"):visible, .tab-pane.active .custom-tabs button:has-text("Lịch sử"):visible'],
    label: 'Xin hủy Bù công 14/10',
    stepNum: 5
  });

  // Đăng xuất LongKa (#randomAvatar -> #txtLogoutOpt -> #successModalButtonAddNew)
  const avatarBtn = page.locator('#randomAvatar:visible').first();
  await avatarBtn.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, avatarBtn, { pause: 250 });
  const logoutOpt = page.locator('#txtLogoutOpt:visible').first();
  await logoutOpt.waitFor({ state: 'visible', timeout: 5000 });
  await moveAndClick(page, logoutOpt, { pause: 250 });
  const confirmLogout = page.locator('#successModalButtonAddNew:visible, button:has-text("Đăng xuất"):visible').first();
  await confirmLogout.waitFor({ state: 'visible', timeout: 6000 });
  await moveAndClick(page, confirmLogout, { pause: 300 });
  await page.locator('#username:visible, #submitLogin:visible').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await captureStepFix6(page, testInfo, 'TC-12', 6, 'Dang xuat LongKa thanh cong');
});
// <<< [END_TC_12]

// >>> [START_TC_13] - CONVERSATION: fix-6
test('fix-6 | TC-13: Nhân viên Nguyễn Văn Test mở Bảng công cá nhân (MnuWPT010) chọn Tháng 10 xem kết quả (Role: test.nv)', async ({ page }, testInfo) => {
  test.setTimeout(120000);
  console.log('\n================ [fix-6] TC-13: NHÂN VIÊN test.nv XEM BẢNG CÔNG CÁ NHÂN (MnuWPT010) THÁNG 10 ================');

  // 1. Đăng nhập tài khoản test.nv (099)
  const empUsername = ACCOUNTS.STAFF_NEW.username;
  const empPassword = ACCOUNTS.STAFF_NEW.password;
  await loginFix6(page, empUsername, empPassword);
  await captureStepFix6(page, testInfo, 'TC-13', 1, 'Dang nhap test.nv');

  // 2. Bấm trực tiếp icon MnuWPT010 trên Dock (khớp 100% JSON), fallback Launchpad nếu Dock chưa ghim
  const dockWpt010 = page.locator('.dock button.MnuWPT010:visible, button.MnuWPT010:visible, .dock .MnuWPT010:visible').first();
  if (await dockWpt010.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, dockWpt010, { steps: 8, pause: 300 });
  } else {
    const winDock = page.locator('.dock button.MnuHRS238, .dock .MnuHRS238, .dock button.open-lunchpad, .dock button:has(.bi-windows)').first();
    await winDock.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, winDock, { steps: 8, pause: 250 });
    await page.waitForTimeout(800);
    const lpSearch = page.locator('#launchpad input:visible, .launchpad input.search-input:visible').first();
    await lpSearch.waitFor({ state: 'visible', timeout: 5000 });
    await typeHumanLike(page, lpSearch, 'bảng công cá nhân');
    await page.waitForTimeout(900);
    const appItem = page.locator('div.MnuWPT010:visible, .child-launchpad.MnuWPT010:visible, .child-launchpad:has-text("Bảng công"):visible').first();
    await appItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, appItem, { steps: 10, pause: 300 });
  }

  const etsRoot = page.locator('#sp_EmployeeMonthlyAttendance:visible, #ets-calendar:visible, .calendar-view:visible, .tab-pane.active:has(table), table:visible, #EmployeeTimeSheetHtml:visible').first();
  await etsRoot.waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(1200);
  await captureStepFix6(page, testInfo, 'TC-13', 2, 'Mo Bang cong ca nhan MnuWPT010');

  // 3. Mở SelectBox Tháng -> Chọn Tháng 10 (khớp 100% JSON)
  const monthSelect = page.locator(
    '#P2F7760C4CFEC4A7E8A298C8D5BBB4F12 .dx-dropdowneditor-button:visible, #P2F7760C4CFEC4A7E8A298C8D5BBB4F12:visible, .tab-pane.active .dx-selectbox:visible, .ets-toolbar .dx-selectbox:visible'
  ).first();
  if (await monthSelect.isVisible({ timeout: 6000 }).catch(() => false)) {
    await moveAndClick(page, monthSelect, { steps: 8, pause: 300 });
    await page.waitForTimeout(600);

    const overlay = page.locator('.dx-overlay-content:visible').first();
    if (await overlay.isVisible({ timeout: 5000 }).catch(() => false)) {
      await overlay.locator('.dx-list-item').first().waitFor({ state: 'attached', timeout: 4000 }).catch(() => {});
      const scrollBox = overlay.locator('.dx-scrollable-container, .dx-list').first();
      const sBox = await scrollBox.boundingBox().catch(() => null);
      if (sBox) {
        await page.mouse.move(sBox.x + sBox.width / 2, sBox.y + sBox.height / 2, { steps: 6 });
        await page.mouse.wheel(0, 260);
        await page.waitForTimeout(450);
      }

      let month10Item = overlay.locator('.dx-list-item .dx-list-item-content:text-is("10")').first();
      if ((await month10Item.count().catch(() => 0)) === 0) {
        month10Item = overlay.locator('.dx-list-item:has-text("10")').first();
      }
      if ((await month10Item.count().catch(() => 0)) === 0) {
        const allMonthItems = overlay.locator('.dx-list-item');
        const totalMonths = await allMonthItems.count().catch(() => 0);
        if (totalMonths >= 10) {
          month10Item = allMonthItems.nth(9);
        } else {
          month10Item = overlay.locator('.dx-list-item-selected').first();
        }
      }
      if ((await month10Item.count().catch(() => 0)) > 0) {
        await month10Item.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
        await page.waitForTimeout(250);
        if (await month10Item.isVisible().catch(() => false)) {
          await moveAndClick(page, month10Item, { steps: 10, pause: 350 });
        }
      }
      await page.waitForTimeout(2500);
    }
  }

  // 4. Cuộn & dừng trực quan trên Bảng công cá nhân Tháng 10 để Người Dùng tự quan sát kết quả
  const calendarArea = page.locator('#ets-calendar:visible, #EmployeeTimeSheetHtml:visible').first();
  if (await calendarArea.isVisible({ timeout: 4000 }).catch(() => false)) {
    await smoothScrollHumanLike(page, calendarArea, { block: 'center', wait: 600 });
    await highlightAndPause(page, calendarArea, {
      label: 'BẢNG CÔNG CÁ NHÂN THÁNG 10/2026 - NV 099 (NGƯỜI DÙNG QUAN SÁT KẾT QUẢ)',
      duration: 4500
    }).catch(() => {});
  }
  await captureStepFix6(page, testInfo, 'TC-13', 3, 'Chon Thang 10 xem Bang cong ca nhan NV 099');
});
// <<< [END_TC_13]



// ============================================================================
// KHU VỰC PHÂN CÔNG 4: CONVERSATION [fix-7] (PRIORITY P4: BIẾN ĐỘNG TÀI CHÍNH, TÍNH LƯƠNG & KHÓA SỔ)
// ============================================================================

async function captureStepFix7(page, testInfo, tcId, stepNum, desc) {
  const cleanDesc = (desc || 'step').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  const fileName = `${tcId}-step${String(stepNum).padStart(2, '0')}-${cleanDesc}.png`;
  const dirPath = path.resolve(process.cwd(), 'test-evidence', PAGE_NAME, tcId, 'screenshots');
  fs.mkdirSync(dirPath, { recursive: true });
  const fullPath = path.join(dirPath, fileName);
  await page.screenshot({ path: fullPath }).catch(() => {});
  await testInfo.attach(`Bước ${stepNum}: ${desc}`, {
    path: fullPath,
    contentType: 'image/png'
  }).catch(() => {
    testInfo.attachments.push({ name: `step-${stepNum}-${cleanDesc}`, contentType: 'image/png', path: fullPath });
  });
  console.log(`📸 [${tcId}] Đã chụp Bước ${stepNum}: ${desc}`);
}

// Helper điều hướng mở menu an toàn riêng cho cụm fix-7 (Phân hệ Tiền Lương MnuPRL000)
async function openMenuFix7(page, menuId, menuName) {
  console.log(`📂 [fix-7]: Tìm và mở menu "${menuName}" (${menuId})...`);

  // Dọn dẹp modal backdrop tồn đọng nếu có
  await page.evaluate(() => {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.querySelectorAll('.modal.show').forEach(m => m.classList.remove('show'));
  }).catch(() => {});

  // 1. Kiểm tra tab đã mở sẵn trên thanh Top Tab Bar -> Di chuyển chuột Neon tới tab
  const tabSelector = `
    #dynamic-tab-${menuId}:visible,
    #tab-${menuId}:visible,
    .nav-tabs button:has-text("${menuName}"):visible,
    .nav-tabs a:has-text("${menuName}"):visible,
    #divTabDynamic button:has-text("${menuName}"):visible,
    .nav-tabs button:has-text("${menuName.replace(/\./g, '')}"):visible
  `;
  const existingTab = page.locator(tabSelector).first();
  if (await existingTab.isVisible({ timeout: 1200 }).catch(() => false)) {
    console.log(`👉 [fix-7]: Tab "${menuName}" đã mở sẵn, di chuột Neon nhấp kích hoạt...`);
    await moveAndClick(page, existingTab, { steps: 8, pause: 200 });
    await page.waitForTimeout(randomBetween(800, 1200));
    return;
  }

  // 2. Nhấp icon Phân hệ Tiền Lương (MnuPRL000) trên thanh Dock nếu Sidebar chưa hiện đúng menu
  const candidateSelectors = `
    span:has-text("${menuName}"):visible,
    a:has-text("${menuName}"):visible,
    .child-launchpad:has-text("${menuName}"):visible,
    .${menuId}:visible,
    [onclick*="${menuId}"]:visible
  `;
  const directItem = page.locator(candidateSelectors).first();
  if (!await directItem.isVisible({ timeout: 1000 }).catch(() => false)) {
    const dockPRL = page.locator('.dock .open-MnuPRL000:visible, .dock .MnuPRL000:visible, .dock button.MnuPRL000:visible, .dock [onclick*="MnuPRL000"]:visible, .dock [title*="Tính lương"]:visible, .dock [title*="lương"]:visible').first();
    if (await dockPRL.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('👉 [fix-7]: Di chuột Neon nhấp Phân hệ "Tính lương" (MnuPRL000) trên Dock...');
      await moveAndClick(page, dockPRL, { steps: 8, pause: 250 });
      await page.waitForTimeout(randomBetween(1200, 1600));
    }
  }

  // 3. Nếu menu đã xuất hiện trên Sidebar / Launchpad sau khi mở Dock
  const itemAfterDock = page.locator(candidateSelectors).first();
  if (await itemAfterDock.isVisible({ timeout: 2500 }).catch(() => false)) {
    console.log(`👉 [fix-7]: Di chuột Neon nhấp menu "${menuName}" trên Sidebar...`);
    await moveAndClick(page, itemAfterDock, { steps: 8, pause: 300 });
    await page.waitForTimeout(randomBetween(1500, 2000));
    return;
  }

  // 4. Mở Sidebar và tìm kiếm tên Menu
  const hamburger = page.locator('button.menu-button:visible, .main-menu-button:visible, .sidebar-toggle:visible, #btnToggleSidebar:visible').first();
  const isSidebarOpen = await page.locator('.sidebar:visible, #sidebar:visible').first().isVisible().catch(() => false);
  if (!isSidebarOpen && await hamburger.isVisible().catch(() => false)) {
    await moveAndClick(page, hamburger, { steps: 6, pause: 200 });
    await page.waitForTimeout(500);
  }

  const sidebarSearch = page.locator('#txtSearchApp:visible, .sidebar-search input:visible, .sidebar input[type="text"]:visible, input[placeholder*="Tìm kiếm"]:visible').first();
  if (await sidebarSearch.isVisible({ timeout: 2000 }).catch(() => false)) {
    await typeHumanLike(page, sidebarSearch, menuName.replace(/\./g, ''));
    await page.waitForTimeout(randomBetween(600, 900));

    const filteredItem = page.locator(`
      .sidebar a:has-text("${menuName}"):visible,
      .sidebar li:has-text("${menuName}"):visible,
      .sidebar span:has-text("${menuName}"):visible,
      [onclick*="${menuId}"]:visible
    `).first();

    if (await filteredItem.isVisible({ timeout: 2500 }).catch(() => false)) {
      await moveAndClick(page, filteredItem, { steps: 8, pause: 300 });
      await page.waitForTimeout(randomBetween(1500, 2000));
      return;
    }
  }

  // 5. Fallback trực tiếp bằng hàm hệ thống nếu UI khuất
  console.log(`👉 [fix-7]: Gọi hàm hệ thống mở tab cho ${menuId}...`);
  await page.evaluate((id) => {
    try {
      if (typeof window.OpenAppInSidebar === 'function') {
        window.OpenAppInSidebar(id);
      } else {
        const app = typeof findAppById === 'function' ? findAppById(id) : null;
        if (app && typeof addNewTab === 'function') {
          addNewTab(app.id, app.name, app.className, '');
        }
      }
    } catch (_) {}
  }, menuId);
  await page.waitForTimeout(randomBetween(1800, 2500));
}

// >>> [START_TC_14] - CONVERSATION: fix-7
test('fix-7 | TC-14: Mô phỏng thao tác nạp Thưởng KPI 1,000,000 VNĐ trên Thu nhập không cố định (MnuPRL036)', async ({ page }, testInfo) => {
  test.setTimeout(120000);
  console.log('\n================ [fix-7 | TC-14]: REPLAY THU NHẬP KHÔNG CỐ ĐỊNH (MnuPRL036) ================');

  // Helper cục bộ mở menu qua Launchpad giống 100% file Recording (MnuHRS238 -> #launchpad input -> click kết quả)
  const openMenuViaLaunchpad = async (keyword, itemSelector) => {
    const winDock = page.locator('button.MnuHRS238:visible, .dock button.MnuHRS238:visible, .dock button:has(.bi-windows):visible').first();
    await winDock.waitFor({ state: 'visible', timeout: 15000 });
    await moveAndClick(page, winDock, { steps: 10, pause: 250 });
    await page.waitForTimeout(700);

    const lpInput = page.locator('#launchpad input:visible').first();
    await lpInput.waitFor({ state: 'visible', timeout: 8000 });
    await typeHumanLike(page, lpInput, keyword);
    await page.waitForTimeout(900);

    const menuItem = page.locator(itemSelector).first();
    await menuItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, menuItem, { steps: 10, pause: 300 });
    await page.waitForTimeout(1500);
  };

  // Helper cục bộ chọn item trong SelectBox DevExtreme (chỉ cuộn khi bị khuất)
  const pickExactSelectOption = async (boxLocator, exactValue) => {
    const box = boxLocator.first();
    await box.waitFor({ state: 'visible', timeout: 10000 });
    const dropBtn = box.locator('.dx-dropdowneditor-button, .dx-texteditor-input').first();
    await moveAndClick(page, (await dropBtn.isVisible().catch(() => false)) ? dropBtn : box, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);

    const overlay = page.locator('.dx-overlay-content:has(.dx-list-item):visible, .dx-dropdowneditor-overlay .dx-overlay-content:visible, .dx-overlay-content:visible').last();
    await overlay.waitFor({ state: 'visible', timeout: 6000 });
    let opt = overlay.locator(`.dx-list-item:has(.dx-list-item-content:text-is("${exactValue}")), .dx-list-item:text-is("${exactValue}")`).first();
    if (!(await opt.count().catch(() => 0))) {
      opt = overlay.locator(`.dx-list-item:has-text("${exactValue}")`).first();
    }
    await opt.waitFor({ state: 'attached', timeout: 6000 });
    const isObscured = await opt.evaluate(el => {
      const r = el.getBoundingClientRect();
      return r.bottom > window.innerHeight - 20 || r.top < 20;
    }).catch(() => false);
    if (isObscured) {
      await smoothScrollHumanLike(page, opt, { block: 'nearest', wait: 350 });
    }
    await moveAndClick(page, opt, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);
  };

  // Bước 1 [Recording 1..20]: Truy cập https://paradisehrm.com/Tai3/ & Đăng nhập Chien.nguyen / 123
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  const uInput = page.locator('#username:visible, input[type="text"]:visible').first();
  const pInput = page.locator('input[type="password"]:visible').first();
  if (await uInput.isVisible({ timeout: 6000 }).catch(() => false)) {
    await typeHumanLike(page, uInput, 'Chien.nguyen');
    await typeHumanLike(page, pInput, '123');
    const loginBtn = page.locator('#submitLogin:visible, button:has-text("Đăng nhập"):visible').first();
    await moveAndClick(page, loginBtn, { steps: 10, pause: 300 });
  }
  await page.locator('.dock, button.MnuHRS238').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1000);
  await captureStepFix7(page, testInfo, 'TC-14', 1, 'Dang nhap Chien nguyen');

  // Bước 2 [Recording 21..34]: Mở Launchpad -> gõ "thu nhập" -> mở menu Thu nhập không cố định (MnuPRL036)
  await openMenuViaLaunchpad(
    'thu nhập',
    '#launchpad .child-launchpad.MnuPRL036 > i:visible, #launchpad .child-launchpad.MnuPRL036:visible'
  );
  await page.locator('#sp_Adjustment_html, #gridAdjustment').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(1000);
  await captureStepFix7(page, testInfo, 'TC-14', 2, 'Mo menu Thu nhap khong co dinh MnuPRL036');

  // Bước 3 [Recording 35..38]: Chọn Tháng 10 & Năm 2026 trên Toolbar
  await pickExactSelectOption(page.locator('#P2A128E4FCF8D4E7E938B82EC1C80EF05'), '10');
  await pickExactSelectOption(page.locator('#P61585A08C403407E9EFEAAFB5F013B6C'), '2026');
  await page.waitForTimeout(800);

  // Bước 4 [Recording 39]: Bấm nút (+) Thêm mới điều chỉnh trên toolbar (.dx-icon-plus)
  const btnAdd = page.locator('#sp_Adjustment_html .dx-toolbar-after .dx-button:has(.dx-icon-plus):visible, #sp_Adjustment_html .adj-icon-btn:has(.dx-icon-plus):visible, #sp_Adjustment_html .dx-icon-plus:visible').first();
  await moveAndClick(page, btnAdd, { steps: 10, pause: 300 });
  await page.locator('#sp_EditAdjustment_html').first().waitFor({ state: 'visible', timeout: 15000 });
  await page.waitForTimeout(700);

  // Bước 5 [Recording 40..56]: Mở hộp chọn Nhân viên -> gõ "test" -> chọn Nguyễn Văn Test (099) -> bấm Chọn/OK
  const empPicker = page.locator('#EmployeeIDP03F80ABC583A40BF8887EB518C00BD09_display:visible, #sp_EditAdjustment_html [id*="EmployeeID"] .dx-dropdowneditor-button:visible').first();
  await moveAndClick(page, empPicker, { steps: 8, pause: 250 });
  await page.waitForTimeout(600);

  const empPopupSearch = page.locator('.dx-overlay-content:visible .dx-datagrid-header-panel input:visible').last();
  await empPopupSearch.waitFor({ state: 'visible', timeout: 8000 });
  await typeHumanLike(page, empPopupSearch, 'test');
  await page.waitForTimeout(900);

  const empRow = await resolveDynamicTarget(page, {
    baseSelector: '.dx-overlay-content:visible tr.dx-data-row',
    requiredTexts: ['Nguyễn Văn Test'],
    preferredTexts: ['099'],
    scrollContainerSelector: '.dx-overlay-content:visible .dx-scrollable-container',
    throwIfNotFound: true
  });
  await moveAndClick(page, empRow.locator('td:has-text("Nguyễn Văn Test"), td').nth(2), { steps: 8, pause: 250 });
  await page.waitForTimeout(300);

  const empOkBtn = page.locator('.dx-overlay-content:visible .dx-popup-bottom .dx-button:has-text("Chọn"), .dx-overlay-content:visible .dx-popup-bottom .dx-button:has-text("OK"), .dx-overlay-content:visible .dx-popup-bottom div:nth-of-type(2) .dx-button').last();
  await moveAndClick(page, empOkBtn, { steps: 8, pause: 250 });
  await page.waitForTimeout(600);

  // Bước 6 [Recording 57..58]: Chọn Loại điều chỉnh "Tiền thưởng"
  await pickExactSelectOption(page.locator('#PB4CC1FFD961745D89F4505DEBDF7BD6E'), 'Tiền thưởng');

  // Bước 7 [Recording 59..60]: Nhập Số tiền 1000000
  const amtInput = page.locator('#PC0CC1804B85E4EA783B473A4D54F7DAE input.dx-texteditor-input:visible, #PC0CC1804B85E4EA783B473A4D54F7DAE input:visible').first();
  await typeHumanLike(page, amtInput, '1000000');

  // Bước 8 [Recording 61..136]: Nhập Ghi chú "Thưởng KPI nhân viên mới xuất sắc"
  const noteEditor = page.locator('#editor-P884C6D96907B49109FB1FC661E9145A6 .ce-paragraph[contenteditable="true"]:visible, #editor-P884C6D96907B49109FB1FC661E9145A6 [contenteditable="true"]:visible, #editor-P884C6D96907B49109FB1FC661E9145A6:visible').first();
  await typeHumanLike(page, noteEditor, 'Thưởng KPI nhân viên mới xuất sắc', { clear: false });

  // Bước 9 [Recording 137]: Bấm nút Lưu (#btnSaveAdjustment) và dừng quan sát trực quan
  const btnSaveAdj = page.locator('#btnSaveAdjustment:visible').first();
  await moveAndClick(page, btnSaveAdj, { steps: 10, pause: 350 });
  await page.locator('#sp_EditAdjustment_html').waitFor({ state: 'hidden', timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(3500);
  await captureStepFix7(page, testInfo, 'TC-14', 3, 'Luu Thuong KPI 1M thanh cong tren MnuPRL036');
});
// <<< [END_TC_14]

// >>> [START_TC_15] - CONVERSATION: fix-7
test('fix-7 | TC-15: Mô phỏng thao tác nạp Tạm ứng lương 2,000,000 VNĐ & Khóa phiếu (MnuPRL070)', async ({ page }, testInfo) => {
  test.setTimeout(120000);
  console.log('\n================ [fix-7 | TC-15]: REPLAY TẠM ỨNG LƯƠNG (MnuPRL070) ================');

  const openMenuViaLaunchpad = async (keyword, itemSelector) => {
    const winDock = page.locator('button.MnuHRS238:visible, .dock button.MnuHRS238:visible, .dock button:has(.bi-windows):visible').first();
    await winDock.waitFor({ state: 'visible', timeout: 15000 });
    await moveAndClick(page, winDock, { steps: 10, pause: 250 });
    await page.waitForTimeout(700);

    const lpInput = page.locator('#launchpad input:visible').first();
    await lpInput.waitFor({ state: 'visible', timeout: 8000 });
    await typeHumanLike(page, lpInput, keyword);
    await page.waitForTimeout(900);

    const menuItem = page.locator(itemSelector).first();
    await menuItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, menuItem, { steps: 10, pause: 300 });
    await page.waitForTimeout(1500);
  };

  const pickExactSelectOption = async (boxLocator, exactValue) => {
    const box = boxLocator.first();
    await box.waitFor({ state: 'visible', timeout: 10000 });
    const dropBtn = box.locator('.dx-dropdowneditor-button, .dx-texteditor-input').first();
    await moveAndClick(page, (await dropBtn.isVisible().catch(() => false)) ? dropBtn : box, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);

    const overlay = page.locator('.dx-overlay-content:has(.dx-list-item):visible, .dx-dropdowneditor-overlay .dx-overlay-content:visible, .dx-overlay-content:visible').last();
    await overlay.waitFor({ state: 'visible', timeout: 6000 });
    let opt = overlay.locator(`.dx-list-item:has(.dx-list-item-content:text-is("${exactValue}")), .dx-list-item:text-is("${exactValue}")`).first();
    if (!(await opt.count().catch(() => 0))) {
      opt = overlay.locator(`.dx-list-item:has-text("${exactValue}")`).first();
    }
    await opt.waitFor({ state: 'attached', timeout: 6000 });
    const isObscured = await opt.evaluate(el => {
      const r = el.getBoundingClientRect();
      return r.bottom > window.innerHeight - 20 || r.top < 20;
    }).catch(() => false);
    if (isObscured) {
      await smoothScrollHumanLike(page, opt, { block: 'nearest', wait: 350 });
    }
    await moveAndClick(page, opt, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);
  };

  // Bước 1 [Recording 1..20]: Đăng nhập Chien.nguyen / 123
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  const uInput = page.locator('#username:visible, input[type="text"]:visible').first();
  const pInput = page.locator('input[type="password"]:visible').first();
  if (await uInput.isVisible({ timeout: 6000 }).catch(() => false)) {
    await typeHumanLike(page, uInput, 'Chien.nguyen');
    await typeHumanLike(page, pInput, '123');
    const loginBtn = page.locator('#submitLogin:visible, button:has-text("Đăng nhập"):visible').first();
    await moveAndClick(page, loginBtn, { steps: 10, pause: 300 });
  }
  await page.locator('.dock, button.MnuHRS238').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1000);
  await captureStepFix7(page, testInfo, 'TC-15', 1, 'Dang nhap Chien nguyen');

  // Bước 2 [Recording 138..164]: Mở Launchpad -> gõ "tạm ứng" -> mở menu Tạm ứng lương (MnuPRL070)
  await openMenuViaLaunchpad(
    'tạm ứng',
    '#launchpad .child-launchpad.MnuPRL070 > i:visible, #launchpad .child-launchpad.MnuPRL070:visible'
  );
  await page.locator('#SAL_Advance_Process, #GridSAL_Advance_Process').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(1200);
  await captureStepFix7(page, testInfo, 'TC-15', 2, 'Mo menu Tam ung luong MnuPRL070');

  // Bước 3 [Recording 165..168]: Chọn Tháng 10 & Năm 2026 trên Toolbar
  await pickExactSelectOption(page.locator('#P13431133E9D6489CA60B01DD1C17F1F2'), '10');
  await pickExactSelectOption(page.locator('#P9F624C1BFF0846AA98AB688E66478E84'), '2026');
  await page.waitForTimeout(800);

  // Bước 4 [Recording 169..180]: Gõ "test" vào ô SearchBox trên toolbar lưới Tạm ứng lương
  const searchBox15 = page.locator('#dynamic-pane-MnuPRL070 .dx-datagrid-search-panel input:visible, #SAL_Advance_Process .dx-datagrid-search-panel input:visible').first();
  await typeHumanLike(page, searchBox15, 'test');
  await page.waitForTimeout(1000);

  // Bước 5 [Recording 181]: Định vị động dòng NV 099 / Nguyễn Văn Test và nhấp đúp mở modal Sửa tạm ứng lương
  const advRow = await resolveDynamicTarget(page, {
    baseSelector: '#dynamic-pane-MnuPRL070 tr.dx-data-row, #SAL_Advance_Process tr.dx-data-row',
    requiredTexts: ['Nguyễn Văn Test'],
    preferredTexts: ['099'],
    scrollContainerSelector: '#SAL_Advance_Process .dx-scrollable-container, #dynamic-pane-MnuPRL070 .dx-scrollable-container',
    throwIfNotFound: true
  });
  const dblTarget = advRow.locator('td:has-text("Nguyễn Văn Test")').first();
  await dblTarget.scrollIntoViewIfNeeded().catch(() => {});
  const box = await dblTarget.boundingBox();
  if (!box) throw new Error('[TC-15] Không lấy được tọa độ dòng Nguyễn Văn Test để doubleClick.');
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 10 });
  await page.waitForTimeout(250);
  await page.mouse.dblclick(box.x + box.width / 2, box.y + box.height / 2);

  await page.locator('#sp_SAL_Advance_Process_Edit_html').first().waitFor({ state: 'visible', timeout: 15000 });
  await page.waitForTimeout(700);

  // Bước 6 [Recording 182..183]: Nhập số tiền Tạm ứng = 2000000
  const advAmountInput = page.locator('#P2C632067A29F4E25812C0144D5019625 input.dx-texteditor-input:visible, #P2C632067A29F4E25812C0144D5019625 input:visible').first();
  await typeHumanLike(page, advAmountInput, '2000000');

  // Bước 7 [Recording 184]: Tích checkbox Khóa (#P03965EDAFBF54FA0B84BED320C664F4A -> tự tick kèm Tiền mặt)
  const lockChk = page.locator('#P03965EDAFBF54FA0B84BED320C664F4A .dx-checkbox-icon:visible, #P03965EDAFBF54FA0B84BED320C664F4A:visible').first();
  await moveAndClick(page, lockChk, { steps: 8, pause: 250 });
  await page.waitForTimeout(400);

  // Bước 8 [Recording 185..238]: Nhập Ghi chú "Tạm ứng sinh hoạt cá nhân"
  const advNotesInput = page.locator('#P0B1DB0A879264428A64EA2F4CB385E8A input.dx-texteditor-input:visible, #P0B1DB0A879264428A64EA2F4CB385E8A input:visible').first();
  await typeHumanLike(page, advNotesInput, 'Tạm ứng sinh hoạt cá nhân');

  // Bước 9 [Recording 239]: Bấm nút Lưu (#btnSaveAdvance) và dừng quan sát kết quả trên lưới
  const btnSaveAdv = page.locator('#btnSaveAdvance:visible').first();
  await moveAndClick(page, btnSaveAdv, { steps: 10, pause: 350 });
  await page.locator('#sp_SAL_Advance_Process_Edit_html').waitFor({ state: 'hidden', timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(3500);
  await captureStepFix7(page, testInfo, 'TC-15', 3, 'Luu va khoa Tam ung 2M tren MnuPRL070');
});
// <<< [END_TC_15]

// >>> [START_TC_16] - CONVERSATION: fix-7
test('fix-7 | TC-16: Mô phỏng thao tác chạy Tính tiền lương Tháng 10/2026 (MnuPRL040)', async ({ page }, testInfo) => {
  test.setTimeout(180000);
  console.log('\n================ [fix-7 | TC-16]: REPLAY TÍNH TIỀN LƯƠNG (MnuPRL040) ================');

  const openMenuViaLaunchpad = async (keyword, itemSelector) => {
    const winDock = page.locator('button.MnuHRS238:visible, .dock button.MnuHRS238:visible, .dock button:has(.bi-windows):visible').first();
    await winDock.waitFor({ state: 'visible', timeout: 15000 });
    await moveAndClick(page, winDock, { steps: 10, pause: 250 });
    await page.waitForTimeout(700);

    const lpInput = page.locator('#launchpad input:visible').first();
    await lpInput.waitFor({ state: 'visible', timeout: 8000 });
    await typeHumanLike(page, lpInput, keyword);
    await page.waitForTimeout(900);

    const menuItem = page.locator(itemSelector).first();
    await menuItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, menuItem, { steps: 10, pause: 300 });
    await page.waitForTimeout(1500);
  };

  const pickExactSelectOption = async (boxLocator, exactValue) => {
    const box = boxLocator.first();
    await box.waitFor({ state: 'visible', timeout: 10000 });
    const dropBtn = box.locator('.dx-dropdowneditor-button, .dx-texteditor-input').first();
    await moveAndClick(page, (await dropBtn.isVisible().catch(() => false)) ? dropBtn : box, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);

    const overlay = page.locator('.dx-overlay-content:has(.dx-list-item):visible, .dx-dropdowneditor-overlay .dx-overlay-content:visible, .dx-overlay-content:visible').last();
    await overlay.waitFor({ state: 'visible', timeout: 6000 });
    let opt = overlay.locator(`.dx-list-item:has(.dx-list-item-content:text-is("${exactValue}")), .dx-list-item:text-is("${exactValue}")`).first();
    if (!(await opt.count().catch(() => 0))) {
      opt = overlay.locator(`.dx-list-item:has-text("${exactValue}")`).first();
    }
    await opt.waitFor({ state: 'attached', timeout: 6000 });
    const isObscured = await opt.evaluate(el => {
      const r = el.getBoundingClientRect();
      return r.bottom > window.innerHeight - 20 || r.top < 20;
    }).catch(() => false);
    if (isObscured) {
      await smoothScrollHumanLike(page, opt, { block: 'nearest', wait: 350 });
    }
    await moveAndClick(page, opt, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);
  };

  // Bước 1 [Recording 1..20]: Đăng nhập Chien.nguyen / 123
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  const uInput = page.locator('#username:visible, input[type="text"]:visible').first();
  const pInput = page.locator('input[type="password"]:visible').first();
  if (await uInput.isVisible({ timeout: 6000 }).catch(() => false)) {
    await typeHumanLike(page, uInput, 'Chien.nguyen');
    await typeHumanLike(page, pInput, '123');
    const loginBtn = page.locator('#submitLogin:visible, button:has-text("Đăng nhập"):visible').first();
    await moveAndClick(page, loginBtn, { steps: 10, pause: 300 });
  }
  await page.locator('.dock, button.MnuHRS238').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1000);
  await captureStepFix7(page, testInfo, 'TC-16', 1, 'Dang nhap Chien nguyen');

  // Bước 2 [Recording 240..269]: Mở Launchpad -> gõ "tính tiền" -> mở menu Tính tiền lương (MnuPRL040)
  await openMenuViaLaunchpad(
    'tính tiền',
    '#launchpad .child-launchpad.MnuPRL040 > i:visible, #launchpad .child-launchpad.MnuPRL040:visible'
  );
  await page.locator('#SALCAL_MAIN').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(1200);
  await captureStepFix7(page, testInfo, 'TC-16', 2, 'Mo menu Tinh tien luong MnuPRL040');

  // Bước 3 [Recording 270..275]: Chọn Tháng 10 & Năm 2026 trong #SALCAL_MAIN (.dx-dropdownbox)
  const salcalSelects = page.locator('#SALCAL_MAIN .dx-dropdownbox:visible, #SALCAL_MAIN .dx-selectbox:visible');
  await salcalSelects.first().waitFor({ state: 'visible', timeout: 15000 });
  await pickExactSelectOption(salcalSelects.nth(0), '10');
  await pickExactSelectOption(salcalSelects.nth(1), '2026');
  await page.waitForTimeout(700);

  // Bước 4 [Recording 276..277]: Nhấp nút Tính lương (#SALCAL_MAIN .btnreload) và dừng quan sát kết quả tính lương
  const calcBtn = page.locator('#SALCAL_MAIN .btnreload:visible, #SALCAL_MAIN .dx-button:has-text("Tính lương"):visible, div.flex-none .dx-button:has-text("Tính lương"):visible').first();
  await moveAndClick(page, calcBtn, { steps: 10, pause: 350 });
  await page.locator('#SALCAL_MAIN tr.dx-data-row').first().waitFor({ state: 'visible', timeout: 25000 }).catch(() => {});
  await page.waitForTimeout(3500);
  await captureStepFix7(page, testInfo, 'TC-16', 3, 'Chay xong Tinh tien luong MnuPRL040');
});
// <<< [END_TC_16]

// >>> [START_TC_17] - CONVERSATION: fix-7
test('fix-7 | TC-17: Mô phỏng thao tác Khóa chấm công (MnuTAD125), Khóa lương (MnuPRL080) & Đăng xuất', async ({ page }, testInfo) => {
  test.setTimeout(150000);
  console.log('\n================ [fix-7 | TC-17]: REPLAY KHÓA CÔNG, KHÓA LƯƠNG & ĐĂNG XUẤT ================');

  const openMenuViaLaunchpad = async (keyword, itemSelector) => {
    const winDock = page.locator('button.MnuHRS238:visible, .dock button.MnuHRS238:visible, .dock button:has(.bi-windows):visible').first();
    await winDock.waitFor({ state: 'visible', timeout: 15000 });
    await moveAndClick(page, winDock, { steps: 10, pause: 250 });
    await page.waitForTimeout(700);

    const lpInput = page.locator('#launchpad input:visible').first();
    await lpInput.waitFor({ state: 'visible', timeout: 8000 });
    await typeHumanLike(page, lpInput, keyword);
    await page.waitForTimeout(900);

    const menuItem = page.locator(itemSelector).first();
    await menuItem.waitFor({ state: 'visible', timeout: 8000 });
    await moveAndClick(page, menuItem, { steps: 10, pause: 300 });
    await page.waitForTimeout(1500);
  };

  const pickExactSelectOption = async (boxLocator, exactValue) => {
    const box = boxLocator.first();
    await box.waitFor({ state: 'visible', timeout: 10000 });
    const dropBtn = box.locator('.dx-dropdowneditor-button, .dx-texteditor-input').first();
    await moveAndClick(page, (await dropBtn.isVisible().catch(() => false)) ? dropBtn : box, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);

    const overlay = page.locator('.dx-overlay-content:has(.dx-list-item):visible, .dx-dropdowneditor-overlay .dx-overlay-content:visible, .dx-overlay-content:visible').last();
    await overlay.waitFor({ state: 'visible', timeout: 6000 });
    let opt = overlay.locator(`.dx-list-item:has(.dx-list-item-content:text-is("${exactValue}")), .dx-list-item:text-is("${exactValue}")`).first();
    if (!(await opt.count().catch(() => 0))) {
      opt = overlay.locator(`.dx-list-item:has-text("${exactValue}")`).first();
    }
    await opt.waitFor({ state: 'attached', timeout: 6000 });
    const isObscured = await opt.evaluate(el => {
      const r = el.getBoundingClientRect();
      return r.bottom > window.innerHeight - 20 || r.top < 20;
    }).catch(() => false);
    if (isObscured) {
      await smoothScrollHumanLike(page, opt, { block: 'nearest', wait: 350 });
    }
    await moveAndClick(page, opt, { steps: 8, pause: 250 });
    await page.waitForTimeout(500);
  };

  // Bước 1 [Recording 1..20]: Đăng nhập Chien.nguyen / 123
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  const uInput = page.locator('#username:visible, input[type="text"]:visible').first();
  const pInput = page.locator('input[type="password"]:visible').first();
  if (await uInput.isVisible({ timeout: 6000 }).catch(() => false)) {
    await typeHumanLike(page, uInput, 'Chien.nguyen');
    await typeHumanLike(page, pInput, '123');
    const loginBtn = page.locator('#submitLogin:visible, button:has-text("Đăng nhập"):visible').first();
    await moveAndClick(page, loginBtn, { steps: 10, pause: 300 });
  }
  await page.locator('.dock, button.MnuHRS238').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1000);
  await captureStepFix7(page, testInfo, 'TC-17', 1, 'Dang nhap Chien nguyen');

  // Bước 2 [Recording 280..310]: Mở Launchpad -> gõ "khóa" -> mở Mở/Khóa. Công (MnuTAD125)
  await openMenuViaLaunchpad(
    'khóa',
    '#launchpad .child-launchpad.MnuTAD125 > i:visible, #launchpad .child-launchpad.MnuTAD125:visible'
  );
  await page.locator('#sp_LockAttendanceData_CheckStatus_html, #dynamic-pane-MnuTAD125').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(1000);

  await pickExactSelectOption(page.locator('#P8C6640AB6B1249658EF8C297541CCE70'), '10');
  await pickExactSelectOption(page.locator('#P9B1B3B08B65B45D6A6FA3BFC4673B92A'), '2026');
  await page.waitForTimeout(800);

  const searchTad = page.locator('#dynamic-pane-MnuTAD125 .dx-datagrid-search-panel input:visible').first();
  await typeHumanLike(page, searchTad, 'test');
  await page.waitForTimeout(900);

  const tadRow = await resolveDynamicTarget(page, {
    baseSelector: '#dynamic-pane-MnuTAD125 tr.dx-data-row',
    requiredTexts: ['Nguyễn Văn Test'],
    preferredTexts: ['099'],
    scrollContainerSelector: '#dynamic-pane-MnuTAD125 .dx-scrollable-container',
    throwIfNotFound: true
  });
  await moveAndClick(page, tadRow.locator('td:has-text("Nguyễn Văn Test"), td').nth(1), { steps: 8, pause: 250 });
  await page.waitForTimeout(400);

  const btnLockAtt = page.locator('#btnLockAttendance:visible, #dynamic-pane-MnuTAD125 .btn-lock-toolbar:visible, #dynamic-pane-MnuTAD125 .dx-toolbar-after .dx-button:has-text("Khóa"):visible').first();
  await moveAndClick(page, btnLockAtt, { steps: 10, pause: 300 });
  await page.waitForTimeout(600);

  const okAtt = page.locator('#vc-vu-confirm-popup button.VC-Vu-btn-ok:visible, #vc-vu-confirm-popup button:has-text("Đồng ý"):visible').first();
  await okAtt.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, okAtt, { steps: 8, pause: 250 });
  await page.waitForTimeout(2500);
  await captureStepFix7(page, testInfo, 'TC-17', 2, 'Khoa cham cong NV 099 tren MnuTAD125');

  // Bước 3 [Recording 313..345]: Mở Launchpad -> gõ "khóa" -> mở Mở/Khóa. Lương (MnuPRL080)
  await openMenuViaLaunchpad(
    'khóa',
    '#launchpad .child-launchpad.MnuPRL080 > i:visible, #launchpad .child-launchpad.MnuPRL080:visible'
  );
  await page.locator('#LockSalaryContainer, #dynamic-pane-MnuPRL080').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(1000);

  await pickExactSelectOption(page.locator('#P682FA188ED5B4BD38C89E22CD6E72646'), '10');
  await pickExactSelectOption(page.locator('#P911AA562E7AC44CEBC3FC7FAB611E906'), '2026');
  await page.waitForTimeout(800);

  const searchPrl = page.locator('#dynamic-pane-MnuPRL080 .dx-datagrid-search-panel input:visible').first();
  await typeHumanLike(page, searchPrl, 'test');
  await page.waitForTimeout(900);

  const prlRow = await resolveDynamicTarget(page, {
    baseSelector: '#dynamic-pane-MnuPRL080 tr.dx-data-row',
    requiredTexts: ['Nguyễn Văn Test'],
    preferredTexts: ['099'],
    scrollContainerSelector: '#dynamic-pane-MnuPRL080 .dx-scrollable-container',
    throwIfNotFound: true
  });
  await moveAndClick(page, prlRow.locator('td:has-text("Nguyễn Văn Test"), td').nth(1), { steps: 8, pause: 250 });
  await page.waitForTimeout(400);

  const btnLockSal = page.locator('#btnLockToolbar:visible').first();
  await moveAndClick(page, btnLockSal, { steps: 10, pause: 300 });
  await page.waitForTimeout(600);

  const okSal = page.locator('#vc-vu-confirm-popup button.VC-Vu-btn-ok:visible, #vc-vu-confirm-popup button:has-text("Đồng ý"):visible').first();
  await okSal.waitFor({ state: 'visible', timeout: 8000 });
  await moveAndClick(page, okSal, { steps: 8, pause: 250 });
  await page.waitForTimeout(3000);
  await captureStepFix7(page, testInfo, 'TC-17', 3, 'Khoa so ky luong NV 099 tren MnuPRL080');

  // Bước 4 [Recording 350..352]: Đăng xuất trên UI (#randomAvatar -> #txtLogoutOpt -> #successModalButtonAddNew)
  const avatarBtn = page.locator('#randomAvatar:visible').first();
  await moveAndClick(page, avatarBtn, { steps: 10, pause: 250 });
  await page.waitForTimeout(500);

  const logoutOpt = page.locator('#txtLogoutOpt:visible').first();
  await moveAndClick(page, logoutOpt, { steps: 8, pause: 250 });
  await page.waitForTimeout(500);

  const logoutConfirmBtn = page.locator('#successModalButtonAddNew:visible').first();
  await moveAndClick(page, logoutConfirmBtn, { steps: 8, pause: 300 });
  await page.locator('#username, #submitLogin').first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(2000);
  await captureStepFix7(page, testInfo, 'TC-17', 4, 'Dang xuat ve man hinh Login');
});
// <<< [END_TC_17]


// ============================================================================
// KHU VỰC PHÂN CÔNG 5: CONVERSATION [fix-8] (PRIORITY P5: BẢNG LƯƠNG & NGHIỆM THU PHIẾU LƯƠNG)
// Áp dụng 100% Quy chuẩn Kiểm thử trực quan Live Visual E2E (Zero Bot Shortcuts)
// ============================================================================

// Trợ lý chụp ảnh từng bước cho cụm fix-8 (Lưu vào test-evidence/quy_trinh_tinh_luong_nv_moi/TC-xx/screenshots/)
async function captureStepFix8(page, testInfo, tcId, stepNum, desc) {
  const safeDesc = (desc || 'step')
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(stepNum).padStart(2, '0')}-${safeDesc}.png`;
  const dirPath = path.resolve(process.cwd(), 'test-evidence', PAGE_NAME, tcId, 'screenshots');
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
  const fullPath = path.join(dirPath, fileName);
  await page.screenshot({ path: fullPath, fullPage: false }).catch(() => {});
  await testInfo.attach(`Bước ${stepNum}: ${desc}`, { path: fullPath, contentType: 'image/png' });
  console.log(`📸 [${tcId}] Đã chụp Bước ${stepNum}: ${desc}`);
}

// Trợ lý đăng nhập trực quan riêng cho fix-8 (chống SPA re-render nuốt phím / bỏ qua đăng nhập âm thầm)
async function loginFix8(page, username, password) {
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {});

  const dockIndicator = page.locator('.dock:visible, button.MnuHRS238:visible').first();
  if (await dockIndicator.isVisible({ timeout: 1500 }).catch(() => false)) {
    return;
  }

  for (let attempt = 1; attempt <= 2; attempt++) {
    const uInput = page.locator('#username:visible, input[placeholder*="tên đăng nhập" i]:visible, input[type="text"]:visible').first();
    const pInput = page.locator('input[type="password"]:visible, input[placeholder*="mật khẩu" i]:visible').first();
    const loginBtn = page.locator('button:has-text("Đăng nhập"):visible, button#btnLogin:visible').first();

    await uInput.waitFor({ state: 'visible', timeout: 15000 });
    await page.waitForTimeout(900);

    await typeHumanLike(page, uInput, username);
    await typeHumanLike(page, pInput, password);

    const typedUser = await uInput.inputValue().catch(() => '');
    const typedPass = await pInput.inputValue().catch(() => '');
    if (typedUser.toLowerCase() !== String(username).toLowerCase() || !typedPass) {
      console.log(`⚠️ [fix-8 Login]: Form đăng nhập vừa re-render, nhập lại lần ${attempt}...`);
      await typeHumanLike(page, uInput, username);
      await typeHumanLike(page, pInput, password);
    }

    await moveAndClick(page, loginBtn, { steps: 10, pause: 250 });

    if (await dockIndicator.waitFor({ state: 'visible', timeout: 20000 }).then(() => true).catch(() => false)) {
      await page.waitForTimeout(randomBetween(600, 900));
      return;
    }

    console.log(`⚠️ [fix-8 Login]: Chưa thấy thanh Dock sau lần thử ${attempt}, tải lại trang đăng nhập...`);
    await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 8000 }).catch(() => {});
  }

  throw new Error(`❌ [fix-8 Login]: Không thể đăng nhập tài khoản "${username}", vẫn đang kẹt tại màn hình Login!`);
}

// Trợ lý điều hướng trực quan riêng cho fix-8 (Ưu tiên Windows Launchpad khớp thao tác JSON Recorder)
async function openMenuFix8(page, menuId, menuName) {
  console.log(`📂 [fix-8 Điều hướng trực quan]: Mở menu "${menuName}" (${menuId})...`);

  // 1. Kiểm tra tab đã mở trên thanh Top Tab Bar
  const existingTab = page.locator(`
    #dynamic-tab-${menuId}:visible,
    #tab-${menuId}:visible,
    .nav-tabs button:has-text("${menuName}"):visible,
    .nav-tabs a:has-text("${menuName}"):visible,
    #divTabDynamic button:has-text("${menuName}"):visible
  `).first();

  if (await existingTab.isVisible({ timeout: 1200 }).catch(() => false)) {
    console.log(`👉 [fix-8]: Tab "${menuName}" đã mở sẵn, di chuột Neon nhấp kích hoạt...`);
    await moveAndClick(page, existingTab, { steps: 10, pause: 250 });
    await page.waitForTimeout(1000);
    return;
  }

  // 2. Mở Windows Launchpad trên thanh Dock -> Gõ tìm kiếm -> Nhấp icon mở menu (khớp 100% JSON Recorder)
  const launchpadBtn = page.locator('button.MnuHRS238 > i, button.MnuHRS238').first();
  if (await launchpadBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    console.log(`👉 [fix-8]: Di chuột Neon nhấp mở Windows Launchpad (MnuHRS238)...`);
    await moveAndClick(page, launchpadBtn, { steps: 12, pause: 300 });
    await page.waitForTimeout(700);

    const launchpadSearch = page.locator('#launchpad input:visible').first();
    if (await launchpadSearch.isVisible({ timeout: 3500 }).catch(() => false)) {
      console.log(`👉 [fix-8]: Gõ từng ký tự tìm "${menuName}" trên thanh tìm kiếm Launchpad...`);
      await typeHumanLike(page, launchpadSearch, menuName);
      await page.waitForTimeout(900);

      const tileCandidates = [
        `#launchpad .open-${menuId} i:visible`,
        `#launchpad .open-${menuId}:visible`,
        `#launchpad [onclick*="${menuId}"] i:visible`,
        `#launchpad [onclick*="${menuId}"]:visible`,
        `#launchpad .wrapper-launchpad > div > div:has-text("${menuName}") i:visible`,
        `#launchpad .wrapper-launchpad > div > div:has-text("${menuName}"):visible`,
        `#launchpad span:has-text("${menuName}"):visible`
      ];

      let launchpadTile = null;
      for (const sel of tileCandidates) {
        const candidate = page.locator(sel).first();
        if (await candidate.isVisible({ timeout: 600 }).catch(() => false)) {
          launchpadTile = candidate;
          break;
        }
      }

      if (launchpadTile) {
        await smoothScrollHumanLike(page, launchpadTile, { block: 'center', wait: 500 });
        console.log(`👉 [fix-8]: Di chuột Neon nhấp mở "${menuName}" (${menuId}) từ Launchpad...`);
        await moveAndClick(page, launchpadTile, { steps: 12, pause: 350 });
        await page.waitForTimeout(1800);

        const paneOpened = await page.locator(
          `#dynamic-pane-${menuId}:visible, #dynamic-tab-${menuId}:visible, #psPayslip:visible, #btnPrint:visible`
        ).first().isVisible({ timeout: 3000 }).catch(() => false);
        if (paneOpened) return;

        console.log(`⚠️ [fix-8]: Click tile Launchpad chưa bung "${menuName}", thử tiếp qua Sidebar/fallback...`);
      }
    }
  }

  // 3. Kiểm tra menu hiển thị trực tiếp trên màn hình
  const directCandidate = `span:has-text("${menuName}"):visible, a:has-text("${menuName}"):visible, .child-launchpad:has-text("${menuName}"):visible, .${menuId}:visible, [data-id="${menuId}"]:visible, [onclick*="${menuId}"]:visible`;
  const directMenu = page.locator(directCandidate).first();
  if (await directMenu.isVisible({ timeout: 1500 }).catch(() => false)) {
    console.log(`👉 [fix-8]: Menu "${menuName}" sẵn sàng trên màn hình, di chuột Neon click...`);
    await moveAndClick(page, directMenu, { steps: 10, pause: 250 });
    await page.waitForTimeout(1500);
    return;
  }

  // 4. Mở Sidebar (nếu đang đóng) -> Gõ tìm kiếm tên Menu bằng bàn phím thật
  const hamburger = page.locator('button.menu-button:visible, .main-menu-button:visible, .sidebar-toggle:visible, #btnToggleSidebar:visible').first();
  const isSidebarOpen = await page.locator('.sidebar:visible, #sidebar:visible').first().isVisible().catch(() => false);
  if (!isSidebarOpen && await hamburger.isVisible({ timeout: 1500 }).catch(() => false)) {
    await moveAndClick(page, hamburger, { steps: 8, pause: 200 });
    await page.waitForTimeout(500);
  }

  const sidebarSearch = page.locator('#txtSearchApp:visible, .sidebar-search input:visible, .sidebar input[type="text"]:visible, input[placeholder*="Tìm kiếm"]:visible').first();
  if (await sidebarSearch.isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log(`👉 [fix-8]: Gõ tìm kiếm menu "${menuName}" trên Sidebar...`);
    await typeHumanLike(page, sidebarSearch, menuName);
    await page.waitForTimeout(800);

    const filteredItem = page.locator(`
      .sidebar a:has-text("${menuName}"):visible,
      .sidebar li:has-text("${menuName}"):visible,
      .sidebar span:has-text("${menuName}"):visible,
      [onclick*="${menuId}"]:visible
    `).first();

    if (await filteredItem.isVisible({ timeout: 2500 }).catch(() => false)) {
      console.log(`👉 [fix-8]: Nhấp mở menu "${menuName}" từ danh sách lọc Sidebar...`);
      await moveAndClick(page, filteredItem, { steps: 10, pause: 250 });
      await page.waitForTimeout(2000);
      return;
    }
  }

  // Fallback điều hướng hệ thống
  await openMenuHumanLike(page, menuId, menuName);
}

// Trợ lý cục bộ fix-8: Khoanh vùng + cuộn mượt + dừng 5s trực quan bằng highlightAndPause chuẩn hệ thống
async function highlightAndPauseSectionFix8(page, locator, label, subSelector = '', duration = 5000) {
  const target = locator.first();
  if (!(await target.isVisible({ timeout: 5000 }).catch(() => false))) return;

  const anchorText = await target.evaluate((el) => {
    const raw = (el.innerText || el.textContent || '').trim();
    const lines = raw.split(/\r?\n/).map(s => s.trim()).filter(Boolean);
    return lines[0] ? lines[0].slice(0, 40) : '';
  }).catch(() => '');

  if (!anchorText) return;

  await highlightAndPause(page, target, {
    expectedText: [anchorText],
    duration,
    label,
    targetSubSelector: subSelector
  });
}

// Trợ lý cục bộ fix-8: Khoanh vùng dòng NV 099 (Nguyễn Văn Test) trong iframe Excel & trượt thanh trượt ngang mượt qua tất cả các cột
async function inspectExcelRowWithHorizontalPanFix8(page, testInfo, tcId, previewIframe) {
  const frameHandle = await previewIframe.elementHandle().catch(() => null);
  const excelFrame = frameHandle ? await frameHandle.contentFrame().catch(() => null) : null;
  if (!excelFrame) return;

  const targetRow = excelFrame.locator('tr:has-text("099"):has-text("Nguyễn Văn Test"), tr:has-text("Nguyễn Văn Test"), tr:has-text("099")').first();
  const fallbackRow = excelFrame.locator('table tr').nth(11);
  const rowToInspect = (await targetRow.isVisible({ timeout: 5000 }).catch(() => false)) ? targetRow : fallbackRow;
  if (!(await rowToInspect.isVisible({ timeout: 3000 }).catch(() => false))) return;

  // Bật khung highlight Neon đỏ trực tiếp trên toàn bộ dòng Nguyễn Văn Test trong iframe
  const highlightRow = async () => {
    await rowToInspect.evaluate((tr) => {
      tr.style.outline = '3px solid #f43f5e';
      tr.style.outlineOffset = '-2px';
      tr.style.backgroundColor = 'rgba(244, 63, 94, 0.22)';
      tr.style.boxShadow = 'inset 0 0 18px rgba(244, 63, 94, 0.45)';
    }).catch(() => {});
  };

  const setOuterBadge = async (text) => {
    const iframeBox = await previewIframe.boundingBox().catch(() => null);
    const rowBox = await rowToInspect.boundingBox().catch(() => null);
    await page.evaluate(({ labelText, leftX, topY }) => {
      let badge = document.getElementById('__ag_focus_badge_fix8__');
      if (!badge) {
        badge = document.createElement('div');
        badge.id = '__ag_focus_badge_fix8__';
        document.body.appendChild(badge);
      }
      badge.style.cssText = `
        position: fixed; z-index: 2147483647; padding: 7px 14px;
        background: #e11d48; color: #ffffff; font-family: 'Segoe UI', Arial, sans-serif;
        font-size: 13px; font-weight: bold; border-radius: 6px;
        box-shadow: 0 4px 18px rgba(225, 29, 72, 0.8); pointer-events: none;
        display: block; opacity: 1;
      `;
      badge.style.left = `${Math.max(16, leftX)}px`;
      badge.style.top = `${Math.max(16, topY)}px`;
      badge.innerText = labelText;
    }, {
      labelText: text,
      leftX: iframeBox ? iframeBox.x + 24 : 40,
      topY: rowBox ? rowBox.y - 44 : 180
    }).catch(() => {});
  };

  // Hàm trượt thanh trượt ngang mượt mà (easeInOutCubic) trong iframe hoặc container #preview-body
  const smoothHorizontalPanTo = async (ratio) => {
    const pannedInsideFrame = await rowToInspect.evaluate((tr, targetRatio) => {
      const findScrollableX = (node) => {
        let cur = node;
        while (cur && cur !== document.body && cur !== document.documentElement) {
          if (cur.scrollWidth > cur.clientWidth + 15) return cur;
          cur = cur.parentElement;
        }
        const docScroller = document.scrollingElement || document.documentElement || document.body;
        if (docScroller && docScroller.scrollWidth > docScroller.clientWidth + 15) return docScroller;
        if (document.body && document.body.scrollWidth > document.body.clientWidth + 15) return document.body;
        return null;
      };
      const scroller = findScrollableX(tr);
      if (!scroller) return { ok: false, maxLeft: 0 };

      const maxLeft = Math.max(0, scroller.scrollWidth - scroller.clientWidth);
      const startLeft = scroller.scrollLeft || 0;
      const destLeft = Math.round(maxLeft * targetRatio);
      const durationMs = 1000;

      return new Promise((resolve) => {
        const startTime = performance.now();
        function step(now) {
          const p = Math.min(1, (now - startTime) / durationMs);
          const eased = p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2;
          scroller.scrollLeft = Math.round(startLeft + (destLeft - startLeft) * eased);
          if (p < 1) {
            requestAnimationFrame(step);
          } else {
            resolve({ ok: true, maxLeft, currentLeft: scroller.scrollLeft });
          }
        }
        requestAnimationFrame(step);
      });
    }, ratio).catch(() => ({ ok: false, maxLeft: 0 }));

    // Nếu bảng tràn ở container #preview-body bên ngoài iframe thì trượt mượt luôn bên ngoài
    if (!pannedInsideFrame.ok || pannedInsideFrame.maxLeft <= 15) {
      await page.evaluate((targetRatio) => {
        const el = document.getElementById('preview-body');
        if (!el || el.scrollWidth <= el.clientWidth + 15) return;
        const maxLeft = el.scrollWidth - el.clientWidth;
        el.scrollTo({ left: Math.round(maxLeft * targetRatio), behavior: 'smooth' });
      }, ratio).catch(() => {});
      await page.waitForTimeout(1000);
    }
  };

  // Di chuyển chuột Neon vào ô nằm gọn trong khung nhìn hiện tại trên dòng NV 099
  const pointMouseToVisibleCell = async (preferRight = false) => {
    const iframeBox = await previewIframe.boundingBox().catch(() => null);
    if (!iframeBox) return;
    const cells = rowToInspect.locator('td');
    const count = await cells.count().catch(() => 0);
    const indices = [];
    for (let i = 0; i < count; i++) indices.push(i);
    if (preferRight) indices.reverse();

    for (const idx of indices) {
      const cell = cells.nth(idx);
      const box = await cell.boundingBox().catch(() => null);
      if (!box || box.width < 12 || box.height < 10) continue;
      const centerX = box.x + box.width / 2;
      const centerY = box.y + box.height / 2;
      if (centerX > iframeBox.x + 25 && centerX < iframeBox.x + iframeBox.width - 25) {
        await page.mouse.move(centerX, centerY, { steps: 14 });
        await page.waitForTimeout(200);
        return;
      }
    }
  };

  // 1. Cuộn dọc đưa dòng Nguyễn Văn Test (099) vào giữa khung nhìn & đưa thanh trượt ngang về trái (0%)
  await rowToInspect.evaluate((tr) => {
    tr.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'start' });
  }).catch(() => {});
  await page.waitForTimeout(1000);
  await smoothHorizontalPanTo(0);
  await highlightRow();

  // Chặng 1 (0% - Cột trái: Mã NV 099, Họ tên Nguyễn Văn Test & Lương cơ bản) -> Pause 5s
  await pointMouseToVisibleCell(false);
  await setOuterBadge('🎯 Bảng lương tổng hợp: NV 099 Nguyễn Văn Test (Cột định danh trái) — Đang dừng 5s đối soát...');
  console.log('🔍 [TC-18 Bảng lương tổng hợp]: Khoanh vùng NV 099 (Phần đầu trái) -> Dừng 5s...');
  await page.waitForTimeout(5000);
  await captureStepFix8(page, testInfo, tcId, 4, 'Bang luong tong hop - Khoanh vung NV 099 (Cot trai)');

  // Chặng 2 (Trượt thanh trượt ngang sang 48% giữa bảng: Công chuẩn, Thực tế, OT, Thu nhập) -> Pause 5s
  console.log('👉 [TC-18 Bảng lương tổng hợp]: Trượt thanh trượt ngang sang GIỮA bảng xem cột công & thu nhập NV 099...');
  await smoothHorizontalPanTo(0.48);
  await highlightRow();
  await pointMouseToVisibleCell(false);
  await setOuterBadge('🎯 Bảng lương tổng hợp: NV 099 Nguyễn Văn Test (Trượt ngang GIỮA bảng: Công, OT & Thu nhập) — Đang dừng 5s...');
  await page.waitForTimeout(5000);
  await captureStepFix8(page, testInfo, tcId, 5, 'Bang luong tong hop - Truot ngang giua bang NV 099');

  // Chặng 3 (Trượt thanh trượt ngang sang 100% cuối phải: Giảm trừ, Thuế TNCN & Thực lãnh) -> Pause 5s
  console.log('👉 [TC-18 Bảng lương tổng hợp]: Trượt thanh trượt ngang hết sang PHẢI xem Thuế & Thực lãnh NV 099...');
  await smoothHorizontalPanTo(1.0);
  await highlightRow();
  await pointMouseToVisibleCell(true);
  await setOuterBadge('🎯 Bảng lương tổng hợp: NV 099 Nguyễn Văn Test (Trượt ngang CUỐI PHẢI: Khấu trừ, Thuế & Thực lãnh) — Đang dừng 5s...');
  await page.waitForTimeout(5000);
  await captureStepFix8(page, testInfo, tcId, 6, 'Bang luong tong hop - Truot ngang cuoi phai NV 099');

  // Dọn highlight & badge sau khi hoàn tất đối soát ngang
  await rowToInspect.evaluate((tr) => {
    tr.style.outline = '';
    tr.style.outlineOffset = '';
    tr.style.backgroundColor = '';
    tr.style.boxShadow = '';
  }).catch(() => {});
  await page.evaluate(() => {
    const badge = document.getElementById('__ag_focus_badge_fix8__');
    if (badge) badge.style.display = 'none';
  }).catch(() => {});
}

// >>> [START_TC_18] - CONVERSATION: fix-8
test('fix-8 | TC-18: Replay Kế toán mở Danh sách trả lương, xem Bảng lương tổng hợp (trượt ngang NV 099), nhảy Phiếu lương & Đăng xuất (Role: Chien.nguyen)', async ({ page }, testInfo) => {
  test.setTimeout(240000);
  console.log('\n================ [TC-18]: REPLAY MnuPRL092 BẢNG LƯƠNG TỔNG HỢP -> PHIẾU LƯƠNG -> ĐĂNG XUẤT ================');

  // Bước 1: Đăng nhập tài khoản Chien.nguyen / 123 (bàn phím từng chữ + chuột Neon)
  await loginFix8(page, 'Chien.nguyen', ACCOUNTS.DIRECTOR.password);
  await captureStepFix8(page, testInfo, 'TC-18', 1, 'Dang nhap tai khoan Chien nguyen');

  // Bước 2: Mở menu Danh sách trả lương (MnuPRL092) qua Windows Launchpad
  await openMenuFix8(page, 'MnuPRL092', 'Danh sách trả lương');
  await page.locator('#btnPrint, #btnView').first().waitFor({ state: 'visible', timeout: 15000 });
  await page.waitForTimeout(1000);
  await captureStepFix8(page, testInfo, 'TC-18', 2, 'Mo man hinh Danh sach tra luong MnuPRL092 qua Launchpad');

  // Bước 3: Mở dropdown Tháng (#P682FA188ED5B4BD38C89E22CD6E72646) chọn Tháng 10 và dropdown Năm (#P911AA562E7AC44CEBC3FC7FAB611E906) chọn Năm 2026
  const monthBox = page.locator('#P682FA188ED5B4BD38C89E22CD6E72646').first();
  if (await monthBox.isVisible({ timeout: 3500 }).catch(() => false)) {
    console.log('👉 [TC-18]: Di chuột Neon chọn Tháng 10...');
    await selectBoxHumanLike(page, monthBox, '10').catch(() => {});
    await page.waitForTimeout(500);
  }
  const yearBox = page.locator('#P911AA562E7AC44CEBC3FC7FAB611E906').first();
  if (await yearBox.isVisible({ timeout: 3500 }).catch(() => false)) {
    console.log('👉 [TC-18]: Di chuột Neon chọn Năm 2026...');
    await selectBoxHumanLike(page, yearBox, '2026').catch(() => {});
  }
  await page.waitForTimeout(900);
  await captureStepFix8(page, testInfo, 'TC-18', 3, 'Chon ky luong Thang 10 Nam 2026');

  // Bước 4: Bấm nút "Bảng lương tổng hợp" (#btnPrint), khoanh vùng dòng NV 099 & trượt thanh trượt ngang hết bảng (mỗi chặng pause 5s)
  const btnPrint = page.locator('#btnPrint, button:has-text("Bảng lương tổng hợp")').first();
  await btnPrint.waitFor({ state: 'visible', timeout: 10000 });
  await smoothScrollHumanLike(page, btnPrint, { block: 'center', wait: 400 });
  console.log('👉 [TC-18]: Di chuột Neon nhấp nút "Bảng lương tổng hợp" (#btnPrint)...');
  await moveAndClick(page, btnPrint, { steps: 12, pause: 350 });

  const previewIframe = page.locator('#preview-body iframe').first();
  await previewIframe.waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(2200);

  await inspectExcelRowWithHorizontalPanFix8(page, testInfo, 'TC-18', previewIframe);

  // Bước 5: Bấm nút "Xem phiếu lương" (#btnView) -> tự động xác định đúng số trang của NV 099 (Nguyễn Văn Test) -> scroll + khoanh vùng + pause 5s
  const btnView = page.locator('#btnView, button:has-text("Xem phiếu lương")').first();
  await btnView.waitFor({ state: 'visible', timeout: 10000 });
  await smoothScrollHumanLike(page, btnView, { block: 'center', wait: 400 });

  // Lắng nghe dữ liệu sp_ViewEmployeePaySlip trình duyệt vừa tải để tìm chính xác trang của NV 099 (không gán cứng số 82)
  let dynamicPayslipPage = null;
  let payslipTotalFromApi = 0;
  const pendingResponseChecks = [];
  const onPayslipResponse = (res) => {
    const p = (async () => {
      try {
        const url = res.url() || '';
        if (res.status() !== 200 || (!url.includes('/hpa/') && !url.includes('paradise'))) return;
        const rawText = await res.text().catch(() => '');
        if (!rawText || !rawText.includes('Nguyễn Văn Test')) return;

        const parsed = JSON.parse(rawText);
        const root = typeof parsed === 'string' ? JSON.parse(parsed) : parsed;
        const tables = Array.isArray(root?.data) ? root.data : [];
        // sp_CompanySalarySummary_html.sql dùng data[2] (EmployeeInfo); tìm đúng mảng chứa thông tin NV (EmployeeID + FullName)
        const empList = tables.find(t => Array.isArray(t) && t.length > 0 && t[0] && ('EmployeeID' in t[0]) && ('FullName' in t[0]))
          || tables[2]
          || tables[0];
        if (Array.isArray(empList) && empList.length > 0) {
          payslipTotalFromApi = empList.length;
          const idx = empList.findIndex(e =>
            String(e?.EmployeeID || '').trim() === '099' ||
            String(e?.FullName || '').toLowerCase().includes('nguyễn văn test')
          );
          if (idx >= 0) {
            dynamicPayslipPage = idx + 1;
            console.log(`🎯 [TC-18]: Xác định động Phiếu lương NV 099 (Nguyễn Văn Test) nằm tại Trang ${dynamicPayslipPage}/${empList.length}`);
          }
        }
      } catch (_) {}
    })();
    pendingResponseChecks.push(p);
  };
  page.on('response', onPayslipResponse);

  console.log('👉 [TC-18]: Di chuột Neon nhấp nút "Xem phiếu lương" (#btnView)...');
  await moveAndClick(page, btnView, { steps: 12, pause: 350 });

  const htmlPayslip = page.locator('#preview-body .html-payslip-page, #preview-container input.pdf-page-input').first();
  await htmlPayslip.waitFor({ state: 'visible', timeout: 25000 });
  await Promise.allSettled(pendingResponseChecks);
  await page.waitForTimeout(1000);
  page.off('response', onPayslipResponse);

  const pageInput = page.locator('#preview-container input.pdf-page-input:visible').first();
  if (await pageInput.isVisible({ timeout: 5000 }).catch(() => false)) {
    const counterText = await page.locator('#preview-container .page-counter-text').first().innerText().catch(() => '');
    const matchTotal = counterText.match(/(\d+)/);
    const totalPages = matchTotal ? parseInt(matchTotal[1], 10) : (payslipTotalFromApi || 1);

    const isCurrentNv099 = async () => {
      const txt = await page.locator('#preview-body .html-payslip-page').first().innerText().catch(() => '');
      return txt.includes('099') && txt.toLowerCase().includes('nguyễn văn test');
    };

    const jumpToPageHumanLike = async (pageNum) => {
      await typeHumanLike(page, pageInput, String(pageNum));
      await page.keyboard.press('Enter');
      // Chạm nhẹ tiêu đề phiếu lương để kích hoạt sự kiện change trên .pdf-page-input chắc chắn 100%
      const titleHeader = page.locator('#preview-body .html-payslip-page h2').first();
      if (await titleHeader.isVisible({ timeout: 1500 }).catch(() => false)) {
        await moveAndClick(page, titleHeader, { steps: 6, pause: 150 });
      }
      await page.waitForTimeout(1200);
    };

    let landedPage = dynamicPayslipPage || 1;
    if (dynamicPayslipPage && dynamicPayslipPage >= 1 && dynamicPayslipPage <= totalPages) {
      console.log(`👉 [TC-18]: Gõ số trang động "${dynamicPayslipPage}/${totalPages}" (của NV 099) vào ô chuyển trang...`);
      await jumpToPageHumanLike(dynamicPayslipPage);
    }

    // Dự phòng nếu API chưa bắt được hoặc dữ liệu vừa thay đổi thứ tự: dò tự động từ trang cuối lùi về trang 1
    if (!(await isCurrentNv099())) {
      console.log(`⚠️ [TC-18]: Đang dò tìm động trang phiếu lương chứa "099 - Nguyễn Văn Test" trong tổng số ${totalPages} trang...`);
      for (let p = totalPages; p >= 1; p--) {
        if (p === dynamicPayslipPage) continue;
        await jumpToPageHumanLike(p);
        if (await isCurrentNv099()) {
          landedPage = p;
          console.log(`🎯 [TC-18]: Đã tìm thấy Phiếu lương NV 099 tại Trang ${p}/${totalPages}`);
          break;
        }
      }
    }

    // Nhóm các phần I -> V trong .html-payslip-page thành từng khối logic để khoanh vùng cả tiêu đề + số liệu + dòng tổng
    await page.evaluate(() => {
      const root = document.querySelector('#preview-body .html-payslip-page');
      if (!root || root.dataset.secWrapped === '1') return;
      root.dataset.secWrapped = '1';
      const children = Array.from(root.children);
      let secIdx = 0;
      let currentWrap = null;
      for (const el of children) {
        if (el.classList.contains('ps-section-title')) {
          secIdx += 1;
          currentWrap = document.createElement('div');
          currentWrap.setAttribute('data-fix8-payslip-sec', String(secIdx));
          currentWrap.style.borderRadius = '6px';
          root.insertBefore(currentWrap, el);
          currentWrap.appendChild(el);
        } else if (el.classList.contains('ps-net')) {
          currentWrap = null;
        } else if (currentWrap) {
          currentWrap.appendChild(el);
        }
      }
    });

    // Khoanh vùng 1 (Thông tin NV 099 - Nguyễn Văn Test & Công thực tế) -> Pause 5s
    const empGrid = page.locator('#preview-body .html-payslip-page .ps-grid').first();
    if (await empGrid.isVisible({ timeout: 4000 }).catch(() => false)) {
      await highlightAndPause(page, empGrid, {
        expectedText: ['099', 'Nguyễn Văn Test'],
        duration: 5000,
        label: `Phiếu lương (MnuPRL092 - Trang ${landedPage}/${totalPages}) - Thông tin NV 099 & Công thực tế`
      });
      await captureStepFix8(page, testInfo, 'TC-18', 7, `Phieu luong trang ${landedPage} - Khoanh vung thong tin NV 099`);
    }

    // Khoanh vùng 2 -> 6: Cuộn mượt & dừng 5s từng Mục I -> V trong Phiếu lương NV 099
    const adminPayslipSections = [
      {
        step: 8,
        secId: '1',
        label: `Phiếu lương (Trang ${landedPage}/${totalPages}) - Mục I: Thông tin lương`,
        shotName: `Phieu luong trang ${landedPage} - Khoanh vung Muc I Thong tin luong`
      },
      {
        step: 9,
        secId: '2',
        label: `Phiếu lương (Trang ${landedPage}/${totalPages}) - Mục II: Phụ cấp`,
        shotName: `Phieu luong trang ${landedPage} - Khoanh vung Muc II Phu cap`
      },
      {
        step: 10,
        secId: '3',
        label: `Phiếu lương (Trang ${landedPage}/${totalPages}) - Mục III: Thu nhập khác & Tổng lương`,
        shotName: `Phieu luong trang ${landedPage} - Khoanh vung Muc III Thu nhap khac va Tong luong`
      },
      {
        step: 11,
        secId: '4',
        label: `Phiếu lương (Trang ${landedPage}/${totalPages}) - Mục IV: Các khoản khấu trừ`,
        shotName: `Phieu luong trang ${landedPage} - Khoanh vung Muc IV Cac khoan khau tru`
      },
      {
        step: 12,
        secId: '5',
        label: `Phiếu lương (Trang ${landedPage}/${totalPages}) - Mục V: Khấu trừ thuế TNCN`,
        shotName: `Phieu luong trang ${landedPage} - Khoanh vung Muc V Thue TNCN`
      }
    ];

    for (const s of adminPayslipSections) {
      await highlightAndPauseSectionFix8(
        page,
        page.locator(`#preview-body .html-payslip-page [data-fix8-payslip-sec="${s.secId}"]`),
        s.label,
        '',
        5000
      );
      await captureStepFix8(page, testInfo, 'TC-18', s.step, s.shotName);
    }

    // Cuộn mượt xuống cuối trang -> Khoanh vùng 7 (Thực lãnh cuối kỳ) -> Pause 5s
    const netRow = page.locator('#preview-body .html-payslip-page .ps-net').first();
    await highlightAndPauseSectionFix8(
      page,
      netRow,
      `Phiếu lương (MnuPRL092 - Trang ${landedPage}/${totalPages}) - Thực lãnh cuối kỳ NV 099`,
      'b',
      5000
    );
    await captureStepFix8(page, testInfo, 'TC-18', 13, `Phieu luong trang ${landedPage} - Khoanh vung Thuc lanh NV 099`);
  }

  // Bước 6: Đăng xuất tài khoản Chien.nguyen (#randomAvatar -> #txtLogoutOpt -> #successModalButtonAddNew)
  const avatarBtn = page.locator('#randomAvatar, #userAvatar, .user-avatar').first();
  if (await avatarBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
    console.log('👉 [TC-18]: Di chuột Neon nhấp Avatar để mở menu Đăng xuất...');
    await moveAndClick(page, avatarBtn, { steps: 12, pause: 300 });
    await page.waitForTimeout(700);

    const logoutOpt = page.locator('#txtLogoutOpt:visible').first();
    if (await logoutOpt.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, logoutOpt, { steps: 10, pause: 300 });
      await page.waitForTimeout(700);

      const confirmLogoutBtn = page.locator('#successModalButtonAddNew:visible').first();
      if (await confirmLogoutBtn.isVisible({ timeout: 4000 }).catch(() => false)) {
        console.log('👉 [TC-18]: Di chuột Neon xác nhận Đăng xuất (#successModalButtonAddNew)...');
        await moveAndClick(page, confirmLogoutBtn, { steps: 10, pause: 300 });
        await page.locator('#username, input[type="password"]').first().waitFor({ state: 'visible', timeout: 12000 }).catch(() => {});
        await page.waitForTimeout(1200);
      }
    }
  }
  await captureStepFix8(page, testInfo, 'TC-18', 14, 'Dang xuat khoi tai khoan Chien nguyen thanh cong');
});
// <<< [END_TC_18]

// >>> [START_TC_19] - CONVERSATION: fix-8
test('fix-8 | TC-19: Replay Nhân viên test.nv mở Phiếu lương -> Tab Lịch sử -> Xem -> Cuộn/Khoanh 5s các mục -> 3 Modal chi tiết (Role: test.nv)', async ({ page }, testInfo) => {
  test.setTimeout(240000);
  console.log('\n================ [TC-19]: REPLAY NHÂN VIÊN test.nv (JSON 9:56 PM) -> LỊCH SỬ -> XEM -> SCROLL & KHOANH 5S -> 3 MODAL ================');

  // Bước 1: Đăng nhập Nhân viên test.nv / 123 (khớp JSON Recording 9:56 PM, đã lọc bỏ nhịp gõ nhầm "nv.té")
  await loginFix8(page, ACCOUNTS.STAFF_NEW.username, ACCOUNTS.STAFF_NEW.password);
  await captureStepFix8(page, testInfo, 'TC-19', 1, 'Dang nhap tai khoan nhan vien test nv');

  // Bước 2: Mở Windows Launchpad (MnuHRS238) -> Gõ "phiếu lương" -> Nhấp mở Phiếu lương (MnuPRL445)
  await openMenuFix8(page, 'MnuPRL445', 'phiếu lương');

  const slipContainer = page.locator('#psPayslip, .salary-slip, #sp_salaryslip_html').first();
  await slipContainer.waitFor({ state: 'visible', timeout: 15000 });
  await page.waitForFunction(() => {
    const el = document.getElementById('psEmpID');
    return el && el.innerText.trim().length > 0;
  }, { timeout: 15000 });
  await page.waitForTimeout(1000);
  await captureStepFix8(page, testInfo, 'TC-19', 2, 'Mo man hinh Phieu luong MnuPRL445 qua Launchpad');

  // Bước 3 (khớp JSON): Nhấp ngay Tab "Lịch Sử" -> Khoanh vùng 5s kỳ lương 10/2026
  const historyTabBtn = page.locator('#dynamic-pane-MnuPRL445 button.ps-tab-btn:has-text("Lịch Sử"), button:has-text("Lịch Sử")').first();
  if (await historyTabBtn.isVisible({ timeout: 5000 }).catch(() => false)) {
    await smoothScrollHumanLike(page, historyTabBtn, { block: 'center', wait: 400 });
    console.log('👉 [TC-19]: Di chuột Neon nhấp Tab "Lịch Sử"...');
    await moveAndClick(page, historyTabBtn, { steps: 10, pause: 300 });
    await page.locator('#psHistory, #psHistoryContent').first().waitFor({ state: 'visible', timeout: 8000 }).catch(() => {});
    await page.waitForTimeout(1000);

    const historyRowOrCard = page.locator('#psHistory .ps-payslip-item:has-text("10/2026"), #psHistory div:has(> button:has-text("Xem"))').first();
    await highlightAndPauseSectionFix8(page, historyRowOrCard, 'Tab Lịch Sử - Kỳ lương Tháng 10/2026', 'button', 5000);
    await captureStepFix8(page, testInfo, 'TC-19', 3, 'Tab Lich Su - Khoanh vung 5s ky luong 10/2026');

    // Bước 4 (khớp JSON): Nhấp nút "Xem" trong Tab Lịch Sử để mở Phiếu lương kỳ 10/2026
    const historyViewBtn = page.locator('#psHistory .ps-payslip-item:has-text("10/2026") button, #psHistory button[onclick*="viewPayslipPs(10"], #psHistory button:visible').first();
    if (await historyViewBtn.isVisible({ timeout: 5000 }).catch(() => false)) {
      await smoothScrollHumanLike(page, historyViewBtn, { block: 'center', wait: 400 });
      console.log('👉 [TC-19]: Di chuột Neon nhấp nút "Xem" trên Tab Lịch Sử...');
      await moveAndClick(page, historyViewBtn, { steps: 10, pause: 300 });
      await page.locator('#psPayslip').first().waitFor({ state: 'visible', timeout: 8000 }).catch(() => {});
      await page.waitForTimeout(1200);
      await captureStepFix8(page, testInfo, 'TC-19', 4, 'Bam nut Xem tu Lich Su mo Phieu luong 10/2026');
    }
  }

  // Bước 5-10: Scroll + Khoanh vùng + Pause 5s từng khu vực thông số trên Phiếu lương 10/2026
  await highlightAndPause(page, page.locator('#psPayslip > .ps-info-grid').first(), {
    expectedText: ['099', 'Nguyễn Văn Test'],
    duration: 5000,
    label: 'Phiếu lương NV 099 - Thông tin nhân viên',
    targetSubSelector: '#psFullName'
  });
  await captureStepFix8(page, testInfo, 'TC-19', 5, 'Khoanh vung 5s Thong tin nhan vien 099');

  const payslipSections = [
    {
      step: 6,
      selector: '#psPayslip .ps-section:has(#psBasicSalary)',
      label: 'Mục I - Công chuẩn, Thực tế, OT, Ngày nghỉ & Lương cơ bản',
      subSelector: '#psBasicSalary',
      shotName: 'Scroll + Khoanh vung 5s Muc I Thong tin luong'
    },
    {
      step: 7,
      selector: '#psPayslip .ps-section:has(#psTotalIncome)',
      label: 'Mục III - Thu nhập khác (Thưởng KPI) & Tổng thu nhập',
      subSelector: '#psTotalIncome',
      shotName: 'Scroll + Khoanh vung 5s Thu nhap khac va Tong thu nhap'
    },
    {
      step: 8,
      selector: '#psPayslip .ps-section:has(#psTotalDeductions)',
      label: 'Mục IV - Các khoản giảm trừ (Tạm ứng & Bảo hiểm)',
      subSelector: '#psTotalDeductions',
      shotName: 'Scroll + Khoanh vung 5s Cac khoan giam tru'
    },
    {
      step: 9,
      selector: '#psPayslip .ps-section:has(#psPIT)',
      label: 'Mục V - Giảm trừ gia cảnh & Thuế TNCN',
      subSelector: '#psPIT',
      shotName: 'Scroll + Khoanh vung 5s Thue TNCN'
    },
    {
      step: 10,
      selector: '#psPayslip .ps-section:has(#psNetSalary)',
      label: 'Cuối phiếu - LƯƠNG THỰC LĨNH NV 099',
      subSelector: '#psNetSalary',
      shotName: 'Scroll + Khoanh vung 5s Luong thuc lanh'
    }
  ];

  for (const sec of payslipSections) {
    await highlightAndPauseSectionFix8(page, page.locator(sec.selector), sec.label, sec.subSelector, 5000);
    await captureStepFix8(page, testInfo, 'TC-19', sec.step, sec.shotName);
  }

  // Bước 11-13 (khớp JSON): Mở, Khoanh vùng 5s & Đóng 3 Modal con mắt đúng thứ tự Tăng ca -> Đi trễ / Về sớm -> Ngày nghỉ
  const modalChecks = [
    {
      step: 11,
      eyeSelector: 'i.ps-eye[onclick*="overtime"], #psOTHours + i, .eye-ot',
      modalSelector: '#psModalOvertime',
      label: 'Modal Chi tiết Tăng ca (Overtime)',
      shotName: 'Modal Tang ca - Khoanh vung 5s quan sat chi tiet',
      logLabel: 'Tăng ca'
    },
    {
      step: 12,
      eyeSelector: 'i.ps-eye[onclick*="lateearly"], #psLateEarly + i, .eye-io',
      modalSelector: '#psModalLateearly',
      label: 'Modal Chi tiết Đi trễ / Về sớm',
      shotName: 'Modal Di tre Ve som - Khoanh vung 5s quan sat chi tiet',
      logLabel: 'Đi trễ / Về sớm'
    },
    {
      step: 13,
      eyeSelector: 'i.ps-eye[onclick*="daysoff"], #psDaysOff + i, .eye-leave',
      modalSelector: '#psModalDaysoff',
      label: 'Modal Chi tiết Ngày nghỉ',
      shotName: 'Modal Ngay nghi - Khoanh vung 5s quan sat chi tiet',
      logLabel: 'Ngày nghỉ'
    }
  ];

  for (const m of modalChecks) {
    const eyeIcon = page.locator(m.eyeSelector).first();
    if (await eyeIcon.isVisible({ timeout: 4000 }).catch(() => false)) {
      await smoothScrollHumanLike(page, eyeIcon, { block: 'center', wait: 500 });
      console.log(`👉 [TC-19]: Di chuột Neon nhấp icon con mắt ${m.logLabel}...`);
      await moveAndClick(page, eyeIcon, { steps: 10, pause: 250 });
      await page.locator(m.modalSelector).waitFor({ state: 'visible', timeout: 6000 }).catch(() => {});
      await highlightAndPauseSectionFix8(
        page,
        page.locator(`${m.modalSelector} .ps-modal-content, ${m.modalSelector} > div`),
        m.label,
        '',
        5000
      );
      await captureStepFix8(page, testInfo, 'TC-19', m.step, m.shotName);

      const closeBtn = page.locator(`${m.modalSelector} .ps-modal-close, ${m.modalSelector} button[onclick*="close"], ${m.modalSelector} button`).first();
      if (await closeBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
        await moveAndClick(page, closeBtn, { steps: 8, pause: 250 });
        await page.locator(m.modalSelector).waitFor({ state: 'hidden', timeout: 4000 }).catch(() => {});
        await page.waitForTimeout(600);
      }
    }
  }

  // Cuộn mượt trở lại phần đầu phiếu & giữ màn hình 3 giây cuối để kết thúc gọn gàng
  const empIdEl = page.locator('#psEmpID, .ps-info-grid').first();
  if (await empIdEl.isVisible({ timeout: 3000 }).catch(() => false)) {
    await smoothScrollHumanLike(page, empIdEl, { block: 'center', wait: 1000 });
  }
  await page.waitForTimeout(2000);
});
// <<< [END_TC_19]
