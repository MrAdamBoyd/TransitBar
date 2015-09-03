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
private let kInboundStopsOnLineEncoderString = "kInboundStopsOnLineEncoder"
private let kOutboundStopsOnLineEncoderString = "kOutboundStopsOnLineEncoder"

class TransitLine: NSObject, NSCoding {
    
    var routeTag:String = ""
    var routeTitle:String = ""
    var inboundStopsOnLine:[TransitStop] = []
    var outboundStopsOnLine:[TransitStop] = []
    
    //Init without stops
    init(lineNumber routeTag:String, lineTitle routeTitle:String) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
    }
    
    //Init with stops
    init(lineNumber routeTag:String, lineTitle routeTitle:String, withInboundStops inboundStopsOnLine:[TransitStop], andOutboundStops outboundStopsOnLine:[TransitStop]) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
        self.inboundStopsOnLine = inboundStopsOnLine
        self.outboundStopsOnLine = outboundStopsOnLine
    }
    
    //MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        inboundStopsOnLine = aDecoder.decodeObjectForKey(kInboundStopsOnLineEncoderString) as! [TransitStop]
        outboundStopsOnLine = aDecoder.decodeObjectForKey(kOutboundStopsOnLineEncoderString) as! [TransitStop]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(inboundStopsOnLine, forKey: kInboundStopsOnLineEncoderString)
        aCoder.encodeObject(outboundStopsOnLine, forKey: kOutboundStopsOnLineEncoderString)
    }
}