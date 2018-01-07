//
//  StatusBarManager.swift
//  TransitBar
//
//  Created by Adam on 1/6/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit
import MapKit
import CoreLocation
import SwiftBus

protocol StatusBarManagerDelegate: class {
    var mostRecentUserLocation: CLLocation? { get }
    func statusBarManager(_ statusBarManager: StatusBarManager, requestDirectionsTo destination: CLLocation?, completion: @escaping (MKDirectionsRequest?) -> Void)
    func statusBarManager(_ statusBarManager: StatusBarManager, requestsCheckForNotificationsToSendFor entry: TransitEntry, predictions: [TransitPrediction])
    func statusBarManagerRequestsToTerminate(_ statusBarManager: StatusBarManager)
    func statusBarManager(_ statusBarManager: StatusBarManager, requestsSetNotificationFor sender: Any)
    func statusBarManagerCheckForUpdates(_ statusBarManager: StatusBarManager)
    func statusBarManagerOpenAboutWindow(_ statusBarManager: StatusBarManager)
    func statusBarManagerOpenAlertsWindow(_ statusBarManager: StatusBarManager)
    func statusBarManagerOpenNotificationsWindow(_ statusBarManager: StatusBarManager)
    func statusBarManagerOpenSettingsWindow(_ statusBarManager: StatusBarManager)
}

final class StatusBarManager {
    
    // MARK: - Properties
    
    private let statusItem: NSStatusItem
    private let dataController: DataController
    private weak var delegate: StatusBarManagerDelegate?
    
    // MARK: - Initializing
    
    init(statusItem: NSStatusItem, dataController: DataController, delegate: StatusBarManagerDelegate) {
        self.statusItem = statusItem
        self.dataController = dataController
        self.delegate = delegate
        
        self.setUpMenuItem()
    }
    
    // MARK: - Changing the menu items
    
    private func setUpMenuItem() {
        //Setting up the status bar menu and the actions from that
        self.statusItem.image = self.emptyStatusBarTemplateImage
        self.createMenuItems()
    }

    /// This is the icon when there is nothing to show in the menubar
    private var emptyStatusBarTemplateImage: NSImage {
        let image = #imageLiteral(resourceName: "TemplateIcon")
        image.isTemplate = true
        return image
    }
    
    /// Creates the menu item from scratch
    func createMenuItems() {
        if self.statusItem.menu == nil {
            self.statusItem.menu = NSMenu()
        }
        
        self.statusItem.menu?.removeAllItems()
        
        for (index, entry) in self.dataController.savedEntries.enumerated() {
            //When clicking on the menu, all the stops always show
            let title = "\(entry.stop.routeTitle) -> \(entry.stop.direction)"
            
            self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: title, target: nil, action: nil, keyEquivalent: ""))
            
