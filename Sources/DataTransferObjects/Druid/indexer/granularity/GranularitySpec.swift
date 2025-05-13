/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#granularityspec
/// https://github.com/apache/druid/blob/master/processing/src/main/java/org/apache/druid/indexer/granularity/GranularitySpec.java
public struct GranularitySpec: Codable, Hashable, Equatable {
    public init(
        type: GranularitySpec.GranularitySpecType? = nil,
        segmentGranularity: QueryGranularity? = nil,
        queryGranularity: QueryGranularity? = nil,
        rollup: Bool? = nil,
        intervals: [String]? = nil
    ) {
        self.type = type
        self.segmentGranularity = segmentGranularity
        self.queryGranularity = queryGranularity
        self.rollup = rollup
        self.intervals = intervals
    }

    public enum GranularitySpecType: String, Codable, CaseIterable {
        case uniform
    }

    public let type: GranularitySpecType?

    /// Time chunking granularity for this datasource. Multiple segments can be created per time chunk. For example, when set to day, the
    ///  events of the same day fall into the same time chunk which can be optionally further partitioned into multiple segments based on
    ///   other configurations and input size. Any granularity can be provided here. Note that all segments in the same time chunk should
    ///   have the same segment granularity.
    ///
    /// Avoid WEEK granularity for data partitioning because weeks don't align neatly with months and years, making it difficult to change
    ///  partitioning by coarser granularity. Instead, opt for other partitioning options such as DAY or MONTH, which offer more
    ///  flexibility.
    public let segmentGranularity: QueryGranularity?

    /// The resolution of timestamp storage within each segment. This must be equal to, or finer, than segmentGranularity. This will be the
    ///  finest granularity that you can query at and still receive sensible results, but note that you can still query at anything coarser
    ///   than this granularity. E.g., a value of minute will mean that records will be stored at minutely granularity, and can be sensibly
    ///    queried at any multiple of minutes (including minutely, 5-minutely, hourly, etc).
    ///
    /// Any granularity can be provided here. Use none to store timestamps as-is, without any truncation. Note that rollup will be applied
    /// if it is set even when the queryGranularity is set to none.
    public let queryGranularity: QueryGranularity?

    /// Whether to use ingestion-time rollup or not. Note that rollup is still effective even when queryGranularity is set to none. Your data
    /// will be rolled up if they have the exactly same timestamp.
    public let rollup: Bool?

    /// A list of intervals defining time chunks for segments. Specify interval values using ISO8601 format. For example,
    /// ["2021-12-06T21:27:10+00:00/2021-12-07T00:00:00+00:00"]. If you omit the time, the time defaults to "00:00:00".
    ///
    /// Druid breaks the list up and rounds off the list values based on the segmentGranularity.
    ///
    /// If null or not provided, batch ingestion tasks generally determine which time chunks to output based on the timestamps found in the
    ///  input data.
    ///
    /// If specified, batch ingestion tasks may be able to skip a determining-partitions phase, which can result in faster ingestion. Batch
    /// ingestion tasks may also be able to request all their locks up-front instead of one by one. Batch ingestion tasks throw away any
    /// records with timestamps outside of the specified intervals.
    ///
    /// Ignored for any form of streaming ingestion.
    public let intervals: [String]?
}
