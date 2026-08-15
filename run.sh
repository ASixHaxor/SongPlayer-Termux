#!/bin/bash

# ==========================================
# KONFIGURASI NAMA FILE UTAMA & DIREKTORI
# ==========================================
ITEM_DIR="$HOME/SongPlayer/item"
PLAYLIST_DIR="$ITEM_DIR/playlist"

# Cari file play.sh di dalam direktori item
MAIN_SCRIPT=""
if [ -f "./item/play.sh" ]; then
    MAIN_SCRIPT="./item/play.sh"
elif [ -f "$ITEM_DIR/play.sh" ]; then
    MAIN_SCRIPT="$ITEM_DIR/play.sh"
else
    # Jika tidak ditemukan di jalur standar, lakukan pencarian dengan find
    MAIN_SCRIPT=$(find ./item "$ITEM_DIR" -name "play.sh" 2>/dev/null | head -n 1)
fi

# Warna
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 1. Cek Paket Pendukung
NEED_SETUP=0
for pkg in mpv socat jq; do
    if ! command -v $pkg &> /dev/null; then
        NEED_SETUP=1
        break
    fi
done

# Jika ada paket yang belum terinstall, jalankan setup.sh otomatis
if [ $NEED_SETUP -eq 1 ]; then
    echo -e "${YELLOW}[!] Beberapa paket belum terinstall. Menjalankan setup otomatis...${NC}"
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    elif [ -f "./item/setup.sh" ]; then
        chmod +x ./item/setup.sh
        ./item/setup.sh
    else
        echo -e "${RED}[!] File setup.sh tidak ditemukan! Menginstall paket secara langsung...${NC}"
        pkg update -y && pkg install -y mpv socat jq findutils coreutils procps
    fi
fi

# 2. Pastikan Folder Playlist Terbuat
if [ ! -d "$PLAYLIST_DIR" ]; then
    mkdir -p "$PLAYLIST_DIR"
fi

# 3. Pastikan Socket Directory Siap
mkdir -p "$PREFIX/tmp"

# 4. Cek Keberadaan Script Utama
if [ -z "$MAIN_SCRIPT" ] || [ ! -f "$MAIN_SCRIPT" ]; then
    echo -e "\n${RED}[!] File 'play.sh' tidak ditemukan di dalam direktori item!${NC}"
    echo -e "${CYAN}Pastikan file 'play.sh' berada di dalam folder 'item' (misal: ./item/play.sh atau $ITEM_DIR/play.sh)${NC}\n"
    exit 1
fi

# 5. Berikan Izin Eksekusi & Jalankan
chmod +x "$MAIN_SCRIPT"
clear
echo -e "${GREEN}[+] Memulai Music Player${NC}"
sleep 1
"$MAIN_SCRIPT"
