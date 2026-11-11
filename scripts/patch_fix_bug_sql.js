const fs = require('fs');
const path = require('path');

const filePath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');
let content = fs.readFileSync(filePath, 'utf8');

// 1. Update line 77 c-filter CSS
const oldCssFilter = `.c-filter {
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
            flex-wrap: wrap !important;
            margin-bottom: 0px !important;
            width: 100% !important;
        }`;

const newCssFilter = `.c-filter {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex-wrap: wrap !important;
            margin-bottom: 0px !important;
            width: auto !important;
        }`;

if (content.includes(oldCssFilter)) {
  content = content.replace(oldCssFilter, newCssFilter);
  console.log('Replaced CSS 1 successfully');
} else {
  console.warn('Could not find oldCssFilter, trying regex/normalized replacement');
  content = content.replace(/\.c-filter\s*\{[^}]*width:\s*100%\s*!important;\s*\}/, newCssFilter);
}

// 2. Update lines 227-285 old c-filter selectors
const oldBlockStart = `.c-filter {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }`;

const newBlock = `.c-filter {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex-wrap: wrap !important;
            margin-bottom: 0px !important;
            width: auto !important;
        }

        .c-filter > div {
            display: inline-flex !important;
            align-items: center !important;
        }

        /* File attachment zone */
        #cImagePreview {
            max-width: 100%;
            max-height: 200px;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }

        .c-filter label {
            display: inline-block !important;
            margin: 0 !important;
            font-weight: 500 !important;
            color: #64748b !important;
            font-size: 12px !important;
            white-space: nowrap !important;
        }

        .c-filter input[type="date"] {
            height: 32px !important;
            padding: 4px 8px !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            outline: none !important;
            box-sizing: border-box !important;
            background-color: #ffffff !important;
            color: #1e293b !important;
        }

        .c-filter button {
            height: 32px !important;
            padding: 0 12px !important;
            border: none !important;
            border-radius: 6px !important;
            cursor: pointer !important;
            font-weight: 500 !important;
            font-size: 12px !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            transition: all 0.3s ease !important;
            white-space: nowrap !important;
        }

        .c-filter .btn-reset {
            color: #198754 !important;
            border: 1px solid #198754 !important;
            background: transparent !important;
        }

        .c-filter .btn-reset:hover {
            background-color: #198754 !important;
            color: white !important;
        }`;

const regexOldBlock = /\.c-filter\s*\{\s*display:\s*flex;\s*gap:\s*15px;[\s\S]*?\.c-filter \.btn-reset:hover\s*\{\s*background-color:\s*#198754;\s*color:\s*white;\s*\}/;

if (regexOldBlock.test(content)) {
  content = content.replace(regexOldBlock, newBlock);
  console.log('Replaced CSS 2 block successfully');
} else {
  console.warn('Regex for CSS 2 block did not match');
}

// 3. Update JavaScript $container
const oldJsContainer = `const $container = $(''<div class="c-filter" style="display: flex; flex-direction: column; gap: 10px;">'');`;
const newJsContainer = `const $container = $(''<div class="c-filter" style="display: flex; flex-direction: row; align-items: center; gap: 8px; flex-wrap: wrap; width: auto; margin: 0; padding: 0;">'');`;

if (content.includes(oldJsContainer)) {
  content = content.replace(oldJsContainer, newJsContainer);
  console.log('Replaced JS $container successfully');
} else {
  console.warn('Could not find oldJsContainer');
}

// 4. Update Date Inputs and button styles
content = content.replace(
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="padding: 6px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 140px;">'');`,
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box;">'');`
);

content = content.replace(
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="padding: 6px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 140px;">'');`,
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box;">'');`
);

content = content.replace(
  `const $filterBtn = $(''<button class="btn btn-success" id="cFilterSearchBtn" style="padding: 6px 12px; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-filter"></i> Làm mới</button>'');`,
  `const $filterBtn = $(''<button class="btn btn-success" id="cFilterSearchBtn" style="height: 32px; padding: 0 12px; color: white; border: none; border-radius: 6px; font-size: 12px; font-weight: 500; cursor: pointer; white-space: nowrap; display: inline-flex; align-items: center; gap: 6px; flex-shrink: 0;"><i class="bi bi-filter"></i> Làm mới</button>'');`
);

content = content.replace(
  `const $resetBtn = $(''<button class="d-none btn btn-outline-success" id="cFilterResetBtn" style="border:1px solid #198754; padding: 6px 12px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');`,
  `const $resetBtn = $(''<button class="d-none btn btn-outline-success" id="cFilterResetBtn" style="height: 32px; border: 1px solid #198754; padding: 0 12px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');`
);

content = content.replace(
  `const $checkboxRow = $(''<div style="display: flex; align-items: center; gap: 12px; flex-shrink: 0; margin-left: 5px;">'');`,
  `const $checkboxRow = $(''<div style="display: inline-flex; align-items: center; gap: 12px; flex-shrink: 0; margin-left: 4px;">'');`
);

content = content.replace(
  `$viewAllWrap.append(''<label for="cFilterViewAll" style="font-size: 11px; color: #94a3b8; white-space: nowrap; cursor: pointer; margin: 0;">%ViewAllDays%</label>'');`,
  `$viewAllWrap.append(''<label for="cFilterViewAll" style="font-size: 12px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0;">%ViewAllDays%</label>'');`
);

content = content.replace(
  `$myWrap.append(''<label for="cFilterMyData" style="font-size: 11px; color: #94a3b8; white-space: nowrap; cursor: pointer; margin: 0;">Chỉ xem của tôi</label>'');`,
  `$myWrap.append(''<label for="cFilterMyData" style="font-size: 12px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0;">Chỉ xem của tôi</label>'');`
);

content = content.replace(
  `''style="padding: 6px 14px; border: none; border-radius: 6px; cursor: pointer; '' +`,
  `''style="height: 32px; padding: 0 14px; border: none; border-radius: 6px; cursor: pointer; '' +`
);

fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated fix-bug.sql');
