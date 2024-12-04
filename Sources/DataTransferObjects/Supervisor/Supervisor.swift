/// Datasource / Namespace Supervisor definition
public struct Supervisor: Codable, Hashable, Equatable {
    public init(type: Supervisor.SupervisorType, spec: SupervisorSpec? = nil, suspended: Bool? = nil) {
        self.type = type
        self.spec = spec
        self.suspended = suspended
    }

    public enum SupervisorType: String, Codable, CaseIterable {
        case kafka
        case kinesis
        case rabbit
        case autocompact
    }

    /// The supervisor type
    public let type: SupervisorType

    /// The container object for the supervisor configuration.
    public let spec: SupervisorSpec?

    /// Indicates whether the supervisor is in a suspended state.
    public let suspended: Bool?
}
