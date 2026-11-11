$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_InsertInOut')"
$def = $cmd.ExecuteScalar()
if ($def) {
    [System.IO.File]::WriteAllText('c:\Users\Y.Thach\Desktop\paradiseHR\scripts\sp_InsertInOut.sql', $def.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "SAVED sp_InsertInOut.sql, Length: " $def.ToString().Length
} else {
    Write-Host "sp_InsertInOut NOT FOUND"
}
$conn.Close()
