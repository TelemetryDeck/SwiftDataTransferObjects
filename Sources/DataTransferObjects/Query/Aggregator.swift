// swiftlint:disable cyclomatic_complexity

import Foundation

/// You can use aggregations at query time to summarize result data.
///
/// https://druid.apache.org/docs/latest/querying/aggregations.html
public indirect enum Aggregator: Codable, Hashable, Equatable {
    // Convenience Aggregators

    /// Counts the number of unique users in a query.
    case userCount(UserCountAggregator)

    /// Counts the number of unique events in a query.
    case eventCount(EventCountAggregator)

    // Produces a histogram over a numerical value (floatValue by default)
    case histogram(HistogramAggregator)

    // Exact aggregations

    /// count computes the count of rows that match the filters.
    case count(CountAggregator)

    /// Calcluate the cardinality of a dimension (deprecated)
    case cardinality(CardinalityAggregator)

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

    // DataSketches Aggregators
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

    case quantilesDoublesSketch(QuantilesDoublesSketchAggregator)

    // Miscellaneous Aggregations

    /// A filtered aggregator wraps any given aggregator, but only aggregates the values for which the given dimension filter matches.
    ///
    /// This makes it possible to compute the results of a filtered and an unfiltered aggregation simultaneously, without having to issue multiple
    /// queries, and use both results as part of post-aggregations.
    ///
    /// Note: If only the filtered results are required, consider putting the filter on the query itself, which will be much faster since it does not require scanning all the data.
    case filtered(FilteredAggregator)

    // Not implemented
    // case javaScript: JavaScript aggregator (missing on purpose)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "userCount":
            self = try .userCount(UserCountAggregator(from: decoder))
        case "eventCount":
            self = try .eventCount(EventCountAggregator(from: decoder))
        case "histogram":
            self = try .histogram(HistogramAggregator(from: decoder))
        case "count":
            self = try .count(CountAggregator(from: decoder))
        case "cardinality":
            self = try .cardinality(CardinalityAggregator(from: decoder))
        case "longSum":
            self = try .longSum(GenericAggregator(from: decoder))
        case "doubleSum":
            self = try .doubleSum(GenericAggregator(from: decoder))
        case "floatSum":
            self = try .floatSum(GenericAggregator(from: decoder))
        case "doubleMin":
            self = try .doubleMin(GenericAggregator(from: decoder))
        case "doubleMax":
            self = try .doubleMax(GenericAggregator(from: decoder))
        case "floatMin":
            self = try .floatMin(GenericAggregator(from: decoder))
        case "floatMax":
            self = try .floatMax(GenericAggregator(from: decoder))
        case "longMin":
            self = try .longMin(GenericAggregator(from: decoder))
        case "longMax":
            self = try .longMax(GenericAggregator(from: decoder))
        case "doubleMean":
            self = try .doubleMean(GenericAggregator(from: decoder))
        case "doubleFirst":
            self = try .doubleFirst(GenericTimeColumnAggregator(from: decoder))
        case "doubleLast":
            self = try .doubleLast(GenericTimeColumnAggregator(from: decoder))
        case "floatFirst":
            self = try .floatFirst(GenericTimeColumnAggregator(from: decoder))
        case "floatLast":
            self = try .floatLast(GenericTimeColumnAggregator(from: decoder))
        case "longFirst":
            self = try .longFirst(GenericTimeColumnAggregator(from: decoder))
        case "longLast":
            self = try .longLast(GenericTimeColumnAggregator(from: decoder))
        case "stringFirst":
            self = try .stringFirst(GenericTimeColumnAggregator(from: decoder))
        case "stringLast":
            self = try .stringLast(GenericTimeColumnAggregator(from: decoder))
        case "doubleAny":
            self = try .doubleAny(GenericAggregator(from: decoder))
        case "floatAny":
            self = try .floatAny(GenericAggregator(from: decoder))
        case "longAny":
            self = try .longAny(GenericAggregator(from: decoder))
        case "stringAny":
            self = try .stringAny(GenericAggregator(from: decoder))
        case "thetaSketch":
            self = try .thetaSketch(GenericAggregator(from: decoder))
        case "quantilesDoublesSketch":
            self = try .quantilesDoublesSketch(QuantilesDoublesSketchAggregator(from: decoder))
        case "filtered":
            self = try .filtered(FilteredAggregator(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .userCount(selector):
            try container.encode("userCount", forKey: .type)
            try selector.encode(to: encoder)
        case let .eventCount(selector):
            try container.encode("eventCount", forKey: .type)
            try selector.encode(to: encoder)
        case let .histogram(selector):
            try container.encode("histogram", forKey: .type)
            try selector.encode(to: encoder)
        case let .count(selector):
            try container.encode("count", forKey: .type)
            try selector.encode(to: encoder)
        case let .cardinality(selector):
            try container.encode("cardinality", forKey: .type)
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
        case let .quantilesDoublesSketch(selector):
            try container.encode("quantilesDoublesSketch", forKey: .type)
            try selector.encode(to: encoder)
        case let .filtered(selector):
            try container.encode("filtered", forKey: .type)
            try selector.encode(to: encoder)
        }
    }

    /// Precompile any convenience aggregators
    func precompile() -> (aggregators: [Aggregator], postAggregators: [PostAggregator])? {
        switch self {
        case let .userCount(aggregator):
            return aggregator.precompile()
        case let .eventCount(aggregator):
            return aggregator.precompile()
        case let .histogram(aggregator):
            return aggregator.precompile()
        default:
            return nil
        }
    }
}

