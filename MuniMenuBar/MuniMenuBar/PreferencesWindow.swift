//
//  PreferencesWindow.swift
//  MuniMenuBar
//
//  Created by Adam on 2015-08-18.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindow:NSWindow, MMBXmlParserDelegate, NSTextFieldDelegate {
    
    //Optionally show different lines at different times
    @IBOutlet weak var differentLinesCheckmark: NSButton!
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    
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
        
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }
    
    @IBAction func checkboxHit(sender: AnyObject) {
        if let button = sender as? NSButton {
            enableOrDisableTimes(button.state == NSOnState)
        }
    }

    @IBAction func startPickerDateChanged(sender: AnyObject) {
        MMBDataController.sharedController.setDifferentStartTime(sender.dateValue!)
    }
    
    @IBAction func endPickerDateChanged(sender: AnyObject) {
        MMBDataController.sharedController.setDifferentEndTime(sender.dateValue!)
    }
    
    
    //Enables or disables the PopUpButtons for the time
    func enableOrDisableTimes(enabledOrDisabled:Bool) {
        startDatePicker.enabled = enabledOrDisabled
        endDatePicker.enabled = enabledOrDisabled
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