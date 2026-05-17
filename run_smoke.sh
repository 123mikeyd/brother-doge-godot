#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GODOT="${GODOT:-$HOME/bin/godot45}"
mkdir -p proof_logs
"$GODOT" --headless --path . --script res://tools/smoke_brother_doge.gd 2>&1 | tee proof_logs/smoke_brother_doge.stdout.log
