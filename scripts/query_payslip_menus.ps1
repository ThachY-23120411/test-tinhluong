$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT MenuID, MenuName, ClassName, ParentMenuID FROM MEN_Menu WHERE MenuID IN ('MnuPRL445', 'MnuHRS145', 'MnuPRL080', 'MnuHRS0102', 'MnuHRS157', 'MnuHRS151', 'MnuHRS225', 'MnuMDT210', 'MnuPRL036', 'MnuPRL070', 'MnuPRL040', 'MnuWPT315', 'MnuWPT316', 'MnuWPT037', 'MnuHRS033')"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()
$dt | Format-Table -AutoSize
