const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));

  await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 10000 });
  await page.fill('#username', 'tai.dang');
  await page.fill('input[type="password"]', '123');
  await page.click('#submitLogin');
  await page.waitForSelector('.dock', { timeout: 20000 });
  await page.waitForTimeout(2000);

  // Click MnuWPT315
  const dockBtn = page.locator('.dock button.open-MnuWPT315, .dock button.MnuWPT315').first();
  await dockBtn.click();
  await page.waitForTimeout(3000);

  // Fill form with AL
  await page.evaluate(() => {
    try {
      if (typeof InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D !== 'undefined' && InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D) {
        InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D.option('value', 'AL');
      }
      var instanceFrom = getControlInstance("LeaveFromDate");
      if (instanceFrom) instanceFrom.option("value", new Date('2026-12-02T08:00:00'));
      var instanceTo = getControlInstance("LeaveToDate");
      if (instanceTo) instanceTo.option("value", new Date('2026-12-02T12:00:00'));
      const el = document.getElementById('lyDo');
      if (el) {
        el.value = 'Nghỉ việc riêng debug test Playwright';
        el.dispatchEvent(new Event('input', { bubbles: true }));
        el.dispatchEvent(new Event('change', { bubbles: true }));
      }
    } catch (e) {
      console.error(e);
    }
  });
  await page.waitForTimeout(1000);

  // Call api_adddata directly and capture output
  const res = await page.evaluate(async () => {
    return new Promise(resolve => {
      var instanceFrom = getControlInstance("LeaveFromDate");
      var instanceTo = getControlInstance("LeaveToDate");
      const dateFrom = instanceFrom ? instanceFrom.option("value") : null;
      const dateTo = instanceTo ? instanceTo.option("value") : null;
      const reason = $("#lyDo").val().trim();
      const leaveTypeSelect = (typeof InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D !== 'undefined') ? InstanceLeaveCodeP59F440E36D7C4C149D326667FF81A79D.option("value") : 'AL';

      function formatDateTime(date) {
        if (!date) return "";
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        const hours = String(date.getHours()).padStart(2, "0");
        const minutes = String(date.getMinutes()).padStart(2, "0");
        const seconds = String(date.getSeconds()).padStart(2, "0");
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      }

      const params = [
        "EmployeeID", employeeId,
        "LeaveFromDate", formatDateTime(dateFrom),
        "LeaveToDate", formatDateTime(dateTo),
        "LeaveCode", leaveTypeSelect,
        "ShiftCode", "",
        "Reason", reason,
        "JsonFile", "[]",
        "IsSubmit", 1,
        "ErrorMessage", ""
      ];

      AjaxHPAParadise({
        data: {
          name: "sp_InsertRegisteredLeave",
          param: params
        },
        success: function (result) {
          resolve({ success: true, result });
        },
        error: function (err) {
          resolve({ error: true, err });
        }
      });
    });
  });

  console.log('Direct API call result:', res);

  await browser.close();
})();
