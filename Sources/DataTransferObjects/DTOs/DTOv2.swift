//
//  InsightDTOs.swift
//  InsightDTOs
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation

public enum DTOv2 {
    public struct Organization: Codable, Hashable, Identifiable {
        public var id: UUID
        public var name: String
        public var createdAt: Date?
        public var updatedAt: Date?
        public var isSuperOrg: Bool
        public var stripeCustomerID: String?
        public var stripeMaxSignals: Int64?
        public var maxSignalsMultiplier: Double?
        public var resolvedMaxSignals: Int64
        public var isInRestrictedMode: Bool
        public var appIDs: [App.ID]
        public var badgeAwardIDs: [BadgeAward.ID]

        public init(
            id: UUID,
            name: String,
            createdAt: Date?,
            updatedAt: Date?,
            isSuperOrg: Bool,
            stripeCustomerID: String?,
            stripeMaxSignals: Int64?,
            maxSignalsMultiplier: Double?,
            resolvedMaxSignals: Int64,
            isInRestrictedMode: Bool,
            appIDs: [App.ID],
            badgeAwardIDs: [BadgeAward.ID]

        ) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.isSuperOrg = isSuperOrg
            self.stripeCustomerID = stripeCustomerID
            self.stripeMaxSignals = stripeMaxSignals
            self.maxSignalsMultiplier = maxSignalsMultiplier
            self.resolvedMaxSignals = resolvedMaxSignals
            self.isInRestrictedMode = isInRestrictedMode
            self.appIDs = appIDs
            self.badgeAwardIDs = badgeAwardIDs
        }
    }

    public struct BadgeAward: Codable, Hashable, Identifiable {
        public var id: UUID
        public var badgeID: UUID
        public var organizationID: UUID
        public var awardedAt: Date

        public init(
            id: UUID,
            badgeID: UUID,
            organizationID: UUID,
            awardedAt: Date

        ) {
            self.id = id
            self.badgeID = badgeID
            self.organizationID = organizationID
            self.awardedAt = awardedAt
        }
    }

    public struct Badge: Codable, Hashable, Identifiable {
        public var id: UUID
        public var title: String
        public var description: String
        public var imageURL: URL?
        public var signalCountMultiplier: Double?
        
        public init(id: UUID, title: String, description: String, imageURL: URL? = nil, signalCountMultiplier: Double? = nil) {
            self.id = id
            self.title = title
            self.description = description
            self.imageURL = imageURL
            self.signalCountMultiplier = signalCountMultiplier
        }
    }

    public struct App: Codable, Hashable, Identifiable {
        public var id: UUID
        public var name: String
        public var organizationID: Organization.ID
        public var insightGroupIDs: [Group.ID]

        public init(id: UUID, name: String, organizationID: Organization.ID, insightGroupIDs: [Group.ID]) {
            self.id = id
            self.name = name
            self.organizationID = organizationID
            self.insightGroupIDs = insightGroupIDs
        }
    }

    public struct Group: Codable, Hashable, Identifiable {
        public init(id: UUID, title: String, order: Double? = nil, appID: DTOv2.App.ID, insightIDs: [DTOv2.Insight.ID]) {
            self.id = id
            self.title = title
            self.order = order
            self.appID = appID
            self.insightIDs = insightIDs
        }
        
        public var id: UUID
        public var title: String
        public var order: Double?
        public var appID: App.ID
        public var insightIDs: [Insight.ID]
    }
    
    public struct AppWithInsights: Codable, Hashable, Identifiable {
        public var id: UUID
        public var name: String
        public var organizationID: Organization.ID
        public var insights: [DTOv2.Insight]

        public init(id: UUID, name: String, organizationID: Organization.ID, insights: [DTOv2.Insight]) {
            self.id = id
            self.name = name
            self.organizationID = organizationID
            self.insights = insights
        }
    }

    /// Defines an insight as saved to the database, no calculation results
    public struct Insight: Codable, Hashable, Identifiable {
        public var id: UUID
        public var groupID: UUID

        public var order: Double?
        public var title: String

        /// If set, display the chart with this accent color, otherwise fall back to default color
        public var accentColor: String?

        /// If set, use the custom query in this property instead of constructing a query out of the options below
        public var druidCustomQuery: DruidCustomQuery?

        /// Which signal types are we interested in? If nil, do not filter by signal type
        public var signalType: String?

        /// If true, only include at the newest signal from each user
        public var uniqueUser: Bool

        /// Only include signals that match all of these key-values in the payload
        public var filters: [String: String]

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

        /// The date this query was last run
        public var lastRunAt: Date?

        public init(
            id: UUID,
            groupID: UUID,
            order: Double?,
            title: String,
            accentColor: String? = nil,
            widgetable: Bool? = false,
            druidCustomQuery: DruidCustomQuery? = nil,
            signalType: String?,
            uniqueUser: Bool,
            filters: [String: String],
            breakdownKey: String?,
            groupBy: InsightGroupByInterval?,
            displayMode: InsightDisplayMode,
            isExpanded: Bool,
            lastRunTime: TimeInterval?,
            lastRunAt: Date?
        ) {
            self.id = id
            self.groupID = groupID
            self.order = order
            self.title = title
            self.accentColor = accentColor
            self.druidCustomQuery = druidCustomQuery
            self.signalType = signalType
            self.uniqueUser = uniqueUser
            self.filters = filters
            self.breakdownKey = breakdownKey
            self.groupBy = groupBy
            self.displayMode = displayMode
            self.isExpanded = isExpanded
            self.lastRunTime = lastRunTime
            self.lastRunAt = lastRunAt
        }
    }

    /// Defines the result of an insight calculation
    public struct InsightCalculationResult: Codable, Hashable, Identifiable {
        /// The ID of the insight that was calculated
        public let id: UUID

        /// The insight that was calculated
        public let insight: DTOv2.Insight

        /// Current Live Calculated Data
        public let data: [DTOv2.InsightCalculationResultRow]

        /// When was this DTO calculated?
        public let calculatedAt: Date

        /// How long did this DTO take to calculate?
        public let calculationDuration: TimeInterval

        public init(id: UUID, insight: DTOv2.Insight, data: [DTOv2.InsightCalculationResultRow], calculatedAt: Date, calculationDuration: TimeInterval) {
            self.id = id
            self.insight = insight
            self.data = data
            self.calculatedAt = calculatedAt
            self.calculationDuration = calculationDuration
        }
    }

    /// Actual row of data inside an InsightCalculationResult
    public struct InsightCalculationResultRow: Codable, Hashable {
        public var xAxisValue: String
        public var yAxisValue: Int64

        public init(xAxisValue: String, yAxisValue: Int64) {
            self.xAxisValue = xAxisValue
            self.yAxisValue = yAxisValue
        }
    }

    public struct PriceStructure: Identifiable, Codable {
        public init(id: String, order: Int, title: String, description: String, includedSignals: Int64, nakedPrice: String, mostPopular: Bool, currency: String, billingPeriod: String, features: [String]) {
            self.id = id
            self.order = order
            self.title = title
            self.description = description
            self.includedSignals = includedSignals
            self.mostPopular = mostPopular
            self.currency = currency
            self.billingPeriod = billingPeriod
            self.nakedPrice = nakedPrice
            self.features = features
            
            // currency is derived
            switch currency {
            case "EUR":
                self.currencySymbol = "€"
            case "USD", "CAD":
                self.currencySymbol = "$"
            default:
                self.currencySymbol = currency
            }
            
            // price is derived
            self.price = "\(self.currencySymbol)\(self.nakedPrice)/\(self.billingPeriod)"
        }
        
        public let id: String
        public let order: Int
        public let title: String
        public let description: String
        public let includedSignals: Int64
        
        /// Price, including period and currency e.g. "$299/month"
        public let price: String
        
        /// Price as a number, e.g. "299"
        public let nakedPrice: String
        
        public let mostPopular: Bool
        
        /// "EUR" or "USD" or "CAD"
        public let currency: String
        
        /// "month" or "year"
        public let billingPeriod: String
        
        ///"$" or "€"
        public let currencySymbol: String
        
        /// Each of these gets a checkmark in front of it
        public let features: [String]
    }

    /// A short message that goes out to  users and is usually displayed in the app UI
    public struct StatusMessage: Identifiable, Codable {
        public init(id: String, validFrom: Date, validUntil: Date?, title: String, description: String?, systemImageName: String?) {
            self.id = id
            self.validFrom = validFrom
            self.validUntil = validUntil
            self.title = title
            self.description = description
            self.systemImageName = systemImageName
        }
        
        public let id: String
        public let validFrom: Date
        public let validUntil: Date?
        public let title: String
        public let description: String?
        public let systemImageName: String?
    }

    struct LexiconSignal: Codable, Hashable, Identifiable {
        public init(type: String, signalCount: Int, userCount: Int, sessionCount: Int) {
            self.type = type
            self.signalCount = signalCount
            self.userCount = userCount
            self.sessionCount = sessionCount
        }
        
        public var id: String { return type }
        public var type: String
        public var signalCount: Int
        public var userCount: Int
        public var sessionCount: Int
    }
}

