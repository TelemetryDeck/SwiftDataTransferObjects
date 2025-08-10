import Foundation

/// Specifies how topN values should be sorted.
public indirect enum TopNMetricSpec: Codable, Equatable, Hashable, Sendable {
    case numeric(NumericTopNMetricSpec)
    case dimension(DimensionTopNMetricSpec)
    case inverted(InvertedTopNMetricSpec)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "numeric":
            self = try .numeric(NumericTopNMetricSpec(from: decoder))
        case "dimension":
            self = try .dimension(DimensionTopNMetricSpec(from: decoder))
        case "inverted":
            self = try .inverted(InvertedTopNMetricSpec(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .numeric(numericSpec):
            try container.encode("numeric", forKey: .type)
            try numericSpec.encode(to: encoder)
        case let .dimension(dimensionSpec):
            try container.encode("dimension", forKey: .type)
            try dimensionSpec.encode(to: encoder)
        case let .inverted(invertedSpec):
            try container.encode("inverted", forKey: .type)
            try invertedSpec.encode(to: encoder)
        }
    }
}

/// The simplest metric specification is a String value indicating the metric to sort topN results by
public struct NumericTopNMetricSpec: Codable, Equatable, Hashable, Sendable {
    public init(metric: String) {
        self.metric = metric
    }

    /// the actual metric field in which results will be sorted by  (i.e. "sort by this field")
    public let metric: String
}

/// This metric specification sorts TopN results by dimension value
public struct DimensionTopNMetricSpec: Codable, Equatable, Hashable, Sendable {
    public init(ordering: StringComparators, previousStop: String? = nil) {
        self.ordering = ordering
        self.previousStop = previousStop
    }

    public let ordering: StringComparators

    /// The starting point of the sort. For example, if a previousStop value is 'b', all values before 'b' are discarded. This field can be used to paginate through all the dimension values.
    public let previousStop: String?
}

/// Sort dimension values in inverted order, i.e inverts the order of the delegate metric spec. It can be used to sort the values in ascending order.
public struct InvertedTopNMetricSpec: Codable, Equatable, Hashable, Sendable {
    public init(metric: TopNMetricSpec) {
        self.metric = metric
    }

    public let metric: TopNMetricSpec
}
