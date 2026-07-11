#!/bin/zsh
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$BASE_DIR/AppIcon/AppIcon-source.png"
MASTER="$BASE_DIR/AppIcon/AppIcon-1024.png"
ICONSET="$BASE_DIR/AppIcon/AppIcon.iconset"
OUTPUT="$BASE_DIR/AppIcon/AppIcon.icns"

[[ -f "$SOURCE" ]] || { echo "Missing icon source: $SOURCE" >&2; exit 1; }

/usr/bin/swift "$BASE_DIR/MacApp/GenerateAppIcon.swift" "$SOURCE" "$MASTER"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$MASTER" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" "$MASTER" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$OUTPUT"
echo "Generated: $OUTPUT"
