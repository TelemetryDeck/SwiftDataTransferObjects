import DateOperations
import Foundation

public struct RelativeTimeInterval: Codable, Hashable, Equatable, Sendable {
    public init(beginningDate: RelativeDate, endDate: RelativeDate) {
        self.beginningDate = beginningDate
        self.endDate = endDate
    }

    public let beginningDate: RelativeDate
    public let endDate: RelativeDate
}

public struct RelativeDate: Codable, Hashable, Equatable, Sendable {
    public enum RelativeDateComponent: String, Codable, Hashable, Equatable, Sendable {
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

    public enum ComponentPosition: String, Codable, Hashable, Equatable, Sendable {
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
    static func from(relativeDate: RelativeDate, originDate: Date? = nil) -> Date {
        var date = originDate ?? Date()

        let calendarComponent = relativeDate.component.calendarComponent

        // Swift's Calendar has a known bug where adding/subtracting .quarter doesn't work correctly.
        // Work around this by converting quarters to months (1 quarter = 3 months).
        if relativeDate.component == .quarter {
            date = date.calendar.date(byAdding: .month, value: relativeDate.offset * 3, to: date) ?? date
        } else {
            date = date.calendar.date(byAdding: calendarComponent, value: relativeDate.offset, to: date) ?? date
        }

        // Swift's Calendar also has bugs with beginning(of: .quarter) and end(of: .quarter).
        // Implement custom quarter boundary logic.
        if relativeDate.component == .quarter {
            switch relativeDate.position {
            case .beginning:
                date = date.beginningOfQuarter ?? date
            case .end:
                date = date.endOfQuarter ?? date
            }
        } else {
            switch relativeDate.position {
            case .beginning:
                date = date.beginning(of: calendarComponent) ?? date
            case .end:
                date = date.end(of: calendarComponent) ?? date
            }
        }

        return date
    }

    /// Returns the first moment of the quarter containing this date.
    /// Q1: Jan 1, Q2: Apr 1, Q3: Jul 1, Q4: Oct 1
    private var beginningOfQuarter: Date? {
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)

        // Determine the first month of the quarter (1, 4, 7, or 10)
        let quarterIndex = (month - 1) / 3  // 0, 1, 2, or 3
        let firstMonthOfQuarter = quarterIndex * 3 + 1

        var components = DateComponents()
        components.year = year
        components.month = firstMonthOfQuarter
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0

        return calendar.date(from: components)
    }

    /// Returns the last moment of the quarter containing this date.
    /// Q1: Mar 31 23:59:59, Q2: Jun 30, Q3: Sep 30, Q4: Dec 31
    private var endOfQuarter: Date? {
        guard let beginningOfNextQuarter = quarterAfter?.beginningOfQuarter else {
            return nil
        }

        // Subtract 1 second to get the last moment of the current quarter
        return calendar.date(byAdding: .second, value: -1, to: beginningOfNextQuarter)
    }

    /// Returns a date in the next quarter
    private var quarterAfter: Date? {
        calendar.date(byAdding: .month, value: 3, to: self)
    }
}

public extension QueryTimeInterval {
    static func from(relativeTimeInterval: RelativeTimeInterval) -> QueryTimeInterval {
        QueryTimeInterval(
            beginningDate: Date.from(relativeDate: relativeTimeInterval.beginningDate),
            endDate: Date.from(relativeDate: relativeTimeInterval.endDate)
        )
    }
}
