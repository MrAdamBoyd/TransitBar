//
//  ViewController.swift
//  TransitBar
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

class ListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NewStopDelegate {

    @IBOutlet weak var createNewLineButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var numberOfItemsToShowTextField: NSTextField!
    @IBOutlet weak var icloudSettingsButton: NSButton!
    @IBOutlet weak var walkTimeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUIFromSettings(reloadData: false)
        self.icloudSettingsButton.state = NSControl.StateValue(rawValue: DataController.shared.storeInCloud ? 1 : 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUIFromSettings), name: .entriesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUIFromSettings), name: .displayWalkingTimeChanged, object: nil)
        
        self.numberOfItemsToShowTextField.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //Interrupt segue and set this view controller as the delegate
        guard let identifier = segue.identifier, identifier.rawValue == "showNewLine" else {
            return
        }
        
        guard let windowController = segue.destinationController as? NSWindowController, let viewController = windowController.contentViewController as? NewLineViewController else {
            return
        }
        
        viewController.delegate = self
    }
    
    override func keyDown(with event: NSEvent) {
        
        guard let key = event.charactersIgnoringModifiers?.first else { return }
        
        guard key == Character(UnicodeScalar(NSDeleteCharacter)!) else {
            super.keyDown(with: event)
            return
        }
        
        guard !self.tableView.selectedRowIndexes.isEmpty else {
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
    
    @objc
    func setUIFromSettings(reloadData: Bool = true) {
        self.numberOfItemsToShowTextField.intValue = Int32(DataController.shared.numberOfPredictionsToShow)
        self.walkTimeButton.state = NSControl.StateValue(rawValue: DataController.shared.displayWalkingTime ? 1 : 0)
        if reloadData { self.tableView.reloadData() }
    }
    
    // MARK: - Actions
    
    @IBAction func createNewLineAction(_ sender: Any) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showNewLine"), sender: self)
    }
    
    @IBAction func viewNotificationsAction(_ sender: Any) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.openNotificationsWindow()
        }
    }

    @IBAction func viewAlertsAction(_ sender: Any) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.openAlertsWindow()
        }
    }
    
    @IBAction func icloudSettingsClicked(_ sender: Any) {
        DataController.shared.storeInCloud = self.icloudSettingsButton.state == .on
    }
    
    @IBAction func walkTimeButtonClicked(_ sender: Any) {
        DataController.shared.displayWalkingTime = self.walkTimeButton.state == .on
    }
    
    func showAbout() {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showAbout"), sender: self)
    }
    
    // MARK: - NewStopDelegate
    
    func newStopControllerDidAdd(newEntry: TransitEntry) {
        print("Did select new stop")
        DataController.shared.savedEntries.append(newEntry)
        self.tableView.reloadData()
    }
    
    // MARK: - NSTextFieldDelegate
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        if let entered = self.numberOfItemsToShowTextField?.intValue, entered > 0, entered < 10 {
        
            //Only allow values of above 0 and less than 10
            DataController.shared.numberOfPredictionsToShow = Int(entered)
            return true
        
        }
        
        return false
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
