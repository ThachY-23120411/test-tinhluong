param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

$connectionString = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $Query
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    foreach ($table in $ds.Tables) {
        $table | Format-List | Out-String | Write-Output
    }
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    if ($conn.State -eq 'Open') {
        $conn.Close()
    }
}
