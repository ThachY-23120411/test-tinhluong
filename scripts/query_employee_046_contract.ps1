$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Check Employee 046
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT EmployeeID, FullName, WorkingStatusID, HireDate, ResignDate, DepartmentID, PositionID FROM tblEmployee WHERE EmployeeID = '046' OR FullName LIKE N'%Đặng Minh Tài%'"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dtEmp = New-Object System.Data.DataTable
$adapter.Fill($dtEmp) | Out-Null
Write-Output "=== EMPLOYEE 046 ==="
$dtEmp | Format-Table -AutoSize

# 2. Check Labour Contract for 046
$cmd.CommandText = "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%LabourContract%' OR TABLE_NAME LIKE '%Contract%'"
$dtTables = New-Object System.Data.DataTable
$adapter.Fill($dtTables) | Out-Null
Write-Output "=== CONTRACT TABLES ==="
$dtTables | Format-Table -AutoSize

# 3. Check Salary History / Contract for 046
$cmd.CommandText = "SELECT TOP 5 * FROM tblSalaryHistory WHERE EmployeeID = '046'"
$dtSalHist = New-Object System.Data.DataTable
$adapter.Fill($dtSalHist) | Out-Null
Write-Output "=== tblSalaryHistory FOR 046 ==="
$dtSalHist | Format-Table -AutoSize

$conn.Close()
