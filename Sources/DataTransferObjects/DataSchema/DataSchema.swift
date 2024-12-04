/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec#dataschema
public struct DataSchema: Codable, Hashable, Equatable {
    /// The dataSource is located in dataSchema → dataSource and is simply the name of the datasource that data will be written to. An example dataSource is:
    public let dataSource: String

    /// Responsible for configuring the primary timestamp
    public let timestampSpec: TimestampSpec?

    /// The metricsSpec is located in dataSchema → metricsSpec and is a list of aggregators to apply at ingestion time.
    ///
    /// This is most useful when rollup is enabled, since it's how you configure ingestion-time aggregation.
    public let metricsSpec: [Aggregator]?

    public let granularitySpec: GranularitySpec?

    public let transformSpec: TransformSpec?

    public let dimensionsSpec: IngestionDimensionSpec?
}
