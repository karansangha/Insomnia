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
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("closed"))
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        constructMenu()
        statusItem.menu = nil
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func changeSleepStatus(_ sender: Any?) {
        changeIcon()
        changeStatus()
    }
    
    func changeStatus() {
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
    
    func changeIcon() {
        if let button = statusItem.button {
            if (button.image == NSImage(named:NSImage.Name("closed"))) {
                button.image = NSImage(named:NSImage.Name("open"))
            } else {
                button.image = NSImage(named:NSImage.Name("closed"))
            }
        }
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Quit Insomnia", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func statusBarButtonClicked(_ sender: Any?) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem.menu = menu
            statusItem.popUpMenu(menu)
            statusItem.menu = nil
        } else {
            statusItem.menu = nil
            changeIcon()
            changeStatus()
        }
    }
}
