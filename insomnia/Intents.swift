import AppIntents
import InsomniaCore

@available(macOS 13.0, *)
struct ToggleInsomniaIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Insomnia"
    static var description = IntentDescription("Turns Insomnia's sleep prevention on or off.")

    @Parameter(title: "Turn On", default: true)
    var turnOn: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = SleepManager.shared
        if turnOn {
            manager.activate()
        } else {
            manager.deactivate()
        }
        return .result()
    }
}

@available(macOS 13.0, *)
struct SetInsomniaTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Insomnia Timer"
    static var description = IntentDescription("Keeps the Mac awake for a specified number of minutes.")

    @Parameter(title: "Minutes", default: 60)
    var minutes: Int

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = SleepManager.shared
        if minutes > 0 {
            manager.activate(for: TimeInterval(minutes * 60))
        } else {
            manager.deactivate()
        }
        return .result()
    }
}

@available(macOS 13.0, *)
struct InsomniaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleInsomniaIntent(),
            phrases: [
                "Toggle \(.applicationName)",
                "Turn on \(.applicationName)",
                "Turn off \(.applicationName)"
            ],
            shortTitle: "Toggle Insomnia",
            systemImageName: "moon.fill"
        )
        AppShortcut(
            intent: SetInsomniaTimerIntent(),
            phrases: [
                "Set \(.applicationName) timer",
                "Keep \(.applicationName) awake for a time"
            ],
            shortTitle: "Set Insomnia Timer",
            systemImageName: "timer"
        )
    }
}
