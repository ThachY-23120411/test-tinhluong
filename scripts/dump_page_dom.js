const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.locator('#username').fill('tai.dang');
  await page.locator('input[type="password"]').fill('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(3000);
  const dock = page.locator('.open-MnuWPT000, .MnuWPT000').first();
  if (await dock.isVisible({ timeout: 5000 }).catch(() => false)) await dock.click();
  await page.locator('a:has-text("Xin bù công")').first().click();
  await page.waitForTimeout(3000);

  const fullHtml = await page.content();
  fs.writeFileSync('scripts/bu_cong_full_page.html', fullHtml, 'utf8');
  console.log('Saved bu_cong_full_page.html, size:', fullHtml.length);

  await browser.close();
})();
