---
name: refactor-screenshot-report
description: Quy chuẩn chuyên nghiệp để tái cấu trúc và chuẩn hóa toàn bộ báo cáo kỹ thuật (fix-report.md) hợp nhất theo từng Menu (fix-bug/<tên_menu>/) thay vì xé lẻ theo từng Screenshot. Gom origin.sql, fix-bug.sql và fix-report.md xài chung cho toàn trang; mỗi TC gồm 4 mục chuẩn: 1. Hiện trạng ban đầu, 2. RCA Câu 28, 3. Đối chiếu Before vs After, 4. Minh chứng sau khi sửa.
---

# KỸ NĂNG: REFACTOR BÁO CÁO KỸ THUẬT HỢP NHẤT THEO TRANG / MENU (`fix-bug/<tên_menu>/`)

Mỗi thư mục `fix-bug/<tên_menu>/` là một gói giải trình cấp Menu/Trang hoàn chỉnh bàn giao cho Sếp hoặc Khách hàng. Kỹ năng này chuẩn hóa 100% cấu trúc của file `fix-report.md` và mã nguồn bản vá xài chung cho toàn bộ các Test Case trên trang, đảm bảo tính nhất quán, minh chứng trực quan đầy đủ trước và sau, và sửa lỗi tại một nơi duy nhất.

---

## 🛑 NGUYÊN TẮC CỐT LÕI BẤT BIẾN

1. **GOM VỀ CẤP MENU — BỎ HẲN CẤU TRÚC `SCREENSHOT-XX`**:
   - Một Stored Procedure đại diện cho toàn bộ màn hình/trang.
   - Bỏ việc chia thư mục con theo `screenshot-xx` hoặc `TC-xx`.
   - Toàn bộ kết quả sửa lỗi của trang nằm trực tiếp tại `fix-bug/<tên_menu>/`:
     * `origin.sql` (bản gốc xài chung)
     * `fix-bug.sql` (bản vá tổng hợp xài chung)
     * `fix-report.md` (báo cáo tổng hợp xài chung, phân đoạn rõ theo từng TC)
     * `screenshot/` (ảnh before/after của từng TC)

2. **QUY TẮC ĐƯỜNG DẪN HÌNH ẢNH TƯƠNG ĐỐI (100% PORTABLE)**:
   - Toàn bộ ảnh minh chứng lỗi (`TC-01-before.png`, `TC-01-after.png`...) **PHẢI** nằm trong thư mục con `screenshot/` ngay cạnh `fix-report.md`.
   - Cú pháp nhúng ảnh trong Markdown **bắt buộc dùng đường dẫn tương đối**:
     ```markdown
     ![Mô tả ảnh](screenshot/TC-01-before.png)
     ```
   - **TUYỆT ĐỐI KHÔNG** dùng link tuyệt đối kiểu `file:///C:/Users/...`, không dùng đường dẫn ổ đĩa `C:\...`, và **TUYỆT ĐỐI KHÔNG** dùng Base64 inline làm phình file Markdown. Khi copy toàn bộ thư mục sang bất kỳ máy tính nào khác hoặc mở trên GitHub / VS Code / Obsidian, ảnh đều phải hiển thị tức thì.

3. **LOẠI BỎ HOÀN TOÀN MỤC HƯỚNG DẪN THỰC THI / NGHIỆM THU (NO VERIFICATION GUIDE)**:
   - **KHÔNG ĐƯA** mục `QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)` vào báo cáo.
   - Báo cáo tập trung 100% vào chuyên môn kỹ thuật: Hiện trạng lỗi $\rightarrow$ Nguyên nhân gốc rễ $\rightarrow$ Đối chiếu mã nguồn & Kết quả thực tế sau khi fix.

4. **BẮT BUỘC CÓ ẢNH KẾT QUẢ THỰC TẾ SAU KHI SỬA (AFTER FIX SCREENSHOT)**:
   - Mỗi Test Case bắt buộc phải có đầy đủ:
     - Ảnh hiện trạng lỗi ban đầu (Before): `screenshot/TC-xx-before.png` (hoặc `screenshot/before.png`)
     - Ảnh kết quả giao diện thực tế sau khi fix (After): `screenshot/TC-xx-after.png` (hoặc `screenshot/after.png`)

5. **CAM KẾT AN TOÀN DATABASE (DATABASE INTEGRITY & SAFETY)**:
   - Tuyệt đối không tự ý thực thi các lệnh làm thay đổi DB (`ALTER`, `UPDATE`, `INSERT`, `DELETE`, `DROP`). Mọi phân tích chỉ thực hiện qua chế độ `READ-ONLY`.

---

## 📋 FORMAT CHUẨN CỦA FILE `fix-report.md`

Mỗi file `fix-report.md` phải tuân thủ nghiêm ngặt 3 phần lớn sau:

```markdown
# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-<N>: <TÊN MENU HOẶC TÊN TÍNH NĂNG> (<MÃ MENU>)

> **Màn hình**: <Tên màn hình>
> **MenuID**: `Mnu...` | **ClassName**: `...`
> **File SQL bản vá độc lập**: [`fix-bug/screenshot-<N>/patch_<tên>.sql`](./patch_<tên>.sql)
> **Ảnh đối chiếu lỗi ban đầu (Before)**: [`./screenshots/<N>.png`](./screenshots/<N>.png)
> **Ảnh kết quả sau khi sửa (After Fix)**: [`./screenshots/<N>_fixed.png`](./screenshots/<N>_fixed.png)

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng lỗi**: Mô tả chi tiết hành vi sai khác trên giao diện.
- **Minh chứng hình ảnh trực quan (Before)**:
  ![Ảnh lỗi ban đầu](./screenshots/<N>.png)
  *Minh chứng lỗi Screenshot <N>: <Mô tả chi tiết vị trí bị lỗi>*

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- Phân tích bản chất kỹ thuật: CSS (thuộc tính gây lỗi), DOM (cây phân cấp), JavaScript (logic nạp), Stored Procedure / API.
- Bóc tách cấu trúc hoặc mô hình khung bao bọc (nếu có).

---

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)

#### 3.1. Đối chiếu chi tiết mã nguồn
##### ❌ HỆ THỐNG BAN ĐẦU (BEFORE):
```sql / css / javascript
-- Code cũ gây lỗi
```

##### ✅ BẢN VÁ HOÀN THIỆN (AFTER):
```sql / css / javascript
-- Code mới đã chuẩn hóa
```

#### 3.2. Minh chứng kết quả giao diện thực tế sau khi sửa (After Fix)
![Ảnh kết quả sau khi sửa](./screenshots/<N>_fixed.png)
*Minh chứng giao diện thực tế sau khi áp dụng bản vá thành công: Giao diện hiển thị chuẩn xác, không còn lỗi.*
```
