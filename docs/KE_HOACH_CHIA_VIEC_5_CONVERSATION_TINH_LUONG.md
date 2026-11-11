# KẾ HOẠCH ĐIỀU PHỐI & PHÂN CHIA TEST CASE CHO 5 CONVERSATION
## DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
### Môi trường thực nghiệm: `https://paradisehrm.com/Tai3/#` | CSDL: `Vietinsoft_ForTest_Tai2` (READ-ONLY)

> **VAI TRÒ ĐIỀU PHỐI (PM / LEAD)**: Antigravity Master Coordinator  
> **DANH SÁCH 5 CONVERSATION THAM GIA**: `fix-4`, `fix-5`, `fix-6`, `fix-7`, `fix-8`  
> **FILE TEST TẬP TRUNG DUY NHẤT**: `tests/quy_trinh_tinh_luong_nv_moi.spec.js`  
> **THƯ MỤC KỊCH BẢN CHI TIẾT**: `kichbantest/<tên_conversation>/TC-XX.md`  
> **QUY CHUẨN ĐỒNG THỜI**: Tuân thủ nghiêm ngặt **Điều 6 AGENTS.md** (Vùng cách ly Test Case - Không giẫm chân nhau).

---

## 🏗️ 1. CẤU TRÚC TỔ CHỨC THƯ MỤC & FILE TOÀN DỰ ÁN

Hệ thống được tổ chức phân cấp, chuyên nghiệp và tách bạch rõ ràng giữa **Tài liệu kịch bản đặc tả**, **Mã nguồn kiểm thử tự động**, **Hàm bổ trợ (Helpers)** và **Thư mục minh chứng (Test Evidence)**:

