$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 lc.ContractID, lc.EmployeeID, lc.ContractNo, lc.SalaryHistoryID, sh.Salary, sh.InsSalary FROM tblLabourContract lc LEFT JOIN tblSalaryHistory sh ON lc.SalaryHistoryID = sh.SalaryHistoryID WHERE lc.EmployeeID IN ('003', '011', '013', '014')"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
Write-Output "=== CONTRACT SALARY LINK ==="
$dt | Format-Table -AutoSize

$conn.Close()
