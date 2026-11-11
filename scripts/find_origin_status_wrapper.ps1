$lines = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\origin.sql"
for ($i = 1450; $i -le 1650; $i++) {
    if ($lines[$i] -match 'statusWrapper' -or $lines[$i] -match 'statusFilterRow') {
        Write-Host "Line $($i+1): $($lines[$i])"
    }
}
