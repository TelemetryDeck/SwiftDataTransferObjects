//
//  File.swift
//
//
//  Created by Daniel Jilg on 09.04.21.
//

import Foundation

public extension DTOv1 {
    /// Defines an insight as saved to the database, no calculation results
    struct InsightDTO: Codable, Identifiable {
        public var id: UUID
        public var group: [String: UUID]

        public var order: Double?
        public var title: String

        /// Which signal types are we interested in? If nil, do not filter by signal type
        public var signalType: String?

        /// If true, only include at the newest signal from each user
        public var uniqueUser: Bool

        /// Only include signals that match all of these key-values in the payload
        public var filters: [String: String]

        /// How far to go back to aggregate signals
        public var rollingWindowSize: TimeInterval

        /// If set, break down the values in this key
        public var breakdownKey: String?

        /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
        public var groupBy: InsightGroupByInterval?

        /// How should this insight's data be displayed?
        public var displayMode: InsightDisplayMode

        /// If true, the insight will be displayed bigger
        public var isExpanded: Bool

        /// The amount of time (in seconds) this query took to calculate last time
        public var lastRunTime: TimeInterval?

        /// The query that was last used to run this query
        public var lastQuery: String?

        /// The date this query was last run
        public var lastRunAt: Date?
    }
}

public extension DTOv1 {
    /// Defines the result of an insight calculation
    struct InsightCalculationResult: Identifiable, Codable {
        public init(id: UUID, order: Double?, title: String, signalType: String?, uniqueUser: Bool, filters: [String: String],
                    rollingWindowSize _: TimeInterval, breakdownKey: String? = nil, groupBy: InsightGroupByInterval? = nil,
                    displayMode: InsightDisplayMode, isExpanded: Bool, data: [DTOv1.InsightData], calculatedAt: Date, calculationDuration: TimeInterval)
        {
            self.id = id
            self.order = order
            self.title = title
            self.signalType = signalType
            self.uniqueUser = uniqueUser
            self.filters = filters
            self.breakdownKey = breakdownKey
            self.groupBy = groupBy
            self.displayMode = displayMode
            self.isExpanded = isExpanded
            self.data = data
            self.calculatedAt = calculatedAt
            self.calculationDuration = calculationDuration
        }

        public let id: UUID

        public let order: Double?
        public let title: String

        /// Which signal types are we interested in? If nil, do not filter by signal type
        public let signalType: String?

        /// If true, only include at the newest signal from each user
        public let uniqueUser: Bool

        /// Only include signals that match all of these key-values in the payload
        public let filters: [String: String]

        /// If set, break down the values in this key
        public var breakdownKey: String?

        /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
        public var groupBy: InsightGroupByInterval?

        /// How should this insight's data be displayed?
        public var displayMode: InsightDisplayMode

        /// If true, the insight will be displayed bigger
        var isExpanded: Bool

        /// Current Live Calculated Data
        public let data: [DTOv1.InsightData]

        /// When was this DTO calculated?
        public let calculatedAt: Date

        /// How long did this DTO take to calculate?
        public let calculationDuration: TimeInterval
    }
}
