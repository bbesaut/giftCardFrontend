#!/usr/bin/env bash
# Smoke test of the macOS disk image: mounts it and checks what a user would see.
#
# Usage (from the repository root): installer/macos/test-dmg.sh <version>
# Fails (non-zero exit) on the first broken expectation. The image is mounted read-only
# and always detached, even on failure.
set -euo pipefail

version="${1:?Usage: $0 <version>}"
dmg="gift-card-front-${version}-macos.dmg"
app_name="Giftcards Management App"

[ -f "${dmg}" ] || { echo "Disk image not found: ${dmg}" >&2; exit 1; }

mount_point="$(mktemp -d)"
cleanup() {
  hdiutil detach "${mount_point}" -quiet -force 2>/dev/null || true
  rmdir "${mount_point}" 2>/dev/null || true
}
trap cleanup EXIT

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "ok: ${description}"
  else
    echo "Disk image check failed: ${description}" >&2
    exit 1
  fi
}

hdiutil attach "${dmg}" -mountpoint "${mount_point}" -nobrowse -readonly -quiet

check "app bundle is present" test -d "${mount_point}/${app_name}.app"
check "app executable is present" test -x "${mount_point}/${app_name}.app/Contents/MacOS/gift_card_front"
check "Info.plist is present" test -f "${mount_point}/${app_name}.app/Contents/Info.plist"
check "Applications shortcut points to /Applications" \
  test "$(readlink "${mount_point}/Applications")" = "/Applications"
