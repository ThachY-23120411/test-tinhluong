const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

function getConnectionString() {
  const envPath = path.resolve(__dirname, '../test.env.json');
  if (fs.existsSync(envPath)) {
    try {
      const env = JSON.parse(fs.readFileSync(envPath, 'utf8'));
      if (env.db && env.db.connectionString) return env.db.connectionString;
    } catch (e) {}
  }
  return 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';
}

/**
 * Thực thi câu lệnh SQL trực tiếp trên Database Vietinsoft_ForTest_Tai2
 * Tự động dùng Windows Authentication qua .NET SqlClient (không cần cài mssql qua npm)
 * CHẾ ĐỘ READ-ONLY NGHIÊM NGẶT: Chỉ cho phép truy vấn đọc dữ liệu (SELECT), cấm tuyệt đối mọi thao tác sửa đổi.
 * @param {string} sql - Câu lệnh SQL (SELECT...)
 * @returns {Array<Object>} Mảng các bản ghi JSON
 */
function query(sql) {
  // KHÓA BẢO VỆ READ-ONLY BẤT BIẾN THEO YÊU CẦU CỦA NGƯỜI DÙNG
  const modifyingKeywords = /\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|MERGE|GRANT|REVOKE)\b/i;
  if (modifyingKeywords.test(sql)) {
    throw new Error(`⛔ [BẢO MẬT DATABASE]: Hành động bị chặn! Bạn tuyệt đối không được phép chỉnh sửa dữ liệu hoặc cấu trúc DB (phát hiện từ khóa cấm trong câu lệnh). Chỉ cho phép các câu lệnh truy vấn đọc (SELECT)!`);
  }

  const connStr = getConnectionString();
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
          elseif ($val -is [DateTime]) { $val = $val.ToString("yyyy-MM-dd HH:mm:ss") }
          $obj[$col.ColumnName] = $val
        }
        $rows += [pscustomobject]$obj
      }
      $rows | ConvertTo-Json -Depth 5 -Compress
    } else {
      "[]"
    }
  `;

  try {
    const raw = execSync('powershell -NoProfile -Command -', {
      input: psScript,
      encoding: 'utf8',
      maxBuffer: 20 * 1024 * 1024
    });
    const trimmed = raw.trim();
    if (!trimmed || trimmed === '[]') return [];
    const parsed = JSON.parse(trimmed);
    return Array.isArray(parsed) ? parsed : [parsed];
  } catch (err) {
    console.error('Lỗi thực thi SQL:', err.message);
    throw err;
  }
}

module.exports = { query, getConnectionString };
