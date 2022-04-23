import DateOperations
import Foundation

public struct RelativeTimeInterval: Codable, Hashable, Equatable {
    let beginningDate: RelativeDate
    let endDate: RelativeDate
}

public struct RelativeDate: Codable, Hashable, Equatable {
    enum RelativeDateComponent: String, Codable, Hashable, Equatable {
        case hour
        case day
        case week
        case month
        case quarter
        case year

        var calendarComponent: Calendar.Component {
            switch self {
            case .hour:
                return .hour
            case .day:
                return .day
            case .week:
                return .weekOfYear
            case .month:
                return .month
            case .quarter:
                return .quarter
            case .year:
                return .year
            }
        }
    }

    enum ComponentPosition: String, Codable, Hashable, Equatable {
        /// Generate a date at the first possible moment in the specified component
        case beginning

        /// Generate a date at the last possible moment in the specified component
        case end
    }

    init(_ position: ComponentPosition, of component: RelativeDateComponent, adding offset: Int) {
        self.component = component
        self.offset = offset
        self.position = position
    }

    /// The granularity with which to work in this component
    let component: RelativeDateComponent

    /// How often to add the component to the current date.
    ///
    /// 0 is the current day/month/component.
    /// Positive values move the date into the future, negative values move the date into the past.
    let offset: Int

    /// Where in the generated hour/day/month/component should the generated date lie?
    let position: ComponentPosition
}

public extension Date {
    static func from(relativeDate: RelativeDate) -> Date {
        var date = Date()

        let calendarComponent = relativeDate.component.calendarComponent
        date = date.calendar.date(byAdding: calendarComponent, value: relativeDate.offset, to: date) ?? date

        switch relativeDate.position {
        case .beginning:
            date = date.beginning(of: calendarComponent) ?? date
        case .end:
            date = date.end(of: calendarComponent) ?? date
        }

        return date
    }
}

public extension QueryTimeInterval {
    static func from(relativeTimeInterval: RelativeTimeInterval) -> QueryTimeInterval {
        return QueryTimeInterval(
            beginningDate: Date.from(relativeDate: relativeTimeInterval.beginningDate),
            endDate: Date.from(relativeDate: relativeTimeInterval.endDate)
        )
    }
}

#if os(Linux)
extension Date {
    func beginning(of component: Calendar.Component) -> Date? {
        if component == .day {
            return calendar.startOfDay(for: self)
        }

        var components: Set<Calendar.Component> {
            switch component {
            case .second:
                return [.year, .month, .day, .hour, .minute, .second]

            case .minute:
                return [.year, .month, .day, .hour, .minute]

            case .hour:
                return [.year, .month, .day, .hour]

            case .weekOfYear, .weekOfMonth:
                return [.yearForWeekOfYear, .weekOfYear]

            case .month:
                return [.year, .month]

            case .year:
                return [.year]

            default:
                return []
            }
        }

        guard !components.isEmpty else { return nil }
        return calendar.date(from: calendar.dateComponents(components, from: self))
    }
}
#endif
