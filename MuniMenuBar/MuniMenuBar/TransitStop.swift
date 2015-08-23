//
//  HelperClasses.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-19.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

private let kRouteTagEncoderString = "kRouteTagEncoder"
private let kStopTitleEncoderString = "kStopTitleEncoder"
private let kStopTagEncoderString = "kStopTagEncoder"
private let kDirectionEncoderString = "kDirectionEncoder"
private let kPredictionsEncoderString = "kPredictionsEncoder"

//Direction for each line
enum LineDirection:Int {
    case NoDirection = 0, Inbound, Outbound
}

//Stored stop identifiers to get the data from
class TransitStop:NSObject, NSCoding {
    var routeTag:String = ""
    var stopTitle:String = ""
    var stopTag:String = ""
    var direction:LineDirection = .NoDirection
    var predictions:[Int] = []
    
    //Init without line info
    init(stopNamed stopTitle:String, stopNumber stopTag:String, goingDirection direction:LineDirection) {
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.direction = direction
    }
    
    //Init without predictions
    init(lineNumber routeTag:String, lineTitle routeTitle:String, atStop stopTag:String, goingDirection direction:LineDirection) {
        self.routeTag = routeTag
        self.stopTitle = routeTitle
        self.stopTag = stopTag
        self.direction = direction
    }
    
    //Init with predictions
    init(lineNumber routeTag:String, stopNamed stopTitle:String, atStop stopTag:String, goingDirection direction:LineDirection, withPredictions predictions:[Int]) {
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.direction = direction
        self.predictions = predictions
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        stopTitle = aDecoder.decodeObjectForKey(kStopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObjectForKey(kStopTagEncoderString) as! String
        direction = LineDirection(rawValue:(aDecoder.decodeIntegerForKey(kDirectionEncoderString) as Int)) ?? .NoDirection
        predictions = aDecoder.decodeObjectForKey(kPredictionsEncoderString) as! [Int]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(stopTitle, forKey: kStopTitleEncoderString)
        aCoder.encodeObject(stopTag, forKey: kStopTagEncoderString)
        aCoder.encodeInteger(direction.rawValue, forKey: kDirectionEncoderString)
        aCoder.encodeObject(predictions, forKey: kPredictionsEncoderString)
    }
}