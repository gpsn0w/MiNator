#!/bin/bash
# ================================================================
#  __  __ _ _   _       _
# |  \/  (_) \ | | __ _| |_ ___  _ __
# | |\/| | |  \| |/ _` | __/ _ \| '__|
# | |  | | | |\  | (_| | || (_) | |
# |_|  |_|_|_| \_|\__,_|\__\___/|_|
#
#       [ Xiaomi Bloat Eliminator ]
#        Made by gpsn0w & Claude
# ================================================================

LANG_BG=false

show_banner() {
    clear
    echo " __  __ _ _   _       _            "
    echo "|  \/  (_) \ | | __ _| |_ ___  _ __"
    echo "| |\/| | |  \| |/ _\` | __/ _ \| '__|"
    echo "| |  | | | |\  | (_| | || (_) | |  "
    echo "|_|  |_|_|_| \_|\__,_|\__\___/|_|  "
    echo ""
    echo "    [ Xiaomi Bloat Eliminator ] v1.0"
    echo "       Made by gpsn0w & Claude"
    echo "          Keep Privacy First"
    echo "================================================"
    echo ""
}

show_instructions() {
    if [ "$LANG_BG" = true ]; then
        echo "  КАК ДА ВКЛЮЧИШ ADB:"
        echo "  ----------------------------------------"
        echo "  1. Настройки → За телефона"
        echo "     Натисни [MIUI версия / HyperOS версия] 7 пъти"
        echo "     (ще видиш: Вече си програмист!)"
        echo ""
        echo "  2. Настройки → Допълнителни настройки → Developer options"
        echo "     Включи: USB debugging"
        echo ""
        echo "  3. Свържи телефона с USB кабел"
        echo "     Натисни [Allow / Разреши] на телефона"
        echo ""
        echo "  БЕЗЖИЧНО ADB (Android 11+):"
        echo "  ----------------------------------------"
        echo "  Настройки → Допълнителни настройки → Developer options"
        echo "  → Wireless debugging → Включи"
        echo "  → Pair device with pairing code"
        echo "  После въведи: adb pair IP:PORT"
        echo "  После въведи: adb connect IP:PORT"
    else
        echo "  HOW TO ENABLE ADB:"
        echo "  ----------------------------------------"
        echo "  1. Settings → About phone"
        echo "     Tap [MIUI Version / HyperOS Version] 7 times"
        echo "     (you will see: You are now a developer!)"
        echo ""
        echo "  2. Settings → Additional settings → Developer options"
        echo "     Enable: USB debugging"
        echo ""
        echo "  3. Connect phone with USB cable"
        echo "     Tap [Allow] on your phone when prompted"
        echo ""
        echo "  WIRELESS ADB (Android 11+):"
        echo "  ----------------------------------------"
        echo "  Settings → Additional settings → Developer options"
        echo "  → Wireless debugging → Enable"
        echo "  → Pair device with pairing code"
        echo "  Then run: adb pair IP:PORT"
        echo "  Then run: adb connect IP:PORT"
    fi
    echo "================================================"
    echo ""
    if ask_yn "$(t 'Did you read the instructions and is your phone ready?' 'Прочете ли инструкциите и готов ли е телефонът?')"; then
        echo ""
    else
        echo ""
        echo "$(t 'Please set up ADB first, then run MiNator again.' 'Настрой ADB първо, след това пусни MiNator отново.')"
        exit 0
    fi
}

select_language() {
    echo "Select language / Избери език:"
    echo "  [1] English (default)"
    echo "  [2] Български"
    echo ""
    read -p "Choice / Избор [1/2]: " lang_choice
    if [ "$lang_choice" = "2" ]; then
        LANG_BG=true
    fi
    echo ""
}

t() {
    if [ "$LANG_BG" = true ]; then
        echo "$2"
    else
        echo "$1"
    fi
}

