# Insomnia

Insomnia is a modern macOS menu bar app that prevents your Mac from falling asleep, keeping your system or display active when you need it most.

Recently rewritten in **SwiftUI** using the modern `MenuBarExtra` API.

## Features
- **Prevent Sleep**: Keep your system awake indefinitely.
- **Timed Wake**: Set a timer — 15 min, 30 min, 1h, 2h, 4h, 8h, 12h, or 24h.
- **Display Sleep**: Allow the display to sleep while keeping the system running (useful for downloads or background audio).
- **Battery Safety**: Automatically deactivates when battery drops below 20%.
- **Launch at Login**: Automatically start Insomnia when you log in.
- **Shortcuts & Siri**: Trigger or configure Insomnia via Apple Shortcuts or Siri.
- **Auto-Update Checker**: In-menu banner when a new release is available.
- **Modern Design**: Native macOS menu bar experience with custom icons.

## Installation

### Download
Check the [Releases](https://github.com/karansangha/Insomnia/releases) page for the latest `.dmg` installer.

### Manual Installation
1. Clone the repository.
2. Run the install script:
   ```bash
   ./install_app.sh
   ```
3. Move `Insomnia.app` to your Applications folder.

> [!NOTE]
> If you see a message that the app is "damaged" or "cannot be opened", run this command in Terminal to fix the quarantine attribute:
> ```bash
> xattr -cr /Applications/Insomnia.app
> ```

### CLI Build
You can also build using Swift Package Manager:
```bash
swift build -c release
```

## Development
This project uses **Swift Package Manager** with two targets:

- **`InsomniaCore`** — library containing all business logic (`SleepManager.swift`). Import this in tests.
- **`Insomnia`** — executable with the SwiftUI app (`InsomniaApp.swift`), Shortcuts intents (`Intents.swift`), and update checker (`UpdateChecker.swift`).

Open `Package.swift` in Xcode to start editing, or use the CLI:

```bash
swift build          # debug build
swift test           # run all tests
./install_app.sh     # build release .app bundle
./create_dmg.sh      # package into a DMG installer
```

## Credits
- Iconography by [Seerat Rana](https://www.behance.net/gallery/71477561/insomina-app-icon)
