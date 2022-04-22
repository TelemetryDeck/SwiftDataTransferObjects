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
        return Date()
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
