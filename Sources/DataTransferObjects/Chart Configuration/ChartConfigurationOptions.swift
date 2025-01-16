import Foundation

/// Options for configuring a chart in our charting library
///
/// Subset of echart's options https://echarts.apache.org/en/option.html
public struct ChartConfigurationOptions: Codable, Equatable {
    /// Whether to enable animation.
    public var animation: Bool?

    /// Duration of the animation in milliseconds.
    public var animationDuration: Int?

    /// Easing function of the animation.
    public var animationEasing: EasingFunction?

    /// Show a tooltip for this chart
    public var tooltip: ToolTipConfiguration?

    public var grid: GridConfiguration?

    public var xAxis: AxisOptions?
    public var yAxis: AxisOptions?

    public init(
        animation: Bool? = nil,
        animationDuration: Int? = nil,
        animationEasing: EasingFunction? = nil,
        tooltip: ToolTipConfiguration? = nil,
        grid: GridConfiguration? = nil,
        xAxis: AxisOptions? = nil,
        yAxis: AxisOptions? = nil
    ) {
        self.animation = animation
        self.animationDuration = animationDuration
        self.animationEasing = animationEasing
        self.tooltip = tooltip
        self.grid = grid
        self.xAxis = xAxis
        self.yAxis = yAxis
    }
}

public struct ToolTipConfiguration: Codable, Equatable {
    public var show: Bool?

    public init(show: Bool? = nil) {
        self.show = show
    }
}

public struct GridConfiguration: Codable, Equatable {
    public var top: Int?
    public var bottom: Int?
    public var left: Int?
    public var right: Int?
    public var containLabel: Bool?

    public init(
        top: Int? = nil,
        bottom: Int? = nil,
        left: Int? = nil,
        right: Int? = nil,
        containLabel: Bool? = nil
    ) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.containLabel = containLabel
    }
}

public enum EasingFunction: String, Codable {
    case linear
    case quadraticIn
    case quadraticOut
    case quadraticInOut
    case cubicIn
    case cubicOut
    case cubicInOut
    case quarticIn
    case quarticOut
    case quarticInOut
    case quinticIn
    case quinticOut
    case quinticInOut
    case sinusoidalIn
    case sinusoidalOut
    case sinusoidalInOut
    case exponentialIn
    case exponentialOut
    case exponentialInOut
    case circularIn
    case circularOut
    case circularInOut
    case elasticIn
    case elasticOut
    case elasticInOut
    case backIn
    case backOut
    case backInOut
    case bounceIn
    case bounceOut
    case bounceInOut
}

public struct AxisOptions: Codable, Equatable {
    /// Set this to false to prevent the axis from showing.
    public var show: Bool?
    public var position: Position?
    public var type: AxisType?
    public var name: String?
    /// Set this to true to invert the axis.
    public var inverse: Bool?

    public init(
        show: Bool? = nil,
        position: AxisOptions.Position? = nil,
        type: AxisOptions.AxisType? = nil,
        name: String? = nil,
        inverse: Bool? = nil
    ) {
        self.show = show
        self.position = position
        self.type = type
        self.name = name
        self.inverse = inverse
    }

    public enum Position: String, Codable, Equatable {
        case top
        case bottom
    }

    public enum AxisType: String, Codable, Equatable {
        /// Numerical axis, suitable for continuous data.
        case value
        /// Category axis, suitable for discrete category data.
        case category
        /// Time axis, suitable for continuous time series data. As compared to value axis, it has a better formatting for time and a different tick calculation method. For example, it decides to use month, week, day or hour for tick based on the range of span.
        case time
        /// Log axis, suitable for log data. Stacked bar or line series with type: 'log' axes may lead to significant visual errors and may have unintended effects in certain circumstances. Their use should be avoided.
        case log
    }
}
