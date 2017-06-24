//
//  TransitVehicle.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

private let vehicleIdEncoderString = "kVehicleIdEncoder"
private let directionTagEncoderString = "kDirectionTagEncoder"
private let latEncoderString = "kLatEncoder"
private let lonEncoderString = "kLonEncoder"
private let secondsSinceReportEncoderString = "kSecondsSinceReportEncoder"
private let leadingVehicleIdEncoderString = "kKeadingVehicleIdEncoder"
private let headingEncoderString = "kHeadingEncoder"
private let speedKmHEncoderString = "kSpeedKmHEncoder"

open class TransitVehicle: NSObject, NSCoding {
    
    open var vehicleId: Int = 0
    open var directionTag: String = ""
    open var lat: Double = 0
    open var lon: Double = 0
    open var secondsSinceReport: Int = 0
    open var leadingVehicleId: Int = 0
    open var heading: Int = 0
    open var speedKmH: Int = 0
    
    //Basic init
    public override init() { super.init() }
    
    //Init with proper things as Ints and Doubles
    public init(vehicleId:Int, directionTag:String, lat:Double, lon:Double, secondsSinceReport:Int, heading:Int, speedKmH:Int) {
        self.vehicleId = vehicleId
        self.directionTag = directionTag
        self.lat = lat
        self.lon = lon
        self.secondsSinceReport = secondsSinceReport
        self.heading = heading
        self.speedKmH = speedKmH
    }
    
    //Init with everything as string, convert in init
    public init(vehicleID:String, directionTag:String, lat:String, lon:String, secondsSinceReport:String, heading:String, speedKmH:String) {
        self.vehicleId = Int(vehicleID)!
        self.directionTag = directionTag
        self.lat = (lat as NSString).doubleValue
        self.lon = (lon as NSString).doubleValue
        self.secondsSinceReport = Int(secondsSinceReport)!
        self.heading = Int(heading)!
        self.speedKmH = Int(speedKmH)!
    }
    
    //MARK : NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        self.vehicleId = aDecoder.decodeInteger(forKey: vehicleIdEncoderString)
        self.directionTag = aDecoder.decodeObject(forKey: directionTagEncoderString) as? String ?? ""
        self.lat = aDecoder.decodeDouble(forKey: latEncoderString)
        self.lon = aDecoder.decodeDouble(forKey: lonEncoderString)
        self.secondsSinceReport = aDecoder.decodeInteger(forKey: secondsSinceReportEncoderString)
        self.leadingVehicleId = aDecoder.decodeInteger(forKey: leadingVehicleIdEncoderString)
        self.heading = aDecoder.decodeInteger(forKey: headingEncoderString)
        self.speedKmH = aDecoder.decodeInteger(forKey: speedKmHEncoderString)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(vehicleId, forKey: vehicleIdEncoderString)
        aCoder.encode(directionTag, forKey: directionTagEncoderString)
        aCoder.encode(lat, forKey: latEncoderString)
        aCoder.encode(lon, forKey: lonEncoderString)
        aCoder.encode(secondsSinceReport, forKey: secondsSinceReportEncoderString)
        aCoder.encode(leadingVehicleId, forKey: leadingVehicleIdEncoderString)
        aCoder.encode(heading, forKey: headingEncoderString)
        aCoder.encode(speedKmH, forKey: speedKmHEncoderString)
    }
}
