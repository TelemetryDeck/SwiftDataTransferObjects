import Foundation

public struct CustomSQLQuery: Codable, Hashable {
    let query: String
    let context: QueryContext

    public init(query: String, context: QueryContext) {
        self.query = query
        self.context = context
    }
}
