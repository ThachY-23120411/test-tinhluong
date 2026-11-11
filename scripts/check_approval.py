import pyodbc

conn_str = 'DRIVER={ODBC Driver 17 for SQL Server};SERVER=192.168.11.51,2222;DATABASE=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'

try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    print("=== 1. TÌM MENU DANH SÁCH PHÊ DUYỆT ===")
    cursor.execute("SELECT MenuID, MenuName, TableName FROM tblMenu WHERE MenuName LIKE '%phê duyệt%' OR MenuName LIKE '%Duyệt%'")
    for row in cursor.fetchall():
        print(row)

    print("\n=== 2. TÌM BẢNG VÀ PROCEDURE DUYỆT / BÙ CÔNG ===")
    cursor.execute("SELECT TOP 20 name FROM sys.objects WHERE type IN ('U', 'P') AND (name LIKE '%Confirm%' OR name LIKE '%Approve%' OR name LIKE '%AttendanceConfirm%')")
    for row in cursor.fetchall():
        print(row)

    print("\n=== 3. XEM BẢNG tblAttendanceConfirmRequest (HOẶC TƯƠNG ĐƯƠNG) ===")
    cursor.execute("SELECT TOP 10 * FROM tblAttendanceConfirmRequest ORDER BY RequestDate DESC")
    cols = [col[0] for col in cursor.description]
    print("Columns:", cols)
    for row in cursor.fetchall():
        print(dict(zip(cols, row)))

    conn.close()
except Exception as e:
    print("Error:", e)
