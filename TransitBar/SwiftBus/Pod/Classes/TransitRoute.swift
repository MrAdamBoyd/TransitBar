//
//  TransitRoute.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

private let routeTagEncoderString = "kRouteTagEncoder"
private let routeTitleEncoderString = "kRouteTitleEncoder"
private let agencyTagEncoderString = "kAgencyTagEncoder"
private let stopsOnRouteEncoderString = "kStopsOnRouteEncoder"
private let directionTagToNameEncoderString = "kDirectionTagToNameEncoder"
private let routeColorEncoderString = "kRouteColorEncoder"
private let oppositeColorEncoderString = "kOppositeColorEncoder"
private let representedRouteColorEncoderString = "kRepresentedRouteColorEncoder"
private let representedOppositeColorEncoderString = "kRepresentedOppositeColorEncoder"
private let vehiclesOnRouteEncoderString = "kVehiclesOnRouteEncoder"
private let latMinEncoderString = "kLatMinEncoder"
private let latMaxEncoderString = "kLatMaxEncoder"
private let lonMinEncoderString = "kLonMinEncoder"
private let lonMaxEncoderString = "kLonMaxEncoder"


open class TransitRoute: NSObject, NSCoding {
    
    open var routeTag: String = ""
    open var routeTitle: String = ""
    open var agencyTag: String = ""
    open var stops: [String: [TransitStop]] = [:]
    open var directionTagToName: [String : String] = [:] //[directionTag : directionName]
    open var routeColor: String = ""
    open var oppositeColor: String = ""
    open var representedRouteColor = SwiftBusColor.clear
    open var representedOppositeColor = SwiftBusColor.clear
    
    @available(*, deprecated: 1.4, obsoleted: 2.0, message: "Use variable `stops` instead")
    open var stopsOnRoute: [String : [TransitStop]] {
        return self.stops
    }
    
    open var vehiclesOnRoute:[TransitVehicle] = []
    open var latMin:Double = 0
    open var latMax:Double = 0
    open var lonMin:Double = 0
    open var lonMax:Double = 0
    
    //Basic init
    public override init() { super.init() }
    
