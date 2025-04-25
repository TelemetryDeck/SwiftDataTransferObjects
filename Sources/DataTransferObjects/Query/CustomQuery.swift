import Crypto
import Foundation

/// Custom JSON based  query
public struct CustomQuery: Codable, Hashable, Equatable {
    public init(
        queryType: CustomQuery.QueryType,
        compilationStatus: CompilationStatus? = nil,
        restrictions: [QueryTimeInterval]? = nil,
        dataSource: String? = nil,
        virtualColumns: [VirtualColumn]? = nil,
        descending: Bool? = nil,
        filter: Filter? = nil,
        having: HavingSpec? = nil,
        appID: UUID? = nil,
        baseFilters: BaseFilters? = nil,
        testMode: Bool? = nil,
        intervals: [QueryTimeInterval]? = nil,
        relativeIntervals: [RelativeTimeInterval]? = nil,
        granularity: QueryGranularity? = nil,
        aggregations: [Aggregator]? = nil,
        postAggregations: [PostAggregator]? = nil,
        limit: Int? = nil,
        context: QueryContext? = nil,
        chartConfiguration: ChartConfiguration? = nil,
        valueFormatter: ValueFormatter? = nil,
        threshold: Int? = nil,
        metric: TopNMetricSpec? = nil,
        dimension: DimensionSpec? = nil,
        dimensions: [DimensionSpec]? = nil,
        columns: [String]? = nil,
        order: Order? = nil,
        steps: [NamedFilter]? = nil,
        sample1: NamedFilter? = nil,
        sample2: NamedFilter? = nil,
        successCriterion: NamedFilter? = nil
    ) {
        self.queryType = queryType
        self.compilationStatus = compilationStatus
        self.restrictions = restrictions

        if let dataSource = dataSource {
            self.dataSource = DataSource(type: .table, name: dataSource)
        }

        self.virtualColumns = virtualColumns
        self.descending = descending
        self.baseFilters = baseFilters
        self.testMode = testMode
        self.filter = filter
        self.having = having
        self.appID = appID
        self.intervals = intervals
        self.relativeIntervals = relativeIntervals
        self.granularity = granularity
        self.aggregations = aggregations
        self.postAggregations = postAggregations
        self.limit = limit
        self.context = context
        self.chartConfiguration = chartConfiguration
        self.valueFormatter = valueFormatter
        self.threshold = threshold
        self.metric = metric
        self.dimension = dimension
        self.dimensions = dimensions
        self.columns = columns
        self.order = order
        self.steps = steps
        self.sample1 = sample1
        self.sample2 = sample2
        self.successCriterion = successCriterion
    }

    public init(
        queryType: CustomQuery.QueryType,
        compilationStatus: CompilationStatus? = nil,
        restrictions: [QueryTimeInterval]? = nil,
        dataSource: DataSource?,
        virtualColumns: [VirtualColumn]? = nil,
        descending: Bool? = nil,
        filter: Filter? = nil,
        having: HavingSpec? = nil,
        appID: UUID? = nil,
        baseFilters: BaseFilters? = nil,
        testMode: Bool? = nil,
        intervals: [QueryTimeInterval]? = nil,
        relativeIntervals: [RelativeTimeInterval]? = nil,
        granularity: QueryGranularity,
        aggregations: [Aggregator]? = nil,
        postAggregations: [PostAggregator]? = nil,
        limit: Int? = nil,
        context: QueryContext? = nil,
        chartConfiguration: ChartConfiguration? = nil,
        valueFormatter: ValueFormatter? = nil,
        threshold: Int? = nil,
        metric: TopNMetricSpec? = nil,
        dimension: DimensionSpec? = nil,
        dimensions: [DimensionSpec]? = nil,
        columns: [String]? = nil,
        order: Order? = nil,
        steps: [NamedFilter]? = nil,
        sample1: NamedFilter? = nil,
        sample2: NamedFilter? = nil,
        successCriterion: NamedFilter? = nil
    ) {
        self.queryType = queryType
        self.compilationStatus = compilationStatus
        self.restrictions = restrictions
        self.dataSource = dataSource
        self.virtualColumns = virtualColumns
        self.descending = descending
        self.baseFilters = baseFilters
        self.testMode = testMode
        self.filter = filter
        self.having = having
        self.appID = appID
        self.intervals = intervals
        self.relativeIntervals = relativeIntervals
        self.granularity = granularity
        self.aggregations = aggregations
        self.postAggregations = postAggregations
        self.limit = limit
        self.context = context
        self.chartConfiguration = chartConfiguration
        self.valueFormatter = valueFormatter
        self.threshold = threshold
        self.metric = metric
        self.dimension = dimension
        self.dimensions = dimensions
        self.columns = columns
        self.order = order
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
        case scan
        case timeBoundary

        // derived types
        case funnel
        case experiment
        // case retention
    }

    public enum Order: String, Codable, CaseIterable {
        case ascending
        case descending
    }

    public enum CompilationStatus: String, Codable, CaseIterable, Identifiable {
        public var id: String { rawValue }

        case notCompiled
        case precompiled
        case compiled
    }

    public var queryType: QueryType
    public var compilationStatus: CompilationStatus?
    public var restrictions: [QueryTimeInterval]?
    public var dataSource: DataSource?

    public var virtualColumns: [VirtualColumn]?

    public var descending: Bool?
    public var baseFilters: BaseFilters?
    public var testMode: Bool?
    public var having: HavingSpec?
    public var filter: Filter?

    /// Used by baseFilter.thisApp, the appID to use for the appID filter
    public var appID: UUID?

    public var intervals: [QueryTimeInterval]?

