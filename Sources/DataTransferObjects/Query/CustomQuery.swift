import Foundation

/// Custom JSON based  query
public struct CustomQuery: Codable, Hashable, Equatable {
    public init(queryType: CustomQuery.QueryType,
                compilationStatus: CompilationStatus? = nil,
                isRestricted: Bool? = nil,
                dataSource: String? = "telemetry-signals",
                descending: Bool? = nil,
                filter: Filter? = nil,
                appID: UUID? = nil,
                baseFilters: BaseFilters? = nil,
                testMode: Bool? = nil,
                intervals: [QueryTimeInterval]? = nil,
                relativeIntervals: [RelativeTimeInterval]? = nil, granularity: QueryGranularity,
                aggregations: [Aggregator]? = nil, postAggregations: [PostAggregator]? = nil,
                limit: Int? = nil, context: QueryContext? = nil,
                threshold: Int? = nil, metric: TopNMetricSpec? = nil,
                dimension: DimensionSpec? = nil, dimensions: [DimensionSpec]? = nil,
                steps: [NamedFilter]? = nil,
                sample1: NamedFilter? = nil, sample2: NamedFilter? = nil, successCriterion: NamedFilter? = nil)
    {
        self.queryType = queryType
        self.compilationStatus = compilationStatus
        self.isRestricted = isRestricted

        if let dataSource = dataSource {
            self.dataSource = DataSource(type: .table, name: dataSource)
        }

        self.descending = descending
        self.baseFilters = baseFilters
        self.testMode = testMode
        self.filter = filter
        self.appID = appID
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
        self.steps = steps
        self.sample1 = sample1
        self.sample2 = sample2
        self.successCriterion = successCriterion
    }

    public init(queryType: CustomQuery.QueryType,
                compilationStatus: CompilationStatus? = nil,
                isRestricted: Bool? = nil,
                dataSource: DataSource?,
                descending: Bool? = nil,
                filter: Filter? = nil,
                appID: UUID? = nil,
                baseFilters: BaseFilters? = nil,
                testMode: Bool? = nil,
                intervals: [QueryTimeInterval]? = nil,
                relativeIntervals: [RelativeTimeInterval]? = nil, granularity: QueryGranularity,
                aggregations: [Aggregator]? = nil, postAggregations: [PostAggregator]? = nil,
                limit: Int? = nil, context: QueryContext? = nil,
                threshold: Int? = nil, metric: TopNMetricSpec? = nil,
                dimension: DimensionSpec? = nil, dimensions: [DimensionSpec]? = nil,
                steps: [NamedFilter]? = nil,
                sample1: NamedFilter? = nil, sample2: NamedFilter? = nil, successCriterion: NamedFilter? = nil)
    {
        self.queryType = queryType
        self.compilationStatus = compilationStatus
        self.isRestricted = isRestricted
        self.dataSource = dataSource
        self.descending = descending
        self.baseFilters = baseFilters
        self.testMode = testMode
        self.filter = filter
        self.appID = appID
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
        self.steps = steps
        self.sample1 = sample1
        self.sample2 = sample2
        self.successCriterion = successCriterion
    }

    public enum QueryType: String, Codable, CaseIterable, Identifiable {
        public var id: String { rawValue }

        case timeseries
        case groupBy
        case topN

        // derived types
        case funnel
        case experiment
        // case retention
    }

    public enum CompilationStatus: String, Codable, CaseIterable, Identifiable {
        public var id: String { rawValue }

        case notCompiled
        case precompiled
        case compiled
    }

    public var queryType: QueryType
    public var compilationStatus: CompilationStatus?
    public var isRestricted: Bool?
    public var dataSource: DataSource? = .init(type: .table, name: "telemetry-signals")
    public var descending: Bool?
    public var baseFilters: BaseFilters?
    public var testMode: Bool?
    public var filter: Filter?

    /// Used by baseFilter.thisApp, the appID to use for the appID filter
    public var appID: UUID?

    public var intervals: [QueryTimeInterval]?

    /// If a relative intervals are set, their calculated output replaces the regular intervals
    public var relativeIntervals: [RelativeTimeInterval]?
    public let granularity: QueryGranularity
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
    
