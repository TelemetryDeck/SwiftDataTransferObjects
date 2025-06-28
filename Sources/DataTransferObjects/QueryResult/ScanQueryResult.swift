import Foundation

public struct ScanQueryResult: Codable, Hashable, Equatable {
    public init(rows: [ScanQueryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.restrictions = restrictions
        self.rows = rows
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [ScanQueryResultRow]
}

public struct ScanQueryResultRow: Codable, Hashable, Equatable {
    public init(
        segmentId: String? = nil,
        columns: [String],
        events: [AdaptableQueryResultItem],
        rowSignature: [ScanQueryRowSignatureRow]
    ) {
        self.segmentId = segmentId
        self.columns = columns
        self.events = events
        self.rowSignature = rowSignature
    }

    public let segmentId: String?
    public let columns: [String]
    public let events: [AdaptableQueryResultItem]
    public let rowSignature: [ScanQueryRowSignatureRow]
}

public struct ScanQueryRowSignatureRow: Codable, Hashable, Equatable {
    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    public let name: String
    public let type: String?
}
