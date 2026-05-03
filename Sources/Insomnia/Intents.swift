import AppIntents
import InsomniaCore

struct ToggleInsomniaIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Insomnia"
    static var description = IntentDescription("Turns Insomnia's sleep prevention on or off.")

    @Parameter(title: "Turn On", default: true)
    var turnOn: Bool

    func perform() async throws -> some IntentResult {
        let on = turnOn
        await MainActor.run {
            if on {
                SleepManager.shared.activate()
            } else {
                SleepManager.shared.deactivate()
            }
        }
        return .result()
    }
}

struct SetInsomniaTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Insomnia Timer"
    static var description = IntentDescription("Keeps the Mac awake for a specified number of minutes.")

    @Parameter(title: "Minutes", default: 60)
    var minutes: Int

    func perform() async throws -> some IntentResult {
        let mins = minutes
        await MainActor.run {
            if mins > 0 {
                SleepManager.shared.activate(for: TimeInterval(mins * 60))
            } else {
                SleepManager.shared.deactivate()
            }
        }
        return .result()
    }
}

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
