/// The split hint spec is used to help the supervisor task divide input sources. Each worker task processes a single input division. You can control the amount of data each worker task reads during the first phase.
///
/// https://druid.apache.org/docs/latest/ingestion/native-batch/#split-hint-spec
public indirect enum SplitHintSpec: Codable, Hashable, Equatable, Sendable {
    case notImplemented
}
