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
        self.dataSource = DataSource(type: .table, name: dataSource)
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
    
    public init(queryType: CustomQuery.QueryType, dataSource: DataSource = .init(type: .table, name: "telemetry-signals"),
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

    public enum Granularity: String, Codable, Hashable, CaseIterable {
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
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        public init(from decoder: Decoder) throws {
            let type: String
            
            let singleValueContainer = try decoder.singleValueContainer()
            if let singleValueType = try? singleValueContainer.decode(String.self) {
                type = singleValueType
            }
            
            else {
                let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
                type = try keyedContainer.decode(String.self, forKey: .type)
            }
            
            for possibleCase in Self.allCases {
                if type == possibleCase.rawValue {
                    self = possibleCase
                    return
                }
            }
            
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "needs to be a string or a dict",
                underlyingError: nil
            ))
        }
    }

    public var queryType: QueryType
    public var dataSource: DataSource = .init(type: .table, name: "telemetry-signals")
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
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CustomQuery.CodingKeys> = try decoder.container(keyedBy: CustomQuery.CodingKeys.self)
        
        self.queryType = try container.decode(CustomQuery.QueryType.self, forKey: CustomQuery.CodingKeys.queryType)
        self.dataSource = try container.decode(DataSource.self, forKey: CustomQuery.CodingKeys.dataSource)
        self.descending = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.descending)
        self.filter = try container.decodeIfPresent(Filter.self, forKey: CustomQuery.CodingKeys.filter)
        self.relativeIntervals = try container.decodeIfPresent([RelativeTimeInterval].self, forKey: CustomQuery.CodingKeys.relativeIntervals)
        self.granularity = try container.decode(CustomQuery.Granularity.self, forKey: CustomQuery.CodingKeys.granularity)
        self.aggregations = try container.decodeIfPresent([Aggregator].self, forKey: CustomQuery.CodingKeys.aggregations)
        self.postAggregations = try container.decodeIfPresent([PostAggregator].self, forKey: CustomQuery.CodingKeys.postAggregations)
        self.limit = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.limit)
        self.context = try container.decodeIfPresent(QueryContext.self, forKey: CustomQuery.CodingKeys.context)
        self.threshold = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.threshold)
        self.dimension = try container.decodeIfPresent(DimensionSpec.self, forKey: CustomQuery.CodingKeys.dimension)
        self.metric = try container.decodeIfPresent(TopNMetricSpec.self, forKey: CustomQuery.CodingKeys.metric)
        self.dimensions = try container.decodeIfPresent([DimensionSpec].self, forKey: CustomQuery.CodingKeys.dimensions)
        
        if let intervals = try? container.decode(QueryTimeIntervalsContainer.self, forKey: CustomQuery.CodingKeys.intervals) {
            self.intervals = intervals.intervals
        }
        
        else {
            self.intervals = try container.decodeIfPresent([QueryTimeInterval].self, forKey: CustomQuery.CodingKeys.intervals)
        }
        
    }
}
