//
//  AboutWindow.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-09-08.
//  Copyright © 2015 Adam. All rights reserved.
//

import Foundation
import Cocoa

class AboutWindow: NSWindow {
    
}

//Only used for the website text field
class clickableTextField:NSTextField {
    //Clicking event
    override func mouseDown(theEvent: NSEvent) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://mradamboyd.github.io/MuniMenuBar/")!)
        self.sendAction(self.action, to: self.target)
    }
}
