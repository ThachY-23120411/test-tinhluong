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
  try {
    const output = execSync('powershell -NoProfile -NonInteractive -Command -', {
      input: psScript,
      encoding: 'utf8',
      maxBuffer: 10 * 1024 * 1024
    });
    return JSON.parse(output.trim() || '[]');
  } catch (e) {
    return { error: e.message };
  }
}

const dbs = ['Vietinsoft_ForTest_Tai', 'Vietinsoft_ForTest_Tai2', 'Vietinsoft_ForTest3'];
for (const db of dbs) {
  console.log(`\n=== Database: ${db} ===`);
  const res = queryDb(db, `
    SELECT TableName, LEN(html) as HtmlLen, 
           CHARINDEX('allowColumnResizing', html) as HasResizing, 
           CHARINDEX('18%', html) as Has18Pct
    FROM tblHtmlScriptCache 
    WHERE TableName LIKE '%sp_Debt_PaymentDebt%'
  `);
  console.log(res);
}
