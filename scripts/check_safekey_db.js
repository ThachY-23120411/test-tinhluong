const fs = require('fs');
const { execSync } = require('child_process');

// Run query to check shortcut script in DB
const psScript = `
$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT CASE WHEN OBJECT_DEFINITION(OBJECT_ID('HtmlMacOSLayOut_html')) LIKE '%event.key ||%' THEN 1 ELSE 0 END as HasSafeKey,
(SELECT TOP 1 CASE WHEN html LIKE '%event.key ||%' THEN 1 ELSE 0 END FROM tblHtmlScriptCache WHERE TableName = 'HtmlMacOSLayOut') as CacheHasSafeKey"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP HasSafeKey: $($reader['HasSafeKey'])"
    Write-Host "Cache HasSafeKey: $($reader['CacheHasSafeKey'])"
}
$conn.Close()
`;

fs.writeFileSync('scripts/tmp_check_safekey.ps1', psScript, 'utf8');
const out = execSync('powershell -ExecutionPolicy Bypass -File scripts/tmp_check_safekey.ps1', { encoding: 'utf8' });
console.log(out);
