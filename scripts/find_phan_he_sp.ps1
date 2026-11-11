$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$sql = "SELECT name FROM sys.procedures WHERE name LIKE '%Module%' OR name LIKE '%PhanHe%' OR name LIKE '%Price%' OR name LIKE '%BaoGia%' OR name LIKE '%Quotation%' OR name LIKE '%Package%' ORDER BY name"
$da = New-Object System.Data.SqlClient.SqlDataAdapter($sql, $connStr)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$dt | Format-Table -AutoSize
