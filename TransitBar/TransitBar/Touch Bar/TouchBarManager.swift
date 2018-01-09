//
//  TouchBarManager.swift
//  TransitBar
//
//  Created by Adam on 1/8/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit

final class TouchBarManager {
    
    // MARK: - Properties
    
    private let identifier = "TransitBar"
    private var touchBarViewContoller: NSViewController?
    private var touchBarWindow: NSWindow?
    
    // MARK: - Initializing
    
    init(entries: [TransitEntry]) {
        if #available(OSX 10.12.2, *) {
            //Starting up the touch bar
            self.touchBarViewContoller = TouchBarViewController(entries: entries)
            self.touchBarWindow = NSWindow(contentViewController: self.touchBarViewContoller!)
        }
    }
    
    /// Makes the touch bar visible if it's available on the system
    func makeVisibleIfAvailable() {
        if #available(OSX 10.12.2, *) {
            DFRSystemModalShowsCloseBoxWhenFrontMost(true)
            let customTouchBarItem = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: self.identifier))
            let customTouchBarItemButton = NSButton(title: "", image: #imageLiteral(resourceName: "TemplateIcon"), target: self, action: #selector(self.touchBarButtonTapped))
            customTouchBarItem.view = customTouchBarItemButton
            NSTouchBarItem.addSystemTrayItem(customTouchBarItem)
            DFRElementSetControlStripPresenceForIdentifier(customTouchBarItem.identifier.rawValue, true)
            
            self.touchBarWindow?.touchBar = self.touchBarViewContoller?.touchBar
            self.touchBarWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc
    @available(OSX 10.12.2, *)
    private func touchBarButtonTapped() {
        guard let touchBar = self.touchBarViewContoller?.touchBar else { return }
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: self.identifier)
    }
}
