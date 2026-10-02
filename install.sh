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
                    echo "[!] Homebrew not found. Install it first:"
                    echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
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
            else
                echo "[!] Could not detect package manager."
                echo "    Install ADB manually: https://developer.android.com/tools/releases/platform-tools"
                exit 1
            fi
            echo ""
            echo "[+] ADB installed!"
            echo ""
            ;;
        *)
            echo ""
            echo "[!] ADB is required. Install it and run MiNator again."
            exit 1
            ;;
    esac
fi

# Download and run MiNator
echo "[*] Downloading MiNator..."
TMPFILE=$(mktemp /tmp/minator_XXXXXX.sh)
if curl -fsSL "https://raw.githubusercontent.com/gpsn0w/MiNator/main/minator.sh" -o "$TMPFILE"; then
    chmod +x "$TMPFILE"
    echo "[+] Done! Starting MiNator..."
    echo ""
    bash "$TMPFILE"
    rm -f "$TMPFILE"
else
    echo "[!] Download failed. Check your internet connection."
    rm -f "$TMPFILE"
    exit 1
fi
