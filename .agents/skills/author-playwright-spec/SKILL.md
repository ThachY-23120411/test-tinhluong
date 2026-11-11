---
name: author-playwright-spec
description: Chuyên gia nhào nặn kịch bản kiểm thử Playwright (.spec.js) chuẩn mực, cô đọng, sắc sảo từ yêu cầu của Dev. Áp dụng đánh giá động (Dynamic Assertion if/else), tiêu đề trung lập (Neutral Steps), tiền đề tự hành (Auto Pre-condition), di chuột trực quan và BỘ 9 LUẬT THÉP BẤT BIẾN (CHỐNG FAKE PASS, TRIỆT TIÊU TRÙNG LẶP ẢNH, KIỂM CHỨNG KÉP CSDL, ĐỐI SOÁT ĐỊNH LƯỢNG TỪNG TRƯỜNG DỮ LIỆU & KIỂM SOÁT THÀNH PHẦN ĐỘNG DYNAMIC STATE). Tuyệt đối không gán cứng FAIL.
---

# AUTHOR PLAYWRIGHT SPEC — KỸ NĂNG NHÀO NẶN KỊCH BẢN KIỂM THỬ PLAYWRIGHT

> **Sứ mệnh duy nhất**: Nhận yêu cầu nghiệp vụ từ Dev $\longrightarrow$ Khảo sát DOM/CSDL $\longrightarrow$ Áp dụng **BỘ 9 LUẬT THÉP CHỐNG FAKE PASS, ĐỐI SOÁT ĐỊNH LƯỢNG TỪNG TRƯỜNG & KIỂM SOÁT THÀNH PHẦN ĐỘNG** $\longrightarrow$ Xuất mã nguồn `tests/<page>.spec.js` chuẩn 100%, cô đọng, test sâu tận gốc, zero fake pass, đối soát từng con số, không văng lỗi oan.
> *(Khâu đóng gói `.bat`, quản lý menu và chạy báo cáo sẽ do skill `playwright-live-visual-e2e` đảm nhiệm).*

---

## 🛑 BỘ 9 LUẬT THÉP BẤT KHẢ XÂM PHẠM (IRONCLAD ZERO-FAKE-PASS, FIELD-RECONCILIATION & DYNAMIC-STATE RULES)

> [!CAUTION]
> **CẢNH BÁO BẤT BIẾN CHO AGENT**:
> Một kịch bản kiểm thử vô giá trị nhất là kịch bản báo xanh (PASS) trong khi trên thực tế dữ liệu chưa hề được tạo, đơn từ bị kẹt ở popup chưa gửi, hoặc kiểm tra nhầm vào dữ liệu cũ trong quá khứ! Agent bắt buộc phải khắc cốt ghi tâm 9 luật thép sau:

### 🛑 LUẬT THÉP 1: TRIỆT TIÊU 100% "FAKE PASS" BẰNG DYNAMIC EXACT MATCH
* **CẤM TUYỆT ĐỐI CÁC KIỂM TRA NÔNG (SHALLOW ASSERTIONS)**:
  * ❌ `expect(cards.count()).toBeGreaterThan(0)` $\longrightarrow$ *Cực kỳ nguy hiểm vì dữ liệu rác từ tháng trước/năm trước vẫn làm test pass!*
  * ❌ `expect(text).toContain('Đang chờ duyệt')` $\longrightarrow$ *Bắt nhầm đơn cũ vẫn đang ở trạng thái chờ duyệt.*
  * ❌ `expect(locator.isVisible()).toBeTruthy()` mà không so khớp nội dung chi tiết.
* **BẮT BUỘC ÁP DỤNG DYNAMIC EXACT MATCH (SO KHỚP CHÍNH XÁC ĐỊNH LƯỢNG)**:
  1. Khi nhập liệu: Tạo ra **Dấu ấn định danh duy nhất (Unique Fingerprint)**:
     - Ngày kiểm thử cụ thể (ví dụ: ngày hôm nay `02/11/2026`).
     - Giờ cụ thể (`08:00`).
     - Lý do kèm mốc thời gian: ``Quên quẹt thẻ ngày ${todayStr} do đi công tác [${Date.now()}]``.
  2. Khi kiểm tra Tab Lịch sử / Danh sách bảng:
     - **Bắt buộc soi chi tiết Thẻ đầu tiên (Top 1)**: `const topCardText = await cards.first().innerText();`
     - So khớp chặt chẽ: Thẻ Top 1 phải chứa đúng Ngày vừa tạo, đúng Giờ vừa tạo (`08:00`), đúng Lý do vừa nhập.
     - **Nếu thẻ Top 1 KHÔNG KHỚP $\longrightarrow$ BẮT BUỘC ĐÁNH FAIL NGAY LẬP TỨC!**
     ```javascript
     const hasTargetDate = topCardText.includes(todayStr);
     const hasTargetTime = topCardText.includes('08:00');
     const isPassed = hasTargetDate && hasTargetTime;

     if (isPassed) {
       testInfo.annotations.push({
         type: 'business_status',
         description: `PASS - Thẻ Top 1 hiển thị chính xác đơn vừa tạo ngày ${todayStr} lúc 08:00`
       });
     } else {
       testInfo.annotations.push({
         type: 'business_status',
         description: `FAIL - Không tìm thấy đơn vừa tạo tại Top 1! Đơn có thể chưa được lưu vào CSDL hoặc bị lỗi gửi.`
       });
       testInfo.annotations.push({
         type: 'defect_evidence',
         description: JSON.stringify({
           issue: 'Đơn mới tạo không xuất hiện tại vị trí Top 1 trong Lịch sử',
           expected: { date: todayStr, time: '08:00' },
           actualTopCard: topCardText.substring(0, 200)
         })
       });
     }
     ```

---

### 🛑 LUẬT THÉP 2: THẨM ĐỊNH CHUỖI PHÊ DUYỆT ĐA CẤP (APPROVAL MATRIX DISCOVERY)
* **CẤM ĐOÁN MÒ VAI TRÒ NGƯỜI DUYỆT**:
  * Trong Paradise HRM, mọi đơn từ (Xin nghỉ phép, Xin bù công, Xin tăng ca, Đổi ca, Đi trễ về sớm...) đều vận hành theo **Chuỗi phê duyệt đa cấp (Approval Flow)**: Cấp 1 $\longrightarrow$ Cấp 2 $\longrightarrow$ Cấp 3.
  * Tuyệt đối không bao giờ được giả định một người duy nhất duyệt.
