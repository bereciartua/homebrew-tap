#!/bin/sh
# Points Casks/ek-bridge.rb at an EK Bridge release: the latest published one,
# or the version given (`sh scripts/update-cask.sh 0.9.0`).
#
# The DMG is downloaded and trusted only if its build attestation says the
# ek-bridge release workflow built it from that version's tag on a GitHub
# runner, and its SHA-256 matches the release's SHA256SUMS. The cask then gets
# that version and SHA-256. Never moves the cask to an older version.
#
# Needs gh (signed in, or GH_TOKEN). In GitHub Actions it writes `changed` and
# `version` to $GITHUB_OUTPUT.
set -eu

repo=bereciartua/ek-bridge
workflow="$repo/.github/workflows/release.yml"
tap_dir=$(cd "$(dirname "$0")/.." && pwd)
cask="$tap_dir/Casks/ek-bridge.rb"

output() {
    if [ -n "${GITHUB_OUTPUT:-}" ]; then printf '%s=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"; fi
}
fail() {
    printf 'update-cask: %s\n' "$1" >&2
    exit 1
}

if [ $# -gt 0 ]; then
    tag="v${1#v}"
else
    tag=$(gh release view --repo "$repo" --json tagName --jq .tagName)
fi
version=${tag#v}
case "$version" in
    *[!0-9.]* | "" | .* | *.) fail "\"$version\" isn't a release version" ;;
esac
current=$(sed -n 's/^  version "\(.*\)"$/\1/p' "$cask")
output version "$version"
if [ "$version" = "$current" ]; then
    printf 'update-cask: already at %s\n' "$version"
    output changed false
    exit 0
fi
if [ "$(printf '%s\n%s\n' "$current" "$version" | sort -V | tail -n 1)" != "$version" ]; then
    fail "$tag is older than the cask's $current"
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
dmg="EKBridge-$version.dmg"
gh release download "$tag" --repo "$repo" --dir "$work" --pattern "$dmg" --pattern SHA256SUMS
gh attestation verify "$work/$dmg" --repo "$repo" --signer-workflow "$workflow" \
    --source-ref "refs/tags/$tag" --deny-self-hosted-runners > /dev/null ||
    fail "$dmg has no attestation from $workflow at $tag"
sha256=$(shasum -a 256 "$work/$dmg" | cut -d' ' -f1)
listed=$(awk -v f="$dmg" '$2 == f { print $1 }' "$work/SHA256SUMS")
[ "$sha256" = "$listed" ] || fail "$dmg has SHA-256 $sha256, but SHA256SUMS lists \"$listed\""

V="$version" S="$sha256" perl -pi -e '
    s/^  version ".*"$/  version "$ENV{V}"/;
    s/^  sha256 ".*"$/  sha256 "$ENV{S}"/;
' "$cask"
if ! grep -qx "  version \"$version\"" "$cask" || ! grep -qx "  sha256 \"$sha256\"" "$cask"; then
    fail "couldn't rewrite $cask"
fi
printf 'update-cask: %s -> %s (attested, SHA-256 %s)\n' "$current" "$version" "$sha256"
output changed true
