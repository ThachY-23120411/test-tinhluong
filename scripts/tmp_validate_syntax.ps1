
$conn = New-Object System.Data.SqlClient.SqlConnection('Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;');
$conn.Open();

$sql = [System.IO.File]::ReadAllText('fix-bug/sales_pipeline/fix-bug.sql', [System.Text.Encoding]::UTF8);

# Enable PARSEONLY on connection
$cmdOn = $conn.CreateCommand();
$cmdOn.CommandText = 'SET PARSEONLY ON;';
$cmdOn.ExecuteNonQuery() | Out-Null;

# Split batches by GO
$batches = [System.Text.RegularExpressions.Regex]::Split($sql, '(?m)^s*GOs*$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase);

$hasError = $false;
$batchNum = 1;

foreach ($b in $batches) {
    $trimmed = $b.Trim();
    if ($trimmed.Length -eq 0) { continue; }
    
    $cmd = $conn.CreateCommand();
    $cmd.CommandText = $trimmed;
    try {
        $cmd.ExecuteNonQuery() | Out-Null;
        Write-Host "Batch $batchNum syntax OK (length: $($trimmed.Length))";
    } catch {
        Write-Host "Batch $batchNum SYNTAX ERROR: $_";
        $hasError = $true;
    }
    $batchNum++;
}

# Reset PARSEONLY
$cmdOff = $conn.CreateCommand();
$cmdOff.CommandText = 'SET PARSEONLY OFF;';
$cmdOff.ExecuteNonQuery() | Out-Null;

$conn.Close();
if ($hasError) {
    exit 1;
} else {
    Write-Host "ALL BATCHES PARSED 100% CLEAN!";
}
