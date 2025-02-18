/// This virtual column provides an alternative way to use 'list filtered' dimension spec as a virtual column. It has optimized access
/// to the underlying column value indexes that can provide a small performance improvement in some cases.
public struct ListFilteredVirtualColumn: Codable, Hashable, Equatable {
    public init(name: String, delegate: String, values: [String], isAllowList: Bool? = nil) {
        self.name = name
        self.delegate = delegate
        self.values = values
        self.isAllowList = isAllowList
    }

    /// The output name of the virtual column
    public let name: String

    /// The name of the multi-value STRING input column to filter
    public let delegate: String

    /// Set of STRING values to allow or deny
    public let values: [String]

    /// If true, the output of the virtual column will be limited to the set specified by values,
    /// else it will provide all values except those specified.
    public let isAllowList: Bool?
}
