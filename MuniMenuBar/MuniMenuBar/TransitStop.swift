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
private let kRouteTitleEncoderString = "kRouteTitleEncoder"
private let kStopTagEncoderString = "kStopTagEncoder"
private let kDirectionEncoderString = "kDirectionEncoder"
private let kPredictionsEncoderString = "kPredictionsEncoder"

//Direction for each line
enum LineDirection:Int {
    case NoDirection = 0, Inbound, Outbound
}

//Stored stop identifiers to get the data from
class TransitStop:NSObject, NSCoding {
    var routeTag:Int = 0
    var routeTitle:String = ""
    var stopTag:Int = 0
    var direction:LineDirection = .NoDirection
    var predictions:[Int] = []
    
    
    //Init without predictions
    init(lineNumber routeTag:Int, lineTitle routeTitle:String, atStop stopTag:Int, goingDirection direction:LineDirection) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
        self.stopTag = stopTag
        self.direction = direction
    }
    
    //Init with predictions
    init(lineNumber routeTag:Int, lineTitle routeTitle:String, atStop stopTag:Int, goingDirection direction:LineDirection, withPredictions predictions:[Int]) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
        self.stopTag = stopTag
        self.direction = direction
        self.predictions = predictions
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeIntegerForKey(kRouteTagEncoderString)
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        stopTag = aDecoder.decodeIntegerForKey(kStopTagEncoderString)
        direction = aDecoder.decodeObjectForKey(kDirectionEncoderString) as! LineDirection
        direction = LineDirection(rawValue:(aDecoder.decodeIntegerForKey(kDirectionEncoderString))) ?? .NoDirection
        predictions = aDecoder.decodeObjectForKey(kPredictionsEncoderString) as! [Int]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeInteger(stopTag, forKey: kStopTagEncoderString)
        aCoder.encodeObject(direction.rawValue, forKey: kDirectionEncoderString)
        aCoder.encodeObject(predictions, forKey: kPredictionsEncoderString)
    }
}