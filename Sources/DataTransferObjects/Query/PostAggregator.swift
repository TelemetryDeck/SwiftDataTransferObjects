// swiftlint:disable cyclomatic_complexity

import Foundation

/// Post-aggregations are specifications of processing that should happen on aggregated values as they come out of the timeseries DB.
/// If you include a post aggregation as part of a query, make sure to include all aggregators the post-aggregator requires.
///
/// https://druid.apache.org/docs/latest/querying/post-aggregations.html
public indirect enum PostAggregator: Codable, Hashable {
    case arithmetic(ArithmetricPostAggregator)
    case fieldAccess(FieldAccessPostAggregator)
    case finalizingFieldAccess(FieldAccessPostAggregator)
    case constant(ConstantPostAggregator)
    case doubleGreatest(GreatestLeastPostAggregator)
    case longGreatest(GreatestLeastPostAggregator)
    case doubleMax(GreatestLeastPostAggregator)
    case doubleLeast(GreatestLeastPostAggregator)
    case longLeast(GreatestLeastPostAggregator)
    // - Expression post-aggregator
//    case hyperUniqueCardinality
    
    // Not implemented by design
    // - JavaScript post-aggregator
    
    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        
        switch type {
        case "arithmetic":
            self = .arithmetic(try ArithmetricPostAggregator(from: decoder))
        case "fieldAccess":
            self = .fieldAccess(try FieldAccessPostAggregator(from: decoder))
        case "finalizingFieldAccess":
            self = .fieldAccess(try FieldAccessPostAggregator(from: decoder))
        case "constant":
            self = .constant(try ConstantPostAggregator(from: decoder))
        case "doubleGreatest":
            self = .doubleGreatest(try GreatestLeastPostAggregator(from: decoder))
        case "longGreatest":
            self = .longGreatest(try GreatestLeastPostAggregator(from: decoder))
        case "doubleMax":
            self = .doubleMax(try GreatestLeastPostAggregator(from: decoder))
        case "doubleLeast":
            self = .doubleLeast(try GreatestLeastPostAggregator(from: decoder))
        case "longLeast":
            self = .longLeast(try GreatestLeastPostAggregator(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type: \(type)", underlyingError: nil))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .arithmetic(postAggregator):
            try container.encode("arithmetic", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .fieldAccess(postAggregator):
            try container.encode("fieldAccess", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .finalizingFieldAccess(postAggregator):
            try container.encode("finalizingFieldAccess", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .constant(postAggregator):
            try container.encode("constant", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .doubleGreatest(postAggregator):
            try container.encode("doubleGreatest", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .longGreatest(postAggregator):
            try container.encode("longGreatest", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .doubleMax(postAggregator):
            try container.encode("doubleMax", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .doubleLeast(postAggregator):
            try container.encode("doubleLeast", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .longLeast(postAggregator):
            try container.encode("longLeast", forKey: .type)
            try postAggregator.encode(to: encoder)
        }
    }
}

public enum PostAggregatorType: String, Codable, Hashable {
    case arithmetic
    case fieldAccess
    case finalizingFieldAccess
    case constant
    case expression
    case doubleGreatest
    case longGreatest
    case doubleMax
    case doubleLeast
    case longLeast
    case hyperUniqueCardinality
}

/// Arithmetic post-aggregator
///
/// The arithmetic post-aggregator applies the provided function to the given fields from left to right. The fields can be aggregators or other post aggregators.
///
/// Supported functions are +, -, *, /, and quotient.
///
/// Note:
///
/// - / division always returns 0 if dividing by 0, regardless of the numerator.
/// - quotient division behaves like regular floating point division
/// - Arithmetic post-aggregators always use floating point arithmetic.
/// - Arithmetic post-aggregators may also specify an ordering, which defines the order of resulting values when sorting results (this can be useful for topN queries for instance)
///
/// Arithmetic post-aggregators may also specify an ordering, which defines the order of resulting values when sorting results (this can be useful for topN queries for instance):
///
/// - If no ordering (or null) is specified, the default floating point ordering is used.
/// - numericFirst ordering always returns finite values first, followed by NaN, and infinite values last.
public struct ArithmetricPostAggregator: Codable, Hashable {
    public init(name: String, function: MathematicalFunction, fields: [PostAggregator], ordering: Ordering? = nil) {
        self.type = .arithmetic
        self.name = name
        self.fn = function
        self.fields = fields
        self.ordering = ordering
    }

    public enum MathematicalFunction: String, Codable, Hashable {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "*"
        case division = "/"
        case quotient
    }
    
    public enum Ordering: String, Codable, Hashable {
        case numericFirst
    }

    public let type: PostAggregatorType

    /// The output name for the aggregated value
    public let name: String

    public let fn: MathematicalFunction
    
    public let fields: [PostAggregator]
    
    public let ordering: Ordering?
}


/// Field accessor post-aggregators
///
/// These post-aggregators return the value produced by the specified aggregator.
///
/// fieldName refers to the output name of the aggregator given in the aggregations portion of the query. For complex aggregators, like "cardinality" and
/// "hyperUnique", the type of the post-aggregator determines what the post-aggregator will return. Use type "fieldAccess" to return the raw aggregation
/// object, or use type "finalizingFieldAccess" to return a finalized value, such as an estimated cardinality.
public struct FieldAccessPostAggregator: Codable, Hashable {
    public init(type: PostAggregatorType, name: String, fieldName: String) {
        self.type = type
        self.name = name
        self.fieldName = fieldName
    }
    
    public let type: PostAggregatorType
    
    /// The output name for the aggregated value
    public let name: String
    
    /// An aggregator name
    public let fieldName: String
}

/// The constant post-aggregator always returns the specified value.
public struct ConstantPostAggregator: Codable, Hashable {
    public init(name: String, value: Double) {
        self.type = .constant
        self.name = name
        self.value = value
    }
    
    public let type: PostAggregatorType
    
    /// The output name for the aggregated value
    public let name: String
    
    /// The value to return
    public let value: Double
}

public struct GreatestLeastPostAggregator: Codable, Hashable {
    public init(type: PostAggregatorType, name: String, fields: [PostAggregator]) {
        self.type = type
        self.name = name
        self.fields = fields
    }
    
    public let type: PostAggregatorType
    
    /// The output name for the aggregated value
    public let name: String

    public let fields: [PostAggregator]
}

