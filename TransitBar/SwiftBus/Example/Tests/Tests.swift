//
//  SwiftBusTests.swift
//  SwiftBusTests
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import UIKit
import XCTest
import SwiftBus

class SwiftBusTests: XCTestCase {
    
    var agency = TransitAgency()
    var route = TransitRoute()
    var stopOB = TransitStop(routeTitle: "N-Judah", routeTag: "N", stopTitle: "Carl & Cole", stopTag: "3909")
    
    //This method is called before the invocation of each test method in the class.
    override func setUp() {
        
        //Creating agency
        let agency = TransitAgency()
        agency.agencyTag = "sf-muni"
        agency.agencyTitle = "San Francisco Muni"
        agency.agencyRegion = "California-Northern"
        
        //Creating route
        route.agencyTag = "sf-muni"
        route.routeTitle = "N-Judah"
        
        //Creating OB stop
        stopOB.predictions["Outbound to Ocean Beach"] = [TransitPrediction(predictionInMinutes: 1), TransitPrediction(predictionInMinutes: 2), TransitPrediction(predictionInMinutes: 3)]
        stopOB.predictions["Outbound to Ocean Beach via Downtown"] = [TransitPrediction(predictionInMinutes: 4), TransitPrediction(predictionInMinutes: 5), TransitPrediction(predictionInMinutes: 6)]
        
        route.stops["Outbound to Ocean Beach Via Downtown"] = [stopOB]
        
    }
    
    //This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    func testRouteGetStop() {
        if let _ = route.stop(forTag: "3909") {
            XCTAssert(true, "Stop is gotten properly")
        } else {
            XCTAssert(false, "Stop is not gotten properly")
        }
    }
    
    func testPredictionsInOrder() {
        if stopOB.allPredictions[0].predictionInSeconds < stopOB.allPredictions[1].predictionInSeconds {
            XCTAssert(true, "Sorted predictions are in order")
        } else {
            XCTAssert(false, "Sorted predictions are not in order")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
