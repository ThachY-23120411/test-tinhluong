$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$sql = "SELECT name, type_desc FROM sys.objects WHERE name LIKE '%sp_Sub_%' ORDER BY name"
$da = New-Object System.Data.SqlClient.SqlDataAdapter($sql, $connStr)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$dt | Format-Table -AutoSize
