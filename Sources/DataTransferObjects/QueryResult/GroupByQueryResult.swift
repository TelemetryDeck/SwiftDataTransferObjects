import Foundation

/// GroupBy queries return an array of JSON objects, where each object represents a grouping as described in the group-by query.
/// For example, we can query for the daily average of a dimension for the past month grouped by another dimension.
public struct GroupByQueryResult: Codable, Hashable, Equatable {
    public init(rows: [GroupByQueryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.restrictions = restrictions
        self.rows = rows
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [GroupByQueryResultRow]
}

public struct GroupByQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, event: AdaptableQueryResultItem) {
        version = "v1"
        self.timestamp = timestamp
        self.event = event
    }

    public let version: String
    public let timestamp: Date
    public let event: AdaptableQueryResultItem
}
