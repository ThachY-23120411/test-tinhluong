$lines = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\release_patches.sql"
$matches = $lines | Select-String -Pattern 'sp_KPIListDataCollection'
foreach ($m in $matches) {
    Write-Host "Line $($m.LineNumber): $($m.Line)"
}
