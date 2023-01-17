
import Foundation

public extension CustomQuery {
    enum QueryGenerationError: Error {
        case notAllowed(reason: String)
        case notImplemented(reason: String)
        case keyMissing(reason: String)
    }
    
    /// Compiles almost all TelemetryDeck-properties down into a regular query that can be enqueued in the Query Task Runner.
    ///
    /// Will not compile the relativeTimeIntervals property into intervals. These need to be calculated directly before running the query.
    ///
    /// @warn Both precompile AND compileToRunnableQuery need to be run before a query can safely be handed to Druid!
    ///
    /// @see compileToRunnableQuery
    func precompile(organizationAppIDs: [UUID], isSuperOrg: Bool) throws -> CustomQuery {
        // Make an editable copy of self
        var query = self
        
        // Make sure either intervals or relative intervals are set
        guard query.intervals != nil || query.relativeIntervals != nil else {
            throw QueryGenerationError.keyMissing(reason: "Either 'relativeIntervals' or 'intervals' need to be set")
        }
        
        // Custom Query Types
        if query.queryType == .funnel {
            guard let steps = query.steps else { throw QueryGenerationError.keyMissing(reason: "Missing key 'steps'") }
            query = try FunnelQueryGenerator.generateFunnelQuery(steps: steps, stepNames: query.stepNames, filter: query.filter)
        }
        
        // TODO:
        // if query.queryType == .retention {
        //     query = RetentionQueryGenerator.generateRetentionQuery
        // }
        
        // Apply base filters and data source
        query = try Self.applyBaseFilters(query: query, organizationAppIDs: organizationAppIDs, isSuperOrg: isSuperOrg)
        
        // Set all telemetrydeck properties to nil except relativeIntervals
        // so that we can check in compileToRunnableQuery that all these have been set
        query.appID = nil
        query.testMode = nil
        query.steps = nil
        query.stepNames = nil
        
        return query
    }
    
    /// Compiles all TelemetryDeck additions down into a regular query that can be run on Apache Druid.
    ///
    /// Since this includes the `relativeTimeIntervals` property, this should only be called directly before actually running the query.
    ///
    /// @warn Both precompile AND compileToRunnableQuery need to be run before a query can safely be handed to Druid!
    ///
    /// @see precompile
    func compileToRunnableQuery() throws -> CustomQuery {
        // Make an editable copy of self
        var query = self
        
        // Check if all telemetrydeck properties are set to nil, or throw.
        // This is a precaution to make it more likely that precompile
        // has been run on this query at some point in the past
        // which, may I remind you, gentle reader, is a requirement.
        guard query.appID == nil, query.testMode == nil, query.steps == nil, query.stepNames == nil else {
            throw CustomQuery.QueryGenerationError.notAllowed(reason: "Not all precompilation steps have completed.")
        }
        
        // Compile relative Time intervals
        if let relativeIntervals = query.relativeIntervals {
            query.intervals = relativeIntervals.map { QueryTimeInterval.from(relativeTimeInterval: $0) }
        }
        
        return query
    }
}
 
extension CustomQuery {
    static func applyBaseFilters(query: CustomQuery, organizationAppIDs: [UUID]?, isSuperOrg: Bool) throws -> CustomQuery {
        // make an editable copy of the query
        var query = query

        // Throw if noFilter is requested by an ord that is not super
        let baseFilters = query.baseFilters ?? .thisOrganization
        if baseFilters == .noFilter {
            guard isSuperOrg else {
                throw QueryGenerationError.notAllowed(reason: "The noFilter base filter is not implemented.")
            }
        } else {
            query.dataSource = .init("telemetry-signals")
            query.context = QueryContext(timeout: "200000", skipEmptyBuckets: false)
        }

        // Apply filters according to the basefilters property
        switch baseFilters {
        case .thisOrganization:
            guard let organizationAppIDs = organizationAppIDs else { throw QueryGenerationError.keyMissing(reason: "Missing organization app IDs") }
            query.filter = query.filter && (try appIDFilter(for: organizationAppIDs)) && testModeFilter(for: query)
            return query
            
        case .thisApp:
            guard let appID = query.appID else { throw QueryGenerationError.keyMissing(reason: "Missing key 'appID'") }
            query.filter = query.filter && (try appIDFilter(for: [appID])) && testModeFilter(for: query)
            return query

        case .exampleData:
            let appIDFilter = Filter.selector(.init(dimension: "appID", value: "B97579B6-FFB8-4AC5-AAA7-DA5796CC5DCE"))
            query.filter = query.filter && appIDFilter && testModeFilter(for: query)
            return query

        case .noFilter:
            return query
        }
    }
    
    /// Returns a filter according to the query objects `testMode` property.
    static func testModeFilter(for query: CustomQuery) -> Filter {
        return Filter.selector(.init(dimension: "isTestMode", value: "\(query.testMode ?? false ? "true" : "false")"))
    }
    
    // Given a list of app UUIDs, generates a Filter object that restricts a query to only apps with either of the given IDs
    static func appIDFilter(for organizationAppIDs: [UUID]) throws -> Filter {
        guard organizationAppIDs.count > 0 else {
            throw QueryGenerationError.keyMissing(reason: "Missing organization app IDs")
        }
        
        guard organizationAppIDs.count != 1 else {
            return Filter.selector(.init(dimension: "appID", value: organizationAppIDs.first!.uuidString))
        }
        
        let filters = organizationAppIDs.compactMap {
            Filter.selector(.init(dimension: "appID", value: $0.uuidString))
        }

        return Filter.or(.init(fields: filters))
    }
}
