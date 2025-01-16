import Foundation

/// Configuration for aggregations in a chart.
///
/// Maps to "seriesConfiguration" internally in the charting library.
///
/// Subset of https://echarts.apache.org/en/option.html#series-line
public struct ChartAggregationConfiguration: Codable, Equatable {
    public var startAngle: Int?
    public var endAngle: Int?
    public var radius: [String]?
    public var center: [String]?
    public var stack: String?

    public init(
        startAngle: Int? = nil,
        endAngle: Int? = nil,
        radius: [String]? = nil,
        center: [String]? = nil,
        stack: String? = nil
    ) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.radius = radius
        self.center = center
        self.stack = stack
    }
}
