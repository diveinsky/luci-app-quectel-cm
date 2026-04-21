#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "$BIN_DIR/diag_lib.sh"

TS_CRNG="$(get_first_ts 'crng init done')"
TS_PROCD_INIT="$(get_first_ts 'procd: - init -')"
TS_NETIFD_START="$(get_first_ts 'netifd: ' )"
TS_WIFI_UP="$(printf '%s' "$DMESG" | grep -iE 'wifi.*up|phy.*up|AP-STA-CONNECTED|AP-STA-DISCONNECTED' | head -n1 | sed -n 's/.*\[\s*\([0-9.]*\)\].*/\1/p')"

BOOT_TO_PROCD=""
if [ -n "$TS_CRNG" ] && [ -n "$TS_PROCD_INIT" ]; then
    BOOT_TO_PROCD="$(awk "BEGIN {printf \"%.3f\", $TS_PROCD_INIT - $TS_CRNG}")"
fi

PROCD_TO_NETIFD=""
if [ -n "$TS_PROCD_INIT" ] && [ -n "$TS_NETIFD_START" ]; then
    PROCD_TO_NETIFD="$(awk "BEGIN {printf \"%.3f\", $TS_NETIFD_START - $TS_PROCD_INIT}")"
fi

NETIFD_TO_WIFI=""
if [ -n "$TS_NETIFD_START" ] && [ -n "$TS_WIFI_UP" ]; then
    NETIFD_TO_WIFI="$(awk "BEGIN {printf \"%.3f\", $TS_WIFI_UP - $TS_NETIFD_START}")"
fi

BOOT_STAGES="[]"
cat <<EOF
{
  "timestamps": {
    "crng_init_sec": $(safe_num "$TS_CRNG"),
    "procd_init_sec": $(safe_num "$TS_PROCD_INIT"),
    "netifd_start_sec": $(safe_num "$TS_NETIFD_START"),
    "wifi_up_sec": $(safe_num "$TS_WIFI_UP")
  },
  "delays": {
    "boot_to_procd_init_sec": $(safe_num "$BOOT_TO_PROCD"),
    "procd_init_to_netifd_sec": $(safe_num "$PROCD_TO_NETIFD"),
    "netifd_to_wifi_up_sec": $(safe_num "$NETIFD_TO_WIFI")
  }
}
EOF
