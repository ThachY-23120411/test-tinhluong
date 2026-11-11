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
      SELECT TableName, LanguageID, SUBSTRING(CAST(html AS NVARCHAR(MAX)), 5400, 500) as snippet
      FROM tblHtmlScriptCache 
      WHERE TableName = 'sp_CRM_EmailKPIFollow' AND LanguageID = 'VN'
    "
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $da.Fill($ds) | Out-Null
    $conn.Close()
    $ds.Tables[0] | ConvertTo-Json
  `;
  fs.writeFileSync('scripts/temp_check2.ps1', ps, 'utf8');
  const out = execSync('powershell -ExecutionPolicy Bypass -File scripts/temp_check2.ps1', { encoding: 'utf8' });
  console.log(out);
  fs.unlinkSync('scripts/temp_check2.ps1');
}

run();
