//
//  NewLineViewController.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-11-19.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import SwiftBus

protocol NewStopDelegate: class {
    func newStopControllerDidAdd(newStop: TransitStop)
}

class NewLineViewController: NSViewController {
    
    @IBOutlet weak var agencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var routePopUpButton: NSPopUpButton!
    @IBOutlet weak var directionPopUpButton: NSPopUpButton!
    @IBOutlet weak var stopPopUpButton: NSPopUpButton!
    @IBOutlet weak var addStopButton: NSButton!
    
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
        
        SwiftBus.shared.transitAgencies() { agencies in
            var inOrderAgencies = Array(agencies.values)
            
            //Ordering the routes alphabetically
            inOrderAgencies = inOrderAgencies.sorted {
                $0.agencyTitle.localizedCaseInsensitiveCompare($1.agencyTitle) == ComparisonResult.orderedAscending
            }
            
            self.agencies = inOrderAgencies
            self.agencyPopUpButton.addItems(withTitles: inOrderAgencies.map({ $0.agencyTitle }))
        }
    }
    
    // MARK: - Actions from the popup buttons
    
    func agencySelectedAction() {
        self.routePopUpButton.removeAllItems()
        self.routes = []
        self.selectedRoute = nil
        self.directionPopUpButton.removeAllItems()
        self.directions = []
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        let agency = self.agencies[self.agencyPopUpButton.indexOfSelectedItem]
        SwiftBus.shared.routes(forAgency: agency) { routes in
            var inOrderRoutes = Array(routes.values)
            
            //Ordering the routes alphabetically
            inOrderRoutes = inOrderRoutes.sorted {
                $0.routeTitle.localizedCaseInsensitiveCompare($1.routeTitle) == ComparisonResult.orderedAscending
            }
            
            self.routes = inOrderRoutes
            self.routePopUpButton.addItems(withTitles: inOrderRoutes.map({ $0.routeTitle }))
        }
    }
    
    func routeSelectedAction() {
        self.selectedRoute = nil
        self.directionPopUpButton.removeAllItems()
        self.directions = []
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        let selectedRoute = self.routes[self.routePopUpButton.indexOfSelectedItem]
        SwiftBus.shared.configuration(forRoute: selectedRoute) { route in
            guard let route = route else { return }
            
            self.selectedRoute = route
            //The keys to this array are all possible directions
            self.directionPopUpButton.addItems(withTitles: Array(route.stopsOnRoute.keys))
        }
    }
    
    func directionSelectedAction() {
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        self.addStopButton.isEnabled = false
        
        if let title = self.directionPopUpButton.selectedItem?.title, let stops = self.selectedRoute?.stopsOnRoute[title] {
            self.stopPopUpButton.addItems(withTitles: stops.map({ $0.stopTitle }))
        }
    }
    
    func stopSelectedAction() {
        self.addStopButton.isEnabled = true
    }
    
    @IBAction func addNewStop(_ sender: Any) {
        guard let stop = self.selectedStop else { return }
        self.delegate?.newStopControllerDidAdd(newStop: stop)
    }
}
