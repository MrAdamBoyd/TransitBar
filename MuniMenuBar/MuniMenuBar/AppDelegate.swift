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
    
    var minuteTimer:NSTimer = NSTimer()

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        statusItem.title = "Loading..."
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings", action: Selector("openSettings"), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if !MMBDataController.sharedController.anyStopsSaved() {
            //User doesn't have any stops, open settings menu
            window.makeKeyAndOrderFront(self)
            
            MMBXmlParser.sharedParser.requestAllLineData()
        }
        
        //Timer that updates the label runs every 60 seconds
        minuteTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("loadData"), userInfo: nil, repeats: true)
        
        loadData()
    }
    
    func loadData() {
        if MMBDataController.sharedController.anyStopsSaved() {
            var stopsToCheck:[TransitStop] = MMBDataController.sharedController.getCurrentActiveStops()
            
            for stop in stopsToCheck {
                MMBXmlParser.sharedParser.requestStopPredictionData(stop)
            }
            
        } else {
            statusItem.title = "No Stops"
        }
    }
    
    //This function determines if we are done loading data, and if we are, we can update the label
    func predictionAdded(stop:TransitStop) {
        var allStops = MMBDataController.sharedController.getCurrentActiveStops()
        
        if allStops.count == 1 {
            //We're done, update label
            updateLabel()
        } else {
            //If this is the second element, we're done
            if stop == allStops[1] {
                //We're done, update label
                updateLabel()
            }
        }
    }
    
    //We have all the information, update label
    func updateLabel() {
        var allStops = MMBDataController.sharedController.getCurrentActiveStops()
        var stop1String = ""
        var stop2String = ""
        
        //Building string for first stop
        if allStops.count == 1 {
            stop1String = buildStopString(allStops[0])
        }
        
        if allStops.count == 2 {
            stop2String = "; " + buildStopString(allStops[1])
        }
        
        statusItem.title = stop1String
    }
    
    
    //Building the string for the stop
    func buildStopString(stop:TransitStop) -> String {
        var stopString = ""
        var directionString:String = " IB: "
        if stop.direction == .Outbound {
            directionString = " OB: "
        }
        
        var predictionString:String = ""
        
        //Takes first 3 predictions
        for index in 0...2 {
            predictionString += String(stop.predictions[index])
            if index != 2 {
                predictionString += ", "
            }
        }
        
        stopString = stop.routeTag + directionString + predictionString
        
        return stopString
        
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

