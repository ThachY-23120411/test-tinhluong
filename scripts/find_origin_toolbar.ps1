$lines = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\origin.sql"
$matches = $lines | Select-String -Pattern 'dx-toolbar'
foreach ($m in $matches | Select-Object -First 30) {
    Write-Host "Line $($m.LineNumber): $($m.Line)"
}
