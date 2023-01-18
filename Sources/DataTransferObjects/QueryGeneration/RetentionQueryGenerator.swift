//
//  RetentionQueryGenerator.swift
//
//
//  Created by Daniel Jilg on 28.11.22.
//

import Foundation

public enum RetentionQueryGenerator {
    public enum RetentionQueryGeneratorErrors: Error {
        /// beginDate and endDate are less than one month apart
        case datesTooClose
    }

    public static func generateRetentionQuery(appID: String, testMode: Bool, beginDate: Date, endDate: Date) throws -> CustomQuery {
        // If beginDate and endDate are less than 1m apart, this does not make sense as a query
        let components = Calendar.current.dateComponents([.month], from: beginDate, to: endDate)
        if (components.month ?? 0) < 1 {
            throw RetentionQueryGeneratorErrors.datesTooClose
        }

        let months = splitIntoMonthLongIntervals(from: beginDate, to: endDate)

        // Collect all Aggregators and PostAggregators
        var aggregators = [Aggregator]()
        var postAggregators = [PostAggregator]()

        for month in months {
            aggregators.append(aggregator(for: month))
        }

        for row in months {
            for column in months where column >= row {
                postAggregators.append(postAggregatorBetween(interval1: row, interval2: column))
            }
        }

        // Combine query
        return CustomQuery(
            queryType: .groupBy,
            dataSource: "telemetry-signals",
            filter: .and(.init(fields: [
                .selector(.init(dimension: "appID", value: appID)),
                .selector(.init(dimension: "isTestMode", value: testMode ? "true" : "false"))
            ])),
            intervals: [QueryTimeInterval(beginningDate: beginDate, endDate: endDate)],
            granularity: .all,
            aggregations: aggregators.uniqued(),
            postAggregations: postAggregators.uniqued()
        )
    }

    static func numberOfMonthsBetween(beginDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: beginDate, to: endDate)
        return components.month ?? 0
    }

    static func splitIntoMonthLongIntervals(from fromDate: Date, to toDate: Date) -> [DateInterval] {
        let calendar = Calendar.current
        let numberOfMonths = numberOfMonthsBetween(beginDate: fromDate, endDate: toDate)
        var intervals = [DateInterval]()
        for month in 0 ... numberOfMonths {
            let startOfMonth = calendar.date(byAdding: .month, value: month, to: fromDate)!.startOfMonth
            let endOfMonth = startOfMonth.endOfMonth
            let interval = DateInterval(start: startOfMonth, end: endOfMonth)
            intervals.append(interval)
        }
        return intervals
    }

    // beginning of the month
    static func beginningOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    // end of the month
    static func endOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: calendar.date(from: components)!)!
    }

    static func title(for interval: DateInterval) -> String {
        "\(DateFormatter.iso8601.string(from: interval.start))_\(DateFormatter.iso8601.string(from: interval.end))"
    }

    static func aggregator(for interval: DateInterval) -> Aggregator {
        return .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [.init(dateInterval: interval)]
            )),
            aggregator: .thetaSketch(.init(
                type: .thetaSketch,
                name: "_\(title(for: interval))",
                fieldName: "clientUser"
            ))
        )
        )
    }

    static func postAggregatorBetween(interval1: DateInterval, interval2: DateInterval) -> PostAggregator {
        return .thetaSketchEstimate(.init(
            name: "retention_\(title(for: interval1))_\(title(for: interval2))",
            field: .thetaSketchSetOp(.init(
                func: .intersect,
                fields: [
                    .fieldAccess(.init(type: .fieldAccess, fieldName: "_\(title(for: interval1))")),
                    .fieldAccess(.init(type: .fieldAccess, fieldName: "_\(title(for: interval2))"))
                ]
            )
            )
        )
        )
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
