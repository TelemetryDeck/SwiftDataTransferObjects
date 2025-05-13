/// The container object for the supervisor configuration.
public struct ParallelIndexIngestionSpec: Codable, Hashable, Equatable {
    public init(ioConfig: IoConfig? = nil, tuningConfig: TuningConfig? = nil, dataSchema: DataSchema? = nil) {
        self.ioConfig = ioConfig
        self.tuningConfig = tuningConfig
        self.dataSchema = dataSchema
    }

    public let ioConfig: IoConfig?
    public let tuningConfig: TuningConfig?
    public let dataSchema: DataSchema?
}
