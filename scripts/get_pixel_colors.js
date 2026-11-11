const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function getPixelColors() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  const fileBuf = fs.readFileSync('C:/Antigravity_MultiAccount/Profiles/Profile4/.gemini/antigravity/brain/34c6ffcf-084b-4048-840e-3bed86e40404/.user_uploaded/media_1793243578275_cea8ce46.png');
  const base64 = 'data:image/png;base64,' + fileBuf.toString('base64');

  await page.setContent(`
    <html>
      <body>
        <img id="img" src="${base64}" />
        <canvas id="canvas"></canvas>
      </body>
    </html>
  `);

  await page.waitForFunction(() => {
    const img = document.getElementById('img');
    return img && img.complete && img.naturalWidth > 0;
  });

  const colors = await page.evaluate(() => {
    const img = document.getElementById('img');
    const canvas = document.getElementById('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    const w = canvas.width;
    const h = canvas.height;
    
    // Sample multiple points (x, y, width, height)
    const center = ctx.getImageData(Math.floor(w * 0.5), Math.floor(h * 0.5), 1, 1).data;
    const topBorder = ctx.getImageData(Math.floor(w * 0.5), 1, 1, 1).data;
    const leftBorder = ctx.getImageData(1, Math.floor(h * 0.5), 1, 1).data;
    const bgNearIcon = ctx.getImageData(Math.floor(w * 0.25), Math.floor(h * 0.5), 1, 1).data;

    const toHex = (d) => '#' + [d[0], d[1], d[2]].map(x => x.toString(16).padStart(2, '0')).join('');

    return {
      dimensions: { w, h },
      centerBg: { rgb: Array.from(center.slice(0, 3)), hex: toHex(center) },
      bgNearIcon: { rgb: Array.from(bgNearIcon.slice(0, 3)), hex: toHex(bgNearIcon) },
      topBorder: { rgb: Array.from(topBorder.slice(0, 3)), hex: toHex(topBorder) },
      leftBorder: { rgb: Array.from(leftBorder.slice(0, 3)), hex: toHex(leftBorder) }
    };
  });

  console.log(JSON.stringify(colors, null, 2));
  await browser.close();
}

getPixelColors().catch(console.error);
