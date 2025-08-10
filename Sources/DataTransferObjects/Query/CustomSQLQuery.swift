import Foundation

public struct CustomSQLQuery: Codable, Hashable, Sendable {
    let query: String
    let context: QueryContext

    public init(query: String, context: QueryContext) {
        self.query = query
        self.context = context
    }
}
