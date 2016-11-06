//
//  AppDelegate.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var aboutWindow: NSWindow!
    
    var minuteTimer:NSTimer = NSTimer()
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        statusItem.title = "Loading..."
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "About Muni Menu Bar", action: #selector(self.openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(self.checkForUpdates), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(self.openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(self.quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if !MMBDataController.sharedController.anyStopsSaved() {
            //User doesn't have any stops, open settings menu
            window.makeKeyAndOrderFront(self)
            
            MMBXmlParser.sharedParser.requestAllLineData()
        }
        
        //Timer that updates the label runs every 60 seconds
        minuteTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
        
        SUUpdater.sharedUpdater().automaticallyChecksForUpdates = true
        
        loadData()
    }
    
    func loadData() {
        if MMBDataController.sharedController.anyStopsSaved() {
            var stopsToCheck:[TransitStop] = MMBDataController.sharedController.getCurrentActiveStops()
            
            MMBXmlParser.sharedParser.requestStopPredictionData(stopsToCheck[0])
            
        } else {
            statusItem.title = "No Stops"
        }
    }
    
    //This function determines if we are done loading data, and if we are, we can update the label
    func predictionAdded(stop:TransitStop) {
        var allStops:[TransitStop] = MMBDataController.sharedController.getCurrentActiveStops()
        
        if allStops.count == 1 {
            //We're done, update label
            updateLabel()
        } else {
            //If this is the second element, we're done
            if stop == allStops[1] {
                //We're done, update label
                updateLabel()
            } else {
                //Request data for second line
                MMBXmlParser.sharedParser.requestStopPredictionData(allStops[1])
            }
        }
    }
    
    //We have all the information, update label
    func updateLabel() {
        var allStops = MMBDataController.sharedController.getCurrentActiveStops()
        var stop1String = ""
        var stop2String = ""
        
        //Building string for first stop
        stop1String = buildStopString(allStops[0])
        
        if allStops.count == 2 {
            stop2String = "; " + buildStopString(allStops[1])
        }
        
        statusItem.title = stop1String + stop2String
    }
    
    
    //Building the string for the stop
    func buildStopString(stop:TransitStop) -> String {
        var stopString:String = ""
        var predictionString:String = ""
        var directionString:String = " IB: "
        if stop.direction == .Outbound {
            directionString = " OB: "
        }
        
        //Takes first 3 predictions
        let numberOfPredictionsToShow = stop.predictions.count > 3 ? 3 : stop.predictions.count
        
        if numberOfPredictionsToShow > 0 {
            //If there are predictions, show them
            for index in 0...numberOfPredictionsToShow - 1 {
                predictionString += String(stop.predictions[index])
                if index != numberOfPredictionsToShow - 1 {
                    predictionString += ", "
                }
            }
        } else {
            //If there are no predictions, show that line isn't running
            predictionString = "--"
        }
        
        
        stopString = stop.routeTag + directionString + predictionString
        
        return stopString
        
    }
    
    func quitApp() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    //Called by the "Check for updates" menu button being clicked
    func checkForUpdates() {
        SUUpdater.sharedUpdater().checkForUpdates(self)
    }
    
    func openAbout() {
        aboutWindow.makeKeyAndOrderFront(self)
    }
    
    func openSettings() {
        window.makeKeyAndOrderFront(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}

