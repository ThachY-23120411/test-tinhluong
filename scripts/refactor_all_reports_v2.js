const fs = require('fs');
const path = require('path');

const reportsMeta = [
  {
    dir: 'screenshot-1',
    fixedImgs: [
      {
        path: './screenshots/1_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng giao diện Lịch sử đổi quà sau khi sửa: Cột Ngày đổi, Nhân viên, Quà tặng, Coin và Trạng thái căn chỉnh thẳng hàng tăm tắp, badge Đã nhận căn trái đẹp mắt.'
      }
    ]
  },
  {
    dir: 'screenshot-2',
    fixedImgs: [
      {
        path: './screenshots/2_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Cổng thanh toán công nợ sau khi sửa: Toàn bộ header và các ô số liệu Tổng công nợ, Đã thu, Còn nợ, Liên hệ, Trạng thái thẳng hàng, căn giữa trung tâm, không còn bị lệch sang lề phải.'
      }
    ]
  },
  {
    dir: 'screenshot-3',
    fixedImgs: [
      {
        path: './screenshots/3_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Dashboard CRM sau khi sửa: Toàn bộ thẻ KPI Email thủ công, Thu thập dữ liệu, Content, Demo hiển thị đầy đủ số liệu và tỷ lệ tăng trưởng, không còn bị trắng trang.'
      }
    ]
  },
  {
    dir: 'screenshot-4',
    fixedImgs: [
      {
        path: './screenshots/4_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Dashboard CRM - Bộ lọc ngày giờ sau khi sửa: Các ô Nhân viên, Xem theo, Thời gian nền đen bị triệt tiêu, ăn khớp đồng bộ theme tối của hệ thống.'
      }
    ]
  },
  {
    dir: 'screenshot-5',
    fixedImgs: [
      {
        path: './screenshots/5_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Menu Tạo mật khẩu sau khi sửa: Form tạo mật khẩu 2 cột hiện đại, đầy đủ trường Mật khẩu mới & Xác nhận mật khẩu, nút Lưu mật khẩu và Đóng tab an toàn.'
      }
    ]
  },
  {
    dir: 'screenshot-6',
    fixedImgs: [
      {
        path: './screenshots/6_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Danh sách công ty CRM sau khi sửa: Bảng DataGrid hiển thị tràn viền 100%, 4 cột Tên công ty, Địa chỉ, Mã số thuế, Kích hoạt thoáng đãng, triệt tiêu khoảng đen bên phải.'
      }
    ]
  },
  {
    dir: 'screenshot-8',
    fixedImgs: [
      {
        path: './screenshots/8_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Quản lý hợp đồng lao động sau khi sửa: Cụm 5 chip lọc nằm riêng biệt trên Hàng 1, cụm 4 nút thao tác In/Xuất/Làm mới/Tìm kiếm nằm riêng trên Hàng 2, không còn đè bẹp lên nhau.'
      }
    ]
  },
  {
    dir: 'screenshot-11',
    fixedImgs: [
      {
        path: './screenshots/11_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Nhập lương Trí Luật sau khi sửa: Cụm Toolbar Tháng, Năm, Duyệt công nợ, Chuyển khoản, Thông báo, Làm mới, Tải lên/xuống, Tìm kiếm thu gọn trên đúng 1 hàng duy nhất.'
      }
    ]
  },
  {
    dir: 'screenshot-13',
    fixedImgs: [
      {
        path: './screenshots/13_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Danh sách công nợ khách hàng sau khi sửa: Vòng xoay spinner biến mất, toàn bộ dữ liệu công nợ khách hàng hiển thị đầy đủ, không còn bị treo vô tận.'
      }
    ]
  },
  {
    dir: 'screenshot-14',
    fixedImgs: [
      {
        path: './screenshots/14_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Các email theo dõi KPI sau khi sửa: Bảng danh sách email hiển thị 100% full width, không còn bị lỗi 0.apply và modal hiển thị kích thước chuẩn 580px.'
      }
    ]
  },
  {
    dir: 'screenshot-15',
    fixedImgs: [
      {
        path: './screenshots/15_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Các cuộc họp CRM sau khi sửa: Nút Tạo cuộc họp mới không bị nhân bản, toàn bộ cụm chọn nhân viên, ngày tháng, làm mới, tìm kiếm và nút Tạo cuộc họp nằm trên 1 hàng 42px.'
      }
    ]
  },
  {
    dir: 'screenshot-16',
    fixedImgs: [
      {
        path: './screenshots/16_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Theo dõi dịch vụ bán hàng sau khi sửa: Toolbar thu gọn chuẩn 1 hàng 42px duy nhất, nút Làm mới và Checkbox Xem của tôi nằm ngang hàng, không bị rớt dòng.'
      }
    ]
  },
  {
    dir: 'screenshot-17',
    fixedImgs: [
      {
        path: './screenshots/17_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Email gửi thủ công sau khi sửa: Hai Checkbox "Xem tất cả các ngày" và "Chỉ xem của tôi" nằm thẳng hàng cùng Toolbar trên 1 dòng duy nhất, không bị rớt hàng.'
      }
    ]
  },
  {
    dir: 'screenshot-18',
    fixedImgs: [
      {
        path: './screenshots/18_fixed.png',
        title: 'Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)',
        caption: 'Minh chứng Dữ liệu khách hàng KPI sau khi sửa: Checkbox "Xem của tôi" gom chung vào hàng chip lọc chính, thu gọn Toolbar về chuẩn 42px, triệt tiêu hàng trống 80px.'
      }
    ]
  },
  {
    dir: 'screenshot-20',
    fixedImgs: [
      {
        path: './screenshots/20_fixed.png',
        title: 'Minh chứng kết quả Tổng quan hỗ trợ sau khi sửa (Screenshot 20)',
        caption: 'Tổng quan hỗ trợ: Chào mừng hiển thị tên công ty VIET TIN SOFTWARE, DevTools sạch 100% không còn lỗi Console, avatar hiển thị an toàn.'
      },
      {
        path: './screenshots/21_fixed.png',
        title: 'Minh chứng kết quả Xin nghỉ phép sau khi sửa (Screenshot 21)',
        caption: 'Xin nghỉ phép: Nạp đầy đủ thông tin nhân viên (Nguyễn Tấn Chiến - 013), số ngày phép còn lại (10.0625 ngày), người duyệt (Mr. Cường [014]), không còn lỗi đỏ.'
      },
      {
        path: './screenshots/22_fixed.png',
        title: 'Minh chứng kết quả Đổi quà tặng sau khi sửa (Screenshot 22)',
        caption: 'Cửa hàng quà tặng: Hiển thị đầy đủ số dư 10,000 Coin, danh mục quà tặng (Tiền mặt 500k, Huy hiệu 100%, 1 Ly Cafe), nút Đổi ngay / Tặng, không còn màn hình trắng.'
      },
      {
        path: './screenshots/23_fixed.png',
        title: 'Minh chứng kết quả Lịch sử đổi quà sau khi sửa (Screenshot 23)',
        caption: 'Lịch sử đổi quà: Hiển thị trọn vẹn toàn bộ 91 dòng bản ghi trong cơ sở dữ liệu, cột và dữ liệu thẳng hàng, không còn báo "No data".'
      }
    ]
  }
];

