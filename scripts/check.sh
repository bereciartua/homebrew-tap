#!/bin/sh
# Checks the tap as Homebrew sees it: style, an online audit, and that
# livecheck finds each cask's version in its app's update feed. With --install
# it also installs each cask, checks the app and its command's link, and
# uninstalls it again.
#   sh scripts/check.sh [--install] [CASK...]   (default: every cask in scripts/casks.sh)
#
# For CI: it replaces any bereciartua/tap with a clone of this checkout's last
# commit, and --install installs into /Applications. Don't run it on a Mac
# that uses the tap or has one of its apps installed.
set -eu

tap=bereciartua/tap
tap_dir=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=scripts/casks.sh
. "$tap_dir/scripts/casks.sh"
install=false
if [ "${1:-}" = --install ]; then
    install=true
    shift
fi
# shellcheck disable=SC2086 # casks is a space-separated list of names
[ $# -gt 0 ] || set -- $casks
for name in "$@"; do cask_info "$name"; done
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_DEVELOPER=1

brew untap --force "$tap" 2> /dev/null || true
brew tap "$tap" "$tap_dir"
# Homebrew loads a third-party tap only once it is trusted (https://docs.brew.sh/Tap-Trust).
brew trust "$tap"

# brew style would hold the scripts to Homebrew's own shell format; shellcheck is enough.
if [ -n "${CI:-}" ] && ! command -v shellcheck > /dev/null; then brew install --quiet shellcheck; fi
if command -v shellcheck > /dev/null; then shellcheck -x "$tap_dir"/scripts/*.sh; fi

for name in "$@"; do
    cask_info "$name"
    cask="$tap/$name"
    brew style --cask "$cask"
    brew audit --cask --strict --online "$cask"
    version=$(sed -n 's/^  version "\(.*\)"$/\1/p' "$tap_dir/Casks/$name.rb")
    found=$(brew livecheck --cask --json "$cask" | ruby -rjson -e 'print JSON.parse(STDIN.read)[0].dig("version", "latest")')
    # The feed may already offer a newer version than the cask; never an older one.
    [ "$(printf '%s\n%s\n' "$version" "$found" | sort -V | tail -n 1)" = "$found" ] || {
        printf 'check: the %s cask has %s, but the update feed offers %s\n' "$name" "$version" "$found" >&2
        exit 1
    }
    printf 'check: %s style, audit and livecheck passed (cask %s, feed %s)\n' "$name" "$version" "$found"

    [ "$install" = true ] || continue

    app_path="/Applications/$app"
    link="$(brew --prefix)/bin/$binary"
    brew install --cask "$cask"
    [ "$(defaults read "$app_path/Contents/Info" CFBundleShortVersionString)" = "$version" ]
    spctl --assess --type execute --verbose=2 "$app_path" 2>&1 | tee /dev/stderr | grep -qx 'source=Notarized Developer ID'
    [ "$(readlink "$link")" = "$app_path/Contents/MacOS/$binary" ]
    "$link" --help > /dev/null
    brew uninstall --cask "$cask"
    [ ! -e "$app_path" ] && [ ! -e "$link" ]
    printf 'check: installed %s %s (notarized, %s linked) and uninstalled it\n' "$name" "$version" "$binary"
done
