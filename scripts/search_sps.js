const { execSync } = require('child_process');

function queryDb(dbName, sql) {
  const connStr = `Server=192.168.11.51,2222;Database=${dbName};Integrated Security=True;TrustServerCertificate=True;`;
  const psScript = `
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
    $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
    $conn.Open();
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = @"
${sql}
"@;
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd);
    $ds = New-Object System.Data.DataSet;
    $adapter.Fill($ds) | Out-Null;
    $conn.Close();
    if ($ds.Tables.Count -gt 0 -and $ds.Tables[0].Rows.Count -gt 0) {
      $rows = @()
      foreach ($row in $ds.Tables[0].Rows) {
        $obj = [ordered]@{}
        foreach ($col in $ds.Tables[0].Columns) {
          $val = $row[$col]
          if ($val -eq [DBNull]::Value) { $val = $null }
          $obj[$col.ColumnName] = $val
        }
        $rows += [PSCustomObject]$obj
      }
      $rows | ConvertTo-Json -Depth 5
    } else {
      "[]"
    }
  `;
  const output = execSync('powershell -NoProfile -NonInteractive -Command -', {
    input: psScript,
    encoding: 'utf8',
    maxBuffer: 20 * 1024 * 1024
  });
  return JSON.parse(output.trim() || '[]');
}

const sps = queryDb('Vietinsoft_ForTest_Tai2', "SELECT name FROM sys.objects WHERE type = 'P' AND name LIKE '%html%' AND name != 'Template_SalaryImport_TriLuat_html'");
console.log('Total HTML SPs:', sps.length);

// Check a few SPs that have Month or Year
const query = `
SELECT o.name 
FROM sys.objects o
JOIN sys.sql_modules m ON o.object_id = m.object_id
WHERE o.type = 'P' AND m.definition LIKE '%MonthUID%' AND m.definition LIKE '%sp_MonthList%'
`;
const monthSps = queryDb('Vietinsoft_ForTest_Tai2', query);
console.log('SPs using MonthUID and sp_MonthList:', monthSps);
