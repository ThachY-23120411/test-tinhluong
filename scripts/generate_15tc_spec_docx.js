const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, HeadingLevel, BorderStyle, AlignmentType } = require('docx');
const fs = require('fs');
const path = require('path');

const TC_DATA = [
  {
    id: 'TC-01',
    title: 'CRUD Tạo đơn Xin nghỉ phép và lưu vào CSDL',
    role: 'tai.dang (Nhân viên)',
    menu: 'Xin nghỉ phép (MnuWPT315)',
    action: 'Chọn ngày nghỉ khả dụng, nhập lý do, bấm Đăng ký',
    db: 'tblResignation (Kiểm tra bản ghi đơn nghỉ phép)'
  },
  {
    id: 'TC-02',
    title: 'CRUD Tạo đơn Xin tăng ca và lưu vào CSDL',
    role: 'tai.dang (Nhân viên)',
    menu: 'Xin tăng ca (MnuWPT316)',
    action: 'Thiết lập ngày tăng ca, khung giờ, thêm vào danh sách, bấm Đăng ký',
    db: 'tblOvertime_Assignment (Kiểm tra giờ OT và trạng thái)'
  },
  {
    id: 'TC-03',
    title: 'Quản lý Cấp 1 thẩm định và phê duyệt đơn',
    role: 'ThanhLong (Quản lý trực tiếp)',
    menu: 'Danh sách phê duyệt (MnuWPT037)',
    action: 'Thẩm định đơn của tai.dang, bấm Duyệt, kiểm tra thành phần động (Luật Thép 9)',
    db: 'tblOvertime_Assignment / tblResignation (Cập nhật cấp 1)'
  },
  {
    id: 'TC-04',
    title: 'Quản lý Cấp 2 thẩm định và phê duyệt toàn trình',
    role: 'cuong.vu (Quản lý cấp cao)',
    menu: 'Danh sách phê duyệt (MnuWPT037)',
    action: 'Thẩm định đơn, bấm Duyệt toàn trình, avatar xanh lá, nút hành động ẩn',
    db: 'tblOvertime_Assignment / tblResignation (Duyệt toàn trình)'
  },
  {
    id: 'TC-05',
    title: 'Nhân sự C&B kiểm tra Hồ sơ nhân viên',
    role: 'cuong.vu (Nhân sự C&B)',
    menu: 'Hồ sơ nhân viên (MnuHRS0102)',
    action: 'Lọc nhân viên 046 Đặng Minh Tài, xem tab Thông tin lương và thông tin cơ bản',
    db: 'tblEmployee (Mã NV, chức vụ, phòng ban, lương thỏa thuận)'
  },
  {
    id: 'TC-06',
    title: 'Nhân sự C&B thẩm định Người phụ thuộc NPT',
    role: 'cuong.vu (Nhân sự C&B)',
    menu: 'Thông tin gia đình (MnuHRS157)',
    action: 'Xem danh sách NPT, xác thực mức giảm trừ gia cảnh 4.400.000 VNĐ / người',
    db: 'tblSal_Tax (FamilyDependents, FamilyDeduction)'
  },
  {
    id: 'TC-07',
    title: 'Nhân sự C&B đối soát Hợp đồng lao động',
    role: 'cuong.vu (Nhân sự C&B)',
    menu: 'Quản lý hợp đồng lao động (MnuHRS151)',
    action: 'Xem tab HĐ lao động hiện tại, đối soát hợp đồng và lương đóng bảo hiểm',
    db: 'tblSalaryHistory (Lương đóng BHXH 8%, BHYT 1.5%, BHTN 1%)'
  },
  {
    id: 'TC-08',
    title: 'Nhân sự C&B đối soát Dữ liệu chấm công hàng ngày TAD',
    role: 'cuong.vu (Nhân sự C&B)',
    menu: 'Xem dữ liệu chấm công hằng ngày (MnuHRS225)',
    action: 'Lọc nhân viên 046, kiểm tra công chuẩn 26 ngày, công thực tế và ngày nghỉ đã duyệt',
    db: 'tblDailyAttendance / tblHasTA (Công thực tế)'
  },
  {
    id: 'TC-09',
    title: 'Kế toán trưởng đối soát Trợ cấp lương',
    role: 'chien.nguyen (Kế toán trưởng)',
    menu: 'Trợ cấp lương (MnuMDT210)',
    action: 'Đối soát bảng danh mục phụ cấp lương (phụ cấp ăn trưa, xăng xe, điện thoại)',
    db: 'tblSal_Allowance (Các khoản phụ cấp vào bảng lương)'
  },
  {
    id: 'TC-10',
    title: 'Kế toán trưởng đối soát Thu nhập không cố định',
    role: 'chien.nguyen (Kế toán trưởng)',
    menu: 'Thu nhập không cố định (MnuPRL036)',
    action: 'Xem danh sách thưởng nóng, KPI, hoa hồng, điều chỉnh lương',
    db: 'tblPR_Adjustment (Khoản điều chỉnh thu nhập)'
  },
  {
    id: 'TC-11',
    title: 'Kế toán trưởng kiểm tra Tạm ứng lương',
    role: 'chien.nguyen (Kế toán trưởng)',
    menu: 'Tạm ứng lương (MnuPRL070)',
    action: 'Kiểm tra danh sách tạm ứng lương khấu trừ kỳ này của nhân viên',
    db: 'tblSal_Advance (isLock = 1, số tiền tạm ứng khấu trừ)'
  },
  {
    id: 'TC-12',
    title: 'Kế toán trưởng kích hoạt Tính tiền lương tự động',
    role: 'chien.nguyen (Kế toán trưởng)',
    menu: 'Tính tiền lương (MnuPRL040)',
    action: 'Di chuột Neon nhấp nút Tính lương, chạy tổng hợp tiền lương tự động',
    db: 'tblSal_Sal (Bản ghi tính toán lương hoàn tất)'
  },
  {
    id: 'TC-13',
    title: 'Kế toán trưởng thẩm định chốt chặn Khóa lương',
    role: 'chien.nguyen (Kế toán trưởng)',
    menu: 'Mở/Khóa. Lương (MnuPRL080)',
    action: 'Kiểm tra trạng thái khóa kỳ lương để phân quyền cho nhân viên xem lịch sử',
    db: 'tblSal_LockSalary (IsLock = 1)'
  },
  {
    id: 'TC-14',
    title: 'Nhân viên đối soát định lượng 11 chỉ tiêu trên Phiếu lương',
    role: 'tai.dang (Nhân viên)',
    menu: 'Phiếu lương (MnuPRL445)',
    action: 'Đối soát 11 chỉ tiêu: Lương CB, Ngày công, Tiền OT, Phụ cấp, Thưởng, NPT, BHXH, Thực lĩnh',
    db: 'tblSal_Sal (Đối chiếu khớp định lượng 100% CSDL)'
  },
  {
    id: 'TC-15',
    title: 'Đối soát Tab Lịch sử phiếu lương và 3 Modal Popup Chi tiết',
    role: 'tai.dang (Nhân viên)',
    menu: 'Phiếu lương (MnuPRL445)',
    action: 'Xem Tab Lịch sử, click mở và đối soát 3 Modal (Tăng ca, Ngày nghỉ, Đi trễ)',
    db: 'tblSal_OT_Detail, tblSal_PaidLeave_Detail, tblSal_IO'
  }
];

