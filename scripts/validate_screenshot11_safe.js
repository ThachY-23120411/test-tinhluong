const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { getConnectionString } = require('../helpers/db');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql'), 'utf8')
  .replace(/^\uFEFF/, '');

const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);

console.log(`Checking syntax of all ${batches.length} batches on SQL Server with connection-level SET NOEXEC ON...`);

const connStr = getConnectionString();

const psScript = `
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
  $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
  $conn.Open();

  # Bật SET NOEXEC ON trên connection
  $cmdOn = $conn.CreateCommand();
  $cmdOn.CommandText = "SET NOEXEC ON;";
  $cmdOn.ExecuteNonQuery() | Out-Null;

  $allOk = $true;
`;

let psBatches = psScript;

for (let i = 0; i < batches.length; i++) {
  const code = batches[i].trim().replace(/`/g, '``').replace(/\$/g, '`$');
  psBatches += `
  try {
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = @"
${code}
"@;
    $cmd.ExecuteNonQuery() | Out-Null;
    Write-Host "Batch ${i}: OK (Parse Successful)";
  } catch {
    Write-Host "Batch ${i} ERROR: $($_.Exception.Message)";
    $allOk = $false;
  }
`;
}

psBatches += `
  # Tắt SET NOEXEC OFF
  $cmdOff = $conn.CreateCommand();
  $cmdOff.CommandText = "SET NOEXEC OFF;";
  $cmdOff.ExecuteNonQuery() | Out-Null;
  $conn.Close();

  if ($allOk) {
    Write-Host "🎉 ALL BATCHES PARSE 100% SUCCESSFULLY ON SQL SERVER!";
  } else {
    exit 1;
  }
`;

try {
  const out = execSync('powershell -NoProfile -Command -', {
    input: psBatches,
    encoding: 'utf8'
  });
  console.log(out.trim());
} catch(e) {
  console.error(e.stdout || e.message);
  process.exit(1);
}
