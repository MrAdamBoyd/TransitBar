//
//  UserSettings.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

private let kMostRecentVersionEncoderString = "kMostRecentVersionEncoder"
private let kFirstTimeUsingAppEncoderString = "kFirstTimeUseringAppEncoder"

class UserSettings: NSObject, NSCoding {
    var mostRecentVersion:Double = 1.0
    var firstTimeUsingApp:Bool = false
    
    override init() {
        super.init()
    }
    
    init(version:Double) {
        mostRecentVersion = version
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        mostRecentVersion = aDecoder.decodeDoubleForKey(kMostRecentVersionEncoderString)
        firstTimeUsingApp = aDecoder.decodeBoolForKey(kFirstTimeUsingAppEncoderString)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(mostRecentVersion, forKey: kMostRecentVersionEncoderString)
        aCoder.encodeBool(firstTimeUsingApp, forKey: kFirstTimeUsingAppEncoderString)
    }
}