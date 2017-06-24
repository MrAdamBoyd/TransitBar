//
//  RequestURLs.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

let allAgenciesURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=agencyList"
let allRoutesURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a="
let routeConfigURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a="
let vehicleLocationsURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a="
let multiplePredictionsURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a="
let stopPredictionsURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a="
let routeURLSegment = "&r="
let stopURLSegment = "&s="
let multiStopURLSegment = "&stops="
