# MiNator v1.0 - Xiaomi Bloat Eliminator

```
 __  __ _ _   _       _            
|  \/  (_) \ | | __ _| |_ ___  _ __
| |\/| | |  \| |/ _` | __/ _ \| '__|
| |  | | | |\  | (_| | || (_) | |  
|_|  |_|_|_| \_|\__,_|\__\___/|_|  

    [ Xiaomi Bloat Eliminator ] v1.0
       Made by gpsn0w & Claude
          Keep Privacy First
```

**Tested on: Xiaomi 14 — HyperOS 3.0** ✓

---

## EN

> **Keep Privacy First**

MiNator removes pre-installed bloatware from Xiaomi/Redmi devices running MIUI or HyperOS.
No root required — uses ADB.

**What it removes:**
- Ads & Analytics (spyware that sends your data to Xiaomi)
- Facebook & LinkedIn (run in background without your consent)
- Mi Game Center (useless if you don't play Xiaomi games)
- Mi Browser *(PRIVACY NIGHTMARE! sends your entire browsing history to Xiaomi)*
- Mi Music & Video (ad-infested media players)
- GetApps / Mi Store (spam notifications)
- Safe system bloat (bug reports & user tracking sent to Xiaomi)
- Mi Cloud Backup *(optional, double confirmation — may affect Find My Device)*

**Features:**
- Supports MIUI and HyperOS
- Language selection: English / Bulgarian
- Shows what each package does before removing
- If a package is not found, tries alternative package names automatically
- If already removed — tells you with a smile :)
- Wireless ADB support (Android 11+)

---

## БГ

> **Keep Privacy First**

MiNator маха предварително инсталирания bloatware от Xiaomi/Redmi устройства с MIUI или HyperOS.
Не е нужен root — използва ADB.

**Какво маха:**
- Реклами & Аналитика (шпионски софтуер, праща данни към Xiaomi)
- Facebook & LinkedIn (работят на заден план без твое съгласие)
- Mi Game Center (безполезен ако не играеш Xiaomi игри)
- Mi Browser *(PRIVACY NIGHTMARE! праща цялата ти история към Xiaomi)*
- Mi Music & Video (медийни плейъри с вградени реклами)
- GetApps / Mi Store (spam нотификации)
- Безопасен системен bloat (bug репорти и проследяване към Xiaomi)
- Mi Cloud Backup *(по избор, двойно потвърждение — може да засегне Find My Device)*

**Функции:**
- Поддържа MIUI и HyperOS
- Избор на език: English / Български
- Показва какво прави всеки пакет преди да го маха
- Ако пакетът не е намерен — опитва алтернативно име автоматично
- Ако е вече махнат — казва с усмивка :)
- Поддръжка за Wireless ADB (Android 11+)

---

## How to use / Как да използваш

### Requirements / Изисквания
- ADB installed / ADB инсталиран
  - **Mac:** `brew install android-platform-tools`
  - **Ubuntu/Debian:** `sudo apt install adb`
  - **Fedora:** `sudo dnf install android-tools`
  - **Windows:** [Download Platform Tools](https://developer.android.com/tools/releases/platform-tools)

### One-line install / Инсталация с един ред

**Mac / Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/gpsn0w/MiNator/main/install.ps1 | iex
```

> Nothing is saved to disk. Automatically checks if ADB is installed — if not, offers to install it for you.

---

### Manual run / Ръчно стартиране

**Mac / Linux:**
```bash
chmod +x minator.sh
./minator.sh
```

**Windows:**
```
minator.bat
```

---

## Tested on / Тествано на

| Device | OS | Status |
|--------|----|--------|
| Xiaomi 14 | HyperOS 3.0 | ✅ Working |

*More devices coming as tested. Feel free to open an issue with your device results!*

---

Made by **gpsn0w** & **Claude** with dark humor and good intentions (:
