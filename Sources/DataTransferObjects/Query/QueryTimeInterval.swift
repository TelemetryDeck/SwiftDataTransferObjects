import DateOperations
import Foundation

public struct QueryTimeIntervalsContainer: Codable, Hashable, Equatable {
    public enum ContainerType: String, Codable, Hashable, Equatable {
        case intervals
    }
    
    public let type: ContainerType
    public let intervals: [QueryTimeInterval]
}

public struct QueryTimeInterval: Codable, Hashable, Equatable {
    public let beginningDate: Date
    public let endDate: Date

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let date1 = Formatter.iso8601.string(from: beginningDate)
        let date2 = Formatter.iso8601.string(from: endDate)

        try container.encode(date1 + "/" + date2)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intervalString = try container.decode(String.self)

        let intervalArray = intervalString.split(separator: "/").map { String($0) }

        guard let beginningString = intervalArray.first,
              let endString = intervalArray.last,
              let beginningDate = Formatter.iso8601.date(from: beginningString) ?? Formatter.iso8601noFS.date(from: beginningString) ?? Formatter.iso8601dateOnly.date(from: beginningString),
              let endDate = Formatter.iso8601.date(from: endString) ?? Formatter.iso8601noFS.date(from: endString) ?? Formatter.iso8601dateOnly.date(from: endString)
        else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "Could not find two dates!",
                underlyingError: nil
            ))
        }

        self.beginningDate = beginningDate
        self.endDate = endDate
    }

    public init(beginningDate: Date, endDate: Date) {
        self.beginningDate = beginningDate
        self.endDate = endDate
    }
    
    public init(dateInterval: DateInterval) {
        self.beginningDate = dateInterval.start
        self.endDate = dateInterval.end
    }
}
