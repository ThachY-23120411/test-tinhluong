$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Check tblLabourContract for 046
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT * FROM tblLabourContract WHERE EmployeeID = '046'"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dtContracts = New-Object System.Data.DataTable
$adapter.Fill($dtContracts) | Out-Null
Write-Output "=== tblLabourContract FOR 046 ==="
Write-Output "Count: $($dtContracts.Rows.Count)"
$dtContracts | Format-Table -AutoSize

# 2. Check definition of sp_CurrentLabourContractDisplay
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CurrentLabourContractDisplay'))"
$def = $cmd.ExecuteScalar()
Write-Output "`n=== sp_CurrentLabourContractDisplay DEFINITION ==="
if ($def) {
    Write-Output $def.Substring(0, [Math]::Min(1500, $def.Length))
} else {
    Write-Output "Procedure not found"
}

# 3. Check what employees ARE in tblLabourContract
$cmd.CommandText = "SELECT DISTINCT EmployeeID FROM tblLabourContract"
$dtEmpsInContract = New-Object System.Data.DataTable
$adapter.Fill($dtEmpsInContract) | Out-Null
Write-Output "`n=== EMPLOYEES IN tblLabourContract ==="
$dtEmpsInContract | Format-Table -AutoSize

$conn.Close()
