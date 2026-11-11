const fs = require('fs');

const html = fs.readFileSync('scripts/returned_html.html', 'utf8');
const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/i;
const match = scriptRegex.exec(html);

if (match) {
  const js = match[1];
  const lines = js.split('\n');
  console.log('Total JS lines:', lines.length);

  // Dò binary search hoặc từng đoạn để tìm dòng lỗi
  for (let i = 1; i <= lines.length; i++) {
    const chunk = lines.slice(0, i).join('\n');
    try {
      // Bọc thử xem có parse được không
      new Function(chunk + '\n;} catch(e){}');
    } catch (e) {
      if (e.message.includes('Invalid or unexpected token') || e.message.includes('Unexpected token')) {
        console.log(`Error around line ${i}: ${e.message}`);
        console.log('Line content:', lines[i - 1]);
        // In 5 dòng trước và sau
        for (let j = Math.max(0, i - 5); j < Math.min(lines.length, i + 5); j++) {
          console.log(`${j + 1}: ${lines[j]}`);
        }
        break;
      }
    }
  }
}