    //Init without stops
    public init(routeTag:String, routeTitle:String) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
    }
    
    
    /**
    Initializes the object with everything needed to get the route config
    
    - parameter routeTag:  tag of the route, eg. "5R"
    - parameter agencyTag: agency where the route is, eg. "sf-muni"
    
    - returns: None
    */
    public init(routeTag:String, agencyTag:String) {
        self.routeTag = routeTag
        self.agencyTag = agencyTag
    }
    
    /**
    Downloading the information about the route config, only need the routeTag and the agencyTag
    
    - parameter completion: Code that is called when the route is finished loading
        - parameter route:   The route object with all the information
    */
    open func configuration(_ completion: ((_ result: SwiftBusResult<TransitRoute>) -> Void)?) {
        let connectionHandler = SwiftBusConnectionHandler()
        connectionHandler.requestRouteConfiguration(self.routeTag, fromAgency: self.agencyTag) { result in
            
            switch result {
            case let .success(route):
                self.updateData(route)
                completion?(.success(self))
            case let .error(error):
                completion?(.error(error))
            }
        }

    }
    
    /**
    Downloads the information about vehicle locations, also gets the route config
    
    - parameter completion:    Code that is called when loading is done
        - parameter vehicles:   Locations of the vehicles
    */
    open func vehicleLocations(_ completion: ((_ vehicles: SwiftBusResult<[TransitVehicle]>) -> Void)?) {
        self.configuration() { result in
            switch result {
            case .success:
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestVehicleLocationData(onRoute: self.routeTag, withAgency: self.agencyTag) { result in
                    
                    switch result {
                    case let .success(locations):
                        self.vehiclesOnRoute = []
                        
                        for vehiclesInDirection in locations.values {
                            self.vehiclesOnRoute += vehiclesInDirection
                        }
                        completion?(.success(self.vehiclesOnRoute))
                        
                    case let .error(error):
                        completion?(.error(error))
                    }
                }
            case let .error(error):
                completion?(.error(error))
            }
        }
    }
    
    /**
     Getting the stop predictions for a certain stop
     
     - parameter stop:          Stop to get predictions for
     - parameter completion:    Code that is called when the information is done downloading
         - parameter result:    Predictions for the current stop
     */
    open func stopPredictions(forStop stop: TransitStop?, completion: ((_ result: SwiftBusResult<[String : [TransitPrediction]]>) -> Void)?) {
        self.stopPredictions(forStopTag: stop?.stopTag, completion: completion)
    }
    
    /**
    Getting the stop predictions for a certain stop
    
    - parameter stopTag:    Tag of the stop
    - parameter completion:    Code that is called when the information is done downloading
        - parameter result:    Predictions for the current stop
    */
    open func stopPredictions(forStopTag stopTag: String?, completion: ((_ result: SwiftBusResult<[String : [TransitPrediction]]>) -> Void)?) {
        
        guard let stopTag = stopTag else {
            completion?(.error(SwiftBusError.error(with: .unspecifiedStopTag)))
            return
        }
        
        self.configuration() { result in
            
            switch result {
            case .success:
                guard let stop = self.stop(forTag: stopTag) else {
                    //The stop doesn't exist
                    completion?(.error(SwiftBusError.error(with: .unknownStop)))
                    return
                }
                
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestStopPredictionData(stopTag, onRoute: self.routeTag, withAgency: self.agencyTag) { result in
                    
                    switch result {
                    case let .success(predictions):
                        //Saving the messages and predictions
                        stop.predictions = predictions.predictions
                        stop.messages = predictions.messages
                        
                        //Finished loading, send back
                        completion?(.success(predictions.predictions))
                    case let .error(error):
                        completion?(.error(error))
                    }
                }
                
            case let .error(error):
                //Encountered a problem, the route probably doesn't exist or the agency isn't right
                completion?(.error(error))
            }

        }
    }
    
    /**
    Returns the TransitStop object for a certain stop tag if it exists
    
    - parameter stopTag: Tag of the stop that will be returned
    
    - returns: Optional TransitStop object for the tag provided
    */
    open func stop(forTag stopTag:String) -> TransitStop? {
        for direction in stops.keys {
            //For each direction
            for directionStop in stops[direction]! {
                //For each stop in each direction
                if directionStop.stopTag == stopTag {
                    //If the stop matches, set the value to true
                    return directionStop
                }
            }
        }
        
        return nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop with a certain stop tag can be found in this route
    
    - parameter stopTag: the tag that is being matched against
    
    - returns: Whether the stop is in this route
    */
    open func containsStop(withTag stopTag:String) -> Bool {
        return self.stop(forTag: stopTag) != nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop can be be found in this route
    
    - parameter stop: TransitStop object that is checked against all stops in the route
    
    - returns: Whether the stop is in this route
    */
    open func containsStop(stop: TransitStop) -> Bool {
        return self.containsStop(withTag: stop.stopTag)
    }
    
    //Used to update all the data after getting the route information
    fileprivate func updateData(_ newRoute: TransitRoute) {
        self.routeTitle = newRoute.routeTitle
        self.stops = newRoute.stops
        self.directionTagToName = newRoute.directionTagToName
        self.routeColor = newRoute.routeColor
        self.oppositeColor = newRoute.oppositeColor
        self.representedRouteColor = newRoute.representedRouteColor
        self.representedOppositeColor = newRoute.representedOppositeColor
        self.vehiclesOnRoute = newRoute.vehiclesOnRoute
        self.latMin = newRoute.latMin
        self.latMax = newRoute.latMax
        self.lonMin = newRoute.lonMin
        self.lonMax = newRoute.lonMax
    }
    
    //MARK: NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        guard let tag = aDecoder.decodeObject(forKey: routeTagEncoderString) as? String,
            let title = aDecoder.decodeObject(forKey: routeTitleEncoderString) as? String,
            let agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as? String else {
            return
        }
        self.routeTag = tag
        self.routeTitle = title
        self.agencyTag = agencyTag
        self.stops = aDecoder.decodeObject(forKey: stopsOnRouteEncoderString) as? [String: [TransitStop]] ?? [:]
        self.directionTagToName = aDecoder.decodeObject(forKey: directionTagToNameEncoderString) as? [String: String] ?? [:]
        self.routeColor = aDecoder.decodeObject(forKey: routeColorEncoderString) as? String ?? ""
        self.oppositeColor = aDecoder.decodeObject(forKey: oppositeColorEncoderString) as? String ?? ""
        self.representedRouteColor = aDecoder.decodeObject(forKey: representedRouteColorEncoderString) as? SwiftBusColor ?? SwiftBusColor.clear
        self.representedOppositeColor = aDecoder.decodeObject(forKey: representedOppositeColorEncoderString) as? SwiftBusColor ?? SwiftBusColor.clear
        
        self.vehiclesOnRoute = aDecoder.decodeObject(forKey: vehiclesOnRouteEncoderString) as? [TransitVehicle] ?? []
        self.latMin = aDecoder.decodeDouble(forKey: latMinEncoderString)
        self.latMax = aDecoder.decodeDouble(forKey: latMaxEncoderString)
        self.lonMin = aDecoder.decodeDouble(forKey: lonMinEncoderString)
        self.lonMax = aDecoder.decodeDouble(forKey: lonMaxEncoderString)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeTag, forKey: routeTagEncoderString)
        aCoder.encode(self.routeTitle, forKey: routeTitleEncoderString)
        aCoder.encode(self.agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(self.stops, forKey: stopsOnRouteEncoderString)
        aCoder.encode(self.directionTagToName, forKey: directionTagToNameEncoderString)
        aCoder.encode(self.routeColor, forKey: routeColorEncoderString)
        aCoder.encode(self.oppositeColor, forKey: oppositeColorEncoderString)
        aCoder.encode(self.representedRouteColor, forKey: representedRouteColorEncoderString)
        aCoder.encode(self.representedOppositeColor, forKey: representedOppositeColorEncoderString)
        aCoder.encode(self.vehiclesOnRoute, forKey: vehiclesOnRouteEncoderString)
        aCoder.encode(self.latMin, forKey: latMinEncoderString)
        aCoder.encode(self.latMax, forKey: latMaxEncoderString)
        aCoder.encode(self.lonMin, forKey: lonMinEncoderString)
        aCoder.encode(self.lonMax, forKey: lonMaxEncoderString)
    }
}
