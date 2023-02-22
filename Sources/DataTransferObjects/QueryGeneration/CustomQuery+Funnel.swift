extension CustomQuery {
    func precompiledFunnelQuery() throws -> CustomQuery {
        var query = self

        guard let steps = steps else { throw QueryGenerationError.keyMissing(reason: "Missing key 'steps'") }
        
        let stepFilters = steps.compactMap({ $0.filter })
        let stepNames = steps.compactMap({ $0.name })

        // Generate Filter Statement
        let stepsFilters = Filter.or(.init(fields: stepFilters))
        let queryFilter = filter && stepsFilters

        // Generate Aggregations
        let aggregationNamePrefix = "_funnel_step_"
        var aggregations = [Aggregator]()
        for (index, step) in stepFilters.enumerated() {
            aggregations.append(.filtered(.init(
                filter: step,
                aggregator: .thetaSketch(.init(
                    type: .thetaSketch,
                    name: "\(aggregationNamePrefix)\(index)",
                    fieldName: "clientUser"
                ))
            )))
        }

        // Generate Post-Agregations
        var postAggregations = [PostAggregator]()
        for index in steps.indices {
            if index == 0 {
                postAggregations.append(.thetaSketchEstimate(.init(
                    name: "\(index)_\(stepNames[safe: index, default: "\(aggregationNamePrefix)\(index)"])",
                    field: .fieldAccess(.init(
                        type: .fieldAccess,
                        fieldName: "\(aggregationNamePrefix)\(index)"
                    ))
                )))
                continue
            }

            postAggregations.append(.thetaSketchEstimate(.init(
                name: "\(index)_\(stepNames[safe: index, default: "\(aggregationNamePrefix)\(index)"])",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: (0 ... index).map { stepNumber in
                        .fieldAccess(.init(type: .fieldAccess, fieldName: "\(aggregationNamePrefix)\(stepNumber)"))
                    }
                ))
            )))
        }

        // Combine query
        query.queryType = .groupBy
        query.filter = queryFilter
        query.aggregations = aggregations
        query.postAggregations = postAggregations

        return query
    }
}

fileprivate extension Array {
    subscript(safe index: Index, default defaultValue: Element) -> Element {
        return indices.contains(index) ? self[index] : defaultValue
    }
}
