const fs = require('fs');
const path = require('path');

const folders = fs.readdirSync('fix-bug').filter(f => f.startsWith('screenshot-')).sort((a,b) => {
  return parseInt(a.replace('screenshot-', '')) - parseInt(b.replace('screenshot-', ''));
});

console.log('Auditing and refactoring all', folders.length, 'reports...');

folders.forEach(f => {
  const fPath = path.join('fix-bug', f);
  const repPath = path.join(fPath, 'fix-report.md');
  if (!fs.existsSync(repPath)) return;

  let content = fs.readFileSync(repPath, 'utf8');

  // 1. Clean all absolute paths
  content = content.replace(/\(file:\/\/\/.*?\/fix-bug\/(screenshot-\w+)\/screenshots\/(.*?)\)/g, '(./screenshots/$2)');
  content = content.replace(/\(file:\/\/\/.*?\/Screenshots_1_bug\/(.*?)\)/g, '(./screenshots/$1)');
  content = content.replace(/\(file:\/\/\/.*?\/fix-bug\/(screenshot-\w+)\/(patch_.*?\.sql)\)/g, '(./$2)');
  content = content.replace(/\(file:\/\/\/.*?\/fix-bug\/(screenshot-\w+)\/(origin\.sql)\)/g, '(./$2)');
  content = content.replace(/\(file:\/\/\/.*?\/fix-bug\/(screenshot-\w+)\/(fix-report\.md)\)/g, '(./$2)');

  // 2. Remove any remaining file:/// to local desktop
  content = content.replace(/\(file:\/\/\/c:\/Users\/Y\.Thach\/Desktop\/paradiseHR\/Screenshots_1_bug\/(.*?)\)/g, '(./screenshots/$1)');
  content = content.replace(/\(file:\/\/\/c:\/Users\/Y\.Thach\/Desktop\/paradiseHR\/fix-bug\/(screenshot-\w+)\/screenshots\/(.*?)\)/g, '(./screenshots/$2)');

  // 3. For screenshot-specific adjustments:
  const num = f.replace('screenshot-', '');

  // Case screenshot-3:
  if (f === 'screenshot-3') {
    content = content.replace(
      /\* \*\*Ảnh đối chiếu lỗi\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi màn hình trống trơn](./screenshots/3.png)\n`
    );
  }

  // Case screenshot-4:
  if (f === 'screenshot-4') {
    content = content.replace(
      /- \*\*Hiện tượng thực tế nhìn thấy trên \[Screenshot 4\].*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi 3 ô ngày giờ nền đen](./screenshots/4.png)\n\n- **Hiện tượng thực tế nhìn thấy trên Screenshot 4**:\n`
    );
  }

  // Case screenshot-5:
  if (f === 'screenshot-5') {
    content = content.replace(
      /\* \*\*Minh chứng hình ảnh\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi tạo mật khẩu](./screenshots/5.png)\n`
    );
  }

  // Case screenshot-6:
  if (f === 'screenshot-6') {
    content = content.replace(
      /Trên giao diện màn hình \*\*Danh sách công ty CRM\*\* \(.*?\),/,
      `Trên giao diện màn hình **Danh sách công ty CRM**:\n\n- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi bảng co cụm Danh sách công ty](./screenshots/6.png)\n\nNgười dùng gặp phải 3 khuyết tật hiển thị nghiêm trọng:`
    );
  }

  // Case screenshot-8:
  if (f === 'screenshot-8') {
    if (!content.includes('![Ảnh lỗi nút đè Tab filter')) {
      content = content.replace(
        /1\. \*\*Lỗi trên Tab 2 \(Screenshot 8 - `8\.png`\)\*\*:/,
        `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi nút đè Tab filter (Screenshot 8)](./screenshots/8.png)\n  ![Ảnh lỗi cột hiển thị mã thô (Screenshot 9)](./screenshots/9.png)\n\n1. **Lỗi trên Tab 2 (Screenshot 8)**:`
      );
    }
  }

  // Case screenshot-11:
  if (f === 'screenshot-11') {
    content = content.replace(
      /\* \*\*Minh chứng hình ảnh\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi lệch toolbar Nhập lương Trí Luật](./screenshots/11.png)\n`
    );
  }

  // Case screenshot-13:
  if (f === 'screenshot-13') {
    content = content.replace(
      /2\. \*\*Ảnh đối chiếu thực tế\*\*:\s+- Minh chứng chi tiết tại:.*?\n/,
      `2. **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi xoay loading vô tận](./screenshots/13.png)\n`
    );
  }

  // Case screenshot-14:
  if (f === 'screenshot-14') {
    content = content.replace(
      /- \*\*Ảnh đối chiếu\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi modal bé và sập 0.apply](./screenshots/14.png)\n`
    );
  }

  // Case screenshot-15:
  if (f === 'screenshot-15') {
    content = content.replace(
      /\* \*\*Minh chứng hình ảnh\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi nút Tạo cuộc họp rớt hàng](./screenshots/15.png)\n`
    );
  }

  // Case screenshot-16:
  if (f === 'screenshot-16') {
    content = content.replace(
      /- \*\*Minh chứng\*\*: Xem trực tiếp tại.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi nút Làm mới & Checkbox rớt dòng](./screenshots/16.png)\n`
    );
  }

  // Case screenshot-17:
  if (f === 'screenshot-17') {
    content = content.replace(
      /- \*\*Ảnh đối chiếu\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi 2 checkbox rớt hàng](./screenshots/17.png)\n`
    );
    // Standardize Section 3 heading in screenshot-17 if needed
    content = content.replace(
      '### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)',
      '### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)'
    );
  }

  // Case screenshot-18:
  if (f === 'screenshot-18') {
    content = content.replace(
      /- \*\*Ảnh đối chiếu\*\*:.*?\n/,
      `- **Minh chứng hình ảnh trực quan (Before)**:\n  ![Ảnh lỗi Checkbox Xem của tôi chiếm 1 hàng 80px](./screenshots/18.png)\n`
    );
    content = content.replace(
      '### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)',
      '### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)'
    );
  }

  // Write back
  fs.writeFileSync(repPath, content, 'utf8');
  console.log(`[OK] Refactored ${f}`);
});
