$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- TÌM CÁC BẢNG CÓ TỪ MENU ---"
$cmd.CommandText = "SELECT name FROM sys.tables WHERE name LIKE '%Menu%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['name'].ToString())
}
$reader.Close()

Write-Host "--- TÌM CÁC BẢNG CÓ CỘT MenuName HOẶC MenuID ---"
$cmd.CommandText = "SELECT t.name, c.name as col FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE c.name IN ('MenuID', 'MenuName')"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['name'].ToString() + ' -> ' + $reader['col'].ToString())
}
$reader.Close()

$conn.Close()
