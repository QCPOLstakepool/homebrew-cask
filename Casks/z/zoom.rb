cask "zoom" do
  arch arm: "arm64/"
  livecheck_folder = on_arch_conditional arm: "?archType=arm64"

  version "5.17.1.27701"
  sha256 arm:   "afe4c26e9bdd89977ea0f82527c0f576066196ee272620207a2850301145c9d0",
         intel: "a1f089d4adaefe394d8e21daff3855da7e6fd48e78d0aa936c38dd7d9466700a"

  url "https://cdn.zoom.us/prod/#{version}/#{arch}zoomusInstallerFull.pkg"
  name "Zoom"
  desc "Video communication and virtual meeting platform"
  homepage "https://www.zoom.us/"

  livecheck do
    url "https://www.zoom.us/client/latest/zoomusInstallerFull.pkg#{livecheck_folder}"
    strategy :header_match
  end

  auto_updates true
  conflicts_with cask: "zoom-for-it-admins"

  pkg "zoomusInstallerFull.pkg"

  postflight do
    # Description: Ensure console variant of postinstall is non-interactive.
    # This is because `open "$APP_PATH"&` is called from the postinstall
    # script of the package and we don't want any user intervention there.
    retries ||= 3
    ohai "The Zoom package postinstall script launches the Zoom app" if retries >= 3
    ohai "Attempting to close zoom.us.app to avoid unwanted user intervention" if retries >= 3
    return unless system_command "/usr/bin/pkill", args: ["-f", "/Applications/zoom.us.app"]
  rescue RuntimeError
    sleep 1
    retry unless (retries -= 1).zero?
    opoo "Unable to forcibly close zoom.us.app"
  end

  uninstall launchctl: "us.zoom.ZoomDaemon",
            signal:    ["KILL", "us.zoom.xos"],
            pkgutil:   "us.zoom.pkg.videomeeting",
            delete:    [
              "/Applications/zoom.us.app",
              "/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
              "/Library/Logs/DiagnosticReports/zoom.us*",
              "/Library/PrivilegedHelperTools/us.zoom.ZoomDaemon",
            ]

  zap trash: [
    "~/.zoomus",
    "~/Desktop/Zoom",
    "~/Documents/Zoom",
    "~/Library/Application Scripts/*.ZoomClient3rd",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings.plist",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings",
    "~/Library/Application Support/CrashReporter/zoom.us*",
    "~/Library/Application Support/zoom.us",
    "~/Library/Caches/us.zoom.xos",
    "~/Library/Cookies/us.zoom.xos.binarycookies",
    "~/Library/Group Containers/*.ZoomClient3rd",
    "~/Library/HTTPStorages/us.zoom.xos",
    "~/Library/HTTPStorages/us.zoom.xos.binarycookies",
    "~/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
    "~/Library/Logs/zoom.us",
    "~/Library/Logs/zoominstall.log",
    "~/Library/Logs/ZoomPhone",
    "~/Library/Preferences/us.zoom.airhost.plist",
    "~/Library/Preferences/us.zoom.caphost.plist",
    "~/Library/Preferences/us.zoom.Transcode.plist",
    "~/Library/Preferences/us.zoom.xos.Hotkey.plist",
    "~/Library/Preferences/us.zoom.xos.plist",
    "~/Library/Preferences/us.zoom.ZoomAutoUpdater.plist",
    "~/Library/Preferences/ZoomChat.plist",
    "~/Library/Saved Application State/us.zoom.xos.savedState",
    "~/Library/WebKit/us.zoom.xos",
  ]
end
