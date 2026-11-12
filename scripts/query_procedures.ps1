$conn = New-Object System.Data.SqlClient.SqlConnection("Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;")
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_MakeupHours_html')) as Def"
    $htmlDef = $cmd.ExecuteScalar()
    if ($htmlDef) {
        [System.IO.File]::WriteAllText("scripts/sp_MakeupHours_html.sql", $htmlDef, [System.Text.Encoding]::UTF8)
        Write-Host "sp_MakeupHours_html saved. Length: $($htmlDef.Length)"
    } else {
        Write-Host "sp_MakeupHours_html not found."
    }

    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ApproveAttendanceRequest')) as Def"
    $approveDef = $cmd.ExecuteScalar()
    if ($approveDef) {
        [System.IO.File]::WriteAllText("scripts/sp_ApproveAttendanceRequest.sql", $approveDef, [System.Text.Encoding]::UTF8)
        Write-Host "sp_ApproveAttendanceRequest saved. Length: $($approveDef.Length)"
    } else {
        Write-Host "sp_ApproveAttendanceRequest not found."
    }

    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CheckApprovalPermission')) as Def"
    $checkDef = $cmd.ExecuteScalar()
    if ($checkDef) {
        [System.IO.File]::WriteAllText("scripts/sp_CheckApprovalPermission.sql", $checkDef, [System.Text.Encoding]::UTF8)
        Write-Host "sp_CheckApprovalPermission saved. Length: $($checkDef.Length)"
    } else {
        Write-Host "sp_CheckApprovalPermission not found."
    }

    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
