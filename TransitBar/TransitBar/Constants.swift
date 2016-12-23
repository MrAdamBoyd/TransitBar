//
//  Constants.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-12-05.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation

struct Constants {
    static let numberOfPredictionsKey = "numberOfPredictionsKey"
    static let entryArrayKey = "entryArrayKey"
    static let entriesChangedNotification = "entriesChangedNotification"
    static var userDefaultsName = "TransitBar"
}

extension Notification.Name {
    static let entriesChanged = Notification.Name(Constants.entriesChangedNotification)
}
