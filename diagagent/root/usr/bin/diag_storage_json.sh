#!/bin/sh

BIN_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "$BIN_DIR/diag_lib.sh"

ROOTFS_TYPE="$(mount 2>/dev/null | awk '$3=="/"{print $5; exit}')"
OVERLAY_LINE="$(mount 2>/dev/null | grep 'on /overlay ' || true)"
OVERLAY_FS_TYPE="$(printf '%s' "$OVERLAY_LINE" | awk '{print $5}')"
OVERLAY_SOURCE="$(printf '%s' "$OVERLAY_LINE" | awk '{print $1}')"
ROOT_RDONLY="$(mount 2>/dev/null | awk '$3=="/" && /ro/ { print "1"; exit }')"
EXTROOT="0"
[ -n "$OVERLAY_SOURCE" ] && echo "$OVERLAY_SOURCE" | grep -Eq '^/dev/|^/tmp/|^/mnt/' && EXTROOT="1"

OVERLAY_TOTAL_KB="$(df -k 2>/dev/null | awk '$6=="/overlay"{print $2; exit}')"
OVERLAY_USED_KB="$(df -k 2>/dev/null | awk '$6=="/overlay"{print $3; exit}')"
OVERLAY_AVAIL_KB="$(df -k 2>/dev/null | awk '$6=="/overlay"{print $4; exit}')"
OVERLAY_USE_PCT="$(df -k 2>/dev/null | awk '$6=="/overlay"{print $5; exit}' | tr -d '%')"

ROOTFS_DATA_SIZE_HEX="$(printf '%s' "$MTDINFO" | awk -F'[: ]+' '/"rootfs_data"/{print $3}')"
ROOTFS_DATA_SIZE_BYTES="$(hex_to_dec "$ROOTFS_DATA_SIZE_HEX")"

TMPFS_OVERLAY=0
JFFS2_NOT_READY=0
JFFS2_SCAN_COUNT="$(printf '%s' "$DMESG" | grep -ic 'jffs2_scan_eraseblock()')"

has_grep "$DMESG" "temporary tmpfs overlay" && TMPFS_OVERLAY=1
has_grep "$DMESG" "mount_root: jffs2 not ready yet" && JFFS2_NOT_READY=1

SMALL_ROOTFS_DATA="0"
if [ -n "$ROOTFS_DATA_SIZE_BYTES" ] && [ "$ROOTFS_DATA_SIZE_BYTES" -lt 2097152 ]; then
    SMALL_ROOTFS_DATA=1
fi

OVERLAY_FULL="0"
if [ -n "$OVERLAY_USE_PCT" ] && [ "$OVERLAY_USE_PCT" -ge 90 ]; then
    OVERLAY_FULL=1
fi

cat <<EOF
{
  "rootfs_type": "$(escape_json "$ROOTFS_TYPE")",
  "overlay_fs_type": "$(escape_json "$OVERLAY_FS_TYPE")",
  "overlay_source": "$(escape_json "$OVERLAY_SOURCE")",
  "overlay_usage_percent": $(safe_num "$OVERLAY_USE_PCT"),
  "overlay_total_kb": $(safe_num "$OVERLAY_TOTAL_KB"),
  "overlay_used_kb": $(safe_num "$OVERLAY_USED_KB"),
  "overlay_avail_kb": $(safe_num "$OVERLAY_AVAIL_KB"),
  "rootfs_data_size_bytes": $(safe_num "$ROOTFS_DATA_SIZE_BYTES"),
  "rootfs_read_only": $(json_bool "$ROOT_RDONLY"),
  "extroot_detected": $(json_bool "$EXTROOT"),
  "firstboot_like": $(json_bool "$TMPFS_OVERLAY"),
  "repeated_jffs2_scan": $(json_bool "$JFFS2_SCAN_COUNT"),
  "small_rootfs_data": $(json_bool "$SMALL_ROOTFS_DATA"),
  "overlay_full": $(json_bool "$OVERLAY_FULL")
}
EOF
