import Foundation

/// Display configuration for charts. Overrides various default display options.
///
/// Not hashable, because we don't want to include these values in the cache, as cached calculation results won't change based on these values.
public struct ChartConfiguration: Codable, Equatable {
    /// The display mode for the chart.
    public var displayMode: ChartDisplayMode?

    /// Enable dark mode for this chart
    public var darkMode: Bool?

    /// Global chart settings
    public var options: ChartConfigurationOptions?

    /// Applied to every single aggregation and post-aggregation in the chart
    public var aggregationConfiguration: ChartAggregationConfiguration?

    public init(
        displayMode: ChartDisplayMode? = nil,
        darkMode: Bool? = nil,
        options: ChartConfigurationOptions? = nil,
        aggregationConfiguration: ChartAggregationConfiguration? = nil
    ) {
        self.displayMode = displayMode
        self.darkMode = darkMode
        self.options = options
        self.aggregationConfiguration = aggregationConfiguration
    }
}

public enum ChartDisplayMode: String, Codable {
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
