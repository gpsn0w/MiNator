@echo off
chcp 65001 > nul
title MiNator - Xiaomi Bloat Eliminator
setlocal enabledelayedexpansion

set LANG_BG=0

:BANNER
cls
echo  __  __ _ _   _       _
echo ^|  \/  (_) \ ^| ^| __ _^| ^|_ ___  _ __
echo ^| ^|\/^| ^| ^|  \^| ^|/ _`  ^| __/ _ \^| '__^|
echo ^| ^|  ^| ^| ^| ^|^\  ^| (_^| ^| ^|^| (_) ^| ^|
echo ^|_^|  ^|_^|_^|_^| \_^|\__,_^\__\___/^|_^|
echo.
echo     [ Xiaomi Bloat Eliminator ] v1.0
echo        Made by gpsn0w ^& Claude
echo           Keep Privacy First
echo ================================================
echo.
rem Instructions shown after language selection - see :SHOW_INSTRUCTIONS
echo.

:SELECT_LANG
echo Select language / Избери език:
echo   [1] English (default)
echo   [2] Български
echo.
set /p lang_choice="Choice / Избор [1/2]: "
if "%lang_choice%"=="2" set LANG_BG=1
echo.

rem ================================================================
rem Show instructions in selected language
rem ================================================================
if %LANG_BG%==1 (
    echo   КАК ДА ВКЛЮЧИШ ADB:
    echo   ----------------------------------------
    echo   1. Настройки -^> За телефона
    echo      Натисни [MIUI версия / HyperOS версия] 7 пъти
    echo      ^(ще видиш: Вече си програмист!^)
    echo.
    echo   2. Настройки -^> Допълнителни настройки -^> Developer options
    echo      Включи: USB debugging
    echo.
    echo   3. Свържи телефона с USB кабел
    echo      Натисни [Allow / Разреши] на телефона
    echo.
    echo   БЕЗЖИЧНО ADB ^(Android 11+^):
    echo   ----------------------------------------
    echo   Настройки -^> Допълнителни настройки -^> Developer options
    echo   -^> Wireless debugging -^> Включи
    echo   -^> Pair device with pairing code
    echo   После въведи: adb pair IP:PORT
    echo   После въведи: adb connect IP:PORT
) else (
    echo   HOW TO ENABLE ADB:
    echo   ----------------------------------------
    echo   1. Settings -^> About phone
    echo      Tap [MIUI Version / HyperOS Version] 7 times
    echo      ^(you will see: You are now a developer!^)
    echo.
    echo   2. Settings -^> Additional settings -^> Developer options
    echo      Enable: USB debugging
    echo.
    echo   3. Connect phone with USB cable
    echo      Tap [Allow] on your phone when prompted
    echo.
    echo   WIRELESS ADB ^(Android 11+^):
    echo   ----------------------------------------
    echo   Settings -^> Additional settings -^> Developer options
    echo   -^> Wireless debugging -^> Enable
    echo   -^> Pair device with pairing code
    echo   Then run: adb pair IP:PORT
    echo   Then run: adb connect IP:PORT
)
echo ================================================
echo.
if %LANG_BG%==1 (
    set /p ready="Прочете ли инструкциите и готов ли е телефонът? [y/N]: "
) else (
    set /p ready="Did you read the instructions and is your phone ready? [y/N]: "
)
if /i not "!ready!"=="y" (
    if %LANG_BG%==1 (
        echo Настрой ADB първо, след това пусни MiNator отново.
    ) else (
        echo Please set up ADB first, then run MiNator again.
    )
    pause
    exit /b
)
echo.

rem ================================================================
rem Check ADB
rem ================================================================
if %LANG_BG%==1 (
    echo [*] Проверявам ADB...
) else (
    echo [*] Checking ADB...
)

adb version > nul 2>&1
if errorlevel 1 (
    if %LANG_BG%==1 (
        echo [!] ADB не е намерен! Инсталирай го от:
    ) else (
        echo [!] ADB not found! Download from:
    )
    echo     https://developer.android.com/tools/releases/platform-tools
    echo.
    pause
    exit /b
)

if %LANG_BG%==1 (
    echo [+] ADB намерен!
) else (
    echo [+] ADB found!
)
echo.

rem ================================================================
rem Check device
rem ================================================================
if %LANG_BG%==1 (
    echo [*] Търся свързано устройство...
) else (
    echo [*] Looking for connected device...
)

set DEVICE=
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" if not defined DEVICE set DEVICE=%%a
)

set UNAUTH=
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="unauthorized" if not defined UNAUTH set UNAUTH=%%a
)

if not defined DEVICE (
    if defined UNAUTH (
        if %LANG_BG%==1 (
            echo [!] Устройство намерено но НЕ Е оторизирано!
            echo     Моля натисни [Allow] на телефона и опитай отново.
        ) else (
            echo [!] Device found but NOT authorized!
            echo     Please tap [Allow] on your phone and try again.
        )
        pause
        exit /b
    )
    if %LANG_BG%==1 (
        echo [!] Няма свързано устройство!
        echo.
        echo   1. Включи USB Debugging:
        echo      Настройки - За телефона - натисни Build number 7 пъти
        echo      Developer Options - USB Debugging
        echo   2. Свържи с USB кабел
        echo   3. Натисни Allow на телефона
    ) else (
        echo [!] No device found!
        echo.
        echo   1. Enable USB Debugging:
        echo      Settings - About phone - tap Build number 7 times
        echo      Developer Options - USB Debugging
        echo   2. Connect with USB cable
        echo   3. Tap Allow on your phone
    )
    echo.
    pause
    exit /b
)

for /f "delims=" %%a in ('adb -s %DEVICE% shell getprop ro.product.marketname 2^>nul') do set MODEL=%%a
if not defined MODEL (
    for /f "delims=" %%a in ('adb -s %DEVICE% shell getprop ro.product.model 2^>nul') do set MODEL=%%a
)
for /f "delims=" %%a in ('adb -s %DEVICE% shell getprop ro.mi.os.version.name 2^>nul') do set HYPEROS=%%a
for /f "delims=" %%a in ('adb -s %DEVICE% shell getprop ro.miui.ui.version.name 2^>nul') do set MIUI=%%a

if defined HYPEROS (
    set OS_TYPE=HyperOS %HYPEROS%
) else if defined MIUI (
    set OS_TYPE=MIUI %MIUI%
) else (
    set OS_TYPE=Unknown OS
)

if %LANG_BG%==1 (
    echo [+] Устройство намерено: %MODEL% ^(%OS_TYPE%^)
) else (
    echo [+] Device found: %MODEL% ^(%OS_TYPE%^)
)
echo.
echo ================================================
echo.

rem ================================================================
rem CATEGORY 1: ADS & ANALYTICS
rem ================================================================
if %LANG_BG%==1 (
    set /p ans1="[?] Маха Реклами & Аналитика? (шпионира те) [y/N]: "
) else (
    set /p ans1="[?] Remove Ads & Analytics? (spyware, sends data to Xiaomi) [y/N]: "
)
if /i "!ans1!"=="y" (
    call :remove_pkg "com.miui.analytics" "" "Mi Analytics - tracks everything you do and sends it to Xiaomi 🕵️" "Mi Analytics - следи всичко и го праща на Xiaomi 🕵️"
    call :remove_pkg "com.miui.msa" "" "Mi Service Framework - injects ads directly into your system 📢" "Mi Service Framework - вкарва реклами директно в системата 📢"
    call :remove_pkg "com.miui.systemAdSolution" "" "System Ad Solution - literally has 'ads' in the name 😂" "System Ad Solution - буквално има 'реклами' в името 😂"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 2: FACEBOOK / LINKEDIN
rem ================================================================
if %LANG_BG%==1 (
    set /p ans2="[?] Маха Facebook & LinkedIn? (работят на заден план) [y/N]: "
) else (
    set /p ans2="[?] Remove Facebook & LinkedIn bloatware? [y/N]: "
)
if /i "!ans2!"=="y" (
    call :remove_pkg "com.facebook.system" "" "Facebook System - spies on you even without Facebook installed 👁️" "Facebook System - шпионира те дори без Facebook инсталиран 👁️"
    call :remove_pkg "com.facebook.appmanager" "" "Facebook App Manager - can install Facebook without asking you 😤" "Facebook App Manager - може да инсталира Facebook без да те пита 😤"
    call :remove_pkg "com.facebook.services" "" "Facebook Services - collects your data even without an account 🤦" "Facebook Services - събира данни дори без да имаш акаунт 🤦"
    call :remove_pkg "com.linkedin.android" "" "LinkedIn - pre-installed, nobody asked for it 🤷" "LinkedIn - предварително инсталиран, никой не го е искал 🤷"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 3: MI GAME CENTER
rem ================================================================
if %LANG_BG%==1 (
    set /p ans3="[?] Маха Mi Game Center? (безполезен ако не играеш Xiaomi игри) [y/N]: "
) else (
    set /p ans3="[?] Remove Mi Game Center? (useless if you don't play Xiaomi games) [y/N]: "
)
if /i "!ans3!"=="y" (
    call :remove_pkg "com.xiaomi.migameservice" "" "Mi Game Service - Xiaomi's game store nobody uses 🎮" "Mi Game Service - Xiaomi магазин за игри, никой не го ползва 🎮"
    call :remove_pkg "com.xiaomi.glgm" "" "Mi Game Center - partner in crime of the above 🎮" "Mi Game Center - другарят на горното, също безполезен 🎮"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 5: MI BROWSER
rem ================================================================
if %LANG_BG%==1 (
    set /p ans5="[?] Маха Mi Browser? (privacy nightmare - праща историята ти към Xiaomi) [y/N]: "
) else (
    set /p ans5="[?] Remove Mi Browser? (privacy nightmare - sends your history to Xiaomi) [y/N]: "
)
if /i "!ans5!"=="y" (
    call :remove_pkg "com.mi.globalbrowser" "" "Mi Browser - PRIVACY NIGHTMARE! every site you visit gets sent to Xiaomi. Yes, ALL of them. Yes, THAT one too." "Mi Browser - PRIVACY NIGHTMARE! всеки сайт който посещаваш отива при Xiaomi. Да, ВСИЧКИ. Да, и ОНЗИ."
    call :remove_pkg "com.mi.globalbrowser.mini" "" "Mi Browser Mini - same story, just smaller. Still spying on you 😅" "Mi Browser Mini - същата история, само по-малко. Пак те шпионира 😅"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 6: MI MUSIC & VIDEO
rem ================================================================
if %LANG_BG%==1 (
    set /p ans6="[?] Маха Mi Music & Video? (медийни плейъри с реклами) [y/N]: "
) else (
    set /p ans6="[?] Remove Mi Music & Video? (ad-infested media players) [y/N]: "
)
if /i "!ans6!"=="y" (
    call :remove_pkg "com.miui.player" "" "Mi Music - music player with built-in ads, use Spotify instead 🎵💸" "Mi Music - музикален плейър с вградени реклами, ползвай Spotify 🎵💸"
    call :remove_pkg "com.miui.video" "" "Mi Video - video player with built-in ads, use VLC instead 🎬💸" "Mi Video - видео плейър с вградени реклами, ползвай VLC 🎬💸"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 7: GETAPPS / MI STORE
rem ================================================================
if %LANG_BG%==1 (
    set /p ans7="[?] Маха GetApps (Mi Store)? (spam нотификации, реклами) [y/N]: "
) else (
    set /p ans7="[?] Remove GetApps (Mi Store)? (spam notifications, ads) [y/N]: "
)
if /i "!ans7!"=="y" (
    call :remove_pkg "com.xiaomi.mipicks" "com.miui.mipicks" "GetApps - Xiaomi's Play Store, full of spam notifications 📦🗑️" "GetApps - Xiaomi Play Store, пълен със spam нотификации 📦🗑️"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 8: SAFE SYSTEM BLOAT
rem ================================================================
if %LANG_BG%==1 (
    set /p ans8="[?] Маха безопасен системен bloat? (bug репорти и проследяване към Xiaomi) [y/N]: "
) else (
    set /p ans8="[?] Remove safe system bloat? (bug reports & user tracking sent to Xiaomi) [y/N]: "
)
if /i "!ans8!"=="y" (
    call :remove_pkg "com.miui.bugreport" "" "Mi Bug Report - auto-sends 'bug reports' to Xiaomi without asking 🐛" "Mi Bug Report - автоматично праща 'bug репорти' към Xiaomi без да те пита 🐛"
    call :remove_pkg "com.miui.feedback" "" "Mi Feedback - sends how you use your phone as 'feedback' 📊" "Mi Feedback - праща как ползваш телефона като 'feedback' 📊"
    call :remove_pkg "com.miui.usertrack" "" "User Track - literally called 'usertrack', need we say more? 😱" "User Track - буквално се казва 'usertrack', трябва ли да казваме повече? 😱"
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
rem CATEGORY 4: MI CLOUD (DOUBLE CONFIRMATION)
rem ================================================================
if %LANG_BG%==1 (
    echo [!] ВНИМАНИЕ: Mi Cloud е свързан с Find My Device!
) else (
    echo [!] WARNING: Mi Cloud is connected to Find My Device!
)
echo.
if %LANG_BG%==1 (
    set /p ans4a="[?] Маха Mi Cloud Backup? (бекъп в китайски сървъри) [y/N]: "
) else (
    set /p ans4a="[?] Remove Mi Cloud Backup? (backup to Chinese servers) [y/N]: "
)
if /i "!ans4a!"=="y" (
    echo.
    if %LANG_BG%==1 (
        echo [!!] НУЖНО Е ВТОРО ПОТВЪРЖДЕНИЕ!
        echo [!!] Find My Device може да СПРЕ да работи!
        echo.
        set /p ans4b="[?] 100%% сигурен ли си? Потвърди махането на Mi Cloud Backup? [y/N]: "
    ) else (
        echo [!!] SECOND CONFIRMATION REQUIRED!
        echo [!!] Find My Device may STOP working if you proceed!
        echo.
        set /p ans4b="[?] Are you 100%% sure? Confirm removal of Mi Cloud Backup? [y/N]: "
    )
    if /i "!ans4b!"=="y" (
        call :remove_pkg "com.miui.cloudbackup" "" "Mi Cloud Backup - backs up your data to Chinese servers ☁️" "Mi Cloud Backup - прави бекъп на данните ти в китайски сървъри ☁️"
    ) else (
        if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
    )
) else (
    if %LANG_BG%==1 (echo   -^> Пропуснато.) else (echo   -^> Skipped.)
)
echo.

rem ================================================================
echo ================================================
if %LANG_BG%==1 (
    echo [+] MiNator приключи! Моля РЕСТАРТИРАЙ телефона.
) else (
    echo [+] MiNator done! Please RESTART your phone.
)
echo ================================================
echo.
pause
exit /b

rem ================================================================
:remove_pkg
set PKG=%~1
set ALT=%~2
set DESC_EN=%~3
set DESC_BG=%~4
set RESULT_FILE=%TEMP%\minator_tmp.txt

if not "%ALT%"=="" (
    echo   -^> %PKG% / %ALT%
) else (
    echo   -^> %PKG%
)
if %LANG_BG%==1 (
    echo      %DESC_BG%
) else (
    echo      %DESC_EN%
)
<nul set /p "     "
adb -s %DEVICE% shell pm uninstall -k --user 0 %PKG% > "%RESULT_FILE%" 2>&1
findstr /c:"Success" "%RESULT_FILE%" > nul
if not errorlevel 1 (
    if %LANG_BG%==1 (echo OK - Премахнат!) else (echo OK - Removed!)
    echo.
    goto :eof
)
if not "%ALT%"=="" (
    if %LANG_BG%==1 (echo не е намерен, опитвам алтернатива...) else (echo not found, trying alt...)
    <nul set /p "     "
    adb -s %DEVICE% shell pm uninstall -k --user 0 %ALT% > "%RESULT_FILE%" 2>&1
    findstr /c:"Success" "%RESULT_FILE%" > nul
    if not errorlevel 1 (
        if %LANG_BG%==1 (echo OK - Премахнат!) else (echo OK - Removed!)
    ) else (
        if %LANG_BG%==1 (echo OK - Вече е махнат от преди, или не е на това устройство :^)) else (echo OK - Already removed before, or not on this device :^))
    )
) else (
    if %LANG_BG%==1 (echo OK - Вече е махнат от преди, или не е на това устройство :^)) else (echo OK - Already removed before, or not on this device :^))
)
echo.
goto :eof
