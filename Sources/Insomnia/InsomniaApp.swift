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
            Button("For 15 Minutes") {
                sleepManager.activate(for: 15 * 60)
            }
            .disabled(sleepManager.isActive && sleepManager.remainingTime == 15 * 60) // Simple check, might refine later

            Button("For 30 Minutes") {
                sleepManager.activate(for: 30 * 60)
            }
            
            Button("For 1 Hour") {
                sleepManager.activate(for: 60 * 60)
            }
            
            Menu("More Options") {
                Button("For 2 Hours") { sleepManager.activate(for: 2 * 3600) }
                Button("For 4 Hours") { sleepManager.activate(for: 4 * 3600) }
                Button("For 8 Hours") { sleepManager.activate(for: 8 * 3600) }
                Button("For 12 Hours") { sleepManager.activate(for: 12 * 3600) }
                Button("For 24 Hours") { sleepManager.activate(for: 24 * 3600) }
            }
            
            Divider()
            
            // Status info
            if let remaining = sleepManager.remainingTimeIdentifier {
                Text(remaining)
                    .foregroundColor(.secondary)
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
            Image(sleepManager.iconName)
        }
        .menuBarExtraStyle(.menu) // Ensure standard menu style
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
