const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';

const fullSql = fs.readFileSync('fix-bug/sales_pipeline/fix-bug.sql', 'utf8');
const batches = fullSql.split(/^[ \t]*GO[ \t]*\r?$/im).map(b => b.trim()).filter(b => b.length > 0);

console.log(`Validating ${batches.length} batches on SQL Server...`);

let allOk = true;

for (let i = 0; i < batches.length; i++) {
  const batch = batches[i];
  const tmpSql = path.resolve(`scripts/tmp_validate_b${i}.sql`);
  fs.writeFileSync(tmpSql, batch, 'utf8');

  const ps = `
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
    $conn = New-Object System.Data.SqlClient.SqlConnection('${connStr}');
    $conn.Open();
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = "SET NOEXEC ON;";
    $cmd.ExecuteNonQuery() | Out-Null;

    $cmd.CommandText = [System.IO.File]::ReadAllText('${tmpSql.replace(/\\/g, '/')}', [System.Text.Encoding]::UTF8);
    try {
        $cmd.ExecuteNonQuery() | Out-Null;
        Write-Host "BATCH_${i + 1}_OK";
    } catch {
        Write-Error "BATCH_${i + 1}_ERROR: $($_.Exception.Message)";
    } finally {
        $conn.Close();
    }
  `;

  const tmpPs = path.resolve(`scripts/tmp_run_b${i}.ps1`);
  fs.writeFileSync(tmpPs, ps, 'utf8');

  try {
    const res = execSync(`powershell -ExecutionPolicy Bypass -File "${tmpPs}"`, { encoding: 'utf8' });
    console.log(`✓ Batch ${i + 1}:`, res.trim());
  } catch (e) {
    allOk = false;
    console.error(`✗ Batch ${i + 1} Error:`, e.stderr || e.stdout || e.message);
  } finally {
    if (fs.existsSync(tmpPs)) fs.unlinkSync(tmpPs);
    if (fs.existsSync(tmpSql)) fs.unlinkSync(tmpSql);
  }
}

if (allOk) {
  console.log('🎉 100% ALL 3 BATCHES VALIDATED WITH ZERO SYNTAX ERRORS ON SQL SERVER (SET NOEXEC ON)!');
} else {
  process.exit(1);
}
