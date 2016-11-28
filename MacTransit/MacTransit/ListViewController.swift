//
//  ViewController.swift
//  MacTransit
//
//  Created by Adam Boyd on 2016-10-11.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import SwiftBus

protocol MainAppViewController {
    var savedStops: [TransitEntry] { get set }
    func showAbout()
}

fileprivate let entryArrayKey = "entryArrayKey"

class ListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NewStopDelegate {

    @IBOutlet weak var createNewLineButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var savedStops: [TransitEntry] = [] {
        didSet {
            self.tableView.reloadData()
            
            //Convert array to Data first, then UserDefaults can save it
            let archievedObject = NSKeyedArchiver.archivedData(withRootObject: self.savedStops)
            UserDefaults.standard.set(archievedObject, forKey: entryArrayKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Get data from user defaults and then convert from data to array of entries
        if let unarchivedObject = UserDefaults.standard.object(forKey: entryArrayKey) as? Data {
            self.savedStops = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as! [TransitEntry]
        }
        
        //Getting the stops from the user defaults
        if let stops = UserDefaults.standard.array(forKey: entryArrayKey) as? [TransitEntry] {
            self.savedStops = stops
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //Interrupt segue and set this view controller as the delegate
        guard let identifier = segue.identifier, identifier == "showNewLine" else {
            return
        }
        
        guard let windowController = segue.destinationController as? NSWindowController, let viewController = windowController.contentViewController as? NewLineViewController else {
            return
        }
        
        viewController.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func createNewLineAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showNewLine", sender: self)
    }
    
    func showAbout() {
        self.performSegue(withIdentifier: "showAbout", sender: self)
    }
    
    // MARK: - NewStopDelegate
    func newStopControllerDidAdd(newEntry: TransitEntry) {
        print("Did select new stop")
        self.savedStops.append(newEntry)
    }

    // MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.savedStops.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        guard let title = tableColumn?.title else { return nil }
        
        let entry = self.savedStops[row]
        
        switch title {
        case "Route":
            return entry.stop.routeTitle
        case "Stop":
            return entry.stop.stopTitle
        case "Direction":
            return entry.stop.direction
        default:
            if let times = entry.times {
                
                //Date formatter for just the hours and minutes
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm"
                
                //Formats time "xx:xx - yy:yy"
                if times.0 < times.1 {
                    return "\(dateFormatter.string(from: times.0)) - \(dateFormatter.string(from: times.1))"
                } else {
                    return "\(dateFormatter.string(from: times.1)) - \(dateFormatter.string(from: times.0))"
                }
                
            } else {
                return "Always shown"
            }
        }
    }
    
}
