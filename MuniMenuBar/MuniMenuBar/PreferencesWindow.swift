//
//  PreferencesWindow.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindow:NSWindow, MMBXmlParserDelegate {
    
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
        
        MMBXmlParser.sharedParser.delegate = self

        addTimesToPopUpButtons()
        
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }
    
    func addTimesToPopUpButtons() {
        
    }
    
    @IBAction func checkboxHit(sender: AnyObject) {
        if let button = sender as? NSButton {
            enableOrDisableTimes(button.state == NSOnState)
        }
    }
    
    //Enables or disables the PopUpButtons for the time
    func enableOrDisableTimes(enabledOrDisabled:Bool) {
        startTimePopup.enabled = enabledOrDisabled
        endTimePopup.enabled = enabledOrDisabled
    }
    
    //MARK: MMBXmlParserProtocol
    
    func allLinesDataFinishedLoading() {
        let titleArray = MMBDataController.sharedController.getAllLinesToString()
        
        line1.addItemsWithTitles(titleArray)
        line2.addItemsWithTitles(titleArray)
        line3.addItemsWithTitles(titleArray)
        line4.addItemsWithTitles(titleArray)
    }
    
}