async function generateDocx() {
  const tableRows = [
    new TableRow({
      children: [
        new TableCell({ children: [new Paragraph({ text: 'Mã TC', style: 'Heading2' })], width: { size: 10, type: WidthType.PERCENTAGE } }),
        new TableCell({ children: [new Paragraph({ text: 'Vai Trò', style: 'Heading2' })], width: { size: 18, type: WidthType.PERCENTAGE } }),
        new TableCell({ children: [new Paragraph({ text: 'Màn Hình / Menu', style: 'Heading2' })], width: { size: 22, type: WidthType.PERCENTAGE } }),
        new TableCell({ children: [new Paragraph({ text: 'Thao Tác Nghiệp Vụ', style: 'Heading2' })], width: { size: 28, type: WidthType.PERCENTAGE } }),
        new TableCell({ children: [new Paragraph({ text: 'Đối Chiếu CSDL', style: 'Heading2' })], width: { size: 22, type: WidthType.PERCENTAGE } })
      ]
    })
  ];

  TC_DATA.forEach(tc => {
    tableRows.push(
      new TableRow({
        children: [
          new TableCell({ children: [new Paragraph(tc.id)] }),
          new TableCell({ children: [new Paragraph(tc.role)] }),
          new TableCell({ children: [new Paragraph(tc.menu)] }),
          new TableCell({ children: [new Paragraph(tc.action)] }),
          new TableCell({ children: [new Paragraph(tc.db)] })
        ]
      })
    );
  });

  const doc = new Document({
    sections: [{
      properties: {},
      children: [
        new Paragraph({
          text: 'TÀI LIỆU ĐẶC TẢ KIỂM THỬ LIÊN HOÀN ĐA PHÂN HỆ & ĐA MÀN HÌNH NUÔI PHIẾU LƯƠNG',
          heading: HeadingLevel.HEADING_1,
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ text: '' }),
        new Paragraph({
          children: [
            new TextRun({ text: 'Dự án: ', bold: true }),
            new TextRun('Paradise HRM (Web Application)')
          ]
        }),
        new Paragraph({
          children: [
            new TextRun({ text: 'Phân hệ: ', bold: true }),
            new TextRun('Chấm Công & Quản Trị Nhân Sự & Tính Lương (TAD - HRS - PRL - WPT)')
          ]
        }),
        new Paragraph({
          children: [
            new TextRun({ text: 'Mục tiêu: ', bold: true }),
            new TextRun('Kiểm thử siêu chuỗi liên hoàn 15 Test Cases, bao quát 13 màn hình hệ thống nuôi trực tiếp dữ liệu vào Phiếu Lương, kiểm soát đa vai trò và triệt tiêu toàn bộ lỗi giả pass theo Luật Thép 9.')
          ]
        }),
        new Paragraph({ text: '' }),
        new Table({
          rows: tableRows,
          width: { size: 100, type: WidthType.PERCENTAGE }
        })
      ]
    }]
  });

  const buffer = await Packer.toBuffer(doc);
  const outPath = path.resolve(__dirname, '../docs/test-specs/cham_cong_tinh_luong_crud_lien_hoan-test-spec.docx');
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, buffer);
  console.log(`Đã xuất tài liệu đặc tả: ${outPath} (${buffer.length} bytes)`);
}

generateDocx().catch(console.error);