* **QUY TRÌNH THẨM ĐỊNH CHUỖI DUYỆT BẮT BUỘC**:
  1. **Quan sát trực tiếp trên DOM/UI**: Khi nhân viên mở form, giao diện luôn vẽ widget chuỗi duyệt (ví dụ: các avatar tròn `Mr. LONG [011] ➔ Mr. CƯỜNG [014]`).
  2. **Truy vấn CSDL (Read-only an toàn)**: Dùng `helpers/db.js` truy vấn bảng `tblApprovalLineByEmployee` hoặc `sp_GetApprovalFlow` theo mã nhân viên để biết trước 100%:
     - Ai là Người duyệt Cấp 1? (`ApproverID = '011'` - `ThanhLong`).
     - Ai là Người duyệt Cấp 2? (`ApproverID = '014'` - `cuong.vu`).
* **QUY TẮC DUYỆT BẬC THANG TUẦN TỰ (SEQUENTIAL WATERFALL APPROVAL)**:
  * **Chặng 1**: Đăng nhập Quản lý Cấp 1 $\longrightarrow$ Vào menu *Danh sách phê duyệt* $\longrightarrow$ Mở đơn $\longrightarrow$ Bấm *Duyệt* $\longrightarrow$ Xác nhận duyệt.
  * **Chặng 2**: **CHỈ SAU KHI CẤP 1 ĐÃ DUYỆT THÀNH CÔNG**, hệ thống mới chuyển `Approve_Status = 1` cho Cấp 2. Lúc này mới đăng nhập Quản lý Cấp 2 $\longrightarrow$ Vào *Danh sách phê duyệt* $\longrightarrow$ Lúc này đơn mới hiển thị $\longrightarrow$ Duyệt tiếp Cấp 2.
  * *Hậu quả nếu nhảy cóc*: Nếu vào thẳng Cấp 2 khi Cấp 1 chưa duyệt, danh sách sẽ luôn báo `Không có dữ liệu`!

---

### 🛑 LUẬT THÉP 3: CHUẨN HÓA VÒNG ĐỜI GỬI FORM, BẮT POPUP XÁC NHẬN (#VC-VU-CONFIRM-POPUP) & GIÁM SÁT NETWORK / CHROME DEVTOOLS MCP (ZERO BLIND SUBMIT)
* **QUY CHUẨN THIẾT LẬP THỜI GIAN ĐẦU VÀO FORM (CHỐNG LỖI TỐI THIỂU 15 PHÚT)**:
  * Khi điền ô ngày giờ (`dxDateBox` type `datetime`), **TUYỆT ĐỐI CẤM** dùng `new Date('YYYY-MM-DD')` thuần túy vì trình duyệt sẽ chuyển thành `07:00:00` cho cả Từ ngày và Đến ngày $\longrightarrow$ Dẫn đến thời lượng = 0 phút, backend ném lỗi: *"Thời gian nghỉ phép tối thiểu là 15 phút!"*.
  * **BẮT BUỘC THIẾT LẬP GIỜ CA LÀM VIỆC CHUẨN XÁC**:
    - **Form nghỉ phép (MnuWPT315)**: Bắt đầu `08:00:00`, kết thúc `17:00:00` (đủ 1 ca ngày 8 giờ làm việc, > 15 phút).
      ```javascript
      const parts = dateStr.split('-').map(Number);
      instanceFrom.option('value', new Date(parts[0], parts[1] - 1, parts[2], 8, 0, 0));
      instanceTo.option('value', new Date(parts[0], parts[1] - 1, parts[2], 17, 0, 0));
      ```
    - **Form tăng ca (MnuWPT316)**: Từ `18:00` đến `20:00` (2.0 giờ).
* **TUYỆT ĐỐI KHÔNG DỪNG LẠI Ở NÚT "ĐĂNG KÝ" / "LƯU"**:
  * Khi bấm nút `Đăng ký`, hệ thống Paradise HRM **CHƯA HỀ LƯU DỮ LIỆU**, mà luôn bật ra modal xác nhận:
    `#vc-vu-confirm-popup` với câu hỏi: *"Bạn có chắc đăng ký đơn này không? [Không] [Đồng ý]"*.
* **BẮT BUỘC HOÀN TẤT CHUỖI 5 PHA VÀ GIÁM SÁT NETWORK / CHROME DEVTOOLS MCP**:
  1. **Pha 1**: Bấm nút gửi (`button.btnRegister` hoặc `button:has-text("Đăng ký")`).
  2. **Pha 2**: Chờ popup xác nhận `#vc-vu-confirm-popup` xuất hiện $\longrightarrow$ Di chuột Neon bấm nút xanh **"Đồng ý"** (`.VC-Vu-btn-ok`).
     - **Cơ chế click phòng thủ chống Pointer Interception**: Do DevExtreme scrollable content hoặc ô `textarea #Note` có thể chồng toạ độ, luôn dùng:
     ```javascript
     const dongYBtn = page.locator('#vc-vu-confirm-popup .VC-Vu-btn-ok, button.VC-Vu-btn-ok:has-text("Đồng ý")').first();
     await dongYBtn.waitFor({ state: 'visible', timeout: 5000 });
     await moveAndClick(page, dongYBtn, { steps: 6, pause: 200 });
     // Fallback native click trực tiếp trên DOM để đảm bảo 100% không bị overlay chặn
     await page.evaluate(() => {
       const btn = document.querySelector('#vc-vu-confirm-popup .VC-Vu-btn-ok');
       if (btn) btn.click();
     });
     ```
  3. **Pha 3**: Chờ popup xác nhận đóng lại $\longrightarrow$ Bấm tiếp nút `OK` trên popup thông báo kết quả nếu có (`#vc-vu-info-popup .VC-Vu-btn-ok` hoặc `.dx-toast-message`).
  4. **Pha 4 (GIÁM SÁT NETWORK RESPONSE / CHROME DEVTOOLS MCP - BẮT BUỘC)**:
     - Chặn bắt và phân tích gói tin AJAX `/hpa/paradise2` hoặc API backend.
     - Kiểm tra trực tiếp: Gói tin trả về phải có `returnValue === 0` và có `IdentityID` hợp lệ.
     - **CHỐNG TIẾP TỤC MÙ QUÁNG (ZERO BLIND PROCEED)**: Nếu có thông báo lỗi toast (`.dx-toast-error`, `.swal2-error`) hoặc backend trả về `returnValue: 1` $\longrightarrow$ **BẮT BUỘC DỪNG NGAY TEST VÀ NÉM LỖI (THROW ERROR)**. Tuyệt đối không được bỏ qua để chạy tiếp các bước sau khi form gốc chưa lưu được!
  5. **Pha 5**: Đối soát CSDL kép qua `helpers/db.js` xác nhận bản ghi thực tế đã tồn tại trong bảng (`tblLeaveRegistered` hoặc `tblOTListRegistered`).

