/// Tasks do all ingestion-related work in Druid.
///
/// For batch ingestion, you will generally submit tasks directly to Druid using the Tasks APIs. For streaming ingestion,
/// tasks are generally submitted for you by a supervisor.
///
/// https://druid.apache.org/docs/latest/ingestion/tasks
public indirect enum TaskSpec: Codable, Hashable, Equatable {
    case indexParallel(IndexParallelTaskSpec)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "index_parallel":
            self = try .indexParallel(IndexParallelTaskSpec(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .indexParallel(spec):
            try container.encode("index_parallel", forKey: .type)
            try spec.encode(to: encoder)
        }
    }
}
