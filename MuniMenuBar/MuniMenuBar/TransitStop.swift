//
//  HelperClasses.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-19.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

private let kRouteTitleEncoderString = "kRouteTitleEncoder"
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
    var routeTitle:String = ""
    var routeTag:String = ""
    var stopTitle:String = ""
    var stopTag:String = ""
    var direction:LineDirection = .NoDirection
    var predictions:[Int] = []
    
    //Init without predictions or direction
    init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
    }
    
    //Init without predictions
    init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String, direction:LineDirection) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.direction = direction
    }
    
    //Init with predictions
    init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String, direction:LineDirection, predictions:[Int]) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.direction = direction
        self.predictions = predictions
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        stopTitle = aDecoder.decodeObjectForKey(kStopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObjectForKey(kStopTagEncoderString) as! String
        direction = LineDirection(rawValue:(aDecoder.decodeIntegerForKey(kDirectionEncoderString) as Int)) ?? .NoDirection
        predictions = aDecoder.decodeObjectForKey(kPredictionsEncoderString) as! [Int]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(stopTitle, forKey: kStopTitleEncoderString)
        aCoder.encodeObject(stopTag, forKey: kStopTagEncoderString)
        aCoder.encodeInteger(direction.rawValue, forKey: kDirectionEncoderString)
        aCoder.encodeObject(predictions, forKey: kPredictionsEncoderString)
    }
}