//
//  DTOv2.swift
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
        public var stripePriceID: String?
        public var stripeMaxSignals: Int64?
        public var maxSignalsMultiplier: Double?
        public var resolvedMaxSignals: Int64
        public var isInRestrictedMode: Bool
        public var countryCode: String?
        public var referralCode: String
        public var referredBy: UUID?
        public var appIDs: [App.ID]
        public var badgeAwardIDs: [BadgeAward.ID]
        public var settings: OrganizationSettings?

        public init(
            id: UUID,
            name: String,
            createdAt: Date?,
            updatedAt: Date?,
            isSuperOrg: Bool,
            stripeCustomerID: String?,
            stripePriceID: String?,
            stripeMaxSignals: Int64?,
            maxSignalsMultiplier: Double?,
            resolvedMaxSignals: Int64,
            isInRestrictedMode: Bool,
            countryCode: String?,
            referralCode: String,
            referredBy: UUID?,
            appIDs: [App.ID],
            badgeAwardIDs: [BadgeAward.ID],
            settings: OrganizationSettings
        ) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.isSuperOrg = isSuperOrg
            self.stripeCustomerID = stripeCustomerID
            self.stripePriceID = stripePriceID
            self.stripeMaxSignals = stripeMaxSignals
            self.maxSignalsMultiplier = maxSignalsMultiplier
            self.resolvedMaxSignals = resolvedMaxSignals
            self.isInRestrictedMode = isInRestrictedMode
            self.countryCode = countryCode
            self.referralCode = referralCode
            self.referredBy = referredBy
            self.appIDs = appIDs
            self.badgeAwardIDs = badgeAwardIDs
            self.settings = settings
        }
    }

    public struct OrganizationSettings: Codable, Hashable {
        // TBA

        public init() {}
    }

    struct User: Identifiable, Codable {
        public let id: UUID
        public let organization: DTOv1.Organization?
        public var firstName: String
        public var lastName: String
        public var email: String
        public let emailIsVerified: Bool
        public var receiveMarketingEmails: Bool?
        public let isFoundingUser: Bool
        public var receiveReports: ReportSendingRate
        public var settings: UserSettings?

        public init(
            id: UUID,
            organization: DTOv1.Organization?,
            firstName: String,
            lastName: String,
            email: String,
            emailIsVerified: Bool,
            receiveMarketingEmails: Bool?,
            isFoundingUser: Bool,
            receiveReports: ReportSendingRate,
            settings: UserSettings
        ) {
            self.id = id
            self.organization = organization
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.emailIsVerified = emailIsVerified
            self.receiveMarketingEmails = receiveMarketingEmails
            self.isFoundingUser = isFoundingUser
            self.receiveReports = receiveReports
            self.settings = settings
        }
    }

    public struct UserSettings: Codable, Hashable {
        public enum ChartColorSet: String, Codable, Hashable {
            case telemetryDeckRainbow
            case highContrast
        }

        // if set, use a custom chart color set, e.g. for various forms of color blindness
        public var chartColorSet: ChartColorSet

        public init(chartColorSet: ChartColorSet? = nil) {
            self.chartColorSet = chartColorSet ?? .telemetryDeckRainbow
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

    public struct SignalBoost: Codable, Hashable, Identifiable {
        public init(id: UUID, receivedAt: Date, organizationID: UUID, source: String, message: String? = nil, signalsReceived: Int64) {
            self.id = id
            self.receivedAt = receivedAt
            self.organizationID = organizationID
            self.source = source
            self.message = message
            self.signalsReceived = signalsReceived
        }

        public var id: UUID
        public var receivedAt: Date
        public var organizationID: UUID

        /// Human-Readable "from" field
        public var source: String

        /// An optional message from the booster to the boostee
        public var message: String?

        /// How many signals were gifted?
        public var signalsReceived: Int64
    }

    public struct App: Codable, Hashable, Identifiable {
        public var id: UUID
        public var name: String
        public var organizationID: Organization.ID
        public var insightGroupIDs: [Group.ID]
        public var settings: AppSettings

        public init(id: UUID, name: String, organizationID: Organization.ID, insightGroupIDs: [Group.ID], settings: AppSettings) {
            self.id = id
            self.name = name
            self.organizationID = organizationID
            self.insightGroupIDs = insightGroupIDs
            self.settings = settings
        }
    }

    public struct AppSettings: Codable, Hashable {
        public enum DisplayMode: String, Codable, Hashable {
            case app
            case website
        }

        public enum StartOfWeek: String, Codable, Hashable {
            case sunday
            case monday
        }

        /// If true, the app should display demo content instead of
        public var showExampleData: Bool?

        /// What colors should charts be in?
        ///
        /// This should be formatted as
        ///   - space-separated hex codes like "#ff0000 #12aa33 #baff1e"
        ///   - a color scheme name like "highcontrast"
        ///   - or nil for default color scheme
        public var colorScheme: String?

        /// How should the overview page for this application be layouted?
        public var displayMode: DisplayMode?

        /// The start of week when filtering using weekly filters like 'This Week'.
        public var startOfWeek: StartOfWeek?

        public init(displayMode: DisplayMode? = nil, colorScheme: String? = nil, showExampleData: Bool? = nil, startOfWeek: StartOfWeek? = nil) {
            self.displayMode = displayMode ?? .app
            self.colorScheme = colorScheme
            self.showExampleData = showExampleData ?? false
            self.startOfWeek = startOfWeek ?? .sunday
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
        public var settings: AppSettings

        public init(id: UUID, name: String, organizationID: Organization.ID, insights: [DTOv2.Insight], settings: AppSettings) {
            self.id = id
            self.name = name
            self.organizationID = organizationID
            self.insights = insights
            self.settings = settings
        }
    }

    /// Defines an insight as saved to the database, no calculation results
    public struct Insight: Codable, Hashable, Identifiable {
        public enum InsightType: String, Codable, Hashable {
            case timeseries
            case topN
            case customQuery
            case funnel
            case experiment
        }

        public var id: UUID
        public var groupID: UUID

        /// order in which insights appear in the apps (if not expanded)
        public var order: Double?
        public var title: String

        /// What kind of insight is this?
        public var type: InsightType

        /// If set, display the chart with this accent color, otherwise fall back to default color
        public var accentColor: String?

        /// If set, use the custom query in this property instead of constructing a query out of the options below
        public var customQuery: CustomQuery?

        /// Which signal types are we interested in? If nil, do not filter by signal type
        public var signalType: String?

        /// If true, only include at the newest signal from each user
        public var uniqueUser: Bool

        /// Only include signals that match all of these key-values in the payload
        public var filters: [String: String]

        /// If set, break down the values in this key
        public var breakdownKey: String?

        /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
        public var groupBy: QueryGranularity?

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
            type: InsightType,
            accentColor: String? = nil,
            widgetable _: Bool? = false,
            customQuery: CustomQuery? = nil,
            signalType: String?,
            uniqueUser: Bool,
            filters: [String: String],
            breakdownKey: String?,
            groupBy: QueryGranularity?,
            displayMode: InsightDisplayMode,
            isExpanded: Bool,
            lastRunTime: TimeInterval?,
            lastRunAt: Date?
        ) {
            self.id = id
            self.groupID = groupID
            self.order = order
            self.title = title
            self.type = type
            self.accentColor = accentColor
            self.customQuery = customQuery
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
        public init(
            id: String,
            order: Int,
            title: String,
            description: String,
            includedSignals: Int64,
            nakedPrice: String,
            mostPopular: Bool,
            currency: String,
            billingPeriod: String,
            features: [String]
        ) {
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
                currencySymbol = "€"
            case "USD", "CAD":
                currencySymbol = "$"
            default:
                currencySymbol = currency
            }

            // price is derived
            price = "\(currencySymbol)\(self.nakedPrice)/\(self.billingPeriod)"
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

        /// "$" or "€"
        public let currencySymbol: String

        /// Each of these gets a checkmark in front of it
        public let features: [String]
    }

    /// A short message that goes out to  users and is usually displayed in the app UI
    public struct StatusMessage: Identifiable, Codable {
        public init(id: String, validFrom: Date, validUntil: Date?, title: String, description: String?, severity: Int?, systemImageName: String?) {
            self.id = id
            self.validFrom = validFrom
            self.validUntil = validUntil
            self.title = title
            self.description = description
            self.severity = severity
            self.systemImageName = systemImageName
        }

        public let id: String
        public let validFrom: Date
        public let validUntil: Date?
        public let title: String
        public let description: String?

        /// 3 = bad, 2 = moderate, 1 = okay, 0 = info
        public let severity: Int?
        public let systemImageName: String?
    }

    struct LexiconSignal: Codable, Hashable, Identifiable {
        public init(type: String, signalCount: Int, userCount: Int, sessionCount: Int) {
            self.type = type
            self.signalCount = signalCount
            self.userCount = userCount
            self.sessionCount = sessionCount
        }

        public var id: String { type }
        public var type: String
        public var signalCount: Int
        public var userCount: Int
        public var sessionCount: Int
    }

    public struct LexiconPayloadKey: Codable, Hashable, Identifiable {
        public init(name: String, count: Int) {
            self.name = name
            self.count = count
        }

        /// Name of the payload key
        public let name: String

        /// Occurrences of the payload key within this month and the previous one
        public let count: Int

        public var id: String { name }
    }
}

public struct ChartTemplate: Codable {
    public init(template: ChartTemplate.Template, breakdownKey: String?, funnelSignalTypes: [String]?) {
        self.template = template
        self.breakdownKey = breakdownKey
        self.funnelSignalTypes = funnelSignalTypes
    }

    public enum Template: String, Codable {
        case custom
        case signalCount
        case userCount
        case breakdown
        case funnel
    }

    public let template: Template
    public let breakdownKey: String?
    public let funnelSignalTypes: [String]?
}

public enum InsightDisplayMode: String, Codable {
    case number // Deprecated, use Raw instead
    case raw
    case barChart
    case lineChart
    case pieChart
    case funnelChart
    case experimentChart
    case matrix
    case sankey
}

public extension DTOv2.Insight {
    static func newTimeSeriesInsight(groupID: UUID) -> DTOv2.Insight {
        DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "New Time Series Insight",
            type: .timeseries,
            customQuery: nil,
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
            type: .topN,
            customQuery: nil,
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
            type: .timeseries,
            customQuery: nil,
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
            type: .timeseries,
            customQuery: nil,
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
            type: .timeseries,
            customQuery: nil,
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
            type: .timeseries,
            customQuery: nil,
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
        let customQuery = CustomQuery(
            queryType: .groupBy,
            dataSource: .init(type: .table, name: "telemetry-signals"),
            intervals: [],
            granularity: .all,
            aggregations: [
                .longSum(.init(type: .longSum, name: "total_usage", fieldName: "count")),
            ]
        )

        return DTOv2.Insight(
            id: UUID.empty,
            groupID: groupID,
            order: nil,
            title: "Custom Query",
            type: .customQuery,
            customQuery: customQuery,
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
