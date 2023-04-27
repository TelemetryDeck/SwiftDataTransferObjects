@testable import DataTransferObjects
import XCTest

final class ExperimentQueryGenerationTests: XCTestCase {
    let cohort1: NamedFilter =
        .init(filter: .selector(.init(dimension: "type", value: "payScreenALaunched")), name: "Payscreen A")
    let cohort2: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "payScreenBLaunched")), name: "Payscreen B")
    

    let successCriterion: NamedFilter = .init(filter: .selector(.init(dimension: "type", value: "paymentSucceeded")), name: "Payment Succeeded")

    let tinyQuery = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter:
        .or(.init(fields: [
            .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
            .selector(.init(dimension: "type", value: "dataEntered")),
            .selector(.init(dimension: "type", value: "paywallSeen")),
            .selector(.init(dimension: "type", value: "conversion"))

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
