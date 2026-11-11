const { execSync } = require('child_process');
const fs = require('fs');

const ps = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = 'SELECT TableName, ScreenType, LanguageID, DATALENGTH(html) as HtmlLen FROM tblHtmlScriptCache WHERE TableName LIKE ''%KPIProcessCustomer%''';
$r = $cmd.ExecuteReader();
while ($r.Read()) {
    Write-Host ($r['TableName'] + ' | ' + $r['ScreenType'] + ' | ' + $r['LanguageID'] + ' | ' + $r['HtmlLen']);
}
$r.Close();
$conn.Close();
`;

fs.writeFileSync('scripts/tmp_cache.ps1', ps, 'utf8');
const res = execSync('powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tmp_cache.ps1', { encoding: 'utf8' });
console.log(res);
fs.unlinkSync('scripts/tmp_cache.ps1');
