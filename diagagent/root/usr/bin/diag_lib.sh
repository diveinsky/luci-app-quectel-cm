#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

DMESG="$(dmesg 2>/dev/null)"
LOGREAD="$(logread 2>/dev/null)"
MTDINFO="$(cat /proc/mtd 2>/dev/null)"
BOARD_JSON="$(ubus call system board 2>/dev/null)"
DATE_NOW="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"

escape_json() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

json_bool() {
    [ "$1" = "1" ] && printf 'true' || printf 'false'
}

safe_num() {
    [ -n "$1" ] && printf '%s' "$1" || printf 'null'
}

get_first_ts() {
    printf '%s' "$DMESG" | grep -m1 -i "$1" | sed -n 's/.*\[\s*\([0-9.]*\)\].*/\1/p'
}

get_last_ts() {
    printf '%s' "$DMESG" | grep -i "$1" | tail -n1 | sed -n 's/.*\[\s*\([0-9.]*\)\].*/\1/p'
}

count_grep() {
    printf '%s' "$1" | grep -ic "$2" 2>/dev/null
}

has_grep() {
    printf '%s' "$1" | grep -iq "$2" 2>/dev/null
}

hex_to_dec() {
    [ -n "$1" ] && printf "%d" "0x$1" 2>/dev/null || printf ''
}
