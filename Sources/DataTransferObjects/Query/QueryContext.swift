import Foundation

public struct QueryContext: Codable, Hashable, Sendable {
    /// Query timeout in millis, beyond which unfinished queries will be cancelled. 0 timeout means no timeout.
    public var timeout: String?

    /// Query Priority. Queries with higher priority get precedence for computational resources. Default: 0
    public var priority: Int?

    public var timestampResultField: String? = "d0"

    // topN specific context
    public var minTopNThreshold: Int?
    // time series specific contexts

    /// Druid can include an extra "grand totals" row as the last row of a timeseries result set. To enable this, add "grandTotal" : true to your query context. For example:
    public var grandTotal: Bool?

    /// Timeseries queries normally fill empty interior time buckets with zeroes.
    public var skipEmptyBuckets: Bool?

    /// How long are the results of this query valid for?
    ///
    /// This is used to determine whether to use cached results or to re-run the query. Value is in minutes.
    ///
    /// The query server may choose to ignore this value.
    public var cacheValidityDuration: Int?

    public init(
        timeout: String? = nil,
        priority: Int? = nil,
        timestampResultField: String? = nil,
        minTopNThreshold: Int? = nil,
        grandTotal: Bool? = nil,
        skipEmptyBuckets: Bool? = nil,
        cacheValidityDuration: Int? = nil
    ) {
        self.timeout = timeout
        self.priority = priority
        self.timestampResultField = timestampResultField
        self.minTopNThreshold = minTopNThreshold
        self.grandTotal = grandTotal
        self.skipEmptyBuckets = skipEmptyBuckets
        self.cacheValidityDuration = cacheValidityDuration
    }
}
