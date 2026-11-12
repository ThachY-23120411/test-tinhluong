-- =========================================================================================
-- FILE: scripts/seed_attendance_5days_nv099.sql
-- MỤC ĐÍCH: SEED DỮ LIỆU CHẤM CÔNG THÁNG 10/2026 CHO NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
--           CÔNG TY LÀM VIỆC HÀNH CHÍNH CHUẨN: 08:00 - 17:00 (Nghỉ trưa 12:00 - 13:00 = 8.0h/ngày)
--
-- QUY TẮC SEED DỮ LIỆU KỲ CÔNG THÁNG 10/2026 (fn_Get_SalaryPeriod(10, 2026): 10/10 -> 09/11/2026):
--   1. TẤT CẢ CÁC NGÀY LÀM VIỆC BÌNH THƯỜNG (Thứ 2 -> Thứ 6), TRỪ 4 ngày đặc biệt và TRỪ T7, CN:
--      -> Full ca chuẩn: 08:00 - 17:00 (8.0h công chuẩn) trên CẢ tblHasTA VÀ tblTmpAttend!
--   2. THỨ 7, CHỦ NHẬT (trừ trường hợp nghỉ phép 24/10):
--      -> Để trống (AttStart = NULL, AttEnd = NULL, 0.0h công).
--   3. 4 NGÀY ĐẶC BIỆT PHỤC VỤ TEST NGHIỆP VỤ:
--      - Ngày 14/10/2026 (Thứ 4): 08:00 - 15:00 -> 6.0h công lẻ (Test nộp nhầm đơn bù Giờ Ra 17:00 rồi TỰ HỦY -> giữ 6.0h)
--      - Ngày 15/10/2026 (Thứ 5): 08:00 - 12:00 -> 4.0h công lẻ (Test xin bù Giờ Ra 17:00 & ĐƯỢC DUYỆT -> tăng lên 8.0h!)
--      - Ngày 16/10/2026 (Thứ 6): 08:00 - 16:00 -> 7.0h công lẻ (Test xin bù Giờ Ra 17:00 & BỊ TỪ CHỐI -> giữ nguyên 7.0h!)
--      - Ngày 24/10/2026 (Thứ 7): NULL - NULL  -> 0.0h (Chờ đơn xin Nghỉ phép năm AL 1 ngày = 8.0h ở TC-08)
--
-- LƯU Ý QUAN TRỌNG: Seed đồng bộ CẢ tblHasTA VÀ tblTmpAttend (bảng quẹt thẻ thô) để khi chạy
-- "Tính toán lại" (sp_ReCalculate_TAData), hệ thống nối đúng 08:00 (Vào) + 17:00 (Ra được duyệt) = 8.0h!
-- =========================================================================================
-- Hướng dẫn: Mở trên SQL Server Management Studio (SSMS) -> Bấm Ctrl+F5 kiểm tra cú pháp -> F5 để thực thi
-- =========================================================================================

