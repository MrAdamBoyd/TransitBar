//
//  TransitPrediction.swift
//  SwiftBus
//
//  Created by Adam on 2015-09-01.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

private let numberOfVehiclesEncoderString = "kNumberOfVehiclesEncoder"
private let predictionInMinutesEncoderString = "kPredictionInMinutesEncoder"
private let predictionInSecondsEncoderString = "kPredictionInSecondsEncoder"
private let vehicleTagEncoderString = "kVehicleTagEncoder"
private let directionNameEncoderString = "directionNameEncoderString"

open class TransitPrediction: NSObject, NSCoding {
    
    open var numberOfVehicles: Int = 0
    open var predictionInMinutes: Int = 0
    open var predictionInSeconds: Int = 0
    open var vehicleTag: Int = 0
    open var directionName: String = ""
    
    //Basic init
    public override init() { super.init() }
    
    //Init with only # of minutes
    public init(predictionInMinutes:Int) {
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = self.predictionInMinutes * 60
    }
    
    //Init with all parameters except number of vehicles
    public init(predictionInMinutes:Int, predictionInSeconds:Int, vehicleTag:Int) {
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = predictionInSeconds
        self.vehicleTag = vehicleTag
    }
    
    //MARK : NSCoding
    public required init(coder aDecoder: NSCoder) {
        self.numberOfVehicles = aDecoder.decodeInteger(forKey: numberOfVehiclesEncoderString)
        self.predictionInMinutes = aDecoder.decodeInteger(forKey: predictionInMinutesEncoderString)
        self.predictionInSeconds = aDecoder.decodeInteger(forKey: predictionInSecondsEncoderString)
        self.vehicleTag = aDecoder.decodeInteger(forKey: vehicleTagEncoderString)
        if let directionName = aDecoder.decodeObject(forKey: directionNameEncoderString) as? NSString {
            self.directionName = directionName as String
        }
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.numberOfVehicles, forKey: numberOfVehiclesEncoderString)
        aCoder.encode(self.predictionInMinutes, forKey: predictionInMinutesEncoderString)
        aCoder.encode(self.predictionInSeconds, forKey: predictionInSecondsEncoderString)
        aCoder.encode(self.vehicleTag, forKey: vehicleTagEncoderString)
        aCoder.encode(self.directionName as NSString, forKey: directionNameEncoderString)
    }
    
}
