//
//  AppDelegate.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-10-11.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import Sparkle
import SwiftBus

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    //Timer that goes once a minute to update times in MenuBar
    var minuteTimer: Timer = Timer()
    
    //Item that lives in the status bar
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    var listWindowController: NSWindowController?
    var aboutWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Setting up the status bar menu and the actions from that
        self.statusItem.title = "Loading..."
        
        self.recreateMenuItems()
        
        //Setting up the Sparkle updater
        SUUpdater.shared().automaticallyChecksForUpdates = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recreateMenuItems), name: .entriesChanged, object: nil)
        
        if DataController.shared.savedEntries.count == 0 {
            self.openSettingsWindow()
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    /// Creates the menu items for preferences/about/etc and also for all the transit entries
    func recreateMenuItems() {
        if self.statusItem.menu == nil {
            self.statusItem.menu = NSMenu()
        }
        
        self.statusItem.menu?.removeAllItems()
        
        for entry in DataController.shared.savedEntries {
            let title = "\(entry.stop.routeTitle) -> \(entry.stop.direction): predictions"
            self.statusItem.menu?.addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
        }
        
        self.statusItem.menu?.addItem(NSMenuItem(title: "About MacTransit", action: #selector(self.openAboutWindow), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(self.checkForUpdates), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem.separator())
        self.statusItem.menu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(self.openSettingsWindow), keyEquivalent: ","))
        self.statusItem.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(self.terminate), keyEquivalent: "q"))
    }
    
    /**
     Checks Sparkle to see if there are any updates
     */
    func checkForUpdates() {
        SUUpdater.shared().checkForUpdates(self)
    }
    
    /**
     Opens the settings window
     */
    func openSettingsWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: "mainWindow") as? NSWindowController else { return }
        self.listWindowController = windowController
        self.listWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    /**
     Opens the about window
     */
    func openAboutWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: "aboutWindow") as? NSWindowController else { return }
        self.aboutWindowController = windowController
        self.aboutWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    /**
     Quits the app
     */
    func terminate() {
        NSApplication.shared().terminate(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
