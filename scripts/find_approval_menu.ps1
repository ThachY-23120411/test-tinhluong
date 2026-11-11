$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- TÌM MENU DANH SÁCH PHÊ DUYỆT TRONG CACHE HOẶC SYSOBJECTS ---"
$cmd.CommandText = "SELECT DISTINCT TableName FROM tblHtmlScriptCache WHERE html LIKE N'%Danh sách phê duyệt%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['TableName'].ToString())
}
$reader.Close()

Write-Host "--- TÌM CÁC BẢNG LIÊN QUAN CONFIRM / REQUEST ---"
$cmd.CommandText = "SELECT name FROM sys.tables WHERE name LIKE '%Confirm%' OR name LIKE '%Request%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['name'].ToString())
}
$reader.Close()

$conn.Close()
