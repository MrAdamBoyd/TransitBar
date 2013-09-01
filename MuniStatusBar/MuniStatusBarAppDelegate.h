//
//  MuniStatusBarAppDelegate.h
//  MuniStatusBar
//
//  Created by Adam on 8/31/13.
//  Copyright (c) 2013 AdamBoyd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MuniStatusBarAppDelegate : NSObject <NSApplicationDelegate, NSXMLParserDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    NSURLConnection *connection;
    NSMutableData *xmlData;
    
    NSMutableArray *numberDictionary;
}

-(void)fetchInfo;

@end
