//
//  DataController.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-12-05.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation

class DataController {
    static let shared = DataController()
    
    private init() {
        //Get data from user defaults and then convert from data to array of entries
        if let unarchivedObject = UserDefaults.standard.object(forKey: Constants.entryArrayKey) as? Data {
            self.savedEntries = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! [TransitEntry]
        }
        
        //Getting the stops from the user defaults
        if let stops = UserDefaults.standard.array(forKey: Constants.entryArrayKey) as? [TransitEntry] {
            self.savedEntries = stops
        }
    }
    
    var savedEntries: [TransitEntry] = [] {
        didSet {
            //Convert array to Data first, then UserDefaults can save it
            let archievedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedEntries)
            UserDefaults.standard.set(archievedObject, forKey: Constants.entryArrayKey)
            UserDefaults.standard.synchronize()
        }
    }
}
