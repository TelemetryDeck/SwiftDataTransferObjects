@testable import DataTransferObjects
import XCTest

final class AggregatorTests: XCTestCase {
    let exampleDruidAggregatorsThetaSketch = """
    [
        {
          "fieldName": "clientUser",
          "name": "count",
          "type": "thetaSketch"
        }
      ]
    """
    .filter { !$0.isWhitespace }
    .data(using: .utf8)!

    let exampleDruidAggregatorsCountSum = """
    [
        {
          "fieldName": "count",
          "name": "count",
          "type": "longSum"
        }
      ]
    """
    .filter { !$0.isWhitespace }
    .data(using: .utf8)!

    let exampleDruidAggregatorsFiltered = """
    [
        {
          "type": "filtered",
          "name": "_namedFilteredAggregator",
          "filter": {
            "type": "selector",
            "dimension": "type",
            "value": "newSessionBegan"
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "newSessionBegan",
            "fieldName": "clientUser"
          }
        },
        {
          "type": "filtered",
          "filter": {
            "type": "and",
            "fields": [
              {
                "type": "selector",
                "dimension": "type",
                "value": "InsightShown"
              }
            ]
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "InsightShown",
            "fieldName": "clientUser"
          }
        }
      ]
    """
    .filter { !$0.isWhitespace }
    .data(using: .utf8)!

    func testThetaSketchAggregatorDecoding() throws {
        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: exampleDruidAggregatorsThetaSketch)

        XCTAssertEqual(decodedAggregators, [Aggregator.thetaSketch(.init(name: "count", fieldName: "clientUser"))])
    }

    func testQuantilesDoublesSketchAggregator() throws {
        let stringRepresentation = """
        [
            {
              "fieldName": "clientUser",
              "k": 1024,
              "name": "count",
              "type": "quantilesDoublesSketch"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        let swiftRepresentation = [Aggregator.quantilesDoublesSketch(.init(name: "count", fieldName: "clientUser", k: 1024))]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: stringRepresentation.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, swiftRepresentation)

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(swiftRepresentation)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, stringRepresentation)
    }

    func testLongSumAggregatorDecoding() throws {
        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: exampleDruidAggregatorsCountSum)

        XCTAssertEqual(decodedAggregators, [Aggregator.longSum(.init(type: .longSum, name: "count", fieldName: "count"))])
    }

    func testCardinalityAggregator() throws {
        let exampleAggregatorsString = """
        [
          {
            "byRow": false,
            "fields": ["clientUser"],
            "name": "a0",
            "round": true,
            "type": "cardinality"
          }
        ]
        """
        .filter { !$0.isWhitespace }

        let exampleAggregators = [Aggregator.cardinality(.init(name: "a0", fields: ["clientUser"], round: true))]

        XCTAssertEqual(try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: exampleAggregatorsString.data(using: .utf8)!), exampleAggregators)

        XCTAssertEqual(try String(data: JSONEncoder.telemetryEncoder.encode(exampleAggregators), encoding: .utf8)!, exampleAggregatorsString)
    }

    func testFilteredAggregatorDecoding() throws {
        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: exampleDruidAggregatorsFiltered)

        XCTAssertEqual(decodedAggregators, [
            .filtered(
                .init(
                    filter: .selector(
                        .init(
                            dimension: "type",
                            value: "newSessionBegan"
                        )
                    ),
                    aggregator: .thetaSketch(
                        .init(
                            name: "newSessionBegan",
                            fieldName: "clientUser"
                        )
                    ),
                    name: "_namedFilteredAggregator"
                )
            ),
            .filtered(
                .init(
                    filter: .and(
                        .init(
                            fields: [
                                .selector(
                                    .init(
                                        dimension: "type",
                                        value: "InsightShown"
                                    )
                                ),
                            ]
                        )
                    ),
                    aggregator: .thetaSketch(
                        .init(
                            name: "InsightShown",
                            fieldName: "clientUser"
                        )
                    )
                )
            ),
        ])
    }

    func testFilteredAggregatorEncoding() throws {
        let aggregators: [Aggregator] = [
            .filtered(
                .init(
                    filter: .selector(
                        .init(
                            dimension: "type",
                            value: "newSessionBegan"
                        )
                    ),
                    aggregator: .thetaSketch(
                        .init(
                            name: "newSessionBegan",
                            fieldName: "clientUser"
                        )
                    ),
                    name: "_namedFilteredAggregator"
                )
            ),
            .filtered(
                .init(
                    filter: .and(
                        .init(
                            fields: [
                                .selector(
                                    .init(
                                        dimension: "type",
                                        value: "InsightShown"
                                    )
                                ),
                            ]
                        )
                    ),
                    aggregator: .thetaSketch(
                        .init(
                            name: "InsightShown",
                            fieldName: "clientUser"
                        )
                    )
                )
            ),
        ]

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(aggregators)

        let expectedEncodedAggregators = """
        [
            {
              "aggregator": {
                "fieldName": "clientUser",
                "name": "newSessionBegan",
                "type": "thetaSketch"
              },
              "filter": {
                "dimension": "type",
                "type": "selector",
                "value": "newSessionBegan"
              },
              "name": "_namedFilteredAggregator",
              "type": "filtered"
            },
            {
              "aggregator": {
                "fieldName": "clientUser",
                "name": "InsightShown",
                "type": "thetaSketch"
              },
              "filter": {
                "fields": [
                  {
                    "dimension": "type",
                    "type": "selector",
                    "value": "InsightShown"
                  }
                ],
                "type": "and"
              },
              "type": "filtered"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, expectedEncodedAggregators)
    }


    func testUserCountAggregator() throws {
        let stringRepresentation = """
        [
            {
              "type": "userCount"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        let swiftRepresentation = [Aggregator.userCount(.init())]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: stringRepresentation.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, swiftRepresentation)

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(swiftRepresentation)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, stringRepresentation)
    }

    func testEventCountAggregator() throws {
        let stringRepresentation = """
        [
            {
              "type": "eventCount"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        let swiftRepresentation = [Aggregator.eventCount(.init())]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: stringRepresentation.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, swiftRepresentation)

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(swiftRepresentation)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, stringRepresentation)
    }

    func testHistogramAggregatorWithDefaults() throws {
        let stringRepresentation = """
        [
            {
              "type": "histogram"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        let swiftRepresentation = [Aggregator.histogram(.init())]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: stringRepresentation.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, swiftRepresentation)

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(swiftRepresentation)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, stringRepresentation)
    }

    func testHistogramAggregatorWithParameters() throws {
        let stringRepresentation = """
        [
            {
              "fieldName": "anotherNumericalField",
              "k": 512,
              "name": "MyVeryCoolHistogram",
              "numBins": 25,
              "type": "histogram"
            }
          ]
        """
        .filter { !$0.isWhitespace }

        let swiftRepresentation = [Aggregator.histogram(.init(name: "MyVeryCoolHistogram", fieldName: "anotherNumericalField", splitPoints: nil, numBins: 25, k: 512))]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: stringRepresentation.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, swiftRepresentation)

        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(swiftRepresentation)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8)!, stringRepresentation)
    }
}
