const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const psScript = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = @"
SELECT 'sp_KPIProcessCustomer_html' AS Name, OBJECT_DEFINITION(OBJECT_ID('sp_KPIProcessCustomer_html')) AS Def
UNION ALL
SELECT 'sp_KPIProcessCustomer' AS Name, OBJECT_DEFINITION(OBJECT_ID('sp_KPIProcessCustomer')) AS Def
"@;
$r = $cmd.ExecuteReader();
while ($r.Read()) {
    $name = $r["Name"];
    $def = $r["Def"];
    if ($def -ne [DBNull]::Value -and $def) {
        Write-Host "Object: $name, Length: $($def.Length)";
        [System.IO.File]::WriteAllText("scripts/$name.txt", $def, [System.Text.Encoding]::UTF8);
    } else {
        Write-Host "Object: $name NOT FOUND";
    }
}
$r.Close();
$conn.Close();
`;

const psFile = path.resolve('scripts/tmp_check_kpi.ps1');
fs.writeFileSync(psFile, psScript, 'utf8');
const out = execSync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${psFile}"`, { encoding: 'utf8' });
console.log(out);
if (fs.existsSync(psFile)) fs.unlinkSync(psFile);