ask_yn() {
    local question="$1"
    local answer
    read -p "$question [y/N]: " answer
    case "$answer" in
        [yY]|[yY][eE][sS]|[дД]|[дД][аА]) return 0 ;;
        *) return 1 ;;
    esac
}

remove_pkg() {
    local pkg="$1"
    local alt="$2"
    local desc_en="$3"
    local desc_bg="$4"
    local desc

    if [ "$LANG_BG" = true ]; then desc="$desc_bg"; else desc="$desc_en"; fi

    if [ -n "$alt" ]; then
        echo "  → $pkg / $alt"
    else
        echo "  → $pkg"
    fi
    echo "     $desc"
    printf "     "

    result=$(adb shell pm uninstall -k --user 0 "$pkg" 2>&1)

    if echo "$result" | grep -q "Success"; then
        echo "✓ $(t 'Removed!' 'Премахнат!')"
    elif [ -n "$alt" ]; then
        echo "$(t 'not found, trying alt...' 'не е намерен, опитвам алтернатива...')"
        printf "     "
        result2=$(adb shell pm uninstall -k --user 0 "$alt" 2>&1)
        if echo "$result2" | grep -q "Success"; then
            echo "✓ $(t 'Removed!' 'Премахнат!')"
        else
            echo "✓ $(t 'Already removed before, or not on this device 😊' 'Вече е махнат от преди, или не е на това устройство 😊')"
        fi
    else
        echo "✓ $(t 'Already removed before, or not on this device 😊' 'Вече е махнат от преди, или не е на това устройство 😊')"
    fi
    echo ""
}

# ================================================================
show_banner
select_language
show_instructions

# Check ADB
echo "$(t '[*] Checking ADB...' '[*] Проверявам ADB...')"
if ! command -v adb &> /dev/null; then
    echo "$(t '[!] ADB not found! Install it:' '[!] ADB не е намерен! Инсталирай го:')"
    echo "    Mac:    brew install android-platform-tools"
    echo "    Ubuntu/Debian: sudo apt install adb"
    echo "    Fedora: sudo dnf install android-tools"
    exit 1
fi
echo "$(t '[+] ADB found!' '[+] ADB намерен!')"
echo ""

# Check device
echo "$(t '[*] Looking for connected device...' '[*] Търся свързано устройство...')"
device_line=$(adb devices | grep -v "List" | grep "device$" | head -1)

if [ -z "$device_line" ]; then
    echo "$(t '[!] No device found!' '[!] Няма свързано устройство!')"
    echo ""
    echo "$(t 'How to connect:' 'Как да се свържеш:')"
    echo "  1. $(t 'Enable USB Debugging:' 'Включи USB Debugging:')"
    echo "     $(t 'Settings → About phone → tap Build number 7 times → Developer Options → USB Debugging' 'Настройки → За телефона → натисни Build number 7 пъти → Developer Options → USB Debugging')"
    echo "  2. $(t 'Connect with USB cable' 'Свържи с USB кабел')"
    echo "  3. $(t 'Tap Allow on your phone' 'Натисни Allow на телефона')"
    exit 1
fi

device_model=$(adb shell getprop ro.product.marketname 2>/dev/null | tr -d '\r')
if [ -z "$device_model" ]; then
    device_model=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
fi
hyperos_version=$(adb shell getprop ro.mi.os.version.name 2>/dev/null | tr -d '\r')
miui_version=$(adb shell getprop ro.miui.ui.version.name 2>/dev/null | tr -d '\r')

if [ -n "$hyperos_version" ]; then
    os_type="HyperOS $hyperos_version"
elif [ -n "$miui_version" ]; then
    os_type="MIUI $miui_version"
else
    os_type="Unknown OS"
fi

echo "$(t "[+] Device found: $device_model ($os_type)" "[+] Устройство намерено: $device_model ($os_type)")"
echo ""
echo "================================================"
echo ""

