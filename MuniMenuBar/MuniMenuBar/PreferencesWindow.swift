//
//  PreferencesWindow.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindow:NSWindow {
    
    //Optionally show different lines at different times
    @IBOutlet weak var differentLinesCheckmark: NSButton!
    @IBOutlet weak var startTimePopup: NSPopUpButton!
    @IBOutlet weak var endTimePopup: NSPopUpButton!
    
    //First line
    @IBOutlet weak var line1: NSPopUpButton!
    @IBOutlet weak var stop1: NSPopUpButton!
    
    //Second line
    @IBOutlet weak var line2: NSPopUpButton!
    @IBOutlet weak var stop2: NSPopUpButton!
    
    //Third line, first optional line
    @IBOutlet weak var line3: NSPopUpButton!
    @IBOutlet weak var stop3: NSPopUpButton!
    
    //Fourth line, second optional line
    @IBOutlet weak var line4: NSPopUpButton!
    @IBOutlet weak var stop4: NSPopUpButton!
    
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        println("TEST")
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }
}