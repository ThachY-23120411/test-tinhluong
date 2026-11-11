const { execSync } = require('child_process');
const fs = require('fs');

const ps = `
$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT html FROM tblHtmlScriptCache WHERE TableName = 'HtmlMacOSLayOut' AND ScreenType = -1 AND LanguageID = 'VN'"
$html = $cmd.ExecuteScalar()
$conn.Close()

$idx = $html.IndexOf("event.key.toUpperCase")
if ($idx -ge 0) {
    Write-Host $html.Substring($idx, 600)
}
`;

fs.writeFileSync('scripts/tmp_check_keyup.ps1', ps, 'utf8');
const out = execSync('powershell -ExecutionPolicy Bypass -File scripts/tmp_check_keyup.ps1', { encoding: 'utf8' });
console.log(out);