```text
paradiseHR/
├── AGENTS.md                                    # Quy chuẩn làm việc bất biến & Điều 6 (Quy tắc cách ly Multi-Agent)
├── docs/                                        # Hồ sơ tài liệu điều phối & kiểm thử
│   ├── KE_HOACH_CHIA_VIEC_5_CONVERSATION_TINH_LUONG.md  # [FILE NÀY] Bản kế hoạch tổng thể & Prompt cho 5 Agent
│   ├── KICH_BAN_KIEM_THU_THU_CONG_NHAN_VIEN_MOI.md      # Runbook kịch bản kiểm thử thủ công (Dành cho Dev/Lead test tay)
│   └── HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md    # Cẩm nang 30 câu hỏi nghiệp vụ & kiến trúc Paradise HRM
│
├── kichbantest/                                 # THƯ MỤC KỊCH BẢN ĐẶC TẢ CHI TIẾT THEO TỪNG AGENT
│   ├── fix-4/                                   # [Priority P1] Giai đoạn Thiết lập HĐLĐ, Người phụ thuộc & Phân ca
│   │   ├── TC-01.md                             # [SQL Pre-seed] Hồ sơ NV 099 (Đã nạp thẳng vào DB qua seed_test_employee_099.sql)
│   │   ├── TC-02.md                             # [SQL Pre-seed] Cấp user test.nv (Đã nạp thẳng vào DB qua seed_test_employee_099.sql)
│   │   ├── TC-03.md                             # [MnuHRS145]  Thiết lập HĐLĐ chính thức & Lương cơ bản 10,000,000 đ
│   │   ├── TC-04.md                             # [MnuHRS157]  Khai báo 1 Người phụ thuộc thuế (Nguyễn Minh Khang)
│   │   └── TC-05.md                             # [MnuTAD020]  Phân ca làm việc hành chính chuẩn (Ca HC)
│   │
│   ├── fix-5/                                   # [Priority P2] Giai đoạn Nhân viên nộp 3 loại đơn từ Portal
│   │   ├── TC-06.md                             # [MnuHRS225 & MnuTAD1000] Khảo sát Before ngày 15/10 & Tổng công T10
│   │   ├── TC-07.md                             # [MnuHRS033]  Nộp đơn Xin bù công ngày 15/10/2026 (Giờ vào 08:00)
│   │   ├── TC-08.md                             # [MnuWPT315]  Nộp đơn Xin nghỉ phép năm AL hưởng lương (24/10/2026)
│   │   └── TC-09.md                             # [MnuWPT316]  Nộp đơn Xin tăng ca OT 2.0h ngày thường (20/10/2026)
│   │
│   ├── fix-6/                                   # [Priority P3] Giai đoạn Phê duyệt đa cấp & Chốt chặn Delta After
│   │   ├── TC-10.md                             # [MnuWPT037]  Quản lý ThanhLong duyệt Cấp 1 đơn Nghỉ phép AL
│   │   ├── TC-11.md                             # [MnuWPT037]  Quản lý LongKa duyệt Cấp 1 đơn Tăng ca OT
│   │   ├── TC-12.md                             # [MnuWPT037]  Giám đốc cuong.vu duyệt chặng cuối CẢ 2 ĐƠN + Bù công
│   │   └── TC-13.md                             # [MnuHRS225 & MnuTAD1000] Đối soát chốt chặn Delta After công ngày & tháng
│   │
│   ├── fix-7/                                   # [Priority P4] Giai đoạn Nạp thu nhập/Khấu trừ & Tính lương tự động
│   │   ├── TC-14.md                             # [MnuPRL036]  Kế toán chien.nguyen nạp Thưởng KPI 1,000,000 đ
│   │   ├── TC-15.md                             # [MnuPRL070]  Kế toán chien.nguyen nạp Tạm ứng 2,000,000 đ & Khóa phiếu
│   │   ├── TC-16.md                             # [MnuPRL040]  Kế toán kích hoạt Tính tiền lương tự động SALCAL_MAIN
│   │   └── TC-17.md                             # [MnuPRL080]  Kế toán thực hiện Khóa sổ kỳ lương Tháng 10/2026
│   │
│   └── fix-8/                                   # [Priority P5] Giai đoạn Nghiệm thu Bảng lương & Phiếu lương 17 chỉ tiêu
│       ├── TC-18.md                             # [MnuPRL092]  Kế toán đối soát Bảng lương tổng hợp toàn công ty
│       ├── TC-19.md                             # [MnuPRL445]  Nhân viên mới đăng nhập & Nghiệm thu 17 chỉ tiêu Phiếu lương
│       └── TC-20.md                             # [MnuPRL445]  Kiểm tra tương tác 3 Modal con mắt 👁️ và Tab Lịch sử
│
├── tests/
│   └── quy_trinh_tinh_luong_nv_moi.spec.js      # ⭐ FILE TEST DUY NHẤT CHỨA TOÀN BỘ 20 TC CỦA CẢ 5 CONVERSATION
│
├── helpers/
│   └── db.js                                    # Helper truy vấn CSDL SQL Server ở chế độ READ-ONLY nghiêm ngặt
│
├── visual_cursor.js                             # Con trỏ chuột Neon phát sáng trực quan phục vụ Live Visual Testing
│
└── test-evidence/                               # THƯ MỤC LƯU TRỮ MINH CHỨNG TỰ ĐỘNG SAU KHI TEST CHẠY
    └── quy_trinh_tinh_luong_nv_moi/             # Lưu video, ảnh chụp before/after, log đối soát cho từng TC (TC-01..20)
```

---

## 💡 2. TRIẾT LÝ THIẾT KẾ: TẠI SAO PHẢI LÀ "1 FILE TEST DUY NHẤT"?

### 🔴 1. Vấn đề chí mạng khi chia thành nhiều file .spec.js riêng lẻ:
* Nghiệp vụ Tiền lương & Chấm công có tính **ràng buộc trạng thái luân chuyển (State Machine Lifecycle)**:
  $$\text{Tạo NV 099} \longrightarrow \text{Nộp đơn (Chờ duyệt)} \longrightarrow \text{Duyệt đơn (Approved)} \longrightarrow \text{Tính lương} \longrightarrow \text{Khóa sổ}$$
