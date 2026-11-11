const { chromium } = require('playwright');

async function cropRightSide() {
  const browser = await chromium.launch({ headless: true, executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe' });
  const page = await browser.newPage({ viewport: { width: 1920, height: 600 } });

  await page.setContent(`
    <html>
      <body style="background: #000; margin: 0; padding: 20px;">
        <h3>Original 29.png - Right side of toolbar:</h3>
        <div style="width: 700px; height: 100px; overflow: hidden; border: 2px solid yellow;">
          <img src="file:///C:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/29.png" style="margin-left: -1200px; margin-top: -50px;">
        </div>
      </body>
    </html>
  `);

  await page.screenshot({ path: 'scripts/29_right_crop.png' });
  console.log('Saved scripts/29_right_crop.png');
  await browser.close();
}

cropRightSide();
