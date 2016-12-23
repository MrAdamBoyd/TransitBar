//
//  TransitEntry.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-11-19.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation
import SwiftBus

fileprivate let stopKey = "entryStopKey"
fileprivate let timeKey0 = "entryTimesKey0"
fileprivate let timeKey1 = "entryTimesKey1"
fileprivate let timeKeyNever = "entryTimesKeyNever"

class TransitEntry: NSObject, NSCoding {
    var stop: TransitStop!
    var times: (Date?, Date?)? //Nil if should always be shown

    init(stop: TransitStop, times: (Date?, Date?)?) {
        self.stop = stop
        self.times = times
    }
    
    /// Calculates whether or not this entry should be shown in the menubar based on if the current time falls between the times that the user selected
    var shouldBeShownInMenuBar: Bool {
        
        //If no times exist, should always be shown
        guard let times = times else {
            return true
        }
        
        //If the tuple exists but is nil, should neve rbe shown
        guard let earlier = times.0, let later = times.1 else {
            return false
        }
        
        let calendar = Calendar(identifier: .gregorian)
        
        let now = Date()
        
        //Getting the hour, minute, and second from the earlier and later times
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: earlier)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: later)
        
        //Creating new Date objects that have the hour, minute, and second from the previous times BUT the day is today
        let startTime = calendar.date(bySettingHour: startComponents.hour!, minute: startComponents.minute!, second: startComponents.second!, of: now)!
        let endTime = calendar.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: endComponents.second!, of: now)!
        
        return startTime.timeIntervalSince1970 < now.timeIntervalSince1970 && now.timeIntervalSince1970 < endTime.timeIntervalSince1970
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        if let unarchivedObject = aDecoder.decodeObject(forKey: stopKey) as? Data {
            self.stop = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! TransitStop
        }
        
        if let date1 = aDecoder.decodeObject(forKey: timeKey0) as? Date, let date2 = aDecoder.decodeObject(forKey: timeKey1) as? Date {
            //Shown in menu bar between certain times
            self.times = (date1, date2)
        } else if let _ = aDecoder.decodeObject(forKey: timeKeyNever) {
            //Never shown in menu bar
            self.times = (nil, nil)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        let archivedStop = NSKeyedArchiver.archivedData(withRootObject: self.stop)
        aCoder.encode(archivedStop, forKey: stopKey)
        
        if let times = self.times {
            if let earlier = times.0, let later = times.1 {
                //Shown in menu bar between certain times
                aCoder.encode(earlier, forKey: timeKey0)
                aCoder.encode(later, forKey: timeKey1)
            } else {
                //Never shown in menu bar
                aCoder.encode("never", forKey: timeKeyNever)
            }
        }
    }
}
