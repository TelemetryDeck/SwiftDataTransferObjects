/// https://druid.apache.org/docs/latest/ingestion/supervisor/#io-configuration
/// https://druid.apache.org/docs/latest/ingestion/kinesis-ingestion#io-configuration
public struct KinesisIOConfig: Codable, Hashable, Equatable {
    /// The Kinesis stream to read
    public let stream: String

    /// The input format to define input data parsing.
    public let inputFormat: InputFormat

    /// The AWS Kinesis stream endpoint for a region. http://docs.aws.amazon.com/general/latest/gr/rande.html#ak_region
    public let endpoint: String?

    /// The maximum number of reading tasks in a replica set.
    ///
    /// Multiply taskCount and replicas to measure the maximum number of reading tasks. The total number of tasks, reading and publishing, is higher than the maximum number of reading tasks. When
    /// taskCount is greater than the number of Kafka partitions or Kinesis shards, the actual number of reading tasks is less than the taskCount value.
    public let taskCount: Int?

    /// The number of replica sets, where 1 is a single set of tasks (no replication). Druid always assigns replicate tasks to different workers to provide resiliency against process failure.
    public let replicas: Int?

    /// ISO 8601 period. The length of time before tasks stop reading and begin publishing segments. Defaults to PT1H
    public let taskDuration: String?

    /// ISO 8601 period. The period to wait before the supervisor starts managing tasks.. Defaults to PT5S
    public let startDelay: String?

    /// ISO 8601 period. Determines how often the supervisor executes its management logic. Note that the supervisor also runs in response to certain events, such as tasks succeeding, failing, and
    /// reaching their task duration. The period value specifies the maximum time between iterations. Defaults to PT30S
    public let period: String?

    /// If a supervisor is managing a datasource for the first time, it obtains a set of starting sequence numbers from Kinesis. This flag determines whether a supervisor retrieves the earliest or latest sequence numbers in Kinesis. Under normal circumstances, subsequent tasks start from where the previous segments ended so this flag is only used on the first run.
    public let useEarliestSequenceNumber: Bool?

    /// ISO 8601 period. The length of time to wait before declaring a publishing task as failed and terminating it. If the value is too low, tasks may never publish. The publishing clock for a task begins roughly after taskDuration elapses.
    public let completionTimeout: String?

    /// ISO 8601 period. Configures tasks to reject messages with timestamps earlier than this period before the task was created. For example, if this property is set to PT1H and the supervisor creates a task at 2016-01-01T12:00Z, Druid drops messages with timestamps earlier than 2016-01-01T11:00Z. This may help prevent concurrency issues if your data stream has late messages and you have multiple pipelines that need to operate on the same segments, such as a streaming and a nightly batch ingestion pipeline. You can specify only one of the late message rejection properties.
    public let lateMessageRejectionPeriod: String?

    /// ISO 8601 period.  Configures tasks to reject messages with timestamps later than this period after the task reached its task duration. For example, if this property is set to PT1H, the task duration is set to PT1H and the supervisor creates a task at 2016-01-01T12:00Z, Druid drops messages with timestamps later than 2016-01-01T14:00Z. Tasks sometimes run past their task duration, such as in cases of supervisor failover. Setting earlyMessageRejectionPeriod too low may cause Druid to drop messages unexpectedly whenever a task runs past its originally configured task duration.
    public let earlyMessageRejectionPeriod: String?

    /// ISO 8601 date time. Configures tasks to reject messages with timestamps earlier than this date time. For example, if this property is set to 2016-01-01T11:00Z and the supervisor creates a task at 2016-01-01T12:00Z, Druid drops messages with timestamps earlier than 2016-01-01T11:00Z. This can prevent concurrency issues if your data stream has late messages and you have multiple pipelines that need to operate on the same segments, such as a realtime and a nightly batch ingestion pipeline.
    public let lateMessageRejectionStartDateTime: String?

    /// Defines auto scaling behavior for ingestion tasks. See Task autoscaler for more information.
    // not implemented: autoScalerConfig

    public let idleConfig: IdleConfig?

    /// Improved Supervisor rolling restarts
    ///
    /// The stopTaskCount config now prioritizes stopping older tasks first. As part of this change, you must also explicitly set a value for stopTaskCount. It no longer defaults to the same value as taskCount.
    ///
    /// See https://github.com/apache/druid/pull/15859
    public let stopTaskCount: Int?

    /// Time in milliseconds to wait between subsequent calls to fetch records from Kinesis. See https://druid.apache.org/docs/latest/ingestion/kinesis-ingestion#determine-fetch-settings
    public let fetchDelayMillis: Int?

    /// The AWS assumed role to use for additional permissions.
    public let awsAssumedRoleArn: String?

    /// The AWS external ID to use for additional permissions
    public let awsExternalId: String?
}
