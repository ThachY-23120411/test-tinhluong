$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$sql = "SELECT OBJECT_NAME(object_id) as sp_name FROM sys.sql_modules WHERE definition LIKE N'%Thêm phân hệ%' OR definition LIKE N'%Quản lý phân hệ%'"
$da = New-Object System.Data.SqlClient.SqlDataAdapter($sql, $connStr)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$dt | Format-Table -AutoSize
