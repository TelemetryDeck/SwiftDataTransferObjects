import Foundation

/// Display configuration for charts. Overrides various default display options.
///
/// Not hashable, because we don't want to include these values in the cache, as cached calculation results won't change based on these values.
public struct ChartConfiguration: Codable, Equatable, Sendable {
    /// The display mode for the chart.
    public var displayMode: ChartDisplayMode?

    /// Enable dark mode for this chart
    public var darkMode: Bool?

    /// Global chart settings
    public var options: ChartConfigurationOptions?

    /// Applied to every single aggregation and post-aggregation in the chart
    public var aggregationConfiguration: ChartAggregationConfiguration?

    public var explanation: String?

    public init(
        displayMode: ChartDisplayMode? = nil,
        darkMode: Bool? = nil,
        options: ChartConfigurationOptions? = nil,
        aggregationConfiguration: ChartAggregationConfiguration? = nil,
        explanation: String? = nil
    ) {
        self.displayMode = displayMode
        self.darkMode = darkMode
        self.options = options
        self.aggregationConfiguration = aggregationConfiguration
        self.explanation = explanation
    }
}

public enum ChartDisplayMode: String, Codable, Sendable {
    case raw
    case barChart
    case lineChart
    case pieChart
    case funnelChart
    case experimentChart
    case matrix
    case sankey
    case lineChartRace
}
