@testable import DataTransferObjects
import XCTest

final class IndexParallelTaskSpecTests: XCTestCase {
    let tdValueString = """
    {
      "type": "index_parallel",
      "spec": {
    
        "context": {
          "storeEmptyColumns": false
        },
        "ioConfig": {
          "type": "index_parallel",
          "appendToExisting": false,
          "inputSource": {
            "type": "druid",
            "dataSource": "telemetry-signals",
            "interval": "2025-01-01/3000",
            "filter": {
              "type": "or",
              "fields": [
                {"type": "selector","dimension": "appID","value": "73B9CA2A-30E6-46C9-B6B8-9034E68AAD21"},
                {"type": "selector","dimension": "appID","value": "25D36DE5-FF0E-4456-9BA9-47B66BBB6BD6"}
              ]
            }
          },
          "inputFormat": {
            "type": "json"
          }
        },
        "tuningConfig": {
          "type": "index_parallel",
          "partitionsSpec": {
            "type": "hashed"
          },
          "maxNumConcurrentSubTasks": 5,
          "forceGuaranteedRollup": false
        },
        "dataSchema": {
          "dataSource": "com.goodsnooze",
          "timestampSpec": {
            "column": "__time",
            "format": "millis"
          },
          "granularitySpec": {
            "queryGranularity": "hour",
            "rollup": true,
            "segmentGranularity": "day"
          },
          "transformSpec": {

          },
          "dimensionsSpec": {
            "dimensionExclusions": [
              "count"
            ]
          },
          "metricsSpec": [
            {
              "name": "count",
              "type": "longSum",
              "fieldName": "count"
            }
          ]
        }
      }
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = TaskSpec.indexParallel(
        .init(
            id: nil,
            spec: .init(
                ioConfig:.indexParallel(
                    .init(
                        inputFormat: .init(type: .json),
                        inputSource: .druid(
                            .init(
                                dataSource: "telemetry-signals",
                                interval: .init(
                                    beginningDate: .init(iso8601String: "2025-01-01T00:00:00.000Z")!,
                                    endDate: .init(iso8601String: "3000-01-01T00:00:00.000Z")!
                                ),
                                filter: .or(.init(fields: [
                                    .selector(.init(dimension: "appID", value: "73B9CA2A-30E6-46C9-B6B8-9034E68AAD21")),
                                    .selector(.init(dimension: "appID", value: "25D36DE5-FF0E-4456-9BA9-47B66BBB6BD6"))
                                ]))
                            )
                        ),
                        appendToExisting: false,
                        dropExisting: nil
                    )
                ),
                tuningConfig: .indexParallel(
                    .init(
                        partitionsSpec: .hashed(.init()),
                        forceGuaranteedRollup: false,
                        maxNumConcurrentSubTasks: 5
                    )
                ),
                dataSchema: .init(
                    dataSource: "com.goodsnooze",
                    timestampSpec: .init(
                        column: "__time",
                        format: .millis
                    ),
                    metricsSpec: [
                        .longSum(.init(type: .longSum, name: "count", fieldName: "count"))
                    ],
                    granularitySpec: .init(
                        segmentGranularity: .day,
                        queryGranularity: .hour,
                        rollup: true
                    ),
                    transformSpec: nil,
                    dimensionsSpec: DimensionsSpec(
                        dimensionExclusions: ["count"]
                    )
                )
            )
        )
    )

    let testedType = TaskSpec.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)




    }
}
