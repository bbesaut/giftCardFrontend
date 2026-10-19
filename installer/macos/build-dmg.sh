#!/usr/bin/env bash
# Builds the macOS disk image (.dmg) from an existing `flutter build macos --release` output.
#
# Usage (from the repository root): installer/macos/build-dmg.sh <version>
# Output: gift-card-front-<version>-macos.dmg at the repository root.
#
# The image shows the app next to a shortcut to /Applications, so installing is a drag and drop.
# Nothing is signed or notarized yet: Gatekeeper will ask the user to confirm the first launch.
set -euo pipefail

version="${1:?Usage: $0 <version>}"
app_name="Giftcards Management App"
app_source="build/macos/Build/Products/Release/gift_card_front.app"
output="gift-card-front-${version}-macos.dmg"

if [ ! -d "${app_source}" ]; then
  echo "Build output not found: ${app_source} (run flutter build macos --release first)" >&2
  exit 1
fi

staging="$(mktemp -d)"
trap 'rm -rf "${staging}"' EXIT

# The app is renamed to its display name: that is what the user sees in Finder and Applications.
cp -R "${app_source}" "${staging}/${app_name}.app"
ln -s /Applications "${staging}/Applications"

rm -f "${output}"
hdiutil create -volname "${app_name}" -srcfolder "${staging}" -ov -format UDZO "${output}"
echo "Built ${output}"
