const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

/**
 * CRAWLER ENGINE — ĐẢO NGƯỢC NGHIỆP VỤ & BÓC TÁCH GIAO DIỆN (UI REVERSE ENGINEERING)
 * Tự động mở trình duyệt, cào cấu trúc DOM, bóc tách Form fields, Dropdowns,
 * Validation rules ngầm, và bắt trọn API Network Requests / Stored Procedures.
 */

async function runCrawler(options = {}) {
  const envPath = path.resolve(__dirname, '../test.env.json');
  let env = {};
  if (fs.existsSync(envPath)) {
    env = JSON.parse(fs.readFileSync(envPath, 'utf8'));
  }

  const targetUrl = options.url || env.baseUrl || 'https://paradisehrm.com/Tai3/#';
  const menuTarget = options.menu || '';
  const outputDir = path.resolve(__dirname, `../docs/raw_crawled`);
  fs.mkdirSync(outputDir, { recursive: true });

  console.log(`🌐 [CRAWLER] Khởi chạy Chrome để cào nghiệp vụ: ${targetUrl}`);
  if (menuTarget) console.log(`🎯 [CRAWLER] Mục tiêu phân hệ: "${menuTarget}"`);

  const browser = await chromium.launch({
    headless: false,
    channel: 'chrome',
    slowMo: 50,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  // BỘ THU THẬP NETWORK (API CONTRACTS & STORED PROCEDURES)
  const networkCalls = [];
  page.on('request', request => {
    const url = request.url();
    const method = request.method();
    if (['xhr', 'fetch'].includes(request.resourceType())) {
      const postData = request.postData();
      networkCalls.push({
        type: 'request',
        url,
        method,
        resourceType: request.resourceType(),
        postData: postData ? tryParseJson(postData) : null,
        timestamp: new Date().toISOString()
      });
    }
  });

  page.on('response', async response => {
    const req = response.request();
    if (['xhr', 'fetch'].includes(req.resourceType())) {
      let body = null;
      try {
        const text = await response.text();
        body = tryParseJson(text);
      } catch (_) {}

      networkCalls.push({
        type: 'response',
        url: response.url(),
        status: response.status(),
        responseBody: body,
        timestamp: new Date().toISOString()
      });
    }
  });

  try {
    // 1. Mở trang web
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded', timeout: 45000 });
    await page.waitForTimeout(2000);

    // 2. Tự động đăng nhập nếu có form login
    if (env.auth && (await page.locator(env.auth.usernameSelector || '#username').isVisible().catch(() => false))) {
      console.log('🔑 [CRAWLER] Tự động đăng nhập với tài khoản:', env.auth.username);
      await page.fill(env.auth.usernameSelector || '#username', env.auth.username);
      await page.fill(env.auth.passwordSelector || 'input[type="password"]', env.auth.password);
      await page.click(env.auth.submitSelector || '#submitLogin');
      await page.locator('.dock, .navbar, body').first().waitFor({ state: 'visible', timeout: 30000 });
      await page.waitForTimeout(2500);
      console.log('✅ [CRAWLER] Đăng nhập thành công!');
    }

    // 3. Nếu có chỉ định tên Menu, tự động tìm và click mở menu
    if (menuTarget) {
      console.log(`📂 [CRAWLER] Đang tìm kiếm và mở menu: "${menuTarget}"...`);
      const menuLocator = page.locator(`text="${menuTarget}"`).first();
      if (await menuLocator.isVisible({ timeout: 5000 }).catch(() => false)) {
        await menuLocator.click();
        await page.waitForTimeout(3000);
        console.log(`✅ [CRAWLER] Đã kích hoạt menu: "${menuTarget}"`);
      }
    }

    // 4. BÓC TÁCH MÀN HÌNH CHÍNH (MAIN SCREEN EXTRACTION)
    console.log('🔍 [CRAWLER] Bắt đầu bóc tách cấu trúc trường và dữ liệu màn hình chính...');
    const mainScreenData = await extractPageStructure(page, 'Main Screen');

    // 5. TÌM VÀ KÍCH HOẠT CÁC MODAL / POPUP ĐỂ CÀO FORM CHI TIẾT
    console.log('🔍 [CRAWLER] Đang dò tìm các nút mở Form / Modal / Popup (Thêm, Sửa, Chỉnh sửa, Chi tiết)...');
    const modalDataList = [];
    const editBtns = page.locator('button, a, .dx-button').filter({
      hasText: /chỉnh sửa|sửa|thêm|thêm mới|tạo mới|chi tiết|cập nhật|edit|create|add|new/i
    });

    const btnCount = Math.min(await editBtns.count(), 8); // Quét tối đa 8 nút tiêu biểu
    for (let i = 0; i < btnCount; i++) {
      const btn = editBtns.nth(i);
      if (!(await btn.isVisible().catch(() => false))) continue;
      const btnText = (await btn.innerText().catch(() => '')).trim();

      try {
        console.log(`👉 [CRAWLER] Thử kích hoạt nút: "${btnText}" (Vị trí #${i + 1})...`);
        await btn.click({ timeout: 4000 });
        await page.waitForTimeout(2000);

        // Kiểm tra xem có popup / modal nào xuất hiện không
        const activeModal = page.locator('.dx-overlay-content:visible, .modal.show, .modal:visible, div[role="dialog"]:visible').first();
        if (await activeModal.isVisible({ timeout: 3000 }).catch(() => false)) {
          const modalTitle = (await activeModal.locator('.dx-toolbar-label, .modal-title, h4, h5, .title').first().innerText().catch(() => 'Modal Form')).trim();
          console.log(`✨ [CRAWLER] Phát hiện Modal: "${modalTitle}"! Bắt đầu cào chi tiết trường...`);

          const modalData = await extractPageStructure(page, `Modal: ${modalTitle}`, activeModal);
          modalDataList.push(modalData);

          // Đóng modal sau khi cào xong
          const closeBtn = activeModal.locator('.dx-closebutton, button.close, button:has-text("Đóng"), button:has-text("Hủy"), .btn-close').first();
          if (await closeBtn.isVisible().catch(() => false)) {
            await closeBtn.click();
            await page.waitForTimeout(1000);
          } else {
            await page.keyboard.press('Escape');
            await page.waitForTimeout(800);
          }
        }
      } catch (err) {
        console.log(`⚠️ [CRAWLER] Không thể mở hoặc đóng modal cho nút #${i + 1}:`, err.message);
      }
    }

    // 6. TỔNG HỢP KẾT QUẢ ĐẦY ĐỦ
    const safeMenuName = (menuTarget || 'general')
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');

    const finalReport = {
      targetUrl,
      menuTarget: menuTarget || 'Toàn bộ trang',
      crawledAt: new Date().toISOString(),
      mainScreen: mainScreenData,
      modals: modalDataList,
      apiNetworkCalls: filterRelevantApiCalls(networkCalls)
    };

    const resultPath = path.join(outputDir, `${safeMenuName}.json`);
    fs.writeFileSync(resultPath, JSON.stringify(finalReport, null, 2), 'utf8');

    console.log('\n====================================================================');
    console.log(`🎉 [CRAWLER] HOÀN TẤT CÀO NGHIỆP VỤ THÀNH CÔNG!`);
    console.log(`📁 File kết quả cấu trúc JSON đã được lưu tại:`);
    console.log(`   ${resultPath}`);
    console.log(`📊 Số trường màn hình chính: ${mainScreenData.fields.length}`);
    console.log(`📊 Số Modal phát hiện và bóc tách: ${modalDataList.length}`);
    console.log(`📡 Số API/Stored Procedure bắt được: ${finalReport.apiNetworkCalls.length}`);
    console.log('====================================================================\n');

    return finalReport;
  } finally {
    await browser.close();
  }
}

// HÀM BÓC TÁCH CẤU TRÚC FORM & TRƯỜNG TRỰC TIẾP TỪ DOM VÀ JAVASCRIPT OBJECTS
async function extractPageStructure(page, contextName, rootLocator = null) {
  return await page.evaluate(({ ctxName }) => {
    const fields = [];
    const buttons = [];
    const root = document;

    // 1. Quét toàn bộ Form Controls (Standard HTML + DevExtreme + AntD + Bootstrap)
    const formItems = root.querySelectorAll(`
      .dx-field, .dx-form-group, .form-group, .form-item, tr, .field-wrapper,
      .sec-field, .dx-item.dx-field-item
    `);

    // Helper trích xuất nhãn (Label)
    function getLabel(el) {
      const labelEl = el.querySelector('label, .dx-field-item-label, .dx-field-item-label-text, .control-label, th, .label');
      if (labelEl) return labelEl.innerText.replace(/[*:]/g, '').trim();
      const placeholder = el.querySelector('input, textarea')?.getAttribute('placeholder');
      if (placeholder) return placeholder.trim();
      return '';
    }

    // Helper xác định kiểu UI Control
    function detectControlType(el) {
      if (el.classList.contains('dx-selectbox') || el.querySelector('.dx-selectbox, select')) return 'Dropdown / SelectBox';
      if (el.classList.contains('dx-datebox') || el.querySelector('.dx-datebox, input[type="date"]')) return 'DatePicker / DateBox';
      if (el.classList.contains('dx-numberbox') || el.querySelector('.dx-numberbox, input[type="number"]')) return 'NumberInput';
      if (el.classList.contains('dx-checkbox') || el.querySelector('.dx-checkbox, input[type="checkbox"]')) return 'CheckBox';
      if (el.classList.contains('dx-radiogroup') || el.querySelector('.dx-radiogroup, input[type="radio"]')) return 'RadioGroup';
      if (el.classList.contains('dx-textarea') || el.querySelector('textarea, .dx-textarea')) return 'TextArea';
      return 'TextBox (Text / String)';
    }

    // Helper trích xuất quy tắc validation
    function extractValidations(el, inputEl) {
      const rules = [];
      const isRequired = el.innerText.includes('*') ||
        el.querySelector('.dx-field-item-required-mark') !== null ||
        inputEl?.hasAttribute('required') ||
        el.querySelector('.dx-validator, [data-validate*="required"]') !== null;

      if (isRequired) rules.push('Bắt buộc nhập (*)');
      if (inputEl) {
        if (inputEl.maxLength > 0 && inputEl.maxLength < 10000) rules.push(`Tối đa ${inputEl.maxLength} ký tự`);
        if (inputEl.type === 'number') rules.push('Chỉ nhận giá trị số');
        if (inputEl.pattern) rules.push(`Định dạng Regex: ${inputEl.pattern}`);
      }
      return {
        isRequired,
        rulesString: rules.length > 0 ? rules.join(', ') : 'Tùy chọn (Optional)'
      };
    }

    formItems.forEach((item, idx) => {
      const inputEl = item.querySelector('input, textarea, select');
      const label = getLabel(item);
      if (!label && !inputEl) return;

      const controlType = detectControlType(item);
      const valInfo = extractValidations(item, inputEl);
      const currentValue = inputEl ? inputEl.value || '' : '';
      const isDisabled = (inputEl && (inputEl.disabled || inputEl.readOnly)) || item.classList.contains('dx-state-disabled');

      fields.push({
        index: idx + 1,
        label: label || `Trường #${idx + 1}`,
        controlType,
        state: isDisabled ? 'DISABLED' : 'ENABLED',
        required: valInfo.isRequired ? 'YES (*)' : 'NO',
        conditional: 'Hiển thị mặc định',
        sourceValidation: valInfo.rulesString,
        currentValue: currentValue.trim()
      });
    });

    // 2. Quét các nút bấm hành động (Action Buttons)
    const buttonElements = root.querySelectorAll('button, .dx-button, a.btn, input[type="submit"]');
    buttonElements.forEach(btn => {
      const text = btn.innerText ? btn.innerText.trim() : btn.getAttribute('value') || '';
      if (text && text.length < 50 && !buttons.includes(text)) {
        buttons.push(text.replace(/\n/g, ' '));
      }
    });

    return {
      contextName: ctxName,
      fields,
      buttons
    };
  }, { ctxName: contextName });
}

// LỌC CÁC API THỰC SỰ CHỨA LOGIC NGHIỆP VỤ (BỎ QUA FILE TĨNH .JS, .CSS, .PNG)
function filterRelevantApiCalls(calls) {
  const filtered = [];
  for (const c of calls) {
    if (!c.url) continue;
    // Bỏ qua static assets
    if (/\.(css|js|png|jpg|jpeg|gif|svg|woff|woff2|ttf|ico)(\?.*)?$/i.test(c.url)) continue;
    filtered.push(c);
  }
  return filtered;
}

function tryParseJson(str) {
  if (typeof str !== 'string') return str;
  try {
    return JSON.parse(str);
  } catch (_) {
    return str.slice(0, 500); // Lấy tối đa 500 ký tự nếu là text/form-urlencoded
  }
}

// Cho phép chạy trực tiếp từ dòng lệnh: node helpers/crawler_engine.cjs --menu "Hồ sơ nhân viên"
if (require.main === module) {
  const args = process.argv.slice(2);
  let menu = '';
  let url = '';
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--menu' && args[i + 1]) menu = args[i + 1];
    if (args[i] === '--url' && args[i + 1]) url = args[i + 1];
  }
  runCrawler({ menu, url }).catch(err => {
    console.error('❌ [CRAWLER ERROR]:', err);
    process.exit(1);
  });
}

module.exports = { runCrawler };
