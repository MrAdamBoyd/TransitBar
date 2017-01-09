//
//  AlertsViewController.swift
//  TransitBar
//
//  Created by Adam Boyd on 2017-01-08.
//  Copyright © 2017 adam. All rights reserved.
//

import Foundation
import Cocoa
import SwiftBus

class AlertsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    
    var routeTitles: [String] = []
    var messages: [TransitMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.string = "Click on an alert above to view the message."
        
        for entry in DataController.shared.savedEntries {
            for message in entry.stop.messages {
                self.messages.append(message)
                self.routeTitles.append(entry.stop.routeTitle)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        guard let title = tableColumn?.title else { return nil }
        
        if title == "Route" {
            return self.routeTitles[row]
        } else {
            switch self.messages[row].priority {
            case .low:      return "Low"
            case .medium:   return "Medium"
            case .high:     return "High"
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        self.textView.string = self.messages[row].text
        return true
    }
}
