const fs = require('fs');

const html = fs.readFileSync('scripts/returned_html.html', 'utf8');

// Tìm tất cả các đoạn <script>...</script>
const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/gi;
let match;
let count = 0;

while ((match = scriptRegex.exec(html)) !== null) {
  count++;
  const js = match[1];
  console.log(`Checking script tag #${count}, length: ${js.length}...`);
  try {
    // Dùng new Function để kiểm tra cú pháp syntax JS
    new Function(js);
    console.log(`Script #${count} syntax OK!`);
  } catch (err) {
    console.error(`Script #${count} SYNTAX ERROR:`, err.message);
    // Tìm dòng gây lỗi
    const lines = js.split('\n');
    console.log('Total lines:', lines.length);
  }
}

if (count === 0) {
  console.warn('NO SCRIPT TAGS FOUND IN HTML!');
}
