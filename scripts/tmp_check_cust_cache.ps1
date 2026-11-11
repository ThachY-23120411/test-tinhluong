
$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT 
    CASE WHEN OBJECT_DEFINITION(OBJECT_ID('sp_KPIListDataCollection_html')) LIKE '%dc-status-wrapper%' THEN 1 ELSE 0 END as SpHasWrapper,
    (SELECT TOP 1 CASE WHEN html LIKE '%dc-status-wrapper%' THEN 1 ELSE 0 END FROM tblHtmlScriptCache WHERE TableName = 'sp_KPIListDataCollection' AND ScreenType = -1) as CacheHasWrapper
"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SpHasWrapper: $($reader['SpHasWrapper'])"
    Write-Host "CacheHasWrapper: $($reader['CacheHasWrapper'])"
}
$conn.Close()
