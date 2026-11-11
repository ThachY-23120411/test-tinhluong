$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_PaySlipView'))"
$def = $cmd.ExecuteScalar()
$conn.Close()

$match = [regex]::Matches($def, 'SELECT[\s\S]*?FROM[\s\S]*?(?:WHERE|ORDER BY|\Z)')
foreach ($m in $match) {
    if ($m.Value.Length -gt 300) {
        Write-Output "--- QUERY ---"
        Write-Output $m.Value.Substring(0, [Math]::Min(1000, $m.Value.Length))
    }
}
