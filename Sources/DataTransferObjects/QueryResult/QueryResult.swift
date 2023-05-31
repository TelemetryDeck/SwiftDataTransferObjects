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
        case let .timeSeries(timeSeries):
            try container.encode("timeSeriesResult", forKey: .type)
            try timeSeries.encode(to: encoder)
        case let .topN(topN):
            try container.encode("topNResult", forKey: .type)
            try topN.encode(to: encoder)
        case let .groupBy(columnComparison):
            try container.encode("groupByResult", forKey: .type)
            try columnComparison.encode(to: encoder)
        }
    }
}

public struct TimeSeriesQueryResult: Codable, Hashable, Equatable {
    public init(rows: [TimeSeriesQueryResultRow], restrictions: [QueryTimeInterval]? = nil) {
        self.rows = rows
        self.restrictions = restrictions
    }

    public let restrictions: [QueryTimeInterval]?
    public let rows: [TimeSeriesQueryResultRow]
}

/// Wrapper around the Double type that also accepts encoding and decoding as "Infinity" and "-Infinity"
public struct DoubleWrapper: Codable, Hashable, Equatable {
    public let value: Double

    public init(_ doubleValue: Double) {
        value = doubleValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            if stringValue == "Infinity" {
                value = Double.infinity
            } else if stringValue == "-Infinity" {
                value = -Double.infinity
            } else {
                guard let parsedDoubleValue = NumberFormatter().number(from: stringValue)?.doubleValue else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: [],
                        debugDescription: "Could not parse value as Double",
                        underlyingError: nil
                    ))
                }

                value = parsedDoubleValue
            }

            return
        }

        value = try container.decode(Double.self)
    }

    enum CodingKeys: CodingKey {
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if value == Double.infinity {
            try container.encode("Infinity")
        } else if value == -Double.infinity {
            try container.encode("-Infinity")
        } else {
            try container.encode(value)
        }
    }
}

/// Time series queries return an array of JSON objects, where each object represents a value as described in the time-series query.
/// For instance, the daily average of a dimension for the last one month.
public struct TimeSeriesQueryResultRow: Codable, Hashable, Equatable {
    public init(timestamp: Date, result: [String: DoubleWrapper]) {
        self.timestamp = timestamp
        self.result = result
    }

    public let timestamp: Date
    public let result: [String: DoubleWrapper]
}

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

/// Represents a JSON object that can contain string values (dimensions), double values (dimensions) and null values.
public struct AdaptableQueryResultItem: Codable, Hashable, Equatable {
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
            } else if let doubleElement = try? container.decode(Double.self, forKey: key) {
                metrics[key.stringValue] = doubleElement
            } else {
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
        init?(intValue _: Int) {
            nil
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
