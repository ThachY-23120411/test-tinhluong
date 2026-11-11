$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Check tblFamilyInfo
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 * FROM tblFamilyInfo"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
Write-Output "=== tblFamilyInfo ==="
$dt | Format-Table -AutoSize

# 2. Check tblFamilyInfo for 046
$cmd.CommandText = "SELECT * FROM tblFamilyInfo WHERE EmployeeID = '046'"
$dt046 = New-Object System.Data.DataTable
$adapter.Fill($dt046) | Out-Null
Write-Output "=== tblFamilyInfo FOR 046 ==="
Write-Output "Count: $($dt046.Rows.Count)"
$dt046 | Format-Table -AutoSize

$conn.Close()
