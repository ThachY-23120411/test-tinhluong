# HƯỚNG DẪN KIỂM THỬ TỰ ĐỘNG & BẰNG CHỨNG NGHIỆM THU (TEST EVIDENCE)

## 1. Cơ chế tự động chạy theo hệ thống hiện tại

Mỗi khi bạn mở bất kỳ file `.bat` nào:
* 🎯 **`Run-This-TC.bat`** (trong `test-evidence/<tên_trang>/<TC-0x>/`): Chạy lại riêng 1 kịch bản cụ thể.
* 📄 **`Run-This-Page.bat`** (trong `test-evidence/<tên_trang>/`): Chạy lại toàn bộ kịch bản của trang đó.
* 🖥️ **`Run-ParadiseHR-Interactive.bat`** (ngoài Desktop / thư mục gốc): Menu tổng để chọn chạy bất kỳ trang nào.

**Hệ thống sẽ tự động thực hiện hoàn toàn mới:**
1. **Mở trình duyệt Google Chrome thật** và truy cập thẳng vào trang web hiện tại (theo URL trong `test.env.json`).
2. **Quay một Video `.webm` MỚI TOANH** ghi lại toàn bộ chuyển động con trỏ chuột Neon và hành động trên giao diện mới nhất.
3. **Chụp các ảnh Screenshot MỚI** để lưu vết màn hình tại thời điểm chạy.
4. **Cập nhật lại Báo cáo `test-report.md` và `results.json`**:
   - Ghi nhận chính xác ngày giờ vừa chạy (`timestamp`).
   - Nếu hệ thống chạy tốt $\rightarrow$ Đánh dấu **✅ PASS**.
   - Nếu hệ thống vừa sửa phát sinh lỗi (bug) $\rightarrow$ Đánh dấu **❌ FAIL**, trích xuất ảnh lỗi và log lỗi chi tiết vào báo cáo để bạn gửi cho team dev sửa ngay!

---

## 2. Hai trường hợp khi hệ thống thay đổi

* **Trường hợp 1 (Sửa backend/logic, UI giữ nguyên)**:
  👉 Bạn chỉ việc chạy file `.bat`. Không cần sửa bất kỳ dòng mã test nào, kết quả, ảnh chụp và video mới sẽ tự động cập nhật phản ánh đúng trạng thái hệ thống hiện tại.
* **Trường hợp 2 (Giao diện đổi lớn: đổi tên nút, đổi luồng, đổi vị trí menu)**:
  👉 Bạn chỉ cần nhắn AI một câu: *"Hệ thống vừa đổi menu X thành Y / đổi quy trình duyệt, hãy cập nhật lại kịch bản test"*. AI sẽ mở trình duyệt dò lại và cập nhật kịch bản `.spec.js`. Sau đó file `.bat` của bạn vẫn tiếp tục sử dụng bình thường mà không cần làm lại từ đầu!

---

## 3. Chuẩn Báo Cáo Kép (Dual Status: Trạng Thái Test & Trạng Thái Logic Nghiệp Vụ)

Mỗi kịch bản test đều được phân định rạch ròi 2 trạng thái:
* **Trạng thái thực thi Test (Kỹ thuật)**: `✅ PASS` nếu script Playwright chạy thông suốt, không crash code; `❌ FAIL` nếu script bị lỗi cú pháp/timeout.
* **Trạng thái Logic Nghiệp vụ (Business Output)**: `✅ PASS` nếu dữ liệu thực tế (Actual Output) khớp với mong đợi (Expected Output); `❌ FAIL` nếu phát hiện **Lỗi phần mềm / Bug logic** (ví dụ: Duyệt thành công nhưng giao diện không cập nhật).

