//
//  MMBXmlParser.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-20.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa
import SWXMLHash

enum RequestType:Int {
    case NoRequest = 0, AllLines, LineDefinition, StopPredictions
}

class MMBXmlParser: NSObject, NSURLConnectionDataDelegate {
    static let sharedParser = MMBXmlParser()
    
    var delegate: MMBXmlParserDelegate?
    
    private var currentRequestType:RequestType = .NoRequest
    private var connection:NSURLConnection?
    var xmlData:NSMutableData?
    var xmlString:String = ""
    var indexOfLine:Int?
    var sender:AnyObject?
    var transitStop:TransitStop?
    
    //Private init for singleton
    //private init() { }
    
    //Request data for all lines
    func requestAllLineData() {
        xmlData = NSMutableData()
        currentRequestType = .AllLines
        let allLinesURL = NSURL(string: kMMBAllLinesURL)
        
        let allLinesURLRequest = NSURLRequest(URL: allLinesURL!)
        connection = NSURLConnection(request: allLinesURLRequest, delegate: self, startImmediately: true)
    }
    
    func requestLineDefinitionData(line:String, indexOfLine:Int, sender:AnyObject) {
        xmlData = NSMutableData()
        currentRequestType = .LineDefinition
        self.indexOfLine = indexOfLine
        self.sender = sender
        
        let completeLineDefinitionURL = kMMBLineDefinitionURL + line
        let lineDefinitionURL = NSURL(string: completeLineDefinitionURL)
        let lineDefinitionURLRequest = NSURLRequest(URL: lineDefinitionURL!)
        connection = NSURLConnection(request: lineDefinitionURLRequest, delegate: self, startImmediately: true)
        
    }
    
    func requestStopPredictionData(stop:TransitStop) {
        xmlData = NSMutableData()
        currentRequestType = .StopPredictions
        transitStop = stop
        
        let completeLinePredictionURL = kMMBLinePredictionURL1 + stop.routeTag + kMMBLinePredictionURL2 + stop.stopTag
        let linePredictionURL = NSURL(string: completeLinePredictionURL)
        let linePredictionRequest = NSURLRequest(URL: linePredictionURL!)
        connection = NSURLConnection(request: linePredictionRequest, delegate: self, startImmediately: true)
    }
    
    //Clears all data after making a request
    func clearXMLParsingData() {
        currentRequestType = .NoRequest
        connection = nil
        xmlData = nil
        xmlString = ""
        indexOfLine = nil
        sender = nil
    }
    
    func parseAllLinesData(xml:XMLIndexer) {
        //Going through all lines and saving them
        for child in xml["body"].children {
            if let tag = child.element!.attributes["tag"], title = child.element!.attributes["title"] {
                MMBDataController.sharedController.addLine(TransitLine(lineNumber: tag, lineTitle: title))
            }
        }
        
        if let currentDelegate = self.delegate {
            currentDelegate.allLinesDataFinishedLoading()
        }
        
        clearXMLParsingData()
    }
    
    //Parsing the line definition
    func parseLineDefinition(xml:XMLIndexer) {
        var outboundStops: [String] = []
        var inboundStops: [String] = []
        var stopDictionary: [String: TransitStop] = [:]
        var inboundTransitStops: [TransitStop] = []
        var outboundTransitStops: [TransitStop] = []
        
        let stopDirections = xml["body"]["route"]["direction"]
        
        //Getting the directions for each stop
        for stopDirection in stopDirections {
            //For each direction, inbound and outbound
            if stopDirection.element!.attributes["name"] == "Inbound" {
                //If we are looking at inbound
                for child in stopDirection.children {
                    //Go through and add the stop tags to the set of inbound tags
                    if let tag:String = child.element!.attributes["tag"] {
                        inboundStops.append(tag)
                    }
                }
            } else {
                //If we are looking at outbound
                for child in stopDirection.children {
                    //Go through and add the stop tags to the set of inbound tags
                    if let tag:String = child.element!.attributes["tag"] {
                        outboundStops.append(tag)
                    }
                }

            }
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        let stops = xml["body"]["route"]["stop"]
        
        //Going through the stops and creating TransitStop objects
        for stop in stops {
            if let routeTitle = xml["body"]["route"].element!.attributes["title"], routeTag = xml["body"]["route"].element!.attributes["tag"], stopTitle = stop.element!.attributes["title"], stopTag = stop.element!.attributes["tag"] {
                let stop = TransitStop(routeTitle: routeTitle, routeTag: routeTag, stopTitle: stopTitle, stopTag: stopTag)
                
                stopDictionary[stopTag] = stop
            }
        }
        
        //Need to go through inbound and outbound stops IN ORDER and add them to an array of transit stops
        
        for stop in inboundStops {
            if let transitStop = stopDictionary[stop] as TransitStop! {
                transitStop.direction = .Inbound
                inboundTransitStops.append(transitStop)
            }
        }
        
        for stop in outboundStops {
            if let transitStop = stopDictionary[stop] as TransitStop! {
                transitStop.direction = .Outbound
                outboundTransitStops.append(transitStop)
            }
        }
        
        MMBDataController.sharedController.addStopsToLineAtIndex(indexOfLine!, inboundStops: inboundTransitStops, outboundStops: outboundTransitStops)
        
        if let currentDelegate = self.delegate {
            currentDelegate.lineDefinitionFinishedLoading(indexOfLine!, sender: sender!)
        }
        
        clearXMLParsingData()
        
    }
    
    //Parsing the information for stop predictions
    func parseStopPredictions(xml:XMLIndexer) {
        let predictions = xml["body"]["predictions"]["direction"]
        var predictionArray:[Int] = []
        
        //Getting all predictions, only if we're using 3
        for prediction in predictions.children {
            let predictionString:String = prediction.element!.attributes["minutes"]!
            if let predictionInt = Int(predictionString) {
                predictionArray.append(predictionInt)
            }
        }
        
        transitStop!.predictions = predictionArray
        
        clearXMLParsingData()
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.predictionAdded(transitStop!)
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        if let finishedXML = xmlData {
            xmlString = NSString(data: finishedXML, encoding: NSUTF8StringEncoding) as! String
            let xml = SWXMLHash.parse(xmlString)
            
            switch currentRequestType {
            case .AllLines:
                parseAllLinesData(xml)
            case .LineDefinition:
                parseLineDefinition(xml)
            case .StopPredictions:
                parseStopPredictions(xml)
            default:
                clearXMLParsingData()
            }
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        xmlData?.appendData(data)
    }
}