const { chromium } = require('playwright');

async function analyzeImg() {
  const browser = await chromium.launch({ headless: true, executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe' });
  const page = await browser.newPage();
  await page.goto('file:///C:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/29.png');

  const analysis = await page.evaluate(() => {
    const img = document.querySelector('img');
    const canvas = document.createElement('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    // Look for bright red pixels (annotations commonly added by testers: #ff0000 / rgb(255, 0, 0))
    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const data = imgData.data;
    const redPixels = [];
    for (let y = 0; y < canvas.height; y += 4) {
      for (let x = 0; x < canvas.width; x += 4) {
        const i = (y * canvas.width + x) * 4;
        const r = data[i], g = data[i+1], b = data[i+2];
        if (r > 200 && g < 50 && b < 50) {
          redPixels.push({ x, y });
        }
      }
    }

    return {
      width: canvas.width,
      height: canvas.height,
      redCount: redPixels.length,
      redBounds: redPixels.length > 0 ? {
        minX: Math.min(...redPixels.map(p => p.x)),
        maxX: Math.max(...redPixels.map(p => p.x)),
        minY: Math.min(...redPixels.map(p => p.y)),
        maxY: Math.max(...redPixels.map(p => p.y))
      } : null
    };
  });

  console.log('Analysis of 29.png:', analysis);
  await browser.close();
}

analyzeImg().catch(console.error);
