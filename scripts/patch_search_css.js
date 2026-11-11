const fs = require('fs');
const path = require('path');

const filePath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');
let content = fs.readFileSync(filePath, 'utf8');

// Normalize to \n first
const isCrlf = content.includes('\r\n');
if (isCrlf) {
  content = content.replace(/\r\n/g, '\n');
}

const oldToolbarAfter = `        #GridContentPost .dx-toolbar-after {
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
        }`;

const newToolbarAfter = `        #GridContentPost .dx-toolbar-after {
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            gap: 8px !important;
            margin-left: auto !important;
            padding-right: 16px !important; /* Dịch sang trái 16px để không sát mép phải */
            flex: 0 0 auto !important;
            height: auto !important;
            overflow: visible !important;
            position: relative !important;
            top: auto !important;
            right: auto !important;
        }`;

if (content.includes(oldToolbarAfter)) {
  content = content.replace(oldToolbarAfter, newToolbarAfter);
  console.log('Replaced ToolbarAfter');
} else {
  console.warn('Could not find ToolbarAfter');
}

const oldSearchBlock = `        /* Styling Search Panel Dark Mode */
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

const newSearchBlock = `        /* Styling Search Panel Dark Mode & Fix Placeholder Gray */
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

if (content.includes(oldSearchBlock)) {
  content = content.replace(oldSearchBlock, newSearchBlock);
  console.log('Replaced SearchBlock');
} else {
  console.warn('Could not find SearchBlock');
}

// Convert back to CRLF if needed
if (isCrlf) {
  content = content.replace(/\n/g, '\r\n');
}

fs.writeFileSync(filePath, content, 'utf8');
console.log('Done rewriting file.');
