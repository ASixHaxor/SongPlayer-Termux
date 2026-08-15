#!/bin/bash

# Warna Terminal
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
LIGHT_MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
DG='\033[1;30m'
GRAY='\033[1;30m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${GRAY}╭──────────────────────────────────────────╮${NC}"
echo -e "${GRAY}│${NC}${BOLD}  SETUP DEPENDENCIES MUSIC PLAYER TERMUX  ${NC}${GRAY}│"
echo -e "${GRAY}╰──────────────────────────────────────────╯${NC}\n"

# 1. Update & Upgrade Paket
echo -e "${WHITE}[${NC}${GREEN}${BOLD}1/3${NC}${WHITE}]${NC} ${GRAY}Memperbarui repository Termux...${NC}"
pkg update -y && pkg upgrade -y

# 2. Install Package Pendukung
echo -e "\n${WHITE}[${NC}${GREEN}${BOLD}2/3${NC}${WHITE}]${NC} ${GRAY}Menginstall mpv, socat, jq, dan utilitas sistem...${NC}"
pkg install python mpv jq socat procps findutils ncurses-utils -y

# 4. Minta Izin Penyimpanan Termux
echo -e "\n${WHITE}[${NC}${GREEN}${BOLD}3/3${NC}${WHITE}]${NC} ${GRAY}Menyiapkan izin penyimpanan...${NC}"
termux-setup-storage

echo -e "\n${GRAY}╭──────────────────────────────────────────╮${NC}"
echo -e "${GRAY}│${NC}     ${GREEN}${BOLD} ✓${NC}${BOLD} SETUP BERHASIL DAN SELESAI ${RED}!${NC}      ${NC}${GRAY}│"
echo -e "${GRAY}╰──────────────────────────────────────────╯${NC}\n"

echo -e "${CYAN}Langkah selanjutnya:${NC}"
echo -e "${BOLD}1. Masukkan file lagu (.mp3 / .flac / .m4a) ke dalam folder:"
echo -e "   ${GREEN}${BOLD}~/SongPlayer-Termux/item/playlist/${NC}"
echo -e "${BOLD}2. Jika tidak mengerti cara memasukan music,bisa melihat video berikut"
echo -e "${BOLD}LINK${GRAY}${BOLD} : ${NC}${GREEN}${BOLD}https://c.top4top.io/m_3878fd2qg0.mp4"
