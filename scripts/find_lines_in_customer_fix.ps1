$lines = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql"
Write-Host "Total lines: $($lines.Count)"
$matches = $lines | Select-String -Pattern 'VTS_RESPONSIVE_DATACOLLECTION_FIX'
foreach ($m in $matches) {
    Write-Host "Line $($m.LineNumber): $($m.Line)"
}
