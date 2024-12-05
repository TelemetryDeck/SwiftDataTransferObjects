/// Expression virtual columns use Druid's native expression system to allow defining query time transforms of inputs from one or more columns.
///
/// https://druid.apache.org/docs/latest/querying/math-expr
public struct ExpressionVirtualColumn: Codable, Hashable, Equatable {
    public init(name: String, expression: String, outputType: String? = nil) {
        self.name = name
        self.expression = expression
        self.outputType = outputType
    }
    
    public let name: String
    public let expression: String
    public let outputType: String?
}


