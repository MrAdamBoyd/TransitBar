//
//  NotificationsViewController.swift
//  TransitBar
//
//  Created by Adam Boyd on 17/4/12.
//  Copyright © 2017 adam. All rights reserved.
//

import Foundation
import Cocoa

class NotificationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var notifications: [TransitNotification] = DataController.shared.scheduledNotifications
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsChanged), name: .notificationsChanged, object: nil)
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
            DataController.shared.scheduledNotifications.remove(at: index)
        }
        
        self.notificationsChanged()
    }
    
    func notificationsChanged() {
        self.notifications = DataController.shared.scheduledNotifications
        self.tableView.reloadData()
    }
    
    // MARK: NSTableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        guard let title = tableColumn?.title else { return nil }
        
        let notification = self.notifications[row]
        
        if title == "Route" {
            return notification.entry.stop.routeTag
        } else if title == "Stop" {
            return notification.entry.stop.stopTitle
        } else {
            return notification.minutesForFirstPredicion
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
