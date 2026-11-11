const { chromium } = require('playwright');

async function inspectAddButtons() {
  const browser = await chromium.launch({ headless: true, channel: 'chrome' });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  await page.fill('#username', 'cuong.vu');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(3000);

  // 1. MnuHRS157 - Thông tin gia đình
  console.log('--- Inspecting MnuHRS157 (Thông tin gia đình) ---');
  await page.locator('button.open-MnuHRS000, button.MnuHRS000').first().click();
  await page.waitForTimeout(1000);
  await page.locator('.child-launchpad:has-text("Thông tin gia đình"), a:has-text("Thông tin gia đình")').first().click();
  await page.waitForTimeout(3000);

  const familyButtons = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('button, .btn, a.btn, .dx-button'))
      .filter(b => b.offsetWidth > 0 && b.offsetHeight > 0)
      .map(b => ({ text: b.innerText.trim(), className: b.className, id: b.id }));
  });
  console.log('Family screen buttons:', familyButtons);

  // 2. MnuHRS151 - Quản lý hợp đồng lao động
  console.log('\n--- Inspecting MnuHRS151 (Quản lý hợp đồng lao động) ---');
  await page.locator('button.open-MnuHRS000, button.MnuHRS000').first().click();
  await page.waitForTimeout(1000);
  await page.locator('.child-launchpad:has-text("hợp đồng"), a:has-text("hợp đồng")').first().click();
  await page.waitForTimeout(3000);

  const contractButtons = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('button, .btn, a.btn, .dx-button'))
      .filter(b => b.offsetWidth > 0 && b.offsetHeight > 0)
      .map(b => ({ text: b.innerText.trim(), className: b.className, id: b.id }));
  });
  console.log('Contract screen buttons:', contractButtons);

  await browser.close();
}

inspectAddButtons().catch(console.error);
