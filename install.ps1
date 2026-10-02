# MiNator - One-line installer for Windows PowerShell
# irm https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.ps1 | iex

$Host.UI.RawUI.WindowTitle = "MiNator Installer"
chcp 65001 | Out-Null
Clear-Host

Write-Host " __  __ _ _   _       _            " -ForegroundColor Cyan
Write-Host "|  \/  (_) \ | | __ _| |_ ___  _ __" -ForegroundColor Cyan
Write-Host "| |\/| | |  \| |/ _` | __/ _ \| '__|" -ForegroundColor Cyan
Write-Host "| |  | | | |\  | (_| | || (_) | |  " -ForegroundColor Cyan
Write-Host "|_|  |_|_|_| \_|\__,_|\__\___/|_|  " -ForegroundColor Cyan
Write-Host ""
Write-Host "    [ Xiaomi Bloat Eliminator ]" -ForegroundColor Yellow
Write-Host "       Made by gpsn0w & Claude" -ForegroundColor Yellow
Write-Host "       Keep Privacy First" -ForegroundColor Green
Write-Host "================================================"
Write-Host ""

# Check ADB
$adbFound = $null -ne (Get-Command adb -ErrorAction SilentlyContinue)

if (-not $adbFound) {
    Write-Host "[!] ADB not found on this system." -ForegroundColor Red
    Write-Host ""
    $installAdb = Read-Host "    Install ADB now? [y/N]"

    if ($installAdb -match '^[yY]') {
        Write-Host ""

        # Try winget first
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "[*] Installing via winget..." -ForegroundColor Cyan
            winget install Google.PlatformTools --silent --accept-package-agreements --accept-source-agreements
            # Refresh PATH
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        }
        # Try chocolatey
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[*] Installing via Chocolatey..." -ForegroundColor Cyan
            choco install adb -y
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        }
        else {
            Write-Host "[!] No package manager found (winget/chocolatey)." -ForegroundColor Red
            Write-Host "    Download manually: https://developer.android.com/tools/releases/platform-tools"
            Write-Host "    Extract and add to PATH, then run MiNator again."
            Read-Host "Press Enter to exit"
            exit 1
        }

        if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
            Write-Host "[!] ADB install may need a terminal restart. Please reopen PowerShell and try again." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit 1
        }

        Write-Host ""
        Write-Host "[+] ADB installed!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[!] ADB is required. Install it and run MiNator again." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Download and run MiNator
Write-Host "[*] Downloading MiNator..." -ForegroundColor Cyan
$tmpFile = Join-Path $env:TEMP "minator_$(Get-Random).bat"

try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gpsn0w/MiNator/main/minator.bat" -OutFile $tmpFile -UseBasicParsing
    Write-Host "[+] Done! Starting MiNator..." -ForegroundColor Green
    Write-Host ""
    & cmd.exe /c $tmpFile
} catch {
    Write-Host "[!] Download failed. Check your internet connection." -ForegroundColor Red
} finally {
    if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force }
}
