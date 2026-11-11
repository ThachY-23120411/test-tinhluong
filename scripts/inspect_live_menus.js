const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function inspectUser(username, password) {
  console.log(`\n==================================================`);
  console.log(`INSPECTING LIVE MENUS FOR USER: ${username}`);
  console.log(`==================================================`);

  const browser = await chromium.launch({
    headless: true,
    channel: 'chrome',
    args: ['--window-size=1440,900']
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 }
  });

  const page = await context.newPage();
  const screenDir = path.resolve(__dirname, `../debug_screens/${username}`);
  fs.mkdirSync(screenDir, { recursive: true });

  try {
    console.log(`Navigating to https://paradisehrm.com/Tai3/# ...`);
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'networkidle', timeout: 45000 });
    await page.waitForTimeout(2000);

    // Login
    const userInput = page.locator('#username, #txtUsername, input[name="username"]').first();
    if (await userInput.isVisible()) {
      await userInput.fill(username);
      const passInput = page.locator('input[type="password"]').first();
      await passInput.fill(password);
      const submitBtn = page.locator('#submitLogin, #btnLogin, button[type="submit"]').first();
      await submitBtn.click();
      await page.waitForTimeout(4000);
    }

    await page.screenshot({ path: path.join(screenDir, '01_after_login.png') });

    // Extract all dock icons / navbar buttons
    const dockButtons = await page.evaluate(() => {
      const btns = Array.from(document.querySelectorAll('.dock button, .dock a, .navbar button, .navbar a, .navbar-nav li'));
      return btns.map(b => ({
        text: (b.innerText || b.getAttribute('title') || b.getAttribute('data-original-title') || '').trim(),
        className: b.className,
        id: b.id,
        onclick: b.getAttribute('onclick') || ''
      })).filter(b => b.text || b.className);
    });

    console.log(`Found ${dockButtons.length} dock/nav items:`);
    dockButtons.forEach(b => console.log(`  - [${b.className}] text: "${b.text}" id: "${b.id}"`));

    // Check Launchpad / Menu tree if launchpad button exists
    const launchpadBtn = page.locator('.open-lunchpad, .MnuHRS238, button[title*="menu"], button[title*="Menu"], .fa-bars, .bi-list, .bi-grid, .open-MnuHRS238').first();
    if (await launchpadBtn.isVisible()) {
      console.log(`Clicking launchpad / main menu button...`);
      await launchpadBtn.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(screenDir, '02_launchpad.png') });
    }

    // Try clicking each dock module and dumping its sidebar items
    const moduleClasses = ['MnuHRS000', 'MnuTAD000', 'MnuPRL000', 'MnuWPT000', 'MnuSYS000', 'MnuKPI000', 'MnuMDT000'];
    const moduleMenus = {};

    for (const mod of moduleClasses) {
      const modBtn = page.locator(`.dock button.${mod}, .dock .open-${mod}, button.${mod}, [data-module="${mod}"]`).first();
      if (await modBtn.isVisible()) {
        console.log(`\n--- Clicking module ${mod} ---`);
        await modBtn.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: path.join(screenDir, `module_${mod}.png`) });

        const items = await page.evaluate(() => {
          const links = Array.from(document.querySelectorAll('.sidebar a, .sidebar button, .sidebar li, .menu-item, .child-launchpad, .nav-item'));
          return links.map(a => ({
            text: (a.innerText || '').replace(/\s+/g, ' ').trim(),
            className: a.className,
            id: a.id,
            href: a.getAttribute('href') || ''
          })).filter(a => a.text && a.text.length < 80);
        });

        moduleMenus[mod] = items;
        console.log(`Module ${mod} has ${items.length} visible items. Examples:`);
        items.slice(0, 15).forEach(i => console.log(`    * [${i.className}] "${i.text}"`));
      } else {
        console.log(`Module ${mod} is not visible on dock for ${username}`);
      }
    }

    fs.writeFileSync(path.join(screenDir, 'menus.json'), JSON.stringify({ dockButtons, moduleMenus }, null, 2));

  } catch (err) {
    console.error(`Error inspecting user ${username}:`, err);
    await page.screenshot({ path: path.join(screenDir, 'error.png') }).catch(() => {});
  } finally {
    await browser.close();
  }
}

async function main() {
  await inspectUser('cuong.vu', '123');
  await inspectUser('chien.nguyen', '123');
  await inspectUser('tai.dang', '123');
}

main();
