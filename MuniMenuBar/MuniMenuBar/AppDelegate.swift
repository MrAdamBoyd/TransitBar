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

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        statusItem.title = "Loading..."
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings", action: Selector("openSettings"), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if MMBDataController.sharedController.anyStopsSaved() {
            //User has stops saved, download the data and start the timer
            
        } else {
            //User doesn't have any stops, open settings menu
            window.makeKeyAndOrderFront(self)
            
            //http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni
        }
        
    }

    func openSettings() {
        window.makeKeyAndOrderFront(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func startRefreshingData() {
        
    }
    
}

