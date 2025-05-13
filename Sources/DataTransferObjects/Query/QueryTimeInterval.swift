import DateOperations
import Foundation

public struct QueryTimeIntervalsContainer: Codable, Hashable, Equatable {
    public enum ContainerType: String, Codable, Hashable, Equatable {
        case intervals
    }

    public init(type: QueryTimeIntervalsContainer.ContainerType, intervals: [QueryTimeInterval]) {
        self.type = type
        self.intervals = intervals
    }

    public init(type: QueryTimeIntervalsContainer.ContainerType, timeSegments: [TimeSegment]) throws {
        self.type = type

        // Sort and deduplicate time segments
        let timeSegmentsNormalized = Set(timeSegments).sorted { $0.beginningDate < $1.beginningDate }

        if timeSegmentsNormalized.isEmpty {
            self.intervals = []
            return
        }

        var component: Calendar.Component
        switch timeSegmentsNormalized.first!.duration {
        case .hour:
            component = .hour
        case .day:
            component = .day
        case .month:
            component = .month
        case .year:
            component = .year
        default:
            throw CustomQuery.QueryGenerationError.compilationStatusError
        }

        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        var intervals = [QueryTimeInterval]()
        var currentInterval = QueryTimeInterval(beginningDate: timeSegmentsNormalized.first!.beginningDate, endDate: timeSegmentsNormalized.first!.beginningDate)

        for segment in timeSegmentsNormalized {
            // If the segment is not continouus, create a new interval
            if try segment.beginningDate > calendar.add(component, to: currentInterval.endDate) {
                currentInterval.endDate = try calendar.add(component, to: currentInterval.endDate)
                intervals.append(currentInterval)
                currentInterval = QueryTimeInterval(beginningDate: segment.beginningDate, endDate: segment.beginningDate)
            }

            // Extend the current interval
            if segment.beginningDate > currentInterval.endDate {
                currentInterval.endDate = segment.beginningDate
            }
        }
        currentInterval.endDate = try calendar.add(component, to: currentInterval.endDate)
        intervals.append(currentInterval)

        self.intervals = intervals
    }

    public let type: ContainerType
    public let intervals: [QueryTimeInterval]

    public func timeSegments(with granularity: QueryGranularity) throws -> [TimeSegment] {
        var segments = Set<TimeSegment>()

        for interval in intervals {
            let intervalSegments = try interval.timeSegments(with: granularity)
            segments.formUnion(intervalSegments)
        }

        return segments.sorted { $0.beginningDate < $1.beginningDate }
    }
}

public struct QueryTimeInterval: Codable, Hashable, Equatable, Comparable {
    public var beginningDate: Date
    public var endDate: Date

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
        beginningDate = dateInterval.start
        endDate = dateInterval.end
    }

    public static func < (lhs: QueryTimeInterval, rhs: QueryTimeInterval) -> Bool {
        if lhs.beginningDate == rhs.beginningDate { return lhs.endDate < rhs.endDate }
        return lhs.beginningDate < rhs.beginningDate
    }

    public func timeSegments(with granularity: QueryGranularity) throws -> [TimeSegment] {
        var segments = [TimeSegment]()

        var component: Calendar.Component
        switch granularity {
        case .hour:
            component = .hour
        case .day:
            component = .day
        case .month:
            component = .month
        case .year:
            component = .year
        default:
            throw CustomQuery.QueryGenerationError.notImplemented(reason: "Granularity \(granularity) not implemented for windowed caching.")
        }

        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        var currentDate: Date?
        if component == .day {
            currentDate = calendar.startOfDay(for: beginningDate)
        } else {
            var components: Set<Calendar.Component> {
                switch component {
                case .hour:
                    return [.year, .month, .day, .hour]

                case .month:
                    return [.year, .month]

                case .year:
                    return [.year]

                default:
                    return []
                }
            }

            guard !components.isEmpty else { throw CustomQuery.QueryGenerationError.notImplemented(reason: "Granularity \(granularity) not implemented for windowed caching.") }
            currentDate = calendar.date(from: calendar.dateComponents(components, from: beginningDate))
        }

        guard var currentDate else {
            throw CustomQuery.QueryGenerationError.notImplemented(reason: "Granularity \(granularity) not implemented for windowed caching.")
        }

        while currentDate < endDate {
            let nextDate = try calendar.add(component, to: currentDate)
            let segment = TimeSegment(beginningDate: currentDate, duration: granularity)
            segments.append(segment)
            currentDate = nextDate
        }

        return segments
    }
}

public struct TimeSegment: Codable, Hashable, Equatable {
    public init(beginningDate: Date, duration: QueryGranularity) {
        self.beginningDate = beginningDate
        self.duration = duration
    }

    public let beginningDate: Date
    public let duration: QueryGranularity
}

extension Calendar {
    func add(_ component: Calendar.Component, value: Int = 1, to date: Date) throws -> Date {
        guard let result = self.date(byAdding: component, value: value, to: date) else {
            throw CustomQuery.QueryGenerationError.compilationStatusError
        }
        return result
    }
}
