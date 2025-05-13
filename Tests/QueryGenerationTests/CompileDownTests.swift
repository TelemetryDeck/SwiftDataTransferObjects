import DataTransferObjects
import XCTest

final class CompileDownTests: XCTestCase {
    let relativeIntervals = [
        RelativeTimeInterval(beginningDate: .init(.beginning, of: .month, adding: 0), endDate: .init(.end, of: .month, adding: 0)),
    ]

    let appID1 = UUID()
    let appID2 = UUID()

    func testFunnel() throws {
        let steps: [NamedFilter] = [
            .init(filter: .selector(.init(dimension: "type", value: "appLaunchedRegularly")), name: "Regular Launch"),
            .init(filter: .selector(.init(dimension: "type", value: "dataEntered")), name: "Data Entered"),
            .init(filter: .selector(.init(dimension: "type", value: "paywallSeen")), name: "Paywall Presented"),
            .init(filter: .selector(.init(dimension: "type", value: "conversion")), name: "Conversion"),
        ]

        let query = CustomQuery(queryType: .funnel, relativeIntervals: relativeIntervals, granularity: .all, steps: steps)

        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)

        // Exact query generation is in FunnelQueryGenerationTests,
        // here we're just making sure we're jumping into the correct paths.
        XCTAssertEqual(precompiledQuery.queryType, .groupBy)
    }

    func testBaseFiltersThisOrganization() throws {
        let query = CustomQuery(queryType: .timeseries, baseFilters: .thisOrganization, relativeIntervals: relativeIntervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)

        XCTAssertEqual(
            precompiledQuery.filter,
            .and(.init(fields: [
                .or(.init(fields: [
                    .selector(.init(
                        dimension: "appID",
                        value: appID1.uuidString
                    )),
                    .selector(.init(
                        dimension: "appID",
                        value: appID2.uuidString
                    )),
                ]
                )),
                .selector(.init(dimension: "isTestMode", value: "false")),
            ]
            ))
        )
    }

    func testBaseFiltersThisApp() throws {
        // this should fail because the query does not have an appID
        let queryFailing = CustomQuery(queryType: .timeseries, baseFilters: .thisApp, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertThrowsError(try queryFailing.precompile(organizationAppIDs: [], isSuperOrg: false))

        // This should succeed because an app ID is provided
        let appID = UUID()
        let query = CustomQuery(queryType: .timeseries, appID: appID, baseFilters: .thisApp, relativeIntervals: relativeIntervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID, appID1, appID2], isSuperOrg: false)

        XCTAssertEqual(
            precompiledQuery.filter,
            .and(.init(fields: [
                .selector(.init(dimension: "appID", value: appID.uuidString)),
                .selector(.init(dimension: "isTestMode", value: "false")),
            ]))
        )
    }

    func testBaseFiltersExampleData() throws {
        let query = CustomQuery(queryType: .timeseries, baseFilters: .exampleData, relativeIntervals: relativeIntervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)

        XCTAssertEqual(
            precompiledQuery.filter,
            .and(.init(fields: [
                .selector(.init(dimension: "appID", value: "B97579B6-FFB8-4AC5-AAA7-DA5796CC5DCE")),
                .selector(.init(dimension: "isTestMode", value: "false")),
            ]))
        )
    }

    func testBaseFiltersNoFilter() throws {
        let query = CustomQuery(queryType: .timeseries, baseFilters: .noFilter, relativeIntervals: relativeIntervals, granularity: .all)

        // this should fail because isSuperOrg is not set to true
        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))

        // this should succeed because isSuperOrg is set to true
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: true)

        XCTAssertNil(precompiledQuery.filter)
    }

    func testDataSource() throws {
        // No datasource means data source is telemetry-signals
        let query1 = CustomQuery(queryType: .timeseries, baseFilters: .thisOrganization, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertEqual(try query1.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false).dataSource, DataSource("telemetry-signals"))

        // Specified datasource but not noFilter + super org will be replaced by telemetry-signals
        let query2 = CustomQuery(queryType: .timeseries, dataSource: "some-data-source", baseFilters: .thisOrganization, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertEqual(try query2.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false).dataSource, DataSource("telemetry-signals"))

        // Specified datasource will be retained if super org is set
        let query3 = CustomQuery(queryType: .timeseries, dataSource: "some-data-source", baseFilters: .noFilter, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertEqual(try query3.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: true).dataSource, DataSource("some-data-source"))
    }

    func testThrowsIfNeitherIntervalsNorRelativeIntervalsSet() throws {
        let query = CustomQuery(queryType: .timeseries, baseFilters: .noFilter, intervals: nil, relativeIntervals: nil, granularity: .all)

        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [], isSuperOrg: false))
    }

    func testCompilationFailsIfNoPrecompilation() throws {
        let query = CustomQuery(queryType: .timeseries, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertThrowsError(try query.compileToRunnableQuery())
    }

    func testIntervalsAreCreated() throws {
        let query = CustomQuery(queryType: .timeseries, relativeIntervals: relativeIntervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()

        XCTAssertNotNil(compiledQuery.intervals)
        XCTAssertFalse(compiledQuery.intervals!.isEmpty)
    }

    func testFiltersSupportRelativeIntervals() throws {
        let query = CustomQuery(
            queryType: .timeseries,
            filter: .or(
                .init(
                    fields: [.interval(
                        .init(
                            dimension: "__time",
                            relativeIntervals: [.init(
                                beginningDate: .init(.beginning, of: .month, adding: -6),
                                endDate: .init(.end, of: .month, adding: 0)
                            )]
                        )
                    )]
                )
            ),
            relativeIntervals: relativeIntervals,
            granularity: .all
        )

        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()

        guard case .and(let testModeFilter) = compiledQuery.filter else {
            XCTFail("Filter is of wrong type")
            return
        }

        guard case .and(let appIDsFilter) = testModeFilter.fields.first else {
            XCTFail("Filter is of wrong type")
            return
        }

        guard let orFilter = appIDsFilter.fields.first else {
            XCTFail("Filter is of wrong type")
            return
        }

        switch orFilter {
        case .or(let orFilterExpression):
            guard let intervalFilter = orFilterExpression.fields.first else {
                XCTFail("Filter is of wrong number")
                return
            }

            switch intervalFilter {
            case .interval(let filterInterval):
                XCTAssertNotNil(filterInterval.intervals)
                XCTAssertFalse(filterInterval.intervals!.isEmpty)
            default:
                XCTFail("Filter is of wrong number")
            }
        default:
            XCTFail("Filter is of wrong type")
        }
    }

    func testAggreggationsSupportRelativeIntervals() throws {
        let query = CustomQuery(
            queryType: .timeseries,
            relativeIntervals: relativeIntervals,
            granularity: .all,
            aggregations: [
                .filtered(
                    .init(
                        filter: .interval(
                            .init(
                                dimension: "__time",
                                relativeIntervals: [.init(
                                    beginningDate: .init(.beginning, of: .month, adding: -6),
                                    endDate: .init(.end, of: .month, adding: 0)
                                )]
                            )
                        ),
                        aggregator: .count(.init(name: "appID"))
                    )
                ),
            ]
        )
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()

        guard let aggregation = compiledQuery.aggregations?.first else {
            XCTFail("CompiledQuery has no aggregations")
            return
        }

        guard case .filtered(let filteredAggregator) = aggregation else {
            XCTFail("CompiledQuery has wrong type of aggregation")
            return
        }

        guard case .interval(let filterInterval) = filteredAggregator.filter else {
            XCTFail("CompiledQuery has wrong type of filter")
            return
        }

        XCTAssertNotNil(filterInterval.intervals)
        XCTAssertFalse(filterInterval.intervals!.isEmpty)
    }

    func testCompilationStatusIsSetCorrectly() throws {
        let query = CustomQuery(queryType: .timeseries, relativeIntervals: relativeIntervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()

        XCTAssertEqual(precompiledQuery.compilationStatus, .precompiled)
        XCTAssertEqual(compiledQuery.compilationStatus, .compiled)
    }

    func testThrowsIfCompilationStatusNotSetCorrectly() throws {
        let query = CustomQuery(queryType: .timeseries, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertThrowsError(try query.compileToRunnableQuery())
    }

    func testRestrictions() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]

        let restrictions: [QueryTimeInterval] = [
            // This restriction should be dropped in the final query, because it does not apply
            .init(beginningDate: Date(iso8601String: "2023-01-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-01-31T00:00:00.000Z")!),

            // This restriction should be included because it does apply
            .init(beginningDate: Date(iso8601String: "2023-05-14T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),

            // This restriction should be included because it applies partially
            .init(beginningDate: Date(iso8601String: "2023-03-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-04-02T00:00:00.000Z")!),
        ]

        let query = CustomQuery(queryType: .timeseries, restrictions: restrictions, intervals: intervals, granularity: .all)
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()

        XCTAssertEqual(compiledQuery.restrictions, [
            .init(beginningDate: Date(iso8601String: "2023-03-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-04-02T00:00:00.000Z")!),
            .init(beginningDate: Date(iso8601String: "2023-05-14T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ])
    }

    func testNamespace() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]

        var query = CustomQuery(queryType: .timeseries, intervals: intervals, granularity: .day)
        query.dataSource = nil
        let precompiledQuery = try query.precompile(namespace: "com.telemetrydeck.test", organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        let compiledQuery = try precompiledQuery.compileToRunnableQuery()
        XCTAssertEqual(compiledQuery.dataSource?.name, "com.telemetrydeck.test")
    }

    func testAllowsHourlyGranularityForTimeseries() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]
        let query = CustomQuery(queryType: .timeseries, intervals: intervals, granularity: .hour)
        XCTAssertNoThrow(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))
    }

    func testAllowsDailyGranularityForTopN() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]
        let query = CustomQuery(queryType: .topN, intervals: intervals, granularity: .day)
        XCTAssertNoThrow(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))
    }

    func testAllowsDailyGranularityForGroupBy() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]
        let query = CustomQuery(queryType: .groupBy, intervals: intervals, granularity: .day)
        XCTAssertNoThrow(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))
    }

    func testDisallowsHourlyQueriesForTopN() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]
        let query = CustomQuery(queryType: .topN, intervals: intervals, granularity: .hour)

        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))
    }

    func testDisallowsHourlyQueriesForGroupBy() throws {
        let intervals: [QueryTimeInterval] = [
            .init(beginningDate: Date(iso8601String: "2023-04-01T00:00:00.000Z")!, endDate: Date(iso8601String: "2023-05-31T00:00:00.000Z")!),
        ]
        let query = CustomQuery(queryType: .groupBy, intervals: intervals, granularity: .hour)

        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false))
    }
}
