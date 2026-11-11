const fs = require('fs');
const content = fs.readFileSync('tests/quy_trinh_tinh_luong_nv_moi.spec.js', 'utf8');

const lines = content.split('\n');
console.log('Total lines:', lines.length);

// Check sections
const sections = [
  'KHU VỰC PHÂN CÔNG 1: CONVERSATION [fix-4]',
  'START_TC_01', 'END_TC_01',
  'START_TC_02', 'END_TC_02',
  'START_TC_03', 'END_TC_03',
  'START_TC_04', 'END_TC_04',
  'START_TC_05', 'END_TC_05',
  'KHU VỰC PHÂN CÔNG 2: CONVERSATION [fix-5]',
  'START_TC_06', 'END_TC_06',
  'START_TC_07', 'END_TC_07',
  'START_TC_08', 'END_TC_08',
  'START_TC_09', 'END_TC_09',
  'KHU VỰC PHÂN CÔNG 3: CONVERSATION [fix-6]',
  'START_TC_10', 'END_TC_10',
  'START_TC_11', 'END_TC_11',
  'START_TC_12', 'END_TC_12',
  'START_TC_13', 'END_TC_13',
  'KHU VỰC PHÂN CÔNG 4: CONVERSATION [fix-7]',
  'START_TC_14', 'END_TC_14',
  'START_TC_15', 'END_TC_15',
  'START_TC_16', 'END_TC_16',
  'START_TC_17', 'END_TC_17',
  'KHU VỰC PHÂN CÔNG 5: CONVERSATION [fix-8]',
  'START_TC_18', 'END_TC_18',
  'START_TC_19', 'END_TC_19',
  'START_TC_20', 'END_TC_20'
];

sections.forEach(sec => {
  const lineIdx = lines.findIndex(l => l.includes(sec));
  console.log(`[${sec}]: Line ${lineIdx + 1}`);
});
