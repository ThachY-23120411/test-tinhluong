const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(3000);

  const userVars = await page.evaluate(() => {
    return {
      windowLoginName: window.LoginName,
      windowUserName: window.userName || window.UserName,
      windowLoginID: window.LoginID || window.loginID,
      profileName: document.querySelector('.user-name, .profile-name, #userName, .user-profile')?.innerText?.trim(),
      localStorage: Object.keys(localStorage).map(k => `${k}=${localStorage.getItem(k)}`).slice(0, 5)
    };
  });
  console.log('User session vars:', JSON.stringify(userVars, null, 2));

  await browser.close();
})();
