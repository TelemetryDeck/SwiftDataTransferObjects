extension CustomQuery {
    func precompiledFunnelQuery(accuracy: Int? = nil) throws -> CustomQuery {
        var query = self

        guard let steps = steps else { throw QueryGenerationError.keyMissing(reason: "Missing key 'steps'") }

        // Generate Filter Statement
        let stepsFilters = Filter.or(.init(fields: steps.compactMap(\.filter)))
        let queryFilter = filter && stepsFilters

        // Generate Aggregations
        let aggregationNamePrefix = "_funnel_step_"
        var aggregations = [Aggregator]()

        for (index, step) in steps.enumerated() {
            aggregations.append(.filtered(.init(
                filter: step.filter ?? Filter.empty,
                aggregator: .thetaSketch(.init(
                    name: "\(aggregationNamePrefix)\(index)",
                    fieldName: "clientUser",
                    size: accuracy
                ))
            )))
        }

        // Generate Post-Agregations
        var postAggregations = [PostAggregator]()
        for (index, step) in steps.enumerated() {
            if index == 0 {
                postAggregations.append(.thetaSketchEstimate(.init(
                    name: "\(index)_\(step.name)",
                    field: .fieldAccess(.init(
                        type: .fieldAccess,
                        fieldName: "\(aggregationNamePrefix)\(index)"
                    ))
                )))
                continue
            }

            postAggregations.append(.thetaSketchEstimate(.init(
                name: "\(index)_\(step.name)",
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

private extension Array {
    subscript(safe index: Index, default defaultValue: Element) -> Element {
        indices.contains(index) ? self[index] : defaultValue
    }
}
