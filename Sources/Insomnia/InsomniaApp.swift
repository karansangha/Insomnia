import SwiftUI
import InsomniaCore
import UserNotifications

@main
struct InsomniaApp: App {
    @StateObject private var sleepManager: SleepManager
    @StateObject private var updateChecker: UpdateChecker

    var body: some Scene {
        MenuBarExtra {
            // Update Banner
            if updateChecker.updateAvailable, let url = updateChecker.releaseURL {
                Button("Update Available: \(updateChecker.latestVersion)") {
                    NSWorkspace.shared.open(url)
                }
                Divider()
            }

            // Unconditional keep awake
            Button {
                sleepManager.toggle()
            } label: {
                if sleepManager.isActive && sleepManager.remainingTime == nil {
                    Text("✓ Indefinitely")
                } else {
                    Text("Indefinitely")
                }
            }

            Divider()

            // Timer options
            timerButton(label: "For 15 Minutes", seconds: 15 * 60)
            timerButton(label: "For 30 Minutes", seconds: 30 * 60)
            timerButton(label: "For 1 Hour", seconds: 60 * 60)

            Menu("More Options") {
                timerButton(label: "For 2 Hours", seconds: 2 * 3600)
                timerButton(label: "For 4 Hours", seconds: 4 * 3600)
                timerButton(label: "For 8 Hours", seconds: 8 * 3600)
                timerButton(label: "For 12 Hours", seconds: 12 * 3600)
                timerButton(label: "For 24 Hours", seconds: 24 * 3600)
            }
            
            Divider()
            
            // Status info
            if let remaining = sleepManager.remainingTimeIdentifier {
                Text(remaining)
                    .foregroundStyle(.secondary)
            }
            
            Toggle("Launch at Login", isOn: Binding(
                get: { sleepManager.launchAtLogin },
                set: { sleepManager.launchAtLogin = $0 }
            ))
            
            Toggle("Allow Display Sleep", isOn: $sleepManager.allowDisplaySleep)
            
            Toggle("Battery Safety (< 20%)", isOn: $sleepManager.batterySafetyEnabled)
            
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            
        } label: {
            Image(sleepManager.isActive ? "open" : "closed")
        }
        .menuBarExtraStyle(.menu) // Ensure standard menu style
    }
    
    @ViewBuilder
    private func timerButton(label: String, seconds: TimeInterval) -> some View {
        let isSelected = sleepManager.isActive && sleepManager.activatedDuration.map { Int($0) == Int(seconds) } == true
        Button {
            if isSelected {
                sleepManager.deactivate()
            } else {
                sleepManager.activate(for: seconds)
            }
        } label: {
            Text(isSelected ? "✓ \(label)" : label)
        }
    }

    init() {
        let manager = SleepManager.shared
        let checker = UpdateChecker()
        checker.checkForUpdates()
        _sleepManager = StateObject(wrappedValue: manager)
        _updateChecker = StateObject(wrappedValue: checker)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
