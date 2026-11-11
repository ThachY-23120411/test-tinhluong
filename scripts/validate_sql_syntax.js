const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function testParseSql(sqlFilePath) {
  const fullSql = fs.readFileSync(sqlFilePath, 'utf8');
  const connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';
  
  // Split batches by GO
  const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);
  console.log(`Total batches to parse: ${batches.length}`);

  for (let i = 0; i < batches.length; i++) {
    const batch = batches[i];
    const psScript = `
      [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
      $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
      $conn.Open();
      $cmd = $conn.CreateCommand();
      $cmd.CommandText = @"
SET NOEXEC ON;
${batch.replace(/"/g, '`"')}
SET NOEXEC OFF;
"@;
      try {
        $cmd.ExecuteNonQuery() | Out-Null;
        Write-Host "BATCH_${i}_OK";
      } catch {
        Write-Error "BATCH_${i}_ERROR: $($_.Exception.Message)";
      } finally {
        $conn.Close();
      }
    `;

    const tmpPs = path.join(__dirname, `test_batch_${i}.ps1`);
    fs.writeFileSync(tmpPs, psScript, 'utf8');
    try {
      const res = execSync(`powershell -ExecutionPolicy Bypass -File "${tmpPs}"`, { encoding: 'utf8' });
      console.log(`Batch ${i}:`, res.trim());
    } catch (err) {
      console.error(`Batch ${i} failed:`, err.stderr || err.stdout || err.message);
    } finally {
      if (fs.existsSync(tmpPs)) fs.unlinkSync(tmpPs);
    }
  }
}

testParseSql(path.resolve(__dirname, '../fix-bug/screenshot-5/patch_tao_mat_khau.sql'));
