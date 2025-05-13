/// The parallel task type index_parallel is a task for multi-threaded batch indexing. Parallel task indexing only relies on Druid
///  resources. It doesn't depend on other external systems like Hadoop.
///
/// The index_parallel task is a supervisor task that orchestrates the whole indexing process. The supervisor task splits the input
/// data and creates worker tasks to process the individual portions of data.
///
/// Druid issues the worker tasks to the Overlord. The Overlord schedules and runs the workers on Middle Managers or Indexers. After a
/// worker task successfully processes the assigned input portion, it reports the resulting segment list to the Supervisor task.
///
/// The Supervisor task periodically checks the status of worker tasks. If a task fails, the Supervisor retries the task until the number
/// of retries reaches the configured limit. If all worker tasks succeed, it publishes the reported segments at once and finalizes
///  ingestion.
///
/// The detailed behavior of the parallel task is different depending on the partitionsSpec. See partitionsSpec for more details.
///
/// https://druid.apache.org/docs/latest/ingestion/native-batch
public struct IndexParallelTaskSpec: Codable, Hashable, Equatable {
    /// The task ID. If omitted, Druid generates the task ID using the task type, data source name, interval, and date-time stamp.
    public let id: String?

    /// The ingestion spec that defines the data schema, IO config, and tuning config.
    public let spec: ParallelIndexIngestionSpec
}
