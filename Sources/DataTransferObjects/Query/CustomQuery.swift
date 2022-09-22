import Foundation

/// Custom JSON based  query
public struct CustomQuery: Codable, Hashable, Equatable {
    public init(queryType: CustomQuery.QueryType, dataSource: String = "telemetry-signals",
                descending: Bool? = nil, filter: Filter? = nil, intervals: [QueryTimeInterval]? = nil,
                relativeIntervals: [RelativeTimeInterval]? = nil, granularity: CustomQuery.Granularity,
                aggregations: [Aggregator]? = nil, postAggregations: [PostAggregator]? = nil,
                limit: Int? = nil, context: QueryContext? = nil,
                threshold: Int? = nil, metric: TopNMetricSpec? = nil,
                dimension: DimensionSpec? = nil, dimensions: [DimensionSpec]? = nil)
    {
        self.queryType = queryType
        self.dataSource = dataSource
        self.descending = descending
        self.filter = filter
        self.intervals = intervals
        self.relativeIntervals = relativeIntervals
        self.granularity = granularity
        self.aggregations = aggregations
        self.postAggregations = postAggregations
        self.limit = limit
        self.context = context
        self.threshold = threshold
        self.metric = metric
        self.dimension = dimension
        self.dimensions = dimensions
    }

    public enum QueryType: String, Codable, CaseIterable, Identifiable {
        public var id: String { rawValue }

        case timeseries
        case groupBy
        case topN
    }

    public enum Granularity: String, Codable, Hashable {
        case all
        case none
        case second
        case minute
        case fifteen_minute
        case thirty_minute
        case hour
        case day
        case week
        case month
        case quarter
        case year
    }

    public var queryType: QueryType
    public var dataSource: String = "telemetry-signals"
    public var descending: Bool?
    public var filter: Filter?
    public var intervals: [QueryTimeInterval]?

    /// If a relative intervals are set, their calculated output replaces the regular intervals
    public var relativeIntervals: [RelativeTimeInterval]?
    public let granularity: Granularity
    public var aggregations: [Aggregator]?
    public var postAggregations: [PostAggregator]?
    public var limit: Int?
    public var context: QueryContext?

    /// Only for topN Queries: An integer defining the N in the topN (i.e. how many results you want in the top list)
    public var threshold: Int?

    /// Only for topN Queries: A DimensionSpec defining the dimension that you want the top taken for
    public var dimension: DimensionSpec?

    /// Only for topN Queries: Specifying the metric to sort by for the top list
    public var metric: TopNMetricSpec?

    /// Only for groupBy Queries: A list of dimensions to do the groupBy over, if queryType is groupBy
    public var dimensions: [DimensionSpec]?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(queryType)
        hasher.combine(dataSource)
        hasher.combine(descending)
        hasher.combine(filter)
        hasher.combine(intervals)
        hasher.combine(relativeIntervals)
        hasher.combine(granularity)
        hasher.combine(aggregations)
        hasher.combine(limit)
        hasher.combine(context)
        hasher.combine(threshold)
        hasher.combine(metric)
        hasher.combine(dimensions)
        hasher.combine(dimension)
    }

    public static func == (lhs: CustomQuery, rhs: CustomQuery) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
