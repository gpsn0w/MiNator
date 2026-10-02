# MiNator - Xiaomi Bloat Eliminator (PowerShell)
# irm https://raw.githubusercontent.com/gpsn0w/MiNator/main/minator.ps1 | iex

chcp 65001 | Out-Null
$LANG_BG = $false
$COUNT_REMOVED = 0
$COUNT_SKIPPED = 0

function Show-Banner {
    Clear-Host
    Write-Host " __  __ _ _   _       _            " -ForegroundColor Cyan
    Write-Host "|  \/  (_) \ | | __ _| |_ ___  _ __" -ForegroundColor Cyan
    Write-Host "| |\/| | |  \| |/ _`` | __/ _ \| '__|" -ForegroundColor Cyan
    Write-Host "| |  | | | |\  | (_| | || (_) | |  " -ForegroundColor Cyan
    Write-Host "|_|  |_|_|_| \_|\__,_|\__\___/|_|  " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    [ Xiaomi Bloat Eliminator ] v1.0" -ForegroundColor Yellow
    Write-Host "       Made by gpsn0w & Claude" -ForegroundColor Yellow
    Write-Host "       Keep Privacy First" -ForegroundColor Green
    Write-Host "================================================"
    Write-Host ""
}

function T {
    param($en, $bg)
    if ($LANG_BG) { return $bg } else { return $en }
}

function Ask-YN {
    param($question)
    $answer = Read-Host "$question [y/N]"
    $a = $answer.ToLower().Trim()
    return ($a -eq 'y' -or $a -eq 'yes' -or $a -eq 'd' -or $a -eq 'da')
}

function Remove-Pkg {
    param($pkg, $alt, $desc_en, $desc_bg)
    $desc = if ($LANG_BG) { $desc_bg } else { $desc_en }
    if ($alt) { Write-Host "  -> $pkg / $alt" -ForegroundColor White }
    else { Write-Host "  -> $pkg" -ForegroundColor White }
    Write-Host "     $desc" -ForegroundColor Gray

    $msgRemoved   = T 'Removed!' 'Премахнат!'
    $msgAlt       = T 'not found, trying alt...' 'не е намерен, опитвам алтернатива...'
    $msgSkipped   = T 'Already removed before, or not on this device' 'Вече е махнат от преди, или не е на това устройство'

    $result = & adb -s $DEVICE shell pm uninstall -k --user 0 $pkg 2>&1
    if ($result -match "Success") {
        Write-Host "     v $msgRemoved" -ForegroundColor Green
        $script:COUNT_REMOVED++
    } elseif ($alt) {
        Write-Host "     $msgAlt" -ForegroundColor Yellow
        $result2 = & adb -s $DEVICE shell pm uninstall -k --user 0 $alt 2>&1
        if ($result2 -match "Success") {
            Write-Host "     v $msgRemoved" -ForegroundColor Green
            $script:COUNT_REMOVED++
        } else {
            Write-Host "     v $msgSkipped" -ForegroundColor DarkGreen
            $script:COUNT_SKIPPED++
        }
    } else {
        Write-Host "     v $msgSkipped" -ForegroundColor DarkGreen
        $script:COUNT_SKIPPED++
    }
    Write-Host ""
}

# ================================================================
Show-Banner

# Language
Write-Host "Select language / Избери език:"
Write-Host "  [1] English (default)"
Write-Host "  [2] Български"
Write-Host ""
$langChoice = Read-Host "Choice / Избор [1/2]"
if ($langChoice -eq "2") { $LANG_BG = $true }
Write-Host ""

