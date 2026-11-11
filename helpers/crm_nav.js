const { expect } = require('@playwright/test');

const CRM_MENU_IDS = {
  'Tổng quan CRM': { tabId: 'dynamic-tab-MnuKPI001', dockClass: 'MnuKPI001', text: 'Tổng quan CRM' },
  'Theo dõi dịch vụ': { tabId: 'dynamic-tab-MnuKPI012', dockClass: 'MnuKPI012', text: 'Theo dõi dịch vụ' },
  'Dữ liệu khách hàng': { tabId: 'dynamic-tab-MnuKPI003', dockClass: 'MnuKPI003', text: 'Dữ liệu khách hàng' },
  'Sales Pipeline': { tabId: 'dynamic-tab-MnuKPI007', dockClass: 'MnuKPI007', text: 'Sales Pipeline' },
  'Doanh số': { tabId: 'dynamic-tab-MnuKPI447', dockClass: 'MnuKPI447', text: 'Doanh số' },
  'Gửi tin nhắn zalo tự động': { tabId: 'dynamic-tab-MnuKPI045', dockClass: 'MnuKPI045', text: 'Gửi tin nhắn zalo tự động', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' },
  'Email gửi thủ công': { tabId: 'dynamic-tab-MnuKPI002', dockClass: 'MnuKPI002', text: 'Email gửi thủ công', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' },
  'Sản phẩm marketing': { tabId: 'dynamic-tab-MnuKPI048', dockClass: 'MnuKPI048', text: 'Sản phẩm marketing', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' },
  'Nội dung đăng tải': { tabId: 'dynamic-tab-MnuKPI005', dockClass: 'MnuKPI005', text: 'Nội dung đăng tải', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' },
  'Lịch sử tin AI tạo tin nhắn': { tabId: 'dynamic-tab-MnuKPI049', dockClass: 'MnuKPI049', text: 'Lịch sử tin AI tạo tin nhắn', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' },
  'Các cuộc họp': { tabId: 'dynamic-tab-MnuKPI006', dockClass: 'MnuKPI006', text: 'Các cuộc họp', parentText: 'Nhiệm vụ', parentClass: 'MnuKPI028' }
};

async function moveAndClick(page, locator, options = {}) {
  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
  const box = await locator.boundingBox().catch(() => null);
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: options.force || false, timeout: 6000 }).catch(async () => {
    await locator.click({ force: true, timeout: 3000 }).catch(() => {});
  });
}

/**
 * Điều hướng mượt mà và an toàn vào 1 trong các menu của phân hệ CRM
 * @param {import('@playwright/test').Page} page
 * @param {'Tổng quan CRM' | 'Theo dõi dịch vụ' | 'Dữ liệu khách hàng' | 'Sales Pipeline' | 'Doanh số' | 'Sản phẩm marketing'} menuName
 */
async function navigateToCrmMenu(page, menuName) {
  const target = CRM_MENU_IDS[menuName];
  if (!target) throw new Error(`Không nhận diện được menu CRM: ${menuName}`);

  // Đóng bất kỳ overlay/modal/backdrop nào còn sót lại trước khi chuyển tab
  const activeOverlay = page.locator('.modal-backdrop:visible, .VC-Vu-component-overlay.active:visible').first();
  if (await activeOverlay.isVisible().catch(() => false)) {
    await page.keyboard.press('Escape').catch(() => {});
    await page.waitForTimeout(300);
  }

  // Đảm bảo dock/navbar đã sẵn sàng
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });
  await page.waitForTimeout(800);

  // 1. Kiểm tra tab đã mở trên thanh điều hướng tab trên cùng
  const targetTab = page.locator(`#${target.tabId}, .nav-tabs button:has-text("${target.text}"), .nav-tabs a:has-text("${target.text}")`).first();
  if (await targetTab.isVisible().catch(() => false)) {
    console.log(`⚡ [CRM NAV]: Tìm thấy tab "${menuName}", đang kích hoạt...`);
    await moveAndClick(page, targetTab, { force: true });
    await page.waitForTimeout(1500);
    return;
  }

  // 2. Mở trực tiếp bằng hàm chuẩn OpenAppInSidebar của hệ thống nếu có
  console.log(`📂 [CRM NAV]: Gọi OpenAppInSidebar("${target.dockClass}") để mở menu "${menuName}"...`);
  const openedByFn = await page.evaluate((dockClass) => {
    if (typeof window.OpenAppInSidebar === 'function') {
      window.OpenAppInSidebar(dockClass);
      return true;
    }
    return false;
  }, target.dockClass).catch(() => false);

  if (openedByFn) {
    await page.waitForTimeout(2000);
    const isTabActive = await page.locator(`#${target.tabId}:visible, #dynamic-pane-${target.dockClass}:visible, #${target.dockClass}:visible`).first().isVisible().catch(() => false);
    if (isTabActive) {
      console.log(`✅ [CRM NAV]: Đã điều hướng thành công vào menu "${menuName}" qua OpenAppInSidebar.`);
      return;
    }
  }

  // 3. Fallback: Nếu có nút app trên dock
  const dockBtn = page.locator(`.dock .icon.${target.dockClass}:visible, .dock [title*="${target.text}"]:visible`).first();
  if (await dockBtn.isVisible().catch(() => false)) {
    console.log(`📂 [CRM NAV]: Nhấp vào nút Dock của "${menuName}"...`);
    await moveAndClick(page, dockBtn);
    await page.waitForTimeout(2000);
    return;
  }

  // 4. Fallback: Mở phân hệ CRM từ Dock nếu chưa mở
  const crmDock = page.locator('.dock .icon.MnuKPI000, .dock [title*="Trang chủ CRM"], .dock [title*="CRM"]').first();
  if (await crmDock.isVisible({ timeout: 5000 }).catch(() => false)) {
    await moveAndClick(page, crmDock);
    await page.waitForTimeout(1200);
  }

  // 5. Tìm link menu trong launchpad hoặc sidebar
  const launchpadOrSide = page.locator(`[onclick*="${target.dockClass}"]:visible, .child-launchpad.${target.dockClass}:visible, span:text-is("${target.text}"):visible`).first();
  if (await launchpadOrSide.isVisible({ timeout: 4000 }).catch(() => false)) {
    await moveAndClick(page, launchpadOrSide);
  } else {
    // Mở hamburger menu nếu sidebar thu nhỏ
    const hamburger = page.locator('button.menu-button.main-menu-button:visible, .menu-button:visible, button:has(.bi-list):visible').first();
    if (await hamburger.isVisible({ timeout: 3000 }).catch(() => false)) {
      await moveAndClick(page, hamburger);
      await page.waitForTimeout(1000);
    }
    const finalItem = page.locator(`[onclick*="${target.dockClass}"]:visible, .${target.dockClass}:visible, span:text-is("${target.text}"):visible`).first();
    await moveAndClick(page, finalItem, { timeout: 10000 });
  }

  await page.waitForTimeout(2000);
  console.log(`✅ [CRM NAV]: Đã điều hướng thành công vào menu "${menuName}".`);
}

module.exports = {
  navigateToCrmMenu,
  moveAndClick,
  CRM_MENU_IDS
};
