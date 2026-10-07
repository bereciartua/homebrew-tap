#!/bin/sh
# Checks the tap as Homebrew sees it: style, an online audit, and that
# livecheck finds the version in EK Bridge's update feed. With --install it
# also installs the cask, checks the app and the bridge-client link, and
# uninstalls it again.
#
# For CI: it replaces any bereciartua/tap with a clone of this checkout's last
# commit, and --install installs into /Applications. Don't run it on a Mac
# that uses the tap or has EK Bridge installed.
set -eu

tap=bereciartua/tap
cask="$tap/ek-bridge"
tap_dir=$(cd "$(dirname "$0")/.." && pwd)
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_DEVELOPER=1

brew untap --force "$tap" 2> /dev/null || true
brew tap "$tap" "$tap_dir"

brew style "$tap"
brew audit --cask --strict --online "$cask"
version=$(sed -n 's/^  version "\(.*\)"$/\1/p' "$tap_dir/Casks/ek-bridge.rb")
found=$(brew livecheck --cask --json "$cask" | ruby -rjson -e 'print JSON.parse(STDIN.read)[0].dig("version", "latest")')
# The feed may already offer a newer version than the cask; never an older one.
[ "$(printf '%s\n%s\n' "$version" "$found" | sort -V | tail -n 1)" = "$found" ] || {
    printf 'check: the cask has %s, but the update feed offers %s\n' "$version" "$found" >&2
    exit 1
}
printf 'check: style, audit and livecheck passed (cask %s, feed %s)\n' "$version" "$found"

[ "${1:-}" = --install ] || exit 0

app=/Applications/EKBridge.app
link="$(brew --prefix)/bin/bridge-client"
brew install --cask "$cask"
[ "$(defaults read "$app/Contents/Info" CFBundleShortVersionString)" = "$version" ]
spctl --assess --type execute --verbose=2 "$app" 2>&1 | tee /dev/stderr | grep -qx 'source=Notarized Developer ID'
[ "$(readlink "$link")" = "$app/Contents/MacOS/bridge-client" ]
"$link" --help > /dev/null
brew uninstall --cask "$cask"
[ ! -e "$app" ] && [ ! -e "$link" ]
printf 'check: installed %s (notarized, bridge-client linked) and uninstalled it\n' "$version"
