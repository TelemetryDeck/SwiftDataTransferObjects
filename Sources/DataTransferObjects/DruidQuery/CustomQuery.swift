//
//  DruidNativeQuery.swift
//  DruidNativeQuery
//
//  Created by Charlotte Böhm on 25.08.21.
//

import Foundation

/// Custom JSON based  query
public struct CustomQuery: Codable, Hashable, Equatable {
    public init(queryType: CustomQuery.QueryType, dataSource: String = "telemetry-signals", descending: Bool? = nil, filter: Filter? = nil, intervals: [DruidInterval], granularity: CustomQuery.Granularity, aggregations: [Aggregator]? = nil, limit: Int? = nil, context: QueryContext? = nil, threshold: Int? = nil, metric: TopNMetricSpec? = nil, dimension: DimensionSpec? = nil, dimensions: [DimensionSpec]? = nil) {
        self.queryType = queryType
        self.dataSource = dataSource
        self.descending = descending
        self.filter = filter
        self.intervals = intervals
        self.granularity = granularity
        self.aggregations = aggregations
        self.limit = limit
        self.context = context
        self.threshold = threshold
        self.metric = metric
        self.dimension = dimension
        self.dimensions = dimensions
    }

    public enum QueryType: String, Codable {
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
    public var descending: Bool? = nil
    public var filter: Filter? = nil
    public var intervals: [DruidInterval]
    public let granularity: Granularity
    public var aggregations: [Aggregator]? = nil
    public var limit: Int? = nil
    public var context: QueryContext? = nil
    
    /// Only for topN Queries: An integer defining the N in the topN (i.e. how many results you want in the top list)
    public var threshold: Int? = nil
    
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
        return lhs.hashValue == rhs.hashValue
    }
}
