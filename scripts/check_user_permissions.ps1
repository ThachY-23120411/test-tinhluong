$connStr = 'Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Check logins
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT LoginID, LoginName, FullName, EmployeeID, GroupID, AdminRight, isAdmin FROM tblSC_Login WHERE LoginName IN ('tai.dang', 'ThanhLong', 'cuong.vu', 'chien.nguyen', 'admin')"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dtLogins = New-Object System.Data.DataTable
$adapter.Fill($dtLogins) | Out-Null
Write-Output "=== LOGINS ==="
$dtLogins | Format-Table -AutoSize

# 2. Check menus for cuong.vu and chien.nguyen
$cmd.CommandText = @"
SELECT l.LoginName, m.MenuID, m.ClassName, m.ParentMenuID, m.Priority, m.URL
FROM tblSC_Login l
CROSS JOIN MEN_Menu m
WHERE l.LoginName = 'cuong.vu'
  AND (m.MenuID LIKE '%HRS%' OR m.MenuID LIKE '%TAD%' OR m.MenuID LIKE '%PRL%' OR m.MenuID LIKE '%WPT%')
  AND m.IsVisible = 1
ORDER BY m.ParentMenuID, m.Priority
"@
$conn.Close()
