$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT DISTINCT TableName FROM tblHtmlScriptCache WHERE TableName LIKE '%Attendance%' OR TableName LIKE '%Confirm%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { 
    Write-Output $reader['TableName'].ToString() 
}
$reader.Close()
$conn.Close()
