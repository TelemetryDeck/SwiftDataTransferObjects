@testable import DataTransferObjects
import XCTest

final class IndexParallelTaskSpecTests: XCTestCase {
    let tdValueString = """
    {
        "spec": {
            "dataSchema": {
                "dataSource": "test.indexParallel",
                "dimensionsSpec": {
                    "dimensionExclusions": [
                        "count"
                    ]
                },
                "granularitySpec": {
                    "queryGranularity": "hour",
                    "rollup": true,
                    "segmentGranularity": "day"
                },
                "metricsSpec": [
                    {
                        "fieldName": "count",
                        "name": "count",
                        "type": "longSum"
                    }
                ],
                "timestampSpec": {
                    "column": "__time",
                    "format": "millis"
                }
            },
            "ioConfig": {
                "appendToExisting": false,
                "inputFormat": {
                    "type": "json"
                },
                "inputSource": {
                    "dataSource": "telemetry-signals",
                    "filter": {
                        "fields": [
                            {
                                "dimension": "appID",
                                "type": "selector",
                                "value": "73B9CA2A-30E6-46C9-B6B8-9034E68AAD21"
                            },
                            {
                                "dimension": "appID",
                                "type": "selector",
                                "value": "25D36DE5-FF0E-4456-9BA9-47B66BBB6BD6"
                            }
                        ],
                        "type": "or"
                    },
                    "interval": "2025-01-01T00:00:00.000Z/2025-01-05T00:00:00.000Z",
                    "type": "druid"
                },
                "type": "index_parallel"
            },
            "tuningConfig": {
                "forceGuaranteedRollup": false,
                "maxNumConcurrentSubTasks": 3,
                "partitionsSpec": {
                    "type": "dynamic"
                },
                "type": "index_parallel"
            }
        },
        "type": "index_parallel"
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = TaskSpec.indexParallel(
        .init(
            id: nil,
            spec: .init(
                ioConfig: .indexParallel(
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
                        partitionsSpec: .dynamic(.init()),
                        forceGuaranteedRollup: false,
                        maxNumConcurrentSubTasks: 3
                    )
                ),
                dataSchema: .init(
                    dataSource: "test.indexParallel",
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
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
