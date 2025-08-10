public indirect enum TuningConfig: Codable, Hashable, Equatable, Sendable {
    case kinesis(KinesisTuningConfig)
    case indexParallel(IndexParallelTuningConfig)
    // case kafka not implemented

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "kinesis":
            self = try .kinesis(KinesisTuningConfig(from: decoder))
        case "index_parallel":
            self = try .indexParallel(IndexParallelTuningConfig(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .kinesis(ioConfig):
            try container.encode("kinesis", forKey: .type)
            try ioConfig.encode(to: encoder)
        case let .indexParallel(tuningConfig):
            try container.encode("index_parallel", forKey: .type)
            try tuningConfig.encode(to: encoder)
        }
    }
}
