# ==============================================================================
# PARADISE HRM - INTERACTIVE AUTOMATION TEST RUNNER (HIERARCHICAL MENU)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Paradise HRM - Automation Test Control Center"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $ProjectDir

function Get-RelPath {
    param([string]$FullPath)
    if ($FullPath.StartsWith($ProjectDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $FullPath.Substring($ProjectDir.Length).TrimStart('\', '/')
    }
    return (Split-Path -Leaf $FullPath)
}

function Show-Header {
    Clear-Host
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "          PARADISE HRM - BO DIEU KHIEN KIEM THU E2E TRUC QUAN                   " -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " Thu muc du an: $ProjectDir" -ForegroundColor DarkGray
    Write-Host " Trinh duyet:   Google Chrome (Live Mode - Co hien thi chuot Neon & go phim)" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
}

function Get-TestFiles {
    if (-not (Test-Path "$ProjectDir\tests")) {
        return @()
    }
    return Get-ChildItem -Path "$ProjectDir\tests" -Filter "*.spec.js" -Recurse | Sort-Object Name
}

function Extract-TestTitle {
    param([string]$FilePath)
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content -match 'test\.describe\(["'']([^"'']+)["'']') {
        return $matches[1]
    }
    $cases = Extract-TestCases -FilePath $FilePath
    if ($cases.Count -gt 0) {
        return "$($cases.Count) test case ($($cases[0]))"
    }
    return (Split-Path -Leaf $FilePath)
}

function Extract-TestCases {
    param([string]$FilePath)
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $results = @()
    $matchesFound = [regex]::Matches($content, 'test\(\s*[''"]([^''"]+)[''"]')
    foreach ($m in $matchesFound) {
        $val = $m.Groups[1].Value
        if ($val -ne "beforeEach" -and $val -ne "afterEach") {
            $results += $val
        }
    }
    return $results
}

function Run-Playwright {
    param(
        [string[]]$Files,
        [int]$Workers = 1,
        [string]$Grep = "",
        [string]$Description = ""
    )

    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host " [KHOI CHAY KIEM THU] $Description" -ForegroundColor Yellow
    Write-Host " So luong cua so chay dong thoi (Workers): $Workers" -ForegroundColor Cyan
    if ($Grep -ne "") {
        Write-Host " Bo loc Test Case (-g): $Grep" -ForegroundColor Magenta
    }
    Write-Host " Danh sach file thuc thi:" -ForegroundColor White
    foreach ($f in $Files) {
        $rel = Get-RelPath $f
        Write-Host "   - $rel" -ForegroundColor Gray
    }
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host ""

    $fileArgs = ($Files | ForEach-Object { 
        $rel = Get-RelPath $_
        """$rel""" 
    }) -join " "

    $grepArg = ""
    if ($Grep -ne "") {
        $escapedGrep = $Grep -replace '"', '\"'
        $grepArg = "-g `"$escapedGrep`""
    }

    $cmd = "npx playwright test $fileArgs $grepArg --headed --workers=$Workers"
    Write-Host "Lenh dang chay: $cmd" -ForegroundColor DarkGray
    Write-Host ""

    cmd /c $cmd

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " Hoan tat luot kiem thu!" -ForegroundColor Green
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan

    $reportPath = Join-Path $ProjectDir "test-evidence\test-report.md"
    if (Test-Path $reportPath) {
        $open = Read-Host "Ban co muon mo file Bao cao Markdown (test-report.md) khong? (Y/N, mac dinh: Y)"
        if ($open -eq "" -or $open.ToUpper() -eq "Y") {
            Start-Process $reportPath
        }
    }
    Write-Host ""
    Write-Host "Bam phim bat ky de quay lai Menu..." -ForegroundColor DarkYellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Vong lap Menu chinh
while ($true) {
    Show-Header
    $testFiles = Get-TestFiles

    Write-Host "DANH SACH CAC MENU / MAN HINH TEST HIEN CO (QUET DONG TU tests/):" -ForegroundColor Green
    if ($testFiles.Count -eq 0) {
        Write-Host "  (Chua co file .spec.js nao trong thu muc tests/!)" -ForegroundColor Red
    } else {
        for ($i = 0; $i -lt $testFiles.Count; $i++) {
            $f = $testFiles[$i]
            $num = $i + 1
            $rel = Get-RelPath $f.FullName
            $title = Extract-TestTitle -FilePath $f.FullName
            Write-Host "  [$num] " -NoNewline -ForegroundColor Yellow
            Write-Host "$rel " -NoNewline -ForegroundColor White
            Write-Host "-> $title" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "CAC CHE DO THUC THI:" -ForegroundColor Green
    Write-Host "  [1..$($testFiles.Count)]  Chon MENU cu the (ho tro chon tung TC-01..TC-0N hoac chay toan bo menu)" -ForegroundColor White
    Write-Host "  [A]     Chay TOAN BO tat ca kịch ban tuan tu (1 cua so tu dau den cuoi)" -ForegroundColor White
    Write-Host "  [P]     Chay SONG SONG (Parallel Multi-Windows) - Tuy chon so luong cua so va kịch ban" -ForegroundColor Cyan
    Write-Host "  [R]     Mo xem Bao cao kiem thu gan nhat (test-evidence/test-report.md)" -ForegroundColor Yellow
    Write-Host "  [Q]     Thoat" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    $choice = Read-Host "👉 Nhap lua chon cua ban"
    if ($choice -eq $null) { break }
    $choice = $choice.Trim()

    if ($choice.ToUpper() -eq "Q") {
        Write-Host "Tam biet!" -ForegroundColor Green
        break
    }
    elseif ($choice.ToUpper() -eq "R") {
        $reportPath = Join-Path $ProjectDir "test-evidence\test-report.md"
        if (Test-Path $reportPath) {
            Start-Process $reportPath
        } else {
            Write-Host "Chua co file bao cao! Hay chay test it nhat 1 lan." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    elseif ($choice.ToUpper() -eq "A") {
        if ($testFiles.Count -eq 0) {
            Write-Host "Khong co file test nao de chay!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
        $allPaths = $testFiles | ForEach-Object { $_.FullName }
        Run-Playwright -Files $allPaths -Workers 1 -Description "Chay toan bo $($testFiles.Count) kịch ban tuan tu (1 cua so)"
    }
    elseif ($choice.ToUpper() -eq "P") {
        if ($testFiles.Count -eq 0) {
            Write-Host "Khong co file test nao de chay!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        Write-Host ""
        Write-Host "--- CAU HINH KIEM THU SONG SONG (PARALLEL RUN) ---" -ForegroundColor Yellow
        $workersInput = Read-Host "1. Ban muon mo bao nhieu cua so Chrome dong thoi? (1-10, mac dinh: 2)"
        $workers = 2
        if ($workersInput -match "^\d+$") {
            $workers = [int]$workersInput
            if ($workers -lt 1) { $workers = 1 }
            if ($workers -gt 10) { $workers = 10 }
        }

        Write-Host "2. Chon cac kịch ban muon chay song song:" -ForegroundColor Yellow
        Write-Host "   - Bam [Enter]: Chay TAT CA $($testFiles.Count) kịch ban tren $workers cua so" -ForegroundColor Gray
        Write-Host "   - Hoac go cac so thu tu cach nhau bang dau phay (Vi du: 1, 2):" -ForegroundColor Gray
        $subChoice = Read-Host "👉 Kịch ban chi dinh"
        if ($subChoice -eq $null) { $subChoice = "" }
        $subChoice = $subChoice.Trim()

        $selectedFiles = @()
        if ($subChoice -eq "") {
            $selectedFiles = $testFiles | ForEach-Object { $_.FullName }
            $desc = "Chay tat ca $($testFiles.Count) kịch ban tren $workers cua so song song"
        } else {
            $indices = $subChoice -split "[,;\s]+"
            foreach ($idx in $indices) {
                if ($idx -match "^\d+$") {
                    $val = [int]$idx
                    if ($val -ge 1 -and $val -le $testFiles.Count) {
                        $selectedFiles += $testFiles[$val - 1].FullName
                    }
                }
            }
            if ($selectedFiles.Count -eq 0) {
                Write-Host "Khong co kịch ban hop le nao duoc chon!" -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }
            $desc = "Chay $($selectedFiles.Count) kịch ban da chon tren $workers cua so song song"
        }

        Run-Playwright -Files $selectedFiles -Workers $workers -Description $desc
    }
    elseif ($choice -match "^\d+$") {
        $idx = [int]$choice
        if ($idx -ge 1 -and $idx -le $testFiles.Count) {
            $selectedFile = $testFiles[$idx - 1].FullName
            $rel = Get-RelPath $selectedFile

            # Submenu: Drill-down into Test Cases of this file!
            $tcList = Extract-TestCases -FilePath $selectedFile
            
            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
            Write-Host " CHI TIET MENU: $rel" -ForegroundColor Yellow
            Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
            Write-Host "  [A] Chay TOAN BO tat ca test case trong menu nay (Mac dinh)" -ForegroundColor Green
            if ($tcList.Count -eq 0) {
                Write-Host "  (Khong phat hien ham test() nao, se chay ca file)" -ForegroundColor Gray
            } else {
                for ($j = 0; $j -lt $tcList.Count; $j++) {
                    $tcNum = $j + 1
                    Write-Host "  [$tcNum] " -NoNewline -ForegroundColor Yellow
                    Write-Host "$($tcList[$j])" -ForegroundColor White
                }
            }
            Write-Host "  [B] Quay lai Menu chinh" -ForegroundColor DarkGray
            Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan

            $tcChoice = Read-Host "👉 Chon Test Case muon chay [A / 1..$($tcList.Count) / B]"
            if ($tcChoice -eq $null) { $tcChoice = "A" }
            $tcChoice = $tcChoice.Trim()

            if ($tcChoice.ToUpper() -eq "B") {
                continue
            }
            elseif ($tcChoice -eq "" -or $tcChoice.ToUpper() -eq "A") {
                Run-Playwright -Files @($selectedFile) -Workers 1 -Description "Chay toan bo menu: $rel"
            }
            elseif ($tcChoice -match "^\d+$") {
                $tcIdx = [int]$tcChoice
                if ($tcIdx -ge 1 -and $tcIdx -le $tcList.Count) {
                    $targetCase = $tcList[$tcIdx - 1]
                    Run-Playwright -Files @($selectedFile) -Workers 1 -Grep $targetCase -Description "Chay rieng: $targetCase"
                } else {
                    Write-Host "So thu tu test case khong hop le!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
            else {
                Write-Host "Lua chon khong hop le!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        } else {
            Write-Host "So thu tu khong hop le! Vui long chon tu 1 den $($testFiles.Count)." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    else {
        Write-Host "Lua chon khong hop le, vui long thu lai!" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}
