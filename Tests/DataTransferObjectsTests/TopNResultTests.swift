//
//  TopNResultTests.swift
//
//
//  Created by Daniel Jilg on 03.01.22.
//

import DataTransferObjects
import XCTest

class TopNResultTests: XCTestCase {
    static let firstMonthDate: Date = Formatter.iso8601.date(from: "2021-12-01T00:00:00.000Z")!
    static let secondMonthDate: Date = Formatter.iso8601.date(from: "2022-01-01T00:00:00.000Z")!

    let emptyResult = """
    [
      {
        "result": [],
        "timestamp": "2021-12-01T00:00:00+0000"
      },
      {
        "result": [],
        "timestamp": "2022-01-01T00:00:00+0000"
      }
    ]
    """
    .filter { !$0.isWhitespace }

    let decodedEmptyExampleResult = [
        TopNQueryResultRow(timestamp: firstMonthDate, result: []),
        TopNQueryResultRow(timestamp: secondMonthDate, result: []),
    ]

    let exampleResult = """
    [
      {
        "result": [
          {
            "appVersion": "276",
            "count": 1
          },
          {
            "appVersion": "324",
            "count": 1
          },
          {
            "appVersion": "408",
            "count": 35
          }
        ],
        "timestamp": "2021-12-01T00:00:00+0000"
      },
      {
        "result": [
          {
            "appVersion": null,
            "count": 2
          },
          {
            "appVersion": "411",
            "count": 6
          },
          {
            "appVersion": "448",
            "count": 9
          }
        ],
        "timestamp": "2022-01-01T00:00:00+0000"
      }
    ]
    """
    .filter { !$0.isWhitespace }

    let decodedExampleResult = [
        TopNQueryResultRow(timestamp: firstMonthDate, result: [
            .init(metrics: ["count": 1], dimensions: ["appVersion": "276"]),
            .init(metrics: ["count": 1], dimensions: ["appVersion": "324"]),
            .init(metrics: ["count": 35], dimensions: ["appVersion": "408"]),
        ]),
        TopNQueryResultRow(timestamp: secondMonthDate, result: [
            .init(metrics: ["count": 2], dimensions: [:], nullValues: ["appVersion"]),
            .init(metrics: ["count": 6], dimensions: ["appVersion": "411"]),
            .init(metrics: ["count": 9], dimensions: ["appVersion": "448"]),
        ]),
    ]

    let resultRowItemNull = """
      {
        "appVersion": null,
        "count": 2
      }
    """
    .filter { !$0.isWhitespace }

    let resultRowItemNullExample = AdaptableQueryResultItem(metrics: ["count": 2], dimensions: [:], nullValues: ["appVersion"])

    let resultRowItemOneEntry = """
      {
        "appVersion": "335",
        "count": 2
      }
    """
    .filter { !$0.isWhitespace }

    let resultRowItemOneItemExample = AdaptableQueryResultItem(metrics: ["count": 2], dimensions: ["appVersion": "335"])

    let resultRowItemManyEntries = """
      {
          "average": 1.25,
          "count": 88,
          "dim1": "another_dim1_val",
          "some_metrics": 28344
       }
    """
    .filter { !$0.isWhitespace }

    let resultRowItemManyEntriesExample = AdaptableQueryResultItem(metrics: ["count": 88, "some_metrics": 28344, "average": 1.25], dimensions: ["dim1": "another_dim1_val"])

    func testDecodingEmptyResult() throws {
        let decodedRows = try JSONDecoder.telemetryDecoder.decode([TopNQueryResultRow].self, from: emptyResult.data(using: .utf8)!)
        XCTAssertEqual(decodedRows, decodedEmptyExampleResult)
    }

    func testEncodingEmptyResult() throws {
        let encoded = try JSONEncoder.telemetryEncoder.encode(decodedEmptyExampleResult)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, emptyResult)
    }

    func testDecoding() throws {
        let decodedRows = try JSONDecoder.telemetryDecoder.decode([TopNQueryResultRow].self, from: exampleResult.data(using: .utf8)!)
        XCTAssertEqual(decodedRows, decodedExampleResult)
    }

    func testEncoding() throws {
        let encoded = try JSONEncoder.telemetryEncoder.encode(decodedExampleResult)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, exampleResult)
    }

    func testDecodingTopNQueryResultRowItemNullEntry() throws {
        let decoded = try JSONDecoder.telemetryDecoder.decode(AdaptableQueryResultItem.self, from: resultRowItemNull.data(using: .utf8)!)
        XCTAssertEqual(decoded, resultRowItemNullExample)
    }

    func testDecodingTopNQueryResultRowItemOneEntry() throws {
        let decoded = try JSONDecoder.telemetryDecoder.decode(AdaptableQueryResultItem.self, from: resultRowItemOneEntry.data(using: .utf8)!)
        XCTAssertEqual(decoded, resultRowItemOneItemExample)
    }

    func testDecodingTopNQueryResultRowItemManyEntries() throws {
        let decoded = try JSONDecoder.telemetryDecoder.decode(AdaptableQueryResultItem.self, from: resultRowItemManyEntries.data(using: .utf8)!)
        XCTAssertEqual(decoded, resultRowItemManyEntriesExample)
    }

    func testEncodingTopNQueryResultRowItemNullEntry() throws {
        let encoded = try JSONEncoder.telemetryEncoder.encode(resultRowItemNullExample)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, resultRowItemNull)
    }

    func testEncodingTopNQueryResultRowItemOneEntry() throws {
        let encoded = try JSONEncoder.telemetryEncoder.encode(resultRowItemOneItemExample)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, resultRowItemOneEntry)
    }

    func testEncodingTopNQueryResultRowItemManyEntries() throws {
        let encoded = try JSONEncoder.telemetryEncoder.encode(resultRowItemManyEntriesExample)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, resultRowItemManyEntries)
    }
}
