//
//  AppDelegate.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-07-10.
//  Copyright © 2016 Adam. All rights reserved.
//

import Cocoa
import SwiftBus
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //Window that contains the settings
    @IBOutlet weak var window: NSWindow!
    
    //Window that contains information about the app
    @IBOutlet weak var aboutWindow: NSWindow!
    
    //Timer that goes once a minute to update times in MenuBar
    var minuteTimer: NSTimer = NSTimer()
    
    //Item that lives in the status bar
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //Setting up the status bar menu and the actions from that
        self.statusItem.title = "Loading..."
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About MacTransit", action: #selector(self.openAboutWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(self.checkForUpdates), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(self.openSettingsWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(self.terminate), keyEquivalent: "q"))
        
        self.statusItem.menu = menu
        
        //Setting up the Sparkle updater
        SUUpdater.sharedUpdater().automaticallyChecksForUpdates = true
    
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    func checkForUpdates() {
        SUUpdater.sharedUpdater().checkForUpdates(self)
    }
    
    /**
     Opens the settings window
     */
    func openSettingsWindow() {
        self.window?.makeKeyAndOrderFront(self)
    }
    
    /**
     Opens the about window
     */
    func openAboutWindow() {
        self.aboutWindow?.makeKeyAndOrderFront(self)
    }
    
    /**
     Quits the app
     */
    func terminate() {
        NSApplication.sharedApplication().terminate(self)
    }

}
