const fs = require('fs');
const path = require('path');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql'), 'utf8');
const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);

console.log(`Checking syntax of all ${batches.length} batches of patch_nhap_luong_tri_luat.sql on SQL Server...`);

const connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';

let psBatches = `
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
$conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
$conn.Open();

$cmdNoExec = $conn.CreateCommand();
$cmdNoExec.CommandText = "SET NOEXEC ON;";
$cmdNoExec.ExecuteNonQuery() | Out-Null;

$allOk = $true;
`;

for (let i = 0; i < batches.length; i++) {
  const batchCode = batches[i].replace(/`/g, '``').replace(/\$/g, '`$');
  psBatches += `
try {
    $cmd${i} = $conn.CreateCommand();
    $cmd${i}.CommandText = @"
${batchCode}
"@;
    $cmd${i}.ExecuteNonQuery() | Out-Null;
    Write-Host "Batch ${i}: OK (Parse Successful)";
} catch {
    Write-Host "Batch ${i} ERROR: $($_.Exception.Message)";
    $allOk = $false;
}
`;
}

psBatches += `
$cmdOff = $conn.CreateCommand();
$cmdOff.CommandText = "SET NOEXEC OFF;";
$cmdOff.ExecuteNonQuery() | Out-Null;
$conn.Close();

if ($allOk) {
    Write-Host ">>> ALL BATCHES PARSE 100% SUCCESSFULLY! <<<";
} else {
    Write-Host ">>> SOME BATCHES FAILED PARSE CHECK <<<";
    exit 1;
}
`;

const psFile = path.resolve(__dirname, 'temp_validate_ss11.ps1');
fs.writeFileSync(psFile, psBatches, 'utf8');

const { execSync } = require('child_process');
try {
  const out = execSync(`powershell -ExecutionPolicy Bypass -File "${psFile}"`, { encoding: 'utf8' });
  console.log(out);
} catch (e) {
  console.error(e.stdout || e.message);
} finally {
  if (fs.existsSync(psFile)) fs.unlinkSync(psFile);
}
