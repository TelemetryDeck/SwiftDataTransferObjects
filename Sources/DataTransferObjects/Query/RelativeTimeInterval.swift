import DateOperations
import Foundation

public struct RelativeTimeInterval: Codable, Hashable, Equatable {
    public init(beginningDate: RelativeDate, endDate: RelativeDate) {
        self.beginningDate = beginningDate
        self.endDate = endDate
    }

    public let beginningDate: RelativeDate
    public let endDate: RelativeDate
}

public struct RelativeDate: Codable, Hashable, Equatable {
    public enum RelativeDateComponent: String, Codable, Hashable, Equatable {
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

    public enum ComponentPosition: String, Codable, Hashable, Equatable {
        /// Generate a date at the first possible moment in the specified component
        case beginning

        /// Generate a date at the last possible moment in the specified component
        case end
    }

    public init(_ position: ComponentPosition, of component: RelativeDateComponent, adding offset: Int) {
        self.component = component
        self.offset = offset
        self.position = position
    }

    /// The granularity with which to work in this component
    public let component: RelativeDateComponent

    /// How often to add the component to the current date.
    ///
    /// 0 is the current day/month/component.
    /// Positive values move the date into the future, negative values move the date into the past.
    public let offset: Int

    /// Where in the generated hour/day/month/component should the generated date lie?
    public let position: ComponentPosition
}

public extension Date {
    static func from(relativeDate: RelativeDate, startWeekOnMonday: Bool) -> Date {
        var date = Date()

        var calendar = date.calendar
        calendar.firstWeekday = startWeekOnMonday ? 2 : 1 // 1 is Sunday, 2 is Monday
        
        let calendarComponent = relativeDate.component.calendarComponent
        date = calendar.date(byAdding: calendarComponent, value: relativeDate.offset, to: date) ?? date

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
    static func from(relativeTimeInterval: RelativeTimeInterval, startWeekOnMonday: Bool) -> QueryTimeInterval {
        QueryTimeInterval(
            beginningDate: Date.from(relativeDate: relativeTimeInterval.beginningDate, startWeekOnMonday: startWeekOnMonday),
            endDate: Date.from(relativeDate: relativeTimeInterval.endDate, startWeekOnMonday: startWeekOnMonday)
        )
    }
}
