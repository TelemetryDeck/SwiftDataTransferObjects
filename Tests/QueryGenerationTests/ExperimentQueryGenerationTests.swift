@testable import DataTransferObjects
import XCTest

final class ExperimentQueryGenerationTests: XCTestCase {
    let cohort1: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "payScreenALaunched")), name: "Payscreen A")
    let cohort2: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "payScreenBLaunched")), name: "Payscreen B")

    let successCriterion: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "paymentSucceeded")), name: "Payment Succeeded")

    let relativeInterval = RelativeTimeInterval(
        beginningDate: .init(.beginning, of: .month, adding: -1),
        endDate: .init(.end, of: .month, adding: 0)
    )

    let organizationAppIDs: [UUID] = [.empty]

    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .and(.init(fields: [
            .selector(.init(
                dimension: "appID", value: "00000000-0000-0000-0000-000000000000"
            )),
            .selector(.init(
                dimension: "isTestMode", value: "false"
            )),
        ])),
        granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "payScreenALaunched")),
                aggregator: .thetaSketch(
                    .init(
                        name: "cohort_1",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "payScreenBLaunched")),
                aggregator: .thetaSketch(
                    .init(
                        name: "cohort_2",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "paymentSucceeded")),
                aggregator: .thetaSketch(
                    .init(
                        name: "success",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .or(.init(fields: [
                    .selector(.init(dimension: "type", value: "payScreenALaunched")),
                    .selector(.init(dimension: "type", value: "payScreenBLaunched")),
                ])),
                aggregator: .thetaSketch(
                    .init(
                        name: "users",
                        fieldName: "clientUser"
                    )
                )
            )),
        ],
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "cohort_1_success",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "cohort_1"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "success"
                        )),
                    ]
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "cohort_2_success",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "cohort_2"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "success"
                        )),
                    ]
                ))
            )),
            .zscore2sample(.init(
                name: "zscore",
                sample1Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_1"
                )),
                successCount1: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_1_success"
                )),
                sample2Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_2"
                )),
                successCount2: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_2_success"
                ))
            )),
            .pvalue2tailedZtest(.init(
                name: "pvalue",
                zScore: .fieldAccess(.init(type: .fieldAccess, fieldName: "zscore"))
            )),
        ]
    )

    func testExample() throws {
        let startingQuery = CustomQuery(
            queryType: .experiment,
            relativeIntervals: [relativeInterval],
            granularity: .all,
            sample1: cohort1,
            sample2: cohort2,
            successCriterion: successCriterion
        )
        let generatedTinyQuery = try startingQuery.precompile(organizationAppIDs: organizationAppIDs, isSuperOrg: false)

        XCTAssertEqual(tinyQuery.filter, generatedTinyQuery.filter)
        XCTAssertEqual(tinyQuery.aggregations, generatedTinyQuery.aggregations)
        XCTAssertEqual(tinyQuery.postAggregations, generatedTinyQuery.postAggregations)
    }
}
