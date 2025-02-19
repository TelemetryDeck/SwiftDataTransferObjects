/// Marks an aggregator as needing precompilation before it can be used in a query.
///
/// Some aggregators require precompilation before they can be used in a query. This is because
/// they are addons introduced by TQL and not understood by Druid. These aggregators must be
/// converted into a set of druid native aggregators and post aggregators before they can be used
/// in a query.
///
/// Implement this protocol on your aggregator to indicate that it needs precompilation and return
/// the set of native aggregators and post aggregators that should be used in place of this
/// aggregator.
public protocol PrecompilableAggregator {
    func precompile() -> (aggregators: [Aggregator], postAggregators: [PostAggregator])
}
