import Foundation

/// A named filter
///
/// Used in e.g. funnel steps and A/B test experiments or in other
/// places where a subset of a query needs to be named.
public struct NamedFilter: Codable, Hashable, Equatable {
    public init(filter: Filter? = nil, name: String) {
        self.filter = filter
        self.name = name
    }
    
    public let filter: Filter?
    public let name: String
}