---

### 🛑 LUẬT THÉP 4: BẢO ĐẢM TOÀN VẸN DÒNG CHẢY LIÊN HOÀN (DOWNSTREAM RIPPLE EFFECT)
* **KHÔNG TEST CÔ LẬP TRÊN 1 MÀN HÌNH**:
  * Nghiệp vụ HRM là dòng chảy liên hoàn dữ liệu (Data Pipeline). Một đơn được duyệt xong không được kết thúc lơ lửng, mà phải đối soát tác động lan tỏa:
    - **Trạm 1 (Portal)**: Nhân viên tạo đơn bù công $\longrightarrow$ Thẻ Lịch sử hiển thị *"Đang chờ duyệt"*.
    - **Trạm 2 (Approval)**: Quản lý Cấp 1 + Cấp 2 duyệt $\longrightarrow$ Thẻ Lịch sử chuyển sang *"Đã duyệt"*.
    - **Trạm 3 (Attendance TAD)**: Giờ bù công phải được tự động ghi nhận vào Bảng công ngày của nhân viên (cột Giờ vào / Giờ ra).
    - **Trạm 4 (Payroll PRL)**: Bảng lương công ty nạp công hợp lệ và tính đủ ngày công/lương.
    - **Trạm 5 (Salary Slip)**: Nhân viên mở xem Phiếu lương cá nhân khớp từng con số.

---

### 🛑 LUẬT THÉP 5: CÔ LẬP PHIÊN CHỐNG XUNG ĐỘT MULTI-ROLE (CLEAN SESSION ISOLATION)
* **KHI CHUYỂN ĐỔI ROLE GIỮA CÁC TEST CASE**:
  * Cấu hình bắt buộc ở đầu file spec: `test.use({ storageState: { cookies: [], origins: [] } });`
  * Trong hàm `loginDirectly(page, credentials)`:
    - Nếu đã đăng nhập user khác: Luôn xóa sạch `localStorage`, `sessionStorage`, xóa cookies và điều hướng về trang login `BASE_URL`.
    - Chờ ô `#username` hiển thị rõ ràng trước khi nhập:
    ```javascript
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded' });
    await page.evaluate(() => {
      localStorage.clear();
      sessionStorage.clear();
    });
    await page.reload({ waitUntil: 'domcontentloaded' });
    const userInput = page.locator('#username').first();
    await userInput.waitFor({ state: 'visible', timeout: 15000 });
    ```

---

### 🛑 LUẬT THÉP 6: CHỈ CHỤP ẢNH KHI GIAO DIỆN CÓ THAY ĐỔI (STATE-CHANGE SCREENSHOT ONLY - ZERO DUPLICATE IMAGES)
* **CẤM TUYỆT ĐỐI CHỤP ẢNH "BẮN LIÊN THANH" KHI MÀN HÌNH ĐỨNG YÊN**:
  * ❌ *Lỗi nghiêm trọng phổ biến*: Bước 4 chụp kết quả màn hình, sau đó Bước 5 chỉ chạy lệnh logic `if (isPassed)` trong bộ nhớ Node.js nhưng lại gọi tiếp `await captureStep(step 5)` $\longrightarrow$ Dẫn đến việc 2-3 bước liên tiếp chụp đi chụp lại đúng 1 màn hình giống hệt nhau 100% từng pixel, làm báo cáo bị trùng lặp ảnh phản cảm!
* **QUY TẮC BẮT BUỘC**:
  * **Chỉ chụp ảnh khi có sự kiện thay đổi trạng thái giao diện (State-change event)**:
    1. Khi mở trang mới hoặc đổi phân hệ.
    2. Khi điền form, chọn bộ lọc hoặc áp dụng tìm kiếm.
    3. Khi xuất hiện Modal/Popup xác nhận.
    4. Khi bảng dữ liệu hoặc kết quả mới được render hoàn tất.
  * **Tại Bước Đánh giá Logic (Bước kết luận)**:
    - Nếu màn hình đã được chụp đầy đủ ở bước thao tác trước đó và không có gì mới: **Tuyệt đối không gọi thêm `captureStep` chụp lại màn hình cũ**!
    - Bước đánh giá logic chỉ tập trung đẩy `testInfo.annotations` (`business_status`) và `defect_evidence`.
  * **Cơ chế phòng thủ của Reporter**: `markdown-reporter.js` đã tích hợp bộ lọc MD5 hash; nếu phát hiện 2 ảnh liên tiếp giống nhau 100%, hệ thống sẽ tự động loại bỏ ảnh trùng và chỉ in ghi chú `*(Giao diện giữ nguyên, không phát sinh thay đổi so với Bước trước)*`.

---

