const { chromium } = require('playwright');

async function cropDateBox() {
  const browser = await chromium.launch({ headless: true, executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe' });
  const page = await browser.newPage({ viewport: { width: 1200, height: 800 } });

  const imgPath = 'C:/Antigravity_MultiAccount/Profiles/Profile4/.gemini/antigravity/brain/34c6ffcf-084b-4048-840e-3bed86e40404/.user_uploaded/media_1793254289884_c8f4fc5e.png';

  // Crop around x: 150 to 450, y: 0 to 64
  await page.setContent(`
    <html>
      <body style="background: #222; margin: 0; padding: 20px;">
        <div style="width: 350px; height: 64px; overflow: hidden; border: 2px solid red;">
          <img src="file:///${imgPath.replace(/\\/g, '/')}" style="margin-left: -150px;">
        </div>
      </body>
    </html>
  `);

  await page.screenshot({ path: 'scripts/datebox_crop.png' });
  console.log('Saved scripts/datebox_crop.png');
  await browser.close();
}

cropDateBox();
