import socket
import json
import time
import os
import sys
import select
import termios
import tty
import re
import urllib.request
import urllib.parse
import shutil

SOCKET_PATH = os.environ.get("PREFIX", "") + "/tmp/mpvsocket"

# Font Bitmap 6 Baris Seragam (ANSI Shadow)
SOLID_FONT = {
    'A': [
        " █████╗ ",
        "██╔══██╗",
        "███████║",
        "██╔══██║",
        "██║  ██║",
        "╚═╝  ╚═╝"
    ],
    'B': [
        "██████╗ ",
        "██╔══██╗",
        "██████╔╝",
        "██╔══██╗",
        "██████╔╝",
        "╚═════╝ "
    ],
    'C': [
        "  ██████╗",
        " ██╔════╝",
        " ██║     ",
        " ██║     ",
        " ╚██████╗",
        "  ╚═════╝"
    ],
    'D': [
        "██████╗ ",
        "██╔══██╗",
        "██║  ██║",
        "██║  ██║",
        "██████╔╝",
        "╚═════╝ "
    ],
    'E': [
        "███████╗",
        "██╔════╝",
        "█████╗  ",
        "██╔══╝  ",
        "███████╗",
        "╚══════╝"
    ],
    'F': [
        "███████╗",
        "██╔════╝",
        "█████╗  ",
        "██╔══╝  ",
        "██║     ",
        "╚═╝     "
    ],
    'G': [
        "  ██████╗",
        " ██╔════╝",
        " ██║  ███╗",
        " ██║   ██║",
        " ╚██████╔╝",
        "  ╚═════╝"
    ],
    'H': [
        "██╗  ██╗",
        "██║  ██║",
        "███████║",
        "██╔══██║",
        "██║  ██║",
        "╚═╝  ╚═╝"
    ],
    'I': [
        "██╗",
        "██║",
        "██║",
        "██║",
        "██║",
        "╚═╝"
    ],
    'J': [
        "     ██╗",
        "     ██║",
        "     ██║",
        "██   ██║",
        "╚█████╔╝",
        " ╚════╝ "
    ],
    'K': [
        "██╗  ██╗",
        "██║ ██╔╝",
        "█████╔╝ ",
        "██╔═██╗ ",
        "██║  ██╗",
        "╚═╝  ╚═╝"
    ],
    'L': [
        "██╗     ",
        "██║     ",
        "██║     ",
        "██║     ",
        "███████╗",
        "╚══════╝"
    ],
    'M': [
        "███╗   ███╗",
        "████╗ ████║",
        "██╔████╔██║",
        "██║╚██╔╝██║",
        "██║ ╚═╝ ██║",
        "╚═╝     ╚═╝"
    ],
    'N': [
        "███╗   ██╗",
        "████╗  ██║",
        "██╔██╗ ██║",
        "██║╚██╗██║",
        "██║ ╚████║",
        "╚═╝  ╚═══╝"
    ],
    'O': [
        " ██████╗ ",
        "██╔═══██╗",
        "██║   ██║",
        "██║   ██║",
        "╚██████╔╝",
        " ╚═════╝ "
    ],
    'P': [
        "██████╗ ",
        "██╔══██╗",
        "██████╔╝",
        "██╔═══╝ ",
        "██║     ",
        "╚═╝     "
    ],
    'Q': [
        " ██████╗ ",
        "██╔═══██╗",
        "██║   ██║",
        "██║▄▄ ██║",
        "╚██████╔╝",
        " ╚══▀▀═╝ "
    ],
    'R': [
        "██████╗ ",
        "██╔══██╗",
        "██████╔╝",
        "██╔══██╗",
        "██║  ██║",
        "╚═╝  ╚═╝"
    ],
    'S': [
        "███████╗",
        "██╔════╝",
        "███████╗",
        "╚════██║",
        "███████║",
        "╚══════╝"
    ],
    'T': [
        "████████╗",
        "╚══██╔══╝",
        "   ██║   ",
        "   ██║   ",
        "   ██║   ",
        "   ╚═╝   "
    ],
    'U': [
        "██╗   ██╗",
        "██║   ██║",
        "██║   ██║",
        "██║   ██║",
        "╚██████╔╝",
        " ╚═════╝ "
    ],
    'V': [
        "██╗   ██╗",
        "██║   ██║",
        "██║   ██║",
        "╚██╗ ██╔╝",
        " ╚████╔╝ ",
        "  ╚═══╝  "
    ],
    'W': [
        "██╗    ██╗",
        "██║    ██║",
        "██║ █╗ ██║",
        "██║███╗██║",
        "╚███╔███╔╝",
        " ╚══╝╚══╝ "
    ],
    'X': [
        "██╗  ██╗",
        "╚██╗██╔╝",
        " ╚███╔╝ ",
        " ██╔██╗ ",
        "██╔╝ ██╗",
        "╚═╝  ╚═╝"
    ],
    'Y': [
        "██╗   ██╗",
        "╚██╗ ██╔╝",
        " ╚████╔╝ ",
        "  ╚██╔╝  ",
        "   ██║   ",
        "   ╚═╝   "
    ],
    'Z': [
        "███████╗",
        "╚══███╔╝",
        "  ███╔╝ ",
        " ███╔╝  ",
        "███████╗",
        "╚══════╝"
    ],
    '0': [
        " ██████╗ ",
        "██╔═████╗",
        "██║██╔██║",
        "████╔╝██║",
        "╚██████╔╝",
        " ╚═════╝ "
    ],
    '1': [
        "  ██╗",
        " ███║",
        " ╚██║",
        "  ██║",
        "  ██║",
        "  ╚═╝"
    ],
    '2': [
        "██████╗ ",
        "╚════██╗",
        " █████╔╝",
        "██╔═══╝ ",
        "███████╗",
        "╚══════╝"
    ],
    '3': [
        "██████╗ ",
        "╚════██╗",
        " █████╔╝",
        " ╚═══██╗",
        "██████╔╝",
        "╚═════╝ "
    ],
    '4': [
        "██╗  ██╗",
        "██║  ██║",
        "███████║",
        "╚════██║",
        "     ██║",
        "     ╚═╝"
    ],
    '5': [
        "███████╗",
        "██╔════╝",
        "███████╗",
        "╚════██║",
        "███████║",
        "╚══════╝"
    ],
    '6': [
        " ██████╗ ",
        "██╔════╝ ",
        "███████╗ ",
        "██╔═══██╗",
        "╚██████╔╝",
        " ╚═════╝ "
    ],
    '7': [
        "███████╗",
        "╚════██║",
        "   ██╔╝ ",
        "  ██╔╝  ",
        "  ██║   ",
        "  ╚═╝   "
    ],
    '8': [
        " █████╗ ",
        "██╔══██╗",
        "╚█████╔╝",
        "██╔══██╗",
        "╚█████╔╝",
        " ╚════╝ "
    ],
    '9': [
        " █████╗ ",
        "██╔══██╗",
        "╚██████║",
        " ╚═══██║",
        " █████╔╝",
        " ╚════╝ "
    ],
    ' ': [
        "     ",
        "     ",
        "     ",
        "     ",
        "     ",
        "     "
    ],
    '!': [
        " ██╗",
        " ██║",
        " ██║",
        " ╚═╝",
        " ██╗",
        " ╚═╝"
    ],
    ':': [
        "    ",
        "██╗ ",
        "╚═╝ ",
        "██╗ ",
        "╚═╝ ",
        "    "
    ],
    '?': [
        " ██████╗ ",
        " ╚════██╗",
        "   ▄███╔╝",
        "   ▀▀══╝ ",
        "   ██╗   ",
        "   ╚═╝   "
    ],
    '-': [
        "        ",
        "        ",
        " █████╗ ",
        " ╚════╝ ",
        "        ",
        "        "
    ],
    "'": [
        " ▄█╗",
        " ╚═╝",
        "    ",
        "    ",
        "    ",
        "    "
    ],
    '.': [
        "    ",
        "    ",
        "    ",
        "    ",
        "██╗ ",
        "╚═╝ "
    ],
    ',': [
        "    ",
        "    ",
        "    ",
        "    ",
        "▄█╗ ",
        "╚═╝ "
    ]
}

