//
//  AppDelegate.swift
//  TransitBar
//
//  Created by Adam Boyd on 2016-10-11.
//  Copyright © 2016 adam. All rights reserved.
//

import Cocoa
import SwiftBus
#if SPARKLE
import Sparkle
#endif
import Fabric
import Crashlytics
import CoreLocation
import MapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, TransitManagerDelegate {
    
    //Item that lives in the status bar
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    /// This is the icon when there is nothing to show in the menubar
    private var emptyStatusBarTemplateImage: NSImage {
        let image = #imageLiteral(resourceName: "TemplateIcon")
        image.isTemplate = true
        return image
    }
    
    
    private let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    private var listWindowController: NSWindowController?
    private var aboutWindowController: NSWindowController?
    private var alertsWindowController: NSWindowController?
    private var notificationsWindowController: NSWindowController?
    
    private let transitManager = TransitManager()
    private lazy var statusBarManager = StatusBarManager(statusItem: self.statusItem, dataController: DataController.shared, delegate: self)
    private var touchBarManager: TouchBarManager?
    
    override init() {
        if #available(OSX 10.12.2, *) {
            //Starting up the touch bar
            self.touchBarManager = TouchBarManager(entries: DataController.shared.savedEntries)
        }
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Fabric
        Fabric.with([Crashlytics.self])
        
        //See https://docs.fabric.io/apple/crashlytics/os-x.html
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])

        //Setting up the status bar menu and the actions from that
        _ = self.statusBarManager
        
        //Setting up transit manager
        self.transitManager.delegate = self
        self.transitManager.loadData()
        self.transitManager.determineTrackingLocation()
        
        #if SPARKLE
            //Setting up the Sparkle updater
            SUUpdater.shared().automaticallyChecksForUpdates = true
        #endif
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.entriesChanged), name: .entriesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.determineTrackingLocation), name: .displayWalkingTimeChanged, object: nil)
        
        if DataController.shared.savedEntries.isEmpty {
            self.openSettingsWindow()
        }
        
        NSUserNotificationCenter.default.delegate = self
        
        self.touchBarManager?.makeVisibleIfAvailable()
        
    }
    
    // MARK: - Responding to delegate events
    
    /// If the entries, changed, need to recreate menu items as might need to insert/remove items
    @objc
    private func entriesChanged() {
        self.statusBarManager.createMenuItems()
    }
    
    @objc
    func determineTrackingLocation() {
        self.transitManager.determineTrackingLocation()
    }
    
    // MARK: - Notifications
    
    /// Checks if this entry has notifications waiting, and if it matches all conditions, sends the notification
    ///
    /// - Parameter entry: entry to look at
    /// - Parameter predictions: predictions for this entry
    private func checkForNotificationsToSend(for entry: TransitEntry, predictions: [TransitPrediction]) {
        //Check for notifications here
        for (index, notification) in DataController.shared.scheduledNotifications.enumerated() {
            
            //Notification is for this item
            if notification.entry.stop.stopTag == entry.stop.stopTag && notification.entry.stop.routeTag == entry.stop.routeTag {
                
                //This filter call leaves in predictions that are less than or equal to the notification's minutes and greater than 5 - the notification's minutes. If this is nonnil, we should send the user a notification
                let firstValid = predictions.first(where: { $0.predictionInMinutes <= notification.minutesForFirstPredicion && $0.predictionInMinutes > notification.minutesForFirstPredicion - 5 })
                
                if let firstValid = firstValid {
                    
                    //Remove this and send notification
                    print("Sending user notification for alert")
                    DataController.shared.scheduledNotifications.remove(at: index)
                    self.sendNotificationFor(notification, firstPredictionInMinutes: firstValid.predictionInMinutes)
                    
                }
            }
        }
    }
    
    
    @objc
    func userWantsToSetNotificationFor(_ sender: Any?) {
        guard let item = self.statusItem.menu?.highlightedItem else { return }
        guard let index = self.statusItem.menu?.index(of: item) else { return }
        
        print("User wants to set notification, selected menu item: \(index)")
        let alert = NSAlert()
        alert.messageText = "Enter the number of minutes you'd like to be alerted before the bus or train arrives"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        //Textfield where user will enter the time
        let textField = NSTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.placeholderString = "5"
        alert.accessoryView = textField
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            let minutes = textField.integerValue
            if minutes > 0 {
                
                //Valid, create notification
                print("User entered \(minutes) minutes")
                let notification = TransitNotification()
                notification.entry = self.statusBarManager.entryForMenuIndex(index)
                notification.minutesForFirstPredicion = minutes
                
                DataController.shared.scheduledNotifications.append(notification)
                
            } else {
                
                //Not valid
                print("User didn't enter a valid number")
                
            }
        } else {
            print("User hit cancel cancel")
        }
    }
    
    // MARK: - Automatic updates
    
    #if SPARKLE
    /**
     Checks Sparkle to see if there are any updates
     */
    @objc
    private func checkForUpdates() {
        SUUpdater.shared().checkForUpdates(self)
    }
    #endif
    
    // MARK: - Opening window
    
    /**
     Opens the settings window
     */
    private func openSettingsWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mainWindow")) as? NSWindowController else { return }
        self.listWindowController = windowController
        self.listWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    /**
     Opens the about window
     */
    private func openAboutWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "aboutWindow")) as? NSWindowController else { return }
        self.aboutWindowController = windowController
        self.aboutWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    /// Opens the window that has all the alerts
    func openAlertsWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "alertsWindow")) as? NSWindowController else { return }
        self.alertsWindowController = windowController
        self.alertsWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    /// Opens the notification window
    func openNotificationsWindow() {
        guard let windowController = self.storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "notificationsWindow")) as? NSWindowController else { return }
        self.notificationsWindowController = windowController
        self.notificationsWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        //Always return true. Usually notifications are only delivered if application is key. However, this is a menubar application and will never be key.
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        self.openAlertsWindow()
    }
    
    // MARK: TransitManagerDelegate
    
    func userLocationUpdated(_ newLocation: CLLocation?) {
        self.entriesChanged()
    }
    
    func transitPredictionsUpdated() {
        self.statusBarManager.updateMenuItems()
        self.touchBarManager?.updatePredictions(entries: DataController.shared.savedEntries)
        
        if let alertsVC = self.alertsWindowController?.contentViewController as? AlertsViewController {
            //If the user has the alerts vc open, reload the messages, as they might have changed
            alertsVC.tableView.reloadData()
        }
    }
    
    /// Sends notifications to the user. This method will send notifications to the user for all the new messages that are not contained in the old messages with high priority.
    ///
    /// - Parameters:
    ///   - newMessages: messages from the most recent prediction
    ///   - oldMessages: messages from the old prediction
    ///   - route: title of the route for notification
    func sendNotificationsToUser(with newMessages: [TransitMessage], differingFrom oldMessages: [TransitMessage], on route: String) {
        
        //Create sets of the message strings for transit messages that have a high priority. They are sets so it is easy to perform diffs.
        let oldMessageSet = Set(oldMessages.filter({ $0.priority == .high }).map({ $0.text }))
        let newMessageSet = Set(newMessages.filter({ $0.priority == .high }).map({ $0.text }))
        
        let messagesToNotify = newMessageSet.subtracting(oldMessageSet)
        
        //Go through each notification and send it
        for message in messagesToNotify {
            let notification = NSUserNotification()
            notification.title = "\(route) Alert"
            notification.informativeText = message
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    /// Sends user notification
    ///
    /// - Parameters:
    ///   - notification: notification to send to user
    ///   - firstPredictionInMinutes: value of the first prediction
    func sendNotificationFor(_ notification: TransitNotification, firstPredictionInMinutes: Int) {
        let userNotification = NSUserNotification()
        userNotification.title = "\(notification.entry.stop.routeTag) Alert"
        userNotification.informativeText = "Your bus or train is coming in \(firstPredictionInMinutes) minutes"
        NSUserNotificationCenter.default.deliver(userNotification)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Status bar

extension AppDelegate: StatusBarManagerDelegate {
    
    var mostRecentUserLocation: CLLocation? {
        return self.transitManager.currentLocation
    }
    
    func statusBarManager(_ statusBarManager: StatusBarManager, requestDirectionsTo destination: CLLocation?, completion: @escaping (MKDirectionsRequest?) -> Void) {
        self.transitManager.directionsRequestFrom(source: self.transitManager.currentLocation, destination: destination, completion: completion)
    }
    
    func statusBarManager(_ statusBarManager: StatusBarManager, requestsCheckForNotificationsToSendFor entry: TransitEntry, predictions: [TransitPrediction]) {
        self.checkForNotificationsToSend(for: entry, predictions: predictions)
    }
    
    func statusBarManager(_ statusBarManager: StatusBarManager, requestsSetNotificationFor sender: Any) {
        self.userWantsToSetNotificationFor(sender)
    }
    
    func statusBarManagerCheckForUpdates(_ statusBarManager: StatusBarManager) {
        SUUpdater.shared().checkForUpdates(self)
    }
    
    func statusBarManagerOpenAboutWindow(_ statusBarManager: StatusBarManager) {
        self.openAboutWindow()
    }
    
    func statusBarManagerOpenAlertsWindow(_ statusBarManager: StatusBarManager) {
        self.openAlertsWindow()
    }
    
    func statusBarManagerOpenNotificationsWindow(_ statusBarManager: StatusBarManager) {
        self.openNotificationsWindow()
    }
    
    func statusBarManagerOpenSettingsWindow(_ statusBarManager: StatusBarManager) {
        self.openSettingsWindow()
    }
    
    func statusBarManagerRequestsToTerminate(_ statusBarManager: StatusBarManager) {
        NSApplication.shared.terminate(self)
    }
    
}
