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
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('paradisepublic')"
    $def = $cmd.ExecuteScalar()
    $conn.Close()
    [System.IO.File]::WriteAllText("scripts/db_paradisepublic.sql", $def, [System.Text.Encoding]::UTF8)
  `;
  fs.writeFileSync('scripts/temp_para.ps1', ps, 'utf8');
  execSync('powershell -ExecutionPolicy Bypass -File scripts/temp_para.ps1', { encoding: 'utf8' });
  fs.unlinkSync('scripts/temp_para.ps1');
  console.log('Saved db_paradisepublic.sql. Size:', fs.statSync('scripts/db_paradisepublic.sql').size);
}

run();
