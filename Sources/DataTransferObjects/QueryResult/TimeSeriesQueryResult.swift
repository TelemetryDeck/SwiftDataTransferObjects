import Foundation

public struct TimeSeriesQueryResult: Codable, Hashable, Equatable {
    public init(rows: [TimeSeriesQueryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.rows = rows
        self.restrictions = restrictions
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [TimeSeriesQueryResultRow]
}

/// Time series queries return an array of JSON objects, where each object represents a value as described in the time-series query.
/// For instance, the daily average of a dimension for the last one month.
public struct TimeSeriesQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [String: DoubleWrapper]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date?
    public let result: [String: DoubleWrapper?]
}
