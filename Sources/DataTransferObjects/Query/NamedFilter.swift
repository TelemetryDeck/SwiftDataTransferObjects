import Foundation

public struct NamedFilter: Codable, Hashable, Equatable {
    public init(filter: Filter? = nil, name: String) {
        self.filter = filter
        self.name = name
    }
    
    public let filter: Filter?
    public let name: String
}
