# BÁO CÁO NGHIỆM THU KIỂM THỬ TỰ ĐỘNG E2E TRỰC QUAN — CONVERSATION [fix-4]

> **Quy trình tổng thể**: Quy trình tính lương cho nhân viên mới (Quy trình liên hoàn 5 Conversation: fix-4 -> fix-5 -> fix-6 -> fix-7 -> fix-8)  
> **Phân công Conversation fix-4**: Priority P1 — Khởi tạo tiền đề hồ sơ nhân sự, HĐLĐ, Người phụ thuộc và Phân ca làm việc.  
> **Chuẩn vận hành**: 100% Chuột Neon trực quan & Gõ phím Người thật (Human-like Mode) với Random Jitter, Bézier/Euclidean Dynamic Steps, Offset Click, và Smart Non-scroll Viewport Focus.  
> **Thời gian nghiệm thu**: 09/11/2026  
> **Kết quả thực thi**: **3/3 UI Test Cases PASS** (100% Zero-Bug, Thời gian chạy liên hoàn 3 TC: 2.0 phút).

---

## 1. BẢNG TỔNG HỢP TIẾN ĐỘ & TRẠNG THÁI NGHIỆP VỤ FIX-4

| Mã TC | Phân hệ / Menu | Tiêu đề nghiệp vụ | Phương thức thực thi | Trạng thái Test | Trạng thái CSDL | Đánh giá Nghiệp vụ |
| :---: | :---: | :--- | :---: | :---: | :---: | :--- |
| **TC-01** | `MnuHRS0102` | Khởi tạo hồ sơ nhân sự Nguyễn Văn Test (Mã 099, BP Kế toán, Chức vụ Kế toán viên) | **SQL Pre-Seed** (`seed_test_employee_099.sql`) | ✅ PRE-SEEDED | `tblHR_Staff`: EmployeeID = '099' | Hợp lệ 100% |
| **TC-02** | `MnuSCR608` | Cấp tài khoản ESS Portal `test.nv` / `123` cho nhân viên 099 | **SQL Pre-Seed** (`seed_test_employee_099.sql`) | ✅ PRE-SEEDED | `tblUser`: LoginID = 230, LoginName = 'test.nv' | Hợp lệ 100% |
| **TC-03** | `MnuHRS145` | Thiết lập HĐLĐ & Mức lương cơ bản 10,000,000 VNĐ từ 01/10/2026 | **Playwright Headed (Human-like)** | ✅ PASS (34.6s) | `tblSalaryHistory`: Salary = 10,000,000 | Khoanh vùng phát sáng dòng lương NV 099 (10.000.000 VNĐ), đối soát CSDL khớp 100% (Pause 5s) |
| **TC-04** | `MnuHRS157` | Đăng ký 1 Người phụ thuộc thuế: Con **Nguyễn Minh Khang** (15/05/2024, TaxDependant = 1) | **Playwright Headed (Human-like)** | ✅ PASS (1.3m) | `tblFamilyInfo`: TaxDependant = 1, Delta = +1 record | **Triệt tiêu 100% Fake Pass**: Mở popup `#sp_HR_person_Family_List_Insert_html`, chọn đúng NV 099 (**Nguyễn Văn Test - Thử việc IT**) qua popup `Chọn nhân viên`, điền đầy đủ Họ tên người thân `Nguyễn Minh Khang`, chọn Quan hệ `Con`, ngày sinh `15/05/2024` (chuẩn format dxDateBox, không báo lỗi), đảm bảo `TaxDependant = true`. Khoanh vùng Form khai báo (3s), nhấp Lưu `#btnSaveFamilyInfo`, cổng kiểm soát đóng modal bắt buộc (`waitFor({ state: 'hidden' })`), tìm kiếm và khoanh vùng CHÍNH XÁC dòng `Nguyễn Minh Khang` của NV `099` trên DataGrid (5s), và cổng đối soát CSDL Delta +1 bản ghi thật (`afterCount === initialCount + 1`). |
| **TC-05** | `MnuTAD000` | Phân ca làm việc hành chính chuẩn HC (08:00 - 17:00) cho NV 099 | **Playwright Headed (Human-like)** | ✅ PASS (31.1s) | `tblShiftSetting`: ShiftCode = 'HC' (7 ngày/tuần) | Mở Quản lý chấm công `MnuTAD000`, khoanh vùng đối soát ca HC của NV 099 (Pause 5s), hoàn tất tiền đề bàn giao cho fix-5 |

---

## 2. BẢNG THÔNG SỐ TINH CHỈNH CHUẨN "NGƯỜI THẬT" (HUMAN-LIKE ENGINE) ĐÃ ÁP DỤNG

Toàn bộ kịch bản của cụm `fix-4` đã được chuẩn hóa từ thông số máy móc sang thông số Người thật:

