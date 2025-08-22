import Foundation
import DateOperations

extension CustomQuery {
    func precompiledRetentionQuery() throws -> CustomQuery {
        var query = self
        
        // Get the query intervals - we need at least one interval
        guard let intervals = intervals ?? relativeIntervals?.map({ QueryTimeInterval.from(relativeTimeInterval: $0) }),
              let firstInterval = intervals.first else {
            throw QueryGenerationError.keyMissing(reason: "Missing intervals for retention query")
        }
        
        let beginDate = firstInterval.beginningDate
        let endDate = firstInterval.endDate
        
        // Check if the dates are at least one month apart
        let components = Calendar.current.dateComponents([.month], from: beginDate, to: endDate)
        if (components.month ?? 0) < 1 {
            throw QueryGenerationError.notImplemented(reason: "Retention queries require at least one month between begin and end dates")
        }
        
        // Split into month-long intervals
        let months = splitIntoMonthLongIntervals(from: beginDate, to: endDate)
        
        // Generate Aggregators
        var aggregators = [Aggregator]()
        for month in months {
            aggregators.append(aggregator(for: month))
        }
        
        // Generate Post-Aggregators
        var postAggregators = [PostAggregator]()
        for row in months {
            for column in months where column >= row {
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
    
    // Helper methods from RetentionQueryGenerator
    private func splitIntoMonthLongIntervals(from fromDate: Date, to toDate: Date) -> [DateInterval] {
        let calendar = Calendar.current
        let numberOfMonths = numberOfMonthsBetween(beginDate: fromDate, endDate: toDate)
        var intervals = [DateInterval]()
        
        for month in 0...numberOfMonths {
            guard let dateWithAddedMonths = calendar.date(byAdding: .month, value: month, to: fromDate) else { continue }
            let startOfMonth = dateWithAddedMonths.beginning(of: .month) ?? dateWithAddedMonths
            let endOfMonth = startOfMonth.end(of: .month) ?? startOfMonth
            let interval = DateInterval(start: startOfMonth, end: endOfMonth)
            intervals.append(interval)
        }
        
        return intervals
    }
    
    private func numberOfMonthsBetween(beginDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: beginDate, to: endDate)
        return components.month ?? 0
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