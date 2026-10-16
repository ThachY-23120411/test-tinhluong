const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

/**
 * CRM BATCH CRAWLER (PERFECTED WITH OpenAppInSidebar IDs)
 * Tự động mở Chrome, đăng nhập Chien.nguyen, kích hoạt dock Trang chủ CRM,
 * và cào tuần tự 36 menu thuộc phân hệ CRM bằng mã App ID chính xác.
 */

const CRM_MENUS = [
  { id: 'MnuKPI001', code: 'CRM-01', name: 'Tổng quan CRM', group: 'Trang chủ CRM' },
  { id: 'MnuKPI012', code: 'CRM-02', name: 'Theo dõi dịch vụ', group: 'Trang chủ CRM' },
  { id: 'MnuKPI003', code: 'CRM-03', name: 'Dữ liệu khách hàng', group: 'Trang chủ CRM' },
  { id: 'MnuKPI007', code: 'CRM-04', name: 'Sales Pipeline', group: 'Trang chủ CRM' },
  { id: 'MnuKPI447', code: 'CRM-05', name: 'Doanh số', group: 'Trang chủ CRM' },
  // Nhóm Nhiệm vụ
  { id: 'MnuKPI045', code: 'CRM-06', name: 'Gửi tin nhắn zalo tự động', group: 'Nhiệm vụ' },
  { id: 'MnuKPI048', code: 'CRM-07', name: 'Sản phẩm marketing', group: 'Nhiệm vụ' },
  { id: 'MnuKPI049', code: 'CRM-08', name: 'Lịch sử tin AI tạo tin nhắn', group: 'Nhiệm vụ' },
  { id: 'MnuKPI002', code: 'CRM-09', name: 'Email gửi thủ công', group: 'Nhiệm vụ' },
  { id: 'MnuKPI005', code: 'CRM-10', name: 'Nội dung đăng tải', group: 'Nhiệm vụ' },
  { id: 'MnuKPI006', code: 'CRM-11', name: 'Các cuộc họp', group: 'Nhiệm vụ' },
  { id: 'MnuKPI015', code: 'CRM-12', name: 'Import bất thường', group: 'Nhiệm vụ' },
  // Nhóm Dữ liệu GoogleMaps
  { id: 'MnuHRS036', code: 'CRM-13', name: 'Thu thập dữ liệu', group: 'Dữ liệu GoogleMaps' },
  { id: 'MnuHRS064', code: 'CRM-14', name: 'Lọc dữ liệu', group: 'Dữ liệu GoogleMaps' },
  // Nhóm Báo giá
  { id: 'MnuCSM004', code: 'CRM-15', name: 'Báo giá phần mềm', group: 'Báo giá' },
  { id: 'MnuCSM005', code: 'CRM-16', name: 'Thêm/Sửa báo giá', group: 'Báo giá' },
  { id: 'MnuCSM003', code: 'CRM-17', name: 'Quản lý phân hệ', group: 'Báo giá' },
  { id: 'MnuKPI446', code: 'CRM-18', name: 'Thêm/Sửa phân hệ', group: 'Báo giá' },
  // Nhóm Kho
  { id: 'MnuKPI017', code: 'CRM-19', name: 'Danh mục sản phẩm', group: 'Kho' },
  { id: 'MnuKPI019', code: 'CRM-20', name: 'Lịch sử nhập kho', group: 'Kho' },
  { id: 'MnuKPI021', code: 'CRM-21', name: 'Lịch sử xuất kho', group: 'Kho' },
  // Nhóm Hỗ trợ
  { id: 'MnuHRS32389', code: 'CRM-22', name: 'Tổng quan hỗ trợ', group: 'Hỗ trợ' },
  { id: 'MnuHRS3250', code: 'CRM-23', name: 'Hướng dẫn sử dụng', group: 'Hỗ trợ' },
  { id: 'MnuHRS3237', code: 'CRM-24', name: 'Danh sách hỗ trợ', group: 'Hỗ trợ' },
  { id: 'MnuTM036', code: 'CRM-25', name: 'Thư ký cuộc họp', group: 'Hỗ trợ' },
  // Nhóm Thiết lập
  { id: 'MnuKPI449', code: 'CRM-26', name: 'Danh sách công ty CRM', group: 'Thiết lập' },
  { id: 'MnuTM037', code: 'CRM-27', name: 'Zalo', group: 'Thiết lập' },
  { id: 'MnuKPI041', code: 'CRM-28', name: 'Thêm/Sửa liên hệ nhân viên', group: 'Thiết lập' },
  { id: 'MnuHRS3239', code: 'CRM-29', name: 'Gửi lời mời', group: 'Thiết lập' },
  { id: 'MnuHRS3240', code: 'CRM-30', name: 'Các loại dịch vụ bán hàng', group: 'Thiết lập' },
  { id: 'MnuKPI010', code: 'CRM-31', name: 'Các email theo dõi KPI', group: 'Thiết lập' },
  { id: 'MnuKPI016', code: 'CRM-32', name: 'Thiết lập KPI nhân viên', group: 'Thiết lập' },
  { id: 'MnuKPI035', code: 'CRM-33', name: 'Loại chi tiết hợp đồng', group: 'Thiết lập' },
  { id: 'MnuKPI037', code: 'CRM-34', name: 'Loại sản phẩm', group: 'Thiết lập' },
  { id: 'MnuKPI040', code: 'CRM-35', name: 'Danh sách nhân viên kinh doanh', group: 'Thiết lập' },
  { id: 'MnuKPI448', code: 'CRM-36', name: 'Theo dõi lead Marketing', group: 'Thiết lập' }
];