* **Hậu quả nếu tách file riêng**:
  - Khi chạy lần 1: Script chạy thêm mới nhân viên, thêm đơn... thành công.
  - Khi chạy lần 2: File tạo NV sẽ bị báo lỗi (Fail) vì NV `099` đã tồn tại trong CSDL. File nộp đơn sẽ fail vì ngày đó đã có đơn trùng. File duyệt đơn sẽ không còn đơn nào ở trạng thái "Chờ duyệt" để bấm duyệt. File tính lương sẽ fail vì kỳ lương Tháng 10 đã bị "Khóa sổ" từ lần chạy trước!
  - Kết quả: Các test case riêng lẻ trở thành **"dùng một lần rồi vứt" (Single-use)**, không thể tái sử dụng cho CI/CD hoặc Regression Test.

### 🟢 2. Giải pháp 1 File Spec duy nhất kết hợp Cơ chế Tự thích ứng (Idempotent Test):
* Khi toàn bộ chuỗi được gom vào **1 file `tests/quy_trinh_tinh_luong_nv_moi.spec.js`**, quy trình chạy tuần tự từ `TC-01` đến `TC-20` phản ánh đúng 100% vòng đời thực tế của một nhân viên mới từ lúc vào công ty đến khi nhận phiếu lương đầu tiên.
* **Cơ chế Idempotent (Tự động thích ứng tiền đề - Auto Pre-condition)**:
  - Trước mỗi hành động tạo mới (Thêm NV, nạp đơn, duyệt, tính lương), script thực hiện câu lệnh kiểm tra:
    * **Nếu dữ liệu CHƯA CÓ**: Thực hiện đầy đủ các bước Click nút Thêm mới, điền form, bấm Lưu.
    * **Nếu dữ liệu ĐÃ CÓ (từ lần test trước)**: Tự động chuyển sang chế độ **Đối soát & Khẳng định (Verify & Highlight)**, dùng helper `highlightAndPause` khoanh viền Neon đỏ vào dòng dữ liệu trên màn hình để kiểm chứng, sau đó bước tiếp sang TC sau mà **không gây lỗi (No Crash)**!

---

## 🛡️ 3. NGUYÊN TẮC CÁCH LY MULTI-AGENT TRÊN FILE CHUNG (ĐIỀU 6 AGENTS.MD)

Để 5 Agent làm việc đồng thời trên 1 file mà không gây xung đột cú pháp (`SyntaxError`) hoặc ghi đè code của nhau:

1. **Phân định ranh giới tuyệt đối**:
   - Mỗi Conversation chỉ được mở và sửa code nằm giữa 2 thẻ đánh dấu định danh của mình:
     ```javascript
     // >>> [START_TC_XX] - CONVERSATION: fix-4
     test('fix-4 | TC-XX: ...', async ({ page }, testInfo) => {
         // >>> TOÀN BỘ CODE CỦA FIX-4 NẰM TRONG NÀY <<<
     });
     // <<< [END_TC_XX]
     ```
2. **Cấm sửa vùng dùng chung**:
   - Tuyệt đối không chỉnh sửa phần Header chung (các hàm helper `moveAndClick`, `highlightAndPause`, `performLogin`, `ACCOUNTS`...).
   - Tuyệt đối không xóa, không sửa, không comment vào block của các conversation khác.
3. **Chế độ chạy cục bộ (Targeted TC Run)**:
   - Mỗi conversation kiểm thử mã nguồn của mình bằng cờ `-g "<tên_conversation>"`:
     ```bash
     npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-4" --project="Google Chrome"
     ```

---

## 📋 4. MA TRẬN PHÂN CÔNG 5 CONVERSATION

