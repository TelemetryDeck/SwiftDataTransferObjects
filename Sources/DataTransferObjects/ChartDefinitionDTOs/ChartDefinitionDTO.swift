//
//  File.swift
//
//
//  Created by Daniel Jilg on 10.11.21.
//

import Foundation

/// Chart-Representable data that was calculated from an Insight
struct ChartDefinitionDTO: Codable {
    /// The ID of the insight that was calculated
    public let id: UUID

    public let metadata: MetadataSection
    public let data: DataSection
    public let axis: AxisSection

    public struct MetadataSection: Codable {
        /// The insight that was calculated
        public let insight: DTOv2.Insight

        /// When was this result calculated?
        public let calculatedAt: Date

        /// How long did this result take to calculate?
        public let calculationDuration: TimeInterval
    }

    public struct DataSection: Codable {
        public let x: String
        public let xFormat: String?
        public let columns: [Column]

        public struct Column: Codable, Equatable {
            public init(label: String, data: [String?]) {
                self.label = label
                self.data = data
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let array = try container.decode([String?].self)

                label = (array.first ?? "No Label") ?? "No Label"
                data = Array(array.dropFirst())
            }

            public let label: String
            public let data: [String?]

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                var containingArray = [String?]()
                containingArray.append(label)
                containingArray.append(contentsOf: data)
                try container.encode(containingArray)
            }
        }
    }

    public struct AxisSection: Codable {
        public let x: AxisDefinition

        public struct AxisDefinition: Codable {
            public let type: String
        }
    }
}