async function crawlCrmSuite(targetMenuFilter = null) {
  const outputDir = path.resolve(__dirname, '../docs/raw_crawled/crm');
  fs.mkdirSync(outputDir, { recursive: true });

  const envPath = path.resolve(__dirname, '../test.env.json');
  const env = fs.existsSync(envPath) ? JSON.parse(fs.readFileSync(envPath, 'utf8')) : {};
  const baseUrl = env.baseUrl || 'https://paradisehrm.com/Tai3/#';
  const auth = (env.roles && env.roles.admin) || env.auth || { username: 'Chien.nguyen', password: '123' };

  console.log(`\n====================================================================`);
  console.log(`🚀 [CRM SUITE CRAWLER V2] Khởi động trình duyệt Google Chrome...`);
  console.log(`🌐 Mục tiêu: ${baseUrl}`);
  console.log(`👤 Tài khoản: ${auth.username}`);
  console.log(`📂 Thư mục xuất dữ liệu: ${outputDir}`);
  console.log(`====================================================================\n`);

  const browser = await chromium.launch({
    headless: false,
    channel: 'chrome',
    slowMo: 30,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  let currentNetworkCalls = [];
  page.on('request', request => {
    if (['xhr', 'fetch'].includes(request.resourceType())) {
      const postData = request.postData();
      currentNetworkCalls.push({
        type: 'request',
        url: request.url(),
        method: request.method(),
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

      currentNetworkCalls.push({
        type: 'response',
        url: response.url(),
        status: response.status(),
        responseBody: body,
        timestamp: new Date().toISOString()
      });
    }
  });

  const manifest = [];

  try {
    // 1. Mở trang web và đăng nhập
    console.log(`🌐 Đang tải trang ${baseUrl}...`);
    await page.goto(baseUrl, { waitUntil: 'domcontentloaded', timeout: 45000 });
    await page.waitForTimeout(2000);

    if (await page.locator('#username').isVisible().catch(() => false)) {
      console.log(`🔑 Đăng nhập với tài khoản: ${auth.username}...`);
      await page.fill('#username', auth.username);
      await page.fill('input[type="password"]', auth.password);
      await page.click('#submitLogin');
      await page.waitForTimeout(4000);
      console.log(`✅ Đăng nhập thành công!`);
    }

    // 2. Kích hoạt phân hệ Trang chủ CRM trên Dock
    console.log(`📂 Kích hoạt dock icon "Trang chủ CRM" (MnuKPI000)...`);
    const crmDockIcon = page.locator('.dock .icon.MnuKPI000, .icon.MnuKPI000, [data-code="MnuKPI000"]').first();
    if (await crmDockIcon.isVisible({ timeout: 5000 }).catch(() => false)) {
      await crmDockIcon.click();
      await page.waitForTimeout(2500);
    }

    const menusToCrawl = targetMenuFilter 
      ? CRM_MENUS.filter(m => m.name.toLowerCase().includes(targetMenuFilter.toLowerCase()) || m.code.toLowerCase() === targetMenuFilter.toLowerCase())
      : CRM_MENUS;

    console.log(`\n📋 Sẽ tiến hành kích hoạt và cào sâu ${menusToCrawl.length} menu trong CRM...\n`);

    for (let idx = 0; idx < menusToCrawl.length; idx++) {
      const menu = menusToCrawl[idx];
      console.log(`--------------------------------------------------------------------`);
      console.log(`[${idx + 1}/${menusToCrawl.length}] 🎯 ĐANG CÀO MENU: "${menu.name}" (${menu.code} - ${menu.id})`);
      
      currentNetworkCalls = [];

      // KÍCH HOẠT MỞ ỨNG DỤNG BẰNG OpenAppInSidebar(menu.id)
      let clickSuccess = false;
      try {
        const opened = await page.evaluate((appId) => {
          if (typeof window.OpenAppInSidebar === 'function') {
            window.OpenAppInSidebar(appId);
            return true;
          }
          const el = document.getElementById(appId);
          if (el) {
            el.click();
            return true;
          }
          return false;
        }, menu.id);

        if (opened) {
          clickSuccess = true;
          console.log(`👉 Kích hoạt OpenAppInSidebar('${menu.id}') thành công!`);
        } else {
          // Thử click phần tử li theo ID
          const liEl = page.locator(`#${menu.id} a, #${menu.id}`).first();
          if (await liEl.isVisible({ timeout: 2000 }).catch(() => false)) {
            await liEl.click();
            clickSuccess = true;
          }
        }
      } catch (err) {
        console.log(`⚠️ Lỗi khi mở ${menu.id}:`, err.message);
      }

      // Đợi nạp dữ liệu và phản hồi mạng
      await page.waitForTimeout(3000);

      // Chụp ảnh màn hình
      const safeSlug = slugify(menu.name);
      const screenshotPath = path.join(outputDir, `${menu.code}_${safeSlug}.png`);
      await page.screenshot({ path: screenshotPath, fullPage: false }).catch(() => {});

      // Bóc tách cấu trúc màn hình
      const mainScreenData = await extractScreenStructure(page, menu.name);

      // Dò và kích hoạt modal ẩn
      const modalDataList = await scanAndExtractModals(page);

      // Phân tích Data Lineage
      const dataLineage = await analyzeDataLineage(page, mainScreenData, currentNetworkCalls, menu.name);

      // Lọc API nghiệp vụ
      const relevantApiCalls = filterRelevantApiCalls(currentNetworkCalls);

      const menuReport = {
        code: menu.code,
        appId: menu.id,
        menuName: menu.name,
        group: menu.group,
        clickSuccess,
        crawledAt: new Date().toISOString(),
        screenshot: `${menu.code}_${safeSlug}.png`,
        mainScreen: mainScreenData,
        modals: modalDataList,
        dataLineage,
        apiNetworkCalls: relevantApiCalls
      };

      const jsonPath = path.join(outputDir, `${menu.code}_${safeSlug}.json`);
      fs.writeFileSync(jsonPath, JSON.stringify(menuReport, null, 2), 'utf8');

      manifest.push({
        code: menu.code,
        appId: menu.id,
        name: menu.name,
        group: menu.group,
        fieldsCount: mainScreenData.fields.length,
        modalsCount: modalDataList.length,
        apiCallsCount: relevantApiCalls.length,
        isDownstream: dataLineage.isDownstreamScreen,
        roleHint: dataLineage.detectedMetadata?.createdby || dataLineage.detectedMetadata?.createdbyrole || null,
        file: `${menu.code}_${safeSlug}.json`
      });

      console.log(`✅ Hoàn tất: ${mainScreenData.fields.length} trường | ${modalDataList.length} modal | ${relevantApiCalls.length} API calls`);
      if (dataLineage.isDownstreamScreen) {
        console.log(`   ⚠️ Màn hình HẠ NGUỒN: ${dataLineage.recommendation}`);
      }
    }

    // Ghi Manifest tổng hợp
    const manifestPath = path.join(outputDir, `crm_manifest.json`);
    fs.writeFileSync(manifestPath, JSON.stringify({
      totalMenus: manifest.length,
      crawledAt: new Date().toISOString(),
      menus: manifest
    }, null, 2), 'utf8');

    console.log(`\n====================================================================`);
    console.log(`🎉 [CRM SUITE CRAWLER V2] HOÀN TẤT CÀO 36/36 MENU PHÂN HỆ CRM!`);
    console.log(`📁 File Manifest: ${manifestPath}`);
    console.log(`====================================================================\n`);

    return manifest;
  } finally {
    await browser.close();
  }
}

// BÓC TÁCH CẤU TRÚC TRƯỜNG & NÚT BẤM TỪ TRANG
async function extractScreenStructure(page, contextName) {
  return await page.evaluate(({ ctxName }) => {
    const fields = [];
    const buttons = [];
    const root = document;

    const formItems = root.querySelectorAll(`
      .dx-field, .dx-form-group, .form-group, .form-item, tr, .field-wrapper,
      .sec-field, .dx-item.dx-field-item, .filter-item, .dx-toolbar-item
    `);

    function getLabel(el) {
      const labelEl = el.querySelector('label, .dx-field-item-label, .dx-field-item-label-text, .control-label, th, .label, .dx-button-text');
      if (labelEl) return labelEl.innerText.replace(/[*:]/g, '').trim();
      const placeholder = el.querySelector('input, textarea')?.getAttribute('placeholder');
      if (placeholder) return placeholder.trim();
      return '';
    }

    function detectControlType(el) {
      if (el.classList.contains('dx-selectbox') || el.querySelector('.dx-selectbox, select')) return 'Dropdown / SelectBox';
      if (el.classList.contains('dx-datebox') || el.querySelector('.dx-datebox, input[type="date"]')) return 'DatePicker / DateBox';
      if (el.classList.contains('dx-numberbox') || el.querySelector('.dx-numberbox, input[type="number"]')) return 'NumberInput';
      if (el.classList.contains('dx-checkbox') || el.querySelector('.dx-checkbox, input[type="checkbox"]')) return 'CheckBox';
      if (el.classList.contains('dx-radiogroup') || el.querySelector('.dx-radiogroup, input[type="radio"]')) return 'RadioGroup';
      if (el.classList.contains('dx-textarea') || el.querySelector('textarea, .dx-textarea')) return 'TextArea';
      return 'TextBox (Text / String)';
    }

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

    const buttonElements = root.querySelectorAll('button, .dx-button, a.btn, input[type="submit"]');
    buttonElements.forEach(btn => {
      const text = btn.innerText ? btn.innerText.trim() : btn.getAttribute('value') || '';
      if (text && text.length > 1 && text.length < 50 && !buttons.includes(text)) {
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

// TỰ ĐỘNG DÒ VÀ MỞ CÁC MODAL ẨN
async function scanAndExtractModals(page) {
  const modalDataList = [];
  const editBtns = page.locator('button, a, .dx-button').filter({
    hasText: /chỉnh sửa|sửa|thêm|thêm mới|tạo mới|chi tiết|cập nhật|edit|create|add|new|tạo|báo giá/i
  });

  const btnCount = Math.min(await editBtns.count().catch(() => 0), 4);
  for (let i = 0; i < btnCount; i++) {
    const btn = editBtns.nth(i);
    if (!(await btn.isVisible().catch(() => false))) continue;
    const btnText = (await btn.innerText().catch(() => '')).trim();

    try {
      await btn.click({ timeout: 3000 });
      await page.waitForTimeout(1500);

      const activeModal = page.locator('.dx-overlay-content:visible, .modal.show, .modal:visible, div[role="dialog"]:visible').first();
      if (await activeModal.isVisible({ timeout: 2500 }).catch(() => false)) {
        const modalTitle = (await activeModal.locator('.dx-toolbar-label, .modal-title, h4, h5, .title').first().innerText().catch(() => `Modal Form ${btnText}`)).trim();
        const modalData = await extractScreenStructure(page, `Modal: ${modalTitle}`);
        modalDataList.push({
          triggerButton: btnText,
          modalTitle,
          data: modalData
        });

        const closeBtn = activeModal.locator('.dx-closebutton, button.close, button:has-text("Đóng"), button:has-text("Hủy"), .btn-close').first();
        if (await closeBtn.isVisible().catch(() => false)) {
          await closeBtn.click();
          await page.waitForTimeout(800);
        } else {
          await page.keyboard.press('Escape');
          await page.waitForTimeout(600);
        }
      }
    } catch (_) {}
  }
  return modalDataList;
}

// PHÂN TÍCH DATA LINEAGE
async function analyzeDataLineage(page, mainScreenData, networkCalls, menuName) {
  const hasTable = await page.evaluate(() => {
    return document.querySelectorAll('table, .dx-datagrid, .dx-grid, [role="grid"], .grid').length > 0;
  }).catch(() => false);

  const hasCreateButton = mainScreenData.buttons.some(b => 
    /thêm|tạo|add|create|new|đăng ký/i.test(b)
  );

  const isDownstream = hasTable && !hasCreateButton;
  const findings = {
    isDownstreamScreen: isDownstream,
    hasDataTable: hasTable,
    hasCreateButton: hasCreateButton,
    detectedMetadata: {},
    inferredStoredProcedures: [],
    recommendation: ''
  };

  const metaKeys = ['createdby', 'createdbyrole', 'created_by', 'submittedby', 'status', 'state', 'sourcetype', 'origin', 'requesttype', 'approvalstatus'];
  
  for (const call of networkCalls) {
    if (!call.url) continue;

    const spMatch = call.url.match(/(sp_[a-zA-Z0-9_]+)/i);
    if (spMatch && !findings.inferredStoredProcedures.includes(spMatch[1])) {
      findings.inferredStoredProcedures.push(spMatch[1]);
    }

    if (call.responseBody) {
      scanObject(call.responseBody, metaKeys, findings.detectedMetadata);
    }
  }

  if (isDownstream) {
    let roleHint = findings.detectedMetadata.createdby || findings.detectedMetadata.createdbyrole || 'Khách hàng / Nhân viên nộp đơn';
    findings.recommendation = `Màn hình "${menuName}" là màn hình Hạ nguồn (chỉ xem/duyệt danh sách). Dữ liệu nhiều khả năng do vai trò "${roleHint}" tạo ra từ chức năng thượng nguồn.`;
  } else {
    findings.recommendation = `Màn hình "${menuName}" có sẵn form tạo/nhập dữ liệu trực tiếp.`;
  }

  return findings;
}

function scanObject(obj, targetKeys, result, depth = 0) {
  if (!obj || depth > 3) return;
  if (Array.isArray(obj)) {
    obj.slice(0, 3).forEach(item => scanObject(item, targetKeys, result, depth + 1));
    return;
  }
  if (typeof obj === 'object') {
    for (const [key, val] of Object.entries(obj)) {
      const lower = key.toLowerCase();
      if (targetKeys.includes(lower) && (typeof val === 'string' || typeof val === 'number')) {
        if (!result[lower]) result[lower] = String(val);
      } else if (typeof val === 'object') {
        scanObject(val, targetKeys, result, depth + 1);
      }
    }
  }
}

function filterRelevantApiCalls(calls) {
  const filtered = [];
  for (const c of calls) {
    if (!c.url) continue;
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
    return str.slice(0, 400);
  }
}

function slugify(text) {
  return (text || 'general')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
}

// CLI EXECUTION
if (require.main === module) {
  const args = process.argv.slice(2);
  let filter = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--filter' && args[i + 1]) filter = args[i + 1];
  }
  crawlCrmSuite(filter).catch(err => {
    console.error('Fatal Error:', err);
    process.exit(1);
  });
}

module.exports = { crawlCrmSuite };
