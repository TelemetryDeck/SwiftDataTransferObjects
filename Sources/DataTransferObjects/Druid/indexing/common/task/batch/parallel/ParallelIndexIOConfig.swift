/// https://druid.apache.org/docs/latest/ingestion/native-batch#ioconfig
/// https://github.com/apache/druid/blob/master/indexing-service/src/main/java/org/apache/druid/indexing/common/task/batch/parallel/ParallelIndexIOConfig.java
public struct ParallelIndexIOConfig: Codable, Hashable, Equatable, Sendable {
    public init(inputFormat: InputFormat?, inputSource: InputSource? = nil, appendToExisting: Bool? = nil, dropExisting: Bool? = nil) {
        self.inputFormat = inputFormat
        self.inputSource = inputSource
        self.appendToExisting = appendToExisting
        self.dropExisting = dropExisting
    }

    /// inputFormat to specify how to parse input data.
    public let inputFormat: InputFormat?

    public let inputSource: InputSource?

    /// Creates segments as additional shards of the latest version
    ///
    /// effectively appending to the segment set instead of replacing it. This means that you can append new segments to any
    /// datasource regardless of its original partitioning scheme. You must use the dynamic partitioning type for the appended
    /// segments. If you specify a different partitioning type, the task fails with an error.
    public let appendToExisting: Bool?

    /// If true and appendToExisting is false and the granularitySpec contains aninterval, then the ingestion task replaces
    /// all existing segments fully contained by the specified interval when the task publishes new segments. If ingestion
    /// fails, Druid doesn't change any existing segments. In the case of misconfiguration where either appendToExisting is
    /// true or interval isn't specified in granularitySpec, Druid doesn't replace any segments even if dropExisting is true.
    ///
    /// WARNING: this feature is still experimental.
    public let dropExisting: Bool?
}
