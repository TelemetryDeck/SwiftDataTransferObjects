import DataTransferObjects
import XCTest

final class FunnelQueryGenerationTests: XCTestCase {
    let steps: [Filter] = [
        .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
        .selector(.init(dimension: "type", value: "dataEntered")),
        .selector(.init(dimension: "type", value: "paywallSeen")),
        .selector(.init(dimension: "type", value: "conversion"))
    ]

    let stepNames: [String] = [
        "Regular Launch",
        "Data Entered",
        "Paywall Presented",
        "Conversion"
    ]

    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .and(.init(fields: [
            .selector(.init(dimension: "appID", value: "79167A27-EBBF-4012-9974-160624E5D07B")),
            .selector(.init(dimension: "isTestMode", value: "false")),
            .or(.init(fields: [
                .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
                .selector(.init(dimension: "type", value: "dataEntered")),
                .selector(.init(dimension: "type", value: "paywallSeen")),
                .selector(.init(dimension: "type", value: "conversion"))
            ]))
        ])),
        granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_funnel_step_0",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "dataEntered")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_funnel_step_1",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "paywallSeen")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_funnel_step_2",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "conversion")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_funnel_step_3",
                        fieldName: "clientUser"
                    )
                )
            ))
        ],
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "0_Regular Launch",
                field: .fieldAccess(.init(
                    type: .fieldAccess,
                    fieldName: "_funnel_step_0"
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "1_Data Entered",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_0"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_1"
                        ))
                    ]
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "2_Paywall Presented",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_0"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_1"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_2"
                        ))
                    ]
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "3_Conversion",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_0"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_1"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_2"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_funnel_step_3"
                        ))
                    ]
                ))
            ))
        ]
    )

    func testExample() throws {
        let generatedTinyQuery = try FunnelQueryGenerator.generateFunnelQuery(
            steps: steps,
            stepNames: stepNames,
            filter: nil,
            appID: "79167A27-EBBF-4012-9974-160624E5D07B",
            testMode: false
        )
        
        XCTAssertEqual(tinyQuery.filter, generatedTinyQuery.filter)
        XCTAssertEqual(tinyQuery.aggregations, generatedTinyQuery.aggregations)
        XCTAssertEqual(tinyQuery.postAggregations, generatedTinyQuery.postAggregations)
        
        XCTAssertEqual(tinyQuery, generatedTinyQuery)

        // Apparently sometimes the previous line says the queries are equal even if they are not,
        // let's double check by comparing the encoded JSON strings!
        XCTAssertEqual(String(data: try! JSONEncoder.telemetryEncoder.encode(tinyQuery), encoding: .utf8), String(data: try! JSONEncoder.telemetryEncoder.encode(generatedTinyQuery), encoding: .utf8))
    }
    
    func testWithAdditionalFilters() throws {
        let additionalFilter = Filter.selector(.init(dimension: "something", value: "other"))
        let generatedTinyQuery = try FunnelQueryGenerator.generateFunnelQuery(
            steps: steps,
            stepNames: stepNames,
            filter: additionalFilter,
            appID: "B97579B6-FFB8-4AC5-AAA7-DA5796CC5DCE",
            testMode: false
        )
        
        let expectedFilter = Filter.and(.init(fields: [
            .selector(.init(dimension: "appID", value: "B97579B6-FFB8-4AC5-AAA7-DA5796CC5DCE")),
            .selector(.init(dimension: "isTestMode", value: "false")),
            additionalFilter,
            .or(.init(fields: [
                .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
                .selector(.init(dimension: "type", value: "dataEntered")),
                .selector(.init(dimension: "type", value: "paywallSeen")),
                .selector(.init(dimension: "type", value: "conversion"))
            ]))
        ]))
        
        
        XCTAssertEqual(expectedFilter, generatedTinyQuery.filter)
        XCTAssertEqual(tinyQuery.aggregations, generatedTinyQuery.aggregations)
        XCTAssertEqual(tinyQuery.postAggregations, generatedTinyQuery.postAggregations)
    }
}
