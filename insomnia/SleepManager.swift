import Foundation
import IOKit
import IOKit.pwr_mgt
import IOKit.ps
import SwiftUI
import AppKit
import ServiceManagement

import ServiceManagement
import Combine

public class SleepManager: ObservableObject {
    public static let shared = SleepManager()

    @Published public var isActive: Bool = false
    @Published public var remainingTime: TimeInterval? = nil
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
                // Re-activate to switch assertion type
                activate(for: remainingTime)
            }
        }
    }
    
    private var assertionID: IOPMAssertionID = 0
    private var timer: Timer?
    private var tickCount = 0
    private let reasonForActivity = "Insomnia - Prevent Sleep" as CFString
    
    public init() {
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
        // If already active, release existing to be safe or just update timer
        if isActive {
            deactivate()
        }
        
        let assertionType = allowDisplaySleep ? kIOPMAssertionTypePreventUserIdleSystemSleep : kIOPMAssertionTypeNoDisplaySleep
        
        let success = IOPMAssertionCreateWithName(
            assertionType as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reasonForActivity,
            &assertionID
        )
        
        if success == kIOReturnSuccess {
            isActive = true
            remainingTime = duration
            
            // start timer unconditionally to handle both custom duration and battery checking
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tick()
            }
        } else {
            print("Failed to create IOPMAssertion")
            isActive = false
        }
    }
    
    public func deactivate() {
        if isActive {
            IOPMAssertionRelease(assertionID)
            isActive = false
        }
        timer?.invalidate()
        timer = nil
        remainingTime = nil
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
        
        // Every 30 seconds, check battery
        if batterySafetyEnabled && tickCount % 30 == 0 {
            checkBattery()
        }
    }
    
    private func checkBattery() {
        guard let level = SleepManager.getBatteryLevel() else { return }
        if level <= 20 {
            deactivate()
            DispatchQueue.main.async {
                self.showBatteryAlert()
            }
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
    
    private func showBatteryAlert() {
        let alert = NSAlert()
        alert.messageText = "Battery Safety Triggered"
        alert.informativeText = "Insomnia has deactivated because your battery dropped below 20%."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
    
    public var iconName: String {
        return isActive ? "open" : "closed"
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
        let minutes = Int(time) / 60
        return "Time remaining: \(minutes)m"
    }
}
