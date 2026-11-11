$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_KPIListDataCollection_html')) as Def"
$dbDef = $cmd.ExecuteScalar()
$conn.Close()

$originFile = "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\origin.sql"
$fileDef = Get-Content $originFile -Raw

Write-Host "DbDef length: $($dbDef.Length)"
Write-Host "FileDef length: $($fileDef.Length)"

# Save exact db definition to origin.sql to ensure 100% fidelity as required by AGENTS.md
[System.IO.File]::WriteAllText($originFile, $dbDef, [System.Text.Encoding]::UTF8)
Write-Host "Updated origin.sql with exact 100% Database definition!"
