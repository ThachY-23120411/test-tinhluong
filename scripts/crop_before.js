const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function cropBefore() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  
  const imgPath = path.resolve('fix-bug/lich_su_nhap_kho/screenshot/screenshot-29-before.png');
  const b64 = fs.readFileSync(imgPath).toString('base64');
  await page.setContent(`
    <html><body style="margin:0;padding:0;background:#000;">
      <img id="img" src="data:image/png;base64,${b64}" style="display:block;" />
    </body></html>
  `);
  
  await page.waitForTimeout(500);
  const img = await page.$('#img');
  const box = await img.boundingBox();
  console.log('Original image size:', box);

  await page.screenshot({
    path: 'scripts/sc29_toolbar_crop.png',
    clip: { x: 0, y: 0, width: box.width, height: 250 }
  });
  console.log('Saved scripts/sc29_toolbar_crop.png');

  await browser.close();
}

cropBefore().catch(console.error);
