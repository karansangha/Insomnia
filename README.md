# Insomnia

Insomnia is a modern macOS menu bar app that prevents your Mac from falling asleep, keeping your system or display active when you need it most.

Recently rewritten in **SwiftUI** using the modern `MenuBarExtra` API.

## Features
- **Prevent Sleep**: Keep your system awake indefinitely.
- **Timed Wake**: Set a timer to keep awake for 15, 30, or 60 minutes.
- **Display Sleep**: Option to allow the display to sleep while keeping the system running (useful for background tasks like downloads or music).
- **Launch at Login**: Automatically start Insomnia when you log in.
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
This project uses **Swift Package Manager**.
- Open `Package.swift` in Xcode to start editing.
- Core logic is in `SleepManager.swift` (InsomniaCore target).
- UI is in `InsomniaApp.swift`.

## Credits
- Iconography by [Seerat Rana](https://www.behance.net/gallery/71477561/insomina-app-icon)
