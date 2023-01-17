
import DataTransferObjects
import XCTest

final class CompileDownTests: XCTestCase {
    let relativeIntervals = [
        RelativeTimeInterval(beginningDate: .init(.beginning, of: .month, adding: 0), endDate: .init(.end, of: .month, adding: 0))
    ]
    
    let appID1 = UUID()
    let appID2 = UUID()
    
    func testFunnel() throws {
        let steps: [Filter] = [
            .selector(.init(dimension: "type", value: "appLaunchedRegularly")),
            .selector(.init(dimension: "type", value: "dataEntered")),
            .selector(.init(dimension: "type", value: "paywallSeen")),
            .selector(.init(dimension: "type", value: "conversion"))
        ]
        
        let query = CustomQuery(queryType: .funnel, relativeIntervals: relativeIntervals, granularity: .all, steps: steps)
        
        let precompiledQuery = try query.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        
        // Exact query generation is in FunnelQueryGenerationTests,
        // here we're just making sure we're jumping into the correct paths.
        XCTAssertEqual(precompiledQuery.queryType, .groupBy)
        
        XCTAssertNil(precompiledQuery.steps)
        XCTAssertNil(precompiledQuery.stepNames)
    }
    
    func testFailIfNoIntervals() throws {
        // this query has neither a relativeIntervals nor an intervals property
        let query = CustomQuery(queryType: .timeseries, granularity: .all)
        
        XCTAssertThrowsError(try query.precompile(organizationAppIDs: [UUID(), UUID()], isSuperOrg: false))
    }
    
    func testBaseFiltersThisOrganization() throws {
        let thisOrganizationQuery = CustomQuery(queryType: .timeseries, baseFilters: .thisOrganization, relativeIntervals: relativeIntervals, granularity: .all)
        let thisOrganizationPrecompiledQuery = try thisOrganizationQuery.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        
        XCTAssertEqual(
            thisOrganizationPrecompiledQuery.filter,
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
        let thisOrganizationQueryFailing = CustomQuery(queryType: .timeseries, baseFilters: .thisApp, relativeIntervals: relativeIntervals, granularity: .all)
        XCTAssertThrowsError(try thisOrganizationQueryFailing.precompile(organizationAppIDs: [], isSuperOrg: false))
        
        let thisOrganizationPrecompiledQuery = try thisOrganizationQuery.precompile(organizationAppIDs: [appID1, appID2], isSuperOrg: false)
        
        XCTAssertEqual(
            thisOrganizationPrecompiledQuery.filter,
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
    
    func testDataSource() throws {
        XCTFail("Not Implemented")
    }
    
    func testAppIDFilter() throws {
        XCTFail("Not Implemented")
    }
    
    func testTestMode() throws {
        XCTFail("Not Implemented")
    }
}
