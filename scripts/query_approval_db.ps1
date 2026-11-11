$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "=== 1. TÌM MENU DANH SÁCH PHÊ DUYỆT ==="
$cmd.CommandText = "SELECT MenuID, MenuName, TableName FROM tblMenu WHERE MenuName LIKE N'%phê duyệt%' OR MenuName LIKE N'%Duyệt%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    $mId = $reader["MenuID"]
    $mName = $reader["MenuName"]
    $tName = $reader["TableName"]
    Write-Host "$mId | $mName | $tName"
}
$reader.Close()

Write-Host "=== 2. TÌM PROCEDURE DUYỆT ==="
$cmd.CommandText = "SELECT TOP 15 name FROM sys.procedures WHERE name LIKE '%Approve%' OR name LIKE '%Confirm%' OR name LIKE '%MnuWPT%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    $pName = $reader["name"]
    Write-Host "$pName"
}
$reader.Close()

Write-Host "=== 3. TÌM BẢNG LƯU ĐƠN BÙ CÔNG ==="
$cmd.CommandText = "SELECT TOP 15 name FROM sys.tables WHERE name LIKE '%Confirm%' OR name LIKE '%Attendance%' OR name LIKE '%Request%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    $t = $reader["name"]
    Write-Host "$t"
}
$reader.Close()

$conn.Close()