# Instructions
if ($LANG_BG) {
    Write-Host "  КАК ДА ВКЛЮЧИШ ADB:" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------"
    Write-Host "  1. Настройки -> За телефона"
    Write-Host "     Натисни [HyperOS / MIUI версия] 7 пъти"
    Write-Host ""
    Write-Host "  2. Настройки -> Допълнителни -> Developer options"
    Write-Host "     Включи: USB debugging"
    Write-Host ""
    Write-Host "  3. Свържи телефона с USB кабел"
    Write-Host "     Натисни [Allow] на телефона"
    Write-Host ""
    Write-Host "  БЕЗЖИЧНО ADB (Android 11+):"
    Write-Host "  ----------------------------------------"
    Write-Host "  Developer options -> Wireless debugging -> Включи"
    Write-Host "  -> Pair device with pairing code"
    Write-Host "  После: adb pair IP:PORT"
    Write-Host "  После: adb connect IP:PORT"
} else {
    Write-Host "  HOW TO ENABLE ADB:" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------"
    Write-Host "  1. Settings -> About phone"
    Write-Host "     Tap [HyperOS / MIUI Version] 7 times"
    Write-Host ""
    Write-Host "  2. Settings -> Additional settings -> Developer options"
    Write-Host "     Enable: USB debugging"
    Write-Host ""
    Write-Host "  3. Connect phone with USB cable"
    Write-Host "     Tap [Allow] on your phone"
    Write-Host ""
    Write-Host "  WIRELESS ADB (Android 11+):"
    Write-Host "  ----------------------------------------"
    Write-Host "  Developer options -> Wireless debugging -> Enable"
    Write-Host "  -> Pair device with pairing code"
    Write-Host "  Then: adb pair IP:PORT"
    Write-Host "  Then: adb connect IP:PORT"
}
Write-Host "================================================"
Write-Host ""

if (-not (Ask-YN (T 'Did you read the instructions and is your phone ready?' 'Прочете ли инструкциите и готов ли е телефонът?'))) {
    Write-Host ""
    Write-Host (T 'Please set up ADB first, then run MiNator again.' 'Настрой ADB първо, след това пусни MiNator отново.') -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Check ADB
Write-Host (T '[*] Checking ADB...' '[*] Проверявам ADB...') -ForegroundColor Cyan
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Host (T '[!] ADB not found! Install it:' '[!] ADB не е намерен! Инсталирай го:') -ForegroundColor Red
    Write-Host "    winget install Google.PlatformTools"
    Write-Host "    or: https://developer.android.com/tools/releases/platform-tools"
    exit 1
}
Write-Host (T '[+] ADB found!' '[+] ADB намерен!') -ForegroundColor Green
Write-Host ""

# Check device
Write-Host (T '[*] Looking for connected device...' '[*] Търся свързано устройство...') -ForegroundColor Cyan

$adbDevices = & adb devices 2>&1
$DEVICE = $null
$UNAUTH = $null

foreach ($line in ($adbDevices | Select-Object -Skip 1)) {
    $parts = $line -split '\s+'
    if ($parts.Count -ge 2) {
        if ($parts[1] -eq 'device' -and -not $DEVICE) { $DEVICE = $parts[0] }
        if ($parts[1] -eq 'unauthorized' -and -not $UNAUTH) { $UNAUTH = $parts[0] }
    }
}

if (-not $DEVICE -and $UNAUTH) {
    Write-Host (T '[!] Device found but NOT authorized!' '[!] Устройство намерено но НЕ Е оторизирано!') -ForegroundColor Red
    Write-Host (T '    Please tap [Allow] on your phone and try again.' '    Моля натисни [Allow] на телефона и опитай отново.') -ForegroundColor Yellow
    exit 1
}

if (-not $DEVICE) {
    Write-Host (T '[!] No device found!' '[!] Няма свързано устройство!') -ForegroundColor Red
    Write-Host (T '    Connect via USB or Wireless ADB and try again.' '    Свържи се чрез USB или Wireless ADB и опитай отново.') -ForegroundColor Yellow
    exit 1
}

$deviceModel = (& adb -s $DEVICE shell getprop ro.product.marketname 2>&1) -replace '\r',''
if (-not $deviceModel) {
    $deviceModel = (& adb -s $DEVICE shell getprop ro.product.model 2>&1) -replace '\r',''
}
$hyperosVer = (& adb -s $DEVICE shell getprop ro.mi.os.version.name 2>&1) -replace '\r',''
$miuiVer    = (& adb -s $DEVICE shell getprop ro.miui.ui.version.name 2>&1) -replace '\r',''

