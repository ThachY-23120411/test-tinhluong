$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$sql = "SELECT DISTINCT TableName FROM tblHtmlScriptCache WHERE TableName LIKE '%Sub%' OR TableName LIKE '%Quotation%' OR TableName LIKE '%BaoGia%' OR TableName LIKE '%PhanHe%'"
$da = New-Object System.Data.SqlClient.SqlDataAdapter($sql, $connStr)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$dt | Format-Table -AutoSize
