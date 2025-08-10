/// The Druid input source is to support reading data directly from existing Druid segments, potentially using a new schema
/// and changing the name, dimensions, metrics, rollup, etc. of the segment. The Druid input source is splittable and can be
/// used by the parallel task. This input source has a fixed input format for reading from Druid segments; no inputFormat
/// field needs to be specified in the ingestion spec when using this input source.
/// https://github.com/apache/druid/blob/master/indexing-service/src/main/java/org/apache/druid/indexing/input/DruidInputSource.java
///
public struct DruidInputSource: Codable, Hashable, Equatable, Sendable {
    public init(dataSource: String, interval: QueryTimeInterval, filter: Filter? = nil) {
        self.dataSource = dataSource
        self.interval = interval
        self.filter = filter
    }

    /// A String defining the Druid datasource to fetch rows from
    public let dataSource: String

    /// A String representing an ISO-8601 interval, which defines the time range to fetch the data over.
    public let interval: QueryTimeInterval

    /// Only rows that match the filter, if specified, will be returned.
    public let filter: Filter?
}
