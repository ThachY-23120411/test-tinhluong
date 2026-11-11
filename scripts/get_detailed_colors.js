const { chromium } = require('playwright');
const fs = require('fs');

async function getDetailedPixelColors() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  const fileBuf = fs.readFileSync('scripts/shot_exact_search_crop.png');
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

    const colorCounts = {};
    const imgData = ctx.getImageData(0, 0, w, h).data;
    for (let i = 0; i < imgData.length; i += 4) {
      const hex = '#' + [imgData[i], imgData[i+1], imgData[i+2]].map(x => x.toString(16).padStart(2, '0')).join('');
      colorCounts[hex] = (colorCounts[hex] || 0) + 1;
    }

    const sorted = Object.entries(colorCounts).sort((a, b) => b[1] - a[1]).slice(0, 8);
    return sorted;
  });

  console.log('Top colors in rendered search crop:');
  console.log(JSON.stringify(colors, null, 2));
  await browser.close();
}

getDetailedPixelColors().catch(console.error);
