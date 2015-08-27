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
    
    func getCurrentActiveStops() -> [TransitStop] {
        var savedStops:[TransitStop] = []
        var needToUseOtherLine:Bool = false
        
        //User enabled different a different line for a different part of the day
        if settings.differentLinesForDay && settings.optionalStop1 != nil {
            
            //I hate dealing with dates
            var calendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            
            var now = NSDate()
            
            var nowComponents:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: now)
            var startComponents:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: settings.differentStartTime!)
            var endComponents:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: settings.differentEndTime!)

            var startTime:NSDate = calendar.dateBySettingHour(startComponents.hour, minute: startComponents.minute, second: startComponents.second, ofDate: now, options: nil)!
            var endTime:NSDate = calendar.dateBySettingHour(endComponents.hour, minute: endComponents.minute, second: endComponents.second, ofDate: now, options: nil)!
            
            //If we are in between the start time and the end time
            if startTime.timeIntervalSince1970 < now.timeIntervalSince1970 && now.timeIntervalSince1970 < endTime.timeIntervalSince1970 {
                needToUseOtherLine = true
            }
            
            
        }
        
        //Using regular lines
        if !needToUseOtherLine {
            if let stop1 = settings.defaultStop1 {
                savedStops.append(stop1)
            }
            
            if let stop2 = settings.defaultStop2 {
                savedStops.append(stop2)
            }
        } else {
            if let stop1 = settings.optionalStop1 {
                savedStops.append(stop1)
            }
            
            if let stop2 = settings.optionalStop2 {
                savedStops.append(stop2)
            }
        }
        
        return savedStops
    }
    
    //Saving a stop
    func saveStop(index:Int, stop:TransitStop) {
        if index == 0 {
            settings.defaultStop1 = stop
        } else if index == 1 {
            settings.defaultStop2 = stop
        } else if index == 2 {
            settings.optionalStop1 = stop
        } else if index == 3 {
            settings.optionalStop2 = stop
        }
        
        saveSettings()
    }
    
    //Getting a stop
    func getStop(index:Int) -> TransitStop? {
        if index == 0 {
            return settings.defaultStop1
        } else if index == 1 {
            return settings.defaultStop2
        } else if index == 2 {
            return settings.optionalStop1
        } else if index == 3 {
            return settings.optionalStop2
        }
        
        return nil
    }
    
    //TransitLines
    
    func addLine(line:TransitLine) {
        settings.lineDefinitionArray.append(line)
    }

    func getAllLines() -> [TransitLine] {
        return settings.lineDefinitionArray
    }
    
    //Returns the string title of all lines
    func getAllLinesToString() -> [NSString] {
        var stringArray:[NSString] = []
        for item in settings.lineDefinitionArray {
            stringArray.append(item.routeTitle)
        }
        return stringArray
    }
    
    //Returns a string array of all inbound or outbound stops
    func getStopNames(forLine index:Int, goingDirection inboundOrOutbound:LineDirection) -> [NSString] {
        var stringArray:[NSString] = []
        var stopsInDirection:[TransitStop] = []
        
        //Determining which stops to look at
        switch inboundOrOutbound {
        case .Inbound:
            stopsInDirection = settings.lineDefinitionArray[index].inboundStopsOnLine
        case .Outbound:
            stopsInDirection = settings.lineDefinitionArray[index].outboundStopsOnLine
        default:
            stopsInDirection = []
        }
        
        for item in stopsInDirection {
            stringArray.append(item.stopTitle)
        }
        
        return stringArray
    }
    
    //differentLinesForDay
    
    func setDifferentLinesForDay(status:Bool) {
        settings.differentLinesForDay = status
        if !settings.differentLinesForDay {
            //Erase settings for the optional stops if the user turns off the different lines for the different parts of the day
            settings.optionalStop1 = nil
            settings.optionalStop2 = nil
        }
        saveSettings()
    }
    
    func getDifferentLinesForDay() -> Bool {
        return settings.differentLinesForDay
    }
    
    
    //different start and end times
    func getDifferentStartTime() -> NSDate? {
        return settings.differentStartTime
    }
    
    func setDifferentStartTime(date:NSDate) {
        settings.differentStartTime = date
        saveSettings()
    }
    
    func getDifferentEndTime() -> NSDate? {
        return settings.differentEndTime
    }
    
    func setDifferentEndTime(date:NSDate) {
        settings.differentEndTime = date
        saveSettings()
    }
    
    //Adding stops to line object
    func addStopsToLineAtIndex(index:Int, inboundStops:[TransitStop], outboundStops:[TransitStop]) {
        settings.lineDefinitionArray[index].inboundStopsOnLine = inboundStops
        settings.lineDefinitionArray[index].outboundStopsOnLine = outboundStops
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