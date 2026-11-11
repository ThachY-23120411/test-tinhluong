$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Columns of tblLabourContract
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblLabourContract'"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
Write-Output "=== COLUMNS OF tblLabourContract ==="
$dt | Format-Table -AutoSize

# Find tables with family
$cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Family%'"
$dtFamTables = New-Object System.Data.DataTable
$adapter.Fill($dtFamTables) | Out-Null
Write-Output "=== TABLES WITH FAMILY ==="
$dtFamTables | Format-Table -AutoSize

$conn.Close()
