import Foundation

/// The selector filter will match a specific dimension with a specific value.
/// Selector filters can be used as the base filters for more complex Boolean
/// expressions of filters.
public struct FilterSelector: Codable, Hashable, Equatable {
    public init(dimension: String, value: String) {
        self.dimension = dimension
        self.value = value
    }

    public let dimension: String
    public let value: String
}

/// The column comparison filter is similar to the selector filter, but instead
/// compares dimensions to each other.
public struct FilterColumnComparison: Codable, Hashable, Equatable {
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
public struct FilterInterval: Codable, Hashable, Equatable {
    public init(dimension: String, intervals: [QueryTimeInterval]) {
        self.dimension = dimension
        self.intervals = intervals
    }

    public let dimension: String
    public let intervals: [QueryTimeInterval]
}

/// The regular expression filter is similar to the selector filter, but using regular
/// expressions. It matches the specified dimension with the given pattern. The
/// pattern can be any standard Java regular expression.
///
/// @see http://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html
public struct FilterRegex: Codable, Hashable, Equatable {
    public init(dimension: String, pattern: String) {
        self.dimension = dimension
        self.pattern = pattern
    }

    public let dimension: String
    public let pattern: String
}

// logical expression filters
public struct FilterExpression: Codable, Hashable, Equatable {
    public init(fields: [Filter]) {
        self.fields = fields
    }

    public let fields: [Filter]
}

public struct FilterNot: Codable, Hashable, Equatable {
    public init(field: Filter) {
        self.field = field
    }

    public let field: Filter
}

/// A filter is a JSON object indicating which rows of data should be included in the computation
/// for a query. It’s essentially the equivalent of the WHERE clause in SQL.
public indirect enum Filter: Codable, Hashable, Equatable {
    /// The selector filter will match a specific dimension with a specific value.
    /// Selector filters can be used as the base filters for more complex Boolean
    /// expressions of filters.
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
            self = .selector(try FilterSelector(from: decoder))
        case "columnComparison":
            self = .columnComparison(try FilterColumnComparison(from: decoder))
        case "interval":
            self = .interval(try FilterInterval(from: decoder))
        case "regex":
            self = .regex(try FilterRegex(from: decoder))
        case "and":
            self = .and(try FilterExpression(from: decoder))
        case "or":
            self = .or(try FilterExpression(from: decoder))
        case "not":
            self = .not(try FilterNot(from: decoder))
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
        return Filter.and(.init(fields: [lhs, rhs]))
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
        return Filter.or(.init(fields: [lhs, rhs]))
    }
}
