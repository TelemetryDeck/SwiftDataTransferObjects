/// https://druid.apache.org/docs/latest/ingestion/data-formats/#input-format
public struct InputFormat: Codable, Hashable, Equatable {
    public enum InputFormatType: String, Codable, CaseIterable {
        case json
    }

    public let type: InputFormatType
    public let keepNullColumns: Bool?
}
