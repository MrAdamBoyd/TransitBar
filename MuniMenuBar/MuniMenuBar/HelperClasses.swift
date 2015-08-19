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
class stopIdentifier:NSObject, NSCoding {
    var routeTag:Int = 0
    var stopTag:Int = 0
    var routeTitle:String = ""
    var direction:LineDirection = .NoDirection
    var predictions:[Int] = []
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
}