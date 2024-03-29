// swiftlint:disable cyclomatic_complexity

import Foundation

/// Post-aggregations are specifications of processing that should happen on aggregated values as they come out of the timeseries DB.
/// If you include a post aggregation as part of a query, make sure to include all aggregators the post-aggregator requires.
///
/// https://druid.apache.org/docs/latest/querying/post-aggregations.html
public indirect enum PostAggregator: Codable, Hashable, Equatable {
    // Included
    case arithmetic(ArithmetricPostAggregator)
    case fieldAccess(FieldAccessPostAggregator)
    case finalizingFieldAccess(FieldAccessPostAggregator)
    case constant(ConstantPostAggregator)
    case doubleGreatest(GreatestLeastPostAggregator)
    case longGreatest(GreatestLeastPostAggregator)
    case doubleMax(GreatestLeastPostAggregator)
    case doubleLeast(GreatestLeastPostAggregator)
    case longLeast(GreatestLeastPostAggregator)
    case hyperUniqueCardinality(HyperUniqueCardinalityPostAggregator)
    case expression(ExpressionPostAggregator)

    // From DataSketches ThetaSketches
    case thetaSketchEstimate(ThetaSketchEstimatePostAggregator)
    case thetaSketchSetOp(ThetaSketchSetOpPostAggregator)

    // From druid-stats
    case zscore2sample(ZScore2SamplePostAggregator)
    case pvalue2tailedZtest(PValue2TailedZTestPostAggregator)

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
            self = try .arithmetic(ArithmetricPostAggregator(from: decoder))
        case "fieldAccess":
            self = try .fieldAccess(FieldAccessPostAggregator(from: decoder))
        case "finalizingFieldAccess":
            self = try .finalizingFieldAccess(FieldAccessPostAggregator(from: decoder))
        case "constant":
            self = try .constant(ConstantPostAggregator(from: decoder))
        case "doubleGreatest":
            self = try .doubleGreatest(GreatestLeastPostAggregator(from: decoder))
        case "longGreatest":
            self = try .longGreatest(GreatestLeastPostAggregator(from: decoder))
        case "doubleMax":
            self = try .doubleMax(GreatestLeastPostAggregator(from: decoder))
        case "doubleLeast":
            self = try .doubleLeast(GreatestLeastPostAggregator(from: decoder))
        case "longLeast":
            self = try .longLeast(GreatestLeastPostAggregator(from: decoder))
        case "hyperUniqueCardinality":
            self = try .hyperUniqueCardinality(HyperUniqueCardinalityPostAggregator(from: decoder))
        case "expression":
            self = try .expression(ExpressionPostAggregator(from: decoder))
        case "thetaSketchEstimate":
            self = try .thetaSketchEstimate(ThetaSketchEstimatePostAggregator(from: decoder))
        case "thetaSketchSetOp":
            self = try .thetaSketchSetOp(ThetaSketchSetOpPostAggregator(from: decoder))
        case "zscore2sample":
            self = try .zscore2sample(ZScore2SamplePostAggregator(from: decoder))
        case "pvalue2tailedZtest":
            self = try .pvalue2tailedZtest(PValue2TailedZTestPostAggregator(from: decoder))
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
        case let .hyperUniqueCardinality(postAggregator):
            try container.encode("hyperUniqueCardinality", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .expression(postAggregator):
            try container.encode("expression", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .thetaSketchEstimate(postAggregator):
            try container.encode("thetaSketchEstimate", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .thetaSketchSetOp(postAggregator):
            try container.encode("thetaSketchOp", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .zscore2sample(postAggregator):
            try container.encode("zscore2sample", forKey: .type)
            try postAggregator.encode(to: encoder)
        case let .pvalue2tailedZtest(postAggregator):
            try container.encode("pvalue2tailedZtest", forKey: .type)
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
    case thetaSketchEstimate
    case thetaSketchSetOp
    case zscore2sample
    case pvalue2tailedZtest
}

public enum PostAggregatorOrdering: String, Codable, Hashable {
    case numericFirst
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
    public init(name: String, function: MathematicalFunction, fields: [PostAggregator], ordering: PostAggregatorOrdering? = nil) {
        type = .arithmetic
        self.name = name
        fn = function
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

    public let type: PostAggregatorType

    /// The output name for the aggregated value
    public let name: String

    public let fn: MathematicalFunction

    public let fields: [PostAggregator]

    public let ordering: PostAggregatorOrdering?
}

/// Field accessor post-aggregators
///
/// These post-aggregators return the value produced by the specified aggregator.
///
/// fieldName refers to the output name of the aggregator given in the aggregations portion of the query. For complex aggregators, like "cardinality" and
/// "hyperUnique", the type of the post-aggregator determines what the post-aggregator will return. Use type "fieldAccess" to return the raw aggregation
/// object, or use type "finalizingFieldAccess" to return a finalized value, such as an estimated cardinality.
public struct FieldAccessPostAggregator: Codable, Hashable {
    public init(type: PostAggregatorType, name: String? = nil, fieldName: String) {
        self.type = type
        self.name = name
        self.fieldName = fieldName
    }

    public let type: PostAggregatorType

    /// The output name for the aggregated value
    public let name: String?

    /// An aggregator name
    public let fieldName: String
}

/// The constant post-aggregator always returns the specified value.
public struct ConstantPostAggregator: Codable, Hashable {
    public init(name: String, value: Double) {
        type = .constant
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

/// The expression post-aggregator is defined using a Druid expression.
/// see https://druid.apache.org/docs/latest/misc/math-expr.html
public struct ExpressionPostAggregator: Codable, Hashable {
    public init(name: String, expression: String, ordering: PostAggregatorOrdering? = nil) {
        type = .expression
        self.name = name
        self.expression = expression
        self.ordering = ordering
    }

    public let type: PostAggregatorType

    /// The output name for the aggregated value
    public let name: String

    public let expression: String

    public let ordering: PostAggregatorOrdering?
}

/// The hyperUniqueCardinality post aggregator is used to wrap a hyperUnique object such that it can be used in post aggregations.
public struct HyperUniqueCardinalityPostAggregator: Codable, Hashable {
    public init(name: String? = nil, fieldName: String) {
        type = .hyperUniqueCardinality
        self.name = name
        self.fieldName = fieldName
    }

    public let type: PostAggregatorType
    public let name: String?
    public let fieldName: String
}

///   "field"  : <post aggregator of type fieldAccess that refers to a thetaSketch aggregator or that of type thetaSketchSetOp>
public struct ThetaSketchEstimatePostAggregator: Codable, Hashable {
    public init(name: String? = nil, field: PostAggregator) {
        type = .thetaSketchEstimate
        self.name = name
        self.field = field
    }

    public let type: PostAggregatorType
    public let name: String?
    public let field: PostAggregator
}

public struct ThetaSketchSetOpPostAggregator: Codable, Hashable {
    public init(name: String? = nil, func: ThetaSketchSetOpPostAggregator.SketchOperation, fields: [PostAggregator]) {
        type = .thetaSketchSetOp
        self.name = name
        self.func = `func`
        self.fields = fields
    }

    public enum SketchOperation: String, Codable, Hashable {
        case union = "UNION"
        case intersect = "INTERSECT"
        case not = "NOT"
    }

    public let type: PostAggregatorType
    public let name: String?
    public let `func`: SketchOperation
    public let fields: [PostAggregator]
}

/// Calculates the z-score using two-sample z-test
///
/// Calculates the z-score using two-sample z-test while
/// converting binary variables (e.g. success or not) to
/// continuous variables (e.g. conversion rate).
///
/// Highly useful for A/B Tests and similar experiments.
///
/// @see https://medium.com/paypal-tech/democratizing-experimentation-data-for-product-innovations-8b6e1cf40c27#DemocratizingExperimentationScience-Druid
public struct ZScore2SamplePostAggregator: Codable, Hashable {
    public init(name: String, sample1Size: PostAggregator, successCount1: PostAggregator, sample2Size: PostAggregator, successCount2: PostAggregator) {
        type = .zscore2sample
        self.name = name
        self.sample1Size = sample1Size
        self.successCount1 = successCount1
        self.sample2Size = sample2Size
        self.successCount2 = successCount2
    }

    public let type: PostAggregatorType
    public let name: String
    public let sample1Size: PostAggregator
    public let successCount1: PostAggregator
    public let sample2Size: PostAggregator
    public let successCount2: PostAggregator
}

/// Calculate p-value of two-sided z-test from zscore
///
/// pvalue2tailedZtest(zscore) - the input is a z-score which can be
/// calculated using the zscore2sample post aggregator
///
/// @see https://medium.com/paypal-tech/democratizing-experimentation-data-for-product-innovations-8b6e1cf40c27#DemocratizingExperimentationScience-Druid
public struct PValue2TailedZTestPostAggregator: Codable, Hashable {
    public init(name: String, zScore: PostAggregator) {
        type = .pvalue2tailedZtest
        self.name = name
        self.zScore = zScore
    }

    public let type: PostAggregatorType
    public let name: String
    public let zScore: PostAggregator
}
