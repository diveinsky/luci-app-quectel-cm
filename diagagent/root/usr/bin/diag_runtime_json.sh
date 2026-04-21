#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "$BIN_DIR/diag_lib.sh"

OOM_KILLER=0
WATCHDOG_RESET=0
KERNEL_PANIC=0
FS_SYNC_ERROR=0
PROCESS_CRASH=0

has_grep "$DMESG" "Out of memory" && OOM_KILLER=1
has_grep "$DMESG" "watchdog: .*hard lockup\|watchdog:.*reboot" && WATCHDOG_RESET=1
has_grep "$DMESG" "kernel panic" && KERNEL_PANIC=1
has_grep "$LOGREAD" "fsync failed\|write error\|sync error" && FS_SYNC_ERROR=1
has_grep "$LOGREAD" "crash\|segfault\|Killed process" && PROCESS_CRASH=1

cat <<EOF
{
  "oom_killer_seen": $(json_bool "$OOM_KILLER"),
  "watchdog_reset": $(json_bool "$WATCHDOG_RESET"),
  "kernel_panic": $(json_bool "$KERNEL_PANIC"),
  "filesystem_sync_error": $(json_bool "$FS_SYNC_ERROR"),
  "process_crash_loop": $(json_bool "$PROCESS_CRASH")
}
EOF
