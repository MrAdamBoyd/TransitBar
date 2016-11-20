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
    
    
    /// Makes sure that all popup buttons have valid selections and if they do, enables the add button
    func checkIfValid() {
        let valid = self.agencyPopUpButton.selectedItem != nil && self.routePopUpButton.selectedItem != nil && self.directionPopUpButton.selectedItem != nil && self.stopPopUpButton.selectedItem != nil
        self.addStopButton.isEnabled = valid
    }
    
    // MARK: - Actions from the popup buttons
    
    func agencySelectedAction() {
        self.routePopUpButton.removeAllItems()
        self.routes = []
        self.directionPopUpButton.removeAllItems()
        self.directions = []
        self.stopPopUpButton.removeAllItems()
        self.stops = []
        
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
        self.directionPopUpButton.removeAllItems()
        self.stopPopUpButton.removeAllItems()
    }
    
    func directionSelectedAction() {
        self.stopPopUpButton.removeAllItems()
    }
    
    func stopSelectedAction() {
        self.checkIfValid()
    }
    
    @IBAction func addNewStop(_ sender: Any) {
        self.delegate?.newStopControllerDidAdd(newStop: TransitStop(routeTitle: "temp", routeTag: "temp", stopTitle: "temp", stopTag: "temp"))
    }
}
