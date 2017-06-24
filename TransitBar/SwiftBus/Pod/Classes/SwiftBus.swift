//
//  SwiftBus.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

open class SwiftBus {
    
    open static let shared = SwiftBus()
    
    fileprivate var masterListTransitAgencies: [String: TransitAgency] = [:]
    
    fileprivate init() { }
    
    /*
    Calls that are pulled live each time
    Stop predictions
    Vehicle locations
    
    Calls that are not pulled live each time
    Agency list
    List of lines in an agency
    List of stops per line
    */
    
    /**
    Gets the list of agencies from the nextbus API or what is already in memory if getAgencies has been called before
    
    agencies.keys.array will return a list of the keys used
    agencies.values.array will return a list of TransitAgencies
    
    - parameter completion: Code that is called after the dictionary of agencies has loaded
        - parameter agencies:    Dictionary of agencyTags to TransitAgency objects
    */
    open func transitAgencies(_ completion: ((_ agencies: [String: TransitAgency]) -> Void)?) {
        
        if self.masterListTransitAgencies.count > 0 {
            completion?(self.masterListTransitAgencies)
            
        } else {
            //We need to load the transit agency data
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self.masterListTransitAgencies = agencies

                completion?(agencies)
            })
            
        }
    }
    
    /**
     Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
     
     - parameter agency:       Agency object
     - parameter completion:   Code that is called after everything has loaded
        - parameter agency:    Optional TransitAgency object that contains the routes
     */
    open func configuration(forAgency agency: TransitAgency?, completion: ((_ agency: TransitAgency?) -> Void)?) {
        self.configuration(forAgencyTag: agency?.agencyTag, completion: completion)
    }
    
    /**
    Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
    
    - parameter agency:       Agency object
    - parameter completion:   Code that is called after everything has loaded
        - parameter agency:   Optional TransitAgency object that contains the routes
    */
    open func configuration(forAgencyTag agencyTag: String?, completion: ((_ agency: TransitAgency?) -> Void)?) {
        
        guard let agencyTag = agencyTag else {
            //If the agency tag doesn't exist, exit early
            completion?(nil)
            return
        }
        
        //Getting all the agencies
        self.transitAgencies({(innerAgencies:[String : TransitAgency]) -> Void in
            
            guard let currentAgency = innerAgencies[agencyTag] else {
                //The agency doesn't exist, return an empty dictionary
                completion?(nil)
                return
            }
                
            //The agency exists & we need to load the transit agency data
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestAllRouteData(agencyTag, completion: {(agencyRoutes:[String : TransitRoute]) -> Void in
                
                //Adding the agency to the route
                for route in agencyRoutes.values {
                    route.agencyTag = agencyTag
                }
                
                //Saving the routes for the agency
                currentAgency.agencyRoutes = agencyRoutes
                
                //Return the transitRoutes for the agency
                completion?(currentAgency)
            })
        })

    }
    
    /**
     Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
     
     - parameter agencyTag:    the transit agency that this will download the routes for
     - parameter completion:   Code that is called after all the data has loaded
        - parameter routes:    Dictionary of routeTags to TransitRoute objects
     */
    open func routes(forAgency agency: TransitAgency?, completion: ((_ routes: [String: TransitRoute]) -> Void)?) {
        self.routes(forAgencyTag: agency?.agencyTag, completion: completion)
    }
    
    /**
    Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
    
    - parameter agencyTag: the transit agency that this will download the routes for
    - parameter completion:   Code that is called after all the data has loaded
        - parameter routes:  Dictionary of routeTags to TransitRoute objects
    */
    open func routes(forAgencyTag agencyTag: String?, completion: ((_ routes: [String: TransitRoute]) -> Void)?) {
        
        self.configuration(forAgencyTag: agencyTag) { agency in
            
            guard let currentAgency = agency else {
                //The agency doesn't exist, return an empty dictionary
                completion?([:])
                return
            }
            
            completion?(currentAgency.agencyRoutes)
        }
    }
    
    /**
     Gets the TransitStop object that contains a list of TransitStops in each direction and the location of each of those stops
     
     - parameter route:        TransitRoute object to download information for
     - parameter completion:   the code that gets called after the data is loaded
        - parameter route:     TransitRoute object that contains the configuration requested
     */

    open func configuration(forRoute route: TransitRoute?, completion: ((_ route: TransitRoute?) -> Void)?) {
        self.configuration(forRouteTag: route?.routeTag, withAgencyTag: route?.agencyTag, completion: completion)
    }
    
    /**
    Gets the TransitStop object that contains a list of TransitStops in each direction and the location of each of those stops
    
    - parameter routeTag:  the route that is being looked up
    - parameter agencyTag: the agency for which the route is being looked up
    - parameter completion:   the code that gets called after the data is loaded
        - parameter route:   TransitRoute object that contains the configuration requested
    */
    open func configuration(forRouteTag routeTag: String?, withAgencyTag agencyTag: String?, completion: ((_ route: TransitRoute?) -> Void)?) {
        
        //Making sure the route and agency aren't nil
        guard let routeTag = routeTag, let agencyTag = agencyTag else {
            completion?(nil)
            return
        }
        
        //Getting all the routes for the agency
        self.routes(forAgencyTag: agencyTag) { transitRoutes in
            
            guard transitRoutes[routeTag] != nil else {
                //If the route doesn't exist, return nil
                completion?(nil)
                return
            }
            
            //If the route exists, get the route configuration
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestRouteConfiguration(routeTag, fromAgency: agencyTag, completion: {(route:TransitRoute?) -> Void in
                
                //If there were no problems getting the route
                if let transitRoute = route as TransitRoute! {
                    
                    //Applying agencyTag to all TransitStop subelements
                    for routeDirection in transitRoute.stops.values {
                        for stop in routeDirection {
                            stop.agencyTag = agencyTag
                        }
                    }
                    
                    self.masterListTransitAgencies[agencyTag]?.agencyRoutes[routeTag] = transitRoute
                    
                    //Call the closure
                    completion?(transitRoute)
                    
                } else {
                    //There was a problem, return nil
                    completion?(nil)
                }
            })
            
        }
    }
    
    /**
     Gets the route configuration for all routes
     
     - parameter routes:        routes to get the configuration for. Do not have to be in the same agency
     - parameter completion:   the code that gets called after all routes have been loaded
     - parameter routes: array of TransitRoute objects. Objects can be accessed with routes[routeTag]
     */
    open func configurations(forMultipleRoutes routes: [TransitRoute], completion: ((_ routes: [TransitRoute]) -> Void)?) {
        var dictionary: [RouteTag: AgencyTag] = [:]
        for route in routes {
            dictionary[route.routeTag] = route.agencyTag
        }
        self.configurations(forMultipleRoutes: dictionary, completion: completion)
    }
    
    
    /**
     Gets the route configuration for all routeTags provided. All routes must come from the same agency
     
     - parameter routeTags: array of routes that will be looked up.
     - parameter agencyTag: the agency for which the route is being looked up
     - parameter completion:   the code that gets called after all routes have been loaded
     - parameter routes: dictionary of TransitRoute objects. Objects can be accessed with routes[routeTag]
     */
    open func configurations(forMultipleRouteTags routeTags: [RouteTag], withAgencyTag agencyTag: String, completion: ((_ routes: [TransitRoute]) -> Void)?) {
        var dictionary: [RouteTag: AgencyTag] = [:]
        for routeTag in routeTags {
            dictionary[routeTag] = agencyTag
        }
        self.configurations(forMultipleRoutes: dictionary, completion: completion)
    }
    
    /**
     Gets the route configuration for all routeTags provided.
     
     - parameter routeTags:     dictionary of route tags to agency tags
     - parameter completion:    the code that gets called after all routes have been loaded
     - parameter routes:        array of TransitRoute objects. Objects can be accessed with routes[routeTag]
     */
    open func configurations(forMultipleRoutes routeAgencyPairs: [RouteTag: AgencyTag], completion: ((_ routes: [TransitRoute]) -> Void)?) {
        let group = DispatchGroup()
        var routeArray: [TransitRoute] = []
        
        //Going through each route tag
        for pair in routeAgencyPairs {
            
            //Getting the route configuration
            group.enter()
            self.configuration(forRouteTag: pair.key, withAgencyTag: pair.value) { route in
                
                DispatchQueue.main.async {
                    if let route = route {
                        routeArray.append(route)
                    }
                    group.leave()
                }
            }
            
        }
        
        group.notify(queue: .main) {
            completion?(routeArray)
        }
    }
    
    /**
     Gets the vehicle locations for a particular route
     
     - parameter route:         Route to get locations for
     - parameter completion:    Code that gets called after the call has completed
     - parameter route:         Optional TransitRoute object that contains the vehicle locations
     */
    open func vehicleLocations(forRoute route: TransitRoute?, completion: ((_ route: TransitRoute?) -> Void)?) {
        self.vehicleLocations(forRouteTag: route?.routeTag, forAgency: route?.agencyTag, completion: completion)
    }
    
    /**
    Gets the vehicle locations for a particular route
    
    - parameter routeTag:  Tag of the route we are looking at
    - parameter agencyTag: Tag of the agency where the line is
    - parameter completion:   Code that gets called after the call has completed
        - parameter route:   Optional TransitRoute object that contains the vehicle locations
    */
    open func vehicleLocations(forRouteTag routeTag: String?, forAgency agencyTag: String?, completion: ((_ route: TransitRoute?) -> Void)?) {
        
        guard let routeTag = routeTag, let agencyTag = agencyTag else {
            completion?(nil)
            return
        }
        
        //Getting the route configuration for the route
        self.configuration(forRouteTag: routeTag, withAgencyTag: agencyTag) { route in
            
            guard let currentRoute = route as TransitRoute! else {
                //There's been a problem, return nil
                completion?(nil)
                return
            }
                
            //Get the route configuration
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestVehicleLocationData(onRoute: routeTag, withAgency: agencyTag, completion:{(locations: [String : [TransitVehicle]]) -> Void in
                
                currentRoute.vehiclesOnRoute = []
                
                for vehiclesInDirection in locations.values {
                    currentRoute.vehiclesOnRoute += vehiclesInDirection
                }
                
                completion?(currentRoute)
                
            })
                
        }
    }
    
    open func stationPredictions(forStop stop: TransitStop?, forRoutes routes: [TransitRoute?], completion: ((_ station: TransitStation?) -> Void)?) {
        guard let stop = stop else {
            completion?(nil)
            return
        }
        self.stationPredictions(forStopTag: stop.stopTag, forRoutes: routes.flatMap({ $0?.routeTag }), withAgencyTag: stop.agencyTag, completion: completion)
    }
    
    /**
    Returns the predictions for a certain stop on a route, returns nil if the stop isn't on the route, also gets all the messages for that stop
    
    - parameter stopTag:   Tag of the stop
    - parameter routeTags: Tags of the routes that serve the stop
    - parameter agencyTag: Tag of the agency
    - parameter completion:   Code that is called after the result is gotten, route will be nil if stop doesn't exist
        - parameter stop:    Optional TransitStation that contains the predictions
    */
    open func stationPredictions(forStopTag stopTag: String, forRoutes routeTags: [String], withAgencyTag agencyTag: String, completion: ((_ station: TransitStation?) -> Void)?) {
        
        //Getting the configuration for all routes
        self.configurations(forMultipleRouteTags: routeTags, withAgencyTag: agencyTag) { routes in
            
            //Only use the routes that exist
            let existingRouteTags = routes.map({ $0.routeTag })
            
            guard existingRouteTags.count > 0 else {
                completion?(nil)
                return
            }
            
            //Get the predictions
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStationPredictionData(stopTag, forRoutes: existingRouteTags, withAgency: agencyTag) { predictions in

                let currentStation = TransitStation()
                currentStation.stopTag = stopTag
                currentStation.agencyTag = agencyTag
                currentStation.routesAtStation = routes
                currentStation.stopTitle = routes[0].stop(forTag: stopTag)!.stopTitle //Safe, we know all these exist
                currentStation.predictions = predictions

                //Saving the predictions in the TransitStop objects for all TransitRoutes
                for route in routes {
                    if let stop = route.stop(forTag: stopTag) {
                        stop.predictions = predictions[route.routeTag]!
                    }
                }
                
                completion?(currentStation)
            }
            
        }
    }
    
    
    /// Gets predictions for an array of stops. MUST BE IN THE SAME AGENCY
    ///
    /// - Parameter stops: stops to get predictions for
    open func stopPredictions(forStops stops: [TransitStop], completion: ((_ stops: [TransitStop]) -> Void)?) {
        let agencyTag = stops[0].agencyTag
        
        var dictionary: [RouteTag: StopTag] = [:]
        for stop in stops {
            dictionary[stop.routeTag] = stop.stopTag
        }
        
        self.stopPredictions(forStops: dictionary, inAgency: agencyTag, completion: completion)
    }
    
    /// Gets predictions for an array of stop tags and route tags. Must have the same number
    ///
    /// - Parameters:
    ///   - stopTags: array of stop tags
    ///   - routeTags: corresponding array of route tags
    ///   - agencyTag: agency tag
    open func stopPredictions(forStopTags stopTags: [StopTag], onRouteTags routeTags: [RouteTag], inAgency agencyTag: String, completion: ((_ stops: [TransitStop]) -> Void)?) {
        var dictionary: [RouteTag: StopTag] = [:]
        
        guard stopTags.count == routeTags.count, stopTags.count > 0 else {
            completion?([])
            return
        }
        
        for (index, stop) in stopTags.enumerated() {
            dictionary[stop] = routeTags[index]
        }
        
        self.stopPredictions(forStops: dictionary, inAgency: agencyTag, completion: completion)
    }
    
    
    /// Gets predictions for multiple stops with multiple routes. MUST BE IN THE SAME AGENCY
    ///
    /// - Parameters:
    ///   - stopTags: dictionary of all routes to stops
    ///   - agencyTag: agency where all routes/stops are
    open func stopPredictions(forStops stopRoutePairs: [StopTag: RouteTag], inAgency agencyTag: String, completion: ((_ stops: [TransitStop]) -> Void)?) {
        
        let stopTags = stopRoutePairs.map { $0.key }
        let routeTags = stopRoutePairs.map { $0.value }
        
        self.configurations(forMultipleRouteTags: routeTags, withAgencyTag: agencyTag) { routes in
            
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestMultipleStopPredictionData(stopTags, forRoutes: routeTags, withAgency: agencyTag) { allPredictionData in
                
                var finalStops: [TransitStop] = []
                
                for predictionGroup in allPredictionData {
                    
                    //Going through each route and organizing the prediction data
                    
                    let routeTag = predictionGroup.key
                    let predictionForRoute = predictionGroup.value
                    
                    guard let route = routes.filter({ $0.routeTag == routeTag }).first else { break }
                    
                    for predictionForStop in predictionForRoute {
                        
                        //Going through all stops that were requested per route
                        
                        let stopTag = predictionForStop.key
                        
                        if let stop = route.stop(forTag: stopTag) {
                            var bucketPredictions: [String: [TransitPrediction]] = [:]
                            
                            //This can be easily done in swift 4, need to switch to that
                            for prediction in predictionForStop.value {
                                
                                //For each stop, make sure that all directions are taken care of
                                //For example, at a stop, the same bus can go to 2 different locations
                                
                                if let _ = bucketPredictions[prediction.directionName] {
                                    bucketPredictions[prediction.directionName]?.append(prediction)
                                } else {
                                    bucketPredictions[prediction.directionName] = [prediction]
                                }
                                
                            }
                            
                            stop.predictions = bucketPredictions
                            finalStops.append(stop)
                        }
                        print("LOL!")
                    }
                    
                }
                
                completion?(finalStops)
                
            }
        }
        
    }
    
    open func stopPredictions(forStop stop: TransitStop?, completion: ((_ stop: TransitStop?) -> Void)?) {
        self.stopPredictions(forStopTag: stop?.stopTag, onRouteTag: stop?.routeTag, withAgencyTag: stop?.agencyTag, completion: completion)
    }
    
    /**
    Returns the predictions for a certain stop on a route, returns nil if the stop isn't on the route, also gets all the messages for that stop
    
    - parameter stopTag:   Tag of the stop
    - parameter routeTag:  Tag of the route
    - parameter agencyTag: Tag of the agency
    - parameter completion:   Code that is called after the result is gotten, route will be nil if stop doesn't exist
        - parameter stop:    Optional TransitStop object that contains the predictions
    */
    open func stopPredictions(forStopTag stopTag: String?, onRouteTag routeTag: String?, withAgencyTag agencyTag: String?, completion: ((_ stop: TransitStop?) -> Void)?) {
        
        guard let stopTag = stopTag, let routeTag = routeTag, let agencyTag = agencyTag else {
            completion?(nil)
            return
        }
        
        //Getting the route configuration for the route
        self.configuration(forRouteTag: routeTag, withAgencyTag: agencyTag) { route in
        
            if let currentRoute = route as TransitRoute! {
                guard let currentStop = currentRoute.stop(forTag: stopTag) else {
                    //This stop isn't in the route that was provided
                    completion?(nil)
                    return
                }
                
                //Get the route configuration
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestStopPredictionData(stopTag, onRoute: routeTag, withAgency: agencyTag, completion: {(predictions:[String : [TransitPrediction]], messages:[TransitMessage]) -> Void in
                    
                    currentStop.predictions = predictions
                    currentStop.messages = messages
                    
                    //Call the closure
                    completion?(currentStop)
                    
                })
                    
            } else {
                //There's been a problem, return nil
                completion?(nil)
            }
        }
    }
    
    /**
    This method clears the transitAgency dictionary from all TransitAgency objects. Because it is formatted as a tree, this clears all information for all routes and stops as well. Any function calls will download new information.
    */
    open func clearSavedData() {
        masterListTransitAgencies = [:]
    }
}
