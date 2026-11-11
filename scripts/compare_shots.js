const { chromium } = require('playwright');

async function compareShots() {
  const browser = await chromium.launch({ headless: true, executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe' });
  const page = await browser.newPage({ viewport: { width: 1400, height: 900 } });

  await page.setContent(`
    <html>
      <body style="background: #1e1e1e; color: #fff; font-family: sans-serif; padding: 20px;">
        <h2>1. Original 29.png (Full top area)</h2>
        <div style="width: 1300px; height: 160px; overflow: hidden; border: 1px solid red; margin-bottom: 20px;">
          <img src="file:///C:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/29.png" style="width: 1300px;">
        </div>

        <h2>2. User Uploaded media_1793254289884_c8f4fc5e.png</h2>
        <div style="border: 1px solid lime; margin-bottom: 20px;">
          <img src="file:///C:/Antigravity_MultiAccount/Profiles/Profile4/.gemini/antigravity/brain/34c6ffcf-084b-4048-840e-3bed86e40404/.user_uploaded/media_1793254289884_c8f4fc5e.png">
        </div>
      </body>
    </html>
  `);

  await page.screenshot({ path: 'scripts/side_by_side.png', fullPage: true });
  console.log('Saved scripts/side_by_side.png');

  await browser.close();
}

compareShots();
