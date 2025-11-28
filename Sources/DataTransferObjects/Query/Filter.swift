import Foundation

/// The selector filter will match a specific dimension with a specific value.
/// Selector filters can be used as the base filters for more complex Boolean
/// expressions of filters.
public struct FilterSelector: Codable, Hashable, Equatable, Sendable {
    public init(dimension: String, value: String) {
        self.dimension = dimension
        self.value = value
    }

    public let dimension: String
    public let value: String
}

/// The column comparison filter is similar to the selector filter, but instead
/// compares dimensions to each other.
public struct FilterColumnComparison: Codable, Hashable, Equatable, Sendable {
    public init(dimensions: [String]) {
        self.dimensions = dimensions
    }

    public let dimensions: [String]
}

/// The Interval filter enables range filtering on columns that contain long
/// millisecond values, with the boundaries specified as ISO 8601 time intervals.
/// It is suitable for the __time column, long metric columns, and dimensions
/// with values that can be parsed as long milliseconds.
///
/// This filter converts the ISO 8601 intervals to long millisecond start/end
/// ranges and translates to an OR of Bound filters on those millisecond ranges,
/// with numeric comparison. The Bound filters will have left-closed and
/// right-open matching (i.e., start <= time < end).
public struct FilterInterval: Codable, Hashable, Equatable, Sendable {
    public init(dimension: String, intervals: [QueryTimeInterval]? = nil, relativeIntervals: [RelativeTimeInterval]? = nil) {
        self.dimension = dimension
        self.intervals = intervals
        self.relativeIntervals = relativeIntervals
    }

    public let dimension: String
    public let intervals: [QueryTimeInterval]?
    public let relativeIntervals: [RelativeTimeInterval]?
}

/// The regular expression filter is similar to the selector filter, but using regular
/// expressions. It matches the specified dimension with the given pattern. The
/// pattern can be any standard Java regular expression.
///
/// @see http://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html
public struct FilterRegex: Codable, Hashable, Equatable, Sendable {
    public init(dimension: String, pattern: String) {
        self.dimension = dimension
        self.pattern = pattern
    }

    public let dimension: String
    public let pattern: String
}

// The Range Filter can be used to filter on ranges of dimension values. It can be
// used for comparison filtering like greater than, less than, greater than or equal
// to, less than or equal to, and "between"
public struct FilterRange: Codable, Hashable, Equatable, Sendable {
    public init(
        column: String,
        matchValueType: FilterRange.MatchValueType,
        lower: String? = nil,
        upper: String? = nil,
        lowerOpen: Bool? = nil,
        upperOpen: Bool? = nil
    ) {
        self.column = column
        self.matchValueType = matchValueType
        self.lower = lower
        self.upper = upper
        self.lowerOpen = lowerOpen
        self.upperOpen = upperOpen
    }

    public enum MatchValueType: String, Codable, Hashable, Equatable, Sendable {
        case String = "STRING"
        case Double = "DOUBLE"
    }

    /// Input column or virtual column name to filter on.
    public let column: String

    /// String specifying the type of bounds to match.
    /// The matchValueType determines how TelemetryDeck interprets the matchValue to assist
    /// in converting to the type of the matched column and also defines the type of
    /// comparison used when matching values.
    public let matchValueType: MatchValueType

    /// Lower bound value to match.
    ///
    /// At least one of lower or upper must not be null.
    public let lower: String?

    /// Upper bound value to match.
    ///
    /// At least one of lower or upper must not be null.
    public let upper: String?

    /// Boolean indicating if lower bound is open in the interval of values defined by the
    /// range (">" instead of ">=").
    public let lowerOpen: Bool?

    /// Boolean indicating if upper bound is open on the interval of values defined by the
    /// range ("<" instead of "<=").
    public let upperOpen: Bool?
}

// logical expression filters
public struct FilterExpression: Codable, Hashable, Equatable, Sendable {
    public init(fields: [Filter]) {
        self.fields = fields
    }

    public let fields: [Filter]
}

public struct FilterNot: Codable, Hashable, Equatable, Sendable {
    public init(field: Filter) {
        self.field = field
    }

    public let field: Filter
}

/// The equality filter matches rows where a column value equals a specific value.
public struct FilterEquals: Codable, Hashable, Equatable, Sendable {
    public init(column: String, matchValueType: MatchValueType, matchValue: MatchValue) {
        self.column = column
        self.matchValueType = matchValueType
        self.matchValue = matchValue
    }

    public enum MatchValueType: String, Codable, Hashable, Equatable, Sendable {
        case string = "STRING"
        case long = "LONG"
        case double = "DOUBLE"
        case float = "FLOAT"
        case arrayString = "ARRAY<STRING>"
        case arrayLong = "ARRAY<LONG>"
        case arrayDouble = "ARRAY<DOUBLE>"
        case arrayFloat = "ARRAY<FLOAT>"
    }

    public enum MatchValue: Hashable, Equatable, Sendable {
        case string(String)
        case int(Int)
        case double(Double)
        case arrayString([String])
        case arrayInt([Int])
        case arrayDouble([Double])
    }

    public let column: String
    public let matchValueType: MatchValueType
    public let matchValue: MatchValue
}