public struct CountAggregator: Codable, Hashable {
    public init(name: String) {
        type = .count
        self.name = name
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String
}

/// Calcluate the cardinality of a dimension (deprecated)
public struct CardinalityAggregator: Codable, Hashable {
    public init(name: String, fields: [String], byRow: Bool = false, round: Bool = true) {
        type = .cardinality
        self.name = name
        self.fields = fields
        self.byRow = byRow
        self.round = round
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String
    public let fields: [String]
    public let byRow: Bool
    public let round: Bool
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
    // Convenience Aggregators
    case userCount
    case eventCount
    case histogram

    // Native Aggregators
    case count
    case cardinality
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
    case quantilesDoublesSketch
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
    public init(filter: Filter, aggregator: Aggregator, name: String? = nil) {
        type = .filtered
        self.filter = filter
        self.aggregator = aggregator
        self.name = name
    }

    public let type: AggregatorType

    public let filter: Filter

    public let aggregator: Aggregator

    public let name: String?
}

public struct QuantilesDoublesSketchAggregator: Codable, Hashable {
    public init(
        name: String,
        fieldName: String,
        k: Int? = nil,
        maxStreamLength: Int? = nil,
        shouldFinalize: Bool? = nil
    ) {
        type = .quantilesDoublesSketch
        self.name = name
        self.fieldName = fieldName
        self.k = k
        self.maxStreamLength = maxStreamLength
        self.shouldFinalize = shouldFinalize
    }

    public let type: AggregatorType

    /// String representing the output column to store sketch values.
    public let name: String

    /// A string for the name of the input field (can contain sketches or raw numeric values).
    public let fieldName: String

    /// Parameter that determines the accuracy and size of the sketch. Higher k means higher accuracy but more space to store
    /// sketches. Must be a power of 2 from 2 to 32768.
    ///
    /// See [accuracy information](https://datasketches.apache.org/docs/Quantiles/OrigQuantilesSketch) in the DataSketches
    ///  documentation for details.
    ///
    ///  Defaults to 128
    public let k: Int?

    /// This parameter defines the number of items that can be presented to each sketch before it may need to move from off-heap to
    ///  on-heap memory. This is relevant to query types that use off-heap memory, including TopN and GroupBy. Ideally, should be
    ///  set high enough such that most sketches can stay off-heap.
    ///
    ///   defaults to 1000000000
    public let maxStreamLength: Int?

    /// Return the final double type representing the estimate rather than the intermediate sketch type itself. In addition to
    ///  controlling the finalization of this aggregator, you can control whether all aggregators are finalized with the query
    ///  context parameters finalize and sqlFinalizeOuterSketches.
    ///
    ///  defaults to true
    public let shouldFinalize: Bool?
}

/// Convenience Aggregator that counts the number of unique users in a query.
///
/// Compiles to a theta sketch aggregator.
public struct UserCountAggregator: Codable, Hashable, PrecompilableAggregator {
    public init(name: String? = nil) {
        self.name = name
    }

    public let name: String?

    public func precompile() -> (aggregators: [Aggregator], postAggregators: [PostAggregator]) {
        let aggregators = [Aggregator.thetaSketch(.init(type: .thetaSketch, name: name ?? "Users", fieldName: "clientUser"))]

        return (aggregators: aggregators, postAggregators: [])
    }
}

/// Convenience Aggregator that counts the number of unique events in a query.
///
/// Compiles to a longSum aggregator.
public struct EventCountAggregator: Codable, Hashable, PrecompilableAggregator {
    public init(name: String? = nil) {
        self.name = name
    }

    public let name: String?

    public func precompile() -> (aggregators: [Aggregator], postAggregators: [PostAggregator]) {
        let aggregators = [Aggregator.longSum(.init(type: .longSum, name: "Events", fieldName: "count"))]

        return (aggregators: aggregators, postAggregators: [])
    }
}

/// Convenience Aggregator that implements a histogram over floatValue using DataSketches Quantiles
public struct HistogramAggregator: Codable, Hashable, PrecompilableAggregator {
    public init(name: String? = nil, fieldName: String? = nil, splitPoints: [Double]? = nil, numBins: Int? = nil, k: Int? = nil) {
        self.name = name
        self.fieldName = fieldName
        self.splitPoints = splitPoints
        self.numBins = numBins
        self.k = k
    }

    /// String representing the output column to store sketch values (defaults to "Histogram")
    public let name: String?

    /// A string for the name of the input field (defaults to `floatvalue`)
    public let fieldName: String?

    /// array of split points (optional)
    public let splitPoints: [Double]?

    /// Number of bins (optional, defaults to 10)
    public let numBins: Int?

    /// Parameter that determines the accuracy and size of the sketch. Higher k means higher accuracy but more space to store
    /// sketches. Must be a power of 2 from 2 to 32768.
    ///
    ///  Defaults to 1024 in the TelemetryDeck implementation
    public let k: Int?

    public func precompile() -> (aggregators: [Aggregator], postAggregators: [PostAggregator]) {
        let aggregators = [
            Aggregator.quantilesDoublesSketch(
                .init(
                    name: "_histogramSketch",
                    fieldName: fieldName ?? "floatValue",
                    k: k ?? 1024
                )
            ),
            Aggregator.longMin(.init(type: .longMin, name: "_quantilesMinValue", fieldName: fieldName ?? "floatValue")),
            Aggregator.longMax(.init(type: .longMax, name: "_quantilesMaxValue", fieldName: fieldName ?? "floatValue")),
        ]

        let postAggregators = [
            PostAggregator.quantilesDoublesSketchToHistogram(
                .init(
                    name: name ?? "Histogram",
                    field: .fieldAccess(.init(type: .fieldAccess, fieldName: "_histogramSketch")),
                    splitPoints: splitPoints,
                    numBins: numBins
                )
            ),
        ]

        return (aggregators: aggregators, postAggregators: postAggregators)
    }
}
