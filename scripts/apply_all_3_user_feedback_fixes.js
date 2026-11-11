const fs = require('fs');
const path = require('path');

const filePath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');
let content = fs.readFileSync(filePath, 'utf8').replace(/\r\n/g, '\n');

// 1. Update .dx-toolbar-after padding-right: 16px
content = content.replace(
  `        #GridContentPost .dx-toolbar-after {
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            gap: 8px !important;
            margin-left: auto !important;
            flex: 0 0 auto !important;
            height: auto !important;
            overflow: visible !important;
            position: relative !important;
            top: auto !important;
            right: auto !important;
        }`,
  `        #GridContentPost .dx-toolbar-after {
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            gap: 8px !important;
            margin-left: auto !important;
            padding-right: 16px !important; /* Dịch chuyển cụm tìm kiếm sang trái 16px để không sát mép phải */
            flex: 0 0 auto !important;
            height: auto !important;
            overflow: visible !important;
            position: relative !important;
            top: auto !important;
            right: auto !important;
        }`
);

// 2. Update Search panel styling & placeholder gray
const oldSearchPanelCss = `        /* Styling Search Panel Dark Mode */
        #GridContentPost .dx-datagrid-search-panel {
            margin-right: 0px !important;
            background-color: #1e293b !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
        }
        #GridContentPost .dx-datagrid-search-panel.dx-state-focused {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input {
            color: #ffffff !important;
            -webkit-text-fill-color: #ffffff !important;
            background-color: transparent !important;
            font-size: 12px !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder,
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder::before {
            color: #94a3b8 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-icon-search,
        #GridContentPost .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear {
            color: #94a3b8 !important;
        }`;

const newSearchPanelCss = `        /* Styling Search Panel Dark Mode & Fix Placeholder Gray */
        #GridContentPost .dx-datagrid-search-panel {
            margin-right: 12px !important; /* Khoảng cách an toàn phía bên phải */
            background-color: #1e293b !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            height: 32px !important;
        }
        #GridContentPost .dx-datagrid-search-panel.dx-state-focused {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input {
            color: #ffffff !important;
            background-color: transparent !important;
            font-size: 12px !important;
            height: 32px !important;
        }
        /* Placeholder màu xám #94a3b8 đồng bộ chuẩn Dark Mode */
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input::placeholder {
            color: #94a3b8 !important;
            -webkit-text-fill-color: #94a3b8 !important;
            opacity: 1 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input::-webkit-input-placeholder {
            color: #94a3b8 !important;
            -webkit-text-fill-color: #94a3b8 !important;
            opacity: 1 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder,
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder::before {
            color: #94a3b8 !important;
            -webkit-text-fill-color: #94a3b8 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-icon-search,
        #GridContentPost .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear {
            color: #94a3b8 !important;
        }`;

content = content.replace(oldSearchPanelCss, newSearchPanelCss);

// 3. Update date input CSS to match dark theme + hide duplicate resetBtn
const oldFilterInputCss = `        .c-filter input[type="date"] {
            height: 32px !important;
            padding: 4px 8px !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            outline: none !important;
            box-sizing: border-box !important;
            background-color: #ffffff !important;
            color: #1e293b !important;
        }`;

const newFilterInputCss = `        .c-filter input[type="date"] {
            height: 32px !important;
            padding: 4px 10px !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            outline: none !important;
            box-sizing: border-box !important;
            background-color: #1e293b !important;
            color: #ffffff !important;
            color-scheme: dark !important;
        }
        .c-filter input[type="date"]:focus {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }
        .c-filter input[type="date"]:disabled {
            background-color: #0f172a !important;
            color: #64748b !important;
            border-color: #1e293b !important;
            cursor: not-allowed !important;
        }
        /* Ẩn triệt để nút làm mới thứ 2 */
        .c-filter button.d-none,
        #cFilterResetBtn {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            border: none !important;
            visibility: hidden !important;
        }`;

content = content.replace(oldFilterInputCss, newFilterInputCss);

// 4. Update JavaScript Date Inputs styling
content = content.replace(
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box;">'');`,
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');`
);

content = content.replace(
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box;">'');`,
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');`
);

// 5. Update $resetBtn and $container.append in JS
content = content.replace(
  `const $resetBtn = $(''<button class="d-none btn btn-outline-success" id="cFilterResetBtn" style="height: 32px; border: 1px solid #198754; padding: 0 12px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');`,
  `const $resetBtn = $(''<button class="d-none btn btn-outline-success" id="cFilterResetBtn" style="display: none !important; width: 0; height: 0; padding: 0; border: none; margin: 0;"></button>'');`
);

content = content.replace(
  `$container.append($fromDiv, $toDiv, $filterBtn, $resetBtn, $checkboxRow);`,
  `$container.append($fromDiv, $toDiv, $filterBtn, $checkboxRow);`
);

fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated fix-bug.sql with all 3 fixes!');
