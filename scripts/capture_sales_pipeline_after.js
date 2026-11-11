const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

async function captureRealAfterFixScreenshots() {
  console.log('🚀 Launching Google Chrome for REAL After-Fix screenshots on live website...');
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('🔑 Authenticating via loginAsAdmin...');
  await loginAsAdmin(page);
  await page.waitForTimeout(2000);

  // Close existing tab if present to force fresh load from tblHtmlScriptCache
  console.log('🔄 Checking for existing Sales Pipeline tab to ensure fresh reload...');
  const closeBtn = page.locator('#dynamic-tab-MnuKPI007 .close, .nav-tabs button:has-text("Sales Pipeline") .close, .nav-tabs li:has-text("Sales Pipeline") .close').first();
  if (await closeBtn.isVisible().catch(() => false)) {
    console.log('Closing existing Sales Pipeline tab to force cache refresh...');
    await closeBtn.click().catch(() => {});
    await page.waitForTimeout(1500);
  }

  // Navigate to Sales Pipeline using standard helper
  console.log('📂 Navigating to Sales Pipeline via navigateToCrmMenu...');
  await navigateToCrmMenu(page, 'Sales Pipeline');

  console.log('⏳ Waiting for #customerKanbanComponent to render from Database...');
  await page.waitForSelector('#customerKanbanComponent', { timeout: 30000 });
  await page.waitForTimeout(4000);

  // Evaluate DOM structure inside kanban-header to verify clean flattening
  const domInfo = await page.evaluate(() => {
    const header = document.querySelector('#customerKanbanComponent .kanban-header');
    if (!header) return { found: false };
    const children = Array.from(header.children).map(c => ({
      tag: c.tagName,
      className: c.className,
      id: c.id,
      rect: {
        top: Math.round(c.getBoundingClientRect().top),
        left: Math.round(c.getBoundingClientRect().left),
        width: Math.round(c.getBoundingClientRect().width),
        height: Math.round(c.getBoundingClientRect().height)
      }
    }));
    return {
      found: true,
      hasHeaderActions: header.querySelector('.header-actions') !== null,
      hasToolbarRightActions: header.querySelector('.toolbar-right-actions') !== null,
      childrenCount: children.length,
      children: children
    };
  });
  console.log('Live DOM structure after execution:', JSON.stringify(domInfo, null, 2));

  const outDir = path.resolve(__dirname, '../fix-bug/sales_pipeline/screenshot');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const viewports = [
    { name: '1440', filename: 'screenshot-sales-pipeline-after.png', w: 1440, h: 900 },
    { name: '1920', filename: 'screenshot-sales-pipeline-1920-after.png', w: 1920, h: 1080 },
    { name: '1024', filename: 'screenshot-sales-pipeline-snap1024-after.png', w: 1024, h: 768 },
    { name: '768', filename: 'screenshot-sales-pipeline-snap768-after.png', w: 768, h: 600 }
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.w, height: vp.h });
    await page.waitForTimeout(1200);

    const shotPath = path.join(outDir, vp.filename);
    await page.screenshot({ path: shotPath });
    console.log(`📸 Saved real after-fix screenshot (${vp.w}x${vp.h}): ${shotPath}`);
  }

  // Also crop the toolbar area specifically at 1440px
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(800);
  const headerEl = await page.$('#customerKanbanComponent .kanban-header');
  if (headerEl) {
    const cropPath = path.join(outDir, 'screenshot-sales-pipeline-toolbar-crop.png');
    await headerEl.screenshot({ path: cropPath });
    console.log(`📸 Saved toolbar crop: ${cropPath}`);
  }

  await browser.close();
  console.log('🎉 100% SUCCESS: All real after-fix screenshots captured from live website!');
}

captureRealAfterFixScreenshots().catch(err => {
  console.error('❌ Error during capture:', err);
  process.exit(1);
});
