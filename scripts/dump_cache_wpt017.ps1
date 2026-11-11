$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_AttendanceConfirmRequest' AND LanguageID = 'VN'"
$html = $cmd.ExecuteScalar()
if ($html) {
    [System.IO.File]::WriteAllText('c:\Users\Y.Thach\Desktop\paradiseHR\scripts\sp_AttendanceConfirmRequest_cache.html', $html.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "SAVED sp_AttendanceConfirmRequest_cache.html, Length: " $html.ToString().Length
} else {
    Write-Host "Not found in tblHtmlScriptCache"
}
$conn.Close()