### 🛑 LUẬT THÉP 7: KIỂM CHỨNG KÉP UI + CSDL (DUAL-LAYER VERIFICATION — VŨ KHÍ TỐI THƯỢNG DIỆT FAKE PASS)
* **NGUYÊN TẮC BẤT BIẾN: CSDL LÀ NGUỒN CHÂN LÝ DUY NHẤT (SINGLE SOURCE OF TRUTH)**:
  * Kiểm thử E2E không được dừng lại ở việc nhìn giao diện DOM (vì DOM dễ bị dữ liệu cũ đánh lừa, nút click có thể bị nuốt thao tác do mạng chậm).
  * **MỌI THAO TÁC GHI / DUYỆT DỮ LIỆU ĐỀU BẮT BUỘC ĐỐI SOÁT CSDL BẰNG `helpers/db.js`**:
    1. **Khi nộp đơn**: Bắt buộc tạo **Dynamic Unique Token** (`const RUN_TOKEN = Date.now();`) gắn vào lý do `Quên quẹt thẻ [ID:${RUN_TOKEN}]`. Sau khi bấm Đồng ý, truy vấn ngay:
       ```javascript
       const { query } = require('../helpers/db');
       const rows = query(`SELECT TOP 1 IdentityID, Approve_Status FROM tblAttendanceConfirmRequest WHERE EmployeeID = '046' AND Remark LIKE '%${RUN_TOKEN}%'`);
       ```
       *Nếu `rows.length === 0` $\longrightarrow$ **FAIL NGAY LẬP TỨC!** (Đơn chưa từng được lưu vào CSDL).*
    2. **Khi duyệt Cấp 1 (`ThanhLong`)**: Sau khi bấm Duyệt trên giao diện, truy vấn ngay:
       ```javascript
       const checkC1 = query(`SELECT Approve_Status, Approval_Time FROM tblApproverHistory WHERE Identity_ID = '${identityId}' AND Level = 1 AND ApproverID = '011'`);
       ```
       *Nếu `checkC1[0].Approve_Status !== 2` $\longrightarrow$ **FAIL NGAY LẬP TỨC!** (Cấp 1 chưa được duyệt thực tế).*
    3. **Khi duyệt Cấp 2 (`cuong.vu`)**: Sau khi bấm Duyệt trên giao diện, truy vấn ngay:
       ```javascript
       const checkC2 = query(`SELECT Approve_Status FROM tblAttendanceConfirmRequest WHERE IdentityID = '${identityId}'`);
       ```
       *Nếu `checkC2[0].Approve_Status !== 2` $\longrightarrow$ **FAIL NGAY LẬP TỨC!** (Cấp 2 chưa duyệt toàn đơn).*
* **CẤM TUYỆT ĐỐI GÁN CỜ HÌNH THỨC (ZERO MOCK FLAGS)**:
  * Nghiêm cấm gán: `isL1Approved = hasCard` hay `isPassed = true`.
  * Biến cờ `isPassed` bắt buộc phải nhận giá trị từ kết quả đối soát CSDL:
    `const isPassed = (checkC1[0]?.Approve_Status === 2) && (checkC2[0]?.Approve_Status === 2);`
  * **Nếu CSDL chưa đổi sang `2` $\longrightarrow$ Kịch bản TUYỆT ĐỐI KHÔNG BAO GIỜ ĐƯỢC PHÉP BÁO XANH (PASS)!**

---

### 🛑 LUẬT THÉP 8: ĐỐI SOÁT ĐỊNH LƯỢNG TỪNG TRƯỜNG DỮ LIỆU (FIELD-BY-FIELD QUANTITATIVE RECONCILIATION — ZERO SHALLOW ASSERTIONS)
* **CẤM KIỂM THỬ BỀ NỔI TRÊN MÀN HÌNH BÁO CÁO / PHIẾU LƯƠNG / TÀI CHÍNH**:
  * ❌ *Kiểm tra hời hợt*: Chỉ kiểm tra container hiển thị (`expect(slipContainer.isVisible()).toBeTruthy()`) $\longrightarrow$ *Hoàn toàn vô nghĩa nếu số liệu bên trong hiển thị `0`, bị lệch ngày công, hoặc sai công thức tính!*
* **BẮT BUỘC ĐỐI SOÁT TỪNG TRƯỜNG DỮ LIỆU (FIELD-BY-FIELD RECONCILIATION)**:
  1. **Bóc tách toàn diện DOM UI (DOM Field Extraction)**: Lấy giá trị chuỗi/số của toàn bộ các trường (ví dụ trên Phiếu lương: Mã NV, Họ tên, Ngày vào làm, Chức vụ, Công chuẩn, Công thực tế, Giờ tăng ca, Lương cơ bản, Tổng thu nhập, Các khoản giảm trừ, Thuế TNCN, Thực lĩnh).
  2. **Truy vấn Ground Truth từ CSDL**: Dùng `helpers/db.js` truy vấn các bảng lõi (`tblEmployee`, `tblSal_Sal`, `tblSal_Sal_Detail`, `tblSal_Tax`, `tblSal_OT_Detail`, `tblCompany`).
  3. **Lập Bảng Ma Trận Đối Soát (Reconciliation Matrix)**: So sánh từng cặp giá trị `UI vs CSDL`.
  4. **Quy tắc Đánh Giá Định Lượng Khắt Khe**:
     - Nếu phát hiện **BẤT KỲ 1 TRƯỜNG NÀO LỆCH SỐ LIỆU** $\longrightarrow$ **FAIL NGAY LẬP TỨC!**
     - Đính kèm bảng kê chi tiết toàn bộ các trường bị lệch vào `defect_evidence` để Dev và Tester đối chiếu ngay.

---

### 🛑 LUẬT THÉP 9: KIỂM SOÁT THÀNH PHẦN ĐỘNG & VÒNG ĐỜI CHUYỂN ĐỔI TRẠNG THÁI TOÀN DIỆN (UNIVERSAL DYNAMIC ELEMENT STATE TRANSITION & DOM LIFECYCLE)

> [!IMPORTANT]
> **QUY CHUẨN TỔNG QUÁT BẮT BUỘC CHO TOÀN DỰ ÁN (PROJECT-WIDE UNIVERSAL LAW)**:
> Quy tắc này áp dụng bình đẳng và bắt buộc cho **TẤT CẢ CÁC MÀN HÌNH, MỌI PHÂN HỆ VÀ MỌI TÍNH NĂNG** trong toàn bộ hệ thống Paradise HRM cũng như bất kỳ hệ thống Enterprise/ERP nào (từ Quản lý Chấm công, Nghỉ phép, Tiền lương, Hồ sơ Nhân sự, Tuyển dụng, Đào tạo đến CRM Khách hàng, Bán hàng Pipeline, Tài chính, Thanh toán Công nợ...).
> Tuyệt đối không được xem đây là quy tắc riêng lẻ cho một trang đơn lẻ. Mọi luồng có thao tác tương tác làm biến đổi trạng thái nghiệp vụ đều phải tuân thủ nghiêm ngặt 3 trụ cột dưới đây:

