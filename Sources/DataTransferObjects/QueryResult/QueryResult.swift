import Foundation

public enum QueryResult: Codable, Hashable, Equatable {
    case timeSeries(TimeSeriesQueryResult)
    case topN(TopNQueryResult)
    case groupBy(GroupByQueryResult)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "timeSeriesResult":
            self = .timeSeries(try TimeSeriesQueryResult(from: decoder))
        case "topNResult":
            self = .topN(try TopNQueryResult(from: decoder))
        case "groupByResult":
            self = .groupBy(try GroupByQueryResult(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .timeSeries(let timeSeries):
            try container.encode("timeSeriesResult", forKey: .type)
            try timeSeries.encode(to: encoder)
        case .topN(let topN):
            try container.encode("topNResult", forKey: .type)
            try topN.encode(to: encoder)
        case .groupBy(let columnComparison):
            try container.encode("groupByResult", forKey: .type)
            try columnComparison.encode(to: encoder)
        }
    }
}

public struct TimeSeriesQueryResult: Codable, Hashable, Equatable {
    public init(rows: [TimeSeriesQueryResultRow]) {
        self.rows = rows
    }

    public let rows: [TimeSeriesQueryResultRow]
}

/// Time series queries return an array of JSON objects, where each object represents a value as described in the time-series query.
/// For instance, the daily average of a dimension for the last one month.
public struct TimeSeriesQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [String: Double]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [String: Double]
}

/// GroupBy queries return an array of JSON objects, where each object represents a grouping as described in the group-by query.
/// For example, we can query for the daily average of a dimension for the past month grouped by another dimension.
public struct GroupByQueryResult: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [String: String]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [String: String]
}

/// TopN queries return a sorted set of results for the values in a given dimension according to some criteria.
///
/// Conceptually, they can be thought of as an approximate GroupByQuery over a single dimension with an Ordering spec.
/// TopNs are much faster and resource efficient than GroupBys for this use case. These types of queries take a topN query
///  object and return an array of JSON objects where each object represents a value asked for by the topN query.
public struct TopNQueryResult: Codable, Hashable, Equatable {
    public init(rows: [TopNQueryResultRow]) {
        self.rows = rows
    }

    public let rows: [TopNQueryResultRow]
}

public struct TopNQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [TopNQueryResultRowItem]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [TopNQueryResultRowItem]
}

public struct TopNQueryResultRowItem: Codable, Hashable, Equatable {
    public init(metrics: [String: Double], dimensions: [String: String], nullValues: [String] = []) {
        self.metrics = metrics
        self.dimensions = dimensions
        self.nullValues = nullValues
    }

    public let metrics: [String: Double]
    public let dimensions: [String: String]
    public let nullValues: [String]

    public init(from decoder: Decoder) throws {
        var metrics = [String: Double]()
        var dimensions = [String: String]()
        var nullValues = [String]()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            if let stringElement = try? container.decode(String.self, forKey: key) {
                dimensions[key.stringValue] = stringElement
            }

            else if let doubleElement = try? container.decode(Double.self, forKey: key) {
                metrics[key.stringValue] = doubleElement
            }

            else {
                nullValues.append(key.stringValue)
            }
        }

        self.metrics = metrics
        self.dimensions = dimensions
        self.nullValues = nullValues
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        for key in metrics.keys {
            try container.encode(metrics[key], forKey: .init(stringValue: String(key))!)
        }

        for key in dimensions.keys {
            try container.encode(dimensions[key], forKey: .init(stringValue: String(key))!)
        }

        for key in nullValues {
            try container.encodeNil(forKey: .init(stringValue: key)!)
        }
    }

    struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
}

// MARK: - Legacy Structs

public enum LegacyDruidResultType: String, Codable {
    case timeSeries
}

public struct LegacyDruidResultWrapper: Codable {
    public let resultType: LegacyDruidResultType
    public let timeSeriesResults: [TimeSeriesQueryResultRow]

    public init(resultType: LegacyDruidResultType, timeSeriesResults: [TimeSeriesQueryResultRow]) {
        self.resultType = resultType
        self.timeSeriesResults = timeSeriesResults
    }
}
