const fs = require('fs');
const path = 'tests/quy_trinh_tinh_luong_nv_moi.spec.js';

let content = fs.readFileSync(path, 'utf8');

// Check exact target block for fix-5
const startMarker = '// ============================================================================\n// KHU VỰC PHÂN CÔNG 2: CONVERSATION [fix-5] (PRIORITY P2: KHẢO SÁT BEFORE & NỘP 3 ĐƠN)\n// ============================================================================';
const endMarker = '// ============================================================================\n// KHU VỰC PHÂN CÔNG 3: CONVERSATION [fix-6]';

const startIndex = content.indexOf(startMarker);
const endIndex = content.indexOf(endMarker);

console.log('Start index:', startIndex);
console.log('End index:', endIndex);

if (startIndex === -1 || endIndex === -1) {
  console.error('Markers not found');
  process.exit(1);
}

const targetBlock = content.substring(startIndex, endIndex);
console.log('Target block preview:');
console.log(targetBlock.substring(0, 300));
