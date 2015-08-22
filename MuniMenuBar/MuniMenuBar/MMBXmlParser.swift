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

enum RequestType {
    case NoRequest
    case AllLines
    case LineDefinition
    case StopPredictions
}

class MMBXmlParser: NSObject, NSURLConnectionDataDelegate {
    static let sharedParser = MMBXmlParser()
    
    var delegate: MMBXmlParserDelegate?
    
    private var currentRequestType:RequestType = .NoRequest
    private var connection:NSURLConnection?
    var xmlData:NSMutableData?
    var xmlString:String = ""
    
    //Private init for singleton
    //private init() { }
    
    //Request data for all lines
    func requestAllLineData() {
        xmlData = NSMutableData()
        currentRequestType = .AllLines
        
        var allLinesURL = NSURL(string: kMMBAllLinesURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var allLinesURLRequest = NSURLRequest(URL: allLinesURL!)
        connection = NSURLConnection(request: allLinesURLRequest, delegate: self, startImmediately: true)
    }
    
    func requestLineDefinitionData(line:String) {
        xmlData = NSMutableData()
        currentRequestType = .LineDefinition
        
        var completeLineDefinitionURL = kMMBLineDefinitionURL + line
        var lineDefinitionURL = NSURL(string: completeLineDefinitionURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var lineDefinitionURLRequest = NSURLRequest(URL: lineDefinitionURL!)
        connection = NSURLConnection(request: lineDefinitionURLRequest, delegate: self, startImmediately: true)
        
    }
    
    //Clears all data after making a request
    func clearXMLParsingData() {
        currentRequestType = .NoRequest
        connection = nil
        xmlData = nil
        xmlString = ""
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        xmlString = NSString(data: xmlData!, encoding: NSUTF8StringEncoding) as! String
        let xml = SWXMLHash.parse(xmlString)
        
        switch currentRequestType {
        case .AllLines:
            //Going through all lines and saving them
            for child in xml["body"].children {
                if let tag = child.element!.attributes["tag"], title = child.element!.attributes["title"] {
                    MMBDataController.sharedController.addLine(TransitLine(lineNumber: tag, lineTitle: title))
                }
            }
            
            if let currentDelegate = self.delegate {
                currentDelegate.allLinesDataFinishedLoading()
            }
        default:
            println("Nothing")
        }
        
        clearXMLParsingData()
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        xmlData?.appendData(data)
    }
}