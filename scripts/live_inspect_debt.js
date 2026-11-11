const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function main() {
  console.log('🚀 [LIVE INSPECT]: Khởi chạy Google Chrome thật để điều tra trực quan...');
  const browser = await chromium.launch({
    headless: false,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    slowMo: 100,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({
    viewport: null // Toàn màn hình
  });

  const page = await context.newPage();

  // Bắt tất cả các network response
  page.on('response', async (res) => {
    const url = res.url();
    if (url.includes('paradise') || url.includes('api') || url.includes('hpa')) {
      try {
        const text = await res.text();
        if (text.includes('sp_Debt_PaymentDebt') || text.includes('dp_grid') || text.includes('allowColumnResizing')) {
          console.log(`\n📥 [NETWORK RESPONSE] ${url}`);
          console.log(`   Status: ${res.status()}`);
          console.log(`   Contains allowColumnResizing: ${text.includes('allowColumnResizing')}`);
          console.log(`   Contains width 18%: ${text.includes('18%')}`);
          console.log(`   Length: ${text.length}`);
          fs.writeFileSync('scripts/last_network_html.txt', text, 'utf8');
        }
      } catch (e) {}
    }
  });

  page.on('console', msg => {
    const txt = msg.text();
    if (txt.includes('error') || txt.includes('Error') || txt.includes('dp_grid') || txt.includes('Debt')) {
      console.log(`🖥️ [BROWSER CONSOLE] ${msg.type()}: ${txt}`);
    }
  });

  // 1. Mở trang đăng nhập
  console.log('📍 Bước 1: Mở trang chủ Paradise HRM...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);

  // 2. Đăng nhập với ThanhLong (hoặc Chien.nguyen)
  if (await page.locator('#username').isVisible().catch(() => false)) {
    console.log('🔑 Đang đăng nhập tài khoản ThanhLong / 123...');
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);
  }

  // 3. Đóng tab cũ "Thanh toán công nợ" nếu đang mở (để ép web load lại HTML từ Server!)
  console.log('🔄 Bước 2: Kiểm tra và đóng tab cũ (nếu có) để ép tải lại...');
  const existingTabCloseBtn = page.locator('.nav-tabs li:has-text("Thanh toán công nợ") .close-tab, .nav-tabs li:has-text("Thanh toán công nợ") i.fa-times, .nav-tabs li:has-text("Thanh toán công nợ") [class*="close"]').first();
  if (await existingTabCloseBtn.isVisible().catch(() => false)) {
    console.log('   Đã bấm đóng tab cũ để clear cache RAM!');
    await existingTabCloseBtn.click();
    await page.waitForTimeout(1000);
  }

  // 4. Tìm và bấm menu "Đổi quà" -> "Thanh toán công nợ"
  console.log('📂 Bước 3: Tìm menu "Thanh toán công nợ" ở Sidebar trái...');
  // Mở group Đổi quà nếu chưa mở
  const doiQuaGroup = page.locator('.sidebar span:has-text("Đổi quà"), #sidebar span:has-text("Đổi quà"), a:has-text("Đổi quà")').first();
  if (await doiQuaGroup.isVisible().catch(() => false)) {
    await doiQuaGroup.click();
    await page.waitForTimeout(1000);
  }

  const thanhToanMenu = page.locator('span:has-text("Thanh toán công nợ"), a:has-text("Thanh toán công nợ")').first();
  await thanhToanMenu.waitFor({ state: 'visible', timeout: 10000 });
  await thanhToanMenu.click();
  console.log('   Đã bấm mở menu Thanh toán công nợ!');

  // 5. Chờ bảng #dp_grid xuất hiện
  console.log('⏳ Bước 4: Chờ bảng DataGrid hiển thị...');
  await page.locator('#dp_grid, #dp_grid_container').first().waitFor({ state: 'visible', timeout: 20000 });
  await page.waitForTimeout(3000);

  // 6. Kiểm tra các cột trong DevExtreme DataGrid instance
  console.log('🔍 Bước 5: Bóc tách thông số DataGrid Instance từ bộ nhớ RAM của Chrome...');
  const gridInfo = await page.evaluate(() => {
    const $grid = $('#dp_grid');
    if (!$grid.length) return { error: 'Không tìm thấy #dp_grid' };
    const inst = $grid.dxDataGrid('instance');
    if (!inst) return { error: 'Không lấy được dxDataGrid instance' };

    const opts = {
      columnAutoWidth: inst.option('columnAutoWidth'),
      allowColumnResizing: inst.option('allowColumnResizing'),
      columnResizingMode: inst.option('columnResizingMode'),
      columnHidingEnabled: inst.option('columnHidingEnabled'),
      columns: inst.option('columns').map(c => ({
        caption: c.caption,
        dataField: c.dataField,
        width: c.width,
        minWidth: c.minWidth,
        hidingPriority: c.hidingPriority
      }))
    };

    // Kiểm tra chiều rộng thực tế từng cột trong DOM (Rendered widths)
    const domCols = [];
    $('.dx-datagrid-headers .dx-header-row > td').each(function () {
      domCols.push({
        text: $(this).text().trim(),
        offsetWidth: $(this).outerWidth(),
        cssWidth: $(this).css('width')
      });
    });

    return { opts, domCols };
  });

  console.log('\n📊 THÔNG SỐ CẤU HÌNH GRID TRONG CHROME:');
  console.log(JSON.stringify(gridInfo.opts, null, 2));

  console.log('\n📏 CHIỀU RỘNG THỰC TẾ TRÊN DOM CỦA CÁC CỘT:');
  console.log(JSON.stringify(gridInfo.domCols, null, 2));

  // 7. Chụp ảnh màn hình thực tế
  const screenshotPath = 'scripts/live_grid_result.png';
  await page.screenshot({ path: screenshotPath, fullPage: false });
  console.log(`\n📸 Đã chụp ảnh màn hình kết quả tại: ${screenshotPath}`);

  await page.waitForTimeout(4000);
  await browser.close();
  console.log('✅ Hoàn tất điều tra trực quan!');
}

main().catch(console.error);