def clear_screen():
    sys.stdout.write("\033[H\033[J")
    sys.stdout.flush()

def get_mpv_property(prop):
    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.connect(SOCKET_PATH)
        cmd = json.dumps({"command": ["get_property", prop]}) + "\n"
        client.sendall(cmd.encode())
        res = client.recv(4096).decode()
        client.close()
        data = json.loads(res)
        return data.get("data")
    except:
        return None

def clean_track_name(filename):
    if not filename:
        return ""
    name = os.path.splitext(filename)[0]
    name = re.sub(r'[\(\[\{].*?[\)\]\}]', '', name)
    name = name.replace("_", " ").replace("-", " ").strip()
    return name

def fetch_online_lrc(query_text):
    try:
        encoded_query = urllib.parse.quote(query_text)
        url = f"https://lrclib.net/api/search?q={encoded_query}"
        req = urllib.request.Request(url, headers={'User-Agent': 'TermuxMusicPlayer/1.0'})

        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode())
            if data and isinstance(data, list):
                for item in data:
                    if item.get("syncedLyrics"):
                        return item["syncedLyrics"]
    except:
        pass
    return None

def parse_lrc_text(lrc_text):
    lyrics = []
    for line in lrc_text.splitlines():
        match = re.match(r'\[(\d+):(\d+(?:\.\d+)?)\](.*)', line)
        if match:
            minutes = int(match.group(1))
            seconds = float(match.group(2))
            text = match.group(3).strip()
            timestamp = minutes * 60 + seconds
            if text:
                lyrics.append((timestamp, text))
    lyrics.sort(key=lambda x: x[0])
    return lyrics

