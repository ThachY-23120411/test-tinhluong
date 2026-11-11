---
name: f
description: >-
  Phím tắt siêu tốc (/f): Phân tích bóc tách phân khu mã nguồn lỗi (HTML, <style>, 5 phân khu <script> theo Câu 28 tài liệu HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md), giải thích sửa như thế nào, tại sao, và lập/bổ sung báo cáo fix-report.md chia làm 2 phần (Phần 1: Automation TC, Phần 2: Screenshot từ Screenshots_1_bug). Mã nguồn sửa được gom chung vào 1 file fix-bug.sql duy nhất cho toàn menu theo chuẩn 3 bước Clean Code. Không bắt buộc cả 2 phần phải có nội dung nếu chỉ có 1 nguồn lỗi.
---

# KỸ NĂNG: BÓC TÁCH PHÂN KHU CODE LỖI & XUẤT FIX-REPORT.MD (`/f`)

Khi người dùng kích hoạt lệnh `/f` hoặc yêu cầu phân tích mã lỗi:

1. **Phân loại nguồn bug**:
   - **Bug từ Automation Test**: Nằm trong `test-evidence/<tên_menu>/TC-xx`, định danh `TC-xx`.
   - **Bug từ Test thủ công**: Ảnh chụp lưu tại `C:\Users\Y.Thach\Desktop\paradiseHR\Screenshots_1_bug`, định danh theo `Screenshot xx`.

2. **Xác định rõ từng đoạn code bị lỗi nằm ở phân khu nào**:
   - Nằm ở HTML tĩnh? Thẻ `<style>`? Hay thẻ `<script>`?
   - Nếu là thẻ `<script>`, đối chiếu chuẩn **Câu 28** trong tài liệu `docs/HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md` để chỉ rõ phân khu:
     * `1️⃣ Phân khu 1: Khai báo Biến & Trạng thái (Variables & States)`
     * `2️⃣ Phân khu 2: Khởi tạo Widget giao diện (Widget Initialization)`
     * `3️⃣ Phân khu 3: Khai báo & Định nghĩa Hàm nghiệp vụ (Function Definitions)`
     * `4️⃣ Phân khu 4: Đăng ký Sự kiện người dùng (Event Listeners Binding)`
     * `5️⃣ Phân khu 5: Thực thi Khởi động (Bootstrap / Trigger Execution)`
   - Nêu rõ: **Bạn sửa nó như thế nào? Tại sao phải sửa như vậy?** (Kèm sơ đồ Mermaid luồng lỗi).

3. **Tự động đóng gói kết quả vào thư mục chuẩn cấp Menu `fix-bug/<tên_menu>/`**:
   - **`origin.sql`**: Giữ nguyên mã nguồn gốc từ DB.
   - **`fix-bug.sql`**: Gom chung tất cả các bản sửa của cả TC và Screenshot vào 1 file duy nhất theo chuẩn 3 bước Clean Code (không dùng REPLACE).
   - **`fix-report.md`**: Cập nhật/bổ sung vào file báo cáo duy nhất của menu, chia rõ làm 2 Phần:
     * **Phần 1**: Các lỗi từ Automation Test (`TC-01`, `TC-02`...). Nếu chưa chạy Playwright test hoặc không có lỗi TC, **bắt buộc để trống** `*(Chưa có kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*`. Tuyệt đối không tự bịa đặt nội dung!
     * **Phần 2**: Các lỗi từ Screenshot thủ công (`Screenshot 25`, `Screenshot 26`...). Nếu không có lỗi Screenshot thì để trống.
   - **Format từng mục trong cả 2 phần là Y CHANG NHAU** (đều đủ 4 mục chuẩn: 1. Hiện trạng ban đầu, 2. RCA Câu 28, 3. Đối chiếu Before vs After, 4. Minh chứng sau khi sửa).
   - **`screenshot/`**: Lưu ảnh tương ứng: `TC-xx-before.png`, `TC-xx-after.png`, `screenshot-xx-before.png`, `screenshot-xx-after.png`. *(LƯU Ý BẤT BIẾN: Ảnh After Fix CHỈ ĐƯỢC CHỤP bằng Playwright và nhúng vào Mục 4 khi Người Dùng chat thông báo đã exec trên DB; khi chưa exec thì Mục 4 bắt buộc để trạng thái chờ: `*(Đang chờ Người Dùng Execute file fix-bug.sql trên SSMS và xác nhận cập nhật)*`)*.
