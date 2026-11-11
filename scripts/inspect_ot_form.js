const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForTimeout(4000);

  // Click on MnuWPT316
  console.log('Navigating to MnuWPT316...');
  // Let's see if button.open-MnuWPT316 is in dock
  const btn = page.locator('button.open-MnuWPT316, button.MnuWPT316').first();
  if (await btn.isVisible()) {
    await btn.click();
  } else {
    await page.evaluate(() => window.OpenAppInSidebar('MnuWPT316'));
  }
  await page.waitForTimeout(3000);

  // Inspect form fields inside MnuWPT316
  const formInfo = await page.evaluate(() => {
    const tabContent = document.querySelector('#content-MnuWPT316') || document;
    const inputs = Array.from(tabContent.querySelectorAll('input, select, textarea, button, .dx-datebox, .dx-selectbox, .dx-button')).map(el => {
      const rect = el.getBoundingClientRect();
      return {
        tag: el.tagName,
        id: el.id,
        name: el.getAttribute('name'),
        cls: el.className,
        placeholder: el.getAttribute('placeholder'),
        value: el.value || '',
        text: (el.innerText || '').trim(),
        visible: rect.width > 0 && rect.height > 0
      };
    }).filter(x => x.visible && (x.id || x.name || x.text));
    return inputs;
  });

  console.log('Form inputs found in MnuWPT316:', formInfo.length);
  formInfo.forEach(i => console.log(JSON.stringify(i)));

  await browser.close();
})();
