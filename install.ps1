# MiNator - One-line installer for Windows PowerShell
# irm https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.ps1 | iex

$Host.UI.RawUI.WindowTitle = "MiNator Installer"
chcp 65001 | Out-Null
Clear-Host

Write-Host " __  __ _ _   _       _            " -ForegroundColor Cyan
Write-Host "|  \/  (_) \ | | __ _| |_ ___  _ __" -ForegroundColor Cyan
Write-Host "| |\/| | |  \| |/ _`` | __/ _ \| '__|" -ForegroundColor Cyan
Write-Host "| |  | | | |\  | (_| | || (_) | |  " -ForegroundColor Cyan
Write-Host "|_|  |_|_|_| \_|\__,_|\__\___/|_|  " -ForegroundColor Cyan
Write-Host ""
Write-Host "    [ Xiaomi Bloat Eliminator ]" -ForegroundColor Yellow
Write-Host "       Made by gpsn0w & Claude" -ForegroundColor Yellow
Write-Host "       Keep Privacy First" -ForegroundColor Green
Write-Host "================================================"
Write-Host ""

function Show-ManualInstall {
    Write-Host ""
    Write-Host "  +---------------------------------------------+" -ForegroundColor Yellow
    Write-Host "  |       HOW TO INSTALL ADB MANUALLY          |" -ForegroundColor Yellow
    Write-Host "  +---------------------------------------------+" -ForegroundColor Yellow
    Write-Host "  |                                             |"
    Write-Host "  |  1. Download Android Platform Tools:       |"
    Write-Host "  |                                             |"
    Write-Host "  |  >> https://developer.android.com/tools/   |" -ForegroundColor Cyan
    Write-Host "  |     releases/platform-tools                |" -ForegroundColor Cyan
    Write-Host "  |                                             |"
    Write-Host "  |  2. Extract the ZIP (e.g. C:\platform-tools)|"
    Write-Host "  |                                             |"
    Write-Host "  |  3. Add to PATH:                           |"
    Write-Host "  |     Start → search 'Environment Variables' |"
    Write-Host "  |     → Edit PATH → Add your folder path     |"
    Write-Host "  |                                             |"
    Write-Host "  |  4. Restart PowerShell and run again:      |"
    Write-Host "  |     irm https://raw.githubusercontent.com/ |" -ForegroundColor Cyan
    Write-Host "  |     gpsn0w/MiNator/main/install.ps1 | iex  |" -ForegroundColor Cyan
    Write-Host "  |                                             |"
    Write-Host "  +---------------------------------------------+" -ForegroundColor Yellow
    Write-Host ""
}

# Check ADB
$adbFound = $null -ne (Get-Command adb -ErrorAction SilentlyContinue)

if (-not $adbFound) {
    Write-Host "[!] ADB not found on this system." -ForegroundColor Red
    Write-Host ""
    $installAdb = Read-Host "    Install ADB now? [y/N]"

    if ($installAdb -match '^[yY]') {
        Write-Host ""
        $installed = $false

        # Try winget
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "[*] Installing via winget..." -ForegroundColor Cyan
            winget install Google.PlatformTools --silent --accept-package-agreements --accept-source-agreements
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
            $installed = $true
        }
        # Try chocolatey
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[*] Installing via Chocolatey..." -ForegroundColor Cyan
            choco install adb -y
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
            $installed = $true
        }

        if (-not $installed) {
            Write-Host "[!] No package manager found (winget / chocolatey)." -ForegroundColor Red
            Show-ManualInstall
            Read-Host "Press Enter to exit"
            exit 1
        }

        # Verify ADB is now available
        if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
            Write-Host ""
            Write-Host "[!] ADB was installed but is not in PATH yet." -ForegroundColor Yellow
            Write-Host "    Please close this window, open a new PowerShell, and run again:" -ForegroundColor Yellow
            Write-Host "    irm https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.ps1 | iex" -ForegroundColor Cyan
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }

        Write-Host ""
        Write-Host "[+] ADB installed!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[!] ADB is required to run MiNator." -ForegroundColor Red
        Show-ManualInstall
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
