/// https://druid.apache.org/docs/latest/ingestion/supervisor/#tuning-configuration
/// https://druid.apache.org/docs/latest/ingestion/kinesis-ingestion#tuning-configuration
public struct KinesisTuningConfig: Codable, Hashable, Equatable {
    // - MARK: Kinesis Related Properties
    /// Whether to enable checking if the current sequence number is still available in a particular Kinesis shard. If false, the indexing task attempts to reset the current sequence number, depending on the value of resetOffsetAutomatically.
    public let skipSequenceNumberAvailabilityCheck: Bool?

    /// The size of the buffer (heap memory bytes) Druid uses between the Kinesis fetch threads and the main ingestion thread.
    public let recordBufferSizeBytes: Int?

    /// The number of milliseconds to wait for space to become available in the buffer before timing out.
    public let recordBufferOfferTimeout: Int?

    /// The number of milliseconds to wait for the buffer to drain before Druid attempts to fetch records from Kinesis again.
    public let recordBufferFullWait: Int?

    /// The size of the pool of threads fetching data from Kinesis. There is no benefit in having more threads than Kinesis shards.
    public let fetchThreads: Int?

    /// The maximum number of bytes to be fetched from buffer per poll. At least one record is polled from the buffer regardless of this config.
    public let maxBytesPerPoll: Int?

    /// ISO 8601 period    When shards are split or merged, the supervisor recomputes shard to task group mappings. The supervisor also signals any running tasks created under the old mappings to stop early at current time + repartitionTransitionDuration. Stopping the tasks early allows Druid to begin reading from the new shards more quickly. The repartition transition wait time controlled by this property gives the stream additional time to write records to the new shards after the split or merge, which helps avoid issues with empty shard handling. https://github.com/apache/druid/issues/7600
    public let repartitionTransitionDuration: String?

    /// Indicates if listShards API of AWS Kinesis SDK can be used to prevent LimitExceededException during ingestion. You must set the necessary IAM permissions.
    public let useListShards: Bool?

    // - MARK: Generic Properties
    /// The number of rows to accumulate before persisting. This number represents the post-aggregation rows. It is not equivalent to the number of input events, but the resulting number of aggregated rows.
    public let maxRowsInMemory: Int?

    /// The number of bytes to accumulate in heap memory before persisting. The value is based on a rough estimate of memory usage and not actual usage. Normally, Druid computes the value
    public let maxBytesInMemory: Int?

    /// The calculation of maxBytesInMemory takes into account overhead objects created during ingestion and each intermediate persist. To exclude the bytes of these overhead objects from the maxBytesInMemory check, set skipBytesInMemoryOverheadCheck to true.
    public let skipBytesInMemoryOverheadCheck: Bool?

    /// The number of rows to store in a segment. This number is post-aggregation rows. Handoff occurs when maxRowsPerSegment or maxTotalRows is reached or every intermediateHandoffPeriod, whichever happens first.
    public let maxRowsPerSegment: Int?

    /// The number of rows to aggregate across all segments; this number is post-aggregation rows. Handoff happens either if maxRowsPerSegment or maxTotalRows is reached or every intermediateHandoffPeriod, whichever happens earlier.
    public let maxTotalRows: Int?

    /// ISO 8601 period    The period that determines how often tasks hand off segments. Handoff occurs if maxRowsPerSegment or maxTotalRows is reached or every intermediateHandoffPeriod, whichever happens first.
    public let intermediateHandoffPeriod: String?

    /// ISO 8601 period    The period that determines the rate at which intermediate persists occur.
    public let intermediatePersistPeriod: String?

    /// Maximum number of persists that can be pending but not started. If a new intermediate persist exceeds this limit, Druid blocks ingestion until the currently running persist finishes. One persist can be running concurrently with ingestion, and none can be queued up. The maximum heap memory usage for indexing scales is maxRowsInMemory * (2 + maxPendingPersists).
    public let maxPendingPersists: Int?

    /// Defines segment storage format options to use at indexing time
    public let indexSpec: IndexSpec?

    /// Defines segment storage format options to use at indexing time for intermediate persisted temporary segments. You can use indexSpecForIntermediatePersists to disable dimension/metric compression on intermediate segments to reduce memory required for final merging. However, disabling compression on intermediate segments might increase page cache use while they are used before getting merged into final segment published.
    public let indexSpecForIntermediatePersists: IndexSpec?

    /// DEPRECATED. If true, Druid throws exceptions encountered during parsing causing ingestion to halt. If false, Druid skips unparseable rows and fields. Setting reportParseExceptions to true overrides existing configurations for maxParseExceptions and maxSavedParseExceptions, setting maxParseExceptions to 0 and limiting maxSavedParseExceptions to not more than 1.
    public let reportParseExceptions: Bool?

    /// Number of milliseconds to wait for segment handoff. Set to a value >= 0, where 0 means to wait indefinitely.
    public let handoffConditionTimeout: Int?

    /// Resets partitions when the sequence number is unavailable. If set to true, Druid resets partitions to the earliest or latest offset, based on the value of useEarliestSequenceNumber or useEarliestOffset (earliest if true, latest if false). If set to false, Druid surfaces the exception causing tasks to fail and ingestion to halt. If this occurs, manual intervention is required to correct the situation, potentially through resetting the supervisor.
    public let resetOffsetAutomatically: Bool?

    /// The number of threads that the supervisor uses to handle requests/responses for worker tasks, along with any other internal asynchronous operation.
    public let workerThreads: Int?

    /// The number of times Druid retries HTTP requests to indexing tasks before considering tasks unresponsive.
    public let chatRetries: Int?

    /// ISO 8601 period    The period of time to wait for a HTTP response from an indexing task.
    public let httpTimeout: String?

    /// ISO 8601 period    The period of time to wait for the supervisor to attempt a graceful shutdown of tasks before exiting.
    public let shutdownTimeout: String?

    /// ISO 8601 period    Determines how often the supervisor queries the streaming source and the indexing tasks to fetch current offsets and calculate lag. If the user-specified value is below the minimum value of PT5S, the supervisor ignores the value and uses the minimum value instead.
    public let offsetFetchPeriod: String?

    // not implemented: segmentWriteOutMediumFactory

    /// If true, Druid logs an error message when a parsing exception occurs, containing information about the row where the error occurred.
    public let logParseExceptions: Bool?

    /// The maximum number of parse exceptions that can occur before the task halts ingestion and fails. Setting reportParseExceptions overrides this limit.
    public let maxParseExceptions: Int?

    /// When a parse exception occurs, Druid keeps track of the most recent parse exceptions. maxSavedParseExceptions limits the number of saved exception instances. These saved exceptions are available after the task finishes in the task completion report. Setting reportParseExceptions overrides this limit.
    public let maxSavedParseExceptions: Int?
}
