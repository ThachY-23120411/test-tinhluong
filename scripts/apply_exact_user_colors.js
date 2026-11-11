const fs = require('fs');
const path = require('path');

const filePath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');
let content = fs.readFileSync(filePath, 'utf8');

// Normalize CRLF to LF for reliable replacements
const isCrlf = content.includes('\r\n');
if (isCrlf) {
  content = content.replace(/\r\n/g, '\n');
}

// 1. Search panel background: #212529, border: #3e444a, placeholder: #8b949e
content = content.replace(
  `        /* Styling Search Panel Dark Mode & Fix Placeholder Gray */
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
        }`,
  `        /* Styling Search Panel Dark Mode & Fix Placeholder Gray (#8b949e, bg #212529) */
        #GridContentPost .dx-datagrid-search-panel {
            margin-right: 12px !important; /* Khoảng cách an toàn phía bên phải */
            background-color: #212529 !important;
            border: 1px solid #3e444a !important;
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
        /* Placeholder chữ màu xám #8b949e đồng bộ chuẩn giao diện người dùng yêu cầu */
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input::placeholder {
            color: #8b949e !important;
            -webkit-text-fill-color: #8b949e !important;
            opacity: 1 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input::-webkit-input-placeholder {
            color: #8b949e !important;
            -webkit-text-fill-color: #8b949e !important;
            opacity: 1 !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder,
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder::before {
            color: #8b949e !important;
            -webkit-text-fill-color: #8b949e !important;
        }
        #GridContentPost .dx-datagrid-search-panel .dx-icon-search,
        #GridContentPost .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear {
            color: #8b949e !important;
        }`
);

// 2. Date inputs CSS background #212529, border #3e444a
content = content.replace(
  `        .c-filter input[type="date"] {
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
        }`,
  `        .c-filter input[type="date"] {
            height: 32px !important;
            padding: 4px 10px !important;
            border: 1px solid #3e444a !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            outline: none !important;
            box-sizing: border-box !important;
            background-color: #212529 !important;
            color: #ffffff !important;
            color-scheme: dark !important;
        }`
);

// 3. Date inputs JS inline styles
content = content.replace(
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');`,
  `$fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 10px; border: 1px solid #3e444a; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #212529; color: #ffffff; color-scheme: dark;">'');`
);

content = content.replace(
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');`,
  `$toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 10px; border: 1px solid #3e444a; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #212529; color: #ffffff; color-scheme: dark;">'');`
);

// Restore CRLF if needed
if (isCrlf) {
  content = content.replace(/\n/g, '\r\n');
}

fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated fix-bug.sql with exact user colors (#212529, #3e444a, #8b949e)!');
