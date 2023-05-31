//
//  DruidQueryResultTests.swift
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
}


