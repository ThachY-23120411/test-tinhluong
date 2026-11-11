$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- DEFINITION OF sp_StaffInformation_LoadDataListPheDuyet ---"
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_StaffInformation_LoadDataListPheDuyet'))"
$def = $cmd.ExecuteScalar()
Write-Output $def

$conn.Close()