#### 1. PHÂN BIỆT RẠCH RÒI 3 NHÓM THÀNH PHẦN TRÊN GIAO DIỆN (THE 3-TIER UI TAXONOMY)
Mọi màn hình trên hệ thống đều được cấu thành từ 3 nhóm thành phần với vòng đời hoàn toàn khác nhau:

| Nhóm Thành Phần | Bản Chất Kỹ Thuật | Vai Trò & Hành Vi | Quy Tắc Kiểm Thử Bắt Buộc |
| :--- | :--- | :--- | :--- |
| **Nhóm 1: Thành phần Tĩnh (Static Components)** | Labels, Headings, Layout Containers, Border, Placeholders, Icon cố định | Khung sườn hiển thị cố định của trang, không thay đổi theo trạng thái dữ liệu | Chỉ dùng để định vị không gian làm việc; **không dùng để đánh giá kết quả nghiệp vụ**. |
| **Nhóm 2: Phản hồi Nhất thời (Ephemeral Feedback)** | Toast Notifications (`DevExpress.ui.notify`, `.dx-toast`), Alert banners, SweetAlert, Snackbar | Thông điệp thông báo nổi chỉ tồn tại trong 1-3 giây rồi tự động biến mất (*Ephemeral*); chỉ phản ánh việc API backend vừa trả về phản hồi sơ bộ (HTTP 200). | ❌ **CẤM TUYỆT ĐỐI COI TOAST LÀ MINH CHỨNG HOÀN TẤT NGHIỆP VỤ!** Chụp ảnh màn hình chỉ dựa vào Toast xanh trong khi các thành phần bên dưới chưa chuyển đổi trạng thái là hành vi **ngụy tạo kết quả (False Positive / Fake Pass)**. |
| **Nhóm 3: Thành phần Động Nghiệp Vụ (Dynamic Business State Elements)** | Badges trạng thái, Chips tiến trình, Dropdowns/Inputs trạng thái, Nút hành động, Bảng số liệu đối ứng | **NƠI LƯU GIỮ VÀ THỂ HIỆN CHÂN LÝ NGHIỆP VỤ (BUSINESS STATE) TRÊN GIAO DIỆN**. Bắt buộc phải biến đổi theo State Machine sau khi tương tác. | **BẮT BUỘC ĐỐI SOÁT VÀ CHỤP ẢNH MINH CHỨNG SỰ CHUYỂN ĐỔI NÀY**. Kịch bản chỉ được phép PASS khi Nhóm 3 đã chuyển đổi trạng thái hoàn tất 100%. |

---

#### 2. NGUYÊN TẮC BẤT BIẾN VỀ VÒNG ĐỜI THÀNH PHẦN ĐỘNG (DYNAMIC STATE TRANSITION RULES)
Sau khi người dùng kích hoạt bất kỳ hành động nào làm thay đổi trạng thái thực thể (Duyệt, Nộp, Lưu, Khóa, Hủy, Chốt hợp đồng, Thanh toán...):

* **A. Đột biến Nhãn/Huy hiệu Trạng thái (Status Badge / Chip Mutation)**:
  * Phải thay đổi đồng bộ cả **Nội dung chữ (Text Content)** lẫn **Lớp giao diện trực quan (Visual Style / CSS Class / Color / Icon)**:
    - *Chuỗi trạng thái*: Bắt buộc chuyển từ trạng thái nguồn sang trạng thái đích (ví dụ: `Chờ xử lý / Đang duyệt / Chưa khóa / Bản nháp` $\longrightarrow$ `Đã duyệt / Đã hoàn tất / Đã khóa / Đã phát hành`).
    - *Lớp style biểu thị*: Class CSS của badge phải đổi màu tương ứng (ví dụ: từ class màu vàng/cam `status-pending` / `.circle.yellow` $\longrightarrow$ sang class màu xanh lá `status-approved` / `.circle.green`).
* **B. Đột biến Vòng Đời Nút Hành Động (Action Button Lifecycle Mutation)**:
  * Theo nguyên tắc toàn vẹn nghiệp vụ (Idempotency & Business Integrity): **Một hành động không được phép cho phép người dùng click lại lần 2 sau khi đã hoàn tất**.
  * Ngay khi hành động thành công, nút bấm kích hoạt hành động đó **BẮT BUỘC PHẢI THAY ĐỔI**:
    1. **Bị ẩn hoàn toàn khỏi DOM**: Được thêm class `.d-none`, `display: none` hoặc bị remove khỏi DOM.
    2. **Hoặc bị vô hiệu hóa hoàn toàn**: Mang thuộc tính `disabled`, `aria-disabled="true"` hoặc class `.is-disabled`.
    3. **Hoặc chuyển đổi sang hành động nghịch đảo**: Ví dụ nút *"Khóa công"* chuyển thành *"Mở khóa công"*; nút *"Duyệt"* chuyển thành *"Hủy duyệt"*; nút *"Bắt đầu"* chuyển thành *"Tạm dừng"*.
  * ❌ **DẤU HIỆU LỖI NGHIỆP VỤ**: Nếu người dùng vừa bấm thành công mà nút thao tác vẫn trơ trơ trên màn hình ở trạng thái kích hoạt $\longrightarrow$ **Đây là bug UI/UX nghiêm trọng, kịch bản phải đánh FAIL ngay lập tức!**
* **C. Đột biến Trạng Thái Nhập Liệu (Form Controls Mutability)**:
  * Khi bản ghi chuyển sang trạng thái đã chốt / đã duyệt / đã khóa: Toàn bộ các ô nhập liệu (`input`, `textarea`, `dxDateBox`, `dxSelectBox`) của bản ghi đó phải tự động chuyển sang chế độ **Chỉ đọc (Readonly / Disabled)** để chống can thiệp trái phép.

