//
//  ConnectionHandler.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import SWXMLHash

enum RequestType:Int {
    case noRequest = 0, allAgencies, allRoutes, routeConfiguration, stopPredictions, stationPredictions, vehicleLocations
}

class SwiftBusConnectionHandler: NSObject, NSURLConnectionDataDelegate {
    
    var currentRequestType:RequestType = .noRequest
    var connection:NSURLConnection?
    var xmlData = NSMutableData()
    var xmlString:String = ""
    var allAgenciesCompletion:(([String : TransitAgency]) -> Void)!
    var allRoutesForAgencyCompletion:(([String : TransitRoute]) -> Void)!
    var routeConfigCompletion:((TransitRoute?) -> Void)!
    var stationPredictionsCompletion:(([String : [String : [TransitPrediction]]]) -> Void)!
    var stopPredictionsCompletion:(([String : [TransitPrediction]], [TransitMessage]) -> Void)!
    var vehicleLocationsCompletion:(([String : [TransitVehicle]]) -> Void)!
    
    //MARK: Requesting data
    
    func requestAllAgencies(_ completion: @escaping (_ agencies: [String: TransitAgency]) -> Void) {
        currentRequestType = .allAgencies
        
        allAgenciesCompletion = completion
        
        startConnection(allAgenciesURL)
    }
    
    //Request data for all lines
    func requestAllRouteData(_ agencyTag: String, completion: @escaping (_ agencyRoutes: [String: TransitRoute]) -> Void) {
        currentRequestType = .allRoutes
        
        allRoutesForAgencyCompletion = completion
        
        startConnection(allRoutesURL + agencyTag)
    }
    
    func requestRouteConfiguration(_ routeTag: String, fromAgency agencyTag: String, completion: @escaping (_ route: TransitRoute?) -> Void) {
        currentRequestType = .routeConfiguration
        
        routeConfigCompletion = completion
        
        startConnection(routeConfigURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestVehicleLocationData(onRoute routeTag: String, withAgency agencyTag: String, completion:@escaping (_ locations: [String: [TransitVehicle]]) -> Void) {
        currentRequestType = .vehicleLocations
        
        vehicleLocationsCompletion = completion
        
        startConnection(vehicleLocationsURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestStationPredictionData(_ stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        currentRequestType = .stationPredictions
        
        stationPredictionsCompletion = completion
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for tag in routeTags {
            multiplePredictionString += multiStopURLSegment + tag + "|" + stopTag
        }
        
        startConnection(multiplePredictionString)
    }
    
    func requestStopPredictionData(_ stopTag: String, onRoute routeTag: String, withAgency agencyTag:String, completion: @escaping (_ predictions: [String: [TransitPrediction]], _ messages: [TransitMessage]) -> Void) {
        currentRequestType = .stopPredictions
        
        stopPredictionsCompletion = completion
        
        startConnection(stopPredictionsURL + agencyTag + routeURLSegment + routeTag + stopURLSegment + stopTag)
    }
    
    func requestMultipleStopPredictionData(_ stopTags: [String], forRoutes routeTags: [String], withAgency agencyTag: String, completion: @escaping (_ predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        currentRequestType = .stationPredictions
        
        stationPredictionsCompletion = completion
        
        let smallestArrayCount = min(stopTags.count, routeTags.count)
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for index in 0..<smallestArrayCount {
            multiplePredictionString.append("&stops=\(routeTags[index])|\(stopTags[index])")
        }
        
        startConnection(multiplePredictionString)
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    - parameter requestURL: string of the url that is being requested
    */
    fileprivate func startConnection(_ requestURL:String) {
        xmlData = NSMutableData()
        let optionalURL:URL? = URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        if let url = optionalURL as URL! {
            let urlRequest:URLRequest = URLRequest(url: url)
            connection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        } else {
            //TODO: Alert user via closure that something bad happened
        }
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        xmlString = NSString(data: xmlData as Data, encoding: String.Encoding.utf8.rawValue) as! String
        let xml = SWXMLHash.parse(xmlString)
        let parser = SwiftBusDataParser()
        
        switch currentRequestType {
        case .allAgencies:
            parser.parseAllAgenciesData(xml, completion: allAgenciesCompletion)
        case .allRoutes:
            parser.parseAllRoutesData(xml, completion: allRoutesForAgencyCompletion)
        case .routeConfiguration:
            parser.parseRouteConfiguration(xml, completion: routeConfigCompletion)
        case .vehicleLocations:
            parser.parseVehicleLocations(xml, completion: vehicleLocationsCompletion)
        case .stationPredictions:
            parser.parseStationPredictions(xml, completion: stationPredictionsCompletion)
        default:
            //Stop predictions
            parser.parseStopPredictions(xml, completion: stopPredictionsCompletion)
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        
        xmlData.append(data)
    }
}