for (const meta of reportsMeta) {
  const reportPath = path.join('fix-bug', meta.dir, 'fix-report.md');
  if (!fs.existsSync(reportPath)) continue;

  let content = fs.readFileSync(reportPath, 'utf8');
  let lines = content.split('\n');

  // 1. Remove Verification Guide section
  const vGuideIdx = lines.findIndex(l => /^###\s+[0-9]\.\s*(QUY TRÌNH THỰC THI|HƯỚNG DẪN NGHIỆM THU|HƯỚNG DẪN KIỂM TRA)/i.test(l));
  let preservedTail = [];

  if (vGuideIdx !== -1) {
    // Check if there is a section like "CAM KẾT AN TOÀN DỮ LIỆU" after it (e.g. in screenshot-6)
    const nextH3Idx = lines.slice(vGuideIdx + 1).findIndex(l => /^###\s+[0-9]\./.test(l));
    if (nextH3Idx !== -1) {
      preservedTail = lines.slice(vGuideIdx + 1 + nextH3Idx);
      // Renumber headings in preservedTail if necessary
      preservedTail = preservedTail.map(l => l.replace(/^###\s+[0-9]\./, '### 4.'));
    }
    // Truncate from vGuideIdx
    lines = lines.slice(0, vGuideIdx);
  }

  // Trim trailing empty lines and horizontal rules
  while (lines.length > 0 && (lines[lines.length - 1].trim() === '' || lines[lines.length - 1].trim() === '---')) {
    lines.pop();
  }

  // 2. Add After Fix screenshot(s) if not already in lines
  let textSoFar = lines.join('\n');
  const missingImgs = meta.fixedImgs.filter(img => !textSoFar.includes(img.path));

  if (missingImgs.length > 0) {
    lines.push('');
    lines.push('---');
    lines.push('');
    lines.push('### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)');
    lines.push('');
    for (const img of missingImgs) {
      lines.push(`#### ${img.title}:`);
      lines.push(`![${img.title}](${img.path})`);
      lines.push(`*${img.caption}*`);
      lines.push('');
    }
  }

  // Re-attach preservedTail if any
  if (preservedTail.length > 0) {
    lines.push('---');
    lines.push('');
    lines.push(...preservedTail);
  }

  fs.writeFileSync(reportPath, lines.join('\n') + '\n', 'utf8');
  console.log(`[OK] Refactored & added after screenshots: ${meta.dir}`);
}

console.log('All reports refactored successfully!');