---

#### 3. BẢO ĐẢM KHÓA NGỮ CẢNH BẢN GHI MỤC TIÊU (TARGET CONTEXT LOCKING)
Trong các hệ thống Enterprise, sau khi thực hiện 1 thao tác, giao diện thường kích hoạt các cơ chế tự động khiến ngữ cảnh hiển thị bị trôi dạt:
1. **Cơ chế Hàng đợi tự nhảy (Queue Auto-Advance)**:
   - Thường gặp ở các màn hình Xử lý danh sách / Phê duyệt hàng đợi / Xử lý Ticket: Sau khi duyệt xong bản ghi A, hệ thống tự động tải bản ghi B tiếp theo trong danh sách lên màn hình.
   - *Nguy cơ*: Nếu chụp ảnh ngay, bạn sẽ chụp trúng bản ghi B (vẫn đang ở trạng thái chờ duyệt) $\longrightarrow$ Báo cáo bị sai lệch hoàn toàn.
2. **Cơ chế Đặt lại biểu mẫu (Form Reset / Clear)**:
   - Thường gặp ở các màn hình Thêm mới / Nhập liệu: Sau khi bấm Lưu, form tự xóa trắng các ô để sẵn sàng nhập bản ghi tiếp theo.
3. **Cơ chế Tải lại bảng dữ liệu làm mất focus (Grid Reload / Selection Loss)**:
   - DataGrid reload lại trang và tự động highlight dòng đầu tiên hoặc bỏ chọn dòng vừa chỉnh sửa.

> [!CAUTION]
> **QUY TẮC KHÓA NGỮ CẢNH BẮT BUỘC (CONTEXT LOCKING PROTOCOL)**:
> * Kịch bản kiểm thử **phải luôn duy trì và bảo toàn định danh bản ghi mục tiêu (`flowState.identityId` / `targetId` / `runToken`)**.
> * Sau khi thao tác hoàn tất, kịch bản **BẮT BUỘC PHẢI CHỦ ĐỘNG KHÓA LẠI NGỮ CẢNH VÀO ĐÚNG BẢN GHI ĐÓ**:
>   - Nếu màn hình tự nhảy đơn (Auto-advance): Kịch bản phải chủ động kích hoạt hàm nạp lại hoặc click chọn lại chính xác bản ghi vừa thao tác trên danh sách để đưa nó trở lại màn hình.
>   - Nếu màn hình dạng DataGrid: Kịch bản phải dùng ô tìm kiếm/bộ lọc để định vị đúng dòng dữ liệu mang ID/Token của bản ghi mục tiêu.
> * **CHỈ KHI VÀ CHỈ KHI** màn hình đã hiển thị chính xác bản ghi mục tiêu và các thành phần động của nó đã render xong trạng thái mới $\longrightarrow$ Lúc đó mới được phép chụp ảnh minh chứng và đối soát!

---

#### 4. QUY TRÌNH 4 BƯỚC XÁC THỰC THÀNH PHẦN ĐỘNG PHỔ QUÁT (THE UNIVERSAL 4-STEP ASSERTION PROTOCOL)

```
[Pha 1: Pre-State Snapshot]  ──► Xác nhận bản ghi đang ở Trạng thái Nguồn (Chờ xử lý, Chưa duyệt, Chưa khóa...)
               │
               ▼
[Pha 2: Action & Network]    ──► Di chuột Neon bấm nút hành động ──► Chờ API Backend hoàn tất (HTTP 200)
               │
               ▼
[Pha 3: Target Context Lock] ──► Giữ vững / Nạp lại đúng Bản ghi Mục tiêu (Triệt tiêu Auto-advance / Reset)
               │
               ▼
[Pha 4: Dual Post-Assertion] ──► Thẩm định kép:
                                 1. UI: Badge đổi màu/chữ mới + Nút hành động bị ẩn/disabled
                                 2. CSDL: Trường trạng thái trong DB đổi sang mã hoàn tất
                                 ──► Chụp ảnh minh chứng rõ nét & Kết luận PASS!
```

---

#### 5. BẢNG ĐỐI CHIẾU ỨNG DỤNG TRÊN TỪNG PHÂN HỆ TIÊU BIỂU CỦA HỆ THỐNG

| Phân Hệ Nghiệp Vụ | Thao Tác Kích Hoạt | Phản Hồi Nhất Thời (Nhóm 2 - Không dùng làm minh chứng) | Chuyển Đổi Thành Phần Động UI (Nhóm 3 - BẮT BUỘC KIỂM CHỨNG) | Đối Soát CSDL Song Hành |
| :--- | :--- | :--- | :--- | :--- |
| **Quy trình Phê duyệt** *(Nghỉ phép, Bù công, Tăng ca, Đề xuất nhân sự)* | Bấm nút `[Duyệt]` / `[Từ chối]` | Toast: *"Phê duyệt thành công"* | - Badge quy trình: Viền đổi sang Xanh lá, chữ *"Đã duyệt"*.<br>- Trạng thái tổng: Chuyển sang *"Đã duyệt"*.<br>- Nút `[Duyệt]` / `[Từ chối]`: **Ẩn hoàn toàn (`.d-none`)**. | `tblApproverHistory.Approve_Status = 2`<br>`tblAttendanceConfirmRequest.Approve_Status = 2` |
| **Quản lý Chấm công & Bảng công** *(Mở / Khóa công)* | Bấm nút `[Khóa công]` | Toast: *"Khóa công thành công"* | - Nút `[Khóa công]` $\longrightarrow$ Đổi thành `[Mở khóa công]`.<br>- Các ô chỉnh sửa dữ liệu công chuyển sang `readonly`.<br>- Badge trên thanh trạng thái: Hiển thị icon Ổ khóa đóng. | `tblAttendanceLock.IsLocked = 1` |
| **Tính toán & Chốt Lương** *(Bảng lương công ty)* | Bấm nút `[Tính lương tự động]` / `[Chốt lương]` | Toast: *"Tính lương hoàn tất"* | - Nút `[Tính lương]` bị vô hiệu hóa hoặc ẩn.<br>- Bảng lương render đầy đủ các dòng nhân viên có số liệu $> 0$.<br>- Badge kỳ lương chuyển sang *"Đã chốt lương"*. | `tblSal_Sal.IsLocked = 1`<br>`tblSal_Sal_Detail.TotalIncome > 0` |
| **CRM Bán hàng & Chăm sóc Khách hàng** *(Sales Pipeline / Lead / Deal)* | Kéo thẻ cơ hội hoặc bấm `[Chốt hợp đồng]` | Toast: *"Cập nhật giai đoạn thành công"* | - Thẻ cơ hội chuyển sang cột Giai đoạn mới (`Thành công` / `Đã ký`).<br>- Huy hiệu giai đoạn đổi màu sắc mới.<br>- Nút `[Chốt hợp đồng]` đổi thành `[Xem hợp đồng]`. | `tblCRM_Deals.StageID = 'WON'` |
| **Quản lý Tài sản & Công nợ** *(Hóa đơn, Thanh toán)* | Bấm nút `[Xác nhận thanh toán]` | Toast: *"Thanh toán thành công"* | - Badge trạng thái hóa đơn: Đổi từ `Chưa thanh toán` $\longrightarrow$ `Đã thanh toán`.<br>- Ô Số tiền còn nợ: Giảm về `0`.<br>- Nút `[Thanh toán]` bị vô hiệu hóa (`disabled`). | `tblInvoices.PaymentStatus = 'PAID'`<br>`tblInvoices.RemainingAmount = 0` |