# ================================================================
# CATEGORY 1: ADS & ANALYTICS
# ================================================================
if ask_yn "$(t '[?] Remove Ads & Analytics? (spyware, sends your data to Xiaomi)' '[?] Маха Реклами & Аналитика? (шпионира те, праща данни към Xiaomi)')"; then
    remove_pkg "com.miui.analytics" "" \
        "Mi Analytics - tracks everything you do and sends it to Xiaomi 🕵️" \
        "Mi Analytics - следи всичко и го праща на Xiaomi 🕵️"
    remove_pkg "com.miui.msa" "" \
        "Mi Service Framework - injects ads directly into your system 📢" \
        "Mi Service Framework - вкарва реклами директно в системата 📢"
    remove_pkg "com.xiaomi.mipicks" "com.miui.mipicks" \
        "Mi Picks - spam ads you never asked for 🗑️" \
        "Mi Picks - spam реклами, които никой не е искал 🗑️"
    remove_pkg "com.miui.systemAdSolution" "" \
        "System Ad Solution - literally has 'ads' in the name 😂" \
        "System Ad Solution - буквално има 'реклами' в името 😂"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 2: FACEBOOK / LINKEDIN
# ================================================================
if ask_yn "$(t '[?] Remove Facebook & LinkedIn bloatware? (run in background without your consent)' '[?] Маха Facebook & LinkedIn? (работят на заден план без твое съгласие)')"; then
    remove_pkg "com.facebook.system" "" \
        "Facebook System - spies on you even without Facebook installed 👁️" \
        "Facebook System - шпионира те дори без Facebook инсталиран 👁️"
    remove_pkg "com.facebook.appmanager" "" \
        "Facebook App Manager - can install Facebook apps without asking you 😤" \
        "Facebook App Manager - може да инсталира Facebook без да те пита 😤"
    remove_pkg "com.facebook.services" "" \
        "Facebook Services - collects your data even without an account 🤦" \
        "Facebook Services - събира данни дори без да имаш акаунт 🤦"
    remove_pkg "com.linkedin.android" "" \
        "LinkedIn - pre-installed, nobody asked for it 🤷" \
        "LinkedIn - предварително инсталиран, никой не го е искал 🤷"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 3: MI GAME CENTER
# ================================================================
if ask_yn "$(t '[?] Remove Mi Game Center? (useless if you do not use Xiaomi games)' '[?] Маха Mi Game Center? (безполезен ако не играеш Xiaomi игри)')"; then
    remove_pkg "com.xiaomi.migameservice" "" \
        "Mi Game Service - Xiaomi's game store nobody uses 🎮" \
        "Mi Game Service - Xiaomi магазин за игри, никой не го ползва 🎮"
    remove_pkg "com.xiaomi.glgm" "" \
        "Mi Game Center - partner in crime of the above 🎮" \
        "Mi Game Center - другарят на горното, също безполезен 🎮"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 5: MI BROWSER (privacy nightmare)
# ================================================================
if ask_yn "$(t '[?] Remove Mi Browser? (privacy nightmare - sends your history to Xiaomi)' '[?] Маха Mi Browser? (privacy nightmare - праща историята ти към Xiaomi)')"; then
    remove_pkg "com.mi.globalbrowser" "" \
        "Mi Browser - PRIVACY NIGHTMARE! every site you visit gets sent to Xiaomi. Yes, ALL of them. Yes, THAT one too." \
        "Mi Browser - PRIVACY NIGHTMARE! всеки сайт който посещаваш отива при Xiaomi. Да, ВСИЧКИ. Да, и ОНЗИ."
    remove_pkg "com.mi.globalbrowser.mini" "" \
        "Mi Browser Mini - same story, just smaller. Still spying on you 😅" \
        "Mi Browser Mini - същата история, само по-малко. Пак те шпионира 😅"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 6: MI MUSIC & VIDEO
