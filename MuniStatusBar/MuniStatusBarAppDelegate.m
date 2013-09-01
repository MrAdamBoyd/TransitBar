//
//  MuniStatusBarAppDelegate.m
//  MuniStatusBar
//
//  Created by Adam on 8/31/13.
//  Copyright (c) 2013 AdamBoyd. All rights reserved.
//

#import "MuniStatusBarAppDelegate.h"

@implementation MuniStatusBarAppDelegate

-(void)awakeFromNib {
    
    numberDictionary = [[NSMutableArray alloc] init];
     
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setTitle:@"Muni Menu Bar"];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Muni Menu Bar"];
    [statusItem setHighlightMode:YES];
    [self fetchInfo];
    
    //
    //1.
    //
    //Number of seconds in between refreshes, for 120 seconds, it should say "120.0f", for 30 seconds, it should say "30.0f"
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(fetchInfo) userInfo:nil repeats:YES];
    
}

-(void)fetchInfo {
    //Create a new data container for the data that comes back from the service
    xmlData = [[NSMutableData alloc] init];
    
    //Construct a URL that will ask the service for the data
    
    //
    //2.
    //
    //Look for "r=31&s=3064". R is the route number, so "5" for 5-Fulton and "N" for N Judah. The stop number you need to find out on nextbus.com. The stop number is indicitave of the direction of the bus.
    NSString *tempString = [NSString stringWithFormat:@"http:webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=31&s=3064&useShortTitles=true"];
    
    NSURL *urlLine = [NSURL URLWithString:tempString];
    
    //Put that URL into an NSURLRequest
    NSURLRequest *reqLine = [NSURLRequest requestWithURL:urlLine];
    
    //Create a connection that will exchange this erquest for data from the URL
    connection = [[NSURLConnection alloc] initWithRequest:reqLine delegate:self startImmediately:YES];
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [xmlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)conn {
    //Create the parser object with data received by the web service
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    //Give it a delegate
    [parser setDelegate:self];
    
    //Tell it to start parsing
    [parser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqual:@"prediction"]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSLog(@"%@", [formatter numberFromString:[attributeDict objectForKey:@"minutes"]]);
        [numberDictionary addObject:[attributeDict objectForKey:@"minutes"]];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSString *tempString = [[NSString alloc] init];
    
    //
    //3.
    //
    //This is the last thing you need to change. Just change the name to whatever your line is, or what ever you want the title to say. Only change the things inside the parenthesis. Both this and the one a couple lines down need to be the exact same.
    tempString = @"31 Balboa: ";
    for (NSString *numberString in numberDictionary) {
                                ///THIS ONE///
        if ([tempString isEqual:@"31 Balboa: "]) {
                                ///THIS ONE///
            tempString = [tempString stringByAppendingFormat:@"%@", numberString];
        }
        else {
            tempString = [tempString stringByAppendingFormat:@", %@", numberString];
        }
    }
    [numberDictionary removeAllObjects];
    [statusItem setTitle:tempString];
}

@end