SET NOCOUNT ON;
PRINT N'=============================================================================';
PRINT N'🌱 BẮT ĐẦU SEED DỮ LIỆU CHẤM CÔNG THÁNG 10/2026 (08:00 - 17:00) CHO NV 099...';
PRINT N'=============================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @FromDate DATE, @ToDate DATE;
    SELECT @FromDate = CAST(FromDate AS DATE), @ToDate = CAST(ToDate AS DATE)
    FROM dbo.fn_Get_SalaryPeriod(10, 2026);

    IF @FromDate IS NULL SET @FromDate = '2026-10-10';
    IF @ToDate IS NULL   SET @ToDate   = '2026-11-09';

    -- Làm sạch dữ liệu quẹt thẻ thô cũ trong kỳ của NV 099 để seed mới sạch 100% (idempotent)
    DELETE FROM tblTmpAttend
    WHERE EmployeeID = '099'
      AND CAST(AttTime AS DATE) BETWEEN @FromDate AND @ToDate;

    DECLARE @d DATE = @FromDate;
    DECLARE @IsWeekend BIT;
    DECLARE @AttStart DATETIME, @AttEnd DATETIME, @WorkHours FLOAT;
    DECLARE @NormalDays INT = 0;

    WHILE @d <= @ToDate
    BEGIN
        -- Xác định T7 / CN độc lập với @@DATEFIRST (0 = Thứ 7, 1 = Chủ Nhật)
        SET @IsWeekend = CASE WHEN ((DATEPART(dw, @d) + @@DATEFIRST) % 7) IN (0, 1) THEN 1 ELSE 0 END;

        IF @d = '2026-10-14'
        BEGIN
            -- Ngày đặc biệt 1: Làm 08:00 - 15:00 (trừ 1h nghỉ trưa 12:00-13:00 = 6.0h công lẻ)
            SET @AttStart  = CAST('2026-10-14 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-14 15:00:00' AS DATETIME);
            SET @WorkHours = 6.0;
        END
        ELSE IF @d = '2026-10-15'
        BEGIN
            -- Ngày đặc biệt 2: Làm sáng 08:00 - 12:00 (4.0h công lẻ, chờ bù Giờ Ra 17:00 -> 8.0h)
            SET @AttStart  = CAST('2026-10-15 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-15 12:00:00' AS DATETIME);
            SET @WorkHours = 4.0;
        END
        ELSE IF @d = '2026-10-16'
        BEGIN
            -- Ngày đặc biệt 3: Làm 08:00 - 16:00 (trừ 1h nghỉ trưa 12:00-13:00 = 7.0h công lẻ, test Reject -> giữ 7.0h)
            SET @AttStart  = CAST('2026-10-16 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-16 16:00:00' AS DATETIME);
            SET @WorkHours = 7.0;
        END
        ELSE IF @d = '2026-10-24' OR @IsWeekend = 1
        BEGIN
            -- Ngày đặc biệt 4 (24/10 chờ Nghỉ phép AL) & Tất cả Thứ 7 / Chủ Nhật: Trống (0.0h)
            SET @AttStart  = NULL;
            SET @AttEnd    = NULL;
            SET @WorkHours = 0.0;
        END
        ELSE
        BEGIN
            -- Các ngày làm việc còn lại (Thứ 2 -> Thứ 6): Full ca chuẩn công ty 08:00 - 17:00 (8.0h)
            SET @AttStart  = DATEADD(HOUR, 8, CAST(@d AS DATETIME));
            SET @AttEnd    = DATEADD(HOUR, 17, CAST(@d AS DATETIME));
            SET @WorkHours = 8.0;
            SET @NormalDays = @NormalDays + 1;
        END

        -- 1. Cập nhật / Chèn vào tblHasTA
        IF EXISTS (SELECT 1 FROM tblHasTA WHERE EmployeeID = '099' AND CAST(AttDate AS DATE) = @d)
        BEGIN
            UPDATE tblHasTA
            SET AttStart = @AttStart,
                AttEnd = @AttEnd,
                WorkingTime = @WorkHours,
                RealWorkingTime = @WorkHours,
                Approve = 0,
                TAStatus = NULL,
                TimeReason = NULL
            WHERE EmployeeID = '099' AND CAST(AttDate AS DATE) = @d;
        END
        ELSE
        BEGIN
            INSERT INTO tblHasTA (EmployeeID, AttDate, Period, AttStart, AttEnd, WorkingTime, RealWorkingTime, Approve)
            VALUES ('099', @d, 0, @AttStart, @AttEnd, @WorkHours, @WorkHours, 0);
        END

        -- 2. Đồng bộ dữ liệu quẹt thẻ thô vào tblTmpAttend (để sp_ShiftDetector tính đúng khi Duyệt bù công / Tính toán lại)
        IF @AttStart IS NOT NULL AND @AttEnd IS NOT NULL
        BEGIN
            INSERT INTO tblTmpAttend (EmployeeID, AttTime, AttState, MachineNo)
            VALUES ('099', @AttStart, 1, 1); -- Quẹt vào 08:00

            INSERT INTO tblTmpAttend (EmployeeID, AttTime, AttState, MachineNo)
            VALUES ('099', @AttEnd, 2, 1);   -- Quẹt ra thực tế
        END

        SET @d = DATEADD(DAY, 1, @d);
    END

    -- Xóa hàng đợi pending do trigger insert tblTmpAttend vừa tạo (vì tblHasTA đã khớp sẵn 100%)
    DELETE FROM tblPendingImportAttend
    WHERE EmployeeID = '099' AND Date BETWEEN @FromDate AND @ToDate;

    DELETE FROM tblPendingTaProcessMain
    WHERE EmployeeID = '099' AND Date BETWEEN @FromDate AND @ToDate;

    COMMIT TRANSACTION;
    PRINT N'✅ Đã seed ' + CAST(@NormalDays AS NVARCHAR(10)) + N' ngày làm việc bình thường (08:00 - 17:00 = 8.0h/ngày).';
    PRINT N'✅ Đã seed 3 ngày đặc biệt (Bắt đầu vào 08:00):';
    PRINT N'   - 14/10: 08:00 - 15:00 (6.0h -> Test tự hủy đơn)';
    PRINT N'   - 15/10: 08:00 - 12:00 (4.0h -> Test bù Giờ Ra 17:00 ĐƯỢC DUYỆT -> 8.0h)';
    PRINT N'   - 16/10: 08:00 - 16:00 (7.0h -> Test bù Giờ Ra 17:00 BỊ TỪ CHỐI -> 7.0h)';
    PRINT N'✅ Ngày 24/10 và tất cả T7, CN: 0.0h (Chờ đơn Phép năm AL ngày 24/10).';
    PRINT N'=============================================================================';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA TRONG QUÁ TRÌNH SEED DỮ LIỆU: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =============================================================================
