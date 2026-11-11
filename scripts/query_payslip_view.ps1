$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_PaySlipView'))"
$def = $cmd.ExecuteScalar()
$conn.Close()
if ($def) {
    Write-Output $def.Substring(0, [Math]::Min(2000, $def.Length))
} else {
    Write-Output "sp_PaySlipView not found"
}
