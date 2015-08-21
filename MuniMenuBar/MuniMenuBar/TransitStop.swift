//
//  HelperClasses.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-19.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

//Direction for each line
enum LineDirection {
    case NoDirection
    case Inbound
    case Outbound
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
    
    //TODO
    
    required init(coder aDecoder: NSCoder) {
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
}