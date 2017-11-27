//
//  NewLineViewController.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-11-19.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import SwiftBus

protocol NewStopDelegate: class {
    func newStopControllerDidAdd(newEntry: TransitEntry)
}

class NewLineViewController: NSViewController {
    
    @IBOutlet weak var agencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var routePopUpButton: NSPopUpButton!
    @IBOutlet weak var directionPopUpButton: NSPopUpButton!
    @IBOutlet weak var stopPopUpButton: NSPopUpButton!
    @IBOutlet weak var addStopButton: NSButton!
    @IBOutlet weak var allTimesRadioButton: NSButton!
    @IBOutlet weak var startTimeDatePicker: NSDatePicker!
    @IBOutlet weak var endTimeDatePicker: NSDatePicker!
    @IBOutlet weak var neverRadioButton: NSButton!
    @IBOutlet weak var betweenTimesRadioButton: NSButton!
    
    weak var delegate: NewStopDelegate?
    var agencies: [TransitAgency] = []
    var routes: [TransitRoute] = []
    var directions: [String] = []
    var stops: [TransitStop] = []
    var selectedRoute: TransitRoute?
    var selectedStop: TransitStop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.agencyPopUpButton.action = #selector(self.agencySelectedAction)
        self.routePopUpButton.action = #selector(self.routeSelectedAction)
        self.directionPopUpButton.action = #selector(self.directionSelectedAction)
        self.stopPopUpButton.action = #selector(self.stopSelectedAction)
        
        self.agencyPopUpButton.menu?.autoenablesItems = true
        self.routePopUpButton.menu?.autoenablesItems = true
        self.directionPopUpButton.menu?.autoenablesItems = true
        self.stopPopUpButton.menu?.autoenablesItems = true
        
        //Get the agencies when the window is opened
        SwiftBus.shared.transitAgencies() { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(agencies):
                    var inOrderAgencies = Array(agencies.values)
                    
                    //Ordering the routes alphabetically
                    inOrderAgencies = inOrderAgencies.sorted {
                        $0.agencyTitle.localizedCaseInsensitiveCompare($1.agencyTitle) == ComparisonResult.orderedAscending
                    }
                    
                    //Placeholder
                    self.agencyPopUpButton.addItem(withTitle: "--")
                    
                    self.agencies = inOrderAgencies
                    self.agencyPopUpButton.addItems(withTitles: inOrderAgencies.map({ $0.agencyTitle }))
                case let .error(error):
                    self.agencyPopUpButton.addItem(withTitle: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    @IBAction func radioButtonTapped(_ sender: Any) {
        print("Radio button tapped")
        let enabled = self.betweenTimesRadioButton.state == .on
        self.startTimeDatePicker.isEnabled = enabled
        self.endTimeDatePicker.isEnabled = enabled
    }
    
    // MARK: - Actions from the popup buttons
    
    @objc
    func agencySelectedAction() {
        self.routePopUpButton.removeAllItems()
        self.routes = []
        self.selectedRoute = nil
        self.directionPopUpButton.removeAllItems()
        self.directions = []
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        guard self.agencyPopUpButton.indexOfSelectedItem != 0 else { return }
        
        let agency = self.agencies[self.agencyPopUpButton.indexOfSelectedItem]
        SwiftBus.shared.routes(forAgency: agency) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(routes):
                    var inOrderRoutes = Array(routes.values)
                    
                    //Ordering the routes alphabetically
                    inOrderRoutes = inOrderRoutes.sorted {
                        $0.routeTitle.localizedCaseInsensitiveCompare($1.routeTitle) == ComparisonResult.orderedAscending
                    }
                    
                    self.routePopUpButton.addItem(withTitle: "--")
                    
                    self.routes = inOrderRoutes
                    self.routePopUpButton.addItems(withTitles: inOrderRoutes.map({ $0.routeTitle }))
                case let .error(error):
                    self.agencyPopUpButton.addItem(withTitle: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc
    func routeSelectedAction() {
        self.selectedRoute = nil
        self.directionPopUpButton.removeAllItems()
        self.directions = []
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        guard self.routePopUpButton.indexOfSelectedItem != 0 else { return }
        
        let selectedRoute = self.routes[self.routePopUpButton.indexOfSelectedItem - 1]
        SwiftBus.shared.configuration(forRoute: selectedRoute) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(route):
                    self.directionPopUpButton.addItem(withTitle: "--")
                    
                    self.selectedRoute = route
                    //The keys to this array are all possible directions
                    self.directionPopUpButton.addItems(withTitles: Array(route.stops.keys))
                case let .error(error):
                    self.agencyPopUpButton.addItem(withTitle: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// User selected a direction for the direction popup
    @objc
    func directionSelectedAction() {
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        //Don't do anything if the placeholder item is selected
        guard self.directionPopUpButton.indexOfSelectedItem != 0 else { return }
        
        if let title = self.directionPopUpButton.selectedItem?.title, let stops = self.selectedRoute?.stops[title] {
            
            DispatchQueue.main.async { [unowned self] in
                //Placeholder
                self.stopPopUpButton.addItem(withTitle: "--")
                
                self.stops = stops
                //Getting the stops for that direction. The direction is the key to the dictionary for the stops on that route
                self.stopPopUpButton.addItems(withTitles: stops.map({ $0.stopTitle }))
            }
        }
    }
    
    @objc
    func stopSelectedAction() {
        //Only enable if placeholder item isn't there
        guard self.stopPopUpButton.indexOfSelectedItem != 0 else { return }
        
        self.addStopButton.isEnabled = true
        self.selectedStop = self.stops[self.stopPopUpButton.indexOfSelectedItem - 1]
    }
    
    @IBAction func addNewStop(_ sender: Any) {
        guard let stop = self.selectedStop else { return }
        var times: (Date?, Date?)? = nil
        
        if self.betweenTimesRadioButton.state == .on {
            
            //Only show the times between two times
            
            //Order the dates so that the 0th date is always earlier than the second one
            if self.startTimeDatePicker.dateValue < self.endTimeDatePicker.dateValue {
                times = (self.startTimeDatePicker.dateValue, self.endTimeDatePicker.dateValue)
            } else {
                times = (self.endTimeDatePicker.dateValue, self.startTimeDatePicker.dateValue)
            }
            
        } else if self.neverRadioButton.state == .on {
            //The tuple exists but has nil values for never being shown
            times = (nil, nil)
        }
        
        let entry = TransitEntry(stop: stop, times: times)
        self.delegate?.newStopControllerDidAdd(newEntry: entry)
        
        self.view.window?.close()
    }
}
