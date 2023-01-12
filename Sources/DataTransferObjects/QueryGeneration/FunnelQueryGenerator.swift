import Foundation

public enum FunnelQueryGenerator {
    public enum FunnelQueryGeneratorErrors: Error {
        // case errors here
    }

    public static func generateFunnelQuery(
        steps: [Filter],
        stepNames: [String],
        filter _: Filter?,
        appID: String,
        testMode: Bool
    ) throws -> CustomQuery {
        // Generate Filter Statement
        let stepsFilters = Filter.or(.init(fields: steps))
        let testModeFilter = Filter.selector(.init(dimension: "isTestMode", value: "\(testMode)"))
        let appIDFilter = Filter.selector(.init(dimension: "appID", value: appID))
        let filter = Filter.and(.init(fields: [appIDFilter, testModeFilter, stepsFilters]))

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
            filter: filter,
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