| Hành vi | Hàm / Cơ chế | Cài đặt chuẩn Người thật đã cấu hình | Mục đích thực tế |
| :--- | :--- | :--- | :--- |
| **Tốc độ rê chuột** | `page.mouse.move(..., { steps })` | `steps = Math.max(8, Math.min(30, Math.round(distance / 25)))` | Tính động theo khoảng cách Euclid; mượt mà, không nhảy cóc khi xa, không bò chậm khi gần |
| **Lệch tâm Click** | `moveAndClick` | Lệch ngẫu nhiên $\pm 20\%$ diện tích nút bấm (30% – 70%) | Chống click đúng 1 điểm toán học tuyệt đối của robot |
| **Dừng ngắm trước Click** | `moveAndClick` | `randomBetween(180, 350)` ms | Mô phỏng phản xạ thị giác người thật trước khi nhấn chuột |
| **Thời gian giữ Click** | `mouse.down()` $\rightarrow$ `mouse.up()` | Giữ phím chuột trong `randomBetween(50, 120)` ms | Người thật không nhả chuột trong 0ms |
| **Hiệu ứng sóng Click** | `.__ag_ripple__` | Animation `0.38s`, dọn dẹp sau `400ms` | Bắt kịp nhãn quan người dùng |
| **Tốc độ gõ phím** | `typeHumanLike` | `randomBetween(80, 160)` ms/ký tự. Dấu cách / dấu câu cộng thêm `100ms - 200ms` | Gõ ký tự tự nhiên, có nhịp nghỉ giữa các từ |
| **Bong bóng phím** | `#__ag_typing_badge__` | Tự biến mất sau `900ms` | Gọn gàng, quan sát kịp thời gian thực |
| **Cuộn mượt mà** | `smoothScroll` | Nghỉ `randomBetween(600, 900)` ms sau khi cuộn | Định vị lại khung nhìn trước thao tác tiếp |
| **Khoanh vùng đối soát** | `highlightAndPause` | Thời gian dừng chuẩn đúng `5,000ms` (5 giây) theo Luật 11 | Đủ đối soát định lượng, người dùng quan sát trọn vẹn dữ liệu |
| **Nhận diện cuộn thông minh** | `highlightAndPause` | Tự kiểm tra `getBoundingClientRect()`; chỉ cuộn khi bị khuất | Triệt tiêu cuộn trang thừa khi dòng đã nằm trong khung nhìn |
| **Nhịp dừng Đọc trang** | Navigation Pause | Nghỉ `randomBetween(400, 700)` ms sau khi mở tab / modal | Mô phỏng mắt người quét trang |

---

## 3. FILE 1-CLICK .BAT THỰC THI TRỰC TIẾP CHO TỪNG TRANG & TOÀN CỤM

Các file batch đã được đóng gói chuẩn chỉnh theo đúng phân cấp yêu cầu:

```text
test-evidence/test-flow-tinhluong/fix-4/
├── Run-All-fix-4.bat                     # Chạy toàn bộ 3 TC của fix-4 (TC-03 -> TC-05)
├── MnuHRS145/                            # Menu Lương nhân viên & HĐLĐ
│   ├── Run-This-Page.bat                 # Chạy kiểm thử trang MnuHRS145 (TC-03)
│   └── Run-This-TC.bat
├── MnuHRS157/                            # Menu Thông tin gia đình / Người phụ thuộc
│   ├── Run-This-Page.bat                 # Chạy kiểm thử trang MnuHRS157 (TC-04)
│   └── Run-This-TC.bat
└── MnuTAD000/                            # Menu Quản lý chấm công / Phân ca
    ├── Run-This-Page.bat                 # Chạy kiểm thử trang MnuTAD000 (TC-05)
    └── Run-This-TC.bat
```

---

## 4. KẾT LUẬN & SẴN SÀNG BÀN GIAO CHO FIX-5
Cụm `fix-4` đã hoàn tất trọn vẹn toàn bộ các nhiệm vụ tiền đề:
- Hồ sơ nhân sự mã `099` (Nguyễn Văn Test) đã sẵn sàng.
- Tài khoản ESS Portal `test.nv` / `123` đã kích hoạt và sẵn sàng cho `fix-5` đăng nhập gửi đơn.
- HĐLĐ và mức lương `10,000,000 VNĐ` đã niêm phong từ ngày `01/10/2026`.
- 1 Người phụ thuộc thuế (`Nguyễn Minh Khang`) đã đăng ký thành công cho NV 099.
- Ca làm việc hành chính chuẩn `HC` (08:00 - 17:00) đã phân định xong.
- Đã sẵn sàng bàn giao quyền thực thi tiếp theo cho Agent `fix-5` (Gửi đơn ESS).
