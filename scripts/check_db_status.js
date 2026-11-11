const { execSync } = require('child_process');
const fs = require('fs');

const ps = `
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_KPIProcessCustomer_html')) AS def";
$def = $cmd.ExecuteScalar();
if ($def -and $def.Contains('toolbar-right-actions')) {
    Write-Host 'DB STATUS: UPDATED with toolbar-right-actions!';
} else {
    Write-Host 'DB STATUS: STILL OLD VERSION (not executed yet).';
}
$conn.Close();
`;

fs.writeFileSync('scripts/tmp_check_db_status.ps1', ps, 'utf8');
const res = execSync('powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tmp_check_db_status.ps1', { encoding: 'utf8' });
console.log(res);
fs.unlinkSync('scripts/tmp_check_db_status.ps1');
