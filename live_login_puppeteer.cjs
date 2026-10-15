const path = require('path');
const { launchLiveBrowser } = require('C:\\Users\\Y.Thach\\Desktop\\para\\.agents\\skills\\live-browser-test-and-fix\\scripts\\live_runner.cjs');

async function main() {
  console.log('================================================================');
  console.log('🚀 ĐANG KHỞI ĐỘNG CHROME LIVE VISUAL BROWSER...');
  console.log('👀 Cửa sổ Chrome thật sẽ mở trực tiếp trên màn hình của bạn!');
  console.log('================================================================\n');

  const { browser, page } = await launchLiveBrowser({
    slowMo: 90,
    searchDirs: ['C:\\Users\\Y.Thach\\Desktop\\para\\backend\\node_modules']
  });

  const url = 'https://paradisehrm.com/Tai3/#';
  console.log(`🌐 Đang mở: ${url}`);
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await new Promise(r => setTimeout(r, 2000));

  console.log('⌨️ Đang di chuột và nhập Tên đăng nhập...');
  await page.liveType('#username', 'Chien.nguyen', { clearFirst: true });

  console.log('⌨️ Đang di chuột và nhập Mật khẩu...');
  await page.liveType('input[type="password"]', '123', { clearFirst: true });

  console.log('👉 Đang di chuột và click nút Đăng nhập...');
  await page.liveClickButton('Đăng nhập', { waitAfter: 3000 });

  console.log('🎉 Đăng nhập hoàn tất! Cửa sổ Chrome đang mở trên màn hình.');
  await new Promise(() => {}); // Giữ cửa sổ mở
}

main().catch(err => {
  console.error('Lỗi Live Runner:', err);
});
