#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
exec "$SCRIPT_DIR/diagagent" --all
