import SwiftUI
import InsomniaCore

@main
struct InsomniaApp: App {
    @StateObject private var sleepManager = SleepManager()

    var body: some Scene {
        MenuBarExtra {
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
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            
        } label: {
            Image(sleepManager.iconName)
        }
    }
}
