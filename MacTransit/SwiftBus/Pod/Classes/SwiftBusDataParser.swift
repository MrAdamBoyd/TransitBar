//
//  SwiftBusParser.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation
import SWXMLHash

class SwiftBusDataParser: NSObject {
    
    /**
    Creating all the transit agencies from the xml, calls the allAgenciesCompletion when done
    
    - parameter xml:    xml gotten from calling NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseAllAgenciesData(_ xml: XMLIndexer, completion: (_ agencies: [String: TransitAgency]) -> Void) {
        let agenciesXML:[XMLIndexer] = xml["body"].children
        var transitAgencies:[String : TransitAgency] = [:]
        
        //Creating all the agencies
        for agencyXML:XMLIndexer in agenciesXML {
            
            //If all the proper elements exist
            if let agencyTag = agencyXML.element!.attributes["tag"], let agencyTitle = agencyXML.element!.attributes["title"], let agencyRegion = agencyXML.element!.attributes["regionTitle"] {
                
                let newAgency:TransitAgency = TransitAgency(agencyTag: agencyTag, agencyTitle: agencyTitle, agencyRegion: agencyRegion)
                
                //Some agencies have a shortTitle
                if let agencyShortTitle = agencyXML.element!.attributes["shortTitle"] {
                    newAgency.agencyShortTitle = agencyShortTitle
                }
                
                transitAgencies[agencyTag] = newAgency
            }
            
        }
        
        completion(transitAgencies)
    }
    
    /**
    Creating all the TransitRoutes from the xml, calls allRoutesForAgencyCompletion when done
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseAllRoutesData(_ xml: XMLIndexer, completion: (_ agencyRoutes: [String: TransitRoute]) -> Void) {
        var transitRoutes:[String : TransitRoute] = [:]
        
        //Going through all lines and saving them
        for child in xml["body"].children {
            
            if let routeTag = child.element!.attributes["tag"], let routeTitle = child.element!.attributes["title"] {
                //If we can create all the routes
                let currentRoute:TransitRoute = TransitRoute(routeTag: routeTag, routeTitle: routeTitle)
                transitRoutes[routeTag] = currentRoute
            }
        }
        
        completion(transitRoutes)
    }
    
    /**
    Parsing the route configuration data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseRouteConfiguration(_ xml: XMLIndexer, completion:(_ route: TransitRoute?) -> Void) {
        let currentRoute = TransitRoute()
        var stopDirectionDict: [String : [String]] = [:]
        var allStopsDictionary: [String : TransitStop] = [:]
        
        var routeConfig:[String : String] = xml["body"]["route"].element!.attributes
        
        //Creating the route from the current information
        guard let routeTag = routeConfig["tag"], let routeTitle = routeConfig["title"], let latMin = routeConfig["latMin"], let latMax = routeConfig["latMax"], let lonMin = routeConfig["lonMin"], let lonMax = routeConfig["lonMax"], let routeColorHex = routeConfig["color"], let oppositeColorHex = routeConfig["oppositeColor"] else {
            //Couldn't get the route information, return
            completion(currentRoute)
            return
        }
        
        currentRoute.routeTag = routeTag
        currentRoute.routeTitle = routeTitle
        currentRoute.latMin = (latMin as NSString).doubleValue
        currentRoute.latMax = (latMax as NSString).doubleValue
        currentRoute.lonMin = (lonMin as NSString).doubleValue
        currentRoute.lonMax = (lonMax as NSString).doubleValue
        currentRoute.routeColor = routeColorHex
        currentRoute.oppositeColor = oppositeColorHex
        #if os(OSX)
        currentRoute.representedRouteColor = NSColor(rgba: "#" + routeColorHex)
        currentRoute.representedOppositeColor = NSColor(rgba: "#" + oppositeColorHex)
        #else
        currentRoute.representedRouteColor = UIColor(rgba: "#" + routeColorHex)
        currentRoute.representedOppositeColor = UIColor(rgba: "#" + oppositeColorHex)
        #endif
        
        let stopDirections:XMLIndexer = xml["body"]["route"]["direction"]
        
        for stopDirection in stopDirections {
            //For each direction, eg. "Inbound to downtown", "Inbound to Caltrain", "Outbound to Ocean Beach"
            if let currentDirection:String = stopDirection.element!.attributes["title"], let directionTag:String = stopDirection.element!.attributes["tag"] {
                
                stopDirectionDict[currentDirection] = []
                currentRoute.directionTagToName[directionTag] = currentDirection
                
                for child in stopDirection.children {
                    //For each stop per direction
                    
                    if let tag:String = child.element!.attributes["tag"] {
                        stopDirectionDict[currentDirection]?.append(tag)
                    }
                    
                }
                
            }
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        let stops = xml["body"]["route"]["stop"]
        
        //Going through the stops and creating TransitStop objects
        for stop in stops {
            if let routeTitle = xml["body"]["route"].element!.attributes["title"], let routeTag = xml["body"]["route"].element!.attributes["tag"], let stopTitle = stop.element!.attributes["title"], let stopTag = stop.element!.attributes["tag"], let stopLat = stop.element!.attributes["lat"], let stopLon = stop.element!.attributes["lon"] {
                let stop = TransitStop(routeTitle: routeTitle, routeTag: routeTag, stopTitle: stopTitle, stopTag: stopTag)
                stop.lat = (stopLat as NSString).doubleValue
                stop.lon = (stopLon as NSString).doubleValue
                
                allStopsDictionary[stopTag] = stop
            }
        }
        
        //Going through all stops IN ORDER and add them to an array of transit stops
        for stopDirection in stopDirectionDict.keys {
            //For each direction
            
            currentRoute.stopsOnRoute[stopDirection] = []
            
            for stopTag in stopDirectionDict[stopDirection]! {
                //For each stop per direction
                
                if let transitStop = allStopsDictionary[stopTag] {
                    //Getting the stop from the dictionary of all stops and adding it to the correct direction for the current TransitRoute
                    transitStop.direction = stopDirection
                    currentRoute.stopsOnRoute[stopDirection]!.append(transitStop)
                }
            }
            
        }
        
        completion(currentRoute)
    }
    
    /**
    Parsing the vehicle location data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseVehicleLocations(_ xml: XMLIndexer, completion: (_ locations:[String : [TransitVehicle]]) -> Void) {
        let vehicles = xml["body"]
        var dictionaryOfVehicles:[String : [TransitVehicle]] = [:]
        
        for vehicle in vehicles.children {
            let attributes = vehicle.element!.attributes
            
            if let vehicleID = attributes["id"], let directionTag = attributes["dirTag"], let lat = attributes["lat"], let lon = attributes["lon"], let secondsSinceLastReport = attributes["secsSinceReport"], let heading = attributes["heading"], let speedKmH = attributes["speedKmHr"] {
                //If all the proper attributes exist
                let newVehicle = TransitVehicle(vehicleID: vehicleID, directionTag: directionTag, lat: lat, lon: lon, secondsSinceReport: secondsSinceLastReport, heading: heading, speedKmH: speedKmH)
                
                //If there is a leading vehicle
                if let leadingVehicleId = attributes["leadingVehicleId"] {
                    newVehicle.leadingVehicleId = Int(leadingVehicleId)!
                }
                
                //Adding newVehicle to the dictionary if it hasn't been created
                if dictionaryOfVehicles[directionTag] == nil {
                    dictionaryOfVehicles[directionTag] = [newVehicle]
                } else {
                    dictionaryOfVehicles[directionTag]?.append(newVehicle)
                }
                
            }
        }
        
        completion(dictionaryOfVehicles)
    }
    
    func parseStationPredictions(_ xml: XMLIndexer, completion: (_ predictions: [String: [String: [TransitPrediction]]]) -> Void) {
        let predictions = xml["body"]
        var predictionDict:[String : [String : [TransitPrediction]]] = [:]
        
        //For each route that the user wants to get predictions for
        for route in predictions.children {
            if let routeTitle = route.element!.attributes["routeTag"] {
                predictionDict[routeTitle] = parsePredictions(route)
            }
        }
        
        completion(predictionDict)
    }
    
    /**
    Parsing the stop prediction data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseStopPredictions(_ xml: XMLIndexer, completion:(_ predictions: [String: [TransitPrediction]], _ messages: [String]) -> Void) {
        let predictions = xml["body"]["predictions"]
        var messageArray:[String] = []
        
        let predictionDict:[String : [TransitPrediction]] = parsePredictions(predictions)
        
        let messages = predictions["message"]
        
        for message in messages {
            //Going through the messages and adding them
            if let messageTitle = message.element!.attributes["text"] {
                messageArray.append(messageTitle)
            }
        }
    
        completion(predictionDict, messageArray)
    }
}

//Parses the predictions for one line in all directions at the stop
private func parsePredictions(_ predictionXML: XMLIndexer) -> [String: [TransitPrediction]] {
    var predictions:[String : [TransitPrediction]] = [:]
    
    //Getting all the predictions
    for direction in predictionXML.children {
        
        //Getting the direction name
        if let directionName = direction.element!.attributes["title"] {
            
            predictions[directionName] = []
            
            for prediction in direction.children {
                //Getting each individual prediction in minutes
                
                if let predictionInMinutes = Int((prediction.element?.attributes["minutes"])!), let predictionInSeconds = Int((prediction.element?.attributes["seconds"])!), let vehicleTag = Int((prediction.element?.attributes["vehicle"])!) {
                    //If all the elements exist
                    
                    let newPrediction = TransitPrediction(predictionInMinutes: predictionInMinutes, predictionInSeconds: predictionInSeconds, vehicleTag: vehicleTag)
                    
                    //Number of vehicles is optionally provided by the API
                    if let numberOfVechiles = prediction.element?.attributes["vehiclesInConsist"] {
                        newPrediction.numberOfVehicles = Int(numberOfVechiles)!
                    }
                    
                    predictions[directionName]?.append(newPrediction)
                }
            }
        }
    }
    
    return predictions
}
