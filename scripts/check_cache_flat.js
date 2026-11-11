const { execSync } = require('child_process');
const fs = require('fs');

const ps = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = "SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_KPIProcessCustomer' AND LanguageID = 'VN'";
$html = $cmd.ExecuteScalar();
if ($html -and $html.Contains('QUY TẮC 6.1')) {
    Write-Host 'Cache Table: Flat Sibling HTML is LIVE on Database!';
} else {
    Write-Host 'Cache Table check:';
    if ($html) {
        Write-Host "Length: $($html.Length)";
        Write-Host "Contains toolbar-right-actions: $($html.Contains('toolbar-right-actions'))";
        Write-Host "Contains header-actions: $($html.Contains('header-actions'))";
    }
}
$conn.Close();
`;

fs.writeFileSync('scripts/tmp_check_cache_flat.ps1', ps, 'utf8');
const res = execSync('powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tmp_check_cache_flat.ps1', { encoding: 'utf8' });
console.log(res);
fs.unlinkSync('scripts/tmp_check_cache_flat.ps1');
