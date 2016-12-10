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
    var savedEntries: [TransitEntry] { get set }
    func showAbout()
}

class ListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NewStopDelegate {

    @IBOutlet weak var createNewLineButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func keyDown(with event: NSEvent) {
        
        guard let key = event.charactersIgnoringModifiers?.characters.first else { return }
        
        guard key == Character(UnicodeScalar(NSDeleteCharacter)!) else {
            super.keyDown(with: event)
            return
        }
        
        guard self.tableView.selectedRowIndexes.count != 0 else {
            super.keyDown(with: event)
            return
        }
        
        //Continue if the key is the delete key
        
        //Need to go in reverse because we could be deleting multiple rows
        for index in self.tableView.selectedRowIndexes.reversed() {
            print("Removing entry at index \(index)")
            DataController.shared.savedEntries.remove(at: index)
        }
        
        self.tableView.reloadData()
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
        DataController.shared.savedEntries.append(newEntry)
        self.tableView.reloadData()
    }

    // MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DataController.shared.savedEntries.count
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        guard let title = tableColumn?.title else { return nil }
        
        let entry = DataController.shared.savedEntries[row]
        
        switch title {
        case "Route":
            return entry.stop.routeTitle
        case "Stop":
            return entry.stop.stopTitle
        case "Direction":
            return entry.stop.direction
        default:
            if let times = entry.times {
                
                guard let earlier = times.0, let later = times.1 else {
                    return "Never"
                }
                
                //Date formatter for just the hours and minutes
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm"
                
                //Formats time "xx:xx - yy:yy"
                return "From \(dateFormatter.string(from: earlier)) to \(dateFormatter.string(from: later))"
                
            } else {
                return "Always"
            }
        }
    }
    
}
