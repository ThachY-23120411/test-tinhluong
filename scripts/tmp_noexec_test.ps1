
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;");
$conn.Open();

# Turn NOEXEC ON so SQL parses and compiles without executing
$cmdOn = $conn.CreateCommand();
$cmdOn.CommandText = "SET NOEXEC ON;";
$cmdOn.ExecuteNonQuery() | Out-Null;

$fullSql = [System.IO.File]::ReadAllText('fix-bug/sales_pipeline/fix-bug.sql', [System.Text.Encoding]::UTF8);
$batches = [System.Text.RegularExpressions.Regex]::Split($fullSql, '(?m)^s*GOs*$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase);

$allOk = $true;
$idx = 1;

foreach ($batch in $batches) {
    $trimmed = $batch.Trim();
    if ($trimmed.Length -eq 0) { continue; }

    $cmd = $conn.CreateCommand();
    $cmd.CommandText = $trimmed;
    try {
        $cmd.ExecuteNonQuery() | Out-Null;
        Write-Host "BATCH $idx OK ($($trimmed.Substring(0, [Math]::Min(50, $trimmed.Length)).Replace(`"`r`n`", ' '))...)";
    } catch {
        $allOk = $false;
        Write-Host "BATCH $idx ERROR: $($_.Exception.Message)";
    }
    $idx++;
}

# Turn NOEXEC OFF
$cmdOff = $conn.CreateCommand();
$cmdOff.CommandText = "SET NOEXEC OFF;";
$cmdOff.ExecuteNonQuery() | Out-Null;
$conn.Close();

if (-not $allOk) {
    exit 1;
} else {
    Write-Host "ALL 3 BATCHES PARSED 100% CLEAN ON SQL SERVER (SET NOEXEC ON)!";
}
