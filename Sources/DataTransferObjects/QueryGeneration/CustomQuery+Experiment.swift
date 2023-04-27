extension CustomQuery {
    func precompiledExperimentQuery() throws -> CustomQuery {
        var query = self
        
        guard let sample1 = sample1 else { throw QueryGenerationError.keyMissing(reason: "Missing key 'sample1'") }
        guard let sample2 = sample2 else { throw QueryGenerationError.keyMissing(reason: "Missing key 'sample2'") }
        guard let successCriterion = successCriterion else { throw QueryGenerationError.keyMissing(reason: "Missing key 'successCriterion'") }
        
        // Generate Filter Statement
        // In theory, we could pre-filter here by combining all filtered aggregations with an "or" filter. Which
        // might bring a bit of a perfmance benefit.
   
        // Generate Aggregations
        var aggregations = [Aggregator]()
        for combined in zip(
            ["cohort_1", "cohort_2", "success"],
            [sample1, sample2, successCriterion]
        ) {
            aggregations.append(
                .filtered(.init(
                    filter: combined.1.filter ?? Filter.empty,
                    aggregator: .thetaSketch(.init(
                        type: .thetaSketch,
                        name: combined.0,
                        fieldName: "clientUser"
                    ))
                ))
            )
        }
        
        // Generate Post-Agregations
        let postAggregations: [PostAggregator] = [
            .thetaSketchEstimate(.init(
                name: "cohort_1_success",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "cohort_1"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "success"
                        ))
                    ]
                ))
            )),
            .thetaSketchEstimate(.init(
                name: "cohort_2_success",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "cohort_2"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "success"
                        ))
                    ]
                ))
            )),
            .zscore2sample(.init(
                name: "zscore",
                sample1Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_1"
                )),
                successCount1: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_1_success"
                )),
                sample2Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_2"
                )),
                successCount2: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "cohort_2_success"
                ))
            )),
            .pvalue2tailedZtest(.init(
                name: "pvalue",
                zScore: .fieldAccess(.init(type: .fieldAccess, fieldName: "zscore"))
            ))
        ]
        
        // Combine query
        query.queryType = .groupBy
        // query.filter = queryFilter
        query.aggregations = aggregations
        query.postAggregations = postAggregations

        return query
    }
}
