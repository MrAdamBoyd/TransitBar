//
//  TransitTouchBar.swift
//  TransitBar
//
//  Created by Adam on 1/8/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit
import SwiftBus

@available(OSX 10.12.2, *)
final class TransitTouchBar: NSTouchBar {
    
    // MARK: - Properties
    
    //Each of the entries
    private var entries: [TransitEntry] = []
    //Each of the touch bar items
    private lazy var items: [TransitTouchBarItem] = self.entries.map({ TransitTouchBarItem(entry: $0) })
    
    // MARK: - Initializing
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    init(entries: [TransitEntry]) {
        super.init()
        self.entries = entries
        self.templateItems = Set(self.items)
        self.defaultItemIdentifiers = [.fixedSpaceSmall, .flexibleSpace] + items.flatMap { [$0.identifier, .flexibleSpace] } + [.fixedSpaceSmall]
    }
    
}
