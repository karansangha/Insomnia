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
            button.action = #selector(printQuote(_:))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @objc func printQuote(_ sender: Any?) {
        status = -status
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor) and status = \(status)")
        
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
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}