-- BẢNG ĐỐI SOÁT DỮ LIỆU TOÀN KỲ CÔNG THÁNG 10/2026 VỪA SEED TRONG tblHasTA
-- =============================================================================
DECLARE @F DATE, @T DATE;
SELECT @F = CAST(FromDate AS DATE), @T = CAST(ToDate AS DATE) FROM dbo.fn_Get_SalaryPeriod(10, 2026);

SELECT 
    CONVERT(varchar, AttDate, 23) AS [Ngày],
    DATENAME(dw, AttDate) AS [Thứ],
    ISNULL(CONVERT(varchar(5), AttStart, 108), '--:--') AS [Giờ Vào],
    ISNULL(CONVERT(varchar(5), AttEnd, 108), '--:--') AS [Giờ Ra],
    WorkingTime AS [Giờ Công],
    CAST(ROUND(WorkingTime / 8.0, 3) AS decimal(5,3)) AS [Quy đổi công],
    CASE 
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-14' THEN N'Đặc biệt 1: 6.0h (Nộp nhầm & Tự hủy)'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-15' THEN N'Đặc biệt 2: 4.0h (Chờ bù Giờ Ra 17:00 -> DUYỆT)'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-16' THEN N'Đặc biệt 3: 7.0h (Chờ bù Giờ Ra 17:00 -> TỪ CHỐI)'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-24' THEN N'Đặc biệt 4: 0.0h (Chờ Nghỉ phép AL 1 ngày)'
        WHEN ((DATEPART(dw, AttDate) + @@DATEFIRST) % 7) IN (0, 1) THEN N'Cuối tuần (T7/CN) - Nghỉ'
        ELSE N'Ngày làm việc chuẩn 8.0h (08:00 - 17:00)'
    END AS [Kịch bản Kiểm thử]
FROM tblHasTA
WHERE EmployeeID = '099' AND CAST(AttDate AS DATE) BETWEEN @F AND @T
ORDER BY AttDate;
GO
