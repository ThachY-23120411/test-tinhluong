const fs = require('fs');
const path = require('path');

const specData = {
  systemName: "Paradise HRM - Phân hệ Chấm công & Tính lương",
  pageName: "Kịch bản Kiểm thử Chuẩn chỉnh Luồng Chấm công & Tính lương (E2E Payroll Workflow)",
  menuUrl: "https://paradisehrm.com/Tai3/# (Phân hệ Cổng thông tin nhân sự, Chấm công & Tính lương)",
  createdDate: "02/11/2026",
  inventory: [
    {
      name: "Form Tạo đơn xác nhận công / Xin bù công",
      group: "Portal Nhân viên (MnuWPT017)",
      selector: "#formAttendanceConfirmRequest",
      action: "Chọn ngày bù công, ca làm việc (HC), nhập giờ vào In1, giờ ra Out1, nhập lý do giải trình quên quẹt thẻ"
    },
    {
      name: "Nút Gửi đơn xin bù công",
      group: "Portal Nhân viên (MnuWPT017)",
      selector: "button#btnSubmitRequest",
      action: "Lưu bản ghi vào tblAttendanceConfirmRequest với trạng thái Approve_Status = 0 (Chờ duyệt)"
    },
    {
      name: "Danh sách đơn chờ duyệt của Quản lý",
      group: "Portal Quản lý (MnuWPT032)",
      selector: "#GridPendingConfirmRequest",
      action: "Hiển thị danh sách các đơn xác nhận công do cấp dưới gửi lên kèm thông tin chi tiết giờ đề xuất"
    },
    {
      name: "Nút Phê duyệt đơn (Approve)",
      group: "Portal Quản lý (MnuWPT032)",
      selector: "button.btn-approve-request",
      action: "Cập nhật Approve_Status = 1, lưu ApproverID và ghi nhận công hợp lệ vào lịch trình làm việc"
    },
    {
      name: "Bảng dữ liệu chấm công hằng ngày",
      group: "Chấm công HR (MnuHRS225)",
      selector: "#GridDailyAttendanceData",
      action: "Hiển thị chi tiết giờ quẹt thẻ In/Out thực tế của từng nhân viên theo từng ngày trong tháng"
    },
    {
      name: "Nút Tính lại dữ liệu chấm công",
      group: "Chấm công HR (MnuHRS225)",
      selector: "button#btnRecalculateDailyAtt",
      action: "Gọi spDailyAttendanceData_ReCalculate đồng bộ giờ bù công đã duyệt vào công chuẩn ngày"
    },
    {
      name: "Nút Xử lý tổng hợp công cả tháng",
      group: "Tổng hợp công HR (MnuTAD1000)",
      selector: "button#btnProcessMonthlySummary",
      action: "Gọi sp_ProcessAttendanceSummaryMonthly chốt tổng số ngày công chuẩn và ngày công thực tế"
    },
    {
      name: "Nút Khóa dữ liệu chấm công",
      group: "Khóa công HR (MnuTAD125)",
      selector: "button#btnLockAttendancePeriod",
      action: "Cập nhật isLock = 1 trong tblSal_Lock, đóng cổng không cho tạo hoặc duyệt đơn lùi ngày"
    },
    {
      name: "Nút Tính lương tự động (SALCAL_MAIN)",
      group: "Tính lương Payroll (MnuPRL102)",
      selector: "button#btnCalculateSalaryMain",
      action: "Thực thi thuật toán tính toàn bộ bảng lương: lương thời gian, phụ cấp, OT, BHXH, Thuế TNCN, Thực lãnh"
    },
    {
      name: "Nút Khóa bảng lương chính thức",
      group: "Duyệt lương Giám đốc (MnuPRL120)",
      selector: "button#btnLockSalaryOfficial",
      action: "Khóa sổ kế toán kỳ lương, chốt dữ liệu để xuất file ngân hàng và phát hành phiếu lương"
    },
    {
      name: "Nút Xuất file Ngân hàng",
      group: "Ngân hàng Payroll (MnuPRL092)",
      selector: "button#btnExportBankTransfer",
      action: "Xuất dữ liệu chi trả lương ra file Excel / Text theo chuẩn kết nối ngân hàng"
    },
    {
      name: "Giao diện Phiếu lương nhân viên",
      group: "Portal Nhân viên (MnuPRL445)",
      selector: "#viewSalarySlipContainer",
      action: "Hiển thị chi tiết 5 phần: Thông tin cá nhân, Thông tin lương công, Thu nhập khác, Khấu trừ, Thuế TNCN & Thực lãnh"
    }
  ],
  controlCases: [
    {
      id: "TC-CTL-01",
      title: "Kiểm tra Kiểm soát Ràng buộc trên Form Xin Bù Công (Validation Controls)",
      objective: "Thẩm định các ràng buộc bắt buộc (ngày bù công, ca làm việc, giờ vào/ra, lý do) trên form Xin bù công",
      precondition: "Nhân viên tai.dang (Pass: 123, Mã: 046) đã đăng nhập vào Portal và mở menu 'Xin bù công' (MnuWPT017)",
      testData: "Nhân viên: tai.dang (Mã: 046), Pass: 123, Ca làm việc: HC, Giờ vào In1: 08:00, Giờ ra Out1: 17:00, Lý do: 'Quên quẹt thẻ do đi công tác gặp khách hàng'",
      steps: [
        "Bước 1: Mở menu Cổng thông tin nhân sự > Xin bù công (MnuWPT017)",
        "Bước 2: Để trống trường Giờ vào và Giờ ra, bấm 'Gửi đơn' để kiểm tra validation",
        "Bước 3: Xác nhận thông báo lỗi 'Vui lòng nhập đầy đủ giờ vào và giờ ra hợp lệ'",
        "Bước 4: Nhập Giờ vào In1 = 08:00:00, Giờ ra Out1 = 17:00:00, Ca làm việc = HC",
        "Bước 5: Nhập lý do giải trình thực tế: 'Quên quẹt thẻ do đi công tác gặp khách hàng'",
        "Bước 6: Nhấn nút 'Gửi đơn' và bắt phản hồi hệ thống lưu thành công"
      ],
      expected: "Hệ thống chặn submit khi thiếu giờ, và lưu thành công khi nhập đủ thông tin. Bản ghi mới có trạng thái Approve_Status = 0 (Chờ duyệt).",
      dbQuery: {
        "sql": "SELECT TOP 1 IdentityID, EmployeeID, AttDate, ShiftCode, In1, Out1, Approve_Status, Remark FROM tblAttendanceConfirmRequest WHERE EmployeeID = '046' ORDER BY CreateTime DESC",
        "expectedResult": "Bản ghi mới tồn tại với EmployeeID = '046', In1 = '08:00:00', Out1 = '17:00:00', Approve_Status = 0"
      }
    },
    {
      id: "TC-CTL-02",
      title: "Kiểm tra Bộ lọc Kỳ lương & Tìm kiếm Nhân viên trên Màn hình Phiếu Lương",
      objective: "Thẩm định tính năng chọn Tháng/Năm và tìm kiếm nhân viên trên giao diện Phiếu lương (sp_salaryslip)",
      precondition: "Tài khoản có quyền xem phiếu lương đang truy cập menu 'Phiếu lương' (MnuPRL445)",
      testData: "Tháng/Năm kiểm tra: Tháng 08/2026 và Tháng 10/2026; Nhân sự: NGUYỄN TẤN CHIẾN (Chien.nguyen - Pass: 123, Mã: 013)",
      steps: [
        "Bước 1: Mở menu Phiếu lương (MnuPRL445) trên Cổng thông tin nhân sự",
        "Bước 2: Ghi nhận thông tin kỳ hiển thị mặc định (Tháng 08/2026 - Công chuẩn: 23 ngày, Công thực tế: 23 ngày)",
        "Bước 3: Chuyển đổi dropdown Tháng/Năm sang Tháng 10/2026",
        "Bước 4: Kiểm tra dữ liệu phiếu lương nạp lại tức thì tương ứng với kỳ tháng 10",
        "Bước 5: Kiểm tra các khối: Thông tin lương, Thu nhập khác, Khấu trừ, Thuế TNCN, Thực lãnh"
      ],
      expected: "Giao diện chuyển đổi kỳ lương mượt mà, gọi Stored Procedure sp_PaySlipView nạp chính xác các chỉ tiêu tương ứng của nhân sự.",
      dbQuery: {
        "sql": "EXEC sp_PaySlipView @LoginID = 22, @Month = 8, @Year = 2026, @PeriodID = 0, @LanguageID = 'VN', @EmployeeID = '013'",
        "expectedResult": "Dataset 1 trả về đúng EmployeeID = '013', StandardWDays = 23, TotalPaidDays = 23, DependantNumber = 3"
      }
    }
  ],
  crudCases: [
    {
      id: "TC-CRUD-01",
      title: "Nghiệp vụ Tạo Đơn Xin Bù Công (Create Attendance Confirmation Request)",
      objective: "Nhân viên thực hiện gửi yêu cầu xác nhận công cho ngày quên quẹt thẻ vào cơ sở dữ liệu",
      precondition: "Tài khoản tai.dang (Pass: 123, Mã: 046) đăng nhập, có ngày làm việc 15/10/2026 bị thiếu dữ liệu quẹt thẻ",
      testData: "Tài khoản: tai.dang / 123 (Mã NV: 046), Ngày bù công: 15/10/2026, Ca: HC, In1: 08:00:00, Out1: 17:00:00, Lý do: 'Quên quẹt thẻ do đi công tác gặp khách hàng'",
      steps: [
        "Bước 1: Nhân viên đăng nhập vào hệ thống với Username: tai.dang / Password: 123",
        "Bước 2: Truy cập Cổng thông tin nhân sự > Xin bù công (MnuWPT017)",
        "Bước 3: Chọn ngày làm việc cần giải trình: 15/10/2026",
        "Bước 4: Nhập giờ vào 08:00:00 và giờ ra 17:00:00 theo đúng khung ca Hành chính (HC)",
        "Bước 5: Nhập lý do chi tiết và bấm nút 'Gửi đơn'",
        "Bước 6: Kiểm tra đơn hiển thị trong danh sách 'Lịch sử xin xác nhận công' với trạng thái 'Chờ duyệt'"
      ],
      expected: "Bản ghi được thêm mới vào bảng tblAttendanceConfirmRequest với Approve_Status = 0, sẵn sàng cho Quản lý phê duyệt.",
      dbQuery: {
        "sql": "SELECT COUNT(*) AS PendingRequests FROM tblAttendanceConfirmRequest WHERE EmployeeID = '046' AND AttDate = '2026-10-15' AND Approve_Status = 0",
        "expectedResult": "PendingRequests = 1 bản ghi"
      }
    },
    {
      id: "TC-CRUD-02",
      title: "Nghiệp vụ Quản Lý Phê Duyệt Đơn Bù Công (Approve Attendance Request)",
      objective: "Quản lý trực tiếp thẩm tra lý do và bấm Duyệt đơn xin xác nhận công của nhân viên cấp dưới",
      precondition: "Tài khoản Quản lý ThanhLong (Pass: 123, Mã: 011) hoặc cuong.vu (Pass: 123, Mã: 014) đăng nhập hệ thống",
      testData: "Quản lý: ThanhLong / 123 (hoặc cuong.vu / 123), Đơn của NV: 046 (Đặng Minh Tài), Ngày: 15/10/2026, Ý kiến duyệt: 'Đồng ý duyệt bù công đầy đủ'",
      steps: [
        "Bước 1: Quản lý đăng nhập vào hệ thống với Username: ThanhLong (hoặc cuong.vu) / Password: 123",
        "Bước 2: Mở menu Cổng thông tin nhân sự > Danh sách phê duyệt > Duyệt đơn xin xác nhận công (MnuWPT032)",
        "Bước 3: Tìm đến đơn của nhân viên Đặng Minh Tài ngày 15/10/2026",
        "Bước 4: Đối chiếu thời gian vào/ra đề xuất và lý do công tác",
        "Bước 5: Nhập ý kiến 'Đồng ý duyệt bù công đầy đủ' và nhấp nút 'Duyệt (Approve)'",
        "Bước 6: Kiểm tra đơn chuyển sang trạng thái 'Đã duyệt' và biến mất khỏi danh sách chờ duyệt"
      ],
      expected: "Cột Approve_Status trong bảng tblAttendanceConfirmRequest được cập nhật từ 0 thành 1, ghi nhận ApproverID.",
      dbQuery: {
        "sql": "SELECT IdentityID, EmployeeID, AttDate, ApproverID, Approve_Status, ApproverRemark FROM tblAttendanceConfirmRequest WHERE EmployeeID = '046' AND AttDate = '2026-10-15'",
        "expectedResult": "Approve_Status = 1, ApproverRemark = N'Đồng ý duyệt bù công đầy đủ'"
      }
    },
    {
      id: "TC-CRUD-03",
      title: "Nghiệp vụ Tổng Hợp Công Tháng & Khóa Kỳ Chấm Công (Process & Lock Attendance)",
      objective: "Chuyên viên Nhân sự chạy tổng hợp công tháng để kết nạp ngày bù công và thực hiện khóa kỳ công",
      precondition: "Tài khoản cuong.vu (Pass: 123) hoặc chien.nguyen (Pass: 123) đăng nhập với quyền Quản trị chấm công",
      testData: "Tài khoản quản trị: cuong.vu / 123, Kỳ công: Tháng 10/2026, Nhân sự đối soát: Đặng Minh Tài (Mã: 046)",
      steps: [
        "Bước 1: Mở Topbar Icon Đồng hồ > Quản lý chấm công > Tổng hợp công cả tháng (VT) (MnuTAD1000)",
        "Bước 2: Chọn Kỳ tháng 10/2026 và nhấp nút 'Xử lý tổng hợp công' (chạy sp_ProcessAttendanceSummaryMonthly)",
        "Bước 3: Xác nhận số ngày công thực tế của NV 046 đã được cộng thêm 1.0 công của ngày 15/10/2026",
        "Bước 4: Chuyển sang menu Quản lý chấm công > Mở/Khóa Công (MnuTAD125)",
        "Bước 5: Chọn Tháng 10/2026 và nhấp nút 'Khóa công'",
        "Bước 6: Kiểm tra cờ trạng thái khóa kỳ công chuyển sang Đã khóa"
      ],
      expected: "Bảng tổng hợp công tháng chốt đúng số công thực tế của nhân viên. CSDL cập nhật trạng thái khóa công trong tblSal_Lock.",
      dbQuery: {
        "sql": "SELECT Month, Year, isLock FROM tblSal_Lock WHERE Month = 10 AND Year = 2026",
        "expectedResult": "isLock = 1 (Kỳ chấm công đã được chốt và đóng băng an toàn)"
      }
    },
    {
      id: "TC-CRUD-04",
      title: "Nghiệp vụ Chạy Tính Lương Tự Động Toàn Công Ty (Execute SALCAL_MAIN)",
      objective: "Kế toán Lương thực thi quy trình tính lương tự động từ dữ liệu công đã khóa và hồ sơ lương",
      precondition: "Tài khoản có quyền Tính lương (cuong.vu / 123 hoặc chien.nguyen / 123) đăng nhập hệ thống",
      testData: "Tài khoản tính lương: cuong.vu / 123, Kỳ lương: Tháng 10/2026, Đối tượng kiểm chứng: Đặng Minh Tài (Mã: 046)",
      steps: [
        "Bước 1: Mở Topbar Icon Tiền > Tính lương > Xử lý tăng lương (Tính lương) (MnuPRL102)",
        "Bước 2: Chọn Kỳ lương: Tháng 10/2026, chọn phạm vi: Toàn công ty",
        "Bước 3: Nhấp nút 'Tính lương tự động' để kích hoạt Stored Procedure SALCAL_MAIN",
        "Bước 4: Chờ hệ thống thực thi thuật toán bóc tách công thời gian, phụ cấp, khấu trừ bảo hiểm và thuế TNCN",
        "Bước 5: Kiểm tra thông báo 'Tính lương hoàn tất thành công 100% nhân sự'"
      ],
      expected: "Hệ thống tính toán toàn bộ các bảng lương thành phần và tổng hợp vào bảng tblSal_Sal với đầy đủ TotalIncome, TotalDeduction, GrossTakeHome.",
      dbQuery: {
        "sql": "SELECT EmployeeID, Month, Year, TotalIncome, GrossTakeHome FROM tblSal_Sal WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026",
        "expectedResult": "Bản ghi lương tồn tại với GrossTakeHome > 0, phản ánh đầy đủ ngày công bù đã được tính tiền lương"
      }
    }
  ],
  downstreamMatrix: [
    {
      sourceAction: "Nhân viên gửi Đơn xin bù công tại 'MnuWPT017'",
      targetTable: "tblAttendanceConfirmRequest",
      readApis: "sp_AttendanceConfirmRequest_PendingApprove",
      targetScreens: "Cổng thông tin > Danh sách phê duyệt (MnuWPT032)",
      roles: "Quản lý (ThanhLong / cuong.vu)"
    },
    {
      sourceAction: "Quản lý Duyệt đơn xin bù công tại 'MnuWPT032'",
      targetTable: "tblAttendanceConfirmRequest (Approve_Status = 1)",
      readApis: "spDailyAttendanceData, spDailyAttendanceData_ReCalculate",
      targetScreens: "Quản lý chấm công > Xem dữ liệu chấm công hằng ngày (MnuHRS225)",
      roles: "Chuyên viên Nhân sự / C&B (cuong.vu)"
    },
    {
      sourceAction: "HR Tổng hợp công tháng tại 'MnuTAD1000' & Khóa công tại 'MnuTAD125'",
      targetTable: "tblSal_Lock (isLock = 1), tblSal_Sal_Detail",
      readApis: "SALCAL_MAIN, sp_PayrollMonthly",
      targetScreens: "Tính lương > Xử lý tăng lương (MnuPRL102), Lương nhân viên (MnuHRS145)",
      roles: "Kế toán Tiền lương / Admin (cuong.vu / chien.nguyen)"
    },
    {
      sourceAction: "Kế toán chạy Tính lương (SALCAL_MAIN) & Khóa bảng lương tại 'MnuPRL120'",
      targetTable: "tblSal_Sal, tblSal_Lock (isLockSalary = 1)",
      readApis: "sp_PaySlipView, sp_CompanySalarySummary, sp_EmailPayslipApprovalList",
      targetScreens: "Cổng thông tin > Phiếu lương (MnuPRL445), Danh sách trả lương (MnuPRL092)",
      roles: "Nhân viên (tai.dang / ly.tran), Ban Giám đốc (chien.nguyen)"
    }
  ],
  flowCases: [
    {
      id: "TC-FLOW-01",
      title: "LUỒNG KIỂM THỬ KHÉP KÍN E2E: TỪ XIN BÙ CÔNG ĐẾN TỔNG HỢP CÔNG, TÍNH LƯƠNG VÀ HIỂN THỊ PHIẾU LƯƠNG",
      objective: "Kiểm chứng tính toàn vẹn và sự lan truyền dữ liệu thông suốt qua các Role và Màn hình thực tế: Nhân viên làm đơn bù công -> Quản lý duyệt -> HR tổng hợp công & khóa kỳ -> Kế toán tính lương -> Nhân viên mở Phiếu lương nghiệm thu thực lãnh",
      precondition: "Nhân viên tai.dang (Pass: 123, Mã: 046) có ngày làm việc 15/10/2026 chưa có công; Các tài khoản quản lý và kế toán đã sẵn sàng",
      testData: "Nhân viên: tai.dang (Pass: 123, Mã: 046), Quản lý: ThanhLong (Pass: 123, Mã: 011), Quản trị HR/Lương: cuong.vu (Pass: 123, Mã: 014), Admin: chien.nguyen (Pass: 123, Mã: 013), Ngày bù công: 15/10/2026 (08:00 - 17:00, Ca HC)",
      steps: [
        "Bước 1 (Role: Nhân viên - tai.dang / 123): Đăng nhập, vào 'Cổng thông tin nhân sự > Xin bù công' (MnuWPT017), tạo đơn xin bù công ngày 15/10/2026 (In: 08:00, Out: 17:00, Ca: HC, Lý do: Quên quẹt thẻ do đi công tác), bấm 'Gửi đơn'",
        "Bước 2 (Role: Quản lý - ThanhLong / 123 hoặc cuong.vu / 123): Đăng nhập tài khoản Quản lý, vào 'Cổng thông tin > Danh sách phê duyệt > Duyệt đơn xin xác nhận công' (MnuWPT032), kiểm tra đơn của Đặng Minh Tài và bấm nút 'Duyệt (Approve)'",
        "Bước 3 (Role: Quản trị HR - cuong.vu / 123): Đăng nhập, vào 'Quản lý chấm công > Xem dữ liệu chấm công hằng ngày' (MnuHRS225), kiểm tra ngày 15/10 của NV 046 đã được ghi nhận đủ giờ In/Out và đủ 1 công",
        "Bước 4 (Role: Quản trị HR - cuong.vu / 123): Vào 'Quản lý chấm công > Tổng hợp công cả tháng (VT)' (MnuTAD1000), bấm 'Xử lý tổng hợp công' để kết nạp ngày bù công vào tổng công tháng. Sau đó sang menu 'Mở/Khóa Công' (MnuTAD125) bấm 'Khóa công'",
        "Bước 5 (Role: Kế toán Lương - cuong.vu / 123 hoặc chien.nguyen / 123): Vào 'Tính lương > Xử lý tăng lương (Tính lương)' (MnuPRL102), chọn Tháng 10/2026 và bấm 'Tính lương tự động' (chạy SALCAL_MAIN)",
        "Bước 6 (Role: Ban Giám đốc / Admin - chien.nguyen / 123): Vào 'Tính lương > Khóa bảng lương' (MnuPRL120) kiểm tra tổng quỹ lương và bấm 'Khóa bảng lương'. Sau đó bấm phát hành phiếu lương",
        "Bước 7 (Role: Nhân viên - tai.dang / 123): Nhân viên đăng nhập lại Portal, mở menu 'Phiếu lương' (MnuPRL445), chọn Tháng 10/2026 và kiểm tra:",
        "       - Mục I (Thông tin lương): Công thực tế đã bao gồm đủ ngày bù công 15/10/2026; Tiền lương ngày công được tính đủ.",
        "       - Mục II, III, IV: Các khoản phụ cấp, giảm trừ bảo hiểm 10.5%, giảm trừ gia cảnh thuế TNCN hiển thị chuẩn xác.",
        "       - Mục V (Thực lãnh): Số tiền thực lãnh phản ánh đúng công sức làm việc, không bị trừ lương do lỗi thiếu công."
      ],
      expected: "Toàn bộ chu trình từ xin bù công, phê duyệt, chốt công tháng đến chạy tính lương và phát hành phiếu lương hoạt động trơn tru 100%, dữ liệu đối soát CSDL đồng nhất tuyệt đối qua từng khâu.",
      downstream: {
        targetMenu: "Phiếu lương nhân viên (MnuPRL445 - sp_salaryslip_html)",
        role: "Nhân viên (tai.dang - Pass: 123)",
        verification: "Phiếu lương Tháng 10/2026 ghi nhận đầy đủ Công thực tế, Lương ngày công và Thực lãnh không bị trừ vắng."
      },
      dbQuery: {
        "sql": "SELECT sal.EmployeeID, sal.Month, sal.Year, dt.StandardWDays, dt.DaysOfSalEntry, sal.TotalIncome, sal.GrossTakeHome FROM tblSal_Sal sal INNER JOIN tblSal_Sal_Detail dt ON sal.EmployeeID = dt.EmployeeID AND sal.Month = dt.Month AND sal.Year = dt.Year WHERE sal.EmployeeID = '046' AND sal.Month = 10 AND sal.Year = 2026",
        "expectedResult": "DaysOfSalEntry đã tính đủ ngày bù công được duyệt, GrossTakeHome khớp 100% với hiển thị trên giao diện Phiếu lương."
      }
    }
  ]
};

const outputPath = path.join(__dirname, 'temp_payroll_flow_spec.json');
fs.writeFileSync(outputPath, JSON.stringify(specData, null, 2), 'utf8');
console.log('Successfully updated spec JSON with exact user accounts to:', outputPath);