| Conversation | Phase | Danh sách TC | Mã Menu đảm nhiệm | Role thực hiện | Trọng tâm kiểm thử & Idempotent Guard |
|:---:|:---:|:---|:---|:---:|:---|
| **`fix-4`** | **P1** | • **TC-03**: HĐLĐ & Lương 10tr<br/>• **TC-04**: Khai báo 1 NPT<br/>• **TC-05**: Phân ca HC | `MnuHRS145`<br/>`MnuHRS157`<br/>`MnuTAD020` | `cuong.vu`<br/>*(HR Admin)* | • **Pre-seed CSDL**: Hồ sơ NV 099 & User `test.nv` đã được nạp thẳng vào DB qua `scripts/seed_test_employee_099.sql` (bỏ qua thao tác UI TC-01 & TC-02 do màn hình MnuSCR608 đang có bug).<br/>• Check `tblSalaryHistory`, `tblFamilyInfo` trước khi tạo.<br/>• Thực hiện 3 bước thiết lập chuẩn trên UI. |
| **`fix-5`** | **P2** | • **TC-06**: Khảo sát Before ngày 15/10<br/>• **TC-07**: Đơn Bù công 15/10<br/>• **TC-08**: Đơn Nghỉ phép AL 24/10<br/>• **TC-09**: Đơn Tăng ca OT 20/10 | `MnuHRS225`<br/>`MnuTAD1000`<br/>`MnuHRS033`<br/>`MnuWPT315`<br/>`MnuWPT316` | `test.nv`<br/>*(Nhân viên mới)* | • Đo baseline Before: Giờ vào `--:--`, tổng công $21.0\text{ ngày}$.<br/>• Nếu 3 đơn đã tồn tại trong tab Lịch sử: Verify trạng thái Pending.<br/>• Nếu chưa có: Điền form nộp đơn. |
| **`fix-6`** | **P3** | • **TC-10**: Duyệt Cấp 1 Phép AL<br/>• **TC-11**: Duyệt Cấp 1 Tăng ca OT<br/>• **TC-12**: Duyệt chặng cuối 3 đơn<br/>• **TC-13**: Đối soát Delta After công | `MnuWPT037`<br/>`MnuWPT037`<br/>`MnuWPT037`<br/>`MnuHRS225`<br/>`MnuTAD1000` | `ThanhLong`<br/>`LongKa`<br/>`cuong.vu` | • Duyệt đa cấp linh hoạt (Nếu đã duyệt thì bỏ qua, chỉ verify `Approved = 1`).<br/>• Chốt chặn Delta After: Ngày 15/10 đạt $8.0\text{h}$, tổng tháng nhảy $21.0 \rightarrow 23.0\text{ ngày}$. |
| **`fix-7`** | **P4** | • **TC-14**: Nạp Thưởng KPI 1tr<br/>• **TC-15**: Nạp & Khóa Tạm ứng 2tr<br/>• **TC-16**: Kích hoạt Tính tiền lương<br/>• **TC-17**: Khóa sổ kỳ lương T10 | `MnuPRL036`<br/>`MnuPRL070`<br/>`MnuPRL040`<br/>`MnuPRL080` | `chien.nguyen`<br/>*(Kế toán)* | • Nạp dữ liệu biến động thu nhập/khấu trừ.<br/>• Thực thi `SALCAL_MAIN` và bắt kết quả `eof`.<br/>• Thực hiện Khóa sổ kỳ lương Tháng 10/2026. |
| **`fix-8`** | **P5** | • **TC-18**: Bảng lương tổng hợp<br/>• **TC-19**: Phiếu lương 17 chỉ tiêu<br/>• **TC-20**: 3 Modal con mắt 👁️ | `MnuPRL092`<br/>`MnuPRL445`<br/>`MnuPRL445` | `chien.nguyen`<br/>`test.nv` | • Đối soát Bảng lương tổng hợp toàn công ty.<br/>• Khớp chính xác 17/17 chỉ tiêu toán học trên Phiếu lương.<br/>• Bấm kiểm tra 3 Modal popup chi tiết (OT, Nghỉ phép, Trễ). |

---

## 💬 5. BỘ 5 PROMPT CHUẨN MẪU GIAO VIỆC (COPY-PASTE CHO TỪNG CONVERSATION)

Người dùng chỉ cần copy nguyên văn prompt tương ứng bên dưới và gửi vào ô chat của conversation đó:

---

