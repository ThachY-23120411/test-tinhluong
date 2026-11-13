-- =========================================================================================
-- FILE: scripts/seed_attendance_5days_nv099.sql
-- MỤC ĐÍCH: SEED DỮ LIỆU CHẤM CÔNG & PHÂN CA THÁNG 10/2026 CHO NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
--           CÔNG TY LÀM VIỆC HÀNH CHÍNH CHUẨN: 08:00 - 17:00 (Nghỉ trưa 12:00 - 13:00 = 8.0h/ngày)
--
-- TẠI SAO PHẢI CẬP NHẬT FILE NÀY?
--   - spDailyAttendanceData (SP lấy dữ liệu hiển thị trên lưới "Chấm công cá nhân" MnuWPT010)
--     dùng INNER JOIN tblWSchedule (Lịch phân ca làm việc).
--   - Nếu bảng tblWSchedule chỉ có 3 ngày (14, 15, 16/10) thì toàn bộ các ngày khác (12, 13, 19, 20...)
--     sẽ BỊ LOẠI BỎ KHỎI LƯỚI do nhân viên chưa được xếp ca!
--   - Do đó, script này đồng bộ trọn vẹn CẢ 3 BẢNG:
--     1. tblWSchedule: Phân ca hành chính HC (Thứ 2 -> Thứ 6: HolidayStatus = 0; T7 & CN: HolidayStatus = 1)
--     2. tblHasTA: Giờ chấm công và số giờ công thực tế
--     3. tblTmpAttend: Dữ liệu quẹt thẻ thô (In 08:00, Out 17:00)
--
-- QUY TẮC SEED DỮ LIỆU KỲ CÔNG THÁNG 10/2026 (fn_Get_SalaryPeriod(10, 2026): 10/10 -> 09/11/2026):
--   1. TẤT CẢ CÁC NGÀY LÀM VIỆC BÌNH THƯỜNG (Thứ 2 -> Thứ 6), TRỪ 4 ngày đặc biệt và TRỪ T7, CN:
--      -> Full ca chuẩn: 08:00 - 17:00 (8.0h công chuẩn) trên CẢ tblHasTA, tblWSchedule VÀ tblTmpAttend!
--   2. THỨ 7, CHỦ NHẬT (trừ trường hợp nghỉ phép 24/10):
--      -> HolidayStatus = 1, Không có giờ công (AttStart = NULL, AttEnd = NULL, 0.0h công).
--   3. 4 NGÀY ĐẶC BIỆT PHỤC VỤ TEST NGHIỆP VỤ:
--      - Ngày 14/10/2026 (Thứ 4): 08:00 - 15:00 -> 6.0h công lẻ (Test nộp nhầm đơn bù Giờ Ra 17:00 rồi TỰ HỦY -> giữ 6.0h)
--      - Ngày 15/10/2026 (Thứ 5): 08:00 - 12:00 -> 4.0h công lẻ (Test xin bù Giờ Ra 17:00 & ĐƯỢC DUYỆT -> tăng lên 8.0h!)
--      - Ngày 16/10/2026 (Thứ 6): 08:00 - 16:00 -> 7.0h công lẻ (Test xin bù Giờ Ra 17:00 & BỊ TỪ CHỐI -> giữ nguyên 7.0h!)
--      - Ngày 22/10/2026 (Thứ 5): NULL - NULL  -> 0.0h (Chờ đơn xin Nghỉ phép năm AL 1 ngày = 8.0h ở TC-08)
-- =========================================================================================
-- Hướng dẫn: Mở trên SQL Server Management Studio (SSMS) -> Bấm Ctrl+F5 kiểm tra cú pháp -> F5 để thực thi
-- =========================================================================================

