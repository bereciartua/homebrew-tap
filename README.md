# bereciartua/tap

Homebrew casks for two menu bar apps that give AI agents scoped access to your Mac:

- [EK Bridge](https://github.com/bereciartua/ek-bridge): scoped access to Calendar and Reminders for scripts and AI agents.
- [Funes Vault](https://funesvault.com): a personal memory vault on your Mac that AI agents can use only as you allow.

## Install

```sh
brew install --cask bereciartua/tap/ek-bridge
```

This installs the same notarized, universal `EKBridge.app` as the [release DMG](https://github.com/bereciartua/ek-bridge/releases/latest) into `/Applications`, and links its command-line client, `bridge-client`, into Homebrew's `bin`. It needs macOS 14 or later. Then open the app and follow its setup checklist ([Setup](https://github.com/bereciartua/ek-bridge/blob/main/docs/SETUP.md)).

```sh
brew install --cask bereciartua/tap/funes-vault
```

This installs the same notarized, universal `FunesVault.app` as the [release DMG](https://github.com/bereciartua/funes-vault-app/releases/latest) into `/Applications`, and links its MCP launcher, `funes-mcp`, into Homebrew's `bin`. It needs macOS 15 or later. Then open the app from the menu bar and connect an agent ([MCP setup](https://github.com/bereciartua/funes-vault-app/blob/main/docs/MCP.md)).

## Updates

Both apps update themselves (**Check for Updates…**, or the daily check), so `brew upgrade` skips them, as it does every cask marked `auto_updates`. `brew upgrade --greedy` updates them through Homebrew instead. Either way they stay at the same path, so EK Bridge's Calendar and Reminders access and Funes Vault's agents, and both apps' agent setups, stay.

## Uninstall

```sh
brew uninstall --cask ek-bridge
```

This quits and removes the app and the `bridge-client` link, and keeps your data. Before uninstalling, remove its Calendar and Reminders access (EK Bridge's [Uninstall](https://github.com/bereciartua/ek-bridge#uninstall) steps). `brew uninstall --zap --cask ek-bridge` also moves its data to the Trash: clients, keys, tokens, Activity and settings in `~/Library/Application Support/EKBridge` and the app's preferences and caches. Agents can't connect again without new keys.

```sh
brew uninstall --cask funes-vault
```

This quits and removes the app and the `funes-mcp` link, and keeps your vault. `brew uninstall --zap --cask funes-vault` also moves its data to the Trash: your memories, agents, agent keys, Activity and settings in `~/Library/Application Support/FunesVault`, and the app's preferences and caches. Export your vault first if you want to keep it. API keys for AI providers you added stay in your Keychain (service `com.funesvault.provider`) until you remove them in Funes Vault's Settings or Keychain Access.

## How the casks are updated

`.github/workflows/update.yml` runs every six hours and after a release (`gh workflow run update.yml --repo bereciartua/homebrew-tap`, optionally with `-f cask=funes-vault -f version=0.1.0`), one job per cask. `scripts/update-cask.sh` downloads the latest release's DMG and uses it only if its [build attestation](https://docs.github.com/actions/security-for-github-actions/using-artifact-attestations) shows that the app's release workflow built it from that version's tag on a GitHub-hosted runner, and its SHA-256 matches the release's `SHA256SUMS`. `scripts/check.sh --install` then runs `brew style`, `brew audit --strict --online` and `brew livecheck`, installs the cask on a macOS runner, checks the app is notarized and its command works, and uninstalls it. Only then is the new version pushed. `scripts/casks.sh` lists each cask's repository, DMG name, app and command.

GitHub turns scheduled workflows off after 60 days without activity in a repository. If it has, `gh workflow enable update.yml --repo bereciartua/homebrew-tap` turns it back on.

## License

[Apache License 2.0](LICENSE), like EK Bridge.
