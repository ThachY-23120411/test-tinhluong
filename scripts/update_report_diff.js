const fs = require('fs');
const path = require('path');

const reportPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-report.md');
let report = fs.readFileSync(reportPath, 'utf8');

// Update diff block to reflect the exact cleaned up code
const oldDiffTarget = `+        .c-filter {
+            display: flex !important;
+            align-items: center !important;
+            gap: 10px !important;
+            flex-wrap: wrap !important;
+            margin-bottom: 0px !important;
+            width: 100% !important;
+        }`;

const newDiffReplacement = `+        .c-filter {
+            display: flex !important;
+            flex-direction: row !important;
+            align-items: center !important;
+            gap: 8px !important;
+            flex-wrap: wrap !important;
+            margin-bottom: 0px !important;
+            width: auto !important;
+        }`;

if (report.includes(oldDiffTarget)) {
  report = report.replace(oldDiffTarget, newDiffReplacement);
}

const oldJsDiff = `+                        // FIX SCREENSHOT 27: Đưa các tickbox lên ngang hàng với filter trong cùng 1 hàng flex
+                        if ($employeeDiv) $container.append($employeeDiv);
+                        $container.append($fromDiv, $toDiv, $filterBtn, $resetBtn, $checkboxRow);
+                        $(element).parent().find('.c-filter').remove();
+                        $(element).parent().prepend($container);`;

const newJsDiff = `+                        // FIX SCREENSHOT 27: Cụm filter + tickbox nằm trên 1 hàng flex ngang (flex-direction: row)
+                        const $container = $('<div class="c-filter" style="display: flex; flex-direction: row; align-items: center; gap: 8px; flex-wrap: wrap; width: auto; margin: 0; padding: 0;">');
+                        if ($employeeDiv) $container.append($employeeDiv);
+                        $container.append($fromDiv, $toDiv, $filterBtn, $resetBtn, $checkboxRow);
+                        $(element).parent().find('.c-filter').remove();
+                        $(element).parent().prepend($container);`;

if (report.includes(oldJsDiff)) {
  report = report.replace(oldJsDiff, newJsDiff);
}

// Add crop screenshot to Section 4
const afterCropSection = `##### 🔹 1. Màn hình Desktop (1440px) — Toàn bộ nằm phẳng phiu trên 1 hàng:
![Minh chứng kết quả Desktop sau khi sửa Screenshot 27](screenshot/screenshot-27-after-desktop.png)

##### 🔹 1.1 Chi tiết cận cảnh thanh Toolbar & Bộ lọc sau khi sửa (Component Crop):
![Chi tiết cận cảnh Toolbar](screenshot/screenshot-27-after-crop.png)`;

if (report.includes('##### 🔹 1. Màn hình Desktop (1440px) — Toàn bộ nằm phẳng phiu trên 1 hàng:')) {
  report = report.replace(
    '##### 🔹 1. Màn hình Desktop (1440px) — Toàn bộ nằm phẳng phiu trên 1 hàng:\n![Minh chứng kết quả Desktop sau khi sửa Screenshot 27](screenshot/screenshot-27-after-desktop.png)',
    afterCropSection
  );
}

fs.writeFileSync(reportPath, report, 'utf8');
console.log('Successfully updated fix-report.md');
