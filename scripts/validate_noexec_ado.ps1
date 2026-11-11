param(
    [string]$SqlFile = "c:\Users\Y.Thach\Desktop\paradiseHR\fix-bug\crm_customer_data\fix-bug.sql"
)

$sql = Get-Content $SqlFile -Raw

$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
$conn.Open()

# Set NOEXEC ON on this connection session
$initCmd = $conn.CreateCommand()
$initCmd.CommandText = "SET NOEXEC ON;"
$initCmd.ExecuteNonQuery() | Out-Null
Write-Host "Connection session placed in SET NOEXEC ON mode."

# Split batches by GO
$batches = [System.Text.RegularExpressions.Regex]::Split($sql, "^\s*GO\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

Write-Host "Total batches: $($batches.Count)"

$batchNum = 0
foreach ($b in $batches) {
    $batchNum++
    $trimmed = $b.Trim()
    if ($trimmed.Length -eq 0) { continue }
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $trimmed
    try {
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Host "✅ Batch $batchNum syntax clean! (Length: $($trimmed.Length))"
    } catch {
        Write-Host "❌ Batch $batchNum SYNTAX ERROR: $($_.Exception.Message)"
        $resetCmd = $conn.CreateCommand()
        $resetCmd.CommandText = "SET NOEXEC OFF;"
        $resetCmd.ExecuteNonQuery() | Out-Null
        $conn.Close()
        exit 1
    }
}

# Turn NOEXEC OFF before closing
$resetCmd = $conn.CreateCommand()
$resetCmd.CommandText = "SET NOEXEC OFF;"
$resetCmd.ExecuteNonQuery() | Out-Null
$conn.Close()

Write-Host "🎉 ALL BATCHES 100% CLEAN SYNTAX VALIDATED ON SQL SERVER!"