SET NOCOUNT ON;
PRINT N'=============================================================================';
PRINT N'🌱 BẮT ĐẦU SEED DỮ LIỆU CHẤM CÔNG & PHÂN CA THÁNG 10/2026 CHO NV 099...';
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
    DECLARE @CurShiftID INT;
    DECLARE @CurHolidayStatus INT;

    WHILE @d <= @ToDate
    BEGIN
        -- Xác định T7 / CN (0 = Thứ 7, 1 = Chủ Nhật)
        SET @IsWeekend = CASE WHEN ((DATEPART(dw, @d) + @@DATEFIRST) % 7) IN (0, 1) THEN 1 ELSE 0 END;

        -- Xác định ca làm việc theo thứ: 1=CN, 2=T2, 3=T3, 4=T4, 5=T5, 6=T6, 7=T7 (khớp ShiftID trong tblShiftSetting)
        SET @CurShiftID = ((DATEPART(dw, @d) + @@DATEFIRST - 2) % 7) + 1;
        SET @CurHolidayStatus = CASE WHEN @IsWeekend = 1 THEN 1 ELSE 0 END;

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
        ELSE IF @d = '2026-10-22'
        BEGIN
            -- Ngày đặc biệt 4 (22/10 Thứ 5: Ngày làm việc có phân ca nhưng TRỐNG CÔNG để test nộp đơn xin Nghỉ phép AL 1 ngày = 8.0h ở TC-08)
            SET @AttStart  = NULL;
            SET @AttEnd    = NULL;
            SET @WorkHours = 0.0;
        END
        ELSE IF @IsWeekend = 1
        BEGIN
            -- Tất cả Thứ 7 / Chủ Nhật: Trống (0.0h)
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

        -- 1. ĐỒNG BỘ LỊCH PHÂN CA (tblWSchedule) - ĐIỀU KIỆN TIÊN QUYẾT ĐỂ spDailyAttendanceData HIỂN THỊ LÊN LƯỚI!
        IF EXISTS (SELECT 1 FROM tblWSchedule WHERE EmployeeID = '099' AND CAST(ScheduleDate AS DATE) = @d)
        BEGIN
            UPDATE tblWSchedule
            SET ShiftID = @CurShiftID,
                HolidayStatus = @CurHolidayStatus
            WHERE EmployeeID = '099' AND CAST(ScheduleDate AS DATE) = @d;
        END
        ELSE
        BEGIN
            INSERT INTO tblWSchedule (EmployeeID, ScheduleDate, ShiftID, HolidayStatus)
            VALUES ('099', CAST(@d AS DATETIME), @CurShiftID, @CurHolidayStatus);
        END

        -- 2. Cập nhật / Chèn vào tblHasTA
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
            VALUES ('099', CAST(@d AS DATETIME), 0, @AttStart, @AttEnd, @WorkHours, @WorkHours, 0);
        END

        -- 3. Đồng bộ dữ liệu quẹt thẻ thô vào tblTmpAttend (để sp_ShiftDetector tính đúng khi Duyệt bù công / Tính toán lại)
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
    PRINT N'✅ Đã phân ca (tblWSchedule) cho TOÀN BỘ kỳ công từ ' + CAST(@FromDate AS NVARCHAR(10)) + N' đến ' + CAST(@ToDate AS NVARCHAR(10)) + N'.';
    PRINT N'✅ Đã seed ' + CAST(@NormalDays AS NVARCHAR(10)) + N' ngày làm việc bình thường (08:00 - 17:00 = 8.0h/ngày).';
    PRINT N'✅ Đã seed 3 ngày đặc biệt (Bắt đầu vào 08:00):';
    PRINT N'   - 14/10: 08:00 - 15:00 (6.0h -> Test tự hủy đơn)';
    PRINT N'   - 15/10: 08:00 - 12:00 (4.0h -> Test bù Giờ Ra 17:00 ĐƯỢC DUYỆT -> 8.0h)';
    PRINT N'   - 16/10: 08:00 - 16:00 (7.0h -> Test bù Giờ Ra 17:00 BỊ TỪ CHỐI -> 7.0h)';
    PRINT N'✅ Ngày 22/10 và tất cả T7, CN: 0.0h (Chờ đơn Phép năm AL ngày 22/10).';
    PRINT N'=============================================================================';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA TRONG QUÁ TRÌNH SEED DỮ LIỆU: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =============================================================================
-- BẢNG ĐỐI SOÁT DỮ LIỆU TOÀN KỲ CÔNG THÁNG 10/2026 VỪA SEED TRONG tblWSchedule & tblHasTA
-- =============================================================================
DECLARE @F DATE, @T DATE;
SELECT @F = CAST(FromDate AS DATE), @T = CAST(ToDate AS DATE) FROM dbo.fn_Get_SalaryPeriod(10, 2026);

SELECT 
    CONVERT(varchar, ws.ScheduleDate, 23) AS [Ngày],
    DATENAME(dw, ws.ScheduleDate) AS [Thứ],
    ws.ShiftID AS [Mã Ca],
    CASE WHEN ws.HolidayStatus = 1 THEN N'Nghỉ tuần' ELSE N'Làm việc' END AS [Lịch phân ca],
    ISNULL(CONVERT(varchar(5), hta.AttStart, 108), '--:--') AS [Giờ Vào],
    ISNULL(CONVERT(varchar(5), hta.AttEnd, 108), '--:--') AS [Giờ Ra],
    ISNULL(hta.WorkingTime, 0) AS [Giờ Công],
    CAST(ROUND(ISNULL(hta.WorkingTime, 0) / 8.0, 3) AS decimal(5,3)) AS [Quy đổi công],
    CASE 
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-14' THEN N'Đặc biệt 1: 6.0h (Nộp nhầm & Tự hủy)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-15' THEN N'Đặc biệt 2: 4.0h (Chờ bù Giờ Ra 17:00 -> DUYỆT)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-16' THEN N'Đặc biệt 3: 7.0h (Chờ bù Giờ Ra 17:00 -> TỪ CHỐI)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-22' THEN N'Đặc biệt 4: 0.0h (Chờ Nghỉ phép AL 1 ngày)'
        WHEN ws.HolidayStatus = 1 THEN N'Cuối tuần (T7/CN) - Nghỉ'
        ELSE N'Ngày làm việc chuẩn 8.0h (08:00 - 17:00)'
    END AS [Kịch bản Kiểm thử]
FROM tblWSchedule ws
LEFT JOIN tblHasTA hta ON hta.EmployeeID = ws.EmployeeID AND hta.AttDate = ws.ScheduleDate
WHERE ws.EmployeeID = '099' AND CAST(ws.ScheduleDate AS DATE) BETWEEN @F AND @T
ORDER BY ws.ScheduleDate;
GO
