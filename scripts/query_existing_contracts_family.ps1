$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Check which employees have contracts and salaries
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT lc.EmployeeID, e.FullName, lc.ContractNo, lc.Salary, l.LoginName
FROM tblLabourContract lc
INNER JOIN tblEmployee e ON lc.EmployeeID = e.EmployeeID
LEFT JOIN tblSC_Login l ON lc.EmployeeID = l.EmployeeID
ORDER BY lc.EmployeeID
"@
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
Write-Output "=== EMPLOYEES WITH LABOUR CONTRACT ==="
$dt | Format-Table -AutoSize

# Check tblPersonFamily for any employees
$cmd.CommandText = "SELECT EmployeeID, RelativeName, RelationID, IsTaxReduction, TaxReductionFromDate FROM tblPersonFamily"
$dtFam = New-Object System.Data.DataTable
$adapter.Fill($dtFam) | Out-Null
Write-Output "`n=== tblPersonFamily RECORDS ==="
$dtFam | Format-Table -AutoSize

$conn.Close()
