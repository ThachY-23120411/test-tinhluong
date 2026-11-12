# BÁO CÁO KIỂM THỬ TRANG: CRM_MARKETING_PRODUCT

> Thời gian kiểm thử: **15:02:25 28/10/2026**
> Tổng số kịch bản: **7** | ✅ LOGIC PASS: **0** | ❌ LOGIC FAIL: **7**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Kiểm tra Màu Chữ và Màu Nền Ô Tìm Kiếm (Search Filter Box) trên Thanh Công Cụ DataGrid Sản Phẩm Marketing | ❌ FAIL | ❌ FAIL | Error: worker process exited unexpectedly (code=3221225477, signal=null) |
| **TC-02** | Kiểm tra Khởi Động, Tải Giao Diện và Đối Soát Danh Sách Sản Phẩm với CSDL | ❌ FAIL | ❌ FAIL | TimeoutError: locator.waitFor: Timeout 20000ms exceeded.
Call log:
[2m  - waiting for locator('#sp_CRM_marketing_product_html:visible, .dx-datagrid:visible').first() to be visible[22m
 |
| **TC-03** | Kiểm tra Vòng Đời 3 Pha Bộ Lọc Tìm Kiếm Nhanh (Full 3-Phase Search Filter Lifecycle) | ❌ FAIL | ❌ FAIL | Lỗi thực thi trong quá trình test |
| **TC-04** | Thẩm Định Hộp Thoại Thêm Mới Sản Phẩm Marketing (Form Validation & Nút Hủy) | ❌ FAIL | ❌ FAIL | Lỗi thực thi trong quá trình test |
| **TC-05** | Kiểm Tra Chức Năng Nghiệp Vụ: XEM CHI TIẾT SẢN PHẨM MARKETING (View Detail Modal) | ❌ FAIL | ❌ FAIL | Lỗi thực thi trong quá trình test |
| **TC-06** | Kiểm Tra Quy Trình Nghiệp Vụ CRUD: THÊM MỚI SẢN PHẨM THỰC TẾ & DỌN DẸP DỮ LIỆU | ❌ FAIL | ❌ FAIL | Lỗi thực thi trong quá trình test |
| **TC-07** | Kiểm Tra Hiệu Ứng Gợn Sóng: Đối Soát Liên Màn Hình Sang Phân Hệ Zalo Gửi Tin Nhắn Tự Động | ❌ FAIL | ❌ FAIL | Lỗi thực thi trong quá trình test |

---

### TC-01: Kiểm tra Màu Chữ và Màu Nền Ô Tìm Kiếm (Search Filter Box) trên Thanh Công Cụ DataGrid Sản Phẩm Marketing

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Error: worker process exited unexpectedly (code=3221225477, signal=null)
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-01/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Error: worker process exited unexpectedly (code=3221225477, signal=null)
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):
```
Error: worker process exited unexpectedly (code=3221225477, signal=null)
```

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

### TC-02: Kiểm tra Khởi Động, Tải Giao Diện và Đối Soát Danh Sách Sản Phẩm với CSDL

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `57.39s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: TimeoutError: locator.waitFor: Timeout 20000ms exceeded.
Call log:
[2m  - waiting for locator('#sp_CRM_marketing_product_html:visible, .dx-datagrid:visible').first() to be visible[22m

* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-02/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: TimeoutError: locator.waitFor: Timeout 20000ms exceeded.
Call log:
[2m  - waiting for locator('#sp_CRM_marketing_product_html:visible, .dx-datagrid:visible').first() to be visible[22m

> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):
```
TimeoutError: locator.waitFor: Timeout 20000ms exceeded.
Call log:
[2m  - waiting for locator('#sp_CRM_marketing_product_html:visible, .dx-datagrid:visible').first() to be visible[22m

```

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_marketing_product/TC-02/traces/trace.zip`)*

---

### TC-03: Kiểm tra Vòng Đời 3 Pha Bộ Lọc Tìm Kiếm Nhanh (Full 3-Phase Search Filter Lifecycle)

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Lỗi thực thi trong quá trình test
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-03/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Lỗi thực thi trong quá trình test
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

### TC-04: Thẩm Định Hộp Thoại Thêm Mới Sản Phẩm Marketing (Form Validation & Nút Hủy)

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Lỗi thực thi trong quá trình test
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-04/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Lỗi thực thi trong quá trình test
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

### TC-05: Kiểm Tra Chức Năng Nghiệp Vụ: XEM CHI TIẾT SẢN PHẨM MARKETING (View Detail Modal)

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Lỗi thực thi trong quá trình test
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-05/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Lỗi thực thi trong quá trình test
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

### TC-06: Kiểm Tra Quy Trình Nghiệp Vụ CRUD: THÊM MỚI SẢN PHẨM THỰC TẾ & DỌN DẸP DỮ LIỆU

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Lỗi thực thi trong quá trình test
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-06/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Lỗi thực thi trong quá trình test
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

### TC-07: Kiểm Tra Hiệu Ứng Gợn Sóng: Đối Soát Liên Màn Hình Sang Phân Hệ Zalo Gửi Tin Nhắn Tự Động

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `0.00s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Lỗi thực thi trong quá trình test
* **Thư mục lưu trữ**: `test-evidence/crm_marketing_product/TC-07/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Lỗi thực thi trong quá trình test
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

