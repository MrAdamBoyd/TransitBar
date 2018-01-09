//
//  TransitTouchBarItem.swift
//  TransitBar
//
//  Created by Adam on 1/8/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit
import SwiftBus

@available(OSX 10.12.2, *)
final class TransitTouchBarItem: NSTouchBarItem {
    
    // MARK: - Properties
    
    private lazy var textField = NSTextField(frame: .zero)
    
    //This is where the system is told where the view for the item should be
    override var view: NSView? {
        return self.textField
    }
    
    // MARK: - Initializing
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init(entry: TransitEntry) {
        super.init(identifier: NSTouchBarItem.Identifier(entry: entry))
    }
    
    // MARK: - Methods
    
    func format(with entry: TransitEntry, predictions: [TransitPrediction]) {
        self.textField.stringValue = "\(entry.stop.routeTag): \(predictions.format())"
    }
}