### 🔹 PROMPT DÀNH CHO CONVERSATION `fix-4`:
```text
Chào bạn fix-4. Bạn được phân công là Agent P1 phụ trách Giai đoạn 1 (Thiết lập HĐLĐ, Người phụ thuộc & Phân ca).

LƯU Ý QUAN TRỌNG VỀ DỮ LIỆU ĐẦU VÀO:
- Hồ sơ nhân viên 099 (Nguyễn Văn Test) và tài khoản ESS Portal test.nv / 123 ĐÃ ĐƯỢC TẠO SẴN TRONG CSDL qua file scripts/seed_test_employee_099.sql (do màn hình MnuSCR608 hiện đang có bug lưu đè và được dev khác fix riêng).
- Vì vậy, bạn KHÔNG CẦN tạo hồ sơ hay tạo user trên UI (bỏ qua TC-01 và TC-02).

Nhiệm vụ của bạn tập trung vào 3 Test Case trên UI:
1. Đọc kỹ kịch bản đặc tả tại thư mục:
   - kichbantest/fix-4/TC-03.md (HĐLĐ & Mức lương 10,000,000 VNĐ - MnuHRS145)
   - kichbantest/fix-4/TC-04.md (Khai báo 1 Người phụ thuộc thuế - MnuHRS157)
   - kichbantest/fix-4/TC-05.md (Phân ca hành chính Ca HC - MnuTAD020 / MnuATT101)
2. Mở file test chung: tests/quy_trinh_tinh_luong_nv_moi.spec.js.
   - TUYỆT ĐỐI TUÂN THỦ ĐIỀU 6 AGENTS.md: Bạn CHỈ ĐƯỢC CHỈNH SỬA mã nguồn trong các block từ [START_TC_03] đến [END_TC_05]. Tuyệt đối không chạm vào code của fix-5, fix-6, fix-7, fix-8 hay header chung.
3. Triển khai theo cơ chế Idempotent:
   - Dùng helper query DB hoặc tìm kiếm UI: Nếu mức lương 10tr hoặc Người phụ thuộc đã tồn tại từ lần test trước, hãy highlightAndPause dòng đó trên UI để đối soát, không thực hiện thêm mới để tránh fail. Nếu chưa có thì thực hiện tạo mới đầy đủ.
4. Chạy kiểm thử kiểm chứng độc lập cho riêng cụm TC của bạn:
   npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-4" --project="Google Chrome"
Báo cáo kết quả và log đối soát sau khi chạy xong.
```

---

### 🔹 PROMPT DÀNH CHO CONVERSATION `fix-5`:
```text
Chào bạn fix-5. Bạn được phân công là Agent P2 phụ trách Giai đoạn 2 (Nhân viên nộp 3 loại đơn từ ESS Portal).
Nhiệm vụ của bạn:
1. Đọc kỹ kịch bản đặc tả tại thư mục:
   - kichbantest/fix-5/TC-06.md (Khảo sát Before ngày 15/10 và tổng công tháng 10)
   - kichbantest/fix-5/TC-07.md (Nộp đơn Xin bù công ngày 15/10 - Giờ vào 08:00)
   - kichbantest/fix-5/TC-08.md (Nộp đơn Xin nghỉ phép năm AL 24/10)
   - kichbantest/fix-5/TC-09.md (Nộp đơn Xin tăng ca OT 20/10)
2. Mở file test chung: tests/quy_trinh_tinh_luong_nv_moi.spec.js.
   - TUYỆT ĐỐI TUÂN THỦ ĐIỀU 6 AGENTS.md: Bạn CHỈ ĐƯỢC CHỈNH SỬA mã nguồn trong các block từ [START_TC_06] đến [END_TC_09]. Tuyệt đối không chạm vào code của conversation khác.
3. Triển khai theo cơ chế Idempotent:
   - Nhân viên test.nv đăng nhập. Nếu 3 đơn đã được nộp từ lần chạy trước (kiểm tra trong tab Lịch sử đơn), hãy khoanh vùng highlight dòng đơn để kiểm chứng trạng thái Pending. Nếu chưa nộp thì thực hiện mở form và nộp đơn.
4. Chạy kiểm thử kiểm chứng độc lập cho riêng cụm TC của bạn:
   npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-5" --project="Google Chrome"
Báo cáo kết quả và log đối soát sau khi chạy xong.
```

---

