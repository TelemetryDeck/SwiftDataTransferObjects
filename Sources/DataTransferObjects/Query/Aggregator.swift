// swiftlint:disable cyclomatic_complexity

import Foundation

/// https://druid.apache.org/docs/latest/querying/aggregations.html
public indirect enum Aggregator: Codable, Hashable {
    // Exact aggregations

    /// count computes the count of rows that match the filters.
    case count(CountAggregator)

    /// Computes the sum of values as a 64-bit, signed integer.
    ///
    /// The longSum aggregator takes the following properties:
    ///     - name: Output name for the summed value
    ///     - fieldName: Name of the metric column to sum over
    case longSum(GenericAggregator)

    /// Computes and stores the sum of values as a 64-bit floating point value. Similar to longSum.
    case doubleSum(GenericAggregator)

    /// Computes and stores the sum of values as a 32-bit floating point value. Similar to longSum and doubleSum.
    case floatSum(GenericAggregator)

    /// doubleMin computes the minimum of all metric values and Double.POSITIVE_INFINITY.
    case doubleMin(GenericAggregator)

    /// doubleMax computes the maximum of all metric values and Double.NEGATIVE_INFINITY.
    case doubleMax(GenericAggregator)

    /// floatMin computes the minimum of all metric values and Float.POSITIVE_INFINITY.
    case floatMin(GenericAggregator)

    /// floatMax computes the maximum of all metric values and Float.NEGATIVE_INFINITY.
    case floatMax(GenericAggregator)

    /// longMin computes the minimum of all metric values and Long.MAX_VALUE.
    case longMin(GenericAggregator)

    /// longMax computes the maximum of all metric values and Long.MIN_VALUE.
    case longMax(GenericAggregator)

    /// Computes and returns the arithmetic mean of a column's values as a 64-bit floating point value.
    ///
    /// doubleMean is a query time aggregator only. It is not available for indexing.
    ///
    /// It also is very mean 😡😡
    case doubleMean(GenericAggregator)

    // First and last aggregators
    /// doubleFirst computes the metric value with the minimum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case doubleFirst(GenericTimeColumnAggregator)

    /// doubleLast computes the metric value with the maximum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case doubleLast(GenericTimeColumnAggregator)

    /// floatFirst computes the metric value with the minimum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case floatFirst(GenericTimeColumnAggregator)

    /// floatLast computes the metric value with the maximum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case floatLast(GenericTimeColumnAggregator)

    /// longFirst computes the metric value with the minimum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case longFirst(GenericTimeColumnAggregator)

    /// longLast computes the metric value with the maximum value for time column or 0 in default mode, or null in SQL-compatible mode if no row exists.
    case longLast(GenericTimeColumnAggregator)

    /// stringFirst computes the metric value with the minimum value for time column or null if no row exists.
    case stringFirst(GenericTimeColumnAggregator)

    /// stringLast computes the metric value with the maximum value for time column or null if no row exists.
    case stringLast(GenericTimeColumnAggregator)

    // ANY aggregators
    /// Returns any value including null. This aggregator can simplify and optimize the performance by returning the first encountered value (including null).
    /// doubleAny returns any double metric value.
    case doubleAny(GenericAggregator)

    /// Returns any value including null. This aggregator can simplify and optimize the performance by returning the first encountered value (including null).
    /// floatAny returns any float metric value.
    case floatAny(GenericAggregator)

    /// Returns any value including null. This aggregator can simplify and optimize the performance by returning the first encountered value (including null).
    /// longAny returns any long metric value.
    case longAny(GenericAggregator)

    /// Returns any value including null. This aggregator can simplify and optimize the performance by returning the first encountered value (including null).
    /// stringAny returns any string metric value.
    case stringAny(GenericAggregator)

    // Approximate Aggregations
    /// This module provides Apache Druid aggregators based on Theta sketch from Apache DataSketches library.
    ///
    /// Note that sketch algorithms are approximate; see details in the "Accuracy" section of the datasketches doc.
    ///
    /// At ingestion time, this aggregator creates the Theta sketch objects which get stored in Druid segments. Logically speaking, a Theta sketch
    /// object can be thought of as a Set data structure. At query time, sketches are read and aggregated (set unioned) together. In the end, by
    /// default, you receive the estimate of the number of unique entries in the sketch object. Also, you can use post aggregators to do union,
    /// intersection or difference on sketch columns in the same row. Note that you can use thetaSketch aggregator on columns which were not
    /// ingested using the same. It will return estimated cardinality of the column. It is recommended to use it at ingestion time as well to make
    /// querying faster.
    ///
    /// https://druid.apache.org/docs/latest/development/extensions-core/datasketches-theta.html
    case thetaSketch(GenericAggregator)

    // Miscellaneous Aggregations

    /// A filtered aggregator wraps any given aggregator, but only aggregates the values for which the given dimension filter matches.
    ///
    /// This makes it possible to compute the results of a filtered and an unfiltered aggregation simultaneously, without having to issue multiple
    /// queries, and use both results as part of post-aggregations.
    ///
    /// Note: If only the filtered results are required, consider putting the filter on the query itself, which will be much faster since it does not require scanning all the data.
    case filtered(FilteredAggregator)

    // Not implemented
    // case javaScript: JavaScript aggregator

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "count":
            self = .count(try CountAggregator(from: decoder))

        case "longSum":
            self = .longSum(try GenericAggregator(from: decoder))
        case "doubleSum":
            self = .doubleSum(try GenericAggregator(from: decoder))
        case "floatSum":
            self = .floatSum(try GenericAggregator(from: decoder))
        case "doubleMin":
            self = .doubleMin(try GenericAggregator(from: decoder))
        case "doubleMax":
            self = .doubleMax(try GenericAggregator(from: decoder))
        case "floatMin":
            self = .floatMin(try GenericAggregator(from: decoder))
        case "floatMax":
            self = .floatMax(try GenericAggregator(from: decoder))
        case "longMin":
            self = .longMin(try GenericAggregator(from: decoder))
        case "longMax":
            self = .longMax(try GenericAggregator(from: decoder))
        case "doubleMean":
            self = .doubleMean(try GenericAggregator(from: decoder))
        case "doubleFirst":
            self = .doubleFirst(try GenericTimeColumnAggregator(from: decoder))
        case "doubleLast":
            self = .doubleLast(try GenericTimeColumnAggregator(from: decoder))
        case "floatFirst":
            self = .floatFirst(try GenericTimeColumnAggregator(from: decoder))
        case "floatLast":
            self = .floatLast(try GenericTimeColumnAggregator(from: decoder))
        case "longFirst":
            self = .longFirst(try GenericTimeColumnAggregator(from: decoder))
        case "longLast":
            self = .longLast(try GenericTimeColumnAggregator(from: decoder))
        case "stringFirst":
            self = .stringFirst(try GenericTimeColumnAggregator(from: decoder))
        case "stringLast":
            self = .stringLast(try GenericTimeColumnAggregator(from: decoder))
        case "doubleAny":
            self = .doubleAny(try GenericAggregator(from: decoder))
        case "floatAny":
            self = .floatAny(try GenericAggregator(from: decoder))
        case "longAny":
            self = .longAny(try GenericAggregator(from: decoder))
        case "stringAny":
            self = .stringAny(try GenericAggregator(from: decoder))
        case "thetaSketch":
            self = .thetaSketch(try GenericAggregator(from: decoder))
        case "filtered":
            self = .filtered(try FilteredAggregator(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .count(selector):
            try container.encode("count", forKey: .type)
            try selector.encode(to: encoder)
        case let .longSum(selector):
            try container.encode("longSum", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleSum(selector):
            try container.encode("doubleSum", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatSum(selector):
            try container.encode("floatSum", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleMin(selector):
            try container.encode("doubleMin", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleMax(selector):
            try container.encode("doubleMax", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatMin(selector):
            try container.encode("floatMin", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatMax(selector):
            try container.encode("floatMax", forKey: .type)
            try selector.encode(to: encoder)
        case let .longMin(selector):
            try container.encode("longMin", forKey: .type)
            try selector.encode(to: encoder)
        case let .longMax(selector):
            try container.encode("longMax", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleMean(selector):
            try container.encode("doubleMean", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleFirst(selector):
            try container.encode("doubleFirst", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleLast(selector):
            try container.encode("doubleLast", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatFirst(selector):
            try container.encode("floatFirst", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatLast(selector):
            try container.encode("floatLast", forKey: .type)
            try selector.encode(to: encoder)
        case let .longFirst(selector):
            try container.encode("longFirst", forKey: .type)
            try selector.encode(to: encoder)
        case let .longLast(selector):
            try container.encode("longLast", forKey: .type)
            try selector.encode(to: encoder)
        case let .stringFirst(selector):
            try container.encode("stringFirst", forKey: .type)
            try selector.encode(to: encoder)
        case let .stringLast(selector):
            try container.encode("stringLast", forKey: .type)
            try selector.encode(to: encoder)
        case let .doubleAny(selector):
            try container.encode("doubleAny", forKey: .type)
            try selector.encode(to: encoder)
        case let .floatAny(selector):
            try container.encode("floatAny", forKey: .type)
            try selector.encode(to: encoder)
        case let .longAny(selector):
            try container.encode("longAny", forKey: .type)
            try selector.encode(to: encoder)
        case let .stringAny(selector):
            try container.encode("stringAny", forKey: .type)
            try selector.encode(to: encoder)
        case let .thetaSketch(selector):
            try container.encode("thetaSketch", forKey: .type)
            try selector.encode(to: encoder)
        case let .filtered(selector):
            try container.encode("filtered", forKey: .type)
            try selector.encode(to: encoder)
        }
    }
}

public struct CountAggregator: Codable, Hashable {
    public init(name: String) {
        self.type = .count
        self.name = name
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String
}

public struct GenericAggregator: Codable, Hashable {
    public init(type: AggregatorType, name: String, fieldName: String) {
        self.type = type
        self.name = name
        self.fieldName = fieldName
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String

    /// The name of the column to aggregate over
    public var fieldName: String
}

public struct GenericTimeColumnAggregator: Codable, Hashable {
    public init(type: AggregatorType, name: String, fieldName: String, timeColumn: String? = nil) {
        self.type = type
        self.name = name
        self.fieldName = fieldName
        self.timeColumn = timeColumn
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String

    /// The name of the column to aggregate over
    public var fieldName: String

    /// Name of the time column to use. Optional, defaults to `__time`
    public let timeColumn: String?
}

public enum AggregatorType: String, Codable, Hashable {
    case count

    case longSum
    case doubleSum
    case floatSum
    case doubleMin
    case doubleMax
    case floatMin
    case floatMax
    case longMin
    case longMax
    case doubleMean
    case doubleFirst
    case doubleLast
    case floatFirst
    case floatLast
    case longFirst
    case longLast
    case stringFirst
    case stringLast
    case doubleAny
    case floatAny
    case longAny
    case stringAny
    case thetaSketch

    case filtered

    // JavaScript aggregator missing
}

/// A filtered aggregator wraps any given aggregator, but only aggregates the values for which the given dimension filter matches.
///
/// This makes it possible to compute the results of a filtered and an unfiltered aggregation simultaneously, without having to issue multiple
/// queries, and use both results as part of post-aggregations.
///
/// Note: If only the filtered results are required, consider putting the filter on the query itself, which will be much faster since it does not require scanning all the data.
public struct FilteredAggregator: Codable, Hashable {
    public init(filter: Filter, aggregator: Aggregator) {
        self.type = .filtered
        self.filter = filter
        self.aggregator = aggregator
    }

    public let type: AggregatorType

    public let filter: Filter

    public let aggregator: Aggregator
}
