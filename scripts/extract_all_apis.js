const fs = require('fs');

function extractApis(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const regex = /name:\s*["']([^"']+)["']/g;
  const apis = new Set();
  let match;
  while ((match = regex.exec(content)) !== null) {
    apis.add(match[1]);
  }
  return Array.from(apis);
}

try {
  const staffApis = extractApis('./scripts/staff_info_list_2.html');
  console.log('APIs in staff_info_list_2.html:');
  console.log(staffApis);

  const bankApis = extractApis('./scripts/popup_info_bank.html');
  console.log('APIs in popup_info_bank.html:');
  console.log(bankApis);
} catch (e) {
  console.error(e);
}
