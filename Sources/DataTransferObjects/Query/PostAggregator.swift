// swiftlint:disable cyclomatic_complexity

import Foundation

/// Post-aggregations are specifications of processing that should happen on aggregated values as they come out of the timeseries DB.
/// If you include a post aggregation as part of a query, make sure to include all aggregators the post-aggregator requires.
/// 
/// https://druid.apache.org/docs/latest/querying/post-aggregations.html
public indirect enum PostAggregator: Codable, Hashable {
    case test
}
