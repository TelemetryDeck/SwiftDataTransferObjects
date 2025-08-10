/// The timestampSpec is located in dataSchema → timestampSpec and is responsible for configuring the primary timestamp.
///
/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec#timestampspec
/// https://druid.apache.org/docs/latest/ingestion/schema-model#primary-timestamp
///
/// You can use the timestamp in a expression as __time because Druid parses the timestampSpec before applying transforms.
/// You can also set the expression name to __time to replace the value of the timestamp.
///
/// Treat __time as a millisecond timestamp: the number of milliseconds since Jan 1, 1970 at midnight UTC.
///
/// https://github.com/apache/druid/blob/master/processing/src/main/java/org/apache/druid/data/input/impl/TimestampSpec.java
public struct TimestampSpec: Codable, Hashable, Equatable, Sendable {
    public init(
        column: String? = nil,
        format: TimestampSpec.TimestampSpecFormat? = nil,
        missingValue: String? = nil
    ) {
        self.column = column
        self.format = format
        self.missingValue = missingValue
    }

    public enum TimestampSpecFormat: String, Codable, CaseIterable, Sendable {
        case iso
        case posix
        case millis
        case micro
        case nano
        case auto
    }

    /// Input row field to read the primary timestamp from.
    ///
    /// Regardless of the name of this input field, the primary timestamp will always be stored as a column named __time in your
    /// Druid datasource.
    public let column: String?

    /// Timestamp forma
    public let format: TimestampSpecFormat?

    /// Timestamp to use for input records that have a null or missing timestamp column. Should be in ISO8601 format, like
    /// "2000-01-01T01:02:03.456", even if you have specified something else for format. Since Druid requires a primary
    /// timestamp, this setting can be useful for ingesting datasets that do not have any per-record timestamps at all.
    public let missingValue: String?
}
