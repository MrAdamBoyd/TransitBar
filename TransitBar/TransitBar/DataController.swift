//
//  DataController.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-12-05.
//  Copyright © 2016 adam. All rights reserved.
//

import Foundation

class DataController: NSObject {
    
    private lazy var appDefaults = UserDefaults(suiteName: Constants.userDefaultsName)
    
    static var shared = DataController()
    
    override init() {
        super.init()
        
        if self.storeInCloud {
            NotificationCenter.default.addObserver(self, selector: #selector(self.getDataFromDefaults), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        
        self.getDataFromDefaults()
    }
    
    //Not persisted
    var scheduledNotifications: [TransitNotification] = [] {
        didSet {
            NotificationCenter.default.post(name: .notificationsChanged, object: nil)
        }
    }
    
    var numberOfPredictionsToShow: Int = 3 {
        didSet {
            self.set(any: self.numberOfPredictionsToShow, for: Constants.numberOfPredictionsKey)
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
    
    var storeInCloud: Bool = false {
        didSet {
            self.set(any: self.storeInCloud, for: Constants.storeInCloudKey)
            NotificationCenter.default.post(name: .storeInCloudChanged, object: nil)
            
            //Just changed where we are storing the defaults. So now, save the current in memory settings to the new defaults location, overwriting any old settings there
            self.resetData()
            
            if self.storeInCloud {
                //Register for the notification and sync the data
                NotificationCenter.default.addObserver(self, selector: #selector(self.getDataFromDefaults), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
                NSUbiquitousKeyValueStore.default.synchronize()
            } else {
                //For the entry changed notification
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    var displayWalkingTime: Bool = false {
        didSet {
            self.set(any: self.displayWalkingTime, for: Constants.walkingTimeKey)
            NotificationCenter.default.post(name: .displayWalkingTimeChanged, object: nil)
        }
    }
    
    var savedEntries: [TransitEntry] = [] {
        didSet {
            //Convert array to Data first, then UserDefaults can save it
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedEntries)
            self.set(any: archivedObject, for: Constants.entryArrayKey)
            
            NotificationCenter.default.post(name: .entriesChanged, object: nil)
        }
    }
    
    // MARK: - Getting and setting values
    
    @objc func getDataFromDefaults() {
        //Number of predictions to show
        if let numberOfPredictions = self.getInt(for: Constants.numberOfPredictionsKey), numberOfPredictions != 0 {
            self.numberOfPredictionsToShow = numberOfPredictions
        }
        
        if let displayWalkingTime = self.getBool(for: Constants.walkingTimeKey) {
            self.displayWalkingTime = displayWalkingTime
        }
        
        //Get data from user defaults and then convert from data to array of entries
        if let unarchivedObject = self.getData(for: Constants.entryArrayKey) {
            self.savedEntries = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! [TransitEntry]
        }
        
        //NOTE: This always needs to be the last one saved
        if let storeInCloud = self.getBool(for: Constants.storeInCloudKey) {
            self.storeInCloud = storeInCloud
        }
    }
    
    func resetData() {
        self.set(any: self.numberOfPredictionsToShow, for: Constants.numberOfPredictionsKey)
        self.set(any: self.storeInCloud, for: Constants.storeInCloudKey)
        self.set(any: self.displayWalkingTime, for: Constants.walkingTimeKey)
        //Convert array to Data first, then UserDefaults can save it
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedEntries)
        self.set(any: archivedObject, for: Constants.entryArrayKey)
    }
    
    fileprivate func getBool(for key: String) -> Bool? {
        
        if key == Constants.storeInCloudKey {
            //Always get this locally
            return self.appDefaults?.bool(forKey: key)
        }
        
        if self.storeInCloud {
            return NSUbiquitousKeyValueStore.default.bool(forKey: key)
        } else {
            return self.appDefaults?.bool(forKey: key)
        }
    }
    
    fileprivate func getInt(for key: String) -> Int? {
        if self.storeInCloud {
            return Int(NSUbiquitousKeyValueStore.default.double(forKey: key))
        } else {
            return self.appDefaults?.integer(forKey: key)
        }
    }
    
    fileprivate func getData(for key: String) -> Data? {
        if self.storeInCloud {
            return NSUbiquitousKeyValueStore.default.object(forKey: key) as? Data
        } else {
            return self.appDefaults?.object(forKey: key) as? Data
        }
    }
    
    // Setting values
    fileprivate func set(any: Any, for key: String) {
        if self.storeInCloud && key != Constants.storeInCloudKey {
            NSUbiquitousKeyValueStore.default.set(any, forKey: key)
            NSUbiquitousKeyValueStore.default.synchronize()
        } else {
            self.appDefaults?.set(any, forKey: key)
            self.appDefaults?.synchronize()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
