//
//  MMBXmlParser.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-20.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

enum RequestType {
    case NoRequest
    case AllLines
    case LineDefinition
    case StopPredictions
}

class MMBXmlParser: NSObject, NSXMLParserDelegate, NSURLConnectionDataDelegate {
    static let sharedParser = MMBXmlParser()
    
    var delegate: MMBXmlParserDelegate?
    
    private var currentRequestType:RequestType = .NoRequest
    private var connection:NSURLConnection?
    var xmlData:NSMutableData?
    
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
    
    //Clears all data after making a request
    func clearXMLParsingData() {
        currentRequestType = .NoRequest
        connection = nil
        xmlData = nil
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var parser = NSXMLParser(data: xmlData!)
        
        parser.delegate = self
        
        parser.parse()
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        xmlData?.appendData(data)
    }
    
    
    //MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        //TODO: Parse the document based on the current request type
        switch currentRequestType {
        case .AllLines:
            if elementName == "route" {
                if let tag = attributeDict["tag"] as? String, title = attributeDict["title"] as? String{
                    MMBDataController.sharedController.addLine(TransitLine(lineNumber: tag, lineTitle: title))
                }
            }
        case .LineDefinition:
            println("Line def")
        case .StopPredictions:
            println("Line prediction")
        default:
            println("Nothing to see here, move along")
        }

    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        //TODO: Parse all the data
        
        switch currentRequestType {
        case .AllLines:
            if let currentDelegate = self.delegate {
                currentDelegate.allLinesDataFinishedLoading()
            }
        default:
            println("Nothing")
        }
        
        clearXMLParsingData()
    }
}