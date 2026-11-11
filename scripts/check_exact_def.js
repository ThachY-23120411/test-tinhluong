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
    $cmd.CommandText = "
      SELECT TableName, LanguageID, Version, LEN(CAST(html AS NVARCHAR(MAX))) as len, 
             CHARINDEX('max-width: 560px', CAST(html AS NVARCHAR(MAX))) as has560,
             CHARINDEX('max-width: 500px', CAST(html AS NVARCHAR(MAX))) as has500
      FROM tblHtmlScriptCache 
      WHERE TableName LIKE '%EmailKPIFollow%'
    "
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $da.Fill($ds) | Out-Null
    $conn.Close()
    $ds.Tables[0] | ConvertTo-Json
  `;
  fs.writeFileSync('scripts/temp_check.ps1', ps, 'utf8');
  const out = execSync('powershell -ExecutionPolicy Bypass -File scripts/temp_check.ps1', { encoding: 'utf8' });
  console.log(out);
  fs.unlinkSync('scripts/temp_check.ps1');
}

run();
