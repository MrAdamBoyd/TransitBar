//
//  AppDelegate.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    @IBOutlet weak var settingsWindow: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        statusItem.title = "Hello"
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings", action: Selector("openSettings"), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    func openSettings() {
        settingsWindow.makeKeyAndOrderFront(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

