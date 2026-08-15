#!/bin/bash

# ==========================================
# DEKLARASI WARNA (ANSI CODE)
# ==========================================
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
GRAY='\033[0;37m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

REPEAT_MODE="OFF"
SHOW_BANNER_MENU=0
EXIT_TIMER=0
choice=""
PLAYING_CODE=""

DIRS="/data/data/com.termux/files/home/SongPlayer/item/playlist"
BANNER_DIR="/data/data/com.termux/files/home/SongPlayer/item/banners"
CONFIG_BANNER="/data/data/com.termux/files/home/SongPlayer/item/.current_banner"
LYRICS_SCRIPT="$HOME/SongPlayer/item/lirik_ascii.py"

TMP_DIR="${PREFIX:-/data/data/com.termux/files/usr}/tmp"
mkdir -p "$TMP_DIR"
mkdir -p "$BANNER_DIR"
SOCKET="$TMP_DIR/mpvsocket"

get_code() {
    local index=$1
    local first_char_code=$(( (index / 26) + 65 ))
    local second_char_code=$(( (index % 26) + 65 ))
    printf "\\$(printf '%03o' $first_char_code)\\$(printf '%03o' $second_char_code)"
}

format_time() {
    local sec=$(echo "$1" | cut -d'.' -f1 | tr -cd '0-9')

    if [ -z "$sec" ]; then
        echo "00:00"
        return
    fi

    sec=$((10#$sec))
    printf "%02d:%02d" $((sec/60)) $((sec%60))
}

print_default_banner() {
    cat << "EOF"
             ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⡆⢰⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
             ⠀⠀⠀⠀⠀⢸⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣾⣿⣿⡇⢸⣿⣿⣷⣦⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⡇⠀⠀⠀⠀⠀
             ⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⢰⣿⣿⡇⠀⢠⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⣿⠿⣿⣿⣷⠀⣿⣶⣶⠀⣴⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀
             ⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⣾⣿⣿⠁⢀⣿⠟⠉⠀⠀⠉⠻⣿⡇⢸⣿⣿⡇⠀⢸⣿⣿⠀⢻⣿⣿⠀⣿⣿⣿⠛⢿⣿⡇⠀⠀⠀⠀⠀
             ⠀⠀⠀⠀⠀ ⣿⣿⣿⣧⣸⣿⣿⣿⠀⢸⡏⠀⠀⠀⠀⠀⠀⢹⡇⠀⣿⣿⣇⠀⠘⢿⣿⠀⢸⣿⣿⠀⢸⣿⣿⠀⢸⣿⣇⠀⠀⠀⠀⠀
             ⠀⠀⢠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢸⠁⠀⠀⠀⠀⠀⠀⢸⡇⠀⠻⣿⣿⣷⣄⡀⠈⠀⢸⣿⣿⡄⢸⣿⣿⠀⠸⣿⣿⣷⣄⠀⠀
             ⠀⠀⠀⠉⢻⣿⣿⡿⣿⣿⡿⣿⣿⡟⠀⣸⢸⣿⠀⠀⠀⢠⣿⣾⣇⠀⡀⠈⠻⢿⣿⣿⣦⡀⢸⣿⣿⡇⢸⣿⣿⡄⠀⠈⠻⠿⠋⠀⠀⠀
             ⠀⠀⠀⠀⢸⣿⣿⡇⢻⣿⠁⣿⣿⡇⢸⣿⢸⣿⠀⠀⠀⢸⣿⣿⣿⡇⣿⣦⡀⠀⢹⣿⣿⡇⢸⣿⣿⡇⠀⣿⣿⡇⠀⠀⢀⡄⠀⠀⠀⠀
             ⠀⠀⠀⠀⣿⣿⣿⠃⢸⠇⢰⣿⣿⡇⢸⣿⢸⣿⠀⠀⠀⢸⣿⣿⣿⡇⣿⣿⣿⠀⢸⣿⣿⡇⠀⣿⣿⣇⠀⣿⣿⡇⠀⢰⣿⣷⠀⠀⠀⠀
             ⠀⠀⠀⣸⣿⣿⣿⠀⠀⠀⢸⣿⣿⡇⠸⣿⢸⣿⠀⠀⠀⢸⣿⣿⣿⠃⣿⣿⣿⠀⢸⣿⣿⡇⠀⣿⣿⣿⠀⢿⣿⣿⣤⣼⣿⣿⣇⠀⠀⠀
             ⠀⠀⢰⣿⣿⣿⣿⠀⠀⠀⠾⢿⣿⡇⠀⠀⣾⣿⣷⣤⣤⣾⣿⣷⠀⠀⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⠿⠿⠂⠈⠻⠿⠿⢿⣿⣿⣿⡄⠀⠀
             ⠀⢠⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣿⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠻⢿⡄⠀
             ⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⠀⠀⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀
             ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⠀⢰⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
             ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
}

show_live_timer() {
    echo
    echo -e "${RED}[${WHITE}!${RED}]${NC}${BOLD} KONTROL: [P] Pause | [N] Next | [L] Lirik ASCII | [Enter/Q] Menu"
    echo

    local first_run=1

    while pgrep -x "mpv" > /dev/null; do
        pos_raw=$(echo '{ "command": ["get_property", "time-pos"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null)
        dur_raw=$(echo '{ "command": ["get_property", "duration"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null)
        pause_raw=$(echo '{ "command": ["get_property", "pause"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null)

        fmt_pos=$(format_time "$pos_raw")
        fmt_dur=$(format_time "$dur_raw")

        status_icon="▶"
        if [ "$pause_raw" == "true" ]; then
            status_icon="𓏻"
        fi

        if read -rs -n 1 -t 1 key; then
            case "$key" in
                p|P)
                    echo '{ "command": ["cycle", "pause"] }' | socat - "$SOCKET" 2>/dev/null > /dev/null
                    ;;
                l|L)
                    clear
                    if [ -f "$LYRICS_SCRIPT" ]; then
                        python3 "$LYRICS_SCRIPT"
                    elif [ -f "./item/lyrics_ascii.py" ]; then
                        python3 "./item/lyrics_ascii.py"
                    elif [ -f "./item/lirik_ascii.py" ]; then
                        python3 "./item/lirik_ascii.py"
                    fi
                    if [ -n "$PLAYING_CODE" ]; then
                        choice="$PLAYING_CODE"
                    fi
                    return 0
                    ;;
                n|N)
                    cur_pos=$(echo '{ "command": ["get_property", "playlist-pos"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null | tr -cd '0-9')
                    total_count=$(echo '{ "command": ["get_property", "playlist-count"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null | tr -cd '0-9')

                    if [ -n "$cur_pos" ] && [ -n "$total_count" ]; then
                        if [ $((cur_pos + 1)) -ge "$total_count" ]; then
                            echo '{ "command": ["set_property", "playlist-pos", 0] }' | socat - "$SOCKET" 2>/dev/null > /dev/null
                        else
                            echo '{ "command": ["playlist-next"] }' | socat - "$SOCKET" 2>/dev/null > /dev/null
                        fi
                    fi
                    sleep 0.2
                    ;;
                q|Q|"")
                    EXIT_TIMER=1
                    return 0
                    ;;
            esac
        fi

        current_file=$(echo '{ "command": ["get_property", "filename"] }' | socat - "$SOCKET" 2>/dev/null | jq -r '.data' 2>/dev/null)
        if [ -n "$current_file" ] && [ "$current_file" != "null" ]; then
            current_media="${current_file%.*}"
        else
            current_media="Memuat..."
        fi

        term_width=$(tput cols 2>/dev/null || echo 80)
        max_media_len=$((term_width - 15))
        if [ $max_media_len -lt 30 ]; then max_media_len=30; fi

        if [ ${#current_media} -gt $max_media_len ]; then
            current_media="${current_media:0:$((max_media_len - 3))}..."
        fi

        if [ $first_run -eq 0 ]; then
            echo -ne "\033[3A"
        else
            first_run=0
        fi

        echo -e "\033[K${RED}[${NC}${BOLD}+${NC}${RED}]${NC} ${BOLD}Memutar : ${current_media}${NC}"
        echo -e "\033[K"
        echo -e "\033[K${RED}[${NC}${BOLD}${status_icon}${NC}${RED}]${NC} ${BOLD}Waktu:${NC} [ ${GREEN}${fmt_pos}${NC} / ${CYAN}${fmt_dur}${NC} ]"
    done
    echo ""
}

while true; do
    clear

    echo -e "${WHITE}${BOLD}Script By ASixHaxor${NC}"
    echo -e "${WHITE}${BOLD}ib display:@Byexe${NC}"
    echo -e "${DG}${BOLD}"

    if [ -f "$CONFIG_BANNER" ] && [ -s "$CONFIG_BANNER" ]; then
        target_banner_file=$(cat "$CONFIG_BANNER")
        if [ -f "$target_banner_file" ]; then
            cat "$target_banner_file"
        else
            print_default_banner
        fi
    else
        print_default_banner
    fi
    echo -e "${NC}"

    mapfile -t PLAYLIST < <(find "$DIRS" -maxdepth 1 \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.wav" -o -name "*.ogg" \) 2>/dev/null)

    PANJANG_GARIS_KIRI_ATAS=30
    PANJANG_GARIS_KANAN_ATAS=30
    PANJANG_GARIS_BAWAH=75

    line_top_left=$(printf '─%.0s' $(seq 1 $PANJANG_GARIS_KIRI_ATAS))
    line_top_right=$(printf '─%.0s' $(seq 1 $PANJANG_GARIS_KANAN_ATAS))
    line_bottom=$(printf '─%.0s' $(seq 1 $PANJANG_GARIS_BAWAH))

    BOX_WIDTH=$(( PANJANG_GARIS_KIRI_ATAS + PANJANG_GARIS_KANAN_ATAS + 11 ))

    echo -e "╭$line_top_left ${RED}[${NC} ${BOLD}M U S I C ${NC}${RED}]${NC} $line_top_right╮"

    if [ ${#PLAYLIST[@]} -eq 0 ]; then
        msg="                   [!] Tidak ada file musik di Download. "
        pad_len=$((BOX_WIDTH - ${#msg}))
        padding=""
        if [ $pad_len -gt 0 ]; then padding=$(printf '%*s' "$pad_len" ""); fi

        echo -e "│${YELLOW}$msg${NC}$padding    │"
    else
        for i in "${!PLAYLIST[@]}"; do
            code=$(get_code $i)
            filename=$(basename "${PLAYLIST[$i]}")
            title="${filename%.*}"

            max_title_len=$((BOX_WIDTH - 8))
            if [ ${#title} -gt $max_title_len ]; then
                title="${title:0:$((max_title_len - 3))}..."
            fi

            visible_text=" [$code] $title"
            pad_len=$((BOX_WIDTH - ${#visible_text}))
            padding=""
            if [ $pad_len -gt 0 ]; then padding=$(printf '%*s' "$pad_len" ""); fi

            echo -e "│ ${WHITE}[${NC}${GREEN}${BOLD}$code${NC}${WHITE}]${NC} ${BOLD}$title${NC}$padding    │"
        done
    fi

    echo -e "╰$line_bottom╯"
    echo ""

    echo -e "${GRAY}╭──────────────────────────────╮${NC}"
    echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}01${NC}${WHITE}]${NC} ${BOLD}Hentikan music${NC}          │${NC}"

    if [ "$REPEAT_MODE" == "ON" ]; then
        echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}02${NC}${WHITE}]${NC} ${BOLD}Repeat Song [ ${GREEN}${BOLD}ON${NC}${BOLD} ]${NC}      │${NC}"
    else
        echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}02${NC}${WHITE}]${NC} ${BOLD}Repeat Song [ ${RED}${BOLD}OFF${NC}${BOLD} ]${NC}     │${NC}"
    fi

    echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}03${NC}${WHITE}]${NC} ${BOLD}Play Acak${NC}               │${NC}"
    echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}04${NC}${WHITE}]${NC} ${BOLD}Ganti banner${NC}            │${NC}"
    echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}05${NC}${WHITE}]${NC} ${BOLD}Lirik ASCII${NC}             │${NC}"
    echo -e "${GRAY}│ ${NC}${WHITE}[${NC}${GREEN}${BOLD}00${NC}${WHITE}]${NC} ${BOLD}Keluar dari script      ${GRAY}│${NC}"

    if [ "$SHOW_BANNER_MENU" -eq 1 ]; then
        echo -e "${GRAY}╰─ ╭─ ${RED}[${NC} ${BOLD}P I L I H${NC} ${RED}]${NC} ───────────╯${NC}"
        echo -e "${GRAY}   ╰─╼${GREEN}>${NC}${BOLD} $choice "
        echo ""

        mapfile -t BANNERS < <(find "$BANNER_DIR" -maxdepth 1 -name "*.txt" 2>/dev/null | sort)

        BANNER_INNER_WIDTH=47
        blank_line=$(printf '%*s' "$BANNER_INNER_WIDTH" "")

        echo -e "${GRAY}╭───────────────── ${RED}[${NC}${BOLD} M E N U ${NC}${RED}]${NC} ─────────────────╮${NC}"

        if [ ${#BANNERS[@]} -eq 0 ]; then
            echo -e "${GRAY}│${blank_line}│${NC}"
            empty_text=" [!] Tidak ada banner"
            pad_len=$((BANNER_INNER_WIDTH - ${#empty_text}))
            [ $pad_len -lt 0 ] && pad_len=0
            padding=$(printf '%*s' "$pad_len" "")
            echo -e "${GRAY}│${NC}${YELLOW}${empty_text}${NC}${padding}${GRAY}│${NC}"
            echo -e "${GRAY}│${blank_line}│${NC}"

            item_text=" [00] Kembali ke menu"
            pad_len=$((BANNER_INNER_WIDTH - ${#item_text}))
            [ $pad_len -lt 0 ] && pad_len=0
            padding=$(printf '%*s' "$pad_len" "")
            echo -e "${GRAY}│${NC} ${WHITE}[${NC}${GREEN}${BOLD}00${NC}${WHITE}]${NC} ${BOLD}Kembali ke menu${NC}${padding}${GRAY}│${NC}"
            echo -e "${GRAY}│${blank_line}│${NC}"
        else
            echo -e "${GRAY}│${blank_line}│${NC}"
            for b_idx in "${!BANNERS[@]}"; do
                b_num=$((b_idx + 1))
                b_num_fmt=$(printf "%02d" $b_num)
                b_filename=$(basename "${BANNERS[$b_idx]}")
                b_name="${b_filename%.*}"

                b_name=$(echo "$b_name" | sed 's/ㅤ/ /g' | tr -s ' ')

                display_name="Banner $b_name"
                max_display_len=$((BANNER_INNER_WIDTH - 9))
                if [ ${#display_name} -gt $max_display_len ]; then
                    display_name="${display_name:0:$((max_display_len - 3))}..."
                fi

                visible_text=" [$b_num_fmt] $display_name"
                pad_len=$((BANNER_INNER_WIDTH - ${#visible_text}))
                [ $pad_len -lt 0 ] && pad_len=0
                padding=$(printf '%*s' "$pad_len" "")

                echo -e "${GRAY}│${NC} ${WHITE}[${NC}${GREEN}${BOLD}$b_num_fmt${NC}${WHITE}]${NC} ${BOLD}$display_name${NC}${padding}${GRAY}│${NC}"
            done

            item_text=" [00] Kembali ke menu"
            pad_len=$((BANNER_INNER_WIDTH - ${#item_text}))
            [ $pad_len -lt 0 ] && pad_len=0
            padding=$(printf '%*s' "$pad_len" "")
            echo -e "${GRAY}│${NC} ${WHITE}[${NC}${GREEN}${BOLD}00${NC}${WHITE}]${NC} ${BOLD}Kembali ke menu${NC}${padding}${GRAY}│${NC}"
            echo -e "${GRAY}│${blank_line}│${NC}"
        fi

        echo -e "${GRAY}╰── ╭─ ${RED}[${NC} ${BOLD}P I L I H${NC} ${RED}]${NC} ───────────────────────────╯${NC}"

        echo -ne "${GRAY}    ╰─╼${GREEN}>${NC}${BOLD} "
        read b_choice

        b_choice=$(echo "$b_choice" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')

        if [ "$b_choice" == "00" ] || [ "$b_choice" == "0" ]; then
            SHOW_BANNER_MENU=0
        else
            if [[ "$b_choice" =~ ^[0-9]+$ ]]; then
                b_num_sel=$((10#$b_choice))
            else
                b_num_sel=-1
            fi

            if [ $b_num_sel -ge 1 ] && [ $b_num_sel -le ${#BANNERS[@]} ]; then
                selected_banner_path="${BANNERS[$((b_num_sel - 1))]}"
                echo "$selected_banner_path" > "$CONFIG_BANNER"
                echo -e "\n${WHITE}[${NC}${BOLD}${GREEN}✓${NC}${WHITE}]${NC} Banner berhasil diganti!"
                SHOW_BANNER_MENU=0
                sleep 1
            else
                echo -e "\n${RED}[!] Pilihan tidak valid!${NC}"
                sleep 1
            fi
        fi

    else
        echo -e "${GRAY}╰─ ╭─ ${RED}[${NC} ${BOLD}P I L I H${NC} ${RED}]${NC} ───────────╯${NC}"

        if pgrep -x "mpv" > /dev/null && [ "$EXIT_TIMER" -eq 0 ]; then
            echo -e "${BOLD}${GRAY}   ╰─╼${GREEN}>${NC} ${BOLD}${choice}${NC}"
            show_live_timer
        else
            echo -ne "${GRAY}   ╰─╼${GREEN}> ${NC}${BOLD}"
            read user_input

            raw_choice=$(echo "$user_input" | tr -d '[:space:]')
            clean_choice=$(echo "$user_input" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')

            case $clean_choice in
               01|1)
                    choice="$raw_choice"
                    PLAYING_CODE=""
                    if pgrep -x "mpv" > /dev/null; then
                        pkill mpv
                        rm -f "$SOCKET"
                        echo -e "\n${RED}[${NC}${WHITE}-${NC}${RED}]${NC} Musik telah dihentikan.${NC}"
                    else
                        echo -e "\n${RED}[${NC}${WHITE}!${RED}]${NC} Tidak ada musik yang sedang diputar.${NC}"
                    fi
                    read -p "Tekan Enter untuk kembali..."
                    ;;
               02|2)
                    choice="$raw_choice"
                    if [ "$REPEAT_MODE" == "OFF" ]; then
                        REPEAT_MODE="ON"
                        echo -e "\n${RED}[${NC}${BOLD}+${NC}${RED}]${NC} Mode Repeat Song ${GREEN}${BOLD}DIAKTIFKAN.${NC}"
                        if pgrep -x "mpv" > /dev/null; then
                            echo '{ "command": ["set_property", "loop-file", "inf"] }' | socat - "$SOCKET" 2>/dev/null > /dev/null
                        fi
                    else
                        REPEAT_MODE="OFF"
                        echo -e "\n${RED}[${NC}${BOLD}-${NC}${RED}]${NC} Mode Repeat Song ${RED}${BOLD}DIMATIKAN${NC}"
                        if pgrep -x "mpv" > /dev/null; then
                            echo '{ "command": ["set_property", "loop-file", "no"] }' | socat - "$SOCKET" 2>/dev/null > /dev/null
                        fi
                    fi
                    sleep 1
                    ;;
               03|3)
                    choice="$raw_choice"
                    PLAYING_CODE="$raw_choice"
                    if [ ${#PLAYLIST[@]} -eq 0 ]; then
                        echo -e "\n${RED}[!] Tidak ada musik untuk diputar secara acak!${NC}"
                        sleep 1
                    else
                        pkill mpv 2>/dev/null
                        rm -f "$SOCKET"

                        if [ "$REPEAT_MODE" == "ON" ]; then
                            mpv --no-video --input-ipc-server="$SOCKET" --shuffle --loop-file=inf "${PLAYLIST[@]}" > /dev/null 2>&1 &
                        else
                            mpv --no-video --input-ipc-server="$SOCKET" --shuffle "${PLAYLIST[@]}" > /dev/null 2>&1 &
                        fi

                        EXIT_TIMER=0
                        show_live_timer
                    fi
                    ;;
               04|4)
                    choice="$raw_choice"
                    SHOW_BANNER_MENU=1
                    ;;
               05|5)
                    choice="$raw_choice"
                    if pgrep -x "mpv" > /dev/null; then
                        clear
                        if [ -f "$LYRICS_SCRIPT" ]; then
                            python3 "$LYRICS_SCRIPT"
                        elif [ -f "./item/lyrics_ascii.py" ]; then
                            python3 "./item/lyrics_ascii.py"
                        elif [ -f "./item/lirik_ascii.py" ]; then
                            python3 "./item/lirik_ascii.py"
                        else
                            echo -e "\n${RED}[!] File lyrics_ascii.py tidak ditemukan!${NC}"
                            sleep 1.5
                        fi
                        if [ -n "$PLAYING_CODE" ]; then
                            choice="$PLAYING_CODE"
                        fi
                    else
                        echo -e "\n${RED}[${NC}${WHITE}!${RED}]${NC} Tidak ada musik yang sedang diputar.${NC}"
                        sleep 1.5
                    fi
                    ;;
                00|0)
                    pkill mpv 2>/dev/null
                    rm -f "$SOCKET"
                    exit 0
                    ;;
                *)
                    found=0
                    for i in "${!PLAYLIST[@]}"; do
                        code=$(get_code $i)
                        if [ "$clean_choice" == "$code" ]; then
                            pkill mpv 2>/dev/null
                            rm -f "$SOCKET"

                            final_playlist=()
                            for j in "${!PLAYLIST[@]}"; do
                                idx=$(( (i + j) % ${#PLAYLIST[@]} ))
                                final_playlist+=("${PLAYLIST[$idx]}")
                            done

                            if [ "$REPEAT_MODE" == "ON" ]; then
                                mpv --no-video --input-ipc-server="$SOCKET" --loop-file=inf "${final_playlist[@]}" > /dev/null 2>&1 &
                            else
                                mpv --no-video --input-ipc-server="$SOCKET" "${final_playlist[@]}" > /dev/null 2>&1 &
                            fi

                            found=1
                            PLAYING_CODE="$raw_choice"
                            choice="$raw_choice"
                            EXIT_TIMER=0
                            show_live_timer
                            break
                        fi
                    done

                    if [ $found -eq 0 ]; then
                        echo -e "\n${RED}[!] Pilihan '$raw_choice' tidak valid!${NC}"
                        sleep 1
                    fi
                    ;;
            esac
        fi
    fi
done
