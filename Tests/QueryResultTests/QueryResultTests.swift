//
//  QueryResultTests.swift
//
//
//  Created by Daniel Jilg on 22.12.21.
//

import DataTransferObjects
import XCTest

class QueryResultTests: XCTestCase {
    let randomDate = Date(timeIntervalSinceReferenceDate: 656510400) // Thursday, October 21, 2021 2:00:00 PM GMT+02:00

    func testEncodingTimeSeries() throws {
        let exampleQueryResult = QueryResult.timeSeries(
            TimeSeriesQueryResult(rows:
                [
                    TimeSeriesQueryResultRow(timestamp: randomDate - 3600, result: ["test": DoubleWrapper(11)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(12)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(Double.infinity)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(-Double.infinity)]),
                ]
            )
        )

        let encodedQueryResult = try JSONEncoder.telemetryEncoder.encode(exampleQueryResult)

        let expectedResult = """
        {
            "rows": [
                {"result":{"test":11},"timestamp":"2021-10-21T11:00:00+0000"},
                {"result":{"test":12},"timestamp":"2021-10-21T12:00:00+0000"},
                {"result":{"test":"Infinity"},"timestamp":"2021-10-21T12:00:00+0000"},
                {"result":{"test":"-Infinity"},"timestamp":"2021-10-21T12:00:00+0000"}
            ],
            "type":"timeSeriesResult"
        }
        """
        .filter { !$0.isWhitespace }

        XCTAssertEqual(String(data: encodedQueryResult, encoding: .utf8)!, expectedResult)
    }

    func testEncodingMultiDimTimeSeries() throws {
        let swiftResult = QueryResult.timeSeries(
            TimeSeriesQueryResult(rows:
                [
                    TimeSeriesQueryResultRow(timestamp: randomDate - 3600, result: ["test": DoubleWrapper([11, 12, 13])]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(12)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper([Double.infinity, 31, 32])]),
                ]
            )
        )


        let stringResult = """
        {
            "rows": [
                {"result":{"test":[11, 12, 13]},"timestamp":"2021-10-21T11:00:00+0000"},
                {"result":{"test":12},"timestamp":"2021-10-21T12:00:00+0000"},
                {"result":{"test":["Infinity", 31, 32]},"timestamp":"2021-10-21T12:00:00+0000"}
            ],
            "type":"timeSeriesResult"
        }
        """
        .filter { !$0.isWhitespace }

        let encodedQueryResult = try JSONEncoder.telemetryEncoder.encode(swiftResult)
        let decodedQueryResult = try JSONDecoder.telemetryDecoder.decode(QueryResult.self, from: stringResult.data(using: .utf8)!)

