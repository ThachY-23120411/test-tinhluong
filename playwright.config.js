const { defineConfig } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

const authFile = path.resolve(__dirname, '.auth/storageState.json');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 60000,
  fullyParallel: false,
  workers: 1, // 1 worker để quan sát tuần tự trên màn hình
  reporter: [
    ['list'],
    ['./markdown-reporter.js', { outputDir: path.resolve(__dirname, 'test-evidence') }]
  ],
  use: {
    headless: false, // Hiển thị cửa sổ Chrome thật
    viewport: null,  // Khớp với kích thước cửa sổ màn hình
    storageState: fs.existsSync(authFile) ? authFile : undefined,
    launchOptions: {
      slowMo: 100,   // Giảm độ trễ thao tác xuống 100ms để chuột và hành động đồng nhất, mượt mà
      args: [
        '--start-maximized',
        '--no-sandbox',
        '--disable-setuid-sandbox'
      ]
    },
    screenshot: 'on',
    trace: 'on',
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
