const fs = require('fs');
const path = require('path');

function replaceInFile(relPath, replacements) {
  const fullPath = path.resolve(relPath);
  if (!fs.existsSync(fullPath)) return;
  let content = fs.readFileSync(fullPath, 'utf8');
  for (const [target, replacement] of replacements) {
    content = content.replace(target, replacement);
  }
  fs.writeFileSync(fullPath, content, 'utf8');
  console.log(`[OK] Aligned: ${relPath}`);
}

// 1. screenshot-1
replaceInFile('fix-bug/screenshot-1/fix-report.md', [
  ['### 2. TÓM TẮT NGUYÊN NHÂN LỖI & CÁCH SỬA (NGẮN GỌN & DỄ HIỂU)', '### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)']
]);

// 2. screenshot-3
replaceInFile('fix-bug/screenshot-3/fix-report.md', [
  ['### 2. NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)', '### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)']
]);

// 3. screenshot-5
replaceInFile('fix-bug/screenshot-5/fix-report.md', [
  ['### 3. ĐỀ XUẤT 2 PHƯƠNG ÁN XỬ LÝ (STRATEGIC SOLUTIONS)', '#### 2.4. Đề xuất 2 phương án xử lý (Strategic Solutions)'],
  ['### 4. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)', '### 3. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)'],
  ['### 5. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU', '### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU']
]);

// 4. screenshot-11
replaceInFile('fix-bug/screenshot-11/fix-report.md', [
  ['### 3. HƯỚNG GIẢI QUYẾT TRIỆT ĐỂ (SOLUTION ARCHITECTURE)', '#### 2.3. Hướng giải quyết triệt để (Solution Architecture)'],
  ['### 4. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)', '### 3. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)'],
  ['### 5. GIẢI TRÌNH LIÊN KẾT DOM & SELECTOR CSS', '### 4. GIẢI TRÌNH LIÊN KẾT DOM & SELECTOR CSS'],
  ['### 6. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU', '### 5. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU']
]);

// 5. screenshot-14
replaceInFile('fix-bug/screenshot-14/fix-report.md', [
  ['### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)', '### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)']
]);

// 6. screenshot-15
replaceInFile('fix-bug/screenshot-15/fix-report.md', [
  ['### 3. HƯỚNG GIẢI QUYẾT TRIỆT ĐỂ (SOLUTION ARCHITECTURE)', '#### 2.3. Hướng giải quyết triệt để (Solution Architecture)'],
  ['### 4. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)', '### 3. ĐỐI CHIẾU MÃ NGUỒN BEFORE VS AFTER (CODE CŨ VS CODE MỚI)'],
  ['### 5. GIẢI TRÌNH LIÊN KẾT DOM & SELECTOR CSS', '### 4. GIẢI TRÌNH LIÊN KẾT DOM & SELECTOR CSS'],
  ['### 6. HƯỚNG DẪN KIỂM TRA & TIÊU CHUẨN NGHIỆM THU', '### 5. HƯỚNG DẪN KIỂM TRA & TIÊU CHUẨN NGHIỆM THU']
]);

// 7. screenshot-16
replaceInFile('fix-bug/screenshot-16/fix-report.md', [
  ['### 2. TÓM TẮT NGUYÊN NHÂN LỖI & CÁCH SỬA (MÔ HÌNH KHUNG BAO BỌC)', '### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ & MÔ HÌNH KHUNG BAO BỌC (ROOT CAUSE ANALYSIS - RCA)']
]);

console.log('Heading alignment completed!');
