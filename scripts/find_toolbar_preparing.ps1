$content = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql" -Raw
$idx = $content.IndexOf("onToolbarPreparing")
if ($idx -ge 0) {
    Write-Host "Found onToolbarPreparing at char $idx"
    Write-Host $content.Substring($idx, [Math]::Min(3000, $content.Length - $idx))
} else {
    Write-Host "onToolbarPreparing not found"
}
