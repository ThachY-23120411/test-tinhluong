const { chromium } = require('playwright');
const fs = require('fs');

async function checkLayout() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
  });
  const page = await browser.newPage();
  
  const scriptContent = fs.readFileSync('scripts/test_preview_responsive.js', 'utf8');
  const startTag = '<!DOCTYPE html>';
  const endTag = '</html>';
  const htmlStart = scriptContent.indexOf(startTag);
  const htmlEnd = scriptContent.indexOf(endTag, htmlStart);
  const html = scriptContent.substring(htmlStart, htmlEnd + endTag.length);
  await page.setContent(html);

  const viewports = [1920, 1440, 1280, 1024, 768];
  for (const w of viewports) {
    await page.setViewportSize({ width: w, height: 800 });
    const layout = await page.evaluate(() => {
      const left = document.querySelector('.header-actions').getBoundingClientRect();
      const right = document.querySelector('.toolbar-right-actions').getBoundingClientRect();
      const search = document.querySelector('.search-box-wrapper').getBoundingClientRect();
      const addBtn = document.querySelector('.btn-add-customer').getBoundingClientRect();
      const board = document.querySelector('.kanban-board').getBoundingClientRect();
      return {
        viewportW: window.innerWidth,
        leftTop: Math.round(left.top),
        rightTop: Math.round(right.top),
        isOneRowDesktop: Math.abs(left.top - right.top) < 10,
        searchTop: Math.round(search.top),
        addBtnTop: Math.round(addBtn.top),
        rightActionsTogether: Math.abs(search.top - addBtn.top) < 5,
        boardTop: Math.round(board.top),
        totalToolbarH: Math.round(board.top - left.top)
      };
    });
    console.log(`Viewport ${w}px:`, layout);
  }
  await browser.close();
}

checkLayout().catch(console.error);
