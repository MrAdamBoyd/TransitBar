//
//  TransitEntry.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-11-19.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation
import SwiftBus

fileprivate let stopKey = "entryStopKey"
fileprivate let timesKey = "entryTimesKey"

class TransitEntry: NSObject, NSCoding {
    var stop: TransitStop!
    var times: (Date, Date)? //Nil if should always be shown

    init(stop: TransitStop, times: (Date, Date)?) {
        self.stop = stop
        self.times = times
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.stop = aDecoder.decodeObject(forKey: stopKey) as! TransitStop
        if let times = aDecoder.decodeObject(forKey: timesKey) as? (Date, Date) {
            self.times = times
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.stop, forKey: stopKey)
        aCoder.encode(self.times, forKey: timesKey)
    }
}
