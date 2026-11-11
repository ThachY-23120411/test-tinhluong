const fs = require('fs');
const path = require('path');

const specData = {
  systemName: "Paradise HRM / CRM",
  pageName: "Báo Cáo Doanh Số (MnuKPI447)",
  menuUrl: "https://paradisehrm.com/Tai3/# (Menu Doanh số)",
  createdDate: "28/10/2026",
  inventory: [
    {
      name: "Cụm nút chuyển kỳ thời gian (Pills)",
      group: "Toolbar Filter",
      selector: ".ttv-pill (Tuần, Tháng, Quý, Năm)",
      action: "Chuyển nhanh chu kỳ thống kê doanh số theo tuần, tháng, quý hoặc cả năm"
    },
    {
      name: "Dropdown chọn Năm",
      group: "Toolbar Filter",
      selector: "#filter-year",
      action: "Lọc doanh thu theo năm tài chính cụ thể (2024, 2025, 2026...)"
    },
    {
      name: "Dropdown chọn Tháng",
      group: "Toolbar Filter",
      selector: "#filter-month",
      action: "Lọc doanh thu chi tiết từ tháng 1 đến tháng 12"
    },
    {
      name: "Dropdown chọn Quý",
      group: "Toolbar Filter",
      selector: "#filter-quarter",
      action: "Lọc doanh thu theo Quý 1, Quý 2, Quý 3, Quý 4 khi ở chế độ Quý"
    },
    {
      name: "Dropdown chọn Tuần",
      group: "Toolbar Filter",
      selector: "#filter-week",
      action: "Lọc doanh thu theo từng tuần trong tháng khi ở chế độ Tuần"
    },
    {
      name: "DateBox Từ ngày - Đến ngày",
      group: "Toolbar Filter",
      selector: "#filter-date-from, #filter-date-to",
      action: "Xem khoảng ngày áp dụng thực tế và hỗ trợ chọn khoảng ngày tùy chỉnh"
    },
    {
      name: "Nút Tải lại dữ liệu",
      group: "Toolbar Action",
      selector: "#btn-reload-main",
      action: "Gửi yêu cầu API tái nạp tức thì dữ liệu doanh số từ CSDL"
    },
    {
      name: "Cụm 6 thẻ Metric KPI Danh sách",
      group: "Summary Cards",
      selector: "#sum-total-revenue, #sum-total-unpaid, #sum-total-paid, #sum-finalized-revenue, #sum-total-commission, #sum-total-contracts",
      action: "Hiển thị tổng doanh số, nợ, thanh toán, đã chốt, hoa hồng và tổng hợp đồng của toàn công ty"
    },
    {
      name: "Bảng danh sách doanh số nhân viên",
      group: "Data List",
      selector: "#crm-body-list, .ttv-grid-row",
      action: "Hiển thị chi tiết từng nhân sự kinh doanh và nhấp dòng để mở dashboard chi tiết"
    },
    {
      name: "Nút Quay lại danh sách",
      group: "Detail Navigation",
      selector: "#btn-back-detail-new",
      action: "Đóng màn hình dashboard chi tiết của nhân viên và quay về danh sách tổng hợp"
    },
    {
      name: "Nút Xuất báo cáo PDF",
      group: "Detail Action",
      selector: "#btn-export-pdf",
      action: "Kích hoạt tiến trình tạo và tải về báo cáo doanh thu PDF chuyên nghiệp"
    },
    {
      name: "Biểu đồ đường Biến động doanh thu",
      group: "Visual Chart",
      selector: "#chart-revenue-trend",
      action: "Trực quan hóa xu hướng tăng trưởng doanh thu theo từng mốc thời gian"
    },
    {
      name: "Biểu đồ tròn Cơ cấu thanh toán (Donut)",
      group: "Visual Chart",
      selector: "#chart-payment-donut, #chart-percent",
      action: "Trực quan hóa tỷ lệ thu hồi công nợ và cơ cấu thanh toán của nhân sự"
    },
    {
      name: "Khối phân tích sâu theo loại hợp đồng",
      group: "Detail Breakdown",
      selector: "#dash-contract-type-list",
      action: "Thống kê chi tiết số lượng và giá trị phân bổ theo từng loại hợp đồng"
    }
  ],
  controlCases: [
    {
      id: "TC-CTL-01",
      title: "Kiểm tra Khởi động, Tải Màn hình Doanh số & Xác thực 6 Thẻ Metric KPI Tổng quan",
      objective: "Thẩm định khả năng nạp đúng phân hệ Doanh số và tính toàn vẹn của các thẻ chỉ số KPI tổng hợp",
      precondition: "Tài khoản đăng nhập Chien.nguyen (Mã 013 / LoginID: 22) có quyền truy cập CRM",
      testData: "Kỳ báo cáo mặc định: Tháng 10/2026",
      steps: [
        "Bước 1: Điều hướng vào phân hệ Trang chủ CRM -> nhấp chọn menu 'Doanh số'",
        "Bước 2: Xác nhận tab Doanh số (#dynamic-tab-MnuKPI447) chuyển sang trạng thái active",
        "Bước 3: Rà soát hiển thị thanh công cụ bộ lọc: cụm nút .ttv-pill, #filter-year, #filter-month",
        "Bước 4: Thẩm định 6 thẻ Metric KPI tổng quan (#sum-total-revenue, #sum-total-unpaid, #sum-total-paid, #sum-finalized-revenue, #sum-total-commission, #sum-total-contracts)",
        "Bước 5: Kiểm tra danh sách nhân sự kinh doanh (#crm-body-list) nạp đầy đủ N0 = 7 nhân viên"
      ],
      expected: "Màn hình nạp hoàn chỉnh không lỗi console, 6 thẻ KPI hiển thị số liệu đồng bộ từ CSDL, bảng danh sách hiển thị đúng 7 nhân sự kinh doanh trong tháng 10/2026.",
      dbQuery: {
        sql: "EXEC [dbo].[sp_getSumContractInCRM] @FilterType = 'month', @FilterYear = 2026, @FilterMonth = 10, @LoginID = 22",
        expectedResult: "Trả về danh sách 7 nhân sự: ĐẶNG THỊ NHUNG (070), LÊ TRẦN HOÀNG NAM (052), NGUYỄN TẤN CHIẾN (013), NGUYỄN THỊ THANH TÂM (054), NGUYỄN TỪ ÁNH TUYẾT (063), TRẦN KHÁNH LY (034), VŨ ĐÌNH CƯỜNG (014)."
      }
    },
    {
      id: "TC-CTL-02",
      title: "Kiểm tra Vòng đời 3 Pha Cụm Nút Lọc Kỳ Doanh số (.ttv-pill: Tuần, Tháng, Quý, Năm)",
      objective: "Thẩm định khả năng phân tích dữ liệu đa chu kỳ và khôi phục toàn vẹn dữ liệu khi chuyển đổi kỳ thống kê",
      precondition: "Bảng danh sách đang ở mốc Tháng 10/2026 với N0 = 7 nhân sự ban đầu",
      testData: "Chuyển đổi chu kỳ: 'Tháng' -> 'Năm' -> 'Quý' -> Khôi phục 'Tháng'",
      steps: [
        "Bước 1 (Pha 1 - Baseline): Ghi nhận số lượng nhân viên ở kỳ mặc định Tháng 10/2026 là N0 = 7 nhân sự",
        "Bước 2 (Pha 2 - Filter Action): Di chuột Neon nhấp chọn pill 'Năm' (button.ttv-pill:has-text('Năm'))",
        "Bước 3: Bắt gói API sp_getSumContractInCRM phản hồi HTTP 200, kiểm tra danh sách mở rộng lên đúng 9 nhân sự lũy kế cả năm 2026",
        "Bước 4: Di chuột Neon nhấp chọn pill 'Quý' (button.ttv-pill:has-text('Quý')), kiểm tra dropdown Quý 4 xuất hiện",
        "Bước 5 (Pha 3 - Reset & Restore): Nhấp lại pill 'Tháng', xác nhận hệ thống khôi phục trọn vẹn N_restored = 7 nhân sự ban đầu"
      ],
      expected: "Khi lọc 'Năm': hiển thị đúng 9 nhân sự (khớp 100% CSDL). Khi chuyển lại 'Tháng': khôi phục chính xác 7 nhân sự ban đầu.",
      dbQuery: {
        sql: "EXEC [dbo].[sp_getSumContractInCRM] @FilterType = 'year', @FilterYear = 2026, @LoginID = 22;\nEXEC [dbo].[sp_getSumContractInCRM] @FilterType = 'month', @FilterYear = 2026, @FilterMonth = 10, @LoginID = 22;",
        expectedResult: "Kỳ Năm: 9 nhân sự (bổ sung thêm Đào Tố Uyên và Lê Thị Kim Thủy). Kỳ Tháng: 7 nhân sự."
      }
    },
    {
      id: "TC-CTL-03",
      title: "Kiểm tra Dropdown Chọn Năm (#filter-year) & Tháng (#filter-month) Kết Hợp Nút Tải Lại (#btn-reload-main)",
      objective: "Thẩm định tính năng chọn mốc thời gian tùy biến và kích hoạt tái nạp số liệu từ máy chủ",
      precondition: "Đang ở chế độ xem Tháng trên thanh Toolbar",
      testData: "Năm mục tiêu: 2025, Tháng mục tiêu: 12 -> Khôi phục Năm 2026, Tháng 10",
      steps: [
        "Bước 1: Xác định dropdown #filter-year (giá trị hiện tại: 2026) và #filter-month (giá trị hiện tại: 10)",
        "Bước 2: Di chuột Neon chọn #filter-year sang giá trị '2025' và #filter-month sang '12'",
        "Bước 3: Di chuột Neon di chuyển vào tâm nút 'Tải lại dữ liệu' (#btn-reload-main) và nhấp chuột",
        "Bước 4: Bắt phản hồi API sp_getSumContractInCRM với tham số FilterYear=2025, FilterMonth=12 thành công",
        "Bước 5: Khôi phục lại Năm 2026 và Tháng 10, bấm nút #btn-reload-main để hoàn tất vòng đời"
      ],
      expected: "Hệ thống tiếp nhận chính xác tham số Năm và Tháng, gọi API tương ứng tải lại toàn bộ 6 thẻ KPI và bảng số liệu mượt mà.",
      dbQuery: {
        sql: "EXEC [dbo].[sp_getSumContractInCRM] @FilterType = 'month', @FilterYear = 2025, @FilterMonth = 12, @LoginID = 22",
        expectedResult: "API phản hồi HTTP 200, dữ liệu trả về khớp với báo cáo lịch sử tháng 12/2025."
      }
    }
  ],
  crudCases: [
    {
      id: "TC-BIZ-01",
      title: "Nghiệp vụ Mở Dashboard Chi tiết Doanh thu Nhân viên (showDetail) & Rà soát Biểu đồ Trực quan",
      objective: "Thẩm định luồng nghiệp vụ xem báo cáo phân tích sâu của từng chuyên viên kinh doanh cụ thể",
      precondition: "Bảng danh sách #crm-body-list đang hiển thị đầy đủ nhân sự kinh doanh",
      testData: "Nhân sự chọn xem chi tiết: 'NGUYỄN TẤN CHIẾN' (Mã: 013, có 28 hợp đồng lũy kế)",
      steps: [
        "Bước 1: Xác định dòng thông tin nhân viên 'NGUYỄN TẤN CHIẾN' trên bảng danh sách",
        "Bước 2: Di chuột Neon nhấp chọn vào dòng nhân sự để kích hoạt hàm showDetail",
        "Bước 3: Xác nhận màn hình danh sách #crm-list-view được ẩn đi và Dashboard chi tiết #crm-dash-view hiển thị",
        "Bước 4: Kiểm tra tiêu đề #dash-emp-name hiển thị đúng 'NGUYỄN TẤN CHIẾN', rà soát biểu đồ xu hướng #chart-revenue-trend và biểu đồ Donut #chart-payment-donut",
        "Bước 5: Di chuột Neon nhấp nút 'Quay lại' (#btn-back-detail-new), xác nhận hệ thống đóng dashboard chi tiết và hiển thị lại danh sách #crm-list-view nguyên vẹn"
      ],
      expected: "Dashboard chi tiết của nhân viên nạp đầy đủ số liệu KPI cá nhân, hai biểu đồ trực quan render chính xác. Nút quay lại hoạt động mượt mà, trả về danh sách ban đầu.",
      dbQuery: {
        sql: "SELECT COUNT(*) AS AssignedContracts, SUM(Cost) AS TotalVal FROM tblCRM_Contract c INNER JOIN tblCRM_CompanyInfo comp ON c.CustomerID = comp.CRM_CustomerID WHERE comp.EmployeeIDs LIKE '%013%'",
        expectedResult: "Số liệu hợp đồng khớp với tổng kết hiển thị trên Dashboard chi tiết của Nguyễn Tấn Chiến."
      }
    },
    {
      id: "TC-BIZ-02",
      title: "Nghiệp vụ Xuất Báo cáo Doanh số PDF (#btn-export-pdf) & Kiểm tra Trạng thái Tiến trình",
      objective: "Thẩm định tính năng xuất báo cáo chuyên nghiệp cho cấp quản lý và trạng thái loading trực quan",
      precondition: "Đang mở Dashboard chi tiết doanh thu nhân viên (#crm-dash-view)",
      testData: "Hành động: Nhấp nút Xuất PDF (#btn-export-pdf)",
      steps: [
        "Bước 1: Xác định vị trí nút 'Xuất PDF' (#btn-export-pdf) trên thanh điều khiển chi tiết",
        "Bước 2: Di chuột Neon vào tâm nút #btn-export-pdf",
        "Bước 3: Nhấp nút Xuất PDF, kiểm tra thẻ thông báo tiến trình #pdf-loading hiển thị ('Đang tạo thông tin PDF... Vui lòng không đóng trình duyệt')",
        "Bước 4: Kiểm tra trình duyệt kích hoạt hàm xuất bản hoặc hộp thoại in tài liệu mà không làm treo giao diện",
        "Bước 5: Xác nhận sau khi hoàn tất, giao diện trở lại trạng thái sẵn sàng bình thường"
      ],
      expected: "Hệ thống kích hoạt tiến trình tạo báo cáo PDF an toàn, hiển thị loading trực quan, không gây vỡ DOM hay phát sinh lỗi JavaScript console.",
      dbQuery: {
        sql: "SELECT TableName, ScreenType FROM tblHtmlScriptCache WHERE TableName = 'sp_CRM_SaleInCRM'",
        expectedResult: "Mã nguồn template in ấn PDF tích hợp đầy đủ trong cấu hình cache hệ thống."
      }
    }
  ],
  downstreamMatrix: [
    {
      sourceAction: "Khách hàng thanh toán hợp đồng dịch vụ tại 'Theo dõi dịch vụ' / 'Thanh toán công nợ'",
      targetTable: "tblCRM_ContractPayment, tblCRM_Contract",
      readApis: "sp_getSumContractInCRM, sp_CRM_CustomerDetail",
      targetScreens: "Báo cáo Doanh số (MnuKPI447), Theo dõi dịch vụ (MnuKPI012), Tổng quan CRM (MnuKPI001)",
      roles: "Admin (Chien.nguyen), Kế toán công nợ, Trưởng phòng Kinh doanh"
    },
    {
      sourceAction: "Chốt doanh số hợp đồng kinh doanh (IsSalesFinalized = 1)",
      targetTable: "tblCRM_ContractPayment",
      readApis: "sp_getSumContractInCRM",
      targetScreens: "Thẻ 'ĐÃ CHỐT' (#sum-finalized-revenue) trên Báo cáo Doanh số",
      roles: "Ban Giám đốc, Kế toán trưởng, Quản trị viên hệ thống"
    }
  ],
  flowCases: [
    {
      id: "TC-FLOW-01",
      title: "Quy trình Đối soát Liên màn hình: DỮ LIỆU THANH TOÁN HỢP ĐỒNG ĐỒNG BỘ TỨC THÌ LÊN BÁO CÁO DOANH SỐ",
      objective: "Kiểm chứng tính nhất quán giữa dữ liệu hợp đồng thanh toán thực tế trong CSDL và số liệu tổng hợp trên Dashboard Doanh số",
      precondition: "Tài khoản có quyền xem dữ liệu hợp đồng và báo cáo doanh thu toàn hệ thống",
      testData: "Bảng đối soát: tblCRM_ContractPayment và tblCRM_Contract",
      steps: [
        "Bước 1: Truy vấn CSDL xác định tổng số lượng hợp đồng đã chốt (IsClosed = 1) và thanh toán hoàn tất",
        "Bước 2: Mở menu 'Doanh số' (MnuKPI447) trên web, chọn kỳ báo cáo 'Năm' (2026)",
        "Bước 3: Đối chiếu tổng số hợp đồng trên thẻ 'TỔNG HỢP ĐỒNG' (#sum-total-contracts) với CSDL",
        "Bước 4: Đối chiếu phân bổ hợp đồng theo từng nhân viên (Nguyễn Tấn Chiến, Trần Khánh Ly) trên bảng danh sách",
        "Bước 5: Xác nhận số liệu trên giao diện web phản ánh chính xác 100% dữ liệu kế toán trong CSDL"
      ],
      expected: "Số liệu doanh thu, số dư nợ và số lượng hợp đồng hiển thị trên Dashboard Doanh số khớp 100% với kết quả truy vấn đối soát từ CSDL quan hệ.",
      downstream: {
        targetMenu: "Theo dõi dịch vụ (MnuKPI012) & Báo cáo Doanh số (MnuKPI447)",
        role: "Admin / Giám đốc kinh doanh",
        verification: "Số lượng và giá trị hợp đồng đồng bộ tức thì trên cả 2 màn hình."
      },
      dbQuery: {
        sql: "SELECT COUNT(*) AS TotalContracts, COUNT(CASE WHEN IsClosed = 1 THEN 1 END) AS ClosedContracts FROM tblCRM_Contract;\nSELECT COUNT(*) AS TotalPayments, COUNT(CASE WHEN IsSalesFinalized = 1 THEN 1 END) AS FinalizedPayments FROM tblCRM_ContractPayment;",
        expectedResult: "Hệ thống ghi nhận 182 hợp đồng (33 hợp đồng đã hoàn tất chốt) và 110 lượt thanh toán hợp đồng."
      }
    }
  ]
};

const outDir = path.resolve(__dirname, '../docs/test-specs');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

const jsonPath = path.join(outDir, 'temp_doanh_so_spec.json');
fs.writeFileSync(jsonPath, JSON.stringify(specData, null, 2), 'utf8');
console.log('Saved temp_doanh_so_spec.json');
