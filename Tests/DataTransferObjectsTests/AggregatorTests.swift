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

        XCTAssertEqual(decodedAggregators, [Aggregator.thetaSketch(.init(type: .thetaSketch, name: "count", fieldName: "clientUser"))])
    }

    func testLongSumAggregatorDecoding() throws {
        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([Aggregator].self, from: exampleDruidAggregatorsCountSum)

        XCTAssertEqual(decodedAggregators, [Aggregator.longSum(.init(type: .longSum, name: "count", fieldName: "count"))])
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
                            type: .thetaSketch,
                            name: "newSessionBegan",
                            fieldName: "clientUser"
                        )
                    )
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
                                )
                            ]
                        )
                    ),
                    aggregator: .thetaSketch(
                        .init(
                            type: .thetaSketch,
                            name: "InsightShown",
                            fieldName: "clientUser"
                        )
                    )
                )
            )
        ])
    }
}
