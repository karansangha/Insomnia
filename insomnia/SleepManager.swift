import Foundation
import IOKit
import IOKit.pwr_mgt
import SwiftUI
import ServiceManagement

import ServiceManagement
import Combine

public class SleepManager: ObservableObject {
    @Published public var isActive: Bool = false
    @Published public var remainingTime: TimeInterval? = nil
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
    private let reasonForActivity = "Insomnia - Prevent Sleep" as CFString
    
    public init() {
        // Restore state if needed, or default to off
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
            
            if let duration = duration {
                remainingTime = duration
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    self?.tick()
                }
            } else {
                remainingTime = nil
                timer?.invalidate()
                timer = nil
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
        guard let time = remainingTime else { return }
        if time > 0 {
            remainingTime = time - 1
        } else {
            deactivate()
        }
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