    /// If a relative intervals are set, their calculated output replaces the regular intervals
    public var relativeIntervals: [RelativeTimeInterval]?
    public let granularity: QueryGranularity?
    public var aggregations: [Aggregator]?
    public var postAggregations: [PostAggregator]?
    public var limit: Int?
    public var context: QueryContext?
    public var chartConfiguration: ChartConfiguration?
    public var valueFormatter: ValueFormatter?

    /// Only for topN Queries: An integer defining the N in the topN (i.e. how many results you want in the top list)
    public var threshold: Int?

    /// Only for topN Queries: A DimensionSpec defining the dimension that you want the top taken for
    public var dimension: DimensionSpec?

    /// Only for topN Queries: Specifying the metric to sort by for the top list
    public var metric: TopNMetricSpec?

    /// Only for groupBy Queries: A list of dimensions to do the groupBy over, if queryType is groupBy
    public var dimensions: [DimensionSpec]?

    /// Only for scan queries: A String array of dimensions and metrics to scan. If left empty, all dimensions and metrics are returned.
    public var columns: [String]?

    /// Only for scan queries: The ordering of returned rows based on timestamp. Make sure to include the timestamp in the columns list.
    public var order: Order?

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

    public var stableHashValue: String {
        // We've tried various hashing functions here and they are just not stable.
        // So instead, let's convert to JSON and hash that.

        guard let jsonData = try? JSONEncoder.telemetryEncoder.encode(self) else { return "nothashed" }
        let digest = SHA256.hash(data: jsonData)

        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    // Return a hash value that is independent of the intervals or relative intervals.
    public var intervalIndependentHash: String {
        var query = self
        query.intervals = nil
        query.relativeIntervals = nil
        return query.stableHashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(queryType)
        hasher.combine(compilationStatus)
        hasher.combine(restrictions)
        hasher.combine(dataSource)
        hasher.combine(virtualColumns)
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
        // chartConfiguration deliberately not included in hash, because we don't want to invalidate caches based on chart configuration
        hasher.combine(valueFormatter)
        hasher.combine(threshold)
        hasher.combine(metric)
        hasher.combine(dimensions)
        hasher.combine(dimension)
        hasher.combine(columns)
        hasher.combine(order)
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

        queryType = try container.decode(CustomQuery.QueryType.self, forKey: CustomQuery.CodingKeys.queryType)
        compilationStatus = try container.decodeIfPresent(CompilationStatus.self, forKey: CustomQuery.CodingKeys.compilationStatus)
        restrictions = try container.decodeIfPresent([QueryTimeInterval].self, forKey: CustomQuery.CodingKeys.restrictions)
        dataSource = try container.decodeIfPresent(DataSource.self, forKey: CustomQuery.CodingKeys.dataSource)
        virtualColumns = try container.decodeIfPresent([VirtualColumn].self, forKey: CustomQuery.CodingKeys.virtualColumns)
        descending = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.descending)
        baseFilters = try container.decodeIfPresent(BaseFilters.self, forKey: CustomQuery.CodingKeys.baseFilters)
        testMode = try container.decodeIfPresent(Bool.self, forKey: CustomQuery.CodingKeys.testMode)
        filter = try container.decodeIfPresent(Filter.self, forKey: CustomQuery.CodingKeys.filter)
        appID = try container.decodeIfPresent(UUID.self, forKey: CustomQuery.CodingKeys.appID)
        relativeIntervals = try container.decodeIfPresent([RelativeTimeInterval].self, forKey: CustomQuery.CodingKeys.relativeIntervals)
        granularity = try container.decodeIfPresent(QueryGranularity.self, forKey: CustomQuery.CodingKeys.granularity)
        aggregations = try container.decodeIfPresent([Aggregator].self, forKey: CustomQuery.CodingKeys.aggregations)
        postAggregations = try container.decodeIfPresent([PostAggregator].self, forKey: CustomQuery.CodingKeys.postAggregations)
        limit = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.limit)
        context = try container.decodeIfPresent(QueryContext.self, forKey: CustomQuery.CodingKeys.context)
        chartConfiguration = try container.decodeIfPresent(ChartConfiguration.self, forKey: CustomQuery.CodingKeys.chartConfiguration)
        valueFormatter = try container.decodeIfPresent(ValueFormatter.self, forKey: CustomQuery.CodingKeys.valueFormatter)
        threshold = try container.decodeIfPresent(Int.self, forKey: CustomQuery.CodingKeys.threshold)
        dimension = try container.decodeIfPresent(DimensionSpec.self, forKey: CustomQuery.CodingKeys.dimension)
        metric = try container.decodeIfPresent(TopNMetricSpec.self, forKey: CustomQuery.CodingKeys.metric)
        dimensions = try container.decodeIfPresent([DimensionSpec].self, forKey: CustomQuery.CodingKeys.dimensions)
        columns = try container.decodeIfPresent([String].self, forKey: CustomQuery.CodingKeys.columns)
        order = try container.decodeIfPresent(Order.self, forKey: CustomQuery.CodingKeys.order)
        steps = try container.decodeIfPresent([NamedFilter].self, forKey: CustomQuery.CodingKeys.steps)
        sample1 = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.sample1)
        sample2 = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.sample2)
        successCriterion = try container.decodeIfPresent(NamedFilter.self, forKey: CustomQuery.CodingKeys.successCriterion)

        if let intervals = try? container.decode(QueryTimeIntervalsContainer.self, forKey: CustomQuery.CodingKeys.intervals) {
            self.intervals = intervals.intervals
        } else {
            intervals = try container.decodeIfPresent([QueryTimeInterval].self, forKey: CustomQuery.CodingKeys.intervals)
        }
    }
}
