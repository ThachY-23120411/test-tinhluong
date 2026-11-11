$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT 
    CASE WHEN OBJECT_DEFINITION(OBJECT_ID('sp_KPIListDataCollection_html')) LIKE '%dc-status-wrapper%' THEN 1 ELSE 0 END as SpHasWrapper,
    CASE WHEN OBJECT_DEFINITION(OBJECT_ID('sp_KPIListDataCollection_html')) LIKE '%VTS_RESPONSIVE_DATACOLLECTION_FIX%' THEN 1 ELSE 0 END as SpHasResponsiveFix,
    CASE WHEN OBJECT_DEFINITION(OBJECT_ID('sp_KPIListDataCollection_html')) LIKE '%container-type: normal%' THEN 1 ELSE 0 END as SpHasNormalContainer,
    (SELECT TOP 1 CASE WHEN html LIKE '%dc-status-wrapper%' THEN 1 ELSE 0 END FROM tblHtmlScriptCache WHERE TableName = 'sp_KPIListDataCollection' AND ScreenType = -1) as CacheHasWrapper,
    (SELECT TOP 1 CASE WHEN html LIKE '%container-type: normal%' THEN 1 ELSE 0 END FROM tblHtmlScriptCache WHERE TableName = 'sp_KPIListDataCollection' AND ScreenType = -1) as CacheHasNormalContainer
"@
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SpHasWrapper: $($reader['SpHasWrapper'])"
    Write-Host "SpHasResponsiveFix: $($reader['SpHasResponsiveFix'])"
    Write-Host "SpHasNormalContainer: $($reader['SpHasNormalContainer'])"
    Write-Host "CacheHasWrapper: $($reader['CacheHasWrapper'])"
    Write-Host "CacheHasNormalContainer: $($reader['CacheHasNormalContainer'])"
}
$conn.Close()
