const { execSync } = require('child_process');
const fs = require('fs');

const ps = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = 'SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = ''P18F22C9ACED845F4BDA48BAF1F6C8DD6''';
$loadUI = $cmd.ExecuteScalar();
[System.IO.File]::WriteAllText('scripts/emp_loadui.js', $loadUI, [System.Text.Encoding]::UTF8);
Write-Host ('Saved emp_loadui.js, length: ' + $loadUI.Length);
$r.Close();
$conn.Close();
`;

fs.writeFileSync('scripts/tmp_ctrl.ps1', ps, 'utf8');
const res = execSync('powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tmp_ctrl.ps1', { encoding: 'utf8' });
console.log(res);
fs.unlinkSync('scripts/tmp_ctrl.ps1');
