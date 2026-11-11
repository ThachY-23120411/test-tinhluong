$connStr = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('sp_Sub_SubProduct_html'))"
$def = $cmd.ExecuteScalar()
$conn.Close()

$destDir = "c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/crm_quan_ly_phan_he"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}
$screenshotDir = "$destDir/screenshot"
if (-not (Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
}

$destFile = "$destDir/origin.sql"
[System.IO.File]::WriteAllText($destFile, $def, [System.Text.Encoding]::UTF8)
Write-Host "Extracted origin.sql for crm_quan_ly_phan_he. Length: $($def.Length) chars."
