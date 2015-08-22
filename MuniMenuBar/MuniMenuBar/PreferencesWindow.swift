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
    @IBOutlet weak var direction1: NSPopUpButton!
    @IBOutlet weak var stop1: NSPopUpButton!
    
    //Second line
    @IBOutlet weak var line2: NSPopUpButton!
    @IBOutlet weak var direction2: NSPopUpButton!
    @IBOutlet weak var stop2: NSPopUpButton!
    
    //Third line, first optional line
    @IBOutlet weak var line3: NSPopUpButton!
    @IBOutlet weak var direction3: NSPopUpButton!
    @IBOutlet weak var stop3: NSPopUpButton!
    
    //Fourth line, second optional line
    @IBOutlet weak var line4: NSPopUpButton!
    @IBOutlet weak var direction4: NSPopUpButton!
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
    
    //One of the line popups was selected
    @IBAction func lineSelected(sender: AnyObject) {
        if let popup = sender as? NSPopUpButton {
            /*The direction is enabled by the index of the selected item being a bool
            The 0th item is "--", so all other values should result in it being enabled
            0 means false and all other selections will be true */
            var shouldStartLoading = Bool(popup.indexOfSelectedItem)
            
            if shouldStartLoading {
                MMBXmlParser.sharedParser.requestLineDefinitionData(MMBDataController.sharedController.getAllLines()[popup.indexOfSelectedItem - 1].routeTag, indexOfLine: popup.indexOfSelectedItem - 1, sender: sender)
            } else {
                //We should disable the direction control if user selected "--"
                //It will be enabled when it is done loading
                enableOrDisableDirectionControls(popup, enableOrDisable: shouldStartLoading)
            }
            
            
        }
    }
    
    //Directional control selected
    @IBAction func directionSelected(sender: AnyObject) {
        if let popup = sender as? NSPopUpButton {
            var direction:LineDirection = LineDirection(rawValue: popup.indexOfSelectedItem)!
            
            //The 0th index is "--" and the initializing LineDirection with 0 results in .NoDirection
            if direction != .NoDirection {
                
                stop1.removeAllItems()
                stop1.addItemWithTitle("--")
                
                if popup == direction1 {
                    stop1.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: line1.indexOfSelectedItem - 1, goingDirection: direction))
                    stop1.enabled = true
                } else if popup == direction2 {
                    stop2.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: line2.indexOfSelectedItem - 1, goingDirection: direction))
                    stop2.enabled = true
                } else if popup == direction3 {
                    stop3.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: line3.indexOfSelectedItem - 1, goingDirection: direction))
                    stop3.enabled = true
                } else if popup == direction4 {
                    stop4.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: line4.indexOfSelectedItem - 1, goingDirection: direction))
                    stop4.enabled = true
                }
            } else {
                //If user selected no direction
                if popup == direction1 {
                    stop1.enabled = false
                } else if popup == direction2 {
                    stop2.enabled = false
                } else if popup == direction3 {
                    stop3.enabled = false
                } else if popup == direction4 {
                    stop4.enabled = false
                }
            }
        }
    }
    
    //Stop selected
    
    @IBAction func stopSelected(sender: AnyObject) {
        
        if let popup = sender as? NSPopUpButton {
            var direction:LineDirection = .NoDirection
            var indexOfLine = -1
            var indexOfStop = popup.indexOfSelectedItem - 1
            var currentStop:TransitStop
            
            //Getting the index of the line
            if popup == stop1 {
                indexOfLine = line1.indexOfSelectedItem - 1
                direction = LineDirection(rawValue: direction1.indexOfSelectedItem)!
            } else if popup == stop2 {
                indexOfLine = line2.indexOfSelectedItem - 1
                direction = LineDirection(rawValue: direction2.indexOfSelectedItem)!
            } else if popup == stop3 {
                indexOfLine = line3.indexOfSelectedItem - 1
                direction = LineDirection(rawValue: direction3.indexOfSelectedItem)!
            } else if popup == stop4 {
                indexOfLine = line4.indexOfSelectedItem - 1
                direction = LineDirection(rawValue: direction4.indexOfSelectedItem)!
            }
            
            //Getting the stop based on the direction
            if direction == .Inbound {
                currentStop = MMBDataController.sharedController.getAllLines()[indexOfLine].inboundStopsOnLine[indexOfStop]
            } else {
                currentStop = MMBDataController.sharedController.getAllLines()[indexOfLine].outboundStopsOnLine[indexOfStop]
            }

            currentStop.routeTag = MMBDataController.sharedController.getAllLines()[indexOfLine].routeTag.toInt()!
            //TODO: Save the stop
            
        }
    }
    
    //Determining whether to enable or disable each direction control
    func enableOrDisableDirectionControls(sender:AnyObject, enableOrDisable:Bool) {
        if let popup = sender as? NSPopUpButton {
            if popup == line1 {
                direction1.enabled = enableOrDisable
            } else if popup == line2 {
                direction2.enabled = enableOrDisable
            } else if popup == line3 {
                direction3.enabled = enableOrDisable
            } else if popup == line4 {
                direction4.enabled = enableOrDisable
            }
        }
    }
    
    //MARK: MMBXmlParserProtocol
    
    func allLinesDataFinishedLoading() {
        let titleArray = MMBDataController.sharedController.getAllLinesToString()
        
        line1.addItemsWithTitles(titleArray)
        line2.addItemsWithTitles(titleArray)
        line3.addItemsWithTitles(titleArray)
        line4.addItemsWithTitles(titleArray)
    }
    
    func lineDefinitionFinishedLoading(indexOfLine:Int, sender:AnyObject) {
        enableOrDisableDirectionControls(sender, enableOrDisable: true)
        if let popup = sender as? NSPopUpButton {
            if popup == line1 {
                stop1.removeAllItems()
                stop1.addItemWithTitle("--")
                stop1.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: indexOfLine, goingDirection: .Inbound))
            } else if popup == line2 {
                direction2.enabled = true
            } else if popup == line3 {
                direction3.enabled = true
            } else if popup == line4 {
                direction4.enabled = true
            }
        }
        
    }
}