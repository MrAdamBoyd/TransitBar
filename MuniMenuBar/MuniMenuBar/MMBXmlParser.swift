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
    case AllLines
    case LineDefinition
    case StopPredictions
}

class MMBXmlParser: NSObject, NSXMLParserDelegate, NSURLConnectionDataDelegate {
    static let sharedParser = MMBXmlParser()
    
    private var currentRequestType:RequestType?
    private var connection:NSURLConnection?
    var xmlData:NSMutableData?
    
    //Private init for singleton
    //private init() { }
    
    //Request data for all lines
    func requestAllLineData() {
        xmlData = NSMutableData()
        currentRequestType = .AllLines
        
        var allLinesURL = NSURL(string: kMMBAllLinesURL)!
        var allLinesURLRequest = NSURLRequest(URL: allLinesURL)
        
        connection = NSURLConnection(request: allLinesURLRequest, delegate: self, startImmediately: true)
    }
    
    //Clears all data after making a request
    func clearXMLParsingData() {
        currentRequestType = nil
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
    
    
    //MARK: NSXMLParserDelegatee
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        //TODO: Parse the document based on the current request type
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        //TODO: Parse all the data
        
        clearXMLParsingData()
    }
}