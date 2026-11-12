const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({ viewport: null });
  const page = await context.newPage();

  console.log('1. Đăng nhập tri.nguyen (Mr. TRÍ [004])...');
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.waitForTimeout(1000);

  const uInput = page.locator('#username, input#txtUsername').first();
  await uInput.waitFor({ state: 'visible', timeout: 10000 });
  await uInput.fill('tri.nguyen');
  const pInput = page.locator('#password, input[type="password"]').first();
  await pInput.fill('123');
  await page.locator('#submitLogin, button[type="submit"]').first().click();
  await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 20000 });
  console.log('Đã đăng nhập thành công tri.nguyen');

  // Mở tab Xin nghỉ phép
  console.log('2. Mở Cổng thông tin -> Xin nghỉ phép...');
  const dockWpt = page.locator('.dock .open-MnuWPT000, .dock .MnuWPT000').first();
  if (await dockWpt.isVisible().catch(() => false)) {
    await dockWpt.click();
    await page.waitForTimeout(1000);
  }
  const leaveMenu = page.locator('span:has-text("Xin nghỉ phép"), a:has-text("Xin nghỉ phép"), .open-MnuWPT315').first();
  if (await leaveMenu.isVisible().catch(() => false)) {
    await leaveMenu.click();
  } else {
    await page.evaluate(() => { if (typeof OpenAppInSidebar === 'function') OpenAppInSidebar('MnuWPT315'); });
  }
  await page.waitForTimeout(3000);

  console.log('3. Kiểm tra danh sách Đơn chờ duyệt...');
  const pending099 = page.locator('#leaveRequestPendding .oa-card:has-text("099"), .oa-card:has-text("099")').first();
  if (await pending099.isVisible({ timeout: 8000 }).catch(() => false)) {
    console.log('TÌM THẤY ĐƠN CHỜ DUYỆT CỦA 099! Đang click chọn...');
    await pending099.click();
    await page.waitForTimeout(2000);

    const approveBtn = page.locator('#sp_ResignationLeave .btnApprove:visible, button.btnApprove:visible, button:has-text("Duyệt"):visible').first();
    console.log('Nút Duyệt visible?', await approveBtn.isVisible().catch(() => false));
    if (await approveBtn.isVisible().catch(() => false)) {
      await approveBtn.click();
      await page.waitForTimeout(1500);

      const modalBtn = page.locator('#modalApproveLeaveRequest #btnActionModalRemake:visible, #modalApproveLeaveRequest button.btn-success:visible').first();
      console.log('Nút Approved trong modal visible?', await modalBtn.isVisible().catch(() => false));
      if (await modalBtn.isVisible().catch(() => false)) {
        await modalBtn.click();
        await page.waitForTimeout(3000);
        console.log('ĐÃ BẤM DUYỆT THÀNH CÔNG TRÊN UI!');
      }
    }
  } else {
    console.log('Không thấy đơn chờ duyệt của 099 trong #leaveRequestPendding');
  }

  await page.waitForTimeout(3000);
  await browser.close();
})();
