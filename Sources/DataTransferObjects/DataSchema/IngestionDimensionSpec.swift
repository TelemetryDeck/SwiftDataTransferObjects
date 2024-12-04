/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#dimensionsspec
public struct IngestionDimensionSpec: Codable, Hashable, Equatable {
    /// A list of dimension names or objects. You cannot include the same column in both dimensions and dimensionExclusions.
    ///
    /// If dimensions and spatialDimensions are both null or empty arrays, Druid treats all columns other than timestamp or metrics
    /// that do not appear in dimensionExclusions as String-typed dimension columns. See inclusions and exclusions for details.
    ///
    /// As a best practice, put the most frequently filtered dimensions at the beginning of the dimensions list. In this case, it
    /// would also be good to consider partitioning by those same dimensions.
    public let dimensions: [IngestionDimensionSpecDimension]

    /// The names of dimensions to exclude from ingestion. Only names are supported here, not objects.
    ///
    /// This list is only used if the dimensions and spatialDimensions lists are both null or empty arrays; otherwise it is ignored.
    ///  See inclusions and exclusions below for details.
    ///
    ///   https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#inclusions-and-exclusions
    public let dimensionExclusions: [String]?

    /// An array of spatial dimensions.
    public let spatialDimensions: [IngestionDimensionSpecSpatialDimension]?

    /// Note that this field only applies to string-based schema discovery where Druid ingests dimensions it discovers as strings.
    /// This is different from schema auto-discovery where Druid infers the type for data. You can set includeAllDimensions to true
    /// to ingest both explicit dimensions in the dimensions field and other dimensions that the ingestion task discovers from input
    /// data. In this case, the explicit dimensions will appear first in the order that you specify them, and the dimensions dynamically
    /// discovered will come after. This flag can be useful especially with auto schema discovery using flattenSpec. If this is not set
    /// and the dimensions field is not empty, Druid will ingest only explicit dimensions. If this is not set and the dimensions field
    /// is empty, all discovered dimensions will be ingested.
    public let includeAllDimensions: Bool?

    /// Configure Druid to use schema auto-discovery to discover some or all of the dimensions and types for your data. For any
    /// dimensions that aren't a uniform type, Druid ingests them as JSON. You can use this for native batch or streaming ingestion.
    public let useSchemaDiscovery: Bool?

    /// When set to true (the default), segments created by the ingestion job are sorted by {__time, dimensions[0], dimensions[1], ...}.
    /// When set to false, segments created by the ingestion job are sorted by {dimensions[0], dimensions[1], ...}.
    ///
    /// To include __time in the sort order when this parameter is set to false, you must include a dimension named __time with type long explicitly in the dimensions list.
    ///
    /// Setting this to false is an experimental feature; see Sorting for details.
    ///  https://druid.apache.org/docs/latest/ingestion/partitioning#sorting
    public let forceSegmentSortByTime: Bool?
}

public struct IngestionDimensionSpecDimension: Codable, Hashable, Equatable {
    public enum DimensionType: String, Codable, Hashable, Equatable {
        case auto
        case string
        case long
        case float
        case double
        case json
    }

    public enum MultiValueHandlingOption: String, Codable, Hashable, Equatable {
        case ARRAY
        case SORTED_ARRAY
        case SORTED_SET
    }

    public let type: DimensionType?
    public let name: String
    public let createBitmapIndex: Bool?
    public let multiValueHandling: MultiValueHandlingOption?
}

public struct IngestionDimensionSpecSpatialDimension: Codable, Hashable, Equatable {
    public let dimName: String
    public let dims: [String]?
}
