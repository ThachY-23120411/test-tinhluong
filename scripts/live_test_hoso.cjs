const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

async function runLiveTest() {
  console.log('================================================================');
  console.log('🚀 ĐANG KHỞI ĐỘNG GOOGLE CHROME THẬT TRÊN MÀN HÌNH...');
  console.log('👀 Hãy nhìn màn hình: Trình duyệt Chrome sẽ xuất hiện và tự động đăng nhập!');
  console.log('================================================================\n');

  // Đưa Chrome lên foreground
  const psScript = path.resolve(__dirname, '../bring_to_front.ps1');
  if (fs.existsSync(psScript)) {
    const p = spawn('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript], { detached: true, stdio: 'ignore' });
    p.unref();
  }

  const browser = await chromium.launch({
    channel: 'chrome',
    headless: false,
    slowMo: 100,
    args: [
      '--start-maximized',
      '--no-sandbox',
      '--disable-setuid-sandbox'
    ]
  });

  const context = await browser.newContext({ viewport: null });

  // Nhúng con trỏ chuột neon phát sáng
  const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
  if (fs.existsSync(cursorScriptPath)) {
    const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
    await context.addInitScript(cursorScript);
  }

  const page = await context.newPage();

  const consoleLogs = [];
  const networkEvents = [];

  page.on('console', msg => {
    const text = `[Console ${msg.type()}]: ${msg.text()}`;
    consoleLogs.push(text);
    if (msg.type() === 'error') {
      console.log(`🚨 TRÌNH DUYỆT BÁO LỖI: ${msg.text()}`);
    }
  });

  page.on('pageerror', err => {
    console.log(`💥 FATAL JAVASCRIPT ERROR: ${err.message}`);
    consoleLogs.push(`[PAGE ERROR]: ${err.message}\nStack: ${err.stack}`);
  });

  page.on('response', async resp => {
    const u = resp.url();
    if (u.includes('paradise') || u.includes('Staff') || u.includes('hpa')) {
      networkEvents.push({ url: u, status: resp.status() });
      if (u.includes('HR_StaffInformation_ForUserWeb')) {
        console.log(`📡 WEB VỪA GỌI API LẤY HTML: ${u.substring(0, 150)}`);
        try {
          const body = await resp.text();
          const hasFix = body.includes('Khởi tạo an toàn đối tượng toàn cục HR_StaffInformation_ForUserWeb');
          console.log(`🔍 KIỂM TRA BẢN HTML TRẢ VỀ: ${hasFix ? '✅ ĐÃ CÓ BẢN MỚI' : '❌ VẪN LÀ BẢN CŨ CHƯA SỬA!'}`);
          console.log(`   Độ dài HTML nhận được: ${body.length} ký tự`);
        } catch (e) {}
      }
    }
  });

  try {
    const url = 'https://paradisehrm.com/Tai3/#';
    console.log(`🌐 1. Mở trang: ${url}`);
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);

    const userInput = page.locator('#username');
    if (await userInput.isVisible({ timeout: 5000 }).catch(() => false)) {
      console.log('⌨️ 2. Đăng nhập với tài khoản ThanhLong / 123');
      await userInput.click();
      await userInput.fill('');
      await userInput.pressSequentially('ThanhLong', { delay: 60 });
      await page.waitForTimeout(300);

      const passInput = page.locator('input[type="password"]');
      await passInput.click();
      await passInput.fill('');
      await passInput.pressSequentially('123', { delay: 60 });
      await page.waitForTimeout(300);

      await page.locator('#submitLogin').click();
      console.log('⏳ 3. Đang chờ hệ thống nạp dữ liệu vào trong...');
      await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 30000 });
      await page.waitForTimeout(3000);
    }

    console.log('🖱️ 4. Tìm và bấm vào biểu tượng "Cổng thông tin nhân sự" trên thanh Dock...');
    const hrsIcon = page.locator('.dock .icon.MnuHRS000, .dock .open-MnuHRS000, .dock .icon.MnuHRS002, .dock .open-MnuHRS002, .dock [class*="MnuHRS"]').first();
    if (await hrsIcon.isVisible({ timeout: 5000 }).catch(() => false)) {
      await hrsIcon.click();
      await page.waitForTimeout(2000);
    }

    console.log('🖱️ 5. Tìm và bấm vào menu "Hồ sơ cá nhân" ở sidebar bên trái...');
    const hosoItem = page.locator('text="Hồ sơ cá nhân"').first();
    if (await hosoItem.isVisible({ timeout: 8000 }).catch(() => false)) {
      await hosoItem.click();
      console.log('⏳ 6. Đang mở tab Hồ sơ cá nhân và theo dõi phản hồi...');
      await page.waitForTimeout(8000);
    } else {
      console.log('⚠️ Không tìm thấy menu Hồ sơ cá nhân');
    }

    // Kiểm tra xem trong DOM có render được gì không
    const domCheck = await page.evaluate(() => {
      const el = document.querySelector('#EmployeeProfile_P, #sp_HR_StaffInformation_List_2_html, [id*="HR_Staff"]');
      return {
        foundContainer: !!el,
        containerHTML: el ? el.innerHTML.substring(0, 300) : 'KHÔNG TÌM THẤY CONTAINER',
        allErrors: window.listError || []
      };
    });
    console.log('📊 KẾT QUẢ KIỂM TRA DOM TRÊN MÀN HÌNH:', domCheck);

    const evidenceDir = path.resolve(__dirname, '../test-evidence/hoso_canhan/live');
    fs.mkdirSync(evidenceDir, { recursive: true });
    await page.screenshot({ path: path.join(evidenceDir, 'live_screen.png') });
    console.log(`📸 Đã chụp ảnh màn hình lưu tại: ${path.join(evidenceDir, 'live_screen.png')}`);

    fs.writeFileSync(path.resolve(__dirname, '../scratch/live_console.txt'), consoleLogs.join('\n'), 'utf8');

    console.log('\n================================================================');
    console.log('🎯 KIỂM THỬ TRỰC QUAN HOÀN TẤT. TRÌNH DUYỆT SẼ ĐÓNG SAU 5 GIÂY...');
    console.log('================================================================\n');
    await page.waitForTimeout(5000);

  } catch (err) {
    console.error('Lỗi kiểm thử:', err.message);
  } finally {
    await browser.close();
  }
}

runLiveTest();
