//
//  ConnectionHandler.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation
import SWXMLHash

enum SwiftBusRequest {
    case allAgencies((SwiftBusResult<[String: TransitAgency]>) -> Void)
    case allRoutes((SwiftBusResult<[String : TransitRoute]>) -> Void)
    case routeConfiguration((SwiftBusResult<TransitRoute>) -> Void)
    case stopPredictions((SwiftBusResult<(predictions: [String : [TransitPrediction]], messages: [TransitMessage])>) -> Void)
    case stationPredictions((SwiftBusResult<[String: [String: [TransitPrediction]]]>) -> Void)
    case vehicleLocations((SwiftBusResult<[String: [TransitVehicle]]>) -> Void)
    
    func passErrorToClosure(_ error: Error) {
        switch self {
        case .allAgencies(let closure):
            closure(.error(error))
        case .allRoutes(let closure):
            closure(.error(error))
        case .routeConfiguration(let closure):
            closure(.error(error))
        case .vehicleLocations(let closure):
            closure(.error(error))
        case .stationPredictions(let closure):
            closure(.error(error))
        case .stopPredictions(let closure):
            closure(.error(error))
        }
    }
}

class SwiftBusConnectionHandler: NSObject {
    
    //MARK: Requesting data
    
    func requestAllAgencies(_ completion: @escaping (_ agencies: SwiftBusResult<[String: TransitAgency]>) -> Void) {
        
        startConnection(allAgenciesURL, with: .allAgencies(completion))
    }
    
    //Request data for all lines
    func requestAllRouteData(_ agencyTag: String, completion: @escaping (_ agencyRoutes: SwiftBusResult<[String: TransitRoute]>) -> Void) {
        
        startConnection(allRoutesURL + agencyTag, with: .allRoutes(completion))
    }
    
    func requestRouteConfiguration(_ routeTag: String, fromAgency agencyTag: String, completion: @escaping (_ route: SwiftBusResult<TransitRoute>) -> Void) {
        
        startConnection(routeConfigURL + agencyTag + routeURLSegment + routeTag, with: .routeConfiguration(completion))
    }
    
    func requestVehicleLocationData(onRoute routeTag: String, withAgency agencyTag: String, completion: @escaping (_ locations: SwiftBusResult<[String: [TransitVehicle]]>) -> Void) {
        
        startConnection(vehicleLocationsURL + agencyTag + routeURLSegment + routeTag, with: .vehicleLocations(completion))
    }
    
    func requestStationPredictionData(_ stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: SwiftBusResult<PredictionGroup>) -> Void) {
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for tag in routeTags {
            multiplePredictionString += multiStopURLSegment + tag + "|" + stopTag
        }
        
        startConnection(multiplePredictionString, with: .stationPredictions(completion))
    }
    
    func requestStopPredictionData(_ stopTag: String, onRoute routeTag: String, withAgency agencyTag:String, completion: @escaping (_ predictions: SwiftBusResult<(predictions: [DirectionName: [TransitPrediction]], messages: [TransitMessage])>) -> Void) {
        
        startConnection(stopPredictionsURL + agencyTag + routeURLSegment + routeTag + stopURLSegment + stopTag, with: .stopPredictions(completion))
    }
    
    func requestMultipleStopPredictionData(_ stopTags: [String], forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: SwiftBusResult<PredictionGroup>) -> Void) {
        
        let smallestArrayCount = min(stopTags.count, routeTags.count)
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for index in 0..<smallestArrayCount {
            multiplePredictionString.append("\(multiStopURLSegment)\(routeTags[index])|\(stopTags[index])")
        }
        
        startConnection(multiplePredictionString, with: .stationPredictions(completion))
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    - parameter requestURL: string of the url that is being requested
    */
    fileprivate func startConnection(_ requestURL:String, with request: SwiftBusRequest) {
        let url = URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        if let url = url {
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let dataTask = session.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    request.passErrorToClosure(error!)
                    return
                }
                
                let xmlString = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue)! as String
                let xml = SWXMLHash.parse(xmlString)
                let parser = SwiftBusDataParser()
                
                parser.startParsing(xml, request: request)
            }
                
            dataTask.resume()
            
            session.finishTasksAndInvalidate()
            
        } else {
            request.passErrorToClosure(SwiftBusError.error(with: .malformedURL))
        }
    }
}