if ($hyperosVer) { $osType = "HyperOS $hyperosVer" }
elseif ($miuiVer) { $osType = "MIUI $miuiVer" }
else { $osType = "Unknown OS" }

Write-Host (T "[+] Device found: $deviceModel ($osType)" "[+] Устройство намерено: $deviceModel ($osType)") -ForegroundColor Green
Write-Host ""
Write-Host "================================================"
Write-Host ""

# ================================================================
# CATEGORY 1: ADS & ANALYTICS
# ================================================================
if (Ask-YN (T '[?] Remove Ads & Analytics? (spyware, sends your data to Xiaomi)' '[?] Маха Реклами & Аналитика? (шпионира те, праща данни към Xiaomi)')) {
    Remove-Pkg "com.miui.analytics" "" "Mi Analytics - tracks everything you do and sends it to Xiaomi" "Mi Analytics - следи всичко и го праща на Xiaomi"
    Remove-Pkg "com.miui.msa" "" "Mi Service Framework - injects ads directly into your system" "Mi Service Framework - вкарва реклами директно в системата"
    Remove-Pkg "com.miui.systemAdSolution" "" "System Ad Solution - literally has 'ads' in the name :D" "System Ad Solution - буквално има 'реклами' в името :D"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 2: FACEBOOK / LINKEDIN
# ================================================================
if (Ask-YN (T '[?] Remove Facebook & LinkedIn bloatware? (run in background without your consent)' '[?] Маха Facebook & LinkedIn? (работят на заден план без твое съгласие)')) {
    Remove-Pkg "com.facebook.system" "" "Facebook System - spies on you even without Facebook installed" "Facebook System - шпионира те дори без Facebook инсталиран"
    Remove-Pkg "com.facebook.appmanager" "" "Facebook App Manager - can install Facebook apps without asking you" "Facebook App Manager - може да инсталира Facebook без да те пита"
    Remove-Pkg "com.facebook.services" "" "Facebook Services - collects your data even without an account" "Facebook Services - събира данни дори без да имаш акаунт"
    Remove-Pkg "com.linkedin.android" "" "LinkedIn - pre-installed, nobody asked for it" "LinkedIn - предварително инсталиран, никой не го е искал"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 3: MI GAME CENTER
# ================================================================
if (Ask-YN (T '[?] Remove Mi Game Center? (useless if you do not use Xiaomi games)' '[?] Маха Mi Game Center? (безполезен ако не играеш Xiaomi игри)')) {
    Remove-Pkg "com.xiaomi.migameservice" "" "Mi Game Service - Xiaomi's game store nobody uses" "Mi Game Service - Xiaomi магазин за игри, никой не го ползва"
    Remove-Pkg "com.xiaomi.glgm" "" "Mi Game Center - partner in crime of the above" "Mi Game Center - другарят на горното, също безполезен"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 5: MI BROWSER
# ================================================================
if (Ask-YN (T '[?] Remove Mi Browser? (PRIVACY NIGHTMARE - sends your history to Xiaomi)' '[?] Маха Mi Browser? (PRIVACY NIGHTMARE - праща историята ти към Xiaomi)')) {
    Remove-Pkg "com.mi.globalbrowser" "" "Mi Browser - PRIVACY NIGHTMARE! every site you visit gets sent to Xiaomi. Yes, ALL of them. Yes, THAT one too." "Mi Browser - PRIVACY NIGHTMARE! всеки сайт който посещаваш отива при Xiaomi. Да, ВСИЧКИ. Да, и ОНЗИ."
    Remove-Pkg "com.mi.globalbrowser.mini" "" "Mi Browser Mini - same story, just smaller. Still spying on you :)" "Mi Browser Mini - същата история, само по-малко. Пак те шпионира :)"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 6: MI MUSIC & VIDEO
# ================================================================
if (Ask-YN (T '[?] Remove Mi Music & Video? (ad-infested media players)' '[?] Маха Mi Music & Video? (медийни плейъри с реклами)')) {
    Remove-Pkg "com.miui.player" "" "Mi Music - music player with built-in ads, use Spotify instead" "Mi Music - музикален плейър с вградени реклами, ползвай Spotify"
    Remove-Pkg "com.miui.video" "" "Mi Video - video player with built-in ads, use VLC instead" "Mi Video - видео плейър с вградени реклами, ползвай VLC"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 7: GETAPPS
# ================================================================
if (Ask-YN (T '[?] Remove GetApps (Mi Store)? (spam notifications, ads)' '[?] Маха GetApps (Mi Store)? (spam нотификации, реклами)')) {
    Remove-Pkg "com.xiaomi.mipicks" "com.miui.mipicks" "GetApps - Xiaomi's Play Store, full of spam notifications" "GetApps - Xiaomi Play Store, пълен със spam нотификации"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 8: SAFE SYSTEM BLOAT
# ================================================================
if (Ask-YN (T '[?] Remove safe system bloat? (bug reports & user tracking sent to Xiaomi)' '[?] Маха безопасен системен bloat? (bug репорти и проследяване към Xiaomi)')) {
    Remove-Pkg "com.miui.bugreport" "" "Mi Bug Report - auto-sends 'bug reports' to Xiaomi without asking" "Mi Bug Report - автоматично праща 'bug репорти' към Xiaomi без да те пита"
    Remove-Pkg "com.miui.feedback" "" "Mi Feedback - sends how you use your phone as 'feedback'" "Mi Feedback - праща как ползваш телефона като 'feedback'"
    Remove-Pkg "com.miui.usertrack" "" "User Track - literally called 'usertrack', need we say more?" "User Track - буквално се казва 'usertrack', трябва ли да казваме повече?"
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
# CATEGORY 4: MI CLOUD (DOUBLE CONFIRMATION)
# ================================================================
Write-Host (T '[!] WARNING: Mi Cloud is connected to Find My Device!' '[!] ВНИМАНИЕ: Mi Cloud е свързан с Find My Device!') -ForegroundColor Red
Write-Host ""
if (Ask-YN (T '[?] Remove Mi Cloud Backup? (backup to Chinese servers, may affect Find My Device)' '[?] Маха Mi Cloud Backup? (бекъп в китайски сървъри, може да засегне Find My Device)')) {
    Write-Host ""
    Write-Host (T '[!!] SECOND CONFIRMATION REQUIRED!' '[!!] НУЖНО Е ВТОРО ПОТВЪРЖДЕНИЕ!') -ForegroundColor Red
    Write-Host (T '[!!] Find My Device may STOP working if you proceed!' '[!!] Find My Device може да СПРЕ да работи!') -ForegroundColor Red
    Write-Host ""
    if (Ask-YN (T '[?] Are you 100% sure? Confirm removal of Mi Cloud Backup?' '[?] 100% сигурен ли си? Потвърди махането на Mi Cloud Backup?')) {
        Remove-Pkg "com.miui.cloudbackup" "" "Mi Cloud Backup - backs up your data to Chinese servers" "Mi Cloud Backup - прави бекъп на данните ти в китайски сървъри"
    } else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
} else { Write-Host "  -> $(T 'Skipped.' 'Пропуснато.')" -ForegroundColor DarkGray }
Write-Host ""

# ================================================================
Write-Host "================================================"
Write-Host (T '[+] MiNator done! Please RESTART your phone.' '[+] MiNator приключи! Моля РЕСТАРТИРАЙ телефона.') -ForegroundColor Green
Write-Host "------------------------------------------------"
Write-Host (T "    Removed : $COUNT_REMOVED package(s)" "    Махнати : $COUNT_REMOVED пакета") -ForegroundColor Green
Write-Host (T "    Skipped : $COUNT_SKIPPED (already gone or not on device)" "    Пропуснати : $COUNT_SKIPPED (вече махнати или не са на устройството)") -ForegroundColor DarkGray
Write-Host "================================================"
