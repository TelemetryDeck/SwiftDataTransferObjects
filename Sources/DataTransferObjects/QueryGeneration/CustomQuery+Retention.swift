import Foundation
import DateOperations

extension CustomQuery {
    func precompiledRetentionQuery() throws -> CustomQuery {
        var query = self
        
        // Get the query intervals - we need at least one interval
        guard let queryIntervals = intervals ?? relativeIntervals?.map({ QueryTimeInterval.from(relativeTimeInterval: $0) }),
              let firstInterval = queryIntervals.first else {
            throw QueryGenerationError.keyMissing(reason: "Missing intervals for retention query")
        }
        
        let beginDate = firstInterval.beginningDate
        let endDate = firstInterval.endDate
        
        // Use the query's granularity to determine retention period, defaulting to month if not specified
        let retentionGranularity = query.granularity ?? .month
        
        // Validate minimum interval based on granularity
        try validateMinimumInterval(from: beginDate, to: endDate, granularity: retentionGranularity)
        
        // Split into intervals based on the specified granularity
        let retentionIntervals = try splitIntoIntervals(from: beginDate, to: endDate, granularity: retentionGranularity)
        
        // Generate Aggregators
        var aggregators = [Aggregator]()
        for interval in retentionIntervals {
            aggregators.append(aggregator(for: interval))
        }
        
        // Generate Post-Aggregators
        var postAggregators = [PostAggregator]()
        for row in retentionIntervals {
            for column in retentionIntervals where column >= row {
                postAggregators.append(postAggregatorBetween(interval1: row, interval2: column))
            }
        }
        
        // Set the query properties
        query.queryType = .groupBy
        query.granularity = .all
        query.aggregations = uniqued(aggregators)
        query.postAggregations = uniqued(postAggregators)
        
        return query
    }
    
    private func uniqued<T: Hashable>(_ array: [T]) -> [T] {
        var set = Set<T>()
        return array.filter { set.insert($0).inserted }
    }
    
    // MARK: - Helper Methods
    
    private func validateMinimumInterval(from beginDate: Date, to endDate: Date, granularity: QueryGranularity) throws {
        let calendar = Calendar.current
        
        switch granularity {
        case .day:
            let components = calendar.dateComponents([.day], from: beginDate, to: endDate)
            if (components.day ?? 0) < 1 {
                throw QueryGenerationError.notImplemented(reason: "Daily retention queries require at least one day between begin and end dates")
            }
        case .week:
            let components = calendar.dateComponents([.weekOfYear], from: beginDate, to: endDate)
            if (components.weekOfYear ?? 0) < 1 {
                throw QueryGenerationError.notImplemented(reason: "Weekly retention queries require at least one week between begin and end dates")
            }
        case .month:
            let components = calendar.dateComponents([.month], from: beginDate, to: endDate)
            if (components.month ?? 0) < 1 {
                throw QueryGenerationError.notImplemented(reason: "Monthly retention queries require at least one month between begin and end dates")
            }
        case .quarter:
            let components = calendar.dateComponents([.quarter], from: beginDate, to: endDate)
            if (components.quarter ?? 0) < 1 {
                throw QueryGenerationError.notImplemented(reason: "Quarterly retention queries require at least one quarter between begin and end dates")
            }
        case .year:
            let components = calendar.dateComponents([.year], from: beginDate, to: endDate)
            if (components.year ?? 0) < 1 {
                throw QueryGenerationError.notImplemented(reason: "Yearly retention queries require at least one year between begin and end dates")
            }
        default:
            throw QueryGenerationError.notImplemented(reason: "Retention queries support day, week, month, quarter, or year granularity")
        }
    }
    
