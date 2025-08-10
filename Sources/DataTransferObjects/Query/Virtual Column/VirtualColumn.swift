public indirect enum VirtualColumn: Codable, Hashable, Equatable, Sendable {
    case expression(ExpressionVirtualColumn)
    case listFiltered(ListFilteredVirtualColumn)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "expression":
            self = try .expression(ExpressionVirtualColumn(from: decoder))
        case "mv-filtered":
            self = try .listFiltered(ListFilteredVirtualColumn(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type: \(type)", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .expression(virtualColumn):
            try container.encode("expression", forKey: .type)
            try virtualColumn.encode(to: encoder)
        case let .listFiltered(virtualColumn):
            try container.encode("mv-filtered", forKey: .type)
            try virtualColumn.encode(to: encoder)
        }
    }
}
