/// The transformSpec is located in dataSchema → transformSpec and is responsible for transforming and filtering records during
/// ingestion time. It is optional.
///
/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#transformspec
public struct TransformSpec: Codable, Hashable, Equatable, Sendable {
    public init(transforms: [TransformSpecTransform]? = nil, filter: Filter? = nil) {
        self.transforms = transforms
        self.filter = filter
    }

    public let transforms: [TransformSpecTransform]?
    public let filter: Filter?
}

public struct TransformSpecTransform: Codable, Hashable, Equatable, Sendable {
    public init(type: String, name: String? = nil, expression: String? = nil) {
        self.type = type
        self.name = name
        self.expression = expression
    }

    public let type: String
    public let name: String?

    /// https://druid.apache.org/docs/latest/querying/math-expr
    public let expression: String?
}
