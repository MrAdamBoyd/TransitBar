//
//  NSMenuItem+Target.swift
//  TransitBar
//
//  Created by Adam on 1/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import AppKit

extension NSMenuItem {
    static func menuItem(withTitle string: String, target: AnyObject?, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        let menuItem = NSMenuItem(title: string, action: selector, keyEquivalent: charCode)
        menuItem.target = target
        return menuItem
    }
}
