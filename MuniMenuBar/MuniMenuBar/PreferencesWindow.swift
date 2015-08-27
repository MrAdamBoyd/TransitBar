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
    @IBOutlet weak var differentLinesCheckmark: NSButton! {
        didSet {
            if MMBDataController.sharedController.getDifferentLinesForDay() {
                differentLinesCheckmark.state = NSOnState
            }
        }
    }
    @IBOutlet var startDatePicker: NSDatePicker! {
        didSet {
            if let date = MMBDataController.sharedController.getDifferentStartTime() {
                //If there is a date
                startDatePicker.dateValue = date
                startDatePicker.enabled = true
            } else {
                //If there isn't a date
                MMBDataController.sharedController.setDifferentStartTime(startDatePicker.dateValue)
            }
        }
    }
    
    @IBOutlet var endDatePicker: NSDatePicker! {
        didSet {
            if let date = MMBDataController.sharedController.getDifferentEndTime() {
                //If there is a date
                endDatePicker.dateValue = date
                endDatePicker.enabled = true
            } else {
                //If there isn't a date
                MMBDataController.sharedController.setDifferentEndTime(endDatePicker.dateValue)
            }
        }
    }
    
    //First line
    @IBOutlet weak var line1: NSPopUpButton!
    @IBOutlet weak var direction1: NSPopUpButton!
    @IBOutlet weak var stop1: NSPopUpButton!
    
    //Second line
    @IBOutlet weak var line2: NSPopUpButton!
    @IBOutlet weak var direction2: NSPopUpButton!
    @IBOutlet weak var stop2: NSPopUpButton!
    
    //Third line, first optional line
    @IBOutlet weak var line3: NSPopUpButton! {
        didSet {
            line3.enabled = MMBDataController.sharedController.getDifferentLinesForDay()
        }
    }
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
    
    //When the window is opened
    override func makeKeyAndOrderFront(sender: AnyObject?) {
        super.makeKeyAndOrderFront(sender)
        
        MMBXmlParser.sharedParser.requestAllLineData()
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
        MMBDataController.sharedController.setDifferentLinesForDay(enabledOrDisabled)
        startDatePicker.enabled = enabledOrDisabled
        endDatePicker.enabled = enabledOrDisabled
        line3.enabled = enabledOrDisabled
        
        if !enabledOrDisabled {
            //Disabling everything else if they aren't enabled
            direction3.enabled = enabledOrDisabled
            stop3.enabled = enabledOrDisabled
            line4.enabled = enabledOrDisabled
            direction4.enabled = enabledOrDisabled
            stop4.enabled = enabledOrDisabled
        }
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
            
            //We need to remove all stops from the corresponding stop popup
            let correspondingButtons = getDirectionAndStopForCurrentLine(popup)
            correspondingButtons.directionButton.selectItemAtIndex(0)
            correspondingButtons.stopButton.removeAllItems()
            correspondingButtons.stopButton.addItemWithTitle("--")
        }
    }
    
    //Directional control selected
    @IBAction func directionSelected(sender: AnyObject) {
        if let popup = sender as? NSPopUpButton {
            var direction:LineDirection = LineDirection(rawValue: popup.indexOfSelectedItem)!
            
            //The 0th index is "--" and the initializing LineDirection with 0 results in .NoDirection
            if direction != .NoDirection {

                if popup == direction1 {
                    addStopsToStopButton(stop1, lineButton: line1, direction: direction)
                    
                } else if popup == direction2 {
                    addStopsToStopButton(stop2, lineButton: line2, direction: direction)
                
                } else if popup == direction3 {
                    addStopsToStopButton(stop3, lineButton: line3, direction: direction)
                
                } else if popup == direction4 {
                    addStopsToStopButton(stop4, lineButton: line4, direction: direction)
                
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
    
    //Adding the correct stops to the stop button
    func addStopsToStopButton(stopButton: NSPopUpButton, lineButton: NSPopUpButton, direction: LineDirection) {
        stopButton.removeAllItems()
        stopButton.addItemWithTitle("--")
        stopButton.addItemsWithTitles(MMBDataController.sharedController.getStopNames(forLine: lineButton.indexOfSelectedItem - 1, goingDirection: direction))
        stopButton.enabled = true
    }
    
    //Stop selected
    
    @IBAction func stopSelected(sender: AnyObject) {
        
        if let popup = sender as? NSPopUpButton {
            var direction:LineDirection = .NoDirection
            var indexOfLine:Int
            var indexOfStop = popup.indexOfSelectedItem - 1
            var currentStop:TransitStop
            var stopToSave:Int

            //User selected stop, not just "--"
            if indexOfStop > 0 {
                //Getting the index of the line
                if popup == stop1 {
                    indexOfLine = line1.indexOfSelectedItem - 1
                    direction = LineDirection(rawValue: direction1.indexOfSelectedItem)!
                    stopToSave = 0
                    line2.enabled = true
                } else if popup == stop2 {
                    indexOfLine = line2.indexOfSelectedItem - 1
                    direction = LineDirection(rawValue: direction2.indexOfSelectedItem)!
                    stopToSave = 1
                } else if popup == stop3 {
                    indexOfLine = line3.indexOfSelectedItem - 1
                    direction = LineDirection(rawValue: direction3.indexOfSelectedItem)!
                    stopToSave = 2
                    line4.enabled = true
                } else {
                    //Stop 4
                    indexOfLine = line4.indexOfSelectedItem - 1
                    direction = LineDirection(rawValue: direction4.indexOfSelectedItem)!
                    stopToSave = 3
                }
                
                //Getting the stop based on the direction
                if direction == .Inbound {
                    currentStop = MMBDataController.sharedController.getAllLines()[indexOfLine].inboundStopsOnLine[indexOfStop]
                } else {
                    currentStop = MMBDataController.sharedController.getAllLines()[indexOfLine].outboundStopsOnLine[indexOfStop]
                }

                currentStop.routeTag = MMBDataController.sharedController.getAllLines()[indexOfLine].routeTag
                
                MMBDataController.sharedController.saveStop(stopToSave, stop: currentStop)
                
                //Updating the label for the app delegate
                let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loadData()
                
            } else {
                //User selected "--", disable the next line
                if popup == stop1 {
                    line2.enabled = false
                } else if popup == stop3 {
                    line4.enabled = false
                }
            }
        }
    }
    
    //Determining whether to enable or disable each direction control
    func enableOrDisableDirectionControls(sender:AnyObject, enableOrDisable:Bool) {
        if let popup = sender as? NSPopUpButton {
            getDirectionAndStopForCurrentLine(popup).directionButton.enabled = enableOrDisable
        }
    }
    
    //Returns a tuple of the stop and direction popup buttons
    func getDirectionAndStopForCurrentLine(lineButton:NSPopUpButton) -> (directionButton: NSPopUpButton, stopButton:NSPopUpButton){
        if lineButton == line1 {
            return (direction1, stop1)
            
        } else if lineButton == line2 {
            return (direction2, stop2)
            
        } else if lineButton == line3 {
            return (direction3, stop3)
            
        } else {
            //Line 4
            return (direction4, stop4)
        }
    }
    
    //MARK: MMBXmlParserProtocol
    
    func allLinesDataFinishedLoading() {
        let titleArray = MMBDataController.sharedController.getAllLinesToString()
        
        line1.addItemsWithTitles(titleArray)
        line2.addItemsWithTitles(titleArray)
        line3.addItemsWithTitles(titleArray)
        line4.addItemsWithTitles(titleArray)
        
        //Restoring the window to the stop that is saved, can't use indexes because lines could be added and removed
        if let transitStop1 = MMBDataController.sharedController.getStop(0) {
            restoreSavedLineToWindow(line1, directionButton: direction1, stopButton: stop1, savedStop: transitStop1)
        }

        if let transitStop2 = MMBDataController.sharedController.getStop(1) {
            restoreSavedLineToWindow(line2, directionButton: direction2, stopButton: stop2, savedStop: transitStop2)
        }

        if let transitStop3 = MMBDataController.sharedController.getStop(2) {
            restoreSavedLineToWindow(line3, directionButton: direction3, stopButton: stop3, savedStop: transitStop3)
        }
        
        if let transitStop4 = MMBDataController.sharedController.getStop(3) {
            restoreSavedLineToWindow(line4, directionButton: direction4, stopButton: stop4, savedStop: transitStop4)
        }
    }
    
    //Select the right bus, direction, and stop for the open preferences window
    func restoreSavedLineToWindow(lineButton:NSPopUpButton, directionButton:NSPopUpButton, stopButton:NSPopUpButton, savedStop:TransitStop) {
        lineButton.enabled = true
        directionButton.enabled = true
        stopButton.enabled = true
        lineButton.selectItemAtIndex(lineButton.indexOfItemWithTitle(savedStop.routeTitle))
        directionButton.selectItemAtIndex(savedStop.direction == .Inbound ? 1 : 2)
        stopButton.addItemWithTitle(savedStop.stopTitle)
        stopButton.selectItemAtIndex(1)
    }
    
    func lineDefinitionFinishedLoading(indexOfLine:Int, sender:AnyObject) {
        enableOrDisableDirectionControls(sender, enableOrDisable: true)
    }
}