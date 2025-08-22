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
        dataSource: .init("com.telemetrydeck.all"),
        filter: .and(.init(fields: [
            .selector(.init(dimension: "appID", value: "79167A27-EBBF-4012-9974-160624E5D07B")),
            .selector(.init(dimension: "isTestMode", value: "false")),
        ])),
        intervals: [
            QueryTimeInterval(
                beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                endDate: Date(iso8601String: "2022-09-30T00:00:00.000Z")!
            ),
        ], granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .interval(.init(
                    dimension: "__time",
                    intervals: [
                        .init(
                            beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                            endDate: Date(iso8601String: "2022-08-31T23:59:59.000Z")!
                        ),
                    ]
                )),
                aggregator: .thetaSketch(
                    .init(
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
                        ),
                    ]
                )),
                aggregator: .thetaSketch(
                    .init(
                        name: "_2022-09-01T00:00:00.000Z_2022-09-30T23:59:59.000Z",
                        fieldName: "clientUser"
                    )
                )
            )),
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
                        )),
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
                        )),
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
                        )),
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

        // Test with new compile-down approach
        let query1 = CustomQuery(
            queryType: .retention,
            dataSource: "com.telemetrydeck.all",
            intervals: [QueryTimeInterval(beginningDate: begin_august, endDate: mid_august)],
            granularity: .all
        )
        XCTAssertThrowsError(try query1.precompile(namespace: nil, useNamespace: false, organizationAppIDs: [UUID()], isSuperOrg: false))
        
        let query2 = CustomQuery(
            queryType: .retention,
            dataSource: "com.telemetrydeck.all",
            intervals: [QueryTimeInterval(beginningDate: begin_august, endDate: end_august)],
            granularity: .all
        )
        XCTAssertThrowsError(try query2.precompile(namespace: nil, useNamespace: false, organizationAppIDs: [UUID()], isSuperOrg: false))
        
        let query3 = CustomQuery(
            queryType: .retention,
            dataSource: "com.telemetrydeck.all",
            intervals: [QueryTimeInterval(beginningDate: begin_august, endDate: end_september)],
            granularity: .all
        )
        XCTAssertNoThrow(try query3.precompile(namespace: nil, useNamespace: false, organizationAppIDs: [UUID()], isSuperOrg: false))
        
        // Also test legacy method for backwards compatibility if needed
        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(dataSource: "com.telemetrydeck.all", appID: "", testMode: false, beginDate: begin_august, endDate: mid_august))
        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(dataSource: "com.telemetrydeck.all", appID: "", testMode: false, beginDate: begin_august, endDate: end_august))
        XCTAssertNoThrow(try RetentionQueryGenerator.generateRetentionQuery(dataSource: "com.telemetrydeck.all", appID: "", testMode: false, beginDate: begin_august, endDate: end_september))
        XCTAssertThrowsError(try RetentionQueryGenerator.generateRetentionQuery(dataSource: "com.telemetrydeck.all", appID: "", testMode: false, beginDate: end_september, endDate: begin_august))
    }

    func testExample() throws {
        // Test with new compile-down approach
        let appID = UUID(uuidString: "79167A27-EBBF-4012-9974-160624E5D07B")!
        let query = CustomQuery(
            queryType: .retention,
            dataSource: "com.telemetrydeck.all",
            appID: appID,
            baseFilters: .thisApp,
            testMode: false,
            intervals: [QueryTimeInterval(
                beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                endDate: Date(iso8601String: "2022-09-30T00:00:00.000Z")!
            )],
            granularity: .all
        )
        
        let compiledQuery = try query.precompile(namespace: nil, useNamespace: false, organizationAppIDs: [appID], isSuperOrg: true)
        
        // Also test legacy method for comparison
        let generatedTinyQuery = try RetentionQueryGenerator.generateRetentionQuery(
            dataSource: "com.telemetrydeck.all",
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
