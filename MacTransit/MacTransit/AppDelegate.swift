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
    
    //Item that lives in the status bar
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    var listWindowController: NSWindowController?
    var aboutWindowController: NSWindowController?
    
    var minuteTimer: Timer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Setting up the status bar menu and the actions from that
        self.statusItem.title = "Loading..."
        
        self.createMenuItems()
        
        //Setting up the Sparkle updater
        SUUpdater.shared().automaticallyChecksForUpdates = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createMenuItems), name: .entriesChanged, object: nil)
        
        if DataController.shared.savedEntries.count == 0 {
            self.openSettingsWindow()
        }
        
        self.minuteTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    /// Loads the predictions for all current stops
    func loadData() {
        print("Loading data...")
        let group = DispatchGroup()
        
        for entry in DataController.shared.savedEntries {
            group.enter()
            
            SwiftBus.shared.stopPredictions(forStop: entry.stop) { stop in
                
                if let stop = stop {
                    entry.stop.predictions = stop.predictions
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.updateMenuItems()
        }
    }
    
    func createMenuItems() {
        if self.statusItem.menu == nil {
            self.statusItem.menu = NSMenu()
        }
        
        self.statusItem.menu?.removeAllItems()
        
        for entry in DataController.shared.savedEntries {
            //When clicking on the menu, all the stops always show
            let title = "\(entry.stop.routeTitle) -> \(entry.stop.direction)"
            
            self.statusItem.menu?.addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
        }
        
        self.statusItem.menu?.addItem(NSMenuItem(title: "About MacTransit", action: #selector(self.openAboutWindow), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(self.checkForUpdates), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem.separator())
        self.statusItem.menu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(self.openSettingsWindow), keyEquivalent: ","))
        self.statusItem.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(self.terminate), keyEquivalent: "q"))
        
        self.loadData()
        self.updateMenuItems()
    }
    
    /// Creates the menu items for preferences/about/etc and also for all the transit entries
    func updateMenuItems() {
        var menuText = ""
        
        for (index, entry) in DataController.shared.savedEntries.enumerated() {
            var title = "\(entry.stop.routeTitle) -> \(entry.stop.direction)"
            
            if let predictions = entry.stop.predictions[entry.stop.direction] {
                
                //Creating the text that will be for this stop
                var menuTextForThisPrediction = entry.stop.routeTag + ": "
                
                var addingText = ": "
                for (index, prediction) in predictions.enumerated() {
                    
                    if index < 3 {
                        //Only add the first 3 predictions to the menubar item
                        menuTextForThisPrediction.append("\(prediction.predictionInMinutes), ")
                    }
                    
                    addingText.append("\(prediction.predictionInMinutes), ")
                }
                
                //Only show it in the menubar text if there is a prediction to add
                if predictions.count != 0 && entry.shouldBeShownInMenuBar {
                    menuTextForThisPrediction = String(menuTextForThisPrediction.characters.dropLast(2)) + "; " //Remove last comma and space and add semicolon
                    menuText.append(menuTextForThisPrediction)
                }
                
                //Menu items are always shown
                if predictions.count == 0 {
                    //No predictions, just add dash
                    addingText.append("-")
                } else {
                    //Remove comma and space
                    addingText = String(addingText.characters.dropLast(2))
                }
                title.append(addingText)
            }
            
            self.statusItem.menu?.items[index].title = title
        }
        
        if menuText == "" {
            menuText = "No Predictions"
        }
        
        self.statusItem.title = String(menuText.characters.dropLast(2)) //Remove final ; and space
    }
    
    // MARK: - Actions
    
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
