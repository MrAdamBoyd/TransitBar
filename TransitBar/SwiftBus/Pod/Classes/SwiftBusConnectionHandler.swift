//
//  ConnectionHandler.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import SWXMLHash

enum RequestType {
    case allAgencies(([String: TransitAgency]) -> Void)
    case allRoutes(([String : TransitRoute]) -> Void)
    case routeConfiguration((TransitRoute?) -> Void)
    case stopPredictions(([String : [TransitPrediction]], [TransitMessage]) -> Void)
    case stationPredictions(([String : [String : [TransitPrediction]]]) -> Void)
    case vehicleLocations(([String : [TransitVehicle]]) -> Void)
}

class SwiftBusConnectionHandler: NSObject {
    
    //MARK: Requesting data
    
    func requestAllAgencies(_ completion: @escaping (_ agencies: [String: TransitAgency]) -> Void) {
        
        startConnection(allAgenciesURL, with: .allAgencies(completion))
    }
    
    //Request data for all lines
    func requestAllRouteData(_ agencyTag: String, completion: @escaping (_ agencyRoutes: [String: TransitRoute]) -> Void) {
        
        startConnection(allRoutesURL + agencyTag, with: .allRoutes(completion))
    }
    
    func requestRouteConfiguration(_ routeTag: String, fromAgency agencyTag: String, completion: @escaping (_ route: TransitRoute?) -> Void) {
        
        startConnection(routeConfigURL + agencyTag + routeURLSegment + routeTag, with: .routeConfiguration(completion))
    }
    
    func requestVehicleLocationData(onRoute routeTag: String, withAgency agencyTag: String, completion:@escaping (_ locations: [String: [TransitVehicle]]) -> Void) {
        
        startConnection(vehicleLocationsURL + agencyTag + routeURLSegment + routeTag, with: .vehicleLocations(completion))
    }
    
    func requestStationPredictionData(_ stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for tag in routeTags {
            multiplePredictionString += multiStopURLSegment + tag + "|" + stopTag
        }
        
        startConnection(multiplePredictionString, with: .stationPredictions(completion))
    }
    
    func requestStopPredictionData(_ stopTag: String, onRoute routeTag: String, withAgency agencyTag:String, completion: @escaping (_ predictions: [String: [TransitPrediction]], _ messages: [TransitMessage]) -> Void) {
        
        startConnection(stopPredictionsURL + agencyTag + routeURLSegment + routeTag + stopURLSegment + stopTag, with: .stopPredictions(completion))
    }
    
    func requestMultipleStopPredictionData(_ stopTags: [String], forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        
        let smallestArrayCount = min(stopTags.count, routeTags.count)
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for index in 0..<smallestArrayCount {
            multiplePredictionString.append("&stops=\(routeTags[index])|\(stopTags[index])")
        }
        
        startConnection(multiplePredictionString, with: .stationPredictions(completion))
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    - parameter requestURL: string of the url that is being requested
    */
    fileprivate func startConnection(_ requestURL:String, with requestType: RequestType) {
        let url = URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        if let url = url {
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let dataTask = session.dataTask(with: url) { data, response, error in
                let xmlString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                let xml = SWXMLHash.parse(xmlString)
                let parser = SwiftBusDataParser()
                
                switch requestType {
                case .allAgencies(let closure):
                    parser.parseAllAgenciesData(xml, completion: closure)
                case .allRoutes(let closure):
                    parser.parseAllRoutesData(xml, completion: closure)
                case .routeConfiguration(let closure):
                    parser.parseRouteConfiguration(xml, completion: closure)
                case .vehicleLocations(let closure):
                    parser.parseVehicleLocations(xml, completion: closure)
                case .stationPredictions(let closure):
                    parser.parseStationPredictions(xml, completion: closure)
                case .stopPredictions(let closure):
                    parser.parseStopPredictions(xml, completion: closure)
                }
            }
                
            dataTask.resume()
        } else {
            //TODO: Alert user via closure that something bad happened
        }
    }
}
