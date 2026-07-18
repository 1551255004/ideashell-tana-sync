#!/bin/zsh
set -euo pipefail

DMG_PATH="${1:?Usage: NOTARY_PROFILE=<keychain-profile> ./notarize-dmg.sh /absolute/path/to/IdeaSync.dmg}"
NOTARY_PROFILE="${NOTARY_PROFILE:?Set NOTARY_PROFILE to a notarytool keychain profile.}"

if [[ ! -f "$DMG_PATH" ]]; then
  echo "DMG not found: $DMG_PATH" >&2
  exit 1
fi

xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

MOUNT_POINT="$(mktemp -d /tmp/ideasync-notarycheck.XXXXXX)"
trap 'hdiutil detach "$MOUNT_POINT" -quiet >/dev/null 2>&1 || true; rmdir "$MOUNT_POINT" 2>/dev/null || true' EXIT
hdiutil attach -nobrowse -readonly -mountpoint "$MOUNT_POINT" "$DMG_PATH" >/dev/null
APP_PATH="$MOUNT_POINT/闪念同步.app"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type execute --verbose=4 "$APP_PATH"
echo "Notarized and stapled: $DMG_PATH"
