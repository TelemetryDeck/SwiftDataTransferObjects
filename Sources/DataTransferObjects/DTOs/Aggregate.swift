//
//  File.swift
//
//
//  Created by Daniel Jilg on 15.04.21.
//

import Foundation

public extension DTOv1 {
    struct Aggregate: Codable {
        public init(min: TimeInterval, avg: TimeInterval, max: TimeInterval, median: TimeInterval) {
            self.min = min
            self.avg = avg
            self.max = max
            self.median = median
        }

        public let min: TimeInterval
        public let avg: TimeInterval
        public let max: TimeInterval
        public let median: TimeInterval
    }
}
