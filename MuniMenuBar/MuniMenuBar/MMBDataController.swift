//
//  MMBDataController.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

private let storedSettingsKey = "kMMBStoredSettings"

class MMBDataController {
    private var settings = UserSettings()
    
    static let sharedController = MMBDataController()
    
    private init() {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(storedSettingsKey) as? NSData {
            settings = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! UserSettings
            
        }
        self.saveSettings()
    }
    
    //Any saved stops to load data from
    func anyStopsSaved() -> Bool {
        return (settings.defaultStop1 != nil || settings.defaultStop2 != nil)
        //No need to check for optional stops being nil, they
    }
    
    //TransitLines
    
    func addLine(line:TransitLine) {
        settings.lineDefinitionArray.append(line)
    }

    func getAllLines() -> [TransitLine] {
        return settings.lineDefinitionArray
    }
    
    //differentLinesForDay
    
    func setDifferentLinesForDay(status:Bool) {
        settings.differentLinesForDay = status
        if !settings.differentLinesForDay {
            //Erase settings for the optional stops if the user turns off the different lines for the different parts of the day
            settings.optionalStop1 = nil
            settings.optionalStop2 = nil
        }
    }
    
    func getDifferentLinesForDay() -> Bool {
        return settings.differentLinesForDay
    }
    
    
    //mostRecentVersion
    
    func setMostRecentVersion(version: Double) {
        settings.mostRecentVersion = version
        self.saveSettings()
        
    }
    
    func getMostRecentVersion() -> Double {
        return settings.mostRecentVersion
    }
    
    //Saves the settings for the user to disk, should be used after setting any variable for the settings
    func saveSettings() {
        let archievedObject = NSKeyedArchiver.archivedDataWithRootObject(settings)
        NSUserDefaults.standardUserDefaults().setObject(archievedObject, forKey: storedSettingsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}