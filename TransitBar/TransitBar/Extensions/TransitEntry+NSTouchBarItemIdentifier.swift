//
//  TransitEntry+NSTouchBarItemIdentifier.swift
//  TransitBar
//
//  Created by Adam on 1/8/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import SwiftBus

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    init(entry: TransitEntry) {
        self.init("\(entry.stop.routeTag)-\(entry.stop.stopTag)")
    }
}
