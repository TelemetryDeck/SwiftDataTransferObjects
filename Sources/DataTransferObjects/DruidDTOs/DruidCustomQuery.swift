//
//  DruidNativeQuery.swift
//  DruidNativeQuery
//
//  Created by Charlotte Böhm on 25.08.21.
//

import Foundation

/// Custom JSON based Druid query
///
/// @see https://druid.apache.org/docs/latest/querying/querying.html
public struct DruidCustomQuery: Codable, Hashable {
    public init(queryType: QueryType, dataSource: String = "telemetry-signals", descending: Bool? = nil, filter: DruidFilter? = nil, intervals: [DruidInterval], granularity: Granularity, aggregations: [DruidAggregator]? = nil, limit: Int? = nil, context: DruidContext? = nil) {
        self.queryType = queryType
        self.dataSource = dataSource
        self.descending = descending
        self.filter = filter
        self.intervals = intervals
        self.granularity = granularity
        self.aggregations = aggregations
        self.limit = limit
        self.context = context
    }
    
    public enum QueryType: String, Codable {
        case timeseries
        case groupBy
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
    public var filter: DruidFilter? = nil
    public var intervals: [DruidInterval]
    public let granularity: Granularity
    public var aggregations: [DruidAggregator]? = nil
    public var limit: Int? = nil
    public var context: DruidContext? = nil

    public func hash(into hasher: inout Hasher) {
        let jsonValue = try! JSONEncoder.druidEncoder.encode(self)
        hasher.combine(jsonValue)
    }

    public static func == (lhs: DruidCustomQuery, rhs: DruidCustomQuery) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


