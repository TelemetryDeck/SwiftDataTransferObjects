/// https://github.com/apache/druid/blob/master/processing/src/main/java/org/apache/druid/data/input/InputSource.java#L61
public indirect enum InputSource: Codable, Hashable, Equatable {
    case druid(DruidInputSource)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "druid":
            self = try .druid(DruidInputSource(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .druid(spec):
            try container.encode("druid", forKey: .type)
            try spec.encode(to: encoder)
        }
    }
}
