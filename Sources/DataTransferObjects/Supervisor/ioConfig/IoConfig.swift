public indirect enum IoConfig: Codable, Hashable, Equatable {
    case kinesis(KinesisIOConfig)
    // space for Kafka

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "kinesis":
            self = try .kinesis(KinesisIOConfig(from: decoder))

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
        }
    }
}
