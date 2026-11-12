$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
SELECT TOP 20 IdentityID, EmployeeID, AttDate, Approve_Status
FROM tblAttendanceConfirmRequest
ORDER BY AttDate DESC;
"@
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    
    $ds.Tables[0] | Format-Table -AutoSize | Out-String | Write-Host
    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
