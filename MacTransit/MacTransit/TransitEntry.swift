//
//  TransitEntry.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-11-19.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation
import SwiftBus

class TransitEntry {
    var stop: TransitStop!
    var times: (Date, Date)? //Nil if should always be shown

    init(stop: TransitStop, times: (Date, Date)?) {
        self.stop = stop
        self.times = times
    }
}
