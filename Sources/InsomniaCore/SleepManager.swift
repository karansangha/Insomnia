import Foundation
import IOKit
import IOKit.pwr_mgt
import IOKit.ps
import ServiceManagement
import Combine
import UserNotifications

@MainActor
public class SleepManager: ObservableObject {
    public static let shared = SleepManager()

    @Published public var isActive: Bool = false
    @Published public var remainingTime: TimeInterval? = nil
    @Published public var activatedDuration: TimeInterval? = nil
    @Published public var batterySafetyEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(batterySafetyEnabled, forKey: "batterySafetyEnabled")
            if batterySafetyEnabled && isActive {
                checkBattery()
            }
        }
    }
    @Published public var allowDisplaySleep: Bool = false {
        didSet {
            if isActive {
                // Explicitly capture remainingTime before teardown, then rebuild with new assertion type.
                let preservedTime = remainingTime
                assertionManager.release(id: assertionID)
                timer?.invalidate()
                timer = nil
                tickCount = 0
                let assertionType = allowDisplaySleep ? kIOPMAssertionTypePreventUserIdleSystemSleep : kIOPMAssertionTypeNoDisplaySleep
                _createAssertion(type: assertionType as CFString, duration: preservedTime)
            }
        }
    }

    private let assertionManager: PowerAssertionManaging
    private var assertionID: IOPMAssertionID = 0
    private var timer: Timer?
    private var tickCount = 0
    private let reasonForActivity = "Insomnia - Prevent Sleep" as CFString

    public init(assertionManager: PowerAssertionManaging = LivePowerAssertionManager()) {
        self.assertionManager = assertionManager
        self.batterySafetyEnabled = UserDefaults.standard.bool(forKey: "batterySafetyEnabled")
    }

    public func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }

    public func activate(for duration: TimeInterval? = nil) {
        if isActive {
            deactivate()
        }
        let assertionType = allowDisplaySleep ? kIOPMAssertionTypePreventUserIdleSystemSleep : kIOPMAssertionTypeNoDisplaySleep
        _createAssertion(type: assertionType as CFString, duration: duration)
    }

    private func _createAssertion(type assertionType: CFString, duration: TimeInterval?) {
        let success = assertionManager.create(type: assertionType, name: reasonForActivity, id: &assertionID)
        if success == kIOReturnSuccess {
            isActive = true
            remainingTime = duration
            activatedDuration = duration
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.tick()
                }
            }
        } else {
            print("Failed to create IOPMAssertion")
            isActive = false
        }
    }

    public func deactivate() {
        if isActive {
            assertionManager.release(id: assertionID)
            isActive = false
        }
        timer?.invalidate()
        timer = nil
        remainingTime = nil
        activatedDuration = nil
        tickCount = 0
    }

    private func tick() {
        tickCount += 1

        if let time = remainingTime {
            if time > 0 {
                remainingTime = time - 1
            } else {
                deactivate()
                return
            }
        }

        if batterySafetyEnabled && tickCount % 30 == 0 {
            checkBattery()
        }
    }

    private func checkBattery() {
        guard let level = SleepManager.getBatteryLevel() else { return }
        if level <= 20 {
            deactivate()
            sendBatteryNotification()
        }
    }

    public static func getBatteryLevel() -> Int? {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        for ps in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as? [String: Any] else { continue }
            if let isPresent = info[kIOPSIsPresentKey] as? Bool, isPresent,
               let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let max = info[kIOPSMaxCapacityKey] as? Int {
                return Int((Double(capacity) / Double(max)) * 100)
            }
        }
        return nil
    }

    private func sendBatteryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Insomnia Deactivated"
        content.body = "Battery dropped below 20%. Sleep prevention has been disabled."
        let request = UNNotificationRequest(identifier: "battery-safety", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    public var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
                objectWillChange.send()
            } catch {
                print("Failed to toggle launch at login: \(error)")
            }
        }
    }

    public var remainingTimeIdentifier: String? {
        guard let time = remainingTime else { return nil }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes == 0 {
            return "Time remaining: \(seconds)s"
        }
        return seconds > 0 ? "Time remaining: \(minutes)m \(seconds)s" : "Time remaining: \(minutes)m"
    }
}
