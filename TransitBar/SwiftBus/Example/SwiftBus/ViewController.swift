//
//  ViewController.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import UIKit
import SwiftBus

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func agencyListTouched(_ sender: AnyObject) {
        SwiftBus.shared.transitAgencies() { (agencies: [String: TransitAgency]) -> Void in
            let agenciesString = "Number of agencies loaded: \(agencies.count)"
            let agencyNamesString = agencies.map({_, agency in "\(agency.agencyTitle)"})
            
            print("\n-----")
            print(agenciesString)
            print(agencyNamesString)
            
            self.showAlertControllerWithTitle(agenciesString, message: "\(agencyNamesString)")
        }
    }

    
    @IBAction func routesForAgencyTouched(_ sender: AnyObject) {
        //Alternative:
        //var agency = TransitAgency(agencyTag: "sf-muni")
        //agency.download({(success:Bool, agency:TransitAgency) -> Void in
        SwiftBus.shared.routes(forAgencyTag: "sf-muni") { routes in
            let agencyString = "Number of routes loaded for SF MUNI: \(routes.count)"
            let routeNamesString = routes.map({_, route in "\(route.routeTitle)"})
            
            print("\n-----")
            print(agencyString)
            print(routeNamesString)
            
            self.showAlertControllerWithTitle(agencyString, message: "\(routeNamesString)")
        }
        
    }
    
    @IBAction func routeConfigurationTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
        SwiftBus.shared.configuration(forRouteTag: "5R", withAgencyTag: "sf-muni") { route in
            //If the route exists
            guard let route = route else { return }
            
            let routeCongigMessage = "Route config for route \(route.routeTitle)"
            
            let stops = Array(route.stops.values)
            let numberOfStopsMessage = "Number of stops on route in one direction: \(stops[0].count)"

            print("\n-----")
            print(routeCongigMessage)
            print(numberOfStopsMessage)
            
            self.showAlertControllerWithTitle(routeCongigMessage, message: numberOfStopsMessage)
            
        }
        
    }
    
    @IBAction func vehicleLocationsTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getVehicleLocations({(success:Bool, vehicles:[TransitVehicle]) -> Void in
        SwiftBus.shared.vehicleLocations(forRouteTag: "N", forAgency: "sf-muni") { route in
            
            guard let route = route else { return }
            
            let vehicleTitleMessage = "\(route.vehiclesOnRoute.count) vehicles on route N Judah"
            let messageString = "Example vehicle:Vehcle ID: \(route.vehiclesOnRoute[0].vehicleId), \(route.vehiclesOnRoute[0].speedKmH) Km/h, \(route.vehiclesOnRoute[0].lat), \(route.vehiclesOnRoute[0].lon), seconds since report: \(route.vehiclesOnRoute[0].secondsSinceReport)"
            
            print("\n-----")
            print(vehicleTitleMessage)
            print(messageString)
            
            self.showAlertControllerWithTitle(vehicleTitleMessage, message: messageString)
        }
        
    }

    @IBAction func stationPredictionsTouched(_ sender: AnyObject) {
        SwiftBus.shared.stationPredictions(forStopTag: "5726", forRoutes: ["KT", "L", "M"], withAgencyTag: "sf-muni") { station in
            if let transitStation = station as TransitStation! {
                let lineTitles = "Prediction for lines: \(transitStation.routesAtStation.map({"\($0.routeTitle)"}))"
                let predictionStrings = "Predictions at stop \(transitStation.allPredictions.map({$0.predictionInMinutes}))"
                
                print("\n-----")
                print("Station: \(transitStation.stopTitle)")
                print(lineTitles)
                print(predictionStrings)
                
                self.showAlertControllerWithTitle(lineTitles, message: "\(predictionStrings)")
            }
        }
    }
    
    
    @IBAction func stopPredictionsTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getStopPredictionsForStop("3909", completion: {(success:Bool, predictions:[String : [TransitPrediction]]) -> Void in
        SwiftBus.shared.stopPredictions(forStopTag: "3909", onRouteTag: "N", withAgencyTag: "sf-muni") { stop in
            
            //If the stop and route exists
            if let transitStop = stop as TransitStop! {
                let predictionStrings:[Int] = transitStop.allPredictions.map({$0.predictionInMinutes})
                
                print("\n-----")
                print("Stop: \(transitStop.stopTitle)")
                print("Predictions at stop \(predictionStrings) mins")
                
                self.showAlertControllerWithTitle("Stop Predictions for stop \(transitStop.stopTitle)", message: "\(predictionStrings)")
            }
            
        }
        
    }
    
    @IBAction func multiPredictionsTouched(_ sender: Any) {
        SwiftBus.shared.stopPredictions(forStopTags: ["7252", "6721", "5631", "6985"], onRouteTags: ["N", "31", "43", "43"], inAgency: "sf-muni") { stops in
            var stopString = ""
            for stop in stops {
                stopString += "Stop \(stop.stopTitle) on route \(stop.routeTitle): \(stop.allPredictions.map({$0.predictionInMinutes}))\n\n"
            }
            
            print("\n-----")
            print("\(stopString)")
            
            self.showAlertControllerWithTitle("Multi Stop Predictions", message: "\(stopString)")
        }
    }
    
    func showAlertControllerWithTitle(_ title: String, message: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

