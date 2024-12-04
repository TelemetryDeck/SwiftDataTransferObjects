@testable import DataTransferObjects
import XCTest

final class DataSchemaTests: XCTestCase {
    let docsValueString = """
    {
      "dataSource": "wikipedia",
      "dimensionsSpec": {
        "dimensions": [
            { "name": "page", "type": "long" },
            { "name": "userId", "type": "long" }
        ]
      },
      "granularitySpec": {
        "intervals": [
          "2013-08-31/2013-09-01"
        ],
        "queryGranularity": "none",
        "segmentGranularity": "day"
      },
      "metricsSpec": [
        { "name": "count", "type": "count" },
        { "fieldName": "bytes_added", "name": "bytes_added_sum", "type": "doubleSum" },
        { "fieldName": "bytes_deleted", "name": "bytes_deleted_sum", "type": "doubleSum" }
      ],
      "timestampSpec": {
        "column": "timestamp",
        "format": "auto"
      }
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = DataSchema(
        dataSource: "wikipedia",
        timestampSpec: .init(column: "timestamp", format: .auto, missingValue: nil),
        metricsSpec: [
            .count(.init(name: "count")),
            .doubleSum(.init(type: .doubleSum, name: "bytes_added_sum", fieldName: "bytes_added")),
            .doubleSum(.init(type: .doubleSum, name: "bytes_deleted_sum", fieldName: "bytes_deleted"))

        ],
        granularitySpec: .init(
            type: .none,
            segmentGranularity: .day,
            queryGranularity: QueryGranularity.none,
            rollup: nil,
            intervals: ["2013-08-31/2013-09-01"]
        ),
        transformSpec: nil,
        dimensionsSpec: .init(
            dimensions: [
                .init(type: .long, name: "page", createBitmapIndex: nil, multiValueHandling: nil),
                .init(type: .long, name: "userId", createBitmapIndex: nil, multiValueHandling: nil)
            ],
            dimensionExclusions: nil,
            spatialDimensions: nil,
            includeAllDimensions: nil,
            useSchemaDiscovery: nil,
            forceSegmentSortByTime: nil
        )
    )

    let tdValueString = """
    {
      "dataSource": "telemetry-signals",
      "dimensionsSpec": {
        "dimensionExclusions": [
          "__time",
          "count",
          "receivedAt"
        ],
        "dimensions": [
          {
            "createBitmapIndex": true,
            "multiValueHandling": "sorted_array",
            "name": "appID",
            "type": "string"
          }
        ],
        "includeAllDimensions": true,
        "useSchemaDiscovery": false
      },
      "granularitySpec": {
        "intervals": [],
        "queryGranularity": "hour",
        "rollup": true,
        "segmentGranularity": "day",
        "type": "uniform"
      },
      "metricsSpec": [
        {
          "name": "count",
          "type": "count"
        }
      ],
      "timestampSpec": {
        "column": "receivedAt",
        "format": "iso"
      },
      "transformSpec": {
        "transforms": []
      }
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = DataSchema(
        dataSource: "telemetry-signals",
        timestampSpec: .init(column: "receivedAt", format: .iso, missingValue: nil),
        metricsSpec: [.count(.init(name: "count"))],
        granularitySpec: .init(
            type: .uniform,
            segmentGranularity: .day,
            queryGranularity: .hour,
            rollup: true,
            intervals: []
        ),
        transformSpec: .init(transforms: [], filter: nil),
        dimensionsSpec: .init(
            dimensions: [.init(type: .string, name: "appID", createBitmapIndex: true, multiValueHandling: .sorted_array)],
            dimensionExclusions: ["__time", "count", "receivedAt"],
            spatialDimensions: nil,
            includeAllDimensions: true,
            useSchemaDiscovery: false,
            forceSegmentSortByTime: nil
        )
    )

    let testedType = DataSchema.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: docsValueString.data(using: .utf8)!)
        XCTAssertEqual(docsValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(docsValue)
        XCTAssertEqual(docsValueString, String(data: encodedValue, encoding: .utf8)!)
    }

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