def load_lyrics():
    media_path = get_mpv_property("path")
    title_meta = get_mpv_property("media-title")

    if media_path:
        lrc_path = os.path.splitext(media_path)[0] + ".lrc"
        if os.path.exists(lrc_path):
            with open(lrc_path, 'r', encoding='utf-8', errors='ignore') as f:
                return parse_lrc_text(f.read())

    search_query = title_meta if title_meta else clean_track_name(os.path.basename(media_path or ""))
    if search_query:
        online_lrc = fetch_online_lrc(search_query)
        if online_lrc:
            return parse_lrc_text(online_lrc)

    fallback_text = search_query if search_query else "MUSIC PLAYING"
    return [(0.0, fallback_text)]

def get_char_pattern(char):
    pattern = SOLID_FONT.get(char, SOLID_FONT.get(' ', ["     "] * 6))
    max_w = max(len(row) for row in pattern)
    # Pastikan setiap baris karakter memiliki panjang simetris
    return [row.ljust(max_w) for row in pattern]

def render_bitmap_solid(text):
    text_upper = text.upper().strip()
    if not text_upper:
        return ""

    term_cols = shutil.get_terminal_size((80, 24)).columns
    max_line_width = max(20, term_cols - 2)

    space_pattern = get_char_pattern(' ')
    space_width = len(space_pattern[0])

    words = text_upper.split()
    lines_of_chars = []
    current_line = []
    current_width = 0

    for word in words:
        word_chars = list(word)
        word_width = sum(len(get_char_pattern(c)[0]) for c in word_chars)
        needed_width = word_width + (space_width if current_line else 0)

        if current_line and (current_width + needed_width > max_line_width):
            lines_of_chars.append(current_line)
            current_line = []
            current_width = 0
            needed_width = word_width

        if word_width <= max_line_width:
            if current_line:
                current_line.append(' ')
                current_width += space_width
            current_line.extend(word_chars)
            current_width += word_width
        else:
            # Jika kata terlalu panjang untuk 1 baris, potong per karakter
            for c in word_chars:
                cw = len(get_char_pattern(c)[0])
                if current_line and (current_width + cw > max_line_width):
                    lines_of_chars.append(current_line)
                    current_line = []
                    current_width = 0
                current_line.append(c)
                current_width += cw

    if current_line:
        lines_of_chars.append(current_line)

    rendered_blocks = []
    for line_chars in lines_of_chars:
        lines_buffer = [""] * 6
        for char in line_chars:
            pattern = get_char_pattern(char)
            for i in range(6):
                lines_buffer[i] += pattern[i]
        rendered_blocks.append("\n".join(lines_buffer))

    return "\n\n".join(rendered_blocks)

def is_key_pressed():
    return select.select([sys.stdin], [], [], 0)[0] != []

def main():
    clear_screen()
    print("\033[1;37m[~] Mencari lirik otomatis untuk lagu yang sedang diputar...\033[0m")

    lyrics = load_lyrics()
    current_index = -1

    old_settings = termios.tcgetattr(sys.stdin)

    try:
        tty.setcbreak(sys.stdin.fileno())
        clear_screen()

        while True:
            if is_key_pressed():
                key = sys.stdin.read(1)
                if key.lower() in ['q', '\n', '\r', ' ']:
                    break

            pos = get_mpv_property("time-pos")
            if pos is None:
                time.sleep(0.2)
                continue

            active_text = ""
            active_idx = -1
            for idx, (ts, text) in enumerate(lyrics):
                if pos >= ts:
                    active_text = text
                    active_idx = idx
                else:
                    break

            if active_idx != current_index and active_text:
                current_index = active_idx
                clear_screen()

                ascii_banner = render_bitmap_solid(active_text)
                sys.stdout.write("\033[1;37m" + ascii_banner + "\033[0m\n")
                sys.stdout.flush()

            time.sleep(0.05)

    except KeyboardInterrupt:
        pass
    finally:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
        clear_screen()

if __name__ == "__main__":
    main()
