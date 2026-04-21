#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "$BIN_DIR/diag_lib.sh"

BRLAN_EVENTS="$(printf '%s' "$DMESG" | grep -i 'br-lan: port .* entered ' 2>/dev/null)"
BRLAN_COUNT="$(printf '%s' "$BRLAN_EVENTS" | wc -l | tr -d ' ')"
REPEATED_INTERFACES=0
[ "${BRLAN_COUNT:-0}" -ge 4 ] && REPEATED_INTERFACES=1

DHCP_FAILED=0
printf '%s' "$LOGREAD" | grep -iq 'dhcp.*no lease\|DHCPREQUEST\|DHCPOFFER' && DHCP_FAILED=1

UBUS_DENIED=0
has_grep "$LOGREAD" "Permission denied" && UBUS_DENIED=1

SERVICE_RESTARTS="$(printf '%s' "$LOGREAD" | grep -ic 'restart.*network\|network.*restart\|netifd.*restart')"

cat <<EOF
{
  "repeated_interface_flaps": $(json_bool "$REPEATED_INTERFACES"),
  "dhcp_issues": $(json_bool "$DHCP_FAILED"),
  "ubus_permission_denied": $(json_bool "$UBUS_DENIED"),
  "service_restart_count": $(safe_num "$SERVICE_RESTARTS")
}
EOF
