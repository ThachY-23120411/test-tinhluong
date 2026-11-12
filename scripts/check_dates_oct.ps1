$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
SELECT IdentityID, EmployeeID, AttDate, Approve_Status
FROM tblAttendanceConfirmRequest
WHERE AttDate >= '2026-10-10' AND AttDate <= '2026-10-20'
ORDER BY AttDate;
"@
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    
    $ds.Tables[0] | Format-Table -AutoSize | Out-String | Write-Host
    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
