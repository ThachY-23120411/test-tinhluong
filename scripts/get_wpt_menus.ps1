$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT MenuID, ClassName, URL FROM MEN_Menu WHERE ClassName LIKE '%AttendanceConfirm%' OR ClassName LIKE '%WPT%' OR URL LIKE '%WPT%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { 
    Write-Output ($reader['MenuID'].ToString() + ' | ' + $reader['ClassName'].ToString() + ' | ' + $reader['URL'].ToString()) 
}
$reader.Close()
$conn.Close()
