# THƯ VIỆN BẪY LỖI NGHIỆP VỤ & TRƯỜNG HỢP BIÊN (EDGE CASES REFERENCE)

Dành cho Agent khi nhào nặn kịch bản `.spec.js` với skill `author-playwright-spec`. Mọi mẫu kiểm tra bắt buộc phải áp dụng **Đánh giá động `if / else`**, tuyệt đối không gán cứng `FAIL`.

---

## 1. NHÓM BẪY LỖI BỘ LỌC & TÌM KIẾM (FILTER & SEARCH TRAPS)

### `EDGE-FLT-01`: Bẫy Mất Dữ Liệu Khi Khôi Phục Trạng Thái (Lost-Data Re-click Trap)
* **Hiện tượng**: Bấm lọc con (Lead) $\rightarrow$ Bấm lại "Tất cả" lần 2. Frontend không khôi phục `isViewAll=1` hoặc ép ngầm khoảng ngày tuần hiện tại làm mất dữ liệu lịch sử.
* **Mẫu kiểm tra Playwright**:
```javascript
const n0 = await page.locator('.dx-data-row').count();
await moveAndClick(page, childPill);
await page.waitForTimeout(1000);
await moveAndClick(page, allPill);
await page.waitForTimeout(1500);
const nRestore = await page.locator('.dx-data-row').count();

const isRestored = (nRestore === n0);
if (isRestored) {
  testInfo.annotations.push({ type: 'business_status', description: `PASS - Khôi phục đủ ${nRestore}/${n0} bản ghi` });
} else {
  testInfo.annotations.push({ type: 'business_status', description: `FAIL - Mất dữ liệu: Chỉ khôi phục ${nRestore}/${n0} dòng` });
  testInfo.annotations.push({ type: 'defect_evidence', description: JSON.stringify({ issue: 'Mất dữ liệu khi chọn lại Tất cả', expected: n0, actual: nRestore, lost: n0 - nRestore }) });
}
```

### `EDGE-FLT-02`: Bẫy Khoảng Ngày Mặc Định Ngầm (Hidden Default Date Boundary)
* **Hiện tượng**: Hệ thống ngầm định lấy ngày theo "Tuần này" hoặc "Tháng này" mà không thông báo, làm biến mất các dữ liệu lịch sử.
* **Kiểm tra**: Chặn API query và kiểm tra xem `@FromDate` có bị ép ngầm khi người dùng KHÔNG hề chọn lọc ngày hay không.

### `EDGE-FLT-03`: Bẫy Ký Tự Đặc Biệt Trong Ô Tìm Kiếm (Special Characters & SQLi)
* **Hiện tượng**: Gõ ký tự `'`, `"`, `\`, `%`, `_`, `--` khiến SP văng lỗi SQL hoặc crash giao diện.
* **Mẫu kiểm tra**: Nhập `' OR '1'='1` $\rightarrow$ Assert bảng hiển thị Empty state an toàn, không văng lỗi alert đỏ.

### `EDGE-FLT-04`: Bẫy Khoảng Trắng 2 Đầu Từ Khóa (Leading / Trailing Whitespace)
* **Hiện tượng**: Copy từ khóa kèm khoảng trắng `" Nguyen Van A "`. Hệ thống không `trim()` làm kết quả rỗng.
* **Mẫu kiểm tra**: Đọc text dòng 1 $\rightarrow$ Gõ kèm khoảng trắng `  ${text}  ` $\rightarrow$ Assert vẫn tìm ra dòng đó.

---

## 2. NHÓM BẪY LỖI FORM & NHẬP LIỆU (INPUT & FORM TRAPS)

### `EDGE-INP-01`: Bẫy Bấm Nhanh Liên Tiếp Nút Lưu (Double Submit / Duplicate Trap)
* **Hiện tượng**: Click liên tiếp vào nút Lưu tạo ra nhiều bản ghi trùng lặp.
* **Mẫu kiểm tra**: Click nút Lưu $\rightarrow$ Assert nút lập tức disabled hoặc có icon loading spinner.

### `EDGE-INP-02`: Bẫy Xóa Dữ Liệu Bắt Buộc Khi Sửa (Required Field Bypass on Update)
* **Hiện tượng**: Mở modal sửa $\rightarrow$ Xóa trắng trường bắt buộc (Tên, Mã) $\rightarrow$ Bấm Lưu.
* **Mẫu kiểm tra**: Assert hệ thống phải hiển thị tooltip/cảnh báo validate đỏ và chặn gọi API Lưu.

### `EDGE-INP-03`: Bẫy Thoát Không Lưu Không Cảnh Báo (Unsaved Changes / Dirty Form Exit)
* **Hiện tượng**: Đã sửa nhiều trường quan trọng $\rightarrow$ Lỡ tay bấm phím `Esc` hoặc bấm `Hủy` làm mất dữ liệu.
* **Mẫu kiểm tra**: Nhập dữ liệu mới $\rightarrow$ Bấm Hủy/Escape $\rightarrow$ Assert xuất hiện confirm dialog: *"Dữ liệu chưa được lưu, bạn có chắc muốn thoát?"*.

---

## 3. NHÓM BẪY LỖI BẢNG DỮ LIỆU & THAO TÁC (DATAGRID TRAPS)

### `EDGE-GRD-01`: Bẫy Mã HTTP 200 Che Giấu Lỗi Backend (HTTP 200 Masking)
* **Hiện tượng**: Server IIS luôn trả về HTTP 200 OK ngay cả khi SQL văng Exception hoặc trả về kết quả rỗng `data: [[]]`.
* **Mẫu kiểm tra**: Chặn response API $\rightarrow$ Bóc tách sâu vào body JSON: `expect(json.result).not.toContain('error')`.

### `EDGE-GRD-02`: Bẫy Xóa Ngay Lập Tức Không Qua Xác Nhận (Accidental Instant Delete)
* **Hiện tượng**: Bấm icon Thùng rác $\rightarrow$ Xóa luôn mà không hỏi lại.
* **Mẫu kiểm tra**: Click icon Xóa $\rightarrow$ Bắt buộc assert có modal xác nhận "Bạn có chắc muốn xóa bản ghi này?".