            if self.dataController.displayWalkingTime {
                
                self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: self.locationTextFrom(source: self.delegate?.mostRecentUserLocation, to: CLLocation(latitude: entry.stop.lat, longitude: entry.stop.lon)), target: nil, action: nil, keyEquivalent: ""))
                self.setWalkingTimeForMenuItemWith(entry: entry, at: index) //Async gets the walking time
            }
            
            self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "Set Notification", target: self, action: #selector(self.setNotificationFor(_:)), keyEquivalent: ""))
            
            self.statusItem.menu?.addItem(NSMenuItem.separator())
            
        }
        
        self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "About TransitBar", target: self, action: #selector(self.openAboutWindow), keyEquivalent: ""))
        #if SPARKLE
            self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "Check for Updates...", target: self, action: #selector(self.checkForUpdates), keyEquivalent: ""))
        #endif
        self.statusItem.menu?.addItem(NSMenuItem.separator())
        self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "View Alerts", target: self, action: #selector(self.openAlertsWindow), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "View Scheduled Notifications", target: self, action: #selector(self.openNotificationsWindow), keyEquivalent: ""))
        self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "Preferences...", target: self, action: #selector(self.openSettingsWindow), keyEquivalent: ","))
        self.statusItem.menu?.addItem(NSMenuItem.menuItem(withTitle: "Quit", target: self, action: #selector(self.terminate), keyEquivalent: "q"))
        
        self.updateMenuItems()
    }
    
    /// Creates the menu items for preferences/about/etc and also for all the transit entries
    func updateMenuItems() {
        var menuText = ""
        
        for (index, entry) in self.dataController.savedEntries.enumerated() {
            
            //Creating the text that will be for this stop in the menubar
            var menuTextForThisEntry = entry.stop.routeTag + ": "
            //Creating the text that will be shown when you click on this item
            var insideDropdownTitle = "\(entry.stop.routeTitle) @ \(entry.stop.stopTitle) -> \(entry.stop.direction)"
            var addingPredictionsForInsideDropdown = ": "
            
            if let error = entry.error {
                
                //Show the error to the user
                //Need to add comma and space after as characters are normally removed before being shown
                menuTextForThisEntry.append("Error, ")
                addingPredictionsForInsideDropdown.append("Error: \(error.localizedDescription), ")
                
            } else if let predictions = entry.stop.predictions[entry.stop.direction] {
                
                //Set up the predictions text
                for (index, prediction) in predictions.enumerated() {
                    
                    if index < self.dataController.numberOfPredictionsToShow {
                        //Only add however many predictions the user wants
                        menuTextForThisEntry.append("\(prediction.predictionInMinutes), ")
                    }
                    
                    addingPredictionsForInsideDropdown.append("\(prediction.predictionInMinutes), ")
                }
                
                self.delegate?.statusBarManager(self, requestsCheckForNotificationsToSendFor: entry, predictions: predictions)
                
            }
            
            //Only show it in the menubar if it should be shown based on current time
            if entry.shouldBeShownInMenuBar {
                menuTextForThisEntry = String(menuTextForThisEntry.dropLast(2)) + "; " //Remove last comma and space and add semicolon
                menuText.append(menuTextForThisEntry)
            }
            
            //Remove comma and space
            addingPredictionsForInsideDropdown = String(addingPredictionsForInsideDropdown.dropLast(2))
            
            //If there are no predictions, add a dash
            if addingPredictionsForInsideDropdown == ": " {
                addingPredictionsForInsideDropdown.append("--")
            }
            
            insideDropdownTitle.append(addingPredictionsForInsideDropdown)
            
            DispatchQueue.main.async {
                if let menuItemToUpdate = self.statusItem.menu?.items[self.menuItemIndexForEntryIndex(index)] {
                    menuItemToUpdate.title = insideDropdownTitle
                }
            }
            
        }
        
        //At the very end, set the status bar text
        DispatchQueue.main.async { self.setStatusBarText(menuText) }
        
    }
    
    // MARK: - Setting text
    
    /// Determines what the status bar will look like. If there is text to set, uses that text. If no text, uses an image
    ///
    /// - Parameter text: text to set
    private func setStatusBarText(_ text: String) {
        //If there is no menubar text, add two dashes
        if text.isEmpty {
            self.statusItem.title = ""
            if self.statusItem.image == nil {
                self.statusItem.image = self.emptyStatusBarTemplateImage
            }
        } else {
            self.statusItem.title = String(text.dropLast(2)) //Remove final ; and space
            if self.statusItem.image != nil {
                self.statusItem.image = nil
            }
        }
    }
    
    // MARK: - Helpers
    
    /// The index of the menu item for the entry index (2nd entry would be the 6th menu item)
    ///
    /// - Parameter index: index of the entry
    /// - Returns: index in the menu
    private func menuItemIndexForEntryIndex(_ index: Int) -> Int {
        if self.dataController.displayWalkingTime {
            return index * 4
        } else {
            return index * 3
        }
    }
    
    /// Gets the entry for the specified menu item index
    ///
    /// - Parameter index: index of the menu item
    /// - Returns: Entry at the index
    func entryForMenuIndex(_ index: Int) -> TransitEntry {
        if self.dataController.displayWalkingTime {
            return self.dataController.savedEntries[index / 4]
        } else {
            return self.dataController.savedEntries[index / 3]
        }
    }
    
    // MARK: - Dealing with locations
    
    /// Gets the walking time for the user's current location to the provided entry. Updates menu item when done
    ///
    /// - Parameters:
    ///   - entry: entry to calculate distance ot
    ///   - index: entry index of the item
    private func setWalkingTimeForMenuItemWith(entry: TransitEntry, at index: Int) {
        self.delegate?.statusBarManager(self, requestDirectionsTo: CLLocation(latitude: entry.stop.lat, longitude: entry.stop.lon)) { directionsRequest in
            
            if let directionsRequest = directionsRequest {
                
                let directions = MKDirections(request: directionsRequest)
                directions.calculate() { [unowned self] response, _ in
                    
                    if let routes = response?.routes {
                        
                        //Get the quickest route
                        let quickest = routes.sorted() { $0.expectedTravelTime < $1.expectedTravelTime }[0]
                        
                        //Set the text including the walking time and the actual distance with directions
                        self.statusItem.menu?.items[self.menuItemIndexForEntryIndex(index) + 1].title = self.locationTextFrom(source: nil, to: nil, overrideDistance: quickest.distance, walkingTime: quickest.expectedTravelTime)
                    }
                    
                }
                
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func setNotificationFor(_ sender: Any) {
        self.delegate?.statusBarManager(self, requestsSetNotificationFor: sender)
    }

    @objc
    private func checkForUpdates() {
        self.delegate?.statusBarManagerCheckForUpdates(self)
    }
    
    @objc
    private func openAboutWindow() {
        self.delegate?.statusBarManagerOpenAboutWindow(self)
    }
    
    @objc
    private func openAlertsWindow() {
        self.delegate?.statusBarManagerOpenAlertsWindow(self)
    }
    
    @objc
    private func openNotificationsWindow() {
        self.delegate?.statusBarManagerOpenNotificationsWindow(self)
    }
    
    @objc
    private func openSettingsWindow() {
        self.delegate?.statusBarManagerOpenSettingsWindow(self)
    }
    
    @objc
    private func terminate() {
        self.delegate?.statusBarManagerRequestsToTerminate(self)
    }
    
    // MARK: Formatting
    
    /// Formats distance in the locality that user has set
    ///
    /// - Parameter distance: distance to format
    /// - Returns: formatted string
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        //Format the string
        let df = MKDistanceFormatter()
        df.unitStyle = .full
        
        return df.string(fromDistance: abs(distance))
    }
    
    /// Builds the string for the menu item that contains the distance and walking time to that stop
    ///
    /// - Parameters:
    ///   - source: user's location
    ///   - destination: stop's location
    ///   - overrideDistance: use this distance instead of calculating
    ///   - walkingTime: include the walking time to format this
    /// - Returns: formatted string
    private func locationTextFrom(source: CLLocation?, to destination: CLLocation?, overrideDistance: CLLocationDistance? = nil, walkingTime: TimeInterval? = nil) -> String {
        
        var returnString = ""
        
        if let distance = overrideDistance {
            //Use this distance instead of calculating
            
            returnString = "Distance: \(self.formatDistance(distance))"
            
        } else if let location = source, let destinationLocation = destination {
            
            //Get the actual distance to the location
            let distance = location.distance(from: destinationLocation)
            
            returnString = "Distance: \(self.formatDistance(distance))"
            
        } else {
            
            //Unknown distance
            returnString = "Distance: unknown"
        }
        
        if let walkingTime = walkingTime {
            let toMinutes = Int(round((walkingTime / 60).truncatingRemainder(dividingBy: 60)))
            returnString.append("; walking time: \(toMinutes) minutes")
        }
        
        return returnString
    }
    
}
