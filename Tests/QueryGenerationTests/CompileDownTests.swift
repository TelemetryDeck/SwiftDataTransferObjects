import DataTransferObjects
import XCTest

final class CompileDownTests: XCTestCase {
    let relativeIntervals = [
        RelativeTimeInterval(beginningDate: .init(.beginning, of: .month, adding: 0), endDate: .init(.end, of: .month, adding: 0))
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

    func testFailIfNoIntervals() throws {
        // this query has neither a relativeIntervals nor an intervals property
        let query = CustomQuery(queryType: .timeseries, granularity: .all)

        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [UUID(), UUID()], isSuperOrg: false))
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
                    ))
                ]
                )),
                .selector(.init(dimension: "isTestMode", value: "false"))
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
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)

        XCTAssertEqual(
            precompiledQuery.filter,
            .and(.init(fields: [
                .selector(.init(dimension: "appID", value: appID.uuidString)),
                .selector(.init(dimension: "isTestMode", value: "false"))
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
                .selector(.init(dimension: "isTestMode", value: "false"))
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
        XCTAssertEqual(try query1.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false).dataSource, DataSource.init("telemetry-signals"))

        // Specified datasource but not noFilter + super org will be replaced by telemetry-signals
        let query2 = CustomQuery(queryType: .timeseries, dataSource: "some-data-source", baseFilters: .thisOrganization, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertEqual(try query2.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false).dataSource, DataSource.init("telemetry-signals"))

        // Specified datasource will be retained if super org is set
        let query3 = CustomQuery(queryType: .timeseries, dataSource: "some-data-source", baseFilters: .noFilter, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertEqual(try query3.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: true).dataSource, DataSource.init("some-data-source"))
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
}
