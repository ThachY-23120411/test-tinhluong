const { execSync } = require('child_process');
const fs = require('fs');

function getSpDef(dbName, outFile) {
  const connStr = `Server=192.168.11.51,2222;Database=${dbName};Integrated Security=True;TrustServerCertificate=True;`;
  const psScript = `
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
    $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
    $conn.Open();
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('[dbo].[Template_SalaryImport_TriLuat_html]'))";
    $def = $cmd.ExecuteScalar();
    $conn.Close();
    [System.IO.File]::WriteAllText('${outFile}', $def, [System.Text.Encoding]::UTF8);
  `;
  execSync('powershell -NoProfile -NonInteractive -Command -', { input: psScript, encoding: 'utf8' });
}

getSpDef('Vietinsoft_ForTest_Tai', 'scripts/orig_tai_sp_def.sql');
const txt = fs.readFileSync('scripts/orig_tai_sp_def.sql', 'utf8');
console.log('Original Tai SP Length:', txt.length);
const lines = txt.split('\n');
lines.forEach((l, i) => {
  if (l.includes('noDataText') || l.includes('forceGridReload') || l.includes('tsitlTopFilterBar') || l.includes('onToolbarPreparing')) {
    console.log(`Line ${i + 1}: ${l.trim()}`);
  }
});
