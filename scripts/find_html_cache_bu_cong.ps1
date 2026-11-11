$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$cmd.CommandText = "SELECT TableName, LanguageID, ScreenType FROM tblHtmlScriptCache WHERE html LIKE '%Bạn có chắc đăng ký đơn này không%' OR html LIKE '%Xác nhận đăng ký%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output ($reader['TableName'].ToString() + ' | Lang: ' + $reader['LanguageID'].ToString() + ' | ScreenType: ' + $reader['ScreenType'].ToString())
}
$reader.Close()
$conn.Close()
