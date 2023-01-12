import DataTransferObjects
import XCTest

final class FunnelQueryGenerationTests: XCTestCase {
    
    
    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .and(.init(fields: [
            .selector(.init(dimension: "appID", value: "79167A27-EBBF-4012-9974-160624E5D07B")),
            .selector(.init(dimension: "isTestMode", value: "false")),
            .or(.init(fields: [
                .selector(.init(dimension: "type", value: "appLaunchedByNotification")),
                .selector(.init(dimension: "type", value: "dataEntered"))
            ]))
        ])),
        granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "appLaunchedByNotification")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "appLaunchedByNotification_count",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "dataEntered")),
                aggregator: .thetaSketch(
                    .init(
                        type: .thetaSketch,
                        name: "dataEntered_count",
                        fieldName: "clientUser"
                    )
                )
            ))
        ],
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "app_launched_and_data_entered_count",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "appLaunchedByNotification_count"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "dataEntered_count"
                        ))
                    ]
                ))
            )
            )
        ]
    )

    func testExample() throws {
        let generatedTinyQuery = try FunnelQueryGenerator.generateFunnelQuery(
            steps: [],
            filter: nil,
            appID: "79167A27-EBBF-4012-9974-160624E5D07B",
            testMode: false
        )
        
        XCTAssertEqual(tinyQuery, generatedTinyQuery)
        
        XCTAssertEqual(String(data: try! JSONEncoder.telemetryEncoder.encode(tinyQuery), encoding: .utf8), String(data: try! JSONEncoder.telemetryEncoder.encode(generatedTinyQuery), encoding: .utf8))
    }
}
