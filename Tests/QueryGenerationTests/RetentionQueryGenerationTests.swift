//
//  RetentionQueryGenerationTests.swift
//
//
//  Created by Daniel Jilg on 28.11.22.
//

// swiftlint:disable force_try

import DataTransferObjects
import XCTest

final class RetentionQueryGenerationTests: XCTestCase {
    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .and(.init(fields: [
            .selector(.init(dimension: "appID", value: "79167A27-EBBF-4012-9974-160624E5D07B")),
            .selector(.init(dimension: "isTestMode", value: "false"))
        ])),
        intervals: [
            QueryTimeInterval(
                beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                endDate: Date(iso8601String: "2022-09-30T00:00:00.000Z")!
            )
        ], granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .interval(.init(
                    dimension: "__time",
                    intervals: [
                        .init(
                            beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                            endDate: Date(iso8601String: "2022-08-31T23:59:59.000Z")!
                        )
                    ]
                )),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .interval(.init(
                    dimension: "__time",
                    intervals: [
                        .init(
                            beginningDate: Date(iso8601String: "2022-09-01T00:00:00.000Z")!,
                            endDate: Date(iso8601String: "2022-09-30T23:59:59.000Z")!
                        )
                    ]
                )),
                aggregator: .thetaSketch(
                    .init(
                        type: .thetaSketch,
                        name: "_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z",
                        fieldName: "clientUser"
                    )
                )
            ))
        ],
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "retention_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z"
                        ))
                    ]
                ))
            )
            ),
            .thetaSketchEstimate(.init(
                name: "retention_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-08-01T00:00:00.000Z_2022-08-31T23:59:59.000Z"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z"
                        ))
                    ]
                ))
            )
            ),
            .thetaSketchEstimate(.init(
                name: "retention_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z"
                        ))
                    ]
                ))
            )
            ),
        ]
    )

    func testThrowsWhenDatesTooClose() {
        let begin_august = Date(iso8601String: "2022-08-01T00:00:00.000Z")!
        let mid_august = Date(iso8601String: "2022-08-15T00:00:00.000Z")!
        let end_august = Date(iso8601String: "2022-08-31T23:59:59.999Z")!
        let end_september = Date(iso8601String: "2022-09-30T23:59:59.999Z")!

        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(appID: "", testMode: false, beginDate: begin_august, endDate: mid_august))
        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(appID: "", testMode: false, beginDate: begin_august, endDate: end_august))
        XCTAssertNoThrow(try RetentionQueryGenerator.generateRetentionQuery(appID: "", testMode: false, beginDate: begin_august, endDate: end_september))
        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(appID: "", testMode: false, beginDate: end_september, endDate: begin_august))
    }

    func testExample() throws {
        let generatedTinyQuery = try RetentionQueryGenerator.generateRetentionQuery(
            appID: "79167A27-EBBF-4012-9974-160624E5D07B",
            testMode: false,
            beginDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
            endDate: Date(iso8601String: "2022-09-30T00:00:00.000Z")!
        )

        XCTAssertEqual(tinyQuery, generatedTinyQuery)

        XCTAssertEqual(String(data: try! JSONEncoder.telemetryEncoder.encode(tinyQuery), encoding: .utf8), String(data: try! JSONEncoder.telemetryEncoder.encode(generatedTinyQuery), encoding: .utf8))

//        let aggregationNames = generatedTinyQuery.aggregations!.map { agg in
//            switch agg {
//            case .filtered(let filteredAgg):
//                switch filteredAgg.aggregator {
//                case .thetaSketch(let genAgg):
//                    return genAgg.name
//                default:
//                    fatalError()
//                }
//            default:
//                fatalError()
//            }
//        }
//        
//        let postAggregationNames = generatedTinyQuery.postAggregations!.map { postAgg in
//            switch postAgg {
//            case .thetaSketchEstimate(let thetaEstimateAgg):
//                return thetaEstimateAgg.name ?? "Name not defined"
//            default:
//                fatalError()
//            }
//        }
//
//        print("Aggregations: ")
//        for aggregationName in aggregationNames {
//            print(aggregationName)
//        }
//
//        print("Post-Aggregations: ")
//        for aggregationName in postAggregationNames {
//            print(aggregationName)
//        }
//
//        print(String(data: try! JSONEncoder.telemetryEncoder.encode(generatedTinyQuery), encoding: .utf8)!)
    }
}
