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
    static let storeInCloudKey = "storeInCloudKey"
    static let walkingTimeKey = "walkingTimeKey"
    static let entryArrayKey = "entryArrayKey"
    static let entriesChangedNotification = "entriesChangedNotification"
    static let storeInCloudNotification = "storeInCloudNotification"
    static let walkingTimeSetNotification = "walkingTimeSetNotification"
    static var userDefaultsName = "TransitBar"
}

extension Notification.Name {
    static let entriesChanged = Notification.Name(Constants.entriesChangedNotification)
    static let storeInCloudChanged = Notification.Name(Constants.storeInCloudNotification)
    static let displayWalkingTimeChanged = Notification.Name(Constants.walkingTimeSetNotification)
}
