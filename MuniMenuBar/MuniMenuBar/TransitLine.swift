//
//  TransitLine.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-20.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let kRouteTagEncoderString = "kRouteTagEncoder"
private let kRouteTitleEncoderString = "kRouteTitleEncoder"
private let kStopsOnLineEncoderString = "kStopsOnLineEncoder"

class TransitLine: NSObject, NSCoding {
    
    var routeTag:Int = 0
    var routeTitle:String = ""
    var stopsOnLine:[TransitStop] = []
    
    //Init without stops
    init(lineNumber routeTag:Int, lineTitle routeTitle:String) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
    }
    
    //Init with stops
    init(lineNumber routeTag:Int, lineTitle routeTitle:String, withStops stopsOnLine:[TransitStop]) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
        self.stopsOnLine = stopsOnLine
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeIntegerForKey(kRouteTagEncoderString)
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        stopsOnLine = aDecoder.decodeObjectForKey(kStopsOnLineEncoderString) as! [TransitStop]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(stopsOnLine, forKey: kStopsOnLineEncoderString)
    }
}