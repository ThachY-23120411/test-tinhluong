const fs = require('fs');
const { execSync } = require('child_process');
const { getConnectionString } = require('../helpers/db');

function run() {
  const connStr = getConnectionString() + ';Connection Timeout=30;';
  const ps = `
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}")
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_CRM_EmailKPIFollow_html')"
    $def = $cmd.ExecuteScalar()
    $conn.Close()
    [System.IO.File]::WriteAllText("scripts/db_sp_html_dump.sql", $def, [System.Text.Encoding]::UTF8)
  `;
  fs.writeFileSync('scripts/temp_dump.ps1', ps, 'utf8');
  execSync('powershell -ExecutionPolicy Bypass -File scripts/temp_dump.ps1', { encoding: 'utf8' });
  fs.unlinkSync('scripts/temp_dump.ps1');
  console.log('Dumped successfully. File size:', fs.statSync('scripts/db_sp_html_dump.sql').size);
}

run();
