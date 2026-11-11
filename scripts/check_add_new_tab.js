const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);

  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  const code = await page.evaluate(() => {
    return {
      addNewTab: window.addNewTab ? window.addNewTab.toString() : null
    };
  });

  console.log('addNewTab:');
  console.log(code.addNewTab);

  await browser.close();
}

main().catch(console.error);
