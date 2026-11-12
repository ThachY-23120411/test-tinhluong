$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
SELECT TOP 10 *
FROM tblAttendanceConfirmRequest r
WHERE r.EmployeeID = '099'
ORDER BY r.AttDate;

SELECT h.Identity_ID, h.ApproverID, h.Level, h.Approve_Status, h.Remark, h.Approval_Time
FROM tblApproverHistory h
JOIN tblAttendanceConfirmRequest r ON h.Identity_ID = r.IdentityID
WHERE r.EmployeeID = '099'
ORDER BY r.AttDate, h.Level;
"@
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    
    Write-Host "=== REQUESTS ==="
    $ds.Tables[0] | Format-Table -AutoSize | Out-String | Write-Host

    Write-Host "=== APPROVER HISTORY ==="
    $ds.Tables[1] | Format-Table -AutoSize | Out-String | Write-Host

    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
