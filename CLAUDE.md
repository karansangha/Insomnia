# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests
swift test

# Run a single test
swift test --filter SleepManagerTests/testToggle

# Build .app bundle (release, ad-hoc signed)
./install_app.sh

# Package into DMG (runs install_app.sh if needed)
./create_dmg.sh
```

Releases are triggered by pushing a `v*` tag; CI builds, tests, signs, and publishes a DMG automatically.

## Architecture

The project uses Swift Package Manager with two targets:

**`InsomniaCore`** (`insomnia/SleepManager.swift`) — a library containing all business logic. `SleepManager` is an `ObservableObject` singleton (`SleepManager.shared`) that wraps `IOPMAssertion` to prevent system or display sleep. It owns a 1-second `Timer` that counts down timed sessions and checks battery every 30 ticks when battery safety is enabled. State (`isActive`, `remainingTime`, `batterySafetyEnabled`, `allowDisplaySleep`) is all `@Published`.

**`Insomnia`** (executable) — depends on `InsomniaCore`. `InsomniaApp.swift` is the `@main` SwiftUI entry point using `MenuBarExtra` for the menu bar UI. `Intents.swift` exposes two `AppIntent`s (`ToggleInsomniaIntent`, `SetInsomniaTimerIntent`) for Shortcuts/Siri integration — both reach `SleepManager.shared`. `UpdateChecker.swift` polls the GitHub Releases API on launch and surfaces an update banner in the menu.

**Key constraint**: `InsomniaCore` excludes `InsomniaApp.swift`, `UpdateChecker.swift`, and `Intents.swift` from its sources (see `Package.swift`), so the test target can import just the core logic without pulling in SwiftUI app lifecycle code.

## IOPMAssertion usage

`SleepManager` holds a single `IOPMAssertionID`. Calling `activate()` always releases any existing assertion before creating a new one. The assertion type switches between `kIOPMAssertionTypeNoDisplaySleep` (keep display on) and `kIOPMAssertionTypePreventUserIdleSystemSleep` (allow display sleep) based on `allowDisplaySleep`. Always pair `activate()` with `deactivate()` — leaking assertions keeps the system awake after the app exits.
