import Foundation

public struct TimeBoundaryResult: Codable, Hashable, Equatable {
    public init(rows: [TimeBoundaryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.restrictions = restrictions
        self.rows = rows
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [TimeBoundaryResultRow]
}

public struct TimeBoundaryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [String: Date]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [String: Date]
}
