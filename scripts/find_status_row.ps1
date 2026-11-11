$lines = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql"
$matches = $lines | Select-String -Pattern 'crm-status-row'
foreach ($m in $matches) {
    Write-Host "Line $($m.LineNumber): $($m.Line)"
}