### 🔹 PROMPT DÀNH CHO CONVERSATION `fix-6`:
```text
Chào bạn fix-6. Bạn được phân công là Agent P3 phụ trách Giai đoạn 3 (Phê duyệt đa cấp & Chốt chặn Delta After công).
Nhiệm vụ của bạn:
1. Đọc kỹ kịch bản đặc tả tại thư mục:
   - kichbantest/fix-6/TC-10.md (ThanhLong duyệt Cấp 1 đơn Nghỉ phép AL)
   - kichbantest/fix-6/TC-11.md (LongKa duyệt Cấp 1 đơn Tăng ca OT)
   - kichbantest/fix-6/TC-12.md (cuong.vu duyệt chặng cuối CẢ 2 ĐƠN + Đơn bù công 15/10)
   - kichbantest/fix-6/TC-13.md (Đối soát Delta After công ngày 15/10 và tổng công tháng)
2. Mở file test chung: tests/quy_trinh_tinh_luong_nv_moi.spec.js.
   - TUYỆT ĐỐI TUÂN THỦ ĐIỀU 6 AGENTS.md: Bạn CHỈ ĐƯỢC CHỈNH SỬA mã nguồn trong các block từ [START_TC_10] đến [END_TC_13]. Tuyệt đối không chạm vào code của conversation khác.
3. Triển khai theo cơ chế Idempotent:
   - Khi login vào màn hình duyệt MnuWPT037: Nếu đơn của NV 099 đã được duyệt từ trước (Approved = 1), hãy lọc tab Đã duyệt và highlight dòng đơn. Nếu đơn đang ở tab Chờ duyệt, thực hiện tick chọn và bấm Duyệt.
   - Tại TC-13: Chốt chặn đối soát Delta After ngày 15/10 đạt 8.0h công chuẩn và tổng công tháng tăng từ 21.0 lên 23.0 ngày.
4. Chạy kiểm thử kiểm chứng độc lập cho riêng cụm TC của bạn:
   npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-6" --project="Google Chrome"
Báo cáo kết quả và log đối soát sau khi chạy xong.
```

---

### 🔹 PROMPT DÀNH CHO CONVERSATION `fix-7`:
```text
Chào bạn fix-7. Bạn được phân công là Agent P4 phụ trách Giai đoạn 4 (Nạp Thưởng/Tạm ứng & Kích hoạt Tính lương tự động).
Nhiệm vụ của bạn:
1. Đọc kỹ kịch bản đặc tả tại thư mục:
   - kichbantest/fix-7/TC-14.md (Kế toán nạp Thưởng KPI 1,000,000 VNĐ Tháng 10/2026)
   - kichbantest/fix-7/TC-15.md (Kế toán nạp Tạm ứng lương 2,000,000 VNĐ & Khóa phiếu)
   - kichbantest/fix-7/TC-16.md (Kế toán kích hoạt Tính tiền lương tự động SALCAL_MAIN)
   - kichbantest/fix-7/TC-17.md (Kế toán thực hiện Khóa sổ kỳ lương Tháng 10/2026)
2. Mở file test chung: tests/quy_trinh_tinh_luong_nv_moi.spec.js.
   - TUYỆT ĐỐI TUÂN THỦ ĐIỀU 6 AGENTS.md: Bạn CHỈ ĐƯỢC CHỈNH SỬA mã nguồn trong các block từ [START_TC_14] đến [END_TC_17]. Tuyệt đối không chạm vào code của conversation khác.
3. Triển khai theo cơ chế Idempotent:
   - Kiểm tra xem Thưởng KPI và Tạm ứng của NV 099 đã nạp và khóa chưa. Nếu đã có, highlight đối soát số tiền 1.000.000 đ và 2.000.000 đ.
   - Thực thi tính lương MnuPRL040: Chờ tiến trình hoàn tất và log ra 'eof'.
   - MnuPRL080: Nếu Tháng 10 đã khóa sổ thì kiểm tra trạng thái khóa, nếu chưa khóa thì thực hiện bấm Khóa sổ.
4. Chạy kiểm thử kiểm chứng độc lập cho riêng cụm TC của bạn:
   npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-7" --project="Google Chrome"
Báo cáo kết quả và log đối soát sau khi chạy xong.
```

---

