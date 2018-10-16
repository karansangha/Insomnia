//
//  AppDelegate.swift
//  insomnia
//
//  Created by Karan Sangha on 2018-10-15.
//  Copyright © 2018 Karan Sangha. All rights reserved.
//

import Cocoa
import IOKit
import IOKit.pwr_mgt

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let reasonForActivity = "Reason for activity" as CFString
    var assertionID: IOPMAssertionID = 0
    var status = -1 // default = off
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(changeSleepStatus(_:))
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @objc func changeSleepStatus(_ sender: Any?) {
        status = -status
        
        var success = IOPMAssertionCreateWithName( kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                   IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                   reasonForActivity,
                                                   &assertionID )
        if success == kIOReturnSuccess {
            if(status == -1) {
                success = IOPMAssertionRelease(assertionID);
            }
        }
    }
}
