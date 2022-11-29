//
//  HashingTests.swift
//
//
//  Created by Daniel Jilg on 18.01.22.
//

import DataTransferObjects
import XCTest

class HashingTests: XCTestCase {
    static let beginDate: Date = Formatter.iso8601.date(from: "2021-12-03T00:00:00.000Z")!
    static let endDate: Date = Formatter.iso8601.date(from: "2022-01-31T22:59:59.999Z")!

    func testSQLQueryHashingNonEquals() {
        let exampleQuery1 = """
            SELECT
              "payload" as "xAxisValue", COUNT(DISTINCT clientUser) AS "yAxisValue"
            FROM "telemetry-signals"
            WHERE appID = 'F679A7F0-22C2-437A-8453-2C0651575EB1'
            AND __time BETWEEN '2022-01-01T04:00:00Z' AND '2022-02-01T03:59:59Z'
            AND isTestMode != 'true'
            AND type = 'applicationDidFinishLaunching'
            AND CONTAINS_STRING(payload, 'signed-in:')

            GROUP BY 1
            ORDER BY 2 DESC
        """

        let exampleQuery2 = """
            SELECT TIME_FLOOR(__time, 'P1D') AS "xAxisValue", SUM("count") AS "yAxisValue" FROM "telemetry-signals"
            WHERE appID = '36EF0DEE-4166-4848-8D94-CDD8C76D5182'
            AND __time BETWEEN '2021-12-31T00:00:00Z' AND '2022-01-31T23:59:59Z'
            AND isTestMode != 'true'


            GROUP BY 1
        """

        XCTAssertNotEqual(exampleQuery1.hashValue, exampleQuery2.hashValue)
    }

    func testSQLQueryHashingEquals() {
        let exampleQuery = """
            SELECT TIME_FLOOR(__time, 'P1D') AS "xAxisValue", SUM("count") AS "yAxisValue" FROM "telemetry-signals"
            WHERE appID = '36EF0DEE-4166-4848-8D94-CDD8C76D5182'
            AND __time BETWEEN '2021-12-31T00:00:00Z' AND '2022-01-31T23:59:59Z'
            AND isTestMode != 'true'


            GROUP BY 1
        """

        let hashValue1 = exampleQuery.hashValue
        let hashValue2 = exampleQuery.hashValue

        XCTAssertEqual(hashValue1, hashValue2)
    }

    func testDruidQueryHashingNonEquals1() {
        let exampleTopNQuery1 = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: .default(.init(dimension: "appVersion", outputName: "appVersion"))
        )

        let exampleTopNQuery2 = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: .default(.init(dimension: "buildNumber", outputName: "buildNumber"))
        )

        XCTAssertNotEqual(exampleTopNQuery1.hashValue, exampleTopNQuery2.hashValue)
    }

    func testDruidQueryHashingNonEquals2() {
        let exampleTopNQuery1 = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: .default(.init(dimension: "appVersion", outputName: "appVersion"))
        )

        let regexQuery = CustomQuery(
            queryType: .groupBy,
            dataSource: "telemetry-signals",
            descending: false,
            filter: nil,
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: nil,
            limit: nil,
            context: nil,
            dimensions: [
                .default(.init(
                    dimension: "appID",
                    outputName: "appID",
                    outputType: .string
                )),

                .extraction(.init(
                    dimension: "payload",
                    outputName: "payload",
                    outputType: .string,
                    extractionFn: .regex(.init(
                        expr: "(.*:).*",
                        replaceMissingValue: true,
                        replaceMissingValueWith: "foobar"
                    ))
                )),
            ]
        )

        XCTAssertNotEqual(exampleTopNQuery1.hashValue, regexQuery.hashValue)
    }

    func testDruidQueryHashingEquals() {
        let exampleTopNQuery = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: .default(.init(dimension: "appVersion", outputName: "appVersion"))
        )

        let hashValue1 = exampleTopNQuery.hashValue
        let hashValue2 = exampleTopNQuery.hashValue

        XCTAssertEqual(hashValue1, hashValue2)
    }

    func testDefaultDimensionSpecHashingNotEquals() {
        let defaultDimension1 = DefaultDimensionSpec(dimension: "test", outputName: "output", outputType: .string)
        let defaultDimension2 = DefaultDimensionSpec(dimension: "anotherTest", outputName: "output", outputType: .string)

        XCTAssertNotEqual(defaultDimension1.hashValue, defaultDimension2.hashValue)

        let dimensionSpec1 = DimensionSpec.default(defaultDimension1)
        let dimensionSpec2 = DimensionSpec.default(defaultDimension2)

        XCTAssertNotEqual(dimensionSpec1.hashValue, dimensionSpec2.hashValue)

        let exampleTopNQuery1 = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: dimensionSpec1
        )

        let exampleTopNQuery2 = CustomQuery(
            queryType: .topN,
            dataSource: "telemetry-signals",
            intervals: [.init(beginningDate: Self.beginDate, endDate: Self.endDate)],
            granularity: .all,
            aggregations: [.count(.init(name: "count"))],
            threshold: 10,
            metric: .dimension(.init(ordering: .version)),
            dimension: dimensionSpec2
        )

        XCTAssertNotEqual(exampleTopNQuery1.hashValue, exampleTopNQuery2.hashValue)
    }

    func testHashingForDifferentAppIDs() throws {
        let query1 = CustomQuery(
            queryType: .timeseries,
            dataSource: "telemetry-signals",
            filter: .selector(.init(dimension: "appID", value: "abcdef")),
            intervals: [],
            granularity: .day,
            aggregations: [
                .count(.init(name: "signals")),
                .thetaSketch(.init(type: .thetaSketch, name: "users", fieldName: "clientUser")),
            ]
        )

        let query2 = CustomQuery(
            queryType: .timeseries,
            dataSource: "telemetry-signals",
            filter: .selector(.init(dimension: "appID", value: "123123123")),
            intervals: [],
            granularity: .day,
            aggregations: [
                .count(.init(name: "signals")),
                .thetaSketch(.init(type: .thetaSketch, name: "users", fieldName: "clientUser")),
            ]
        )

        XCTAssertNotEqual(query1.hashValue, query2.hashValue)
    }
}
