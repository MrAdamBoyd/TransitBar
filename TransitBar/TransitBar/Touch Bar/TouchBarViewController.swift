//
//  TouchBarViewController.swift
//  TransitBar
//
//  Created by Adam on 1/8/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit

@available(OSX 10.12.2, *)
final class TouchBarViewController: NSViewController {
    
    // MARK: - Properties
    
    private var entries: [TransitEntry] = []
    private lazy var transitTouchBar = TransitTouchBar(entries: self.entries)
    
    // MARK: - Initializing
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init(entries: [TransitEntry]) {
        super.init(nibName: nil, bundle: nil)
        self.entries = entries
    }
    
    // MARK: - Methods
    
    //Should have no visible view
    override func loadView() {
        self.view = NSView()
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return self.transitTouchBar
    }
    
    // MARK: - Updating predictions
}
