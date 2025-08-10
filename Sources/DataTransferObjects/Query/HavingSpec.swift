import Foundation

/// A having clause is a JSON object identifying which rows from a groupBy query should be returned, by specifying conditions on aggregated values.
///
/// It is essentially the equivalent of the HAVING clause in SQL.
///
/// The simplest having clause is a numeric filter. Numeric filters can be used as the base filters for more complex boolean expressions of filters.
public indirect enum HavingSpec: Codable, Hashable, Equatable, Sendable {
    /// Query filter HavingSpecs allow all query filters to be used in the Having part of the query.
    case filter(HavingFilter)

    /// Numeric filter that matches rows where the given aggregation is equal to the specified value.
    case equalTo(HavingEqualTo)

    /// Numeric filter that matches rows where the given aggregation is greater than the specified value.
    case greaterThan(HavingGreaterThan)

    /// Numeric filter that matches rows where the given aggregation is less than the specified value.
    case lessThan(HavingLessThan)

    /// The dimSelector filter will match rows with dimension values equal to the specified value
    case dimensionSelector(HavingDimensionSelector)

    /// A logical AND
    case and(HavingAnd)

    /// A logical OR
    case or(HavingOr)

    /// A logical NOT
    case not(HavingNot)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "filter":
            self = try .filter(HavingFilter(from: decoder))
        case "equalTo":
            self = try .equalTo(HavingEqualTo(from: decoder))
        case "greaterThan":
            self = try .greaterThan(HavingGreaterThan(from: decoder))
        case "lessThan":
            self = try .lessThan(HavingLessThan(from: decoder))
        case "dimSelector":
            self = try .dimensionSelector(HavingDimensionSelector(from: decoder))
        case "and":
            self = try .and(HavingAnd(from: decoder))
        case "or":
            self = try .or(HavingOr(from: decoder))
        case "not":
            self = try .not(HavingNot(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .filter(let havingFilter):
            try container.encode("filter", forKey: .type)
            try havingFilter.encode(to: encoder)
        case .equalTo(let havingEqualTo):
            try container.encode("equalTo", forKey: .type)
            try havingEqualTo.encode(to: encoder)
        case .greaterThan(let havingGreaterThan):
            try container.encode("greaterThan", forKey: .type)
            try havingGreaterThan.encode(to: encoder)
        case .lessThan(let havingLessThan):
            try container.encode("lessThan", forKey: .type)
            try havingLessThan.encode(to: encoder)
        case .dimensionSelector(let havingDimensionSelector):
            try container.encode("dimSelector", forKey: .type)
            try havingDimensionSelector.encode(to: encoder)
        case .and(let havingAnd):
            try container.encode("and", forKey: .type)
            try havingAnd.encode(to: encoder)
        case .or(let havingOr):
            try container.encode("or", forKey: .type)
            try havingOr.encode(to: encoder)
        case .not(let havingNot):
            try container.encode("not", forKey: .type)
            try havingNot.encode(to: encoder)
        }
    }
}

public struct HavingFilter: Codable, Hashable, Equatable, Sendable {
    public init(filter: Filter) {
        self.filter = filter
    }

    public let filter: Filter
}

public struct HavingEqualTo: Codable, Hashable, Equatable, Sendable {
    public init(aggregation: String, value: Double) {
        self.aggregation = aggregation
        self.value = value
    }

    public let aggregation: String
    public let value: Double
}

public struct HavingGreaterThan: Codable, Hashable, Equatable, Sendable {
    public init(aggregation: String, value: Double) {
        self.aggregation = aggregation
        self.value = value
    }

    public let aggregation: String
    public let value: Double
}

public struct HavingLessThan: Codable, Hashable, Equatable, Sendable {
    public init(aggregation: String, value: Double) {
        self.aggregation = aggregation
        self.value = value
    }

    public let aggregation: String
    public let value: Double
}

public struct HavingDimensionSelector: Codable, Hashable, Equatable, Sendable {
    public init(dimension: String, value: String) {
        self.dimension = dimension
        self.value = value
    }

    public let dimension: String
    public let value: String
}

public struct HavingAnd: Codable, Hashable, Equatable, Sendable {
    public init(havingSpecs: [HavingSpec]) {
        self.havingSpecs = havingSpecs
    }

    public let havingSpecs: [HavingSpec]
}

public struct HavingOr: Codable, Hashable, Equatable, Sendable {
    public init(havingSpecs: [HavingSpec]) {
        self.havingSpecs = havingSpecs
    }

    public let havingSpecs: [HavingSpec]
}

public struct HavingNot: Codable, Hashable, Equatable, Sendable {
    public init(havingSpec: HavingSpec) {
        self.havingSpec = havingSpec
    }

    public let havingSpec: HavingSpec
}
