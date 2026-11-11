const { execSync } = require('child_process');

function checkObjects(db) {
  const ps = `
    $conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=${db};Integrated Security=True;TrustServerCertificate=True;");
    try {
      $conn.Open();
      $cmd = $conn.CreateCommand();
      $cmd.CommandText = "SELECT (SELECT COUNT(*) FROM sys.objects WHERE name = 'sp_GenerateHTMLScript_new') AS hasGenNew, (SELECT COUNT(*) FROM sys.objects WHERE name = 'sp_GenerateHTMLScript') AS hasGen, (SELECT COUNT(*) FROM sys.objects WHERE name = 'tblMD_Message') AS hasMsg, (SELECT COUNT(*) FROM sys.objects WHERE name = 'Template_SalaryImport_TriLuat_html') AS hasTriLuat";
      $r = $cmd.ExecuteReader();
      if ($r.Read()) {
        Write-Host "${db}: hasGenNew=$($r[0]), hasGen=$($r[1]), hasMsg=$($r[2]), hasTriLuat=$($r[3])";
      }
      $conn.Close();
    } catch {
      Write-Host "${db}: Connection failed - $($_.Exception.Message)";
    }
  `;
  try {
    const out = execSync('powershell -NoProfile -NonInteractive -Command -', { input: ps, encoding: 'utf8' });
    console.log(out.trim());
  } catch(e) {
    console.log(db, e.message);
  }
}

['Vietinsoft_ForTest_Tai', 'Vietinsoft_ForTest_Tai2', 'Vietinsoft_ForTest3', 'Vietinsoft_Dev', 'Paradise_AADH_TaiTesting'].forEach(checkObjects);
