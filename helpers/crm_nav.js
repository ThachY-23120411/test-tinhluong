const { expect } = require('@playwright/test');

const CRM_MENU_IDS = {
  'Tổng quan CRM': { tabId: 'dynamic-tab-MnuKPI001', dockClass: 'MnuKPI001', text: 'Tổng quan CRM' },
  'Theo dõi dịch vụ': { tabId: 'dynamic-tab-MnuKPI012', dockClass: 'MnuKPI012', text: 'Theo dõi dịch vụ' },
  'Dữ liệu khách hàng': { tabId: 'dynamic-tab-MnuKPI003', dockClass: 'MnuKPI003', text: 'Dữ liệu khách hàng' },
  'Sales Pipeline': { tabId: 'dynamic-tab-MnuKPI007', dockClass: 'MnuKPI007', text: 'Sales Pipeline' }
};

async function moveAndClick(page, locator, options = {}) {
  await locator.waitFor({ state: 'visible', timeout: options.timeout || 12000 });
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  const box = await locator.boundingBox();
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: options.force || false });
}

/**
 * Điều hướng mượt mà và an toàn vào 1 trong 4 menu của phân hệ CRM
 * @param {import('@playwright/test').Page} page
 * @param {'Tổng quan CRM' | 'Theo dõi dịch vụ' | 'Dữ liệu khách hàng' | 'Sales Pipeline'} menuName
 */
async function navigateToCrmMenu(page, menuName) {
  const target = CRM_MENU_IDS[menuName];
  if (!target) throw new Error(`Không nhận diện được menu CRM: ${menuName}`);

  // Đảm bảo dock/navbar đã sẵn sàng
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(1000);

  // 1. Kiểm tra tab đã mở trên thanh điều hướng tab trên cùng
  const targetTab = page.locator(`#${target.tabId}, .nav-tabs button:has-text("${target.text}"), .nav-tabs a:has-text("${target.text}")`).first();
  if (await targetTab.isVisible().catch(() => false)) {
    console.log(`⚡ [CRM NAV]: Tìm thấy tab "${menuName}", đang kích hoạt...`);
    await moveAndClick(page, targetTab);
    await page.waitForTimeout(1500);
    return;
  }

  // 2. Nếu tab chưa mở, mở từ Dock icon hoặc Sidebar CRM
  console.log(`📂 [CRM NAV]: Mở phân hệ Trang chủ CRM từ thanh Dock...`);
  const crmDock = page.locator('.dock .icon.MnuKPI000, .dock [title*="Trang chủ CRM"], .dock [title*="CRM"]').first();
  if (await crmDock.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, crmDock);
    await page.waitForTimeout(1200);
  }

  // 3. Tìm link menu trong sidebar
  const menuItem = page.locator(`#sidebar, .sidebar, #menu, .sidebar-content, body`)
    .locator(`text="${target.text}"`)
    .first();

  if (await menuItem.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, menuItem);
  } else {
    // Nếu sidebar đang thu gọn, bấm nút hamburger ☰
    const hamburger = page.locator('button.menu-button.main-menu-button, .menu-button').first();
    if (await hamburger.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, hamburger);
      await page.waitForTimeout(1000);
    }
    await moveAndClick(page, menuItem, { timeout: 10000 });
  }

  await page.waitForTimeout(2000);
  console.log(`✅ [CRM NAV]: Đã điều hướng thành công vào menu "${menuName}".`);
}

module.exports = {
  navigateToCrmMenu,
  moveAndClick,
  CRM_MENU_IDS
};
