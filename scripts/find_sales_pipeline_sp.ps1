$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();

$cmd = $conn.CreateCommand();
$cmd.CommandText = @"
SELECT MenuID, MenuName, TableName, ProcedureName
FROM tblMenu
WHERE MenuName LIKE N'%Sales Pipeline%' OR ProcedureName LIKE '%sp_CRM_Lead%' OR TableName LIKE '%sp_CRM_Lead%';
"@;

$reader = $cmd.ExecuteReader();
while ($reader.Read()) {
    Write-Host "MenuID: $($reader['MenuID']) | MenuName: $($reader['MenuName']) | TableName: $($reader['TableName']) | ProcedureName: $($reader['ProcedureName'])";
}
$reader.Close();

$conn.Close();
