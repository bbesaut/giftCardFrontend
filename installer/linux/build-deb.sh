#!/usr/bin/env bash
# Builds a Debian package (.deb) from an existing `flutter build linux --release` output.
#
# Usage (from the repository root): installer/linux/build-deb.sh <version>
# Output: gift-card-front_<version>_amd64.deb at the repository root.
#
# Layout installed on the target machine:
#   /opt/gift-card-front/                     the Flutter bundle
#   /usr/bin/gift-card-front                  symlink, to start the app from a terminal
#   /usr/share/applications/gift-card-front.desktop   entry in the applications menu
# Nothing is signed yet.
set -euo pipefail

version="${1:?Usage: $0 <version>}"
package="gift-card-front"
app_name="Giftcards Management App"
bundle="build/linux/x64/release/bundle"
output="${package}_${version}_amd64.deb"

if [ ! -x "${bundle}/gift_card_front" ]; then
  echo "Build output not found: ${bundle} (run flutter build linux --release first)" >&2
  exit 1
fi

root="$(mktemp -d)"
trap 'rm -rf "${root}"' EXIT

install -d "${root}/DEBIAN" "${root}/opt/${package}" "${root}/usr/bin" "${root}/usr/share/applications"

cp -R "${bundle}/." "${root}/opt/${package}/"
ln -s "/opt/${package}/gift_card_front" "${root}/usr/bin/${package}"

cat > "${root}/usr/share/applications/${package}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${app_name}
Exec=/opt/${package}/gift_card_front
Terminal=false
Categories=Office;Finance;
EOF

# Runtime libraries the Flutter Linux bundle links against; apt installs them with the package.
installed_size_kb="$(du -sk "${root}/opt" | cut -f1)"
cat > "${root}/DEBIAN/control" <<EOF
Package: ${package}
Version: ${version}
Section: misc
Priority: optional
Architecture: amd64
Maintainer: bbesaut <bbesaut@users.noreply.github.com>
Installed-Size: ${installed_size_kb}
Depends: libgtk-3-0, libblkid1, liblzma5
Description: ${app_name}
 Front-end of the Gift Card Service.
EOF

# Predictable permissions whoever builds the package: directories 755, files 644, executables 755.
find "${root}" -type d -exec chmod 755 {} +
find "${root}/opt" "${root}/usr/share" -type f -exec chmod 644 {} +
chmod 755 "${root}/opt/${package}/gift_card_front"

dpkg-deb --root-owner-group --build "${root}" "${output}"
echo "Built ${output}"
