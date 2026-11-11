$raw = Get-Content 'debug_screens/cuong.vu/menus.json' -Raw | ConvertFrom-Json
Write-Output "=== HRS MENUS ==="
$raw.moduleMenus.MnuHRS000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique

Write-Output "=== TAD MENUS ==="
$raw.moduleMenus.MnuTAD000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique

Write-Output "=== PRL MENUS ==="
$raw.moduleMenus.MnuPRL000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique

Write-Output "=== WPT MENUS ==="
$raw.moduleMenus.MnuWPT000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique
