/// The transformSpec is located in dataSchema → transformSpec and is responsible for transforming and filtering records during
/// ingestion time. It is optional.
///
/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#transformspec
public struct TransformSpec: Codable, Hashable, Equatable {
    public let transforms: [TransformSpecTransform]?
    public let filter: Filter?
}

public struct TransformSpecTransform: Codable, Hashable, Equatable {
    public let type: String
    public let name: String?

    /// https://druid.apache.org/docs/latest/querying/math-expr
    public let expression: String?
}
