const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function main() {
  console.log('🚀 Khởi chạy Chrome...');
  const browser = await chromium.launch({
    headless: false,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    slowMo: 50,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  // Bắt gói tin phản hồi chứa HTML hoặc script
  page.on('response', async (res) => {
    const url = res.url();
    if (url.includes('paradise') || url.includes('hpa') || url.includes('api')) {
      try {
        const text = await res.text();
        if (text.includes('sp_Debt_PaymentDebt') || text.includes('dp_grid') || text.includes('Debt_CustomerLabel')) {
          console.log(`\n📥 [AJAX RESPONSE]: ${url}`);
          console.log(`   Length: ${text.length}`);
          console.log(`   Has allowColumnResizing: ${text.includes('allowColumnResizing')}`);
          console.log(`   Has 18%: ${text.includes('18%')}`);
          fs.writeFileSync('scripts/last_debt_ajax.html', text, 'utf8');
        }
      } catch (e) {}
    }
  });

  console.log('📍 Mở trang chủ Paradise HRM...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(2000);

  // Đăng nhập
  if (await page.locator('#username').isVisible({ timeout: 3000 }).catch(() => false)) {
    console.log('🔑 Đang đăng nhập ThanhLong / 123...');
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  // Tìm cách kích hoạt menu Thanh toán công nợ (MnuPRL409)
  console.log('🔍 Điều hướng tới menu MnuPRL409...');
  
  // Kiểm tra xem tab có sẵn chưa
  const existingTab = page.locator('.nav-tabs li:has-text("Thanh toán công nợ"), #dynamic-tab-MnuPRL409, button:has-text("Thanh toán công nợ")').first();
  if (await existingTab.isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log('⚡ Tab đã mở sẵn, click kích hoạt...');
    await existingTab.click({ force: true });
  } else {
    // Thử click qua JS evaluate hoặc qua sidebar/dock
    const navResult = await page.evaluate(() => {
      // Tìm menu item trong sidebar / dock
      const el = document.querySelector('[class*="MnuPRL409"], a[href*="MnuPRL409"], [data-id*="MnuPRL409"]');
      if (el) {
        el.click();
        return 'Clicked selector: ' + el.outerHTML.substring(0, 80);
      }
      // Thử gọi hàm mở menu nếu có
      if (typeof window.fLoadTabMenu === 'function') {
        window.fLoadTabMenu('MnuPRL409');
        return 'Called fLoadTabMenu(MnuPRL409)';
      }
      if (typeof window.openMenu === 'function') {
        window.openMenu('MnuPRL409');
        return 'Called openMenu(MnuPRL409)';
      }
      // Tìm tất cả a hoặc span chứa text "Thanh toán công nợ"
      const all = Array.from(document.querySelectorAll('a, span, li, button'));
      const target = all.find(e => e.textContent && e.textContent.trim() === 'Thanh toán công nợ');
      if (target) {
        target.click();
        return 'Clicked text target: ' + target.outerHTML.substring(0, 80);
      }
      return 'Không tìm thấy menu MnuPRL409';
    });
    console.log('👉 Kết quả điều hướng:', navResult);
  }

  // Chờ bảng DataGrid hiển thị
  console.log('⏳ Chờ bảng #dp_grid...');
  try {
    await page.locator('#dp_grid, #dp_grid_container, .dx-datagrid').first().waitFor({ state: 'visible', timeout: 15000 });
    console.log('✅ Đã thấy DataGrid trên giao diện!');
  } catch (e) {
    console.log('⚠️ Chưa thấy #dp_grid xuất hiện tự động, chụp màn hình hiện tại...');
  }

  await page.waitForTimeout(3000);

  // Bóc tách thông tin DataGrid trong trình duyệt
  const gridReport = await page.evaluate(() => {
    const $grid = $('#dp_grid');
    if (!$grid.length) {
      return { found: false, html: document.body.innerText.substring(0, 300) };
    }
    const inst = $grid.dxDataGrid ? $grid.dxDataGrid('instance') : null;
    
    // Đo kích thước thực tế các cột từ DOM
    const cols = [];
    $('.dx-datagrid-headers .dx-header-row > td').each(function () {
      cols.push({
        text: $(this).text().trim(),
        width: $(this).outerWidth(),
        cssWidth: $(this).css('width')
      });
    });

    let configCols = [];
    if (inst) {
      configCols = (inst.option('columns') || []).map(c => ({
        caption: c.caption,
        width: c.width,
        minWidth: c.minWidth,
        hidingPriority: c.hidingPriority
      }));
    }

    return {
      found: true,
      gridWidth: $grid.outerWidth(),
      allowColumnResizing: inst ? inst.option('allowColumnResizing') : 'N/A',
      columnHidingEnabled: inst ? inst.option('columnHidingEnabled') : 'N/A',
      configCols,
      domCols: cols
    };
  });

  console.log('\n📊 THÔNG TIN BẢNG THỰC TẾ TRÊN CHROME:');
  console.log(JSON.stringify(gridReport, null, 2));

  // Chụp ảnh màn hình bằng chứng
  const screenshotPath = 'fix-bug/screenshot-2/actual_live_grid.png';
  await page.screenshot({ path: screenshotPath, fullPage: false });
  console.log(`📸 Đã chụp ảnh màn hình lưu tại: ${screenshotPath}`);

  await page.waitForTimeout(2000);
  await browser.close();
  console.log('🏁 Hoàn thành!');
}

main().catch(err => {
  console.error('LỖI:', err);
  process.exit(1);
});
