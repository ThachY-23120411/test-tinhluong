const { chromium } = require('playwright');
const fs = require('fs');

async function main() {
  console.log('🚀 Khởi chạy Chrome để tái hiện bug bấm Làm mới / bấm lại menu...');
  const browser = await chromium.launch({
    headless: false,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    slowMo: 100,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  // Bắt console logs
  page.on('console', msg => {
    const text = msg.text();
    if (text.includes('Error') || text.includes('error') || text.includes('Debt') || text.includes('grid')) {
      console.log(`🖥️ [CONSOLE] ${msg.type()}: ${text}`);
    }
  });

  // Bắt network responses
  page.on('response', async res => {
    const url = res.url();
    if (url.includes('paradise') || url.includes('hpa')) {
      try {
        const text = await res.text();
        if (text.includes('sp_Debt_PaymentDebt') || text.includes('dp_grid')) {
          console.log(`📥 [NETWORK] ${url.substring(0, 100)}... (length: ${text.length})`);
        }
      } catch (e) {}
    }
  });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  if (await page.locator('#username').isVisible().catch(() => false)) {
    console.log('🔑 Đang đăng nhập...');
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  // Bước 1: Mở menu Thanh toán công nợ lần 1
  console.log('📍 Bước 1: Mở menu Thanh toán công nợ...');
  const navBtn = page.locator('[class*="MnuPRL409"], a[href*="MnuPRL409"], span:has-text("Thanh toán công nợ")').first();
  await navBtn.click({ force: true });
  await page.waitForTimeout(4000);

  async function getCols(stepName) {
    return await page.evaluate((step) => {
      const cols = [];
      $('.dx-datagrid-headers .dx-header-row > td').each(function () {
        cols.push({
          text: $(this).text().trim(),
          width: $(this).outerWidth()
        });
      });
      return { step, cols };
    }, stepName);
  }

  const step1 = await getCols('Sau khi mở tab lần 1');
  console.log('📊 Step 1 Cols:', JSON.stringify(step1, null, 2));
  await page.screenshot({ path: 'scripts/repro_step1_open.png' });

  // Bước 2: Bấm vào button "Làm mới"
  console.log('🔄 Bước 2: Bấm vào button "Làm mới"...');
  const refreshBtn = page.locator('button:has-text("Làm mới"), button[onclick*="loadDebtPaymentData"]').first();
  if (await refreshBtn.isVisible()) {
    await refreshBtn.click();
    console.log('   Đã bấm Làm mới!');
    await page.waitForTimeout(3000);
    const step2 = await getCols('Sau khi bấm Làm mới');
    console.log('📊 Step 2 Cols:', JSON.stringify(step2, null, 2));
    await page.screenshot({ path: 'scripts/repro_step2_refresh.png' });
  } else {
    console.log('⚠️ Không tìm thấy nút Làm mới');
  }

  // Bước 3: Bấm lại vào menu "Thanh toán công nợ" ở sidebar
  console.log('📂 Bước 3: Bấm lại vào menu "Thanh toán công nợ" ở sidebar...');
  await navBtn.click({ force: true });
  await page.waitForTimeout(3000);
  const step3 = await getCols('Sau khi bấm lại menu');
  console.log('📊 Step 3 Cols:', JSON.stringify(step3, null, 2));
  await page.screenshot({ path: 'scripts/repro_step3_click_menu_again.png' });

  await page.waitForTimeout(2000);
  await browser.close();
  console.log('🏁 Xong kiểm tra tái hiện!');
}

main().catch(console.error);
