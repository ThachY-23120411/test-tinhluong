-- =========================================================================================
-- BẢN VÁ ĐỒNG BỘ PHÂN QUYỀN API VÀ CỔNG BẢO MẬT TỪ Vietinsoft_ForTest_Tai SANG Vietinsoft_ForTest_Tai2
-- Mục đích: Khắc phục triệt để lỗi mất dữ liệu toàn hệ thống và mất Avatar đối với tài khoản
--           thuộc nhóm quyền (như ThanhLong LoginID = 20, nhóm Managers 8 & Users 9).
-- Database mục tiêu: Vietinsoft_ForTest_Tai2 (Web https://paradisehrm.com/Tai3/)
-- =========================================================================================

USE [Vietinsoft_ForTest_Tai2];
GO

-- -----------------------------------------------------------------------------------------
-- PHẦN 1: ĐỒNG BỘ CỔNG XÁC THỰC VÀ PHÂN QUYỀN API dbo.apiParadise
-- Khắc phục: Bổ sung bóc tách @ParentLoginID qua SplitString để kiểm tra quyền nhóm cho Login con
-- -----------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[apiParadise]
    @apiParadiseUser nvarchar(4000) =null,
    @apiParadisePass nvarchar(4000) =null,
    @apiParadiseToken nvarchar(4000) =null,
    @apiParadiseName nvarchar(4000) =null
as
declare @LoginID int
select @LoginID=LoginID from tblSC_Login where LoginName=@apiParadiseUser and isnull(PassWord, '')=isnull(@apiParadisePass, '')

declare @ParentLoginID varchar(256)
select @ParentLoginID=ParentLoginID from tblSC_Login where LoginID=@LoginID and UseGroupRightOnly=1
SELECT * into #tmp FROM dbo.SplitString(@ParentLoginID,'&')

-- Xóa phần tử rỗng khi SplitString(NULL) hoặc SplitString('') sinh ra dòng trống
delete from #tmp where isnull(rtrim(Items), '') = ''

if not exists(select * from #tmp)
insert #tmp
select @LoginID

if exists (select * from tblApiParadisePrivilege where @apiParadiseName=Name)
    and not exists (select * from tblApiParadisePrivilege where @apiParadiseName=Name and LoginID in (select * from #tmp))
    set @LoginID=-1

if @apiParadiseName in ('spParadiseLogin', 'sp_TwoFacrtorAuthenticationCheck', 'api_getLoginIDWithUser', 'SC_Login_CheckMobileLogin')and isnull(@LoginID, -2) < 0
    set @LoginID=1

if @apiParadiseName!='paradisepublic' and @apiParadiseUser='paradisepublic'
    set @LoginID=-1

if @LoginID>-1
begin
    select @LoginID LoginID, 32 [Right], '' apiParadiseToken
    return
end

declare @getdate datetime=getdate(), @maxdate datetime='9999-12-31 23:59:59'
select @LoginID=isnull(LoginID, 3)
from tblapiParadise
where Token=@apiParadiseToken and @getdate between StartDate and isnull(EndDate, @maxdate)
declare @top int=0
if @LoginID>-1 set @top=1
select top(@top)@LoginID LoginID, 32 [Right], @apiParadiseToken apiParadiseToken
GO

-- -----------------------------------------------------------------------------------------
-- PHẦN 2: ĐỒNG BỘ THỦ TỤC BÓC TÁCH COMPONENT / API dbo.sp_scanAPI_ExtractObjects
-- -----------------------------------------------------------------------------------------
ALTER PROCEDURE dbo.sp_scanAPI_ExtractObjects
    @ProcName NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Chuẩn hóa tên đầu vào
    DECLARE @CleanName NVARCHAR(250) = @ProcName;
    IF LOWER(@CleanName) LIKE 'dbo.%'
        SET @CleanName = SUBSTRING(@CleanName, 5, LEN(@CleanName) - 4);
    IF LOWER(@CleanName) LIKE '%_html'
        SET @CleanName = SUBSTRING(@CleanName, 1, LEN(@CleanName) - 5);
    IF LOWER(@CleanName) LIKE '%_beta'
        SET @CleanName = SUBSTRING(@CleanName, 1, LEN(@CleanName) - 5);

    -- 2. Gom tất cả nguồn script (Stored Procedures + HTML/JS Cache + Mobile Cache)
    IF OBJECT_ID('tempdb..#ScriptChunks') IS NOT NULL DROP TABLE #ScriptChunks;
    CREATE TABLE #ScriptChunks (Chunk NVARCHAR(MAX));

    -- (a) Nạp từ Stored Procedure trên Database
    IF OBJECT_ID(@ProcName, 'P') IS NOT NULL
        INSERT INTO #ScriptChunks VALUES (OBJECT_DEFINITION(OBJECT_ID(@ProcName)));

    IF OBJECT_ID(@CleanName, 'P') IS NOT NULL AND @CleanName <> @ProcName
        INSERT INTO #ScriptChunks VALUES (OBJECT_DEFINITION(OBJECT_ID(@CleanName)));

    IF OBJECT_ID(@CleanName + '_html', 'P') IS NOT NULL
        INSERT INTO #ScriptChunks VALUES (OBJECT_DEFINITION(OBJECT_ID(@CleanName + '_html')));

    IF OBJECT_ID('sp_' + @CleanName + '_html', 'P') IS NOT NULL
        INSERT INTO #ScriptChunks VALUES (OBJECT_DEFINITION(OBJECT_ID('sp_' + @CleanName + '_html')));

    IF OBJECT_ID('sp_' + @CleanName, 'P') IS NOT NULL
        INSERT INTO #ScriptChunks VALUES (OBJECT_DEFINITION(OBJECT_ID('sp_' + @CleanName)));

    -- Hỗ trợ sp_GetSQLScript_Multi nếu có
    IF OBJECT_ID('dbo.sp_GetSQLScript_Multi', 'P') IS NOT NULL
    BEGIN
        BEGIN TRY
            INSERT INTO #ScriptChunks
            EXEC dbo.sp_GetSQLScript_Multi @CleanName;
        END TRY
        BEGIN CATCH
        END CATCH;
    END;

    -- (b) Nạp từ tblHtmlScriptCache (hỗ trợ cả _Beta, _html, _html_Beta)
    IF OBJECT_ID('dbo.tblHtmlScriptCache', 'U') IS NOT NULL
    BEGIN
        INSERT INTO #ScriptChunks
        SELECT ISNULL(html, '') + CHAR(13) + CHAR(10) + ISNULL(paradiseJs, '')
        FROM dbo.tblHtmlScriptCache WITH (NOLOCK)
        WHERE TableName IN (
            @ProcName, @CleanName, 
            @CleanName + '_html', @CleanName + '_Beta', 
            @CleanName + '_html_Beta', @ProcName + '_Beta'
        );
    END;

    -- (c) Nạp từ tblHtmlMobile
    IF OBJECT_ID('dbo.tblHtmlMobile', 'U') IS NOT NULL
    BEGIN
        INSERT INTO #ScriptChunks
        SELECT ISNULL(html, '')
        FROM dbo.tblHtmlMobile WITH (NOLOCK)
        WHERE TableName IN (@ProcName, @CleanName, @CleanName + '_html', @ProcName + '_Beta');
    END;

    -- 3. Bóc tách Token từ các Chunks (Tương thích 100% SQL Server 2008 - 2022+)
    IF OBJECT_ID('tempdb..#FoundTokens') IS NOT NULL DROP TABLE #FoundTokens;
    CREATE TABLE #FoundTokens (
        ObjectName NVARCHAR(250) PRIMARY KEY,
        ObjectType NVARCHAR(100),
        [Type]     VARCHAR(10)
    );

    -- Prefix cần tìm kiếm nhanh
    IF OBJECT_ID('tempdb..#Prefixes') IS NOT NULL DROP TABLE #Prefixes;
    CREATE TABLE #Prefixes (Pfx VARCHAR(30) PRIMARY KEY);
    INSERT INTO #Prefixes (Pfx)
    VALUES ('sp_'), ('api_'), ('HR_'), ('ss_'), ('PR_'), ('SAL_'), ('TA_'), ('DataSetting.'), ('dashboard_');

    DECLARE @Chunk NVARCHAR(MAX);
    DECLARE curChunk CURSOR LOCAL FAST_FORWARD FOR 
        SELECT Chunk FROM #ScriptChunks WHERE Chunk IS NOT NULL AND LEN(Chunk) > 0;
    OPEN curChunk;
    FETCH NEXT FROM curChunk INTO @Chunk;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @len INT = LEN(@Chunk);

        -- Cách 1: Quét pattern name: "..." hoặc name: '...' (Gọi qua AJAX / AjaxHPAParadiseAsync)
        DECLARE @pos INT = 1;
        WHILE @pos <= @len
        BEGIN
            SET @pos = CHARINDEX('name', @Chunk, @pos);
            IF @pos = 0 BREAK;

            DECLARE @subPos INT = @pos + 4;
            WHILE @subPos <= @len AND SUBSTRING(@Chunk, @subPos, 1) IN (' ', CHAR(9), CHAR(13), CHAR(10))
                SET @subPos = @subPos + 1;

            IF SUBSTRING(@Chunk, @subPos, 1) = ':'
            BEGIN
                SET @subPos = @subPos + 1;
                WHILE @subPos <= @len AND SUBSTRING(@Chunk, @subPos, 1) IN (' ', CHAR(9), CHAR(13), CHAR(10))
                    SET @subPos = @subPos + 1;

                DECLARE @quote CHAR(1) = SUBSTRING(@Chunk, @subPos, 1);
                IF @quote IN ('''', '"', '`')
                BEGIN
                    DECLARE @endQuote INT = CHARINDEX(@quote, @Chunk, @subPos + 1);
                    IF @endQuote > @subPos + 1 AND @endQuote - @subPos <= 150
                    BEGIN
                        DECLARE @tok NVARCHAR(150) = SUBSTRING(@Chunk, @subPos + 1, @endQuote - @subPos - 1);
                        IF LEN(@tok) >= 3 AND @tok NOT LIKE '% %'
                        BEGIN
                            DECLARE @objId INT = OBJECT_ID(@tok);
                            IF @objId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #FoundTokens WHERE ObjectName = @tok)
                            BEGIN
                                INSERT INTO #FoundTokens (ObjectName, ObjectType, [Type])
                                SELECT o.name, o.type_desc, RTRIM(o.type)
                                FROM sys.objects o WITH (NOLOCK)
                                WHERE o.object_id = @objId AND o.is_ms_shipped = 0;
                            END;
                        END;
                    END;
                END;
            END;
            SET @pos = @pos + 4;
        END;

        -- Cách 2: Quét theo các prefix thông dụng (sp_, api_, HR_, ss_...)
        DECLARE @curPfx VARCHAR(30);
        DECLARE curPfx CURSOR LOCAL FAST_FORWARD FOR SELECT Pfx FROM #Prefixes;
        OPEN curPfx;
        FETCH NEXT FROM curPfx INTO @curPfx;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @pos = 1;
            DECLARE @pfxLen INT = LEN(@curPfx);
            WHILE @pos <= @len
            BEGIN
                SET @pos = CHARINDEX(@curPfx, @Chunk, @pos);
                IF @pos = 0 BREAK;

                -- Ký tự trước prefix phải là ký tự ngăn cách hợp lệ
                DECLARE @prevChar CHAR(1) = CASE WHEN @pos > 1 THEN SUBSTRING(@Chunk, @pos - 1, 1) ELSE ' ' END;
                IF @prevChar IN ('''', '"', '`', ' ', CHAR(9), CHAR(10), CHAR(13), '(', '=', '>', ':', '?', ';', ',', '[')
                BEGIN
                    DECLARE @endPos INT = @pos + @pfxLen;
                    WHILE @endPos <= @len AND SUBSTRING(@Chunk, @endPos, 1) LIKE '[a-zA-Z0-9_]'
                        SET @endPos = @endPos + 1;

                    IF @endPos > @pos + @pfxLen
                    BEGIN
                        DECLARE @tokPfx NVARCHAR(150) = SUBSTRING(@Chunk, @pos, @endPos - @pos);
                        IF LEN(@tokPfx) >= 4 
                           AND LOWER(@tokPfx) NOT IN ('sp_executesql', 'sp_generatehtmlscript_new', 'sp_generatehtmlscript', LOWER(@ProcName), LOWER(@CleanName))
                        BEGIN
                            DECLARE @pfxObjId INT = OBJECT_ID(@tokPfx);
                            IF @pfxObjId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #FoundTokens WHERE ObjectName = @tokPfx)
                            BEGIN
                                INSERT INTO #FoundTokens (ObjectName, ObjectType, [Type])
                                SELECT o.name, o.type_desc, RTRIM(o.type)
                                FROM sys.objects o WITH (NOLOCK)
                                WHERE o.object_id = @pfxObjId AND o.is_ms_shipped = 0;
                            END;
                        END;
                    END;
                END;
                SET @pos = @pos + @pfxLen;
            END;
            FETCH NEXT FROM curPfx INTO @curPfx;
        END;
        CLOSE curPfx;
        DEALLOCATE curPfx;

        FETCH NEXT FROM curChunk INTO @Chunk;
    END;
    CLOSE curChunk;
    DEALLOCATE curChunk;

    -- Thêm chính Form hiện tại và form liên quan nếu có trên DB
    IF OBJECT_ID(@ProcName, 'P') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #FoundTokens WHERE ObjectName = @ProcName)
    BEGIN
        INSERT INTO #FoundTokens (ObjectName, ObjectType, [Type])
        SELECT o.name, o.type_desc, RTRIM(o.type) FROM sys.objects o WHERE o.name = @ProcName;
    END;

    IF OBJECT_ID(@CleanName, 'P') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #FoundTokens WHERE ObjectName = @CleanName)
    BEGIN
        INSERT INTO #FoundTokens (ObjectName, ObjectType, [Type])
        SELECT o.name, o.type_desc, RTRIM(o.type) FROM sys.objects o WHERE o.name = @CleanName;
    END;

    IF OBJECT_ID(@CleanName + '_html', 'P') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #FoundTokens WHERE ObjectName = @CleanName + '_html')
    BEGIN
        INSERT INTO #FoundTokens (ObjectName, ObjectType, [Type])
        SELECT o.name, o.type_desc, RTRIM(o.type) FROM sys.objects o WHERE o.name = @CleanName + '_html';
    END;

    -- 4. NẠP VÀO BẢNG TẠM CỦA CALLER (NẾU ĐƯỢC GỌI TỪ dbo.sp_scanAPI)
    -- (a) Bảng #CurFormObjects: chứa đầy đủ danh sách Object
    IF OBJECT_ID('tempdb..#CurFormObjects') IS NOT NULL
    BEGIN
        INSERT INTO #CurFormObjects (RawText, SchemaName, ObjectName, ObjectType)
        SELECT DISTINCT ObjectName, 'dbo', ObjectName, ObjectType
        FROM #FoundTokens;
    END;

    -- (b) Bảng #FoundAPIs: chứa danh sách các Stored Procedure / Function cần cấp quyền API
    IF OBJECT_ID('tempdb..#FoundAPIs') IS NOT NULL
    BEGIN
        INSERT INTO #FoundAPIs (api)
        SELECT DISTINCT ObjectName
        FROM #FoundTokens
        WHERE [Type] IN ('P', 'FN', 'IF', 'TF')
          AND ObjectName NOT IN (SELECT api FROM #FoundAPIs)
          AND (
              OBJECT_ID('tempdb..#ExcludeTables') IS NULL 
              OR LOWER(ObjectName) NOT IN (SELECT TblName FROM #ExcludeTables)
          );
    END;

    -- (c) Nếu caller KHÔNG truyền bảng tạm nào (chạy ngoài SSMS kiểm tra)
    IF OBJECT_ID('tempdb..#CurFormObjects') IS NULL AND OBJECT_ID('tempdb..#FoundAPIs') IS NULL
    BEGIN
        SELECT 
            ObjectName AS RawText,
            'dbo' AS SchemaName,
            ObjectName,
            ObjectType
        FROM #FoundTokens
        ORDER BY ObjectType, ObjectName;
    END;

    IF OBJECT_ID('tempdb..#FoundTokens') IS NOT NULL DROP TABLE #FoundTokens;
    IF OBJECT_ID('tempdb..#Prefixes') IS NOT NULL DROP TABLE #Prefixes;
    IF OBJECT_ID('tempdb..#ScriptChunks') IS NOT NULL DROP TABLE #ScriptChunks;
END;
GO

-- -----------------------------------------------------------------------------------------
-- PHẦN 3: ĐỒNG BỘ THỦ TỤC QUÉT VÀ CẤP QUYỀN TỰ ĐỘNG dbo.sp_scanAPI
-- Khắc phục:
--   1. #ValidLogins bao gồm toàn bộ User đang hoạt động (WHERE ISNULL(lg.IsDisable, 0) = 0).
--   2. Tự động nạp quyền thừa kế qua sp_SC_Right và kế thừa ParentLoginID vào tblApiParadisePrivilege.
--   3. Đồng bộ cả quyền đọc (FullAccess = '1') và toàn quyền (FullAccess = '32').
-- -----------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_scanAPI]
    @TableName NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM tblParameter WHERE Code = 'MobileSaveData' AND LTRIM(RTRIM(ISNULL(Value, ''))) = '1')
        RETURN;

    DECLARE @BatchSize INT = 500;
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @FormsScannedThisRun INT = 0;
    DECLARE @TotalRowsWritten INT = 0;

    SET @TableName = NULLIF(LTRIM(RTRIM(@TableName)), N'');

    IF OBJECT_ID('dbo.fn_CheckIsRunningProc', 'FN') IS NOT NULL
    BEGIN
        IF dbo.fn_CheckIsRunningProc('sp_scanAPI') = 1
            RETURN;
    END;

    -- Bảng tạm rỗng phục vụ thủ tục bóc tách con sp_scanAPI_ExtractObjects (không chứa rác)
    IF OBJECT_ID('tempdb..#ExcludeTables') IS NOT NULL DROP TABLE #ExcludeTables;
    CREATE TABLE #ExcludeTables (TblName NVARCHAR(128));

    -- =========================================================================
    -- BƯỚC 0: LỌC DANH SÁCH MENU CẦN QUÉT VÀ COMPONENT KHÔNG CẦN PHÂN QUYỀN
    -- Source-of-Truth: tblSC_Object + MEN_Menu + tblHtmlScriptCache + tblHtmlMobile
    -- =========================================================================

    -- 1. Gom tất cả Name cần quét từ MEN_Menu (ClassName, MenuID) + tblSC_Object (ObjectName đã cắt prefix)
    IF OBJECT_ID('tempdb..#NeedToScan') IS NOT NULL DROP TABLE #NeedToScan;
    SELECT DISTINCT Name INTO #NeedToScan FROM (
        -- MEN_Menu: ClassName
        SELECT LTRIM(RTRIM(ClassName)) AS Name
        FROM dbo.MEN_Menu WITH (NOLOCK)
        WHERE IsVisible = 1 AND ISNULL(ClassName, '') <> ''
        UNION
        -- MEN_Menu: MenuID
        SELECT LTRIM(RTRIM(MenuID)) AS Name
        FROM dbo.MEN_Menu WITH (NOLOCK)
        WHERE IsVisible = 1 AND ISNULL(MenuID, '') <> ''
        UNION
        -- tblSC_Object: ObjectName gốc (có Description nằm trong MenuID của menu visible)
        SELECT LTRIM(RTRIM(o.ObjectName)) AS Name
        FROM dbo.tblSC_Object o WITH (NOLOCK)
        WHERE o.Description IN (SELECT MenuID FROM dbo.MEN_Menu WITH (NOLOCK) WHERE IsVisible = 1)
          AND ISNULL(o.ObjectName, '') <> ''
        UNION
        -- tblSC_Object: ObjectName cắt bỏ prefix (DataSetting., ApprovalAttendanceData., ...)
        SELECT LTRIM(RTRIM(
            CASE
                WHEN o.ObjectName LIKE '%.%' THEN SUBSTRING(o.ObjectName, CHARINDEX('.', o.ObjectName) + 1, LEN(o.ObjectName))
                ELSE o.ObjectName
            END
        )) AS Name
        FROM dbo.tblSC_Object o WITH (NOLOCK)
        WHERE o.Description IN (SELECT MenuID FROM dbo.MEN_Menu WITH (NOLOCK) WHERE IsVisible = 1)
          AND ISNULL(o.ObjectName, '') <> ''
    ) AS combined
    WHERE ISNULL(Name, '') <> '';

    -- 2. Lọc các TableName trong cache KHÔNG thuộc #NeedToScan -> KHÔNG CẦN PHÂN QUYỀN
    IF OBJECT_ID('tempdb..#TableName_NoPermission') IS NOT NULL DROP TABLE #TableName_NoPermission;
    SELECT DISTINCT TableName INTO #TableName_NoPermission FROM (
        SELECT TableName FROM dbo.tblHtmlScriptCache WITH (NOLOCK) WHERE ISNULL(TableName, '') <> ''
        UNION
        SELECT TableName FROM dbo.tblHtmlMobile WITH (NOLOCK) WHERE ISNULL(TableName, '') <> ''
    ) AS c
    WHERE TableName NOT IN (SELECT Name FROM #NeedToScan WHERE Name IS NOT NULL)
      AND REPLACE(REPLACE(TableName, '_html', ''), '_Beta', '') NOT IN (SELECT Name FROM #NeedToScan WHERE Name IS NOT NULL);

    -- 3. Dọn sạch các component không cần phân quyền khỏi tblSC_UserAPIRight và tblApiParadisePrivilege
    IF OBJECT_ID('dbo.tblSC_UserAPIRight', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.tblSC_UserAPIRight
        WHERE TableName IN (SELECT TableName FROM #TableName_NoPermission)
           OR api IN (SELECT TableName FROM #TableName_NoPermission);
    END;

    IF OBJECT_ID('dbo.tblApiParadisePrivilege', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.tblApiParadisePrivilege
        WHERE Name IN (SELECT TableName FROM #TableName_NoPermission);
    END;

    -- =========================================================================
    -- BƯỚC 0.1: DANH SÁCH TÀI KHOẢN ĐƯỢC PHÉP DUYỆT ĐƠN (isLike = 1)
    -- Tự động tổng hợp từ: Admin + Nhóm Managers (8) + Bảng cấu hình luồng duyệt
    -- =========================================================================
    IF OBJECT_ID('tempdb..#ApproverLogins') IS NOT NULL DROP TABLE #ApproverLogins;
    CREATE TABLE #ApproverLogins (LoginID INT PRIMARY KEY);

    -- A. Admin
    INSERT INTO #ApproverLogins (LoginID)
    SELECT lg.LoginID FROM dbo.tblSC_Login lg WITH (NOLOCK)
    WHERE ISNULL(lg.isAdmin, 0) = 1 OR ISNULL(lg.AdminRight, 0) = 1;

    -- B. Nhóm Managers (8) hoặc user thuộc nhóm 8
    INSERT INTO #ApproverLogins (LoginID)
    SELECT lg.LoginID FROM dbo.tblSC_Login lg WITH (NOLOCK)
    WHERE (lg.LoginID = 8 OR ISNULL(lg.ParentLoginID, '') LIKE '%8%')
      AND NOT EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = lg.LoginID);

    -- C. Tất cả những ai là Người duyệt (Approvers) thực tế từ bảng tblApprovalLineByEmployee
    IF OBJECT_ID('dbo.tblApprovalLineByEmployee', 'U') IS NOT NULL
    BEGIN
        INSERT INTO #ApproverLogins (LoginID)
        SELECT DISTINCT lg.LoginID
        FROM dbo.tblSC_Login lg WITH (NOLOCK)
        INNER JOIN (
            SELECT Approver_1 AS EmpID FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Approver_1, '') <> ''
            UNION SELECT Approver_2 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Approver_2, '') <> ''
            UNION SELECT Approver_3 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Approver_3, '') <> ''
            UNION SELECT Approver_4 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Approver_4, '') <> ''
            UNION SELECT Delegacy_1 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Delegacy_1, '') <> ''
            UNION SELECT Delegacy_2 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Delegacy_2, '') <> ''
            UNION SELECT Delegacy_3 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Delegacy_3, '') <> ''
            UNION SELECT Delegacy_4 FROM dbo.tblApprovalLineByEmployee WITH (NOLOCK) WHERE ISNULL(Delegacy_4, '') <> ''
        ) app ON app.EmpID = lg.EmployeeID
        WHERE NOT EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = lg.LoginID);
    END;

    -- =========================================================================
    -- BƯỚC 0.2: NẠP TOÀN BỘ QUYỀN HỆ THỐNG QUA sp_SC_Right (THEO TỪNG LOGIN CÁ NHÂN)
    -- =========================================================================
    IF OBJECT_ID('tempdb..#AllUserRights') IS NOT NULL DROP TABLE #AllUserRights;
    CREATE TABLE #AllUserRights (FullAccess VARCHAR(50), ObjectName NVARCHAR(200), LoginID INT, ObjectID INT);

    IF OBJECT_ID('dbo.sp_SC_Right', 'P') IS NOT NULL
    BEGIN
        EXEC dbo.sp_SC_Right @TempTableNameGetData = '#AllUserRights';
    END;

    -- CỜ KIỂM TRA CÁC BẢNG HỆ THỐNG
    DECLARE @HasRightStoredTable BIT = CASE WHEN OBJECT_ID('dbo.tblSC_Right_Stored', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @HasScanStateTable   BIT = CASE WHEN OBJECT_ID('dbo.tblSC_UserAPIScanState', 'U') IS NOT NULL THEN 1 ELSE 0 END;

    IF OBJECT_ID('tempdb..#ValidLogins') IS NOT NULL DROP TABLE #ValidLogins;
    SELECT DISTINCT lg.LoginID
    INTO #ValidLogins
    FROM dbo.tblSC_Login lg WITH (NOLOCK)
    WHERE ISNULL(lg.IsDisable, 0) = 0;

    -- =========================================================================
    -- BƯỚC 1: CHỌN DANH SÁCH FORM CẦN QUÉT (CHỈ CÁC FORM CÓ TRONG #NeedToScan)
    -- =========================================================================
    IF OBJECT_ID('tempdb..#CandidateForms') IS NOT NULL DROP TABLE #CandidateForms;
    CREATE TABLE #CandidateForms (
        TableName     NVARCHAR(250),
        LanguageID    VARCHAR(10),
        TargetVersion VARCHAR(50),
        SourceType    VARCHAR(20)
    );

    IF @TableName IS NOT NULL
    BEGIN
        DECLARE @BaseTableName NVARCHAR(250) = @TableName;
        IF LOWER(@BaseTableName) LIKE '%_html'
            SET @BaseTableName = SUBSTRING(@BaseTableName, 1, LEN(@BaseTableName) - 5);
        IF LOWER(@BaseTableName) LIKE '%_beta'
            SET @BaseTableName = SUBSTRING(@BaseTableName, 1, LEN(@BaseTableName) - 5);

        -- Form phải thuộc #NeedToScan
        IF NOT EXISTS (
            SELECT 1 FROM #NeedToScan
            WHERE Name = @TableName OR Name = @BaseTableName
        )
        BEGIN
            PRINT N'>> [BỎ QUA] Form ' + @TableName + N' không thuộc danh sách cần quét.';
            RETURN;
        END;

        IF OBJECT_ID('dbo.tblHtmlScriptCache', 'U') IS NOT NULL
        BEGIN
            INSERT INTO #CandidateForms (TableName, LanguageID, TargetVersion, SourceType)
            SELECT DISTINCT s.TableName, ISNULL(NULLIF(s.LanguageID, ''), 'VN'), CAST(s.[Version] AS VARCHAR(50)), 'ScriptCache'
            FROM dbo.tblHtmlScriptCache s WITH (NOLOCK)
            WHERE s.TableName IN (@BaseTableName, @BaseTableName + '_html', @BaseTableName + '_Beta', @BaseTableName + '_html_Beta', @TableName, @TableName + '_Beta');
        END;

        IF NOT EXISTS (SELECT 1 FROM #CandidateForms) AND OBJECT_ID('dbo.tblHtmlMobile', 'U') IS NOT NULL
        BEGIN
            INSERT INTO #CandidateForms (TableName, LanguageID, TargetVersion, SourceType)
            SELECT DISTINCT m.TableName, ISNULL(NULLIF(m.LanguageID, ''), 'VN'), CAST(m.[Version] AS VARCHAR(50)), 'Mobile'
            FROM dbo.tblHtmlMobile m WITH (NOLOCK)
            WHERE m.TableName IN (@BaseTableName, @TableName, @BaseTableName + '_Beta', @TableName + '_Beta');
        END;

        IF NOT EXISTS (SELECT 1 FROM #CandidateForms)
            INSERT INTO #CandidateForms VALUES (@TableName, 'VN', 'MANUAL_1', 'Manual');
    END
    ELSE
    BEGIN
        -- BATCH: Chỉ nạp các Form có trong #NeedToScan
        IF OBJECT_ID('dbo.tblHtmlScriptCache', 'U') IS NOT NULL
        BEGIN
            INSERT INTO #CandidateForms (TableName, LanguageID, TargetVersion, SourceType)
            SELECT DISTINCT s.TableName, ISNULL(NULLIF(s.LanguageID, ''), 'VN'), CAST(s.[Version] AS VARCHAR(50)), 'ScriptCache'
            FROM dbo.tblHtmlScriptCache s WITH (NOLOCK)
            WHERE ISNULL(s.TableName, '') <> ''
              AND (s.TableName IN (SELECT Name FROM #NeedToScan)
                   OR REPLACE(REPLACE(s.TableName, '_html', ''), '_Beta', '') IN (SELECT Name FROM #NeedToScan));
        END;

        IF OBJECT_ID('dbo.tblHtmlMobile', 'U') IS NOT NULL
        BEGIN
            INSERT INTO #CandidateForms (TableName, LanguageID, TargetVersion, SourceType)
            SELECT DISTINCT m.TableName, ISNULL(NULLIF(m.LanguageID, ''), 'VN'), CAST(m.[Version] AS VARCHAR(50)), 'Mobile'
            FROM dbo.tblHtmlMobile m WITH (NOLOCK)
            WHERE ISNULL(m.TableName, '') <> ''
              AND (m.TableName IN (SELECT Name FROM #NeedToScan)
                   OR REPLACE(REPLACE(m.TableName, '_html', ''), '_Beta', '') IN (SELECT Name FROM #NeedToScan))
              AND NOT EXISTS (SELECT 1 FROM #CandidateForms c WHERE c.TableName = m.TableName);
        END;
    END;

    IF OBJECT_ID('tempdb..#TargetForms') IS NOT NULL DROP TABLE #TargetForms;
    CREATE TABLE #TargetForms (
        RowID         INT IDENTITY(1,1) PRIMARY KEY,
        TableName     NVARCHAR(250),
        LanguageID    VARCHAR(10),
        TargetVersion VARCHAR(50)
    );

    IF @TableName IS NOT NULL
    BEGIN
        INSERT INTO #TargetForms (TableName, LanguageID, TargetVersion)
        SELECT DISTINCT TableName, LanguageID, TargetVersion FROM #CandidateForms;
    END
    ELSE
    BEGIN
        INSERT INTO #TargetForms (TableName, LanguageID, TargetVersion)
        SELECT TOP (@BatchSize) c.TableName, c.LanguageID, c.TargetVersion
        FROM #CandidateForms c
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.tblSC_UserAPIRight r
            WHERE r.TableName = c.TableName AND r.LanguageID = c.LanguageID
              AND ISNULL(r.[Version], '') = ISNULL(c.TargetVersion, '')
        )
        ORDER BY c.TableName ASC;
    END;

    IF OBJECT_ID('tempdb..#CandidateForms') IS NOT NULL DROP TABLE #CandidateForms;

    -- =========================================================================
    -- BƯỚC 2: VÒNG LẶP QUÉT TỪNG FORM
    -- =========================================================================
    DECLARE @MaxRowID INT = 0;
    SELECT @MaxRowID = ISNULL(MAX(RowID), 0) FROM #TargetForms;

    DECLARE @CurRowID INT = 1;
    WHILE @CurRowID <= @MaxRowID
    BEGIN
        DECLARE @CurTableName     NVARCHAR(250);
        DECLARE @CurLang          VARCHAR(10);
        DECLARE @CurTargetVersion VARCHAR(50);

        SELECT @CurTableName = TableName, @CurLang = LanguageID, @CurTargetVersion = TargetVersion
        FROM #TargetForms WHERE RowID = @CurRowID;

        DECLARE @CleanTableName NVARCHAR(250) = @CurTableName;
        IF LOWER(@CleanTableName) LIKE '%_html'
            SET @CleanTableName = SUBSTRING(@CleanTableName, 1, LEN(@CleanTableName) - 5);
        IF LOWER(@CleanTableName) LIKE '%_beta'
            SET @CleanTableName = SUBSTRING(@CleanTableName, 1, LEN(@CleanTableName) - 5);

        IF OBJECT_ID('tempdb..#CurFormObjects') IS NOT NULL DROP TABLE #CurFormObjects;
        CREATE TABLE #CurFormObjects (
            RawText    NVARCHAR(250) NULL,
            SchemaName NVARCHAR(50) NULL,
            ObjectName VARCHAR(250),
            ObjectType VARCHAR(50),
            ObjectID   INT NULL,
            isLike     INT NULL
        );

        IF OBJECT_ID('tempdb..#FoundAPIs') IS NOT NULL DROP TABLE #FoundAPIs;
        CREATE TABLE #FoundAPIs (api VARCHAR(250) PRIMARY KEY);

        DECLARE @CurHtml NVARCHAR(MAX) = NULL;
        IF OBJECT_ID('dbo.tblHtmlScriptCache', 'U') IS NOT NULL
            SELECT TOP 1 @CurHtml = html FROM dbo.tblHtmlScriptCache WITH (NOLOCK) WHERE TableName = @CurTableName AND LanguageID = @CurLang;

        IF @CurHtml IS NULL AND OBJECT_ID('dbo.tblHtmlMobile', 'U') IS NOT NULL
            SELECT TOP 1 @CurHtml = html FROM dbo.tblHtmlMobile WITH (NOLOCK) WHERE TableName = @CurTableName AND LanguageID = @CurLang;

        IF OBJECT_ID('dbo.sp_scanAPI_ExtractObjects', 'P') IS NOT NULL
            EXEC dbo.sp_scanAPI_ExtractObjects @ProcName = @CurTableName;

        IF OBJECT_ID('dbo.tblsc_objectScan', 'U') IS NOT NULL
        BEGIN
            UPDATE c SET c.ObjectID = o.ObjectID, c.isLike = o.isLike
            FROM #CurFormObjects c
            INNER JOIN dbo.tblsc_objectScan o WITH (NOLOCK) ON o.TableName = @CurTableName AND o.ObjectName = c.ObjectName;

            INSERT INTO #CurFormObjects (ObjectName, ObjectType, ObjectID, isLike)
            SELECT DISTINCT o.ObjectName, 'SQL_STORED_PROCEDURE', o.ObjectID, o.isLike
            FROM dbo.tblsc_objectScan o WITH (NOLOCK)
            WHERE o.TableName = @CurTableName AND ISNULL(o.ObjectName, '') <> ''
              AND NOT EXISTS (SELECT 1 FROM #CurFormObjects c WHERE c.ObjectName = o.ObjectName);
        END;

        -- Gom API, loại trừ các component không cần phân quyền
        INSERT INTO #FoundAPIs (api)
        SELECT DISTINCT ObjectName
        FROM #CurFormObjects
        WHERE ObjectType IN ('SQL_STORED_PROCEDURE', 'SQL_SCALAR_FUNCTION', 'SQL_TABLE_VALUED_FUNCTION', 'SQL_INLINE_TABLE_VALUED_FUNCTION')
          AND ObjectName NOT IN (SELECT api FROM #FoundAPIs)
          AND ObjectName NOT IN (SELECT TableName FROM #TableName_NoPermission);

        -- Gom quyền người dùng cho Form từ kết quả sp_SC_Right
        IF OBJECT_ID('tempdb..#TmpRights') IS NOT NULL DROP TABLE #TmpRights;
        CREATE TABLE #TmpRights (LoginID INT, FullAccess VARCHAR(10), RightsCount INT);

        DECLARE @RootObjectID INT = NULL;

        SELECT TOP 1 @RootObjectID = o.ObjectID
        FROM dbo.tblSC_Object o WITH (NOLOCK)
        LEFT JOIN dbo.MEN_Menu m WITH (NOLOCK) ON o.Description = m.MenuID OR o.ObjectName = m.MenuID
        WHERE (
            LOWER(m.ClassName) = LOWER(@CurTableName) OR LOWER(m.ClassName) = LOWER(@CleanTableName)
            OR LOWER(m.ClassName) = LOWER('sp_' + @CleanTableName) OR LOWER(m.ClassName) = LOWER('sp_' + @CurTableName)
            OR LOWER(o.ObjectName) = LOWER(@CurTableName) OR LOWER(o.ObjectName) = LOWER(@CleanTableName)
            OR LOWER(o.ObjectName) = LOWER('sp_' + @CleanTableName) OR LOWER(o.ObjectName) = LOWER('sp_' + @CurTableName)
            OR LOWER(o.ObjectName) = LOWER(@CleanTableName + '_html') OR LOWER(o.ObjectName) = LOWER('sp_' + @CleanTableName + '_html')
            OR LOWER(o.ObjectName) = LOWER('DataSetting.' + @CleanTableName) OR LOWER(o.ObjectName) = LOWER('DataSetting.' + @CurTableName)
            OR LOWER(o.ObjectName) LIKE '%.' + LOWER(@CleanTableName) OR LOWER(o.ObjectName) LIKE '%.' + LOWER(@CurTableName)
            OR LOWER(o.Description) = LOWER(@CurTableName) OR LOWER(o.Description) = LOWER(@CleanTableName)
            OR LOWER(o.Description) = LOWER('sp_' + @CleanTableName)
        )
        ORDER BY
            CASE WHEN EXISTS (SELECT 1 FROM #AllUserRights rs WHERE rs.ObjectID = o.ObjectID AND rs.FullAccess <> '0') THEN 0
                 WHEN EXISTS (SELECT 1 FROM dbo.tblSC_Right_Stored rs WITH (NOLOCK) WHERE rs.ObjectID = o.ObjectID) THEN 1 ELSE 2 END ASC,
            CASE
                WHEN LOWER(m.ClassName) = LOWER(@CurTableName) OR LOWER(m.ClassName) = LOWER(@CleanTableName) THEN 1
                WHEN LOWER(m.ClassName) = LOWER('sp_' + @CleanTableName) THEN 2
                WHEN LOWER(o.ObjectName) = LOWER(@CurTableName) OR LOWER(o.ObjectName) = LOWER(@CleanTableName) THEN 3
                ELSE 4
            END ASC;

        IF @RootObjectID IS NULL
        BEGIN
            SELECT TOP 1 @RootObjectID = o.ObjectID
            FROM dbo.tblSC_Object o WITH (NOLOCK)
            INNER JOIN #FoundAPIs a ON LOWER(o.ObjectName) = LOWER(a.api) OR LOWER(o.ObjectName) = LOWER('sp_' + a.api)
                OR LOWER(o.ObjectName) = LOWER('DataSetting.' + a.api) OR LOWER(o.Description) = LOWER(a.api)
            ORDER BY
                CASE WHEN EXISTS (SELECT 1 FROM #AllUserRights rs WHERE rs.ObjectID = o.ObjectID AND rs.FullAccess <> '0') THEN 0
                     WHEN EXISTS (SELECT 1 FROM dbo.tblSC_Right_Stored rs WITH (NOLOCK) WHERE rs.ObjectID = o.ObjectID) THEN 1 ELSE 2 END ASC;
        END;

        IF @RootObjectID IS NOT NULL
        BEGIN
            DECLARE @CurRightsHash INT = 0;
            SELECT @CurRightsHash = COUNT(1) FROM #AllUserRights WHERE ObjectID = @RootObjectID AND FullAccess <> '0';

            -- 1. Ưu tiên lấy trực tiếp từ sp_SC_Right (#AllUserRights)
            INSERT INTO #TmpRights (LoginID, FullAccess, RightsCount)
            SELECT r.LoginID,
                   CASE WHEN r.FullAccess = '32' THEN '32' ELSE '1' END,
                   @CurRightsHash
            FROM #AllUserRights r
            WHERE r.ObjectID = @RootObjectID
              AND ISNULL(r.FullAccess, '0') <> '0'
              AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = r.LoginID);

            -- 2. Fallback nếu sp_SC_Right chưa có dữ liệu cho ObjectID này (lấy từ tblSC_Right_Stored)
            IF NOT EXISTS (SELECT 1 FROM #TmpRights) AND @HasRightStoredTable = 1
            BEGIN
                INSERT INTO #TmpRights (LoginID, FullAccess, RightsCount)
                SELECT rs.LoginID, CASE WHEN rs.FullAccess = 32 THEN '32' ELSE '1' END, @CurRightsHash
                FROM dbo.tblSC_Right_Stored rs WITH (NOLOCK)
                WHERE rs.ObjectID = @RootObjectID
                  AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = rs.LoginID);
            END;
        END;

        IF OBJECT_ID('tempdb..#NewRights') IS NOT NULL DROP TABLE #NewRights;
        CREATE TABLE #NewRights (
            TableName NVARCHAR(250), LoginID INT, api VARCHAR(250), ObjectID INT NULL,
            FullAccess VARCHAR(10), [Version] VARCHAR(50), LanguageID VARCHAR(10), RightsCount INT NULL, isLike INT NULL
        );

        INSERT INTO #NewRights (TableName, LoginID, api, ObjectID, FullAccess, [Version], LanguageID, RightsCount, isLike)
        SELECT DISTINCT @CurTableName, r.LoginID, f.api, c.ObjectID, r.FullAccess, @CurTargetVersion, @CurLang, r.RightsCount,
            CASE WHEN sc.isLike = 1 AND EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = r.LoginID) THEN 1 ELSE NULL END
        FROM #TmpRights r
        CROSS JOIN #FoundAPIs f
        LEFT JOIN #CurFormObjects c ON c.ObjectName = f.api
        LEFT JOIN dbo.tblsc_objectScan sc WITH (NOLOCK) ON sc.TableName = @CurTableName AND sc.ObjectName = f.api;

        -- Với các Stored Procedure thay đổi dữ liệu (isChangeData = 1): Chỉ cấp cho người có FullAccess = '32'
        DELETE n FROM #NewRights n
        INNER JOIN dbo.tblsc_objectScan sc WITH (NOLOCK) ON sc.TableName = @CurTableName AND sc.ObjectName = n.api AND sc.isChangeData = 1
        WHERE n.FullAccess <> '32';

        -- Với các Stored Procedure duyệt đơn, từ chối, hủy đơn (isLike = 1): Chỉ cấp cho người có quyền duyệt (#ApproverLogins)
        DELETE n FROM #NewRights n
        INNER JOIN dbo.tblsc_objectScan sc WITH (NOLOCK) ON sc.TableName = @CurTableName AND sc.ObjectName = n.api AND sc.isLike = 1
        WHERE NOT EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = n.LoginID);

        -- Ghi vào tblSC_UserAPIRight
        DECLARE @RowsWrittenThisForm INT = 0;
        IF OBJECT_ID('dbo.tblSC_UserAPIRight', 'U') IS NOT NULL
        BEGIN
            DELETE r FROM dbo.tblSC_UserAPIRight r
            WHERE r.TableName = @CurTableName AND r.LanguageID = @CurLang;

            INSERT INTO dbo.tblSC_UserAPIRight (TableName, LoginID, api, ObjectID, FullAccess, [Version], LanguageID, RightsCount, isLike, LastUpdated)
            SELECT TableName, LoginID, api, ObjectID, FullAccess, [Version], LanguageID, RightsCount, isLike, GETDATE()
            FROM #NewRights;

            SET @RowsWrittenThisForm = @@ROWCOUNT;
        END;

        -- Đồng bộ vào tblApiParadisePrivilege (Hỗ trợ cả FullAccess = '1' cho API đọc và '32' cho toàn quyền)
        IF OBJECT_ID('dbo.tblApiParadisePrivilege', 'U') IS NOT NULL
        BEGIN
            DELETE p FROM dbo.tblApiParadisePrivilege p
            WHERE EXISTS (SELECT 1 FROM #FoundAPIs a WHERE a.api = p.Name)
              AND p.LoginID NOT IN (SELECT LoginID FROM #ValidLogins);

            DELETE p FROM dbo.tblApiParadisePrivilege p
            WHERE EXISTS (SELECT 1 FROM #FoundAPIs a WHERE a.api = p.Name)
              AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = p.LoginID)
              AND NOT EXISTS (SELECT 1 FROM #NewRights r WHERE r.api = p.Name AND r.LoginID = p.LoginID);

            INSERT INTO dbo.tblApiParadisePrivilege (Name, LoginID, Token)
            SELECT DISTINCT r.api, r.LoginID, NULL
            FROM #NewRights r
            WHERE ISNULL(r.api, '') <> ''
              AND r.api NOT IN (SELECT TableName FROM #TableName_NoPermission)
              AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = r.LoginID)
              AND NOT EXISTS (SELECT 1 FROM dbo.tblApiParadisePrivilege p WHERE p.Name = r.api AND p.LoginID = r.LoginID);
        END;

        IF @HasScanStateTable = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.tblSC_UserAPIScanState WHERE TableName = @CurTableName AND LanguageID = @CurLang)
                UPDATE dbo.tblSC_UserAPIScanState SET [Version] = @CurTargetVersion, LastScan = GETDATE(), RowsWritten = @RowsWrittenThisForm
                WHERE TableName = @CurTableName AND LanguageID = @CurLang;
            ELSE
                INSERT INTO dbo.tblSC_UserAPIScanState (TableName, LanguageID, [Version], LastScan, RowsWritten)
                VALUES (@CurTableName, @CurLang, @CurTargetVersion, GETDATE(), @RowsWrittenThisForm);
        END;

        SET @FormsScannedThisRun = @FormsScannedThisRun + 1;
        SET @TotalRowsWritten = @TotalRowsWritten + @RowsWrittenThisForm;

        IF OBJECT_ID('tempdb..#CurFormObjects') IS NOT NULL DROP TABLE #CurFormObjects;
        IF OBJECT_ID('tempdb..#FoundAPIs') IS NOT NULL DROP TABLE #FoundAPIs;
        IF OBJECT_ID('tempdb..#TmpRights') IS NOT NULL DROP TABLE #TmpRights;
        IF OBJECT_ID('tempdb..#NewRights') IS NOT NULL DROP TABLE #NewRights;

        SET @CurRowID = @CurRowID + 1;
    END;

    -- =========================================================================
    -- PHẦN 2: ĐỒNG BỘ TOÀN BỘ tblSC_UserAPIRight SANG tblApiParadisePrivilege (CHỈ KHI BATCH)
    -- =========================================================================
    IF @TableName IS NULL AND OBJECT_ID('dbo.tblApiParadisePrivilege', 'U') IS NOT NULL
    BEGIN
        -- Dọn tblSC_UserAPIRight: xóa các Form không thuộc #NeedToScan
        DELETE r FROM dbo.tblSC_UserAPIRight r
        WHERE r.TableName IN (SELECT TableName FROM #TableName_NoPermission)
           OR r.api IN (SELECT TableName FROM #TableName_NoPermission);

        DELETE p FROM dbo.tblApiParadisePrivilege p WHERE p.LoginID NOT IN (SELECT LoginID FROM #ValidLogins);

        DELETE p FROM dbo.tblApiParadisePrivilege p
        WHERE EXISTS (SELECT 1 FROM dbo.tblSC_UserAPIRight r WHERE r.api = p.Name)
          AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = p.LoginID)
          AND NOT EXISTS (SELECT 1 FROM dbo.tblSC_UserAPIRight r WHERE r.api = p.Name AND r.LoginID = p.LoginID);

        -- Insert toàn bộ từ UserAPIRight sang tblApiParadisePrivilege (Cả FullAccess 1 và 32)
        INSERT INTO dbo.tblApiParadisePrivilege (Name, LoginID, Token)
        SELECT DISTINCT r.api, r.LoginID, NULL
        FROM dbo.tblSC_UserAPIRight r
        WHERE ISNULL(r.api, '') <> ''
          AND r.api NOT IN (SELECT TableName FROM #TableName_NoPermission)
          AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = r.LoginID)
          AND NOT EXISTS (SELECT 1 FROM dbo.tblApiParadisePrivilege p WHERE p.Name = r.api AND p.LoginID = r.LoginID);

        -- Đồng bộ kế thừa nhóm cho các tài khoản con có UseGroupRightOnly = 1 (Dự phòng tuyệt đối)
        INSERT INTO dbo.tblApiParadisePrivilege (Name, LoginID, Token)
        SELECT DISTINCT p.Name, lg.LoginID, NULL
        FROM dbo.tblApiParadisePrivilege p
        INNER JOIN dbo.tblSC_Login lg WITH (NOLOCK) 
           ON ('&' + REPLACE(lg.ParentLoginID, ' ', '') + '&' LIKE '%&' + CAST(p.LoginID AS VARCHAR(20)) + '&%')
        WHERE ISNULL(lg.ParentLoginID, '') <> '' AND ISNULL(lg.UseGroupRightOnly, 0) = 1
          AND (
              NOT EXISTS (SELECT 1 FROM dbo.tblsc_objectScan sc WHERE sc.ObjectName = p.Name AND ISNULL(sc.isLike, 0) = 1)
              OR EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = lg.LoginID)
          )
          AND NOT EXISTS (
              SELECT 1 FROM dbo.tblApiParadisePrivilege existing 
              WHERE existing.Name = p.Name AND existing.LoginID = lg.LoginID
          );

        -- Bảo vệ triệt để: Xóa bỏ mọi API có isLike = 1 khỏi tài khoản KHÔNG nằm trong #ApproverLogins
        DELETE p FROM dbo.tblApiParadisePrivilege p
        INNER JOIN dbo.tblsc_objectScan sc WITH (NOLOCK) ON sc.ObjectName = p.Name AND ISNULL(sc.isLike, 0) = 1
        WHERE NOT EXISTS (SELECT 1 FROM #ApproverLogins a WHERE a.LoginID = p.LoginID);
    END;

    -- =========================================================================
    -- PHẦN 3: LƯU tblsc_table_fullaccess (CHỈ KHI BATCH)
    -- =========================================================================
    IF @TableName IS NULL AND OBJECT_ID('dbo.tblsc_table_fullaccess', 'U') IS NOT NULL
    BEGIN
        DELETE f FROM dbo.tblsc_table_fullaccess f
        WHERE NOT EXISTS (SELECT 1 FROM dbo.tblSC_UserAPIRight r WHERE r.api = f.Name AND r.LoginID = f.LoginID AND r.FullAccess = '32');

        IF OBJECT_ID('tempdb..#AllPriv') IS NOT NULL DROP TABLE #AllPriv;
        SELECT DISTINCT r.api AS Name, r.LoginID, OBJECT_ID('dbo.' + r.api) AS Oid
        INTO #AllPriv
        FROM dbo.tblSC_UserAPIRight r
        WHERE r.FullAccess = '32' AND ISNULL(r.api, '') <> ''
          AND r.api NOT IN (SELECT TableName FROM #TableName_NoPermission)
          AND EXISTS (SELECT 1 FROM #ValidLogins v WHERE v.LoginID = r.LoginID);

        INSERT INTO dbo.tblsc_table_fullaccess (Name, TableNameEditor, LoginID)
        SELECT DISTINCT b.Name, o.name, b.LoginID
        FROM #AllPriv b
        JOIN sys.sql_expression_dependencies d ON d.referencing_id = b.Oid
        JOIN sys.objects o ON o.object_id = d.referenced_id AND o.type = 'U'
        WHERE b.Oid IS NOT NULL
          AND LOWER(o.name) NOT LIKE 'tblsc_%'
          AND LOWER(o.name) NOT LIKE 'tbl%log%'
          AND LOWER(o.name) NOT IN ('tblhtmlscriptcache', 'tblhtmlmobile', 'tblhtmlcache', 'taskschedule', 'tblerrordetail', 'tblapiparadiseprivilege')
          AND NOT EXISTS (SELECT 1 FROM dbo.tblsc_table_fullaccess f WHERE f.Name = b.Name AND f.TableNameEditor = o.name AND f.LoginID = b.LoginID);

        INSERT INTO dbo.tblsc_table_fullaccess (Name, TableNameEditor, LoginID)
        SELECT DISTINCT f.Name, f.TableNameEditor, lg.LoginID
        FROM dbo.tblsc_table_fullaccess f
        INNER JOIN dbo.tblSC_Login lg WITH (NOLOCK) ON ('&' + REPLACE(lg.ParentLoginID, ' ', '') + '&' LIKE '%&' + CAST(f.LoginID AS VARCHAR(20)) + '&%')
        WHERE ISNULL(lg.ParentLoginID, '') <> '' AND ISNULL(lg.UseGroupRightOnly, 0) = 1
          AND NOT EXISTS (SELECT 1 FROM dbo.tblsc_table_fullaccess existing WHERE existing.Name = f.Name AND existing.TableNameEditor = f.TableNameEditor AND existing.LoginID = lg.LoginID);

        IF OBJECT_ID('tempdb..#AllPriv') IS NOT NULL DROP TABLE #AllPriv;
    END;

    -- Dọn sạch lần cuối: đảm bảo không lọt component layout vào tblApiParadisePrivilege
    IF OBJECT_ID('dbo.tblApiParadisePrivilege', 'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.tblApiParadisePrivilege WHERE Name IN (SELECT TableName FROM #TableName_NoPermission);
    END;

    -- =========================================================================
    -- PHẦN 4: KIỂM TRA LỊCH TASKSCHEDULE
    -- =========================================================================
    IF @TableName IS NULL AND OBJECT_ID('dbo.TaskSchedule', 'U') IS NOT NULL
    BEGIN
        DECLARE @HasRemainingForms BIT = 0;
        IF EXISTS (
            SELECT TOP 1 1
            FROM dbo.tblHtmlScriptCache s WITH (NOLOCK)
            WHERE ISNULL(s.TableName, '') <> ''
              AND (s.TableName IN (SELECT Name FROM #NeedToScan)
                   OR REPLACE(REPLACE(s.TableName, '_html', ''), '_Beta', '') IN (SELECT Name FROM #NeedToScan))
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.tblSC_UserAPIRight r WITH (NOLOCK)
                  WHERE r.TableName = s.TableName AND r.LanguageID = s.LanguageID
                    AND ISNULL(r.[Version], '') = ISNULL(CAST(s.[Version] AS VARCHAR(50)), '')
              )
        )
            SET @HasRemainingForms = 1;

        IF @HasRemainingForms = 0 AND OBJECT_ID('dbo.tblHtmlMobile', 'U') IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT TOP 1 1
                FROM dbo.tblHtmlMobile m WITH (NOLOCK)
                WHERE ISNULL(m.TableName, '') <> ''
                  AND (m.TableName IN (SELECT Name FROM #NeedToScan)
                       OR REPLACE(REPLACE(m.TableName, '_html', ''), '_Beta', '') IN (SELECT Name FROM #NeedToScan))
                  AND NOT EXISTS (
                      SELECT 1 FROM dbo.tblSC_UserAPIRight r WITH (NOLOCK)
                      WHERE r.TableName = m.TableName AND r.LanguageID = m.LanguageID
                        AND ISNULL(r.[Version], '') = ISNULL(CAST(m.[Version] AS VARCHAR(50)), '')
                  )
            )
                SET @HasRemainingForms = 1;
        END;

        IF @HasRemainingForms = 1
            UPDATE dbo.TaskSchedule SET RepeatMinutes = 1, NextRunDate = DATEADD(MINUTE, 1, GETDATE()) WHERE ProducerName = 'sp_scanAPI';
        ELSE
            UPDATE dbo.TaskSchedule SET RepeatMinutes = 30, NextRunDate = DATEADD(MINUTE, 30, GETDATE()) WHERE ProducerName = 'sp_scanAPI';
    END;

    -- Dọn dẹp bảng tạm
    IF OBJECT_ID('tempdb..#ExcludeTables') IS NOT NULL DROP TABLE #ExcludeTables;
    IF OBJECT_ID('tempdb..#ValidLogins') IS NOT NULL DROP TABLE #ValidLogins;
    IF OBJECT_ID('tempdb..#ApproverLogins') IS NOT NULL DROP TABLE #ApproverLogins;
    IF OBJECT_ID('tempdb..#AllUserRights') IS NOT NULL DROP TABLE #AllUserRights;
    IF OBJECT_ID('tempdb..#NeedToScan') IS NOT NULL DROP TABLE #NeedToScan;
    IF OBJECT_ID('tempdb..#TableName_NoPermission') IS NOT NULL DROP TABLE #TableName_NoPermission;
    IF OBJECT_ID('tempdb..#TargetForms') IS NOT NULL DROP TABLE #TargetForms;

    DECLARE @DurationMs INT = DATEDIFF(ms, @StartTime, GETDATE());
    DECLARE @ModeText NVARCHAR(50) = CASE WHEN @TableName IS NULL THEN N'Batch (' + CAST(@BatchSize AS NVARCHAR(10)) + N')' ELSE N'1 Form (' + @TableName + N')' END;

    SELECT 'SUCCESS' AS [Status], @ModeText AS [Mode], @FormsScannedThisRun AS SyncedForms, @TotalRowsWritten AS TotalRowsWritten, @DurationMs AS DurationMs,
           N'Hoàn tất (' + @ModeText + N': ' + CAST(@FormsScannedThisRun AS NVARCHAR(20)) + N' Form, ' + CAST(@TotalRowsWritten AS NVARCHAR(20)) + N' dòng, ' + CAST(@DurationMs AS NVARCHAR(20)) + N' ms).' AS [Message];
END;
GO

-- -----------------------------------------------------------------------------------------
-- PHẦN 4: THỰC THI QUÉT VÀ CẤP LẠI TOÀN BỘ QUYỀN API CHO HỆ THỐNG
-- -----------------------------------------------------------------------------------------
PRINT N'Đang thực thi quét và cấp lại quyền API toàn diện...';
EXEC [dbo].[sp_scanAPI];
GO

-- -----------------------------------------------------------------------------------------
-- PHẦN 5: TRUY VẤN KIỂM TRA ĐỐI SOÁT SAU KHI CHẠY (ThanhLong phải đạt > 1,400 quyền API)
-- -----------------------------------------------------------------------------------------
SELECT 
    l.LoginID, 
    l.LoginName, 
    e.FullName,
    l.ParentLoginID,
    l.UseGroupRightOnly,
    COUNT(p.Name) AS [TongSoAPI_DuocCapQuyen]
FROM dbo.tblSC_Login l WITH (NOLOCK)
LEFT JOIN dbo.tblEmployee e WITH (NOLOCK) ON l.EmployeeID = e.EmployeeID
LEFT JOIN dbo.tblApiParadisePrivilege p WITH (NOLOCK) ON p.LoginID = l.LoginID
WHERE l.LoginID IN (20, 21, 22)
GROUP BY l.LoginID, l.LoginName, e.FullName, l.ParentLoginID, l.UseGroupRightOnly
ORDER BY l.LoginID;
GO