### 🔹 PROMPT DÀNH CHO CONVERSATION `fix-8`:
```text
Chào bạn fix-8. Bạn được phân công là Agent P5 phụ trách Giai đoạn 5 (Nghiệm thu Bảng lương & Phiếu lương 17 chỉ tiêu).
Nhiệm vụ của bạn:
1. Đọc kỹ kịch bản đặc tả tại thư mục:
   - kichbantest/fix-8/TC-18.md (Kế toán đối soát Bảng lương tổng hợp toàn công ty MnuPRL092)
   - kichbantest/fix-8/TC-19.md (Nhân viên mới đăng nhập & Nghiệm thu 17 chỉ tiêu Phiếu lương MnuPRL445)
   - kichbantest/fix-8/TC-20.md (Kiểm tra tương tác 3 Modal con mắt 👁️ và Tab Lịch sử phiếu lương)
2. Mở file test chung: tests/quy_trinh_tinh_luong_nv_moi.spec.js.
   - TUYỆT ĐỐI TUÂN THỦ ĐIỀU 6 AGENTS.md: Bạn CHỈ ĐƯỢC CHỈNH SỬA mã nguồn trong các block từ [START_TC_18] đến [END_TC_20]. Tuyệt đối không chạm vào code của conversation khác.
3. Triển khai chi tiết:
   - TC-18: Mở MnuPRL092, cuộn tìm dòng NV 099, highlight và đối soát Lương thực lĩnh = 8,111,043 VNĐ.
   - TC-19: Đăng nhập test.nv, mở Phiếu lương MnuPRL445, đối soát khớp 17/17 chỉ tiêu tài chính (Lương ngày công, Phép năm, OT, Thưởng, Tạm ứng, Thuế TNCN 4.4M NPT, Bảo hiểm 1.05M...).
   - TC-20: Click 3 nút icon con mắt để mở popup chi tiết Tăng ca, Nghỉ phép, Đi trễ; kiểm tra nội dung hiển thị sạch sẽ không bị vỡ layout.
4. Chạy kiểm thử kiểm chứng độc lập cho riêng cụm TC của bạn:
   npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-8" --project="Google Chrome"
Báo cáo kết quả và log đối soát sau khi chạy xong.
```

---

## 🚀 6. HƯỚNG DẪN THỰC THI & CHẠY TỔNG DUYỆT E2E

### Bước 1: Phát lệnh cho 5 Conversation
Gửi 5 prompt ở Mục 5 vào 5 cửa sổ chat `fix-4`, `fix-5`, `fix-6`, `fix-7`, `fix-8`. Các agent sẽ đọc kịch bản và rà soát/tinh chỉnh code trong block của mình trên file `tests/quy_trinh_tinh_luong_nv_moi.spec.js`.

### Bước 2: Kích hoạt chạy Live Test theo thứ tự Pipeline
Sau khi các agent hoàn tất chỉnh sửa code, kích hoạt chạy tuần tự từng cụm để đảm bảo dữ liệu dây chuyền:
```bash
# 1. Chạy khởi tạo nhân sự & cấp tài khoản:
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-4" --project="Google Chrome"

# 2. Chạy nộp 3 loại đơn từ Portal:
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-5" --project="Google Chrome"

# 3. Chạy phê duyệt đa cấp & chốt chặn Delta After công:
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-6" --project="Google Chrome"

# 4. Chạy nạp thưởng/tạm ứng & kích hoạt tính lương:
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-7" --project="Google Chrome"

# 5. Chạy nghiệm thu bảng lương & phiếu lương 17 chỉ tiêu:
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-8" --project="Google Chrome"
```

### Bước 3: Tổng duyệt toàn bộ 20 Test Case liên hoàn (Full Regression Suite)
Khi cả 5 cụm đều đã PASS độc lập, kích hoạt 1 lệnh duy nhất để chạy toàn bộ 20 TC từ đầu đến cuối:
```bash
npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js --project="Google Chrome"
```
Nhờ cơ chế Idempotent, bộ test này có thể chạy lại bất kỳ lúc nào mà vẫn tự động phát hiện dữ liệu và pass 100%!
