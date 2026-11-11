$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_KPIContentPost_html'))"
$def = $cmd.ExecuteScalar()
$conn.Close()

$dest = "c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/noi_dung_dang_tai/origin.sql"
[System.IO.File]::WriteAllText($dest, $def, [System.Text.Encoding]::UTF8)
Write-Host "Extracted origin.sql successfully. Length: $($def.Length) chars."
