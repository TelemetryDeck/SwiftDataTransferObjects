@testable import DataTransferObjects
import XCTest

final class IndexParallelTaskSpecTests: XCTestCase {
    let tdValueString = """
    {
      "type": "index_parallel",
      "spec": {
        "ioConfig": {
          "type": "index_parallel",
          "appendToExisting": false,
          "inputSource": {
            "type": "druid",
            "dataSource": "telemetry-signals",
            "interval": "2025-01-01/3000"
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
          "maxNumConcurrentSubTasks": 15,
          "forceGuaranteedRollup": true
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
            "filter": {
              "type": "or",
              "fields": [
                {"type": "selector","dimension": "appID","value": "73B9CA2A-30E6-46C9-B6B8-9034E68AAD21"},
                {"type": "selector","dimension": "appID","value": "25D36DE5-FF0E-4456-9BA9-47B66BBB6BD6"}
              ]
            }
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
                ioConfig: .indexParrallel(
                    .init(
                        inputFormat: <#T##InputFormat#>,
                        appendToExisting: false,
                        dropExisting: <#T##Bool?#>
                    )
                ),
                tuningConfig: <#T##TuningConfig?#>,
                dataSchema: <#T##DataSchema?#>
            )
        )
    )

    let testedType = TaskSpec.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)




    }
}
