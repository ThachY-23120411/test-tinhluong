$fixFile = "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql"
$tmpFile = "c:\Users\Y.Thach\Desktop\paradiseHR\scripts\tmp_validate_customer.sql"

$sql = Get-Content $fixFile -Raw
$validateSql = "SET NOEXEC ON;`r`nGO`r`n" + $sql + "`r`nGO`r`nSET NOEXEC OFF;`r`nGO`r`n"
[System.IO.File]::WriteAllText($tmpFile, $validateSql, [System.Text.Encoding]::UTF8)

$sqlcmdOutput = & sqlcmd -S "192.168.11.51,2222" -d "Vietinsoft_ForTest_Tai2" -E -C -b -i $tmpFile 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 SQL SYNTAX 100% VALIDATED CLEAN!"
} else {
    Write-Host "❌ SQL SYNTAX ERROR: $sqlcmdOutput"
}
Remove-Item $tmpFile -ErrorAction SilentlyContinue
