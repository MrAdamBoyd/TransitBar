//
//  TransitManager.swift
//  TransitBar
//
//  Created by Adam Boyd on 17/4/12.
//  Copyright © 2017 adam. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import SwiftBus

protocol TransitManagerDelegate: class {
    func userLocationUpdated(_ newLocation: CLLocation?)
    func transitPredictionsUpdated()
    func sendNotificationsToUser(with newMessages: [TransitMessage], differingFrom oldMessages: [TransitMessage], on route: String)
}

final class TransitManager: NSObject, CLLocationManagerDelegate {
    
    weak var delegate: TransitManagerDelegate?
    private var minuteTimer: Timer!
    
    //Location
    var locManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            self.delegate?.userLocationUpdated(self.currentLocation)
        }
    }
    
    override init() {
        super.init()
        
        //Setting up notifications when the user changes settings or the computer wakes up
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleComputerWake), name: NSWorkspace.didWakeNotification, object: nil)
        
        //Refresh data every 60 seconds
        self.minuteTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
    }
    
    /// Called when the computer wakes from sleep. Loads the data immediately and resets the computer's location
    @objc
    func handleComputerWake() {
        self.loadData()
        self.determineTrackingLocation()
    }
    
    /// Loads the predictions for all current stops
    @objc
    func loadData() {
        print("Loading data...")
        
        let entries = DataController.shared.savedEntries
        
        guard !entries.isEmpty else { return }
        
        let firstItemAgency = entries[0].stop.agencyTag
        
        let numberOfStopsWithSameAgency = entries.filter({ $0.stop.agencyTag == firstItemAgency }).count
        
        if numberOfStopsWithSameAgency == entries.count {
            
            //All stops with same agency, can get them all at once
            
            let stops = entries.map({ $0.stop! })
            SwiftBus.shared.stopPredictions(forStops: stops) { [weak self] result in
                
                switch result {
                case let .success(stops):
                    //Stops not guaranteed to be in the same order, so they need to be reordered
                    
                    for entry in entries {
                        for stop in stops {
                            if entry.stop.stopTag == stop.stopTag && entry.stop.routeTag == stop.routeTag {
                                self?.saveDataFrom(stop, to: entry, with: nil)
                                break
                            }
                        }
                    }
                case let .error(error):
                    entries.forEach({ self?.saveDataFrom(nil, to: $0, with: error) })
                }
                
                self?.delegate?.transitPredictionsUpdated()
            }
            
        } else {

            //Need to get all the predictions individually
            
            let group = DispatchGroup()
            
            for entry in entries {
                group.enter()
                
                SwiftBus.shared.stopPredictions(forStop: entry.stop) { [weak self] result in
                    
                    switch result {
                    case let .success(stop):
                        self?.saveDataFrom(stop, to: entry, with: nil)
                    case let .error(error):
                        self?.saveDataFrom(nil, to: entry, with: error)
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: DispatchQueue.main) { [weak self] in
                self?.delegate?.transitPredictionsUpdated()
            }
            
        }
    }
    
    /// Saves the information from a transitstop object to a transitentry object. Also sends notification if notification should be sent
    ///
    /// - Parameters:
    ///   - stop: stop that has prediction and message information
    ///   - entry: entry that the information should be saved to
    ///   - error: any error that occurred while saving the info
    fileprivate func saveDataFrom(_ stop: TransitStop?, to entry: TransitEntry, with error: Error?) {
        if let stop = stop {
            
            //Only show alerts if it's in the menu bar
            if entry.shouldBeShownInMenuBar {
                self.delegate?.sendNotificationsToUser(with: stop.messages, differingFrom: entry.stop.messages, on: stop.routeTitle)
            }
            
            entry.stop.predictions = stop.predictions
            entry.stop.messages = stop.messages
        }
        
        entry.error = error
    }
    
    // MARK: - Managing locations
    
    /// Starts or stops tracking the user's location
    @objc
    func determineTrackingLocation() {
        if DataController.shared.displayWalkingTime {
            self.locManager.delegate = self
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locManager.startUpdatingLocation()
            self.locManager.startMonitoringSignificantLocationChanges()
        } else {
            self.locManager.stopUpdatingLocation()
            self.locManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    /// Builds an MKDirectionsRequest from the provided source and destination locations
    ///
    /// - Parameters:
    ///   - source: where the user currently is
    ///   - destination: location of the transit stop
    ///   - completion: contains the finished mkdirectionsrequest
    func directionsRequestFrom(source: CLLocation?, destination: CLLocation?, completion: @escaping (MKDirectionsRequest?) -> Void) {
        guard let sourceLocation = source, let destinationLocation = destination else {
            //Only works if both items have a location
            completion(nil)
            return
        }
        
        var sourceMapItem: MKMapItem?
        var destMapItem: MKMapItem?
        
        //Using a dispatch group for organizing the async work
        let group = DispatchGroup()
        group.enter() //For source
        group.enter() //For destination
        
        let geocoder1 = CLGeocoder()
        geocoder1.reverseGeocodeLocation(sourceLocation) { [unowned self] placemarks, _ in
            sourceMapItem = self.mkmapItemFrom(placemarks: placemarks)
            group.leave()
        }
        
        let geocoder2 = CLGeocoder()
        geocoder2.reverseGeocodeLocation(destinationLocation) { [unowned self] placemarks, _ in
            destMapItem = self.mkmapItemFrom(placemarks: placemarks)
            group.leave()
        }
        
        group.notify(queue: .main) {
            //Work is now done
            let request = MKDirectionsRequest()
            request.source = sourceMapItem
            request.destination = destMapItem
            request.requestsAlternateRoutes = true
            request.transportType = .walking
            
            completion(request)
        }
    }
    
    /// builds an MKMapItem from the provided array of placemarks
    ///
    /// - Parameter placemarks: optional array of placemarks
    /// - Returns: optional map item
    func mkmapItemFrom(placemarks: [CLPlacemark]?) -> MKMapItem? {
        if let placemark = placemarks?.first {
            return MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: placemark.addressDictionary as! [String: AnyObject]?))
        } else {
            return nil
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else {
            print("No location provided")
            return
        }
        
        let distance = self.currentLocation?.distance(from: newLocation)
        if self.currentLocation == nil || abs(distance ?? 0) > 5 {
            self.currentLocation = newLocation
            print("New location: \(newLocation)")
            return
        }
        
        if newLocation.horizontalAccuracy < 100 {
            print("User's location is stable, no longer updating data")
            self.locManager.stopUpdatingLocation()
        }
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
