const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function main() {
  const browser = await chromium.launch({ 
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage({ viewport: { width: 1700, height: 1100 } });
  
  const img1 = fs.readFileSync('Screenshots_1_bug/5.png').toString('base64');
  await page.setContent(`<img id="im" src="data:image/png;base64,${img1}" style="display:block;" />`);
  
  // Crop vùng giữa
  await page.locator('#im').screenshot({
    path: 'scripts/img1_center_box.png',
    clip: { x: 500, y: 300, width: 700, height: 500 }
  });
  
  // Crop vùng menu bên trái
  await page.locator('#im').screenshot({
    path: 'scripts/img1_left_menu.png',
    clip: { x: 0, y: 0, width: 350, height: 400 }
  });

  // Crop vùng tab trên cùng
  await page.locator('#im').screenshot({
    path: 'scripts/img1_tabs.png',
    clip: { x: 0, y: 0, width: 1000, height: 150 }
  });

  console.log('Cropped regions of Screenshots_1_bug/5.png successfully!');
  await browser.close();
}

main().catch(console.error);
