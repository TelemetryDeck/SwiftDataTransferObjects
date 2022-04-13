import Foundation

public struct Aggregator: Codable, Hashable {
    public init(type: AggregatorType, name: String, fieldName: String? = nil) {
        self.type = type
        self.name = name
        self.fieldName = fieldName
    }

    public let type: AggregatorType

    /// The output name for the aggregated value
    public let name: String

    /// The name of the column to aggregate over. Ignore for aggregator type "count"
    public var fieldName: String?
}

public enum AggregatorType: String, Codable, Hashable {
    case count

    case longSum
    case doubleSum
    case floatSum

    case doubleMin
    case doubleMax
    case floatMin
    case floatMax
    case longMin
    case longMax

    case doubleMean // 😡

    case doubleFirst
    case doubleLast
    case floatFirst
    case floatLast
    case longFirst
    case longLast
    case stringFirst
    case stringLast

    case doubleAny
    case floatAny
    case longAny
    case stringAny

    case thetaSketch

    // JavaScript aggregator missing
}
