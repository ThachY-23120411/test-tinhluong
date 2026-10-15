const { chromium } = require('C:/Users/Y.Thach/ZeroKitty/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

async function run() {
  console.log('================================================================');
  console.log('🚀 ĐANG KHỞI ĐỘNG GOOGLE CHROME THẬT TRỰC TIẾP TRÊN MÀN HÌNH...');
  console.log('👀 Hãy nhìn màn hình của bạn: Cửa sổ Chrome sẽ được bật lên trên cùng!');
  console.log('================================================================\n');

  // Kích hoạt tiến trình đưa Chrome lên Foreground (trên cùng)
  const psScript = path.resolve(__dirname, 'bring_to_front.ps1');
  if (fs.existsSync(psScript)) {
    const p = spawn('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript], { detached: true, stdio: 'ignore' });
    p.unref();
  }

  // Khởi động Google Chrome thật (headed: true, có cửa sổ)
  const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
  const launchOptions = {
    headless: false,
    slowMo: 90,
    args: [
      '--start-maximized',
      '--new-window',
      '--no-sandbox',
      '--disable-setuid-sandbox'
    ]
  };

  if (fs.existsSync(chromePath)) {
    launchOptions.executablePath = chromePath;
  }

  const browser = await chromium.launch(launchOptions);
  const context = await browser.newContext({ viewport: null });

  // Nhúng visual neon cursor
  const cursorScriptPath = 'C:\\Users\\Y.Thach\\Desktop\\para\\.agents\\skills\\live-browser-test-and-fix\\scripts\\visual_cursor.js';
  if (fs.existsSync(cursorScriptPath)) {
    const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
    await context.addInitScript(cursorScript);
  }

  const page = await context.newPage();

  // Helper di chuột mượt mà và click có hiệu ứng
  async function smoothClick(selector, label = '') {
    console.log(`👉 Đang di chuột tới: ${label || selector} ...`);
    const el = await page.waitForSelector(selector, { state: 'visible', timeout: 15000 });
    const box = await el.boundingBox();
    if (!box) return;

    const targetX = box.x + box.width / 2;
    const targetY = box.y + box.height / 2;

    // Di chuột từng bước để mắt nhìn thấy đường đi của con trỏ neon
    await page.mouse.move(targetX, targetY, { steps: 35 });
    await page.waitForTimeout(250);

    // Bấm chuột xuống & thả ra để kích hoạt ripple effect
    await page.mouse.down();
    await page.waitForTimeout(120);
    await page.mouse.up();
    await page.waitForTimeout(300);
  }

  // Helper nhập liệu trực quan từng ký tự
  async function smoothType(selector, text, label = '') {
    await smoothClick(selector, label);
    console.log(`⌨️ Đang gõ: ${label} -> "${text}"`);
    const locator = page.locator(selector);
    await locator.fill('');
    await locator.pressSequentially(text, { delay: 130 });
    await page.waitForTimeout(400);
  }

  console.log('🌐 Đang mở trang: https://paradisehrm.com/Tai3/# ...');
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  // 1. Nhập Tên đăng nhập
  await smoothType('#username', 'Chien.nguyen', 'Tên đăng nhập');

  // 2. Nhập Mật khẩu
  await smoothType('input[type="password"]', '123', 'Mật khẩu');

  // 3. Click nút Đăng nhập
  await smoothClick('#submitLogin', 'Nút Đăng nhập');

  console.log('⏳ Đang xử lý đăng nhập vào hệ thống...');
  await page.waitForTimeout(5000);

  console.log('🎉 ĐĂNG NHẬP THÀNH CÔNG! Cửa sổ đang mở trên màn hình của bạn.');
  console.log('Trình duyệt sẽ tiếp tục giữ nguyên để bạn theo dõi.');

  // Giữ cửa sổ mở vĩnh viễn
  await new Promise(() => {});
}

run().catch(err => {
  console.error('Lỗi khởi chạy:', err);
});
