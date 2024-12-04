/// The container object for the supervisor configuration.
public struct SupervisorSpec: Codable, Hashable, Equatable {
    public let ioConfig: IoConfig?
    public let tuningConfig: TuningConfig?
    public let dataSchema: DataSchema?
}
