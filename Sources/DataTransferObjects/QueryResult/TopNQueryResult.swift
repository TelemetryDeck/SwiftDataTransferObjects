import Foundation

/// TopN queries return a sorted set of results for the values in a given dimension according to some criteria.
///
/// Conceptually, they can be thought of as an approximate GroupByQuery over a single dimension with an Ordering spec.
/// TopNs are much faster and resource efficient than GroupBys for this use case. These types of queries take a topN query
///  object and return an array of JSON objects where each object represents a value asked for by the topN query.
public struct TopNQueryResult: Codable, Hashable, Equatable {
    public init(rows: [TopNQueryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.rows = rows
        self.restrictions = restrictions
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [TopNQueryResultRow]
}

public struct TopNQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [AdaptableQueryResultItem]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [AdaptableQueryResultItem]
}