    /// Only for funnel Queries: A list of filters that form the steps of the funnel
    public var steps: [NamedFilter]?
    
    /// Only for experiment Queries: The control cohort for the experiment
    public var sample1: NamedFilter?
    
    /// Only for experiment Queries: The experiment cohort for the experiment
    public var sample2: NamedFilter?
    
    /// Only for experiment Queries: A named filter that defines the successful cohort in the experiment.
    ///
    /// Will be intersected with cohort 1 for success 1 and cohort 2 for success 2
    public var successCriterion: NamedFilter?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(queryType)
        hasher.combine(compilationStatus)
        hasher.combine(dataSource)
        hasher.combine(descending)
        hasher.combine(baseFilters)
        hasher.combine(testMode)
        hasher.combine(filter)
        hasher.combine(appID)
        hasher.combine(intervals)
        hasher.combine(relativeIntervals)
        hasher.combine(granularity)
        hasher.combine(aggregations)
        hasher.combine(postAggregations)
        hasher.combine(limit)
        hasher.combine(context)
        hasher.combine(threshold)
        hasher.combine(metric)
        hasher.combine(dimensions)
        hasher.combine(dimension)
        hasher.combine(steps)
        hasher.combine(sample1)
        hasher.combine(sample2)
        hasher.combine(successCriterion)
    }

    public static func == (lhs: CustomQuery, rhs: CustomQuery) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CustomQuery.CodingKeys> = try decoder.container(keyedBy: CustomQuery.CodingKeys.self)

        self.queryType = try container.decode(CustomQuery.QueryType.self, forKey: CustomQuery.CodingKeys.queryType)
        self.compilationStatus = try container.decodeIfPresent(CompilationStatus.self, forKey: CustomQuery.CodingKeys.compilationStatus)
        self.isRestricted = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.isRestricted)
        self.dataSource = try container.decodeIfPresent(DataSource.self, forKey: CustomQuery.CodingKeys.dataSource)
        self.descending = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.descending)
        self.baseFilters = try container.decodeIfPresent(BaseFilters.self, forKey: CustomQuery.CodingKeys.baseFilters)
        self.testMode = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.testMode)
        self.filter = try container.decodeIfPresent(Filter.self, forKey: CustomQuery.CodingKeys.filter)
        self.appID = try container.decodeIfPresent(UUID.self, forKey: CustomQuery.CodingKeys.appID)
        self.relativeIntervals = try container.decodeIfPresent([RelativeTimeInterval].self, forKey: CustomQuery.CodingKeys.relativeIntervals)
        self.granularity = try container.decode(QueryGranularity.self, forKey: CustomQuery.CodingKeys.granularity)
        self.aggregations = try container.decodeIfPresent([Aggregator].self, forKey: CustomQuery.CodingKeys.aggregations)
        self.postAggregations = try container.decodeIfPresent([PostAggregator].self, forKey: CustomQuery.CodingKeys.postAggregations)
        self.limit = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.limit)
        self.context = try container.decodeIfPresent(QueryContext.self, forKey: CustomQuery.CodingKeys.context)
        self.threshold = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.threshold)
        self.dimension = try container.decodeIfPresent(DimensionSpec.self, forKey: CustomQuery.CodingKeys.dimension)
        self.metric = try container.decodeIfPresent(TopNMetricSpec.self, forKey: CustomQuery.CodingKeys.metric)
        self.dimensions = try container.decodeIfPresent([DimensionSpec].self, forKey: CustomQuery.CodingKeys.dimensions)
        self.steps = try container.decodeIfPresent([NamedFilter].self, forKey: CustomQuery.CodingKeys.steps)
        self.sample1 = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.sample1)
        self.sample2 = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.sample2)
        self.successCriterion = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.successCriterion)

        if let intervals = try? container.decode(QueryTimeIntervalsContainer.self, forKey: CustomQuery.CodingKeys.intervals) {
            self.intervals = intervals.intervals
        } else {
            self.intervals = try container.decodeIfPresent([QueryTimeInterval].self, forKey: CustomQuery.CodingKeys.intervals)
        }
    }
}
