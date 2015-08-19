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

//Direction for each line
enum LineDirection {
    case NoDirection
    case Inbound
    case Outbound
}

//Stored stop identifiers to get the data from
class stopIdentifier:NSObject {
    var lineNumber:Int = 0
    var stopNumber:Int = 0
    var direction:LineDirection = .NoDirection
}

class MMBDataController {
    private var settings = UserSettings()
    
    static let sharedController = MMBDataController()
    
    private init() {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(storedSettingsKey) as? NSData {
            settings = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! UserSettings
            
        }
        self.saveSettings()
    }
    
    //mostRecentVersion
    
    func getMostRecentVersion() -> Double {
        return settings.mostRecentVersion
    }
    
    func setMostRecentVersion(version: Double) {
        settings.mostRecentVersion = version
        self.saveSettings()
        
    }
    
    //Saves the settings for the user to disk, should be used after setting any variable for the settings
    func saveSettings() {
        let archievedObject = NSKeyedArchiver.archivedDataWithRootObject(settings)
        NSUserDefaults.standardUserDefaults().setObject(archievedObject, forKey: storedSettingsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}