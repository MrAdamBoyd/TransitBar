//
//  TransitStop.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

private let routeTitleEncoderString = "kRouteTitleEncoder"
private let routeTagEncoderString = "kRouteTagEncoder"
private let stopTitleEncoderString = "kStopTitleEncoder"
private let stopTagEncoderString = "kStopTagEncoder"
private let agencyTagEncoderString = "kAgencyTagEncoder"
private let directionEncoderString = "kDirectionEncoder"
private let latEncoderString = "kLatEncoder"
private let lonEncoderString = "kLonEncoder"
private let predictionsEncoderString = "kPredictionsEncoder"
private let messagesEncoderString = "kMessagesEncoder"

//A transit stop is a single stop which is tied to a single route
open class TransitStop: NSObject, NSCoding {
    
    open var routeTitle: String = ""
    open var routeTag: String = ""
    open var stopTitle: String = ""
    open var stopTag: String = ""
    open var agencyTag: String = ""
    open var direction: String = ""
    open var lat: Double = 0
    open var lon: Double = 0
    open var predictions: [String: [TransitPrediction]] = [:] //[direction : [prediction]]
    open var messages: [TransitMessage] = []
    
    /**
     Returns a list of all the predictions from the different directions in order
     
     - returns: In order list of all predictions from all different directions
     */
    open var allPredictions: [TransitPrediction] {
        var listOfPredictions: [TransitPrediction] = []
        
        for predictionDirection in predictions.values {
            //Going through each direction
            listOfPredictions += predictionDirection
        }
        
        //Sorting the list
        listOfPredictions.sort {
            return $0.predictionInSeconds < $1.predictionInSeconds
        }
        
        return listOfPredictions
    }
    
    //Init without predictions or direction
    public init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
    }
    
    /**
    Gets the predictions and messages for the current stop and calls the closure with the predictions and messages as a parameter. If the agency tag hasn't been loaded, it will call the closure with an empty dictionary.
    
    - parameter completion:    Code that is called after the call has been downloaded and parsed
        - parameter success:     Whether or not the call was a success
        - parameter predictions: The predictions, in all directions, for this stop
        - parameter messages:    The messages for this stop
    */
    open func getPredictionsAndMessages(_ completion:@escaping (_ success:Bool, _ predictions:[String : [TransitPrediction]], _ messages:[TransitMessage]) -> Void) {
        if agencyTag != "" {
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStopPredictionData(self.stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, completion: {(predictions: [String: [TransitPrediction]], messages: [TransitMessage]) in
                
                self.predictions = predictions
                self.messages = messages
                
                //Call completion with success, predictions, and message
                completion(true, predictions, messages)
                
            })
        } else {
            //Stop doesn't exist
            completion(false, [:], [])
        }
    }
    
    @available(*, deprecated: 1.4, obsoleted: 2.0, message: "Use variable `allPredictions` instead")
    open func combinedPredictions() -> [TransitPrediction] {
        return self.allPredictions
    }
    
    //MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let routeTitle = aDecoder.decodeObject(forKey: routeTitleEncoderString) as? String,
            let routeTag = aDecoder.decodeObject(forKey: routeTagEncoderString) as? String,
            let stopTitle = aDecoder.decodeObject(forKey: stopTitleEncoderString) as? String,
            let stopTag = aDecoder.decodeObject(forKey: stopTagEncoderString) as? String else {
            return
        }
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as? String ?? ""
        self.direction = aDecoder.decodeObject(forKey: directionEncoderString) as? String ?? ""
        self.lat = aDecoder.decodeDouble(forKey: latEncoderString)
        self.lon = aDecoder.decodeDouble(forKey: lonEncoderString)
        self.predictions = aDecoder.decodeObject(forKey: predictionsEncoderString) as? [String: [TransitPrediction]] ?? [:]
        self.messages = aDecoder.decodeObject(forKey: messagesEncoderString) as? [TransitMessage] ?? []
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeTitle, forKey: routeTitleEncoderString)
        aCoder.encode(self.routeTag, forKey: routeTagEncoderString)
        aCoder.encode(self.stopTitle, forKey: stopTitleEncoderString)
        aCoder.encode(self.stopTag, forKey: stopTagEncoderString)
        aCoder.encode(self.agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(self.direction, forKey: directionEncoderString)
        aCoder.encode(self.lat, forKey: latEncoderString)
        aCoder.encode(self.lon, forKey: lonEncoderString)
        aCoder.encode(self.predictions, forKey: predictionsEncoderString)
        aCoder.encode(self.messages, forKey: messagesEncoderString)
    }
}
