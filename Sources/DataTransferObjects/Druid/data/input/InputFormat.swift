/// https://druid.apache.org/docs/latest/ingestion/data-formats/#input-format
///
/// https://github.com/apache/druid/blob/master/processing/src/main/java/org/apache/druid/data/input/InputFormat.java
public struct InputFormat: Codable, Hashable, Equatable, Sendable {
    public init(type: InputFormat.InputFormatType, keepNullColumns: Bool? = nil) {
        self.type = type
        self.keepNullColumns = keepNullColumns
    }

    public enum InputFormatType: String, Codable, CaseIterable, Sendable {
        case json
    }

    public let type: InputFormatType
    public let keepNullColumns: Bool?
}
