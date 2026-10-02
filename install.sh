#!/bin/bash
# MiNator - One-line installer for Mac/Linux
# curl -fsSL https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.sh | bash

clear
echo " __  __ _ _   _       _            "
echo "|  \/  (_) \ | | __ _| |_ ___  _ __"
echo "| |\/| | |  \| |/ _\` | __/ _ \| '__|"
echo "| |  | | | |\  | (_| | || (_) | |  "
echo "|_|  |_|_|_| \_|\__,_|\__\___/|_|  "
echo ""
echo "    [ Xiaomi Bloat Eliminator ]"
echo "       Made by gpsn0w & Claude"
echo "       Keep Privacy First"
echo "================================================"
echo ""

install_adb_manual() {
    echo ""
    echo "  ┌─────────────────────────────────────────────┐"
    echo "  │         HOW TO INSTALL ADB MANUALLY         │"
    echo "  ├─────────────────────────────────────────────┤"
    echo "  │                                             │"
    echo "  │  1. Download Android Platform Tools:        │"
    echo "  │     https://developer.android.com/tools/    │"
    echo "  │     releases/platform-tools                 │"
    echo "  │                                             │"
    if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  │  2. Extract the ZIP to a folder             │"
    echo "  │     e.g. ~/platform-tools                   │"
    echo "  │                                             │"
    echo "  │  3. Add to PATH — run this command:         │"
    echo "  │     echo 'export PATH=\$PATH:~/platform-tools'│"
    echo "  │     >> ~/.zshrc && source ~/.zshrc          │"
    else
    echo "  │  2. Extract the ZIP to a folder             │"
    echo "  │     e.g. ~/platform-tools                   │"
    echo "  │                                             │"
    echo "  │  3. Add to PATH — run this command:         │"
    echo "  │     echo 'export PATH=\$PATH:~/platform-tools'│"
    echo "  │     >> ~/.bashrc && source ~/.bashrc        │"
    fi
    echo "  │                                             │"
    echo "  │  4. Run MiNator again:                      │"
    echo "  │     curl -fsSL https://raw.githubusercontent│"
    echo "  │     .com/gpsn0w/MiNator/main/install.sh    │"
    echo "  │     | bash                                  │"
    echo "  │                                             │"
    echo "  └─────────────────────────────────────────────┘"
    echo ""
}

# Check ADB
if ! command -v adb &> /dev/null; then
    echo "[!] ADB not found on this system."
    echo ""
    read -r -p "    Install ADB now? [y/N]: " install_adb
    case "$install_adb" in
        [yY]|[yY][eE][sS])
            echo ""
            if [[ "$OSTYPE" == "darwin"* ]]; then
                if command -v brew &> /dev/null; then
                    echo "[*] Installing via Homebrew..."
                    brew install android-platform-tools
                else
                    echo "[!] Homebrew not found."
                    echo ""
                    echo "    Install Homebrew first with this command:"
                    echo ""
                    echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
                    echo ""
                    echo "    Then install ADB:"
                    echo "    brew install android-platform-tools"
                    echo ""
                    echo "    Or install ADB manually:"
                    install_adb_manual
                    exit 1
                fi
            elif command -v apt &> /dev/null; then
                echo "[*] Installing via apt..."
                sudo apt update && sudo apt install -y adb
            elif command -v dnf &> /dev/null; then
                echo "[*] Installing via dnf..."
                sudo dnf install -y android-tools
            elif command -v pacman &> /dev/null; then
                echo "[*] Installing via pacman..."
                sudo pacman -S --noconfirm android-tools
            elif command -v zypper &> /dev/null; then
                echo "[*] Installing via zypper..."
                sudo zypper install -y android-tools
            else
                echo "[!] No supported package manager found (apt / dnf / pacman / brew)."
                install_adb_manual
                exit 1
            fi
            echo ""
            echo "[+] ADB installed!"
            echo ""
            ;;
        *)
            echo ""
            echo "[!] ADB is required to run MiNator."
            install_adb_manual
            exit 0
            ;;
    esac
fi

# Run MiNator entirely in memory
echo "[*] Loading MiNator..."
echo ""
bash <(curl -fsSL "https://raw.githubusercontent.com/gpsn0w/MiNator/main/minator.sh") || {
    echo "[!] Download failed. Check your internet connection."
    exit 1
}
