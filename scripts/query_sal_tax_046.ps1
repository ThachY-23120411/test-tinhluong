$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Check tblSal_Sal for 046
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 Sal_Sal_ID, Month, Year, EmployeeID, BasicSalary, GrossTakeHome, TotalIncome, TotalDeductions FROM tblSal_Sal WHERE EmployeeID = '046' ORDER BY Year DESC, Month DESC"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dtSal = New-Object System.Data.DataTable
$adapter.Fill($dtSal) | Out-Null
Write-Output "=== tblSal_Sal FOR 046 ==="
$dtSal | Format-Table -AutoSize

# Check tblSal_Sal_Detail for 046
$cmd.CommandText = "SELECT TOP 5 Month, Year, EmployeeID, ActualMonthlyBasic, StandardWDays, DaysOfSalEntry FROM tblSal_Sal_Detail WHERE EmployeeID = '046' ORDER BY Year DESC, Month DESC"
$dtSalDt = New-Object System.Data.DataTable
$adapter.Fill($dtSalDt) | Out-Null
Write-Output "=== tblSal_Sal_Detail FOR 046 ==="
$dtSalDt | Format-Table -AutoSize

# Check tblSal_Tax for 046
$cmd.CommandText = "SELECT TOP 5 Month, Year, EmployeeID, DependantNumber, FamilyExemption, TaxAmt FROM tblSal_Tax WHERE EmployeeID = '046' ORDER BY Year DESC, Month DESC"
$dtTax = New-Object System.Data.DataTable
$adapter.Fill($dtTax) | Out-Null
Write-Output "=== tblSal_Tax FOR 046 ==="
$dtTax | Format-Table -AutoSize

# Check tblCurrentWorkingMonth
$cmd.CommandText = "SELECT * FROM tblCurrentWorkingMonth"
$dtCurMonth = New-Object System.Data.DataTable
$adapter.Fill($dtCurMonth) | Out-Null
Write-Output "=== tblCurrentWorkingMonth ==="
$dtCurMonth | Format-Table -AutoSize

$conn.Close()