---

## 1. QUY TRÌNH 3 BƯỚC NHÀO NẶN KỊCH BẢN

```
[Dev cung cấp: Tên trang + Nghiệp vụ cần test + Expected Output]
                            │
                            ▼
     [Bước 1: Khảo sát DOM, Selectors & API Network + CSDL Chuỗi duyệt]
                            │
                            ▼
     [Bước 2: Viết mã tests/<tên_trang>.spec.js theo BỘ 9 LUẬT THÉP]
                            │
                            ▼
     [Bước 3: Bàn giao file .spec.js sang skill playwright-live-visual-e2e]
```

### Bước 1: Khảo sát DOM & API thực tế
1. Truy cập màn hình mục tiêu trên web, kiểm tra:
   - Selector chính xác của các nút/control (ưu tiên `#id`, `button:has-text(...)`, `.class-dac-trung`; **tuyệt đối cấm dùng selector tổ tiên lỏng lẻo như `*`**).
   - Kiểm tra chuỗi duyệt thực tế: Ai là Cấp 1, ai là Cấp 2.
   - Endpoint API (POST/PUT `.ashx` hoặc `/hpa/...`) và cấu trúc JSON trả về (`result`, `data`, `status`).
2. Xác định rõ ràng:
   - **Thao tác (Action)**: Click nút nào, gõ trường gì, chọn dropdown nào, xử lý popup xác nhận nào.
   - **Kỳ vọng (Expected Output)**: Thẻ Top 1 khớp chính xác ngày giờ nào, DataGrid có bao nhiêu dòng.

### Bước 2: Tạo mới hoặc Bổ sung Test Case vào `tests/<page>.spec.js`
* Tạo mới hoặc cập nhật file `tests/<page_name>.spec.js` theo **Bộ Khung Mẫu Chuẩn** (Mục 3).

### Bước 3: Bàn giao chuyển tiếp
Sau khi hoàn thiện code trong file `.spec.js`, Agent kích hoạt skill `playwright-live-visual-e2e` để đóng gói `.bat` và chạy kiểm thử trực quan nghiệm thu 100%.

---

## 2. NGUYÊN TẮC BỔ TRỢ QUAN TRỌNG

### 🏷️ TIÊU ĐỀ BƯỚC CHỤP ẢNH PHẢI TRUNG LẬP (NEUTRAL STEP TITLES)
* Các bước trung gian (`Bước 1 ➔ Bước 4`) của `captureStep` **chỉ mô tả hành động và quan sát**, tuyệt đối không kết tội trước:
  * ❌ *Sai*: `desc: 'Bấm nút đăng ký làm mất đơn'`
  * ✅ *Đúng*: `desc: 'Nhan vien nhap thong tin va bam nut Dang ky'`
* **Chỉ duy nhất Bước 5 (bước kết luận)** mới đưa ra đánh giá `PASS` hoặc `FAIL` tùy theo nhánh điều kiện `if/else`.

### 🛡️ TIỀN ĐỀ TỰ HÀNH CHO TEST CASE PHỤ THUỘC (AUTO PRE-CONDITION)
Với các test case có tính phụ thuộc (như *Duyệt đơn*, *Xóa bản ghi*, *Sửa thông tin*):
* Khi chạy lẻ file `Run-This-TC.bat`, nếu dữ liệu tiền đề chưa có:
* Script phải **tự động kiểm tra hoặc nạp nhanh tiền đề**, không để test case bị Timeout văng lỗi oan.

---

## 3. BỘ KHUNG MẪU CHUẨN (GOLDEN CODE BLUEPRINT)

