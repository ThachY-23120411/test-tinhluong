// @ts-check
const { defineConfig } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

const authFile = path.resolve(__dirname, '../../.auth/storageState.json');

module.exports = defineConfig({
  testDir: path.resolve(__dirname, '../../tests'),
  timeout: 600000,
  fullyParallel: false,
  workers: 1,
  reporter: [['list']],
  use: {
    headless: false,
    viewport: null,
    permissions: ['geolocation', 'notifications'],
    geolocation: { latitude: 10.7769, longitude: 106.7009 },
    storageState: fs.existsSync(authFile) ? authFile : undefined,
    launchOptions: {
      slowMo: 0,
      args: [
        '--start-maximized',
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--deny-permission-prompts',
        '--disable-notifications',
        '--disable-background-timer-throttling',
        '--disable-renderer-backgrounding',
        '--disable-backgrounding-occluded-windows',
        '--disable-dev-shm-usage',
      ],
    },
    screenshot: 'off',
    trace: 'off',
    video: 'off',
  },
  projects: [
    {
      name: 'Google Chrome',
      use: {
        channel: 'chrome',
      },
    },
  ],
});
