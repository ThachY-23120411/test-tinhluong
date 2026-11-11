[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$jsonText = [System.IO.File]::ReadAllText("debug_screens/cuong.vu/menus.json", [System.Text.Encoding]::UTF8)
$data = $jsonText | ConvertFrom-Json

Write-Output "--- DOCK BUTTONS ---"
foreach ($b in $data.dockButtons) {
    if ($b.text -or $b.className) {
        Write-Output "Dock: [$($b.className)] text: '$($b.text)'"
    }
}

Write-Output "`n--- MnuHRS000 (Quản trị nhân sự) ---"
$data.moduleMenus.MnuHRS000 | Where-Object { $_.text -and $_.className -match 'child-launchpad' } | ForEach-Object {
    Write-Output "  [$($_.className)] -> $($_.text)"
}

Write-Output "`n--- MnuTAD000 (Quản lý chấm công) ---"
$data.moduleMenus.MnuTAD000 | Where-Object { $_.text -and $_.className -match 'child-launchpad' } | ForEach-Object {
    Write-Output "  [$($_.className)] -> $($_.text)"
}

Write-Output "`n--- MnuPRL000 (Tính lương) ---"
$data.moduleMenus.MnuPRL000 | Where-Object { $_.text -and $_.className -match 'child-launchpad' } | ForEach-Object {
    Write-Output "  [$($_.className)] -> $($_.text)"
}
