const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { getConnectionString } = require('../helpers/db');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-14/patch_email_kpi_follow.sql'), 'utf8')
  .replace(/^\uFEFF/, '');

const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);

console.log(`Checking syntax of all ${batches.length} batches on SQL Server with connection-level SET NOEXEC ON...`);

const connStr = getConnectionString();

let psScript = `
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
  $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
  $conn.Open();

  # Bật SET NOEXEC ON trên connection
  $cmdOn = $conn.CreateCommand();
  $cmdOn.CommandText = "SET NOEXEC ON;";
  $cmdOn.ExecuteNonQuery() | Out-Null;

  $allOk = $true;
`;

for (let i = 0; i < batches.length; i++) {
  // Thay thế các ký tự đặc biệt trong powershell here-string
  const code = batches[i].trim().replace(/`/g, '``').replace(/\$/g, '`$');
  psScript += `
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

psScript += `
  # Tắt SET NOEXEC OFF
  $cmdOff = $conn.CreateCommand();
  $cmdOff.CommandText = "SET NOEXEC OFF;";
  $cmdOff.ExecuteNonQuery() | Out-Null;
  $conn.Close();

  if (-not $allOk) { exit 1; }
`;

const tempPs = path.resolve(__dirname, 'temp_validate_s14.ps1');
fs.writeFileSync(tempPs, psScript, 'utf8');

try {
  const out = execSync(`powershell -ExecutionPolicy Bypass -File "${tempPs}"`, { encoding: 'utf8' });
  console.log(out);
} catch (err) {
  console.error('Validation output:', err.stdout || err.message);
} finally {
  if (fs.existsSync(tempPs)) fs.unlinkSync(tempPs);
}