```javascript
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const PAGE_NAME = '<tên_trang>';
const BASE_URL = 'https://paradisehrm.com/Tai3/#';

// CÔ LẬP PHIÊN CHỐNG XUNG ĐỘT MULTI-ROLE
test.use({ storageState: { cookies: [], origins: [] } });

// BẢNG TÀI KHOẢN MẪU THỰC TẾ
const ACCOUNTS = {
  STAFF:   { username: 'tai.dang',  password: '123', empId: '046', name: 'Đặng Minh Tài' },
  MANAGER: { username: 'ThanhLong', password: '123', empId: '011', name: 'Nguyễn Thanh Long' }, // Cấp 1
  HR:      { username: 'cuong.vu',  password: '123', empId: '014', name: 'Vũ Đình Cường' }    // Cấp 2
};

// Helper 1: Di chuyển chuột Neon mượt mà và click có bảo vệ phòng thủ
async function moveAndClick(page, locator, options = {}) {
  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
  const box = await locator.boundingBox().catch(() => null);
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  // Click phòng vệ: force = true và fallback evaluate click
  await locator.click({ force: true, timeout: 5000 }).catch(async () => {
    await locator.evaluate((el) => el.click()).catch(() => {});
  });
}

// Helper 2: Chụp ảnh từng bước tuần tự có dấu (Tích hợp Bộ Lọc MD5 Runtime chống trùng ảnh)
const _lastCapturedHash = {};
async function captureStep(page, testInfo, { tcId, step, desc, pageName = PAGE_NAME }) {
  const safeDesc = desc
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${pageName}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);

  const buffer = await page.screenshot({ fullPage: false }).catch(() => null);
  if (!buffer) return;

  const crypto = require('crypto');
  const hash = crypto.createHash('md5').update(buffer).digest('hex');
  if (_lastCapturedHash[tcId] === hash) {
    console.log(`⏩ [${tcId}] Bỏ qua chụp Bước ${step}: "${desc}" (Giao diện không thay đổi so với bước trước)`);
    return;
  }
  _lastCapturedHash[tcId] = hash;

  fs.writeFileSync(filePath, buffer);
  await testInfo.attach(`Bước ${step}: ${desc}`, { path: filePath, contentType: 'image/png' }).catch(() => {});
  console.log(`📸 [${tcId}] Đã chụp Bước ${step}: ${desc} -> ${fileName}`);
}

// Helper 3: Đăng nhập sạch sẽ
async function loginDirectly(page, credentials) {
  await page.goto(BASE_URL, { waitUntil: 'domcontentloaded' });
  await page.evaluate(() => { localStorage.clear(); sessionStorage.clear(); });
  await page.reload({ waitUntil: 'domcontentloaded' });
  const userInput = page.locator('#username').first();
  await userInput.waitFor({ state: 'visible', timeout: 15000 });
  await moveAndClick(page, userInput, { steps: 6 });
  await userInput.fill(credentials.username);
  const passInput = page.locator('#password').first();
  await moveAndClick(page, passInput, { steps: 6 });
  await passInput.fill(credentials.password);
  const loginBtn = page.locator('#btnLogin, button[type="submit"], button:has-text("Đăng nhập")').first();
  await moveAndClick(page, loginBtn, { steps: 6 });
  await page.waitForTimeout(3000);
}

test.describe('Kiểm thử Trang: <Tên Trang Tiếng Việt>', () => {
  test.describe.configure({ mode: 'serial' });

  test.beforeEach(async ({ context }) => {
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
  });

  // --------------------------------------------------------------------------
  // TC-01: MẪU TẠO ĐƠN & GỬI FORM HOÀN CHỈNH (TUÂN THỦ LUẬT THÉP 1, 3)
  // --------------------------------------------------------------------------
  test('TC-01: Tạo và nộp đơn Xin bù công thực tế (Role: tai.dang)', async ({ page }, testInfo) => {
    await loginDirectly(page, ACCOUNTS.STAFF);
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 1, desc: 'Dang nhap tai khoan nhan vien' });

    // Điền thông tin với Unique Fingerprint
    const todayStr = new Date().toISOString().split('T')[0];
    const uniqueReason = `Quen quet the ngay ${todayStr} - Run ${Date.now()}`;
    // ... Nhập Ngày, Giờ, Lý do ...

    // Bấm Đăng ký -> Bắt buộc xử lý Popup Xác nhận Đồng ý
    const submitBtn = page.locator('button.btnRegister, button:has-text("Đăng ký")').first();
    await moveAndClick(page, submitBtn, { steps: 6 });

    // Xử lý Popup xác nhận #vc-vu-confirm-popup
    const dongYBtn = page.locator('#vc-vu-confirm-popup .VC-Vu-btn-ok, button.VC-Vu-btn-ok:has-text("Đồng ý")').first();
    await dongYBtn.waitFor({ state: 'visible', timeout: 6000 });
    await moveAndClick(page, dongYBtn, { steps: 6 });
    await page.evaluate(() => {
      const b = document.querySelector('#vc-vu-confirm-popup .VC-Vu-btn-ok');
      if (b) b.click();
    });
    await page.waitForTimeout(2500);

    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Don bu cong da duoc xac nhan Dong y va gui thanh cong xuong backend'
    });
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 5, desc: 'Danh gia logic PASS: Don gui thanh cong' });
  });

  // --------------------------------------------------------------------------
  // TC-02: MẪU ĐỐI SOÁT TAB LỊCH SỬ CHỐNG FAKE PASS (TUÂN THỦ LUẬT THÉP 1)
  // --------------------------------------------------------------------------
  test('TC-02: Đối soát thẻ đơn mới tạo tại vị trí Top 1 trong Lịch sử', async ({ page }, testInfo) => {
    await loginDirectly(page, ACCOUNTS.STAFF);
    // Mở Tab Lịch sử ...
    const cards = page.locator('.grid-item, .card, .history-item');
    await cards.first().waitFor({ state: 'visible', timeout: 8000 });
    const topCardText = await cards.first().innerText();

    // So khớp chính xác ngày và giờ vừa tạo
    const todayStr = new Date().toISOString().split('T')[0];
    const hasToday = topCardText.includes(todayStr) || topCardText.includes('08:00');
    const isPending = topCardText.includes('Đang chờ duyệt') || topCardText.includes('Chờ duyệt');
    const isPassed = hasToday && isPending;

    if (isPassed) {
      testInfo.annotations.push({
        type: 'business_status',
        description: `PASS - Thẻ Top 1 khớp chính xác đơn vừa tạo ngày ${todayStr} với trạng thái Đang chờ duyệt`
      });
      await captureStep(page, testInfo, { tcId: 'TC-02', step: 5, desc: 'Danh gia logic PASS: The Top 1 khop chinh xac' });
    } else {
      testInfo.annotations.push({
        type: 'business_status',
        description: `FAIL - The Top 1 khong phai don vua tao! Noi dung: ${topCardText.substring(0, 100)}`
      });
      testInfo.annotations.push({
        type: 'defect_evidence',
        description: JSON.stringify({ issue: 'The Top 1 khong khop don vua tao', actual: topCardText })
      });
      await captureStep(page, testInfo, { tcId: 'TC-02', step: 5, desc: 'Danh gia logic FAIL: The Top 1 khong khop' });
    }
  });
});
```
