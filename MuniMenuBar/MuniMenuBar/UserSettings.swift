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
private let kDefaultStop1EncoderString = "kDefaultStop1Encoder"
private let kDefaultStop2EncoderString = "kDefaultStop2Encoder"
private let kdifferentLinesForDayEncoderString = "kdifferentLinesForDayEncoder"
private let kOptionalStop1EncoderString = "kSecondaryStop1Encoder"
private let kOptionalStop2EncoderString = "kSecondaryStop2Encoder"

class UserSettings: NSObject, NSCoding {
    var mostRecentVersion:Double = 1.0
    var firstTimeUsingApp:Bool = false
    
    //Dealing with the different settings the user might have
    
    //User can have up to 2 stops displaying at all times
    var defaultStop1:stopIdentifier?
    var defaultStop2:stopIdentifier?
    
    //User has choice of enabling different lines showing up at different times of the day
    var differentLinesForDay:Bool = false
    var optionalStop1:stopIdentifier?
    var optionalStop2:stopIdentifier?
    
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
        defaultStop1 = aDecoder.decodeObjectForKey(kDefaultStop1EncoderString) as? stopIdentifier
        defaultStop2 = aDecoder.decodeObjectForKey(kDefaultStop2EncoderString) as? stopIdentifier
        
        differentLinesForDay = aDecoder.decodeBoolForKey(kdifferentLinesForDayEncoderString)
        optionalStop1 = aDecoder.decodeObjectForKey(kOptionalStop1EncoderString) as? stopIdentifier
        optionalStop2 = aDecoder.decodeObjectForKey(kOptionalStop2EncoderString) as? stopIdentifier
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(mostRecentVersion, forKey: kMostRecentVersionEncoderString)
        aCoder.encodeBool(firstTimeUsingApp, forKey: kFirstTimeUsingAppEncoderString)
        aCoder.encodeObject(defaultStop1, forKey: kDefaultStop1EncoderString)
        aCoder.encodeObject(defaultStop2, forKey: kDefaultStop2EncoderString)
        
        aCoder.encodeBool(differentLinesForDay, forKey: kdifferentLinesForDayEncoderString)
        aCoder.encodeObject(optionalStop1, forKey: kOptionalStop1EncoderString)
        aCoder.encodeObject(optionalStop2, forKey: kOptionalStop2EncoderString)
    }
}