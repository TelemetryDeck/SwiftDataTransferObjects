/// Defines Automatic Compaction settings for a data source
public struct AutoCompactionDynamicConfig: Codable, Hashable, Equatable, Sendable {
    public init(
        dataSource: String,
        taskPriority: Int?,
        inputSegmentSizeBytes: Int?,
        skipOffsetFromLatest: String?,
        tuningConfig: TuningConfig?,
        granularitySpec: GranularitySpec?,
        maxRowsPerSegment: Int?
    ) {
        self.dataSource = dataSource
        self.taskPriority = taskPriority
        self.inputSegmentSizeBytes = inputSegmentSizeBytes
        self.skipOffsetFromLatest = skipOffsetFromLatest
        self.tuningConfig = tuningConfig
        self.granularitySpec = granularitySpec
        self.maxRowsPerSegment = maxRowsPerSegment
    }

    /// The datasource name to be compacted.
    public let dataSource: String

    /// Priority of compaction task (Defaults to 25)
    public let taskPriority: Int?

    /// Maximum number of total segment bytes processed per compaction task.
    ///
    /// Since a time chunk must be processed in its entirety, if the segments for a particular time chunk have a total size in bytes greater than this parameter, compaction will not run for that time chunk. (default = 100,000,000,000,000 i.e. 100TB)
    public let inputSegmentSizeBytes: Int?

    /// The offset for searching segments to be compacted in ISO 8601 duration format. Strongly recommended to set for realtime datasources. See Data handling with compaction. (default = "P1D")
    public let skipOffsetFromLatest: String?

    /// Tuning config for compaction tasks.
    public let tuningConfig: TuningConfig?

    // not implemented:
    // public let taskContext: TaskContext?

    /// Custom granularitySpec.
    public let granularitySpec: GranularitySpec?

    // not implemented:
    // public let dimensionsSpec: DimensionsSpec?

    // not implemented:
    // public let transformSpec: TransformSpec?

    // not implemented:
    // public let metricsSpec: MetricsSpec?

    // not implemented:
    // public let iOConfig: IOConfig?

    // undocumented
    public let maxRowsPerSegment: Int?
}
