cask "ek-bridge" do
  version "0.10.2"
  sha256 "98bd20acfb4a5e952420cdd6a0b7498fd4828ea8ec20eccb1950778da3d9ba17"

  url "https://github.com/bereciartua/ek-bridge/releases/download/v#{version}/EKBridge-#{version}.dmg"
  name "EK Bridge"
  desc "Scoped Calendar and Reminders access for scripts and AI agents"
  homepage "https://github.com/bereciartua/ek-bridge"

  livecheck do
    url "https://github.com/bereciartua/ek-bridge/releases/latest/download/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: :sonoma

  app "EKBridge.app"
  binary "#{appdir}/EKBridge.app/Contents/MacOS/bridge-client"

  uninstall quit: "io.github.bereciartua.ekbridge"

  zap trash: [
    "~/Library/Application Support/EKBridge",
    "~/Library/Caches/io.github.bereciartua.ekbridge",
    "~/Library/HTTPStorages/io.github.bereciartua.ekbridge",
    "~/Library/HTTPStorages/io.github.bereciartua.ekbridge.binarycookies",
    "~/Library/Preferences/io.github.bereciartua.ekbridge.plist",
  ]
end
