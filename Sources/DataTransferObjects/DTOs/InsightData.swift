//
//  File.swift
//
//
//  Created by Daniel Jilg on 09.04.21.
//

import Foundation

public extension DTOv1 {
    /// Actual row of data inside an InsightCalculationResult
    struct InsightData: Hashable, Codable {
        public var xAxisValue: String
        public var yAxisValue: String?

        public init(xAxisValue: String, yAxisValue: String?) {
            self.xAxisValue = xAxisValue
            self.yAxisValue = yAxisValue
        }
    }
}
