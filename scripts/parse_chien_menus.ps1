$raw = Get-Content 'debug_screens/chien.nguyen/menus.json' -Raw | ConvertFrom-Json
Write-Output "=== CHIEN.NGUYEN PRL MENUS ==="
$raw.moduleMenus.MnuPRL000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique

Write-Output "=== CHIEN.NGUYEN TAD MENUS ==="
$raw.moduleMenus.MnuTAD000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique

Write-Output "=== CHIEN.NGUYEN HRS MENUS ==="
$raw.moduleMenus.MnuHRS000 | ForEach-Object { "$($_.className) | $($_.text)" } | Select-Object -Unique
