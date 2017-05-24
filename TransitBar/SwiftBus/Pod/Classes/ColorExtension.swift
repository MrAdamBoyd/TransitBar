//
//  ColorExtension.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation

#if os(OSX)
typealias SwiftBusColor = NSColor
#else
import UIKit
typealias SwiftBusColor = UIColor
#endif

extension SwiftBusColor {
    public convenience init(rgba: String) {
        let colorValues = parseRGBAString(rgba)
        
        self.init(red:colorValues.red, green:colorValues.green, blue:colorValues.blue, alpha:colorValues.alpha)
    }
}

//Parsing the string
private func parseRGBAString(_ rgba: String) -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
    var red:   CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue:  CGFloat = 0.0
    var alpha: CGFloat = 1.0
    
    if rgba.hasPrefix("#") {
        let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
        let hex     = rgba.substring(from: index)
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.characters.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
            }
        } else {
            print("Scan hex error")
        }
    } else {
        print("Invalid RGB string, missing '#' as prefix")
    }
    
    return (red, green, blue, alpha)
}
