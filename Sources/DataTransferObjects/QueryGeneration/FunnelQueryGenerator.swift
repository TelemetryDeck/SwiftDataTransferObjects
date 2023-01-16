import Foundation

public enum FunnelQueryGenerator {
    public static func generateFunnelQuery(
        steps: [Filter],
        stepNames: [String]?,
        filter: Filter?
    ) throws -> CustomQuery {
        let stepNames = stepNames ?? []

        // Generate Filter Statement
        let stepsFilters = Filter.or(.init(fields: steps))
        let queryFilter = filter && stepsFilters

        // Generate Aggregations
        let aggregationNamePrefix = "_funnel_step_"
        var aggregations = [Aggregator]()
        for (index, step) in steps.enumerated() {
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
        for (index, _) in steps.enumerated() {
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
        return CustomQuery(
            queryType: .groupBy,
            dataSource: "telemetry-signals",
            filter: queryFilter,
            granularity: .all,
            aggregations: aggregations,
            postAggregations: postAggregations
        )
    }
}

private extension Array {
    subscript(safe index: Index, default defaultValue: Element) -> Element {
        return indices.contains(index) ? self[index] : defaultValue
    }
}
