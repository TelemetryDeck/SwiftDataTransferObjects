import Foundation

public extension CustomQuery {
    enum QueryGenerationError: Error {
        case notAllowed(reason: String)
        case notImplemented(reason: String)
        case keyMissing(reason: String)
        case compilationStatusError
    }

    /// Compiles almost all TelemetryDeck-properties down into a regular query that can be enqueued in the Query Task Runner.
    ///
    /// Will not compile the relativeTimeIntervals property into intervals. These need to be calculated directly before running the query.
    ///
    /// @warn Both precompile AND compileToRunnableQuery need to be run before a query can safely be handed to Druid!
    ///
    /// @see compileToRunnableQuery
    func precompile(organizationAppIDs: [UUID], isSuperOrg: Bool) throws -> CustomQuery {
        guard (compilationStatus ?? .notCompiled) == .notCompiled else {
            throw QueryGenerationError.compilationStatusError
        }

        // Make an editable copy of self
        var query = self

        // Make sure either intervals or relative intervals are set
        guard query.intervals != nil || query.relativeIntervals != nil else {
            throw QueryGenerationError.keyMissing(reason: "Either 'relativeIntervals' or 'intervals' need to be set")
        }

        // Custom Query Types
        if query.queryType == .funnel {
            query = try precompiledFunnelQuery()
        } else if query.queryType == .experiment {
            query = try precompiledExperimentQuery()
        }

        // Apply base filters and data source
        query = try Self.applyBaseFilters(query: query, organizationAppIDs: organizationAppIDs, isSuperOrg: isSuperOrg)

        // Update compilationStatus so the next steps in the pipeline are sure the query has been precompiled
        query.compilationStatus = .precompiled

        return query
    }

    /// Compiles all TelemetryDeck additions down into a regular query that can be run on Apache Druid.
    ///
    /// Since this includes the `relativeTimeIntervals` property, this should only be called directly before actually running the query.
    ///
    /// @warn Both precompile AND compileToRunnableQuery need to be run before a query can safely be handed to Druid!
    ///
    /// @see precompile
    func compileToRunnableQuery(startWeekOnMonday: Bool) throws -> CustomQuery {
        guard compilationStatus == .precompiled else {
            throw QueryGenerationError.compilationStatusError
        }

        // Make an editable copy of self
        var query = self

        // Compile relative Time intervals
        if let relativeIntervals = query.relativeIntervals {
            query.intervals = relativeIntervals.map { QueryTimeInterval.from(relativeTimeInterval: $0, startWeekOnMonday: startWeekOnMonday) }
        }

        guard query.intervals != nil, !query.intervals!.isEmpty else {
            throw QueryGenerationError.keyMissing(reason: "Either 'relativeIntervals' or 'intervals' need to be set")
        }

        // Add restrictionsFilter
        if let applicableRestrictions = Self.getApplicableRestrictions(from: query) {
            query.restrictions = applicableRestrictions
            query.filter = query.filter && Filter.not(.init(field: Filter.interval(.init(dimension: "__time", intervals: applicableRestrictions))))
        }

        // Update compilationStatus so the next steps in the pipeline are sure the query has been compiled
        query.compilationStatus = .compiled

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
            query.context = QueryContext(timeout: "200000", skipEmptyBuckets: false)

            // Check sampling factor
            switch query.sampleFactor {
            case 10:
                query.dataSource = .init("telemetry-signals-sample10")
            case 100:
                query.dataSource = .init("telemetry-signals-sample100")
            case 1000:
                query.dataSource = .init("telemetry-signals-sample1000")
            default:
                query.dataSource = .init("telemetry-signals")
            }
        }

        // Apply filters according to the basefilters property
        switch baseFilters {
        case .thisOrganization:
            guard let organizationAppIDs = organizationAppIDs else { throw QueryGenerationError.keyMissing(reason: "Missing organization app IDs") }
            query.filter = try query.filter && appIDFilter(for: organizationAppIDs) && testModeFilter(for: query)
            return query

        case .thisApp:
            guard let appID = query.appID else { throw QueryGenerationError.keyMissing(reason: "Missing key 'appID'") }
            query.filter = try query.filter && appIDFilter(for: [appID]) && testModeFilter(for: query)
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
        Filter.selector(.init(dimension: "isTestMode", value: "\(query.testMode ?? false ? "true" : "false")"))
    }

    // Given a list of app UUIDs, generates a Filter object that restricts a query to only apps with either of the given IDs
    static func appIDFilter(for organizationAppIDs: [UUID]) throws -> Filter {
        guard !organizationAppIDs.isEmpty else {
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

    static func getApplicableRestrictions(from query: CustomQuery) -> [QueryTimeInterval]? {
        guard let restrictions = query.restrictions else { return nil }

        // Only apply those restrictions that actually are inside the query intervals
        var applicableRestrictions = Set<QueryTimeInterval>()
        for queryInterval in query.intervals ?? [] {
            for restrictionInterval in restrictions {
                let isOverlapping = (queryInterval.beginningDate <= restrictionInterval.endDate) && (restrictionInterval.beginningDate <= queryInterval.endDate)
                if isOverlapping {
                    applicableRestrictions.insert(restrictionInterval)
                }
            }
        }

        if applicableRestrictions.isEmpty {
            return nil
        } else {
            return applicableRestrictions.sorted { $0 < $1 }
        }
    }
}
