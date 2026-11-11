const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const fullSql = fs.readFileSync('fix-bug/screenshot-1/patch_responsive.sql', 'utf8');
const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);

console.log(`Checking syntax of all ${batches.length} batches in patch_responsive.sql...`);

const connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';

let psScript = `
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
  psScript += `
try {
    $cmd${i} = $conn.CreateCommand();
    $cmd${i}.CommandText = @"
${batchCode}
"@;
    $cmd${i}.ExecuteNonQuery() | Out-Null;
    Write-Host "Batch ${i+1}: OK (Parse Successful)";
} catch {
    Write-Host "Batch ${i+1} ERROR: $($_.Exception.Message)";
    $allOk = $false;
}
`;
}

psScript += `
$cmdOff = $conn.CreateCommand();
$cmdOff.CommandText = "SET NOEXEC OFF;";
$cmdOff.ExecuteNonQuery() | Out-Null;
$conn.Close();

if ($allOk) {
    Write-Host ">>> ALL BATCHES PARSE 100% SUCCESSFULLY! <<<";
} else {
    Write-Host ">>> SOME BATCHES FAILED PARSE! <<<";
}
`;

fs.writeFileSync('scratch/test_responsive_syntax.ps1', psScript, 'utf8');

try {
  const out = execSync(`powershell -ExecutionPolicy Bypass -File scratch/test_responsive_syntax.ps1`, { encoding: 'utf8' });
  console.log(out);
} catch (e) {
  console.error('PS error:', e.stdout || e.message);
} finally {
  if (fs.existsSync('scratch/test_responsive_syntax.ps1')) fs.unlinkSync('scratch/test_responsive_syntax.ps1');
}
