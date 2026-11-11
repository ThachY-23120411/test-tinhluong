const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle' });
  
  if (await page.locator('#username').isVisible().catch(() => false)) {
    await page.fill('#username', 'ThanhLong');
    await page.fill('input[type="password"]', '123');
    await page.click('#submitLogin');
    await page.waitForTimeout(3000);
  }

  const menuInfo = await page.evaluate(() => {
    if (!window.dataMenuViewHtml) return [];
    return window.dataMenuViewHtml.filter(m => 
      (m.MenuName && (m.MenuName.includes('mật khẩu') || m.MenuName.includes('Tạo') || m.MenuName.includes('đào tạo'))) ||
      (m.ClassName && (m.ClassName.includes('Password') || m.ClassName.includes('SetInitial')))
    );
  });

  console.log('Found menus:', JSON.stringify(menuInfo, null, 2));

  // Thử tìm element trên menu DOM
  const menuElements = await page.evaluate(() => {
    const elList = Array.from(document.querySelectorAll('*')).filter(el => 
      el.children.length === 0 && el.textContent && el.textContent.trim() === 'Tạo mật khẩu'
    );
    return elList.map(el => ({
      tagName: el.tagName,
      id: el.id,
      className: el.className,
      parentTag: el.parentElement ? el.parentElement.tagName : null,
      parentId: el.parentElement ? el.parentElement.id : null,
      parentClass: el.parentElement ? el.parentElement.className : null
    }));
  });

  console.log('Menu elements in DOM:', menuElements);

  await browser.close();
}

main().catch(console.error);
