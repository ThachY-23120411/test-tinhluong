const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { loginAsAdmin } = require('../helpers/auth');
const { navigateToCrmMenu } = require('../helpers/crm_nav');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('Logging in...');
  await loginAsAdmin(page);

  console.log('Navigating to Dữ liệu khách hàng...');
  await navigateToCrmMenu(page, 'Dữ liệu khách hàng');
  await page.waitForTimeout(3000);

  // Inspect buttons
  const buttonsInfo = await page.evaluate(() => {
    const list = [];
    const elements = document.querySelectorAll('button, .dx-button, a.btn, input[type="button"], input[type="submit"], [role="button"], .badge, .chip');
    elements.forEach((el, i) => {
      if (el.offsetParent === null) return; // invisible
      const text = (el.innerText || el.value || el.getAttribute('aria-label') || el.title || '').trim();
      const id = el.id || '';
      const cls = el.className || '';
      const icon = el.querySelector('i, .dx-icon') ? el.querySelector('i, .dx-icon').className : '';
      list.push({ index: i, tag: el.tagName, text, id, cls, icon });
    });
    return list;
  });

  console.log('=== VISIBLE BUTTONS & ACTION CONTROLS ===');
  buttonsInfo.forEach(b => {
    console.log(`[${b.tag}] "${b.text}" | id: "${b.id}" | icon: "${b.icon}" | cls: "${b.cls.slice(0, 50)}"`);
  });

  // Inspect pager
  const pagerInfo = await page.evaluate(() => {
    const pager = document.querySelector('.dx-pager');
    if (!pager) return 'No DevExtreme pager found';
    return {
      text: pager.innerText,
      pageSizes: Array.from(pager.querySelectorAll('.dx-page-size')).map(e => e.innerText.trim()),
      pages: Array.from(pager.querySelectorAll('.dx-page-index, .dx-page')).map(e => e.innerText.trim())
    };
  });
  console.log('\n=== PAGER INFO ===');
  console.log(pagerInfo);

  // Inspect column headers
  const headers = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.dx-header-row td')).map(td => td.innerText.trim()).filter(Boolean);
  });
  console.log('\n=== HEADERS ===');
  console.log(headers);

  await browser.close();
})();
