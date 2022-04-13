import Foundation

/// DimensionSpecs define how dimension values get transformed prior to aggregation.
///
/// The default dimensionSpec returns dimension values as is and optionally renames the dimension.
///
/// If an etraction function is set, it returns dimension values transformed using the given
/// extraction function.
public indirect enum DimensionSpec: Codable, Equatable, Hashable {
    case `default`(DefaultDimensionSpec)
    case extraction(ExtractionDimensionSpec)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "default":
            self = .default(try DefaultDimensionSpec(from: decoder))
        case "extraction":
            self = .extraction(try ExtractionDimensionSpec(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .default(defaultDimensionSpec):
            try container.encode("default", forKey: .type)
            try defaultDimensionSpec.encode(to: encoder)
        case let .extraction(exxtractionDimensionSpec):
            try container.encode("extraction", forKey: .type)
            try exxtractionDimensionSpec.encode(to: encoder)
        }
    }
}

public enum OutputType: String, Codable, Equatable, Hashable {
    case string = "STRING"
    case long = "LONG"
    case float = "FLOAT"
}

public struct DefaultDimensionSpec: Codable, Equatable, Hashable {
    public init(dimension: String, outputName: String, outputType: OutputType? = nil) {
        self.dimension = dimension
        self.outputName = outputName
        self.outputType = outputType
    }

    public let dimension: String
    public let outputName: String
    public let outputType: OutputType?
}

public struct ExtractionDimensionSpec: Codable, Equatable, Hashable {
    public init(dimension: String, outputName: String, outputType: OutputType? = nil, extractionFn: ExtractionFunction) {
        self.dimension = dimension
        self.outputName = outputName
        self.outputType = outputType
        self.extractionFn = extractionFn
    }

    public let dimension: String
    public let outputName: String
    public let outputType: OutputType?
    public let extractionFn: ExtractionFunction
}
