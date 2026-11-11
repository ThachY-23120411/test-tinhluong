$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- CAC STORED PROCEDURE SU DUNG tblAttendanceConfirmRequest ---"
$cmd.CommandText = "SELECT DISTINCT o.name FROM sys.objects o INNER JOIN sys.sql_modules m ON o.object_id = m.object_id WHERE m.definition LIKE '%tblAttendanceConfirmRequest%' AND o.type = 'P'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['name'].ToString())
}
$reader.Close()

$conn.Close()
