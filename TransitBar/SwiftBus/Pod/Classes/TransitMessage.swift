//
//  TransitMessage.swift
//  Pods
//
//  Created by Adam Boyd on 2016-12-30.
//
//

import Foundation

private let messageEncoderString = "messageEncoder"
private let priorityEncoderString = "priorityEncodier"

public enum TransitMessagePriority: Int {
    case low = 0, medium, high
    
    init(_ priority: String) {
        switch priority {
        case "Low":     self = .low
        case "Normal":  self = .medium
        default:        self = .high
        }
    }
}

open class TransitMessage: NSObject, NSCoding {
    
    open var text: String = ""
    open var priority: TransitMessagePriority = .low
    
    //Basic init
    public override init() { super.init() }
    
    //Full init
    public init(message text: String, priority: TransitMessagePriority) {
        self.text = text
        self.priority = priority
    }
    
    // MARK: - NSCoding
    public required init(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObject(forKey: messageEncoderString) as? String ?? ""
        self.priority = TransitMessagePriority(rawValue: aDecoder.decodeInteger(forKey: priorityEncoderString)) ?? .low
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.text, forKey: messageEncoderString)
        aCoder.encode(self.priority.rawValue, forKey: priorityEncoderString)
    }
}
