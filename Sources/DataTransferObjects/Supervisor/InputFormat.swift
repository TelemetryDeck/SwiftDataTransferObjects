/// https://druid.apache.org/docs/latest/ingestion/data-formats/#input-format
public struct InputFormat: Codable, Hashable, Equatable {
    public init(type: InputFormat.InputFormatType, keepNullColumns: Bool? = nil) {
        self.type = type
        self.keepNullColumns = keepNullColumns
    }

    public enum InputFormatType: String, Codable, CaseIterable {
        case json
    }

    public let type: InputFormatType
    public let keepNullColumns: Bool?
}
