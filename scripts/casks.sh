# Sourced by update-cask.sh and check.sh: what each cask installs and where
# its releases come from.
#   casks              every cask in the tap
#   cask_info NAME     sets repo (GitHub owner/name), dmg_prefix (the DMG is
#                      <dmg_prefix>-<version>.dmg), app (the bundle in
#                      /Applications) and binary (the command it links)
# shellcheck shell=sh

casks="ek-bridge funes-vault"

cask_info() {
    case "$1" in
        ek-bridge)
            repo=bereciartua/ek-bridge dmg_prefix=EKBridge app=EKBridge.app binary=bridge-client ;;
        funes-vault)
            repo=bereciartua/funes-vault-app dmg_prefix=FunesVault app=FunesVault.app binary=funes-mcp ;;
        *)
            printf '%s: no cask "%s" (one of: %s)\n' "$(basename "$0" .sh)" "$1" "$casks" >&2
            exit 2 ;;
    esac
}
