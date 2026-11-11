$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$cmd.CommandText = "SELECT MenuID, MenuName, TableName, ModuleID FROM MEN_Menu WHERE MenuName LIKE '%bù công%' OR MenuName LIKE '%phê duyệt%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['MenuID'].ToString() + ' | ' + $reader['MenuName'].ToString() + ' | ' + $reader['TableName'].ToString() + ' | ' + $reader['ModuleID'].ToString())
}
$reader.Close()
$conn.Close()
