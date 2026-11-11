const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const dir = path.resolve('fix-bug/sales_pipeline');
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

const psScript = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CRM_Lead_html')) AS def;";
$r = $cmd.ExecuteReader();
if ($r.Read()) {
    $def = $r["def"];
    [System.IO.File]::WriteAllText('${path.join(dir, 'origin.sql').replace(/\\/g, '/')}', $def, [System.Text.Encoding]::UTF8);
    Write-Host "Extracted origin.sql successfully! Length: $($def.Length)";
} else {
    Write-Host "ERROR: sp_CRM_Lead_html not found!";
}
$r.Close();
$conn.Close();
`;

const psFile = path.resolve('scripts/tmp_extract_origin.ps1');
fs.writeFileSync(psFile, psScript, 'utf8');
const out = execSync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${psFile}"`, { encoding: 'utf8' });
console.log(out);
if (fs.existsSync(psFile)) fs.unlinkSync(psFile);
