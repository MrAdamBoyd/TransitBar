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
    
}
