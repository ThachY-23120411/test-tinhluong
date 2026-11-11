$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;User Id=sa;Password=123;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

Write-Host "=== TBLCURRENTWORKINGMONTH ==="
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT * FROM tblCurrentWorkingMonth"
$r = $cmd.ExecuteReader()
while ($r.Read()) {
    Write-Host ("ID: " + $r["ID"] + " | Month: " + $r["Month"] + " | Year: " + $r["Year"])
}
$r.Close()

Write-Host "`n=== TBLFAMILYINFO COLUMNS & 003 RECORD ==="
$cmd.CommandText = "SELECT TOP 1 * FROM tblFamilyInfo WHERE EmployeeID = '003'"
$r = $cmd.ExecuteReader()
for ($i=0; $i -lt $r.FieldCount; $i++) {
    Write-Host ($r.GetName($i) + ": " + $r.GetValue($i))
}
$r.Close()

Write-Host "`n=== TBLLABOURCONTRACT COLUMNS & 003 RECORD ==="
$cmd.CommandText = "SELECT TOP 1 * FROM tblLabourContract WHERE EmployeeID = '003'"
$r = $cmd.ExecuteReader()
for ($i=0; $i -lt $r.FieldCount; $i++) {
    Write-Host ($r.GetName($i) + ": " + $r.GetValue($i))
}
$r.Close()

$conn.Close()
