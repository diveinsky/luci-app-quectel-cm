#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "$BIN_DIR/diag_lib.sh"

NOT_SUPPORTED=0
HOSTAPD_CRASH=0
MISSING_RADIO=0
NO_PHY0=0

has_grep "$LOGREAD" "command failed: Not supported" && NOT_SUPPORTED=1
has_grep "$LOGREAD" "hostapd.*\(crash\|segfault\|panic\)" && HOSTAPD_CRASH=1
has_grep "$LOGREAD" "radio.*not found" && MISSING_RADIO=1
has_grep "$LOGREAD" "phy0.*no.*AP" && NO_PHY0=1

cat <<EOF
{
  "command_not_supported": $(json_bool "$NOT_SUPPORTED"),
  "hostapd_crash_detected": $(json_bool "$HOSTAPD_CRASH"),
  "missing_radio": $(json_bool "$MISSING_RADIO"),
  "no_phy0_ap0_link": $(json_bool "$NO_PHY0"),
  "log_matches": {
    "wifi_related": $(printf '%s' "$LOGREAD" | grep -i 'wifi\|radio\|phy0\|hostapd\|Not supported' | sed 's/"/\\"/g; s/$/,/' | awk '{print "\""$0"\""}' | paste -sd ',' -)
  }
}
EOF
