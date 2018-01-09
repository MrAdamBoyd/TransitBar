//
//  TransitPrediction+Format.swift
//  TransitBar
//
//  Created by Adam on 1/9/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation
import SwiftBus

extension Collection where Iterator.Element: TransitPrediction {
    
    /// This returns a string of the predictions in the array. Example: "1, 5, 9 mins" for array of [1, 5, 9, 10, 17] assuming maxCount is 3.
    ///
    /// - Parameter maxCount: number of predictions to include. If number of predictions is less than this, includes all of them
    /// - Returns: formatted string
    func format(maxCount: Int = 3) -> String {
        if self.isEmpty {
            return "--"
        } else {
            let predictionsToCheck = Array(self.prefix(maxCount))
            let predictionsWithBrackets = "\(predictionsToCheck.map({ $0.predictionInMinutes }))"
            let prettyPredictions = String(predictionsWithBrackets.dropFirst().dropLast())
            
            return prettyPredictions
        }
    }
}
