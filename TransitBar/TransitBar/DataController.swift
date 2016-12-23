//
//  DataController.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-12-05.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation

class DataController {
    
    private lazy var appDefaults = UserDefaults(suiteName: Constants.userDefaultsName)
    
    static let shared = DataController()
    
    private init() {
        //Number of predictions to show
        if let numberOfPredictions = self.appDefaults?.integer(forKey: Constants.numberOfPredictionsKey), numberOfPredictions != 0 {
            self.numberOfPredictionsToShow = numberOfPredictions
        }
        
        //Get data from user defaults and then convert from data to array of entries
        if let unarchivedObject = self.appDefaults?.object(forKey: Constants.entryArrayKey) as? Data {
            self.savedEntries = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! [TransitEntry]
        }
        
        //Getting the stops from the user defaults
        if let stops = self.appDefaults?.array(forKey: Constants.entryArrayKey) as? [TransitEntry] {
            self.savedEntries = stops
        }
    }
    
    var numberOfPredictionsToShow: Int = 3 {
        didSet {
            self.appDefaults?.set(self.numberOfPredictionsToShow, forKey: Constants.numberOfPredictionsKey)
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
    
    var savedEntries: [TransitEntry] = [] {
        didSet {
            //Convert array to Data first, then UserDefaults can save it
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedEntries)
            self.appDefaults?.set(archivedObject, forKey: Constants.entryArrayKey)
            self.appDefaults?.synchronize()
            
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
}
