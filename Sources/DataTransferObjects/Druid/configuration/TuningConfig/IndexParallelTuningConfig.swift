public struct IndexParallelTuningConfig: Codable, Hashable, Equatable, Sendable {
    public init(
        maxRowsInMemory: Int? = nil,
        maxBytesInMemory: Int? = nil,
        maxColumnsToMerge: Int? = nil,
        splitHintSpec: SplitHintSpec? = nil,
        partitionsSpec: PartitionsSpec? = nil,
        indexSpec: IndexSpec? = nil,
        indexSpecForIntermediatePersists: IndexSpec? = nil,
        maxPendingPersists: Int? = nil,
        forceGuaranteedRollup: Bool? = nil,
        reportParseExceptions: Bool? = nil,
        pushTimeout: Int? = nil,
        maxNumConcurrentSubTasks: Int? = nil,
        maxRetry: Int? = nil,
        maxNumSegmentsToMerge: Int? = nil,
        totalNumMergeTasks: Int? = nil,
        taskStatusCheckPeriodMs: Int? = nil,
        chatHandlerTimeout: String? = nil,
        chatHandlerNumRetries: Int? = nil,
        awaitSegmentAvailabilityTimeoutMillis: Int? = nil
    ) {
        self.maxRowsInMemory = maxRowsInMemory
        self.maxBytesInMemory = maxBytesInMemory
        self.maxColumnsToMerge = maxColumnsToMerge
        self.splitHintSpec = splitHintSpec
        self.partitionsSpec = partitionsSpec
        self.indexSpec = indexSpec
        self.indexSpecForIntermediatePersists = indexSpecForIntermediatePersists
        self.maxPendingPersists = maxPendingPersists
        self.forceGuaranteedRollup = forceGuaranteedRollup
        self.reportParseExceptions = reportParseExceptions
        self.pushTimeout = pushTimeout
        self.maxNumConcurrentSubTasks = maxNumConcurrentSubTasks
        self.maxRetry = maxRetry
        self.maxNumSegmentsToMerge = maxNumSegmentsToMerge
        self.totalNumMergeTasks = totalNumMergeTasks
        self.taskStatusCheckPeriodMs = taskStatusCheckPeriodMs
        self.chatHandlerTimeout = chatHandlerTimeout
        self.chatHandlerNumRetries = chatHandlerNumRetries
        self.awaitSegmentAvailabilityTimeoutMillis = awaitSegmentAvailabilityTimeoutMillis
    }

    /// Used in determining when intermediate persists to disk should occur. Normally user does not need to set this, but depending on the nature of data, if rows are short in terms of bytes, user may not want to store a million rows in memory and this value should be set. (default = 1000000)
    public let maxRowsInMemory: Int?

    /// Used in determining when intermediate persists to disk should occur. Normally this is computed internally and user does not need to set it. This value represents number of bytes to aggregate in heap memory before persisting. This is based on a rough estimate of memory usage and not actual usage. The maximum heap memory usage for indexing is maxBytesInMemory * (2 + maxPendingPersists) (default = 1/6 of max JVM memory)
    public let maxBytesInMemory: Int?

    /// Limit of the number of segments to merge in a single phase when merging segments for publishing. This limit affects the total number of columns present in a set of segments to merge. If the limit is exceeded, segment merging occurs in multiple phases. Druid merges at least 2 segments per phase, regardless of this setting. (Default = -1 i.e. no limit)
    public let maxColumnsToMerge: Int?

    /// Hint to control the amount of data that each first phase task reads. Druid may ignore the hint depending on the implementation of the input source. (default: size-based split hint spec)
    public let splitHintSpec: SplitHintSpec?

    /// Defines how to partition data in each timeChunk
    public let partitionsSpec: PartitionsSpec?

    /// Defines segment storage format options to use at indexing time
    public let indexSpec: IndexSpec?

    /// Defines segment storage format options to use at indexing time for intermediate persisted temporary segments. You can use indexSpecForIntermediatePersists to disable dimension/metric compression on intermediate segments to reduce memory required for final merging. However, disabling compression on intermediate segments might increase page cache use while they are used before getting merged into final segment published.
    public let indexSpecForIntermediatePersists: IndexSpec?

    /// Maximum number of persists that can be pending but not started. If a new intermediate persist exceeds this limit, Druid blocks ingestion until the currently running persist finishes. One persist can be running concurrently with ingestion, and none can be queued up. The maximum heap memory usage for indexing scales is maxRowsInMemory * (2 + maxPendingPersists).
    public let maxPendingPersists: Int?

    /// Forces perfect rollup. The perfect rollup optimizes the total size of generated segments and querying time but increases indexing time. If true, specify intervals in the granularitySpec and use either hashed or single_dim for the partitionsSpec. You cannot use this flag in conjunction with appendToExisting of IOConfig. (default = false)
    public let forceGuaranteedRollup: Bool?

    /// If true, Druid throws exceptions encountered during parsing and halts ingestion. If false, Druid skips unparseable rows and fields. (default = false)
    public let reportParseExceptions: Bool?

    /// Milliseconds to wait to push segments. Must be >= 0, where 0 means to wait forever. (default = 0)
    public let pushTimeout: Int?

    // not implemented:
    // public let segmentWriteOutMediumFactory

    /// Maximum number of worker tasks which can be run in parallel at the same time. The supervisor task would spawn worker tasks up to maxNumConcurrentSubTasks regardless of the current available task slots. If this value is set to 1, the Supervisor task processes data ingestion on its own instead of spawning worker tasks. If this value is set to too large, too many worker tasks can be created which might block other ingestion (default = 1)
    public let maxNumConcurrentSubTasks: Int?

    /// Maximum number of retries on task failures (default = 3)
    public let maxRetry: Int?

    /// Max limit for the number of segments that a single task can merge at the same time in the second phase. Used only with hashed or single_dim partitionsSpec. (default = 100)
    public let maxNumSegmentsToMerge: Int?

    /// Total number of tasks to merge segments in the merge phase when partitionsSpec is set to hashed or single_dim. (default = 10)
    public let totalNumMergeTasks: Int?

    /// Polling period in milliseconds to check running task statuses. (default=1000)
    public let taskStatusCheckPeriodMs: Int?

    /// Timeout for reporting the pushed segments in worker tasks. (default = PT10S)
    public let chatHandlerTimeout: String?

    /// Retries for reporting the pushed segments in worker tasks. (default = 5)
    public let chatHandlerNumRetries: Int?

    /// Milliseconds to wait for the newly indexed segments to become available for query after ingestion completes. If <= 0, no wait occurs. If > 0, the task waits for the Coordinator to indicate that the new segments are available for querying. If the timeout expires, the task exits as successful, but the segments are not confirmed as available for query.  (default = 0)
    public let awaitSegmentAvailabilityTimeoutMillis: Int?
}
