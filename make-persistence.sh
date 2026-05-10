#!/bin/bash
# AICODE-OS Ventoy persistence dat 자동 생성 (Linux / WSL / macOS)
# Usage: bash make-persistence.sh [SIZE_MB]   default: 3500 (3.5 GB)
set -e

SIZE_MB="${1:-3500}"
OUT="${OUT:-cco-persistence.dat}"

[ "$(id -u)" = "0" ] || { echo "ERROR: must run as root (sudo bash make-persistence.sh)"; exit 1; }
command -v mkfs.ext4 >/dev/null || { echo "ERROR: mkfs.ext4 not found (apt install e2fsprogs)"; exit 1; }

echo "Creating $OUT (${SIZE_MB} MB ext4 label=casper-rw)..."
dd if=/dev/zero of="$OUT" bs=1M count="$SIZE_MB" status=progress
mkfs.ext4 -F -L casper-rw "$OUT"

echo
ls -lh "$OUT"
echo
echo "Done. Copy $OUT to your Ventoy USB root:"
echo "  cp $OUT /run/media/\$USER/Ventoy/        # Linux"
echo "  cp $OUT /Volumes/Ventoy/                 # macOS"
echo "  copy $OUT F:\\                           # Windows (USB drive letter)"
