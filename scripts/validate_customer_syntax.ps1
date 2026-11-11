$sql = Get-Content "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql" -Raw

$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()

# Split batches by GO
$batches = [System.Text.RegularExpressions.Regex]::Split($sql, "^\s*GO\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

Write-Host "Total batches to validate: $($batches.Count)"

$batchNum = 0
foreach ($b in $batches) {
    $batchNum++
    $trimmed = $b.Trim()
    if ($trimmed.Length -eq 0) { continue }
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SET NOEXEC ON;`r`n" + $trimmed + "`r`nSET NOEXEC OFF;"
    try {
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Host "Batch $batchNum syntax OK (length $($trimmed.Length))"
    } catch {
        Write-Host "❌ Batch $batchNum SYNTAX ERROR: $($_.Exception.Message)"
        $conn.Close()
        exit 1
    }
}

$conn.Close()
Write-Host "🎉 ALL BATCHES VALIDATED 100% CLEAN SYNTAX!"
