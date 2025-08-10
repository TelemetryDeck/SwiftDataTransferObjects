import Foundation

public struct DataSource: Codable, Hashable, Equatable, Sendable {
    public init(type: DataSource.DataSourceType, name: String) {
        self.type = type
        self.name = name
    }

    public init(_ name: String) {
        type = .table
        self.name = name
    }

    public enum DataSourceType: String, Codable, Hashable, Equatable, Sendable {
        case table
    }

    public let type: DataSourceType
    public let name: String

    enum CodingKeys: CodingKey {
        case type
        case name
    }

    public init(from decoder: Decoder) throws {
        if let singleValueContainer = try? decoder.singleValueContainer(), let singleValueName = try? singleValueContainer.decode(String.self) {
            self.init(type: .table, name: singleValueName)
            return
        }

        let container: KeyedDecodingContainer<DataSource.CodingKeys> = try decoder.container(keyedBy: DataSource.CodingKeys.self)

        let type = try container.decode(DataSource.DataSourceType.self, forKey: DataSource.CodingKeys.type)
        let name = try container.decode(String.self, forKey: DataSource.CodingKeys.name)

        self.init(type: type, name: name)
    }

    public func encode(to encoder: Encoder) throws {
        if type == .table {
            var container = encoder.singleValueContainer()
            try container.encode(name)
            return
        }

        var container: KeyedEncodingContainer<DataSource.CodingKeys> = encoder.container(keyedBy: DataSource.CodingKeys.self)

        try container.encode(type, forKey: DataSource.CodingKeys.type)
        try container.encode(name, forKey: DataSource.CodingKeys.name)
    }
}
