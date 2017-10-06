//
//  SwiftBusResult.swift
//  Pods
//
//  Created by Adam on 10/2/17.
//

import Foundation

public enum SwiftBusResult<T> {
    case success(T), error(Error)
}