# ================================================================
if ask_yn "$(t '[?] Remove Mi Music & Video? (ad-infested media players)' '[?] Маха Mi Music & Video? (медийни плейъри с реклами)')"; then
    remove_pkg "com.miui.player" "" \
        "Mi Music - music player with built-in ads, use Spotify instead 🎵💸" \
        "Mi Music - музикален плейър с вградени реклами, ползвай Spotify 🎵💸"
    remove_pkg "com.miui.video" "" \
        "Mi Video - video player with built-in ads, use VLC instead 🎬💸" \
        "Mi Video - видео плейър с вградени реклами, ползвай VLC 🎬💸"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 7: GETAPPS / MI STORE
# ================================================================
if ask_yn "$(t '[?] Remove GetApps (Mi Store)? (spam notifications, ads)' '[?] Маха GetApps (Mi Store)? (spam нотификации, реклами)')"; then
    remove_pkg "com.xiaomi.mipicks" "com.miui.mipicks" \
        "GetApps - Xiaomi's Play Store, full of spam notifications 📦🗑️" \
        "GetApps - Xiaomi Play Store, пълен със spam нотификации 📦🗑️"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 8: SAFE SYSTEM BLOAT
# ================================================================
if ask_yn "$(t '[?] Remove safe system bloat? (bug reports & user tracking sent to Xiaomi)' '[?] Маха безопасен системен bloat? (bug репорти и проследяване към Xiaomi)')"; then
    remove_pkg "com.miui.bugreport" "" \
        "Mi Bug Report - auto-sends 'bug reports' to Xiaomi without asking 🐛" \
        "Mi Bug Report - автоматично праща 'bug репорти' към Xiaomi без да те пита 🐛"
    remove_pkg "com.miui.feedback" "" \
        "Mi Feedback - sends how you use your phone as 'feedback' 📊" \
        "Mi Feedback - праща как ползваш телефона като 'feedback' 📊"
    remove_pkg "com.miui.usertrack" "" \
        "User Track - literally called 'usertrack', need we say more? 😱" \
        "User Track - буквално се казва 'usertrack', трябва ли да казваме повече? 😱"
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
# CATEGORY 4: MI CLOUD (DOUBLE CONFIRMATION - FIND MY WARNING)
# ================================================================
echo "$(t '[!] WARNING: Mi Cloud is connected to Find My Device!' '[!] ВНИМАНИЕ: Mi Cloud е свързан с Find My Device!')"
echo ""
if ask_yn "$(t '[?] Remove Mi Cloud Backup? (backup to Chinese servers, may affect Find My Device)' '[?] Маха Mi Cloud Backup? (бекъп в китайски сървъри, може да засегне Find My Device)')"; then
    echo ""
    echo "$(t '[!!] SECOND CONFIRMATION REQUIRED!' '[!!] НУЖНО Е ВТОРО ПОТВЪРЖДЕНИЕ!')"
    echo "$(t '[!!] Find My Device may STOP working if you proceed!' '[!!] Find My Device може да СПРЕ да работи!')"
    echo ""
    if ask_yn "$(t '[?] Are you 100% sure? Confirm removal of Mi Cloud Backup?' '[?] 100% сигурен ли си? Потвърди махането на Mi Cloud Backup?')"; then
        remove_pkg "com.miui.cloudbackup" "" \
            "Mi Cloud Backup - backs up your data to Chinese servers ☁️" \
            "Mi Cloud Backup - прави бекъп на данните ти в китайски сървъри ☁️"
    else
        echo "  $(t '→ Skipped.' '→ Пропуснато.')"
    fi
else
    echo "  $(t '→ Skipped.' '→ Пропуснато.')"
fi
echo ""

# ================================================================
echo "================================================"
echo "$(t '[+] MiNator done! Please RESTART your phone.' '[+] MiNator приключи! Моля РЕСТАРТИРАЙ телефона.')"
echo "================================================"