public enum InsightDisplayMode: String, Codable {
    case number // Deprecated, use Raw instead
    case raw
    case barChart
    case lineChart
    case pieChart
}

public enum InsightGroupByInterval: String, Codable {
    case hour
    case day
    case week
    case month
}

public extension DTOv2.Insight {
    static func newTimeSeriesInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "New Time Series Insight",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newBreakdownInsight(groupID: UUID, title: String? = nil, breakdownKey: String? = nil) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: title ?? "New Breakdown Insight",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: breakdownKey ?? "systemVersion",
            groupBy: .day,
            displayMode: .pieChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newDailyUserCountInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Daily Active Users",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newWeeklyUserCountInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Weekly Active Users",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            breakdownKey: nil,
            groupBy: .week,
            displayMode: .barChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newMonthlyUserCountInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Active Users this Month",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            breakdownKey: nil,
            groupBy: .month,
            displayMode: .raw,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newSignalInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Signals by Day",
            druidCustomQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }

    static func newCustomQueryInsight(groupID: UUID) -> DTOv2.Insight {
        let customQuery = DruidCustomQuery(
            queryType: .groupBy,
            dataSource: "telemetry-signals",
            intervals: [],
            granularity: .all,
            aggregations: [
                .init(type: .longSum, name: "total_usage", fieldName: "count")
            ]
        )

        return DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Custom Query",
            druidCustomQuery: customQuery,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            isExpanded: false,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }
}
