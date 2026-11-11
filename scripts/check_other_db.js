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
    maxBuffer: 10 * 1024 * 1024
  });
  return JSON.parse(output.trim() || '[]');
}

try {
  console.log('--- Vietinsoft_ForTest_Tai ---');
  console.log(queryDb('Vietinsoft_ForTest_Tai', "SELECT LoginID, LoginName FROM tblSC_Login WHERE LoginName IN ('Tai.Dang', 'Cuong.Vu')"));
  console.log('--- Vietinsoft_ForTest_Tai2 ---');
  console.log(queryDb('Vietinsoft_ForTest_Tai2', "SELECT LoginID, LoginName FROM tblSC_Login WHERE LoginName IN ('Tai.Dang', 'Cuong.Vu')"));
} catch (e) {
  console.error(e);
}
