const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function main() {
  const browser = await chromium.launch({ 
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  
  // Create a page that displays both images side by side
  const page = await browser.newPage({ viewport: { width: 1800, height: 1200 } });
  
  const img1 = fs.readFileSync('Screenshots_1_bug/5.png').toString('base64');
  const img2 = fs.readFileSync('C:/Antigravity_MultiAccount/Profiles/Profile11/.gemini/antigravity/brain/80ff1d52-7a74-485b-8c0e-59ef6911cd5d/.user_uploaded/media_1792558321840_4ffb34fd.png').toString('base64');

  await page.setContent(`
    <html>
      <body style="background:#1e1e1e; color:white; font-family:sans-serif; padding:20px;">
        <h2>Image 1: Screenshots_1_bug/5.png</h2>
        <img id="img1" src="data:image/png;base64,${img1}" style="max-width:100%; border:2px solid red;" />
        <h2>Image 2: User Uploaded (media_1792558321840_4ffb34fd.png)</h2>
        <img id="img2" src="data:image/png;base64,${img2}" style="max-width:100%; border:2px solid green;" />
      </body>
    </html>
  `);

  await page.waitForTimeout(1000);
  
  // Let's inspect text on img1 by evaluating simple dimensions or checks
  const img1Dim = await page.locator('#img1').boundingBox();
  const img2Dim = await page.locator('#img2').boundingBox();
  console.log('img1 rendered:', img1Dim);
  console.log('img2 rendered:', img2Dim);

  await page.screenshot({ path: 'scripts/side_by_side_5.png', fullPage: true });
  console.log('Saved side_by_side_5.png');

  await browser.close();
}

main().catch(console.error);
