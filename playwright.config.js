const { defineConfig } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

const authFile = path.resolve(__dirname, '.auth/storageState.json');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 600000,
  fullyParallel: false,
  workers: 1, // 1 worker để quan sát tuần tự trên màn hình
  reporter: [
    ['list'],
    ['./markdown-reporter.js', { outputDir: path.resolve(__dirname, 'test-evidence') }]
  ],
  use: {
    headless: false, // Hiển thị cửa sổ Chrome thật
    viewport: null,  // Khớp với kích thước cửa sổ màn hình
    permissions: ['geolocation', 'notifications'],
    geolocation: { latitude: 10.7769, longitude: 106.7009 },
    storageState: fs.existsSync(authFile) ? authFile : undefined,
    launchOptions: {
      slowMo: 0,     // Tốc độ thời gian thực (Zero lag, chuột di chuyển mượt mà tự nhiên như người dùng thật)
      args: [
        '--start-maximized',
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--deny-permission-prompts',
        '--disable-notifications'
      ]
    },
    screenshot: 'on',
    trace: 'off',
    video: {
      mode: 'on',
      size: { width: 1440, height: 900 }
    }
  },
  projects: [
    {
      name: 'Google Chrome',
      use: {
        channel: 'chrome' // Sử dụng Chrome chính thức trên Windows
      }
    }
  ]
});