        XCTAssertEqual(stringResult, String(data: encodedQueryResult, encoding: .utf8)!)
        XCTAssertEqual(swiftResult, decodedQueryResult)
    }

    func testEncodingGroupBy() throws {
        let exampleQueryResult = QueryResult.groupBy(.init(rows: [GroupByQueryResultRow(timestamp: randomDate, event: .init(metrics: [:], dimensions: ["abc": "def", "uno": "due"]))]))
        let encodedQueryResult = try JSONEncoder.telemetryEncoder.encode(exampleQueryResult)
        let expectedResult = """
        {
          "rows": [{
            "event": {"abc":"def","uno":"due"},
            "timestamp": "2021-10-21T12:00:00+0000",
            "version": "v1"
          }],
          "type":"groupByResult"
        }
        """
        .filter { !$0.isWhitespace }

        XCTAssertEqual(String(data: encodedQueryResult, encoding: .utf8)!, expectedResult)
    }

    func testDecodingGroupBy() throws {
        let expectedResult = QueryResult.groupBy(GroupByQueryResult(
            rows: [GroupByQueryResultRow(
                timestamp: randomDate,
                event: .init(metrics: ["count": 12], dimensions: ["abc": "def", "uno": "due"])
            )]))
        let groupByResult = """
        {
        "rows": [
          {
            "event": {"abc":"def","uno":"due", "count": 12},
            "timestamp": "2021-10-21T12:00:00+0000",
            "version": "v1"
          }
        ],
        "type":"groupByResult"
        }
        """

        let decodedResult = try JSONDecoder.telemetryDecoder.decode(QueryResult.self, from: groupByResult.data(using: .utf8)!)
        XCTAssertEqual(expectedResult, decodedResult)
    }

    func testDecodingTimeSeriesResult() throws {
        let exampleResult = """
        {"timestamp":"2021-01-01T00:00:00.000Z","result":{"d0":1609459200000}}
        """
        .filter { !$0.isWhitespace }

        let decodedResult = try JSONDecoder.telemetryDecoder.decode(TimeSeriesQueryResultRow.self, from: exampleResult.data(using: .utf8)!)

        XCTAssertEqual(decodedResult.result, ["d0": DoubleWrapper(1609459200000)])
    }

    func testDecodingEmptyTimeSeriesResult() throws {
        let exampleResult = """
        { "timestamp": "2023-09-01T00:00:00.000Z", "result": { "count": null } }
        """
        .filter { !$0.isWhitespace }

        let decodedResult = try JSONDecoder.telemetryDecoder.decode(TimeSeriesQueryResultRow.self, from: exampleResult.data(using: .utf8)!)

        XCTAssertEqual(decodedResult.result, ["count": nil])
    }

    func testDecodingInfinity() throws {
        let exampleResult = """
            [
              {"timestamp":"2022-12-19T00:00:00.000Z","result":{"min":"Infinity","max":"-Infinity","mean":0.0}},
              {"timestamp":"2022-12-20T00:00:00.000Z","result":{"min":0.02,"max":5775.11,"mean":938.24}},
            ]
        """
        .filter { !$0.isWhitespace }

        let decodedResult = try JSONDecoder.telemetryDecoder.decode([TimeSeriesQueryResultRow].self, from: exampleResult.data(using: .utf8)!)

        XCTAssertEqual(decodedResult.first?.result, [
            "mean": DoubleWrapper(0.0),
            "max": DoubleWrapper(-Double.infinity),
            "min": DoubleWrapper(Double.infinity),
        ])

        XCTAssertEqual(decodedResult.last?.result, [
            "mean": DoubleWrapper(938.24),
            "max": DoubleWrapper(5775.11),
            "min": DoubleWrapper(0.02),
        ])
    }

    func testEncodingTimeSeriesWithRestricted() throws {
        let exampleQueryResult = QueryResult.timeSeries(
            TimeSeriesQueryResult(rows:
                [
                    TimeSeriesQueryResultRow(timestamp: randomDate - 3600, result: ["test": DoubleWrapper(11)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(12)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(Double.infinity)]),
                    TimeSeriesQueryResultRow(timestamp: randomDate, result: ["test": DoubleWrapper(-Double.infinity)]),
                ],
                restrictions: [.init(beginningDate: randomDate - 3600 * 24 * 10, endDate: randomDate)])
        )

        let encodedQueryResult = try JSONEncoder.telemetryEncoder.encode(exampleQueryResult)

        let expectedResult = """
        {
            "restrictions":["2021-10-11T12:00:00.000Z/2021-10-21T12:00:00.000Z"],
            "rows": [
                {"result":{"test":11},"timestamp":"2021-10-21T11:00:00+0000"},
                {"result":{"test":12},"timestamp":"2021-10-21T12:00:00+0000"},
                {"result":{"test":"Infinity"},"timestamp":"2021-10-21T12:00:00+0000"},
                {"result":{"test":"-Infinity"},"timestamp":"2021-10-21T12:00:00+0000"}
            ],
            "type":"timeSeriesResult"
        }
        """
        .filter { !$0.isWhitespace }

        XCTAssertEqual(String(data: encodedQueryResult, encoding: .utf8)!, expectedResult)
    }

    func testDecodingScan() throws {
        let exampleResult = """
        [
            {
                "segmentId": "telemetry-signals_2024-08-30T00:00:00.000Z_2024-08-31T00:00:00.000Z_2024-08-30T00:00:00.590Z_50",
                "columns": [
                    "__time",
                    "type"
                ],
                "events": [
                    {
                        "__time": 1725004800000,
                        "type": "RevenueCat.Events.CANCELLATION"
                    }
                ],
                "rowSignature": [
                    {
                        "name": "__time",
                        "type": "LONG"
                    },
                    {
                        "name": "type",
                        "type": "STRING"
                    }
                ]
            }
        ]
        """

        let decodedResult = try JSONDecoder.telemetryDecoder.decode([ScanQueryResultRow].self, from: exampleResult.data(using: .utf8)!)

        XCTAssertEqual(
            decodedResult,
            [.init(
                segmentId: "telemetry-signals_2024-08-30T00:00:00.000Z_2024-08-31T00:00:00.000Z_2024-08-30T00:00:00.590Z_50",
                columns: ["__time", "type"],
                events: [.init(metrics: ["__time": 1725004800000], dimensions: ["type": "RevenueCat.Events.CANCELLATION"])],
                rowSignature: [.init(name: "__time", type: "LONG"), .init(name: "type", type: "STRING")]
            )]
        )
    }

    func testDecodingTimeBoundaryResult() throws {
        let exampleResult = """
        [ {
          "timestamp" : "2013-05-09T18:24:00.000Z",
          "result" : {
            "minTime" : "2013-05-09T18:24:00.000Z",
            "maxTime" : "2013-05-09T18:37:00.000Z"
          }
        } ]
        """

        let decodedResult = try JSONDecoder.telemetryDecoder.decode([TimeBoundaryResultRow].self, from: exampleResult.data(using: .utf8)!)
        XCTAssertEqual(
            decodedResult,
            [.init(
                timestamp: .init(iso8601String: "2013-05-09T18:24:00.000Z")!,
                result: [
                    "minTime": .init(iso8601String: "2013-05-09T18:24:00.000Z")!,
                    "maxTime": .init(iso8601String: "2013-05-09T18:37:00.000Z")!,
                ]
            )]
        )
    }

    func testEncodingTimeBoundaryResult() throws {
        let expectedResult = """
        [ {
          "result" : {
            "maxTime" : "2013-05-09T18:37:00+0000",
            "minTime" : "2013-05-09T18:24:00+0000"
          },
          "timestamp" : "2013-05-09T18:24:00+0000"
        } ]
        """

        let exampleResult: [TimeBoundaryResultRow] = [.init(
            timestamp: .init(iso8601String: "2013-05-09T18:24:00.000Z")!,
            result: [
                "minTime": .init(iso8601String: "2013-05-09T18:24:00.000Z")!,
                "maxTime": .init(iso8601String: "2013-05-09T18:37:00.000Z")!,
            ]
        )]

        let encodedResult = try JSONEncoder.telemetryEncoder.encode(exampleResult)

        XCTAssertEqual(
            expectedResult.filter { !$0.isWhitespace },
            String(data: encodedResult, encoding: .utf8)!
        )
    }
}
