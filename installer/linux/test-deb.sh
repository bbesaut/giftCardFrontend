#!/usr/bin/env bash
# Smoke test of the Debian package: installs it with apt, checks the result, removes it, checks again.
#
# Usage (from the repository root): installer/linux/test-deb.sh <version>
# Needs a Debian or Ubuntu machine and root rights (uses sudo when not root). Intended for CI or a
# throwaway container: it really installs the package system-wide. Fails on the first broken expectation.
set -euo pipefail

version="${1:?Usage: $0 <version>}"
package="gift-card-front"
deb="${package}_${version}_amd64.deb"

[ -f "${deb}" ] || { echo "Package not found: ${deb}" >&2; exit 1; }

sudo_cmd=""
if [ "$(id -u)" -ne 0 ]; then
  sudo_cmd="sudo"
fi

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "ok: ${description}"
  else
    echo "Package check failed: ${description}" >&2
    exit 1
  fi
}

${sudo_cmd} apt-get install -y "./${deb}"

check "package is registered with dpkg" dpkg -s "${package}"
check "registered version is ${version}" test "$(dpkg-query -W -f='${Version}' "${package}")" = "${version}"
check "application executable is installed" test -x "/opt/${package}/gift_card_front"
check "launcher symlink resolves to the executable" test -x "/usr/bin/${package}"
check "applications menu entry is installed" test -f "/usr/share/applications/${package}.desktop"

# Every shared library the binary needs must be present, i.e. the Depends field is complete.
if head -c 4 "/opt/${package}/gift_card_front" | grep -q "ELF"; then
  missing="$(ldd "/opt/${package}/gift_card_front" | grep "not found" || true)"
  check "no missing shared library${missing:+ ($missing)}" test -z "${missing}"
fi

${sudo_cmd} apt-get remove -y "${package}"

check "application executable is removed" test ! -e "/opt/${package}/gift_card_front"
check "launcher symlink is removed" test ! -e "/usr/bin/${package}"
check "applications menu entry is removed" test ! -e "/usr/share/applications/${package}.desktop"
