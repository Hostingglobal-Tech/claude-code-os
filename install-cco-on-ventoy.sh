#!/bin/bash
# AICODE-OS Ventoy USB installer for Linux/macOS.
#
# Usage:
#   ./install-cco-on-ventoy.sh                 # auto-detect Ventoy mount point
#   ./install-cco-on-ventoy.sh /mnt/usb        # explicit mount point
#   ./install-cco-on-ventoy.sh /mnt/usb v2.0.5 # explicit release tag
set -euo pipefail

USB_PATH="${1:-}"
VERSION="${2:-latest}"
REPO="Hostingglobal-Tech/claude-code-os"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: '$1' command not found."
    exit 1
  }
}

download_if_missing() {
  local url="$1"
  local out="$2"
  if [ -f "$out" ]; then
    echo "Already exists: $(basename "$out")"
    return 0
  fi
  echo "Downloading: $(basename "$out")"
  curl -fL --retry 3 --retry-delay 2 -o "$out" "$url"
}

need_cmd curl

# 1. Ventoy USB mount point
if [ -z "$USB_PATH" ]; then
  if command -v lsblk >/dev/null 2>&1; then
    USB_PATH="$(lsblk -no MOUNTPOINT,LABEL | awk '$2 ~ /^[Vv]entoy$/ && $1 != "" {print $1; exit}')"
  fi
  if [ -z "$USB_PATH" ] && [ -d /Volumes/Ventoy ]; then
    USB_PATH=/Volumes/Ventoy
  fi
  if [ -z "$USB_PATH" ]; then
    echo "ERROR: Ventoy USB mount point not found."
    echo "Run with an explicit mount point, for example: $0 /mnt/usb"
    exit 1
  fi
  echo "Ventoy USB: $USB_PATH"
fi

[ -d "$USB_PATH" ] || { echo "ERROR: $USB_PATH is not a directory"; exit 1; }

# 2. Resolve release tag
if [ "$VERSION" = "latest" ]; then
  echo "Resolving latest release..."
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" |
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -1)"
  [ -n "$VERSION" ] || { echo "ERROR: failed to resolve latest release"; exit 1; }
fi
echo "Release: $VERSION"

BASE="https://github.com/${REPO}/releases/download/${VERSION}"
ISO="aicode-os-${VERSION}.iso"
PART1="${ISO}.part1"
PART2="${ISO}.part2"
SHA256="${ISO}.sha256"

# 3. Download and merge split ISO
download_if_missing "$BASE/$PART1" "$USB_PATH/$PART1"
download_if_missing "$BASE/$PART2" "$USB_PATH/$PART2"
download_if_missing "$BASE/$SHA256" "$USB_PATH/$SHA256"

if [ ! -f "$USB_PATH/$ISO" ]; then
  echo "Merging ISO parts into: $ISO"
  cat "$USB_PATH/$PART1" "$USB_PATH/$PART2" > "$USB_PATH/$ISO"
else
  echo "Already exists: $ISO"
fi

if command -v sha256sum >/dev/null 2>&1; then
  echo "Verifying ISO sha256..."
  (cd "$USB_PATH" && sha256sum -c "$SHA256")
elif command -v shasum >/dev/null 2>&1; then
  echo "Verifying ISO sha256..."
  expected="$(awk '{print $1}' "$USB_PATH/$SHA256")"
  actual="$(shasum -a 256 "$USB_PATH/$ISO" | awk '{print $1}')"
  [ "$expected" = "$actual" ] || {
    echo "ERROR: sha256 mismatch for $ISO"
    exit 1
  }
else
  echo "WARN: sha256 tool not found; skipped checksum verification."
fi

# 4. Download and expand persistence store
if [ ! -f "$USB_PATH/cco-persistence.dat" ]; then
  need_cmd xz
  download_if_missing "$BASE/cco-persistence.dat.xz" "$USB_PATH/cco-persistence.dat.xz"
  echo "Expanding cco-persistence.dat.xz..."
  xz -dc "$USB_PATH/cco-persistence.dat.xz" > "$USB_PATH/cco-persistence.dat"
else
  echo "Already exists: cco-persistence.dat"
fi

# 5. Write Ventoy persistence config
mkdir -p "$USB_PATH/ventoy"
cat > "$USB_PATH/ventoy/ventoy.json" <<EOF
{
  "control": [
    { "VTOY_DEFAULT_MENU_MODE": "0" },
    { "VTOY_MENU_TIMEOUT": "3" },
    { "VTOY_DEFAULT_IMAGE": "/$ISO" }
  ],
  "persistence": [
    {
      "image": "/$ISO",
      "backend": "/cco-persistence.dat",
      "autosel": 1
    }
  ]
}
EOF

echo
echo "AICODE-OS USB files are ready."
echo "USB: $USB_PATH"
for item in "$USB_PATH/$ISO" "$USB_PATH/cco-persistence.dat" "$USB_PATH/ventoy/ventoy.json"; do
  [ -e "$item" ] && ls -lh "$item"
done
