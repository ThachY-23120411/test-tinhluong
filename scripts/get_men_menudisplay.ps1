$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 m.MenuID, d.Title, m.ClassName, m.URL FROM MEN_Menu m INNER JOIN MEN_MenuDisplay d ON m.MenuID = d.MenuID WHERE d.Title LIKE N'%phê duyệt%' OR d.Title LIKE N'%Danh sách phê duyệt%'"
$r = $cmd.ExecuteReader()
while ($r.Read()) {
    Write-Output ($r['MenuID'].ToString() + ' | ' + $r['Title'].ToString() + ' | ' + $r['ClassName'].ToString())
}
$r.Close()
$conn.Close()