extension FilterEquals.MatchValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arrayString = try? container.decode([String].self) {
            self = .arrayString(arrayString)
        } else if let arrayInt = try? container.decode([Int].self) {
            self = .arrayInt(arrayInt)
        } else if let arrayDouble = try? container.decode([Double].self) {
            self = .arrayDouble(arrayDouble)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else {
            throw DecodingError.typeMismatch(
                FilterEquals.MatchValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String, Int, Double, or array types"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .arrayString(value):
            try container.encode(value)
        case let .arrayInt(value):
            try container.encode(value)
        case let .arrayDouble(value):
            try container.encode(value)
        }
    }
}

/// The in filter can match input rows against a set of values, where a match occurs if the value is contained in the set.
public struct FilterIn: Codable, Hashable, Equatable, Sendable {
    public init(dimension: String, values: [String]) {
        self.dimension = dimension
        self.values = values
    }

    public let dimension: String
    public let values: [String]
    // extractionFn not supported atm
}

/// The null filter matches rows where a column value is null.
public struct FilterNull: Codable, Hashable, Equatable, Sendable {
    public init(column: String) {
        self.column = column
    }

    public let column: String
}

/// A filter is a JSON object indicating which rows of data should be included in the computation
/// for a query. It's essentially the equivalent of the WHERE clause in SQL.
public indirect enum Filter: Codable, Hashable, Equatable, Sendable {
    /// The selector filter will match a specific dimension with a specific value.
    /// Selector filters can be used as the base filters for more complex Boolean
    /// expressions of filters (deprecated -- use equals instead)
    case selector(FilterSelector)

    /// The column comparison filter is similar to the selector filter, but instead
    /// compares dimensions to each other.
    case columnComparison(FilterColumnComparison)

    /// The Interval filter enables range filtering on columns that contain long
    /// millisecond values, with the boundaries specified as ISO 8601 time intervals.
    /// It is suitable for the __time column, long metric columns, and dimensions
    /// with values that can be parsed as long milliseconds.
    case interval(FilterInterval)

    /// The regular expression filter is similar to the selector filter, but using regular
    /// expressions. It matches the specified dimension with the given pattern. The
    /// pattern can be any standard Java regular expression.
    case regex(FilterRegex)

    // The Range Filter can be used to filter on ranges of dimension values. It can be
    // used for comparison filtering like greater than, less than, greater than or equal
    // to, less than or equal to, and "between"
    case range(FilterRange)

    /// The equality filter matches rows where a column value equals a specific value.
    case equals(FilterEquals)

    /// The null filter matches rows where a column value is null.
    case null(FilterNull)

    /// The in filter can match input rows against a set of values, where a match occurs
    /// if the value is contained in the set.
    case `in`(FilterIn)

    // logical expression filters
    case and(FilterExpression)
    case or(FilterExpression)
    case not(FilterNot)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "selector":
            self = try .selector(FilterSelector(from: decoder))
        case "columnComparison":
            self = try .columnComparison(FilterColumnComparison(from: decoder))
        case "interval":
            self = try .interval(FilterInterval(from: decoder))
        case "regex":
            self = try .regex(FilterRegex(from: decoder))
        case "range":
            self = try .range(FilterRange(from: decoder))
        case "equals":
            self = try .equals(FilterEquals(from: decoder))
        case "null":
            self = try .null(FilterNull(from: decoder))
        case "in":
            self = try .in(FilterIn(from: decoder))
        case "and":
            self = try .and(FilterExpression(from: decoder))
        case "or":
            self = try .or(FilterExpression(from: decoder))
        case "not":
            self = try .not(FilterNot(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    /// Empty Filter that basically catches everthing
    public static var empty: Filter {
        Filter.not(.init(field: .selector(.init(dimension: "appID", value: "0"))))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .selector(selector):
            try container.encode("selector", forKey: .type)
            try selector.encode(to: encoder)
        case let .columnComparison(columnComparison):
            try container.encode("columnComparison", forKey: .type)
            try columnComparison.encode(to: encoder)
        case let .interval(interval):
            try container.encode("interval", forKey: .type)
            try interval.encode(to: encoder)
        case let .regex(regex):
            try container.encode("regex", forKey: .type)
            try regex.encode(to: encoder)
        case let .range(range):
            try container.encode("range", forKey: .type)
            try range.encode(to: encoder)
        case let .equals(equals):
            try container.encode("equals", forKey: .type)
            try equals.encode(to: encoder)
        case let .null(null):
            try container.encode("null", forKey: .type)
            try null.encode(to: encoder)
        case let .in(inFilter):
            try container.encode("in", forKey: .type)
            try inFilter.self.encode(to: encoder)
        case let .and(and):
            try container.encode("and", forKey: .type)
            try and.encode(to: encoder)
        case let .or(or):
            try container.encode("or", forKey: .type)
            try or.encode(to: encoder)
        case let .not(not):
            try container.encode("not", forKey: .type)
            try not.encode(to: encoder)
        }
    }

    public static func && (lhs: Filter, rhs: Filter) -> Filter {
        Filter.and(.init(fields: [lhs, rhs]))
    }

    public static func && (lhs: Filter, rhs: Filter?) -> Filter {
        guard let rhs = rhs else { return lhs }
        return Filter.and(.init(fields: [lhs, rhs]))
    }

    public static func && (lhs: Filter?, rhs: Filter) -> Filter {
        guard let lhs = lhs else { return rhs }
        return Filter.and(.init(fields: [lhs, rhs]))
    }

    public static func || (lhs: Filter, rhs: Filter) -> Filter {
        Filter.or(.init(fields: [lhs, rhs]))
    }
}
