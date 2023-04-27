@testable import DataTransferObjects
import XCTest

final class ExperimentQueryGenerationTests: XCTestCase {
    let cohort1: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "payScreenALaunched")), name: "Payscreen A")
    let cohort2: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "payScreenBLaunched")), name: "Payscreen B")

    let successCriterion: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "paymentSucceeded")), name: "Payment Succeeded")

    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .selector(.init(dimension: "appID", value: "8044464F-C327-4ADF-8143-4A0FC1F00896")),
        granularity: .all,
        aggregations: [
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "appCreated")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_cohort_0",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "view")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_cohort_1",
                        fieldName: "clientUser"
                    )
                )
            )),
            .filtered(.init(
                filter: .selector(.init(dimension: "type", value: "pricingPlanSelected")),
                aggregator: .thetaSketch(
                    .init(
                        type: AggregatorType.thetaSketch,
                        name: "_success_0",
                        fieldName: "clientUser"
                    )
                )
            ))
        ],
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "_cohort_0_success_0",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_cohort_0"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_success_0"
                        ))
                    ]
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "_cohort_1_success_0",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_cohort_1"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_success_0"
                        ))
                    ]
                ))
            )),
            .zscore2sample(.init(
                name: "zscore",
                sample1Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_0"
                )),
                successCount1: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_0_success_0"
                )),
                sample2Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_1"
                )),
                successCount2: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_1_success_0"
                ))
            )),
            .pvalue2tailedZtest(.init(
                name: "pvalue",
                zScore: .fieldAccess(.init(type: .fieldAccess, fieldName: "zscore"))
            ))
        ]
    )

    func testExample() throws {
        let startingQuery = CustomQuery(queryType: .experiment, granularity: .all, sample1: cohort1, sample2: cohort2, successCriterion: successCriterion)
        let generatedTinyQuery = try startingQuery.precompile(organizationAppIDs: [], isSuperOrg: false)

        XCTAssertEqual(tinyQuery.filter, generatedTinyQuery.filter)
        XCTAssertEqual(tinyQuery.aggregations, generatedTinyQuery.aggregations)
        XCTAssertEqual(tinyQuery.postAggregations, generatedTinyQuery.postAggregations)
    }

    func testWithAdditionalFilters() throws {
        let additionalFilter = Filter.selector(.init(dimension: "something", value: "other"))

        let startingQuery = CustomQuery(queryType: .experiment, filter: additionalFilter, granularity: .all, sample1: cohort1, sample2: cohort2, successCriterion: successCriterion)
        let generatedTinyQuery = try startingQuery.precompile(organizationAppIDs: [], isSuperOrg: false)

        let expectedFilter = Filter.and(.init(fields: [
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

    func testFunnelQueryGenerationKeepsRelativeIntervals() throws {
        let relativeTimeIntervals = [
            RelativeTimeInterval(
                beginningDate: RelativeDate(.beginning, of: .month, adding: -1),
                endDate: RelativeDate(.end, of: .month, adding: 0)
            )
        ]

        let startingQuery = CustomQuery(queryType: .experiment, relativeIntervals: relativeTimeIntervals, granularity: .all, sample1: cohort1, sample2: cohort2, successCriterion: successCriterion)
        let generatedTinyQuery = try startingQuery.precompile(organizationAppIDs: [], isSuperOrg: false)

        XCTAssertEqual(startingQuery.relativeIntervals, generatedTinyQuery.relativeIntervals)
    }
}
