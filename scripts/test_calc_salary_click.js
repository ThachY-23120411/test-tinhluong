const { chromium } = require('playwright');

(async () => {
    try {
        const browser = await chromium.launch({ channel: 'chrome', headless: true });
        const page = await browser.newPage();
        
        page.on('console', msg => console.log('BROWSER CONSOLE:', msg.type(), msg.text()));
        page.on('request', req => {
            if (req.url().includes('hpa') || req.url().includes('ashx')) {
                console.log('REQUEST:', req.method(), req.url(), req.postData());
            }
        });
        page.on('response', async res => {
            if (res.url().includes('hpa') || res.url().includes('ashx')) {
                try {
                    const text = await res.text();
                    console.log('RESPONSE:', res.url(), text.substring(0, 300));
                } catch(e) {}
            }
        });

        console.log('1. Navigating to login...');
        await page.goto('https://paradisehrm.com/Tai3/#');
        await page.waitForTimeout(2000);

        console.log('2. Logging in as chien.nguyen...');
        await page.fill('#txtUsername', 'chien.nguyen');
        await page.fill('#txtPassword', '123');
        await page.click('#btnLogin');
        await page.waitForTimeout(3000);

        console.log('3. Opening MnuPRL040...');
        await page.evaluate(() => {
            const el = document.querySelector('a[data-menuid="MnuPRL040"], .menu-item[data-id="MnuPRL040"]');
            if (el) el.click();
            else if (window.LoadChildForm) window.LoadChildForm('MnuPRL040');
            else if (window.openMenu) window.openMenu('MnuPRL040');
        });
        await page.waitForTimeout(4000);

        console.log('4. Finding elements...');
        const buttons = await page.evaluate(() => {
            return Array.from(document.querySelectorAll('button, a.btn, div.dx-button, span')).filter(s => s.innerText && s.innerText.includes('Tính lương')).map(s => ({
                tag: s.tagName,
                cls: s.className,
                text: s.innerText,
                id: s.id
            }));
        });
        console.log('Found buttons:', buttons);

        await browser.close();
    } catch(e) {
        console.error('Test error:', e);
    }
})();
