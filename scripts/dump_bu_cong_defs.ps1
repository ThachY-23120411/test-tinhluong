$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_AttendanceConfirmRequest')"
$def = $cmd.ExecuteScalar()
if ($def) {
    [System.IO.File]::WriteAllText('c:\Users\Y.Thach\Desktop\paradiseHR\scripts\sp_AttendanceConfirmRequest.sql', $def.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "SAVED sp_AttendanceConfirmRequest.sql, Length: " $def.ToString().Length
}

$cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_AttendanceConfirmRequest_Submit')"
$def2 = $cmd.ExecuteScalar()
if ($def2) {
    [System.IO.File]::WriteAllText('c:\Users\Y.Thach\Desktop\paradiseHR\scripts\sp_AttendanceConfirmRequest_Submit.sql', $def2.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "SAVED sp_AttendanceConfirmRequest_Submit.sql, Length: " $def2.ToString().Length
}

$conn.Close()
