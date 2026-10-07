# bereciartua/tap

Homebrew casks for [EK Bridge](https://github.com/bereciartua/ek-bridge), the menu bar app that gives scripts and AI agents scoped access to Calendar and Reminders.

## Install

```sh
brew install --cask bereciartua/tap/ek-bridge
```

This installs the same notarized, universal `EKBridge.app` as the [release DMG](https://github.com/bereciartua/ek-bridge/releases/latest) into `/Applications`, and links its command-line client, `bridge-client`, into Homebrew's `bin`. It needs macOS 14 or later. Then open the app and follow its setup checklist ([Setup](https://github.com/bereciartua/ek-bridge/blob/main/docs/SETUP.md)).

## Updates

The app updates itself (**Check for Updates…**, or the daily check), so `brew upgrade` skips it, as it does every cask marked `auto_updates`. `brew upgrade --greedy` updates it through Homebrew instead. Either way it stays at the same path, so its Calendar and Reminders access, clients and agent setups stay.

## Uninstall

```sh
brew uninstall --cask ek-bridge
```

This quits and removes the app and the `bridge-client` link, and keeps your data. Before uninstalling, remove its Calendar and Reminders access (EK Bridge's [Uninstall](https://github.com/bereciartua/ek-bridge#uninstall) steps). `brew uninstall --zap --cask ek-bridge` also moves its data to the Trash: clients, keys, tokens, Activity and settings in `~/Library/Application Support/EKBridge` and the app's preferences and caches. Agents can't connect again without new keys.

## How the cask is updated

`.github/workflows/update.yml` runs every six hours and after a release (`gh workflow run update.yml --repo bereciartua/homebrew-tap`). `scripts/update-cask.sh` downloads the latest release's DMG and uses it only if its [build attestation](https://docs.github.com/actions/security-for-github-actions/using-artifact-attestations) shows that ek-bridge's release workflow built it from that version's tag on a GitHub-hosted runner, and its SHA-256 matches the release's `SHA256SUMS`. `scripts/check.sh --install` then runs `brew style`, `brew audit --strict --online` and `brew livecheck`, installs the cask on a macOS runner, checks the app is notarized and `bridge-client` works, and uninstalls it. Only then is the new version pushed.

GitHub turns scheduled workflows off after 60 days without activity in a repository. If it has, `gh workflow enable update.yml --repo bereciartua/homebrew-tap` turns it back on.

## License

[Apache License 2.0](LICENSE), like EK Bridge.
