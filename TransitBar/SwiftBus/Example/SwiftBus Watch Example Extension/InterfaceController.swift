//
//  InterfaceController.swift
//  SwiftBus Watch Example Extension
//
//  Created by Adam Boyd on 2017-02-02.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import SwiftBus

class InterfaceController: WKInterfaceController {

    @IBOutlet var timesLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func getTimesTapped() {
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
                
                self.timesLabel.setText("Times: \(predictionStrings)")
            }
            
        }
    }
}
