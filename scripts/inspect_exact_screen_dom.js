const { chromium } = require('playwright');

async function checkScreen(screenName, openFn) {
  const browser = await chromium.launch({ headless: true, channel: 'chrome' });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  try {
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
    await page.fill('#username', 'cuong.vu');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(4000);

    await openFn(page);
    await page.waitForTimeout(3000);

    const data = await page.evaluate(() => {
      // Get all active tab names
      const tabs = Array.from(document.querySelectorAll('.nav-tabs li, .nav-tabs button, .nav-tabs a'))
        .map(e => e.innerText.trim()).filter(Boolean);

      // Get buttons
      const buttons = Array.from(document.querySelectorAll('button, a.btn, .dx-button'))
        .filter(e => e.offsetWidth > 0 && e.offsetHeight > 0)
        .map(e => e.innerText.trim()).filter(e => e && e.length < 50);

      // Get table headers
      const headers = Array.from(document.querySelectorAll('.dx-header-row td, th'))
        .map(e => e.innerText.trim()).filter(Boolean);

      // Get inputs/labels
      const inputs = Array.from(document.querySelectorAll('input, select'))
        .filter(e => e.offsetWidth > 0 && e.offsetHeight > 0)
        .map(e => ({ id: e.id, placeholder: e.placeholder, name: e.name, type: e.type, value: e.value }));

      return { tabs, buttons, headers, inputs };
    });

    console.log(`\n================== ${screenName} ==================`);
    console.log('TABS:', data.tabs);
    console.log('BUTTONS:', data.buttons);
    console.log('HEADERS:', data.headers);
    console.log('INPUTS:', data.inputs.map(i => `${i.id || i.name} (${i.placeholder || i.type})`));

  } catch (err) {
    console.error(`Error on ${screenName}:`, err);
  } finally {
    await browser.close();
  }
}

async function main() {
  // 1. Quản lý hợp đồng lao động (MnuHRS151)
  await checkScreen('Quản lý hợp đồng lao động (MnuHRS151)', async (page) => {
    await page.locator('button.open-MnuHRS000, button.MnuHRS000').first().click();
    await page.waitForTimeout(1000);
    await page.locator('.child-launchpad:has-text("hợp đồng"), a:has-text("hợp đồng")').first().click();
  });

  // 2. Thông tin gia đình (MnuHRS157)
  await checkScreen('Thông tin gia đình (MnuHRS157)', async (page) => {
    await page.locator('button.open-MnuHRS000, button.MnuHRS000').first().click();
    await page.waitForTimeout(1000);
    await page.locator('.child-launchpad:has-text("Thông tin gia đình"), a:has-text("Thông tin gia đình")').first().click();
  });

  // 3. Xem dữ liệu chấm công hằng ngày (MnuHRS225)
  await checkScreen('Xem dữ liệu chấm công hằng ngày (MnuHRS225)', async (page) => {
    await page.locator('button.open-MnuTAD000, button.MnuTAD000').first().click();
    await page.waitForTimeout(1000);
    await page.locator('.child-launchpad:has-text("Xem dữ liệu chấm"), a:has-text("Xem dữ liệu chấm")').first().click();
  });

  // 4. Tổng hợp công cả tháng (MnuHRS226 / MnuTAD1000)
  await checkScreen('Tổng hợp công cả tháng (MnuTAD1000)', async (page) => {
    await page.locator('button.open-MnuTAD000, button.MnuTAD000').first().click();
    await page.waitForTimeout(1000);
    await page.locator('.child-launchpad:has-text("Tổng hợp công"), a:has-text("Tổng hợp công")').first().click();
  });
}

main();
