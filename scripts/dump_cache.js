const { execSync } = require('child_process');
const fs = require('fs');

function dumpCache() {
  const connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';
  const psScript = `
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
    $conn = New-Object System.Data.SqlClient.SqlConnection("${connStr}");
    $conn.Open();
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = "SELECT VersionData FROM tblHtmlScriptCache WHERE TableName = 'Template_SalaryImport_TriLuat' AND LanguageID = 'VN'";
    $vData = $cmd.ExecuteScalar();
    $conn.Close();
    [System.IO.File]::WriteAllText('scripts/current_cache_versiondata.html', $vData, [System.Text.Encoding]::UTF8);
  `;
  execSync('powershell -NoProfile -NonInteractive -Command -', { input: psScript, encoding: 'utf8' });
}

dumpCache();
const txt = fs.readFileSync('scripts/current_cache_versiondata.html', 'utf8');
console.log('VersionData Length:', txt.length);
