const { chromium } = require('playwright');
const fs = require('fs');

async function main() {
  console.log('🚀 [REPRODUCE EXACT STEPS]: Mở Google Chrome thật hiển thị trực quan...');
  const browser = await chromium.launch({
    headless: false,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    slowMo: 200,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  // Bắt tất cả network response để theo dõi xem có gói tin nào tải lại HTML cũ không
  page.on('response', async res => {
    const url = res.url();
    if (url.includes('paradise') || url.includes('hpa')) {
      try {
        const text = await res.text();
        if (text.includes('dp_grid') || text.includes('sp_Debt_PaymentDebt') || text.includes('Debt_CustomerLabel')) {
          console.log(`\n📥 [NETWORK] ${url.substring(0, 110)}...`);
          console.log(`   Length: ${text.length}`);
          console.log(`   Has width 18%: ${text.includes('18%')}`);
          console.log(`   Has allowColumnResizing: ${text.includes('allowColumnResizing')}`);
        }
      } catch (e) {}
    }
  });

  // 1. Vào trang web
  console.log('📍 Bước 1: Vào trang Paradise HRM...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  // 2. Đăng nhập ThanhLong / 123
  if (await page.locator('#username').isVisible().catch(() => false)) {
    console.log('🔑 Bước 2: Đăng nhập ThanhLong / 123...');
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  // 3. Thực hiện thao tác: localStorage.clear(); location.reload();
  console.log('🧹 Bước 3: Thực hiện: localStorage.clear(); location.reload()...');
  await page.evaluate(() => {
    localStorage.clear();
    location.reload();
  });
  await page.waitForLoadState('domcontentloaded');
  await page.waitForTimeout(3000);

  // Đăng nhập lại nếu bị logout sau reload
  if (await page.locator('#username').isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log('🔑 Đăng nhập lại sau reload...');
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  // 4. Mở menu Thanh toán công nợ
  console.log('📂 Bước 4: Mở menu Thanh toán công nợ...');
  await page.evaluate(() => {
    const el = document.querySelector('.icon.MnuPRL409, [class*="MnuPRL409"], a[href*="MnuPRL409"]');
    if (el) el.click();
    else if (typeof window.openMenu === 'function') window.openMenu('MnuPRL409');
  });

  // Chờ bảng hiển thị
  console.log('⏳ Chờ nạp dữ liệu bảng #dp_grid...');
  await page.waitForFunction(() => {
    const $grid = $('#dp_grid');
    return $grid.length && $grid.find('.dx-datagrid-headers td').length > 0;
  }, { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Helper đo kích thước DOM
  async function measureCols(label) {
    const result = await page.evaluate((lbl) => {
      const cols = [];
      $('.dx-datagrid-headers .dx-header-row > td').each(function () {
        cols.push({
          text: $(this).text().trim(),
          width: Math.round($(this).outerWidth() * 10) / 10,
          styleWidth: $(this).attr('style') || ''
        });
      });
      return { label: lbl, cols };
    }, label);
    return result;
  }

  const step4Data = await measureCols('SAU KHI CLEAR LOCAL & VỪA MỞ MENU');
  console.log('\n📊 KẾT QUẢ BƯỚC 4 (Vừa mở menu):');
  console.log(JSON.stringify(step4Data, null, 2));
  await page.screenshot({ path: 'scripts/exact_step4_after_clear_local.png' });

  // 5. BẤM VÀO BUTTON "LÀM MỚI"
  console.log('\n🔄 Bước 5: BẤM VÀO BUTTON "LÀM MỚI"...');
  const refreshBtn = page.locator('button:has-text("Làm mới"), button[onclick*="loadDebtPaymentData"]').first();
  await refreshBtn.waitFor({ state: 'visible', timeout: 5000 });
  
  // Highlight nút làm mới bằng viền đỏ dày
  await refreshBtn.evaluate(el => el.style.outline = '4px solid red');
  await page.waitForTimeout(1000);
  
  console.log('👉 Đang bấm click vào nút Làm mới...');
  await refreshBtn.click();
  console.log('   Đã click xong! Chờ 3 giây để API phản hồi và render lại...');
  await page.waitForTimeout(3000);

  const step5Data = await measureCols('SAU KHI BẤM NÚT LÀM MỚI');
  console.log('\n📊 KẾT QUẢ BƯỚC 5 (Sau khi bấm nút Làm mới):');
  console.log(JSON.stringify(step5Data, null, 2));
  await page.screenshot({ path: 'scripts/exact_step5_after_click_refresh.png' });

  // 6. Kiểm tra đối chiếu
  const w4 = step4Data.cols[0].width;
  const w5 = step5Data.cols[0].width;
  console.log(`\n🔍 ĐỐI CHIẾU CỘT KHÁCH HÀNG:`);
  console.log(`   Bước 4 (Vừa mở): ${w4}px`);
  console.log(`   Bước 5 (Sau bấm Làm mới): ${w5}px`);
  if (Math.abs(w4 - w5) > 50) {
    console.log(`🚨 PHÁT HIỆN LỖI: Độ rộng cột bị thay đổi đột ngột sau khi bấm Làm mới!`);
  } else {
    console.log(`✅ Độ rộng cột ổn định, không bị thay đổi sau khi bấm Làm mới.`);
  }

  await page.waitForTimeout(4000);
  await browser.close();
  console.log('🏁 Hoàn thành tái hiện!');
}

main().catch(console.error);
