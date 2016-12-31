//
//  TransitStation.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation

private let routesAtStationEncoderString = "routesAtStationEncoder"
private let stopTitleEncoderString = "stopTitleEncoder"
private let stopTagEncoderString = "stopTagEncoder"
private let agencyTagEncoderString = "agencyTagEncoder"
private let latEncoderString = "latEncoder"
private let lonEncoderString = "lonEncoder"
private let predictionsEncoderString = "predictionsEncoder"
private let messagesEncoderString = "messagesEncoder"

//A tranit station is a transit stop tied to multiple routes
open class TransitStation: NSObject, NSCoding {
    open var routesAtStation: [TransitRoute] = []
    open var stopTitle: String = ""
    open var stopTag: String = ""
    open var agencyTag: String = ""
    open var lat: Double = 0
    open var lon: Double = 0
    open var predictions: [String: [String: [TransitPrediction]]] = [:] //[routeTag : [direction : prediction]]
    open var messages: [String] = []
    
    /**
     Returns a list of all the predictions from the different directions in order
     
     - returns: In order list of all predictions from all different directions
     */
    open var allPredictions: [TransitPrediction] {
        var listOfPredictions: [TransitPrediction] = []
        
        for line in predictions.values {
            //Going through each line
            for predictionDirection in line.values {
                //Going through each direction
                listOfPredictions += predictionDirection
            }
        }
        
        //Sorting the list
        listOfPredictions.sort {
            return $0.predictionInSeconds < $1.predictionInSeconds
        }
        
        return listOfPredictions
    }
    
    //Basic init
    public override init() { super.init() }
    
    /**
    Initializes the object with everything needed to get the route config
    
    - parameter stopTitle:          title of the stop
    - parameter stopTag:            4 digit tag of the stop
    - parameter routesAtStation:    array of routes that go to the station
    
    - returns: None
    */
    public init(stopTitle:String, stopTag:String, routesAtStation:[TransitRoute]) {
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.routesAtStation = routesAtStation
    }
    
    @available(*, deprecated: 1.4, obsoleted: 2.0, message: "Use variable `allPredictions` instead")
    open func combinedPredictions() -> [TransitPrediction] {
        return self.allPredictions
    }
    
    //MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        self.routesAtStation = aDecoder.decodeObject(forKey: routesAtStationEncoderString) as? [TransitRoute] ?? []
        self.stopTitle = aDecoder.decodeObject(forKey: stopTitleEncoderString) as? String ?? ""
        self.stopTag = aDecoder.decodeObject(forKey: stopTagEncoderString) as? String ?? ""
        self.agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as? String ?? ""
        self.lat = aDecoder.decodeDouble(forKey: latEncoderString)
        self.lon = aDecoder.decodeDouble(forKey: lonEncoderString)
        self.predictions = aDecoder.decodeObject(forKey: predictionsEncoderString) as? [String: [String: [TransitPrediction]]] ?? [:]
        self.messages = aDecoder.decodeObject(forKey: messagesEncoderString) as? [String] ?? []
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routesAtStation, forKey: routesAtStationEncoderString)
        aCoder.encode(self.stopTitle, forKey: stopTitleEncoderString)
        aCoder.encode(self.stopTag, forKey: stopTagEncoderString)
        aCoder.encode(self.agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(self.lat, forKey: latEncoderString)
        aCoder.encode(self.lon, forKey: lonEncoderString)
        aCoder.encode(self.predictions, forKey: predictionsEncoderString)
        aCoder.encode(self.messages, forKey: messagesEncoderString)
    }
}
