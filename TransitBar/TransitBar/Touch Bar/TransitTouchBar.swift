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
    
    /// Lets the touch bar items know that the predictions are updated
    ///
    /// - Parameter entries: entries with predictions
    func updatePredictions(entries: [TransitEntry]) {
        for entry in entries {
            if let predictions = entry.stop.predictions[entry.stop.direction] {
                self.item(for: entry)?.format(with: entry, predictions: predictions)
            }
        }
    }
    
    /// Gets the touch bar item for the entry
    ///
    /// - Parameter entry: entry to filter by
    /// - Returns: optional item
    private func item(for entry: TransitEntry) -> TransitTouchBarItem? {
        let identifier = NSTouchBarItem.Identifier(entry: entry)
        let matchingItems = self.items.filter({ $0.identifier == identifier })
        return matchingItems.first
    }
    
}
