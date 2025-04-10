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
    func precompile(
        namespace: String? = nil,
        namespaceAvailableAfter: Date? = nil,
        organizationAppIDs: [UUID],
        isSuperOrg: Bool
    ) throws -> CustomQuery {
        guard (compilationStatus ?? .notCompiled) == .notCompiled else {
            throw QueryGenerationError.compilationStatusError
        }

        // If we're not a super-org, disallow running groupBy and topN queries in hourly granularity
        // because these currently produce misleading or wrong data sometimes.
        // Remove this after the issue is fixed.
        if !isSuperOrg, granularity == .hour, [.topN, .groupBy].contains(queryType) {
            throw QueryGenerationError.notImplemented(reason: "This query can't be calculated in hourly granularity. Please choose daily or monthly instead.")
        }

        // Make an editable copy of self
        var query = self

        // Make sure either intervals or relative intervals are set
        if query.intervals == nil && query.relativeIntervals == nil {
            query.relativeIntervals = [.init(beginningDate: .init(.beginning, of: .day, adding: -30), endDate: .init(.end, of: .day, adding: 0))]
        }

        // Custom Query Types
        if query.queryType == .funnel {
            // If a namespace is set, increase the accuracy of the funnel query (i.e. the size of the theta sketch).
            // This helps increase accuracy for bigger customerrs who have their own namespace while hopefully keeping costs down in telemetry-signals.
            // https://github.com/TelemetryDeck/SwiftDataTransferObjects/issues/55
            query = try namespace == nil ? precompiledFunnelQuery() : precompiledFunnelQuery(accuracy: 65536)
        } else if query.queryType == .experiment {
            query = try precompiledExperimentQuery()
        }

        // Handle precompilable aggregators and post aggregators
        var aggregations = [Aggregator]()
        var postAggregations = [PostAggregator]()
        for aggregator in query.aggregations ?? [] {
            guard let compiled = aggregator.precompile() else {
                aggregations.append(aggregator)
                continue
            }
            aggregations.append(contentsOf: compiled.aggregators)
            postAggregations.append(contentsOf: compiled.postAggregators)
        }
        for postAggregator in query.postAggregations ?? [] {
            guard let compiled = postAggregator.precompile() else {
                postAggregations.append(postAggregator)
                continue
            }
            aggregations.append(contentsOf: compiled.aggregators)
            postAggregations.append(contentsOf: compiled.postAggregators)
        }
        query.aggregations = aggregations
        query.postAggregations = postAggregations

        // Apply base filters and data source
        query = try Self.applyBaseFilters(
            namespace: namespace,
            namespaceAvailableAfter: namespaceAvailableAfter,
            query: query,
            organizationAppIDs: organizationAppIDs,
            isSuperOrg: isSuperOrg
        )

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
    func compileToRunnableQuery() throws -> CustomQuery {
        guard compilationStatus == .precompiled else {
            throw QueryGenerationError.compilationStatusError
        }

        // Make an editable copy of self
        var query = self

        // Compile relative Time intervals
        if let relativeIntervals = query.relativeIntervals {
            query.intervals = relativeIntervals.map { QueryTimeInterval.from(relativeTimeInterval: $0) }
        }

        guard query.intervals != nil, !query.intervals!.isEmpty else {
            throw QueryGenerationError.keyMissing(reason: "Either 'relativeIntervals' or 'intervals' need to be set")
        }

        // Compile relative intervals in Relative Interval filters
        if let filter = query.filter {
            query.filter = compileRelativeFilterInterval(filter: filter)
        }

        // Comppile relative intervals in Aggregators
        if let aggregations = query.aggregations {
            query.aggregations = aggregations.map { agg in compileRelativeIntervalFilterInAggregations(agg: agg) }
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

    private func compileRelativeFilterInterval(filter: Filter) -> Filter {
        switch filter {
        case .selector:
            return filter
        case .columnComparison:
            return filter
        case .interval(let filterInterval):
            if let relativeIntervals = filterInterval.relativeIntervals {
                return Filter.interval(
                    .init(
                        dimension: filterInterval.dimension,
                        intervals: relativeIntervals.map { QueryTimeInterval.from(relativeTimeInterval: $0) }
                    )
                )
            } else {
                return filter
            }
        case .regex:
            return filter
        case .range:
            return filter
        case .and(let filterExpression):
            return Filter.and(.init(fields: filterExpression.fields.map { compileRelativeFilterInterval(filter: $0) }))
        case .or(let filterExpression):
            return Filter.or(.init(fields: filterExpression.fields.map { compileRelativeFilterInterval(filter: $0) }))
        case .not(let filterNot):
            return Filter.not(.init(field: compileRelativeFilterInterval(filter: filterNot.field)))
        }
    }

    private func compileRelativeIntervalFilterInAggregations(agg: Aggregator) -> Aggregator {
        switch agg {
        case .filtered(let filteredAggregator):
            return Aggregator.filtered(
                .init(
                    filter: compileRelativeFilterInterval(filter: filteredAggregator.filter),
                    aggregator: compileRelativeIntervalFilterInAggregations(agg: filteredAggregator.aggregator)
                )
            )
        default:
            return agg
        }
    }
}

extension CustomQuery {
    static func applyBaseFilters(
        namespace: String?,
        namespaceAvailableAfter: Date?,
        query: CustomQuery,
        organizationAppIDs: [UUID]?,
        isSuperOrg: Bool
    ) throws -> CustomQuery {
        // make an editable copy of the query
        var query = query

        // Throw if noFilter is requested by an ord that is not super
        let baseFilters = query.baseFilters ?? .thisOrganization
        if baseFilters == .noFilter {
            guard isSuperOrg else {
                throw QueryGenerationError.notAllowed(reason: "The noFilter base filter is not implemented.")
            }
        } else {
            let maxPriority = isSuperOrg ? 5 : 1
            let minPriority = -1
            var clampedPriority = query.context?.priority ?? 1
            if clampedPriority > maxPriority {
                clampedPriority = maxPriority
            }
            if clampedPriority < minPriority {
                clampedPriority = minPriority
            }

            query.context = QueryContext(
                timeout: "200000",
                priority: query.context?.priority == nil ? nil : clampedPriority,
                timestampResultField: query.context?.timestampResultField,
                minTopNThreshold: query.context?.minTopNThreshold,
                grandTotal: query.context?.grandTotal,
                skipEmptyBuckets: false,
                cacheValidityDuration: query.context?.cacheValidityDuration
            )

            let allowedDataSourceNames = [
                "telemetry-signals",
                "com.telemetrydeck.all",
                "com.telemetrydeck.compacted"
            ]

            // Calculate earliest interval date, to compare against namespaceAvailableAfter
            var earliestIntervalDate = Date.distantFuture
            for interval in query.intervals ?? [] {
                earliestIntervalDate = min(interval.beginningDate, earliestIntervalDate)
            }
            for relativeInterval in query.relativeIntervals ?? [] {
                let interval = QueryTimeInterval.from(relativeTimeInterval: relativeInterval)
                earliestIntervalDate = min(interval.beginningDate, earliestIntervalDate)
            }

            // Decide the data source based on the data source property and namespaces
            if let namespace, (namespaceAvailableAfter ?? Date.distantPast) < earliestIntervalDate {
                // If a namespace is available, use the namespace, even if another data source is specified.
                // This allows us to specify com.telemetrydeck.all for global queries and still use the customer's
                // name space if they have one.
                query.dataSource = .init(namespace)
            } else if let dataSource = query.dataSource, allowedDataSourceNames.contains(dataSource.name) {
                // If no namespace is available and the customer requested a specific data source, use it
                // if it is in the list of allowed data sources.
                query.dataSource = .init(dataSource.name)
            } else {
                // Else fall back to telemetry-signals
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
            guard isSuperOrg || (organizationAppIDs ?? []).contains(appID) else { throw QueryGenerationError.notAllowed(reason: "AppID not in organization") }
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
