$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;';
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr);
$conn.Open();
$cmd = $conn.CreateCommand();
$cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('Template_SalaryImport_TriLuat_html')";
$def = $cmd.ExecuteScalar();
$conn.Close();
[System.IO.File]::WriteAllText('scripts/Template_SalaryImport_TriLuat_html_clean.sql', $def, [System.Text.Encoding]::UTF8);
Write-Host "Saved clean SQL, length: $($def.Length)";
