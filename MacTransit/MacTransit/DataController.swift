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
        //Number of predictions to show
        let numberOfPredictions = UserDefaults.standard.integer(forKey: Constants.numberOfPredictionsKey)
        if numberOfPredictions != 0 {
            //0 means there is no key
            self.numberOfPredictionsToShow = numberOfPredictions
        }
        
        //Get data from user defaults and then convert from data to array of entries
        if let unarchivedObject = UserDefaults.standard.object(forKey: Constants.entryArrayKey) as? Data {
            self.savedEntries = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! [TransitEntry]
        }
        
        //Getting the stops from the user defaults
        if let stops = UserDefaults.standard.array(forKey: Constants.entryArrayKey) as? [TransitEntry] {
            self.savedEntries = stops
        }
    }
    
    var numberOfPredictionsToShow: Int = 3 {
        didSet {
            UserDefaults.standard.set(self.numberOfPredictionsToShow, forKey: Constants.numberOfPredictionsKey)
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
    
    var savedEntries: [TransitEntry] = [] {
        didSet {
            //Convert array to Data first, then UserDefaults can save it
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedEntries)
            UserDefaults.standard.set(archivedObject, forKey: Constants.entryArrayKey)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
}