    private func splitIntoIntervals(from fromDate: Date, to toDate: Date, granularity: QueryGranularity) throws -> [DateInterval] {
        let calendar = Calendar.current
        var intervals = [DateInterval]()
        
        switch granularity {
        case .day:
            let numberOfDays = numberOfUnitsBetween(beginDate: fromDate, endDate: toDate, component: .day)
            for day in 0...numberOfDays {
                guard let date = calendar.date(byAdding: .day, value: day, to: fromDate) else { continue }
                let startOfDay = date.beginning(of: .day) ?? date
                let endOfDay = startOfDay.end(of: .day) ?? startOfDay
                intervals.append(DateInterval(start: startOfDay, end: endOfDay))
            }
            
        case .week:
            let numberOfWeeks = numberOfUnitsBetween(beginDate: fromDate, endDate: toDate, component: .weekOfYear)
            for week in 0...numberOfWeeks {
                guard let date = calendar.date(byAdding: .weekOfYear, value: week, to: fromDate) else { continue }
                let startOfWeek = date.beginning(of: .weekOfYear) ?? date
                let endOfWeek = startOfWeek.end(of: .weekOfYear) ?? startOfWeek
                intervals.append(DateInterval(start: startOfWeek, end: endOfWeek))
            }
            
        case .month:
            let numberOfMonths = numberOfUnitsBetween(beginDate: fromDate, endDate: toDate, component: .month)
            for month in 0...numberOfMonths {
                guard let date = calendar.date(byAdding: .month, value: month, to: fromDate) else { continue }
                let startOfMonth = date.beginning(of: .month) ?? date
                let endOfMonth = startOfMonth.end(of: .month) ?? startOfMonth
                intervals.append(DateInterval(start: startOfMonth, end: endOfMonth))
            }
            
        case .quarter:
            let numberOfQuarters = numberOfUnitsBetween(beginDate: fromDate, endDate: toDate, component: .quarter)
            for quarter in 0...numberOfQuarters {
                guard let date = calendar.date(byAdding: .quarter, value: quarter, to: fromDate) else { continue }
                let startOfQuarter = date.beginning(of: .quarter) ?? date
                let endOfQuarter = startOfQuarter.end(of: .quarter) ?? startOfQuarter
                intervals.append(DateInterval(start: startOfQuarter, end: endOfQuarter))
            }
            
        case .year:
            let numberOfYears = numberOfUnitsBetween(beginDate: fromDate, endDate: toDate, component: .year)
            for year in 0...numberOfYears {
                guard let date = calendar.date(byAdding: .year, value: year, to: fromDate) else { continue }
                let startOfYear = date.beginning(of: .year) ?? date
                let endOfYear = startOfYear.end(of: .year) ?? startOfYear
                intervals.append(DateInterval(start: startOfYear, end: endOfYear))
            }
            
        default:
            throw QueryGenerationError.notImplemented(reason: "Retention queries support day, week, month, quarter, or year granularity")
        }
        
        return intervals
    }
    
    private func numberOfUnitsBetween(beginDate: Date, endDate: Date, component: Calendar.Component) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([component], from: beginDate, to: endDate)
        
        switch component {
        case .day:
            return components.day ?? 0
        case .weekOfYear:
            return components.weekOfYear ?? 0
        case .month:
            return components.month ?? 0
        case .quarter:
            return components.quarter ?? 0
        case .year:
            return components.year ?? 0
        default:
            return 0
        }
    }
    
    private func title(for interval: DateInterval) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return "\(formatter.string(from: interval.start))_\(formatter.string(from: interval.end))"
    }
    
    private func aggregator(for interval: DateInterval) -> Aggregator {
        .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [.init(dateInterval: interval)]
            )),
            aggregator: .thetaSketch(.init(
                name: "_\(title(for: interval))",
                fieldName: "clientUser"
            ))
        ))
    }
    
    private func postAggregatorBetween(interval1: DateInterval, interval2: DateInterval) -> PostAggregator {
        .thetaSketchEstimate(.init(
            name: "retention_\(title(for: interval1))_\(title(for: interval2))",
            field: .thetaSketchSetOp(.init(
                func: .intersect,
                fields: [
                    .fieldAccess(.init(type: .fieldAccess, fieldName: "_\(title(for: interval1))")),
                    .fieldAccess(.init(type: .fieldAccess, fieldName: "_\(title(for: interval2))")),
                ]
            ))
        ))
    }
}