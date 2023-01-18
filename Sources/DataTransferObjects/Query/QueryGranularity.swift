public enum QueryGranularity: String, Codable, Hashable, CaseIterable {
    case all
    case none
    case second
    case minute
    case fifteen_minute
    case thirty_minute
    case hour
    case day
    case week
    case month
    case quarter
    case year

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let type: String

        let singleValueContainer = try decoder.singleValueContainer()
        if let singleValueType = try? singleValueContainer.decode(String.self) {
            type = singleValueType
        } else {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            type = try keyedContainer.decode(String.self, forKey: .type)
        }

        for possibleCase in Self.allCases where type == possibleCase.rawValue {
            self = possibleCase
            return
        }

        throw DecodingError.dataCorrupted(.init(
            codingPath: [],
            debugDescription: "needs to be a string or a dict",
            underlyingError: nil
        ))
    }
}
