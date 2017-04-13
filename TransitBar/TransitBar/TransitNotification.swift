//
//  TransitNotification.swift
//  TransitBar
//
//  Created by Adam Boyd on 17/4/12.
//  Copyright © 2017 adam. All rights reserved.
//

import Foundation

class TransitNotification: Equatable {
    var minutesForFirstPredicion: Int = 0 //This is the number of minutes that the first prediction should be less than to send a notification to the user
    var entry: TransitEntry!
    
    static func ==(lhs: TransitNotification, rhs: TransitNotification) -> Bool {
        guard lhs.minutesForFirstPredicion == rhs.minutesForFirstPredicion else {
            return false
        }
        
        guard lhs.entry.stop.routeTag == rhs.entry.stop.routeTag else {
            return false
        }
        
        guard lhs.entry.stop.stopTag == rhs.entry.stop.stopTag else {
            return false
        }
        
        return true
    }
}
