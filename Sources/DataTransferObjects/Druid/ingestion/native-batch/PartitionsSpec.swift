/// The primary partition for Druid is time. You can define a secondary partitioning method in the partitions spec. Use the partitionsSpec type that applies for your rollup method.
///
/// For perfect rollup, you can use:
///
/// * hashed partitioning based on the hash value of specified dimensions for each row
/// * single_dim based on ranges of values for a single dimension
/// * range based on ranges of values of multiple dimensions.
///
/// For best-effort rollup, use dynamic.
///
/// https://druid.apache.org/docs/latest/ingestion/native-batch/#partitionsspec
public indirect enum PartitionsSpec: Codable, Hashable, Equatable, Sendable {
    case dynamic(DynamicPartitionSpec)
    case hashed(HashedPartitionSpec)
    case singleDimension(SingleDimensionPartitionSpec)
    case range(RangePartitionSpec)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "dynamic":
            self = try .dynamic(DynamicPartitionSpec(from: decoder))
        case "hashed":
            self = try .hashed(HashedPartitionSpec(from: decoder))
        case "single_dim":
            self = try .singleDimension(SingleDimensionPartitionSpec(from: decoder))
        case "range":
            self = try .range(RangePartitionSpec(from: decoder))

        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .dynamic(dynamicSpec):
            try container.encode("dynamic", forKey: .type)
            try dynamicSpec.encode(to: encoder)
        case let .hashed(hashedSpec):
            try container.encode("hashed", forKey: .type)
            try hashedSpec.encode(to: encoder)
        case let .singleDimension(singleDimensionSpec):
            try container.encode("single_dim", forKey: .type)
            try singleDimensionSpec.encode(to: encoder)
        case let .range(rangeSpec):
            try container.encode("range", forKey: .type)
            try rangeSpec.encode(to: encoder)
        }
    }
}

/// With the dynamic partitioning, the parallel index task runs in a single phase spawning multiple worker tasks (type single_phase_sub_task), each of which creates segments.
///
/// How the worker task creates segments:
///
/// Whenever the number of rows in the current segment exceeds maxRowsPerSegment.
/// When the total number of rows in all segments across all time chunks reaches to maxTotalRows. At this point the task pushes all segments created so far to the deep storage and creates new ones.
public struct DynamicPartitionSpec: Codable, Hashable, Equatable, Sendable {
    public init(maxRowsPerSegment: Int? = nil, maxTotalRows: Int? = nil) {
        self.maxRowsPerSegment = maxRowsPerSegment
        self.maxTotalRows = maxTotalRows
    }

    /// Used in sharding. Determines how many rows are in each segment. (default is 5000000)
    public let maxRowsPerSegment: Int?

    /// Total number of rows across all segments waiting for being pushed. Used in determining when intermediate segment push should occur. (default is 20000000)
    public let maxTotalRows: Int?
}

/// The Parallel task with hash-based partitioning is similar to MapReduce. The task runs in up to three phases: partial dimension cardinality, partial segment generation and partial segment merge.
///
/// The partial dimension cardinality phase is an optional phase that only runs if numShards is not specified. The Parallel task splits the input data and assigns them to worker tasks based on the split hint spec. Each worker task (type partial_dimension_cardinality) gathers estimates of partitioning dimensions cardinality for each time chunk. The Parallel task will aggregate these estimates from the worker tasks and determine the highest cardinality across all of the time chunks in the input data, dividing this cardinality by targetRowsPerSegment to automatically determine numShards.
///
/// In the partial segment generation phase, just like the Map phase in MapReduce, the Parallel task splits the input data based on the split hint spec and assigns each split to a worker task. Each worker task (type partial_index_generate) reads the assigned split, and partitions rows by the time chunk from segmentGranularity (primary partition key) in the granularitySpec and then by the hash value of partitionDimensions (secondary partition key) in the partitionsSpec. The partitioned data is stored in local storage of the middle Manager or the indexer.
///
/// The partial segment merge phase is similar to the Reduce phase in MapReduce. The Parallel task spawns a new set of worker tasks (type partial_index_generic_merge) to merge the partitioned data created in the previous phase. Here, the partitioned data is shuffled based on the time chunk and the hash value of partitionDimensions to be merged; each worker task reads the data falling in the same time chunk and the same hash value from multiple Middle Manager/Indexer processes and merges them to create the final segments. Finally, they push the final segments to the deep storage at once.
public struct HashedPartitionSpec: Codable, Hashable, Equatable, Sendable {
    public init(
        numShards: Int? = nil,
        targetRowsPerSegment: Int? = nil,
        partitionDimensions: [String]? = nil
    ) {
        self.numShards = numShards
        self.targetRowsPerSegment = targetRowsPerSegment
        self.partitionDimensions = partitionDimensions
    }

    /// Directly specify the number of shards to create. If this is specified and intervals is specified in the granularitySpec, the index task can skip the determine intervals/partitions pass through the data. This property and targetRowsPerSegment cannot both be set.
    public let numShards: Int?

    /// A target row count for each partition. If numShards is left unspecified, the Parallel task will determine a partition count automatically such that each partition has a row count close to the target, assuming evenly distributed keys in the input data. A target per-segment row count of 5 million is used if both numShards and targetRowsPerSegment are null. Default is null (or 5,000,000 if both numShards and targetRowsPerSegment are null)
    public let targetRowsPerSegment: Int?

    /// The dimensions to partition on. Leave blank to select all dimensions.
    public let partitionDimensions: [String]?
}

/// Single-dimension range partitioning
///
/// Range partitioning has several benefits related to storage footprint and query performance.
///
/// The Parallel task will use one subtask when you set maxNumConcurrentSubTasks to 1.
///
/// When you use this technique to partition your data, segment sizes may be unequally distributed if the data in your partitionDimension is also unequally distributed. Therefore, to avoid imbalance in data layout, review the distribution of values in your source data before deciding on a partitioning strategy.
///
/// Range partitioning is not possible on multi-value dimensions. If the provided partitionDimension is multi-value, your ingestion job will report an error.
public struct SingleDimensionPartitionSpec: Codable, Hashable, Equatable, Sendable {
    public init(
        partitionDimension: String,
        targetRowsPerSegment: Int? = nil,
        maxRowsPerSegment: Int? = nil,
        assumeGrouped: Bool? = nil
    ) {
        self.partitionDimension = partitionDimension
        self.targetRowsPerSegment = targetRowsPerSegment
        self.maxRowsPerSegment = maxRowsPerSegment
        self.assumeGrouped = assumeGrouped
    }

    /// The dimension to partition on. Only rows with a single dimension value are allowed.
    public let partitionDimension: String

    /// A target row count for each partition. If numShards is left unspecified, the Parallel task will determine a partition count automatically such that each partition has a row count close to the target, assuming evenly distributed keys in the input data. A target per-segment row count of 5 million is used if both numShards and targetRowsPerSegment are null. Default is null (or 5,000,000 if both numShards and targetRowsPerSegment are null)
    public let targetRowsPerSegment: Int?

    /// Soft max for the number of rows to include in a partition.
    public let maxRowsPerSegment: Int?

    /// Assume that input data has already been grouped on time and dimensions. Ingestion will run faster, but may choose sub-optimal partitions if this assumption is violated.
    public let assumeGrouped: Bool?
}

/// Multi-dimension range partitioning
///
/// Range partitioning has several benefits related to storage footprint and query performance. Multi-dimension range partitioning improves over single-dimension range partitioning by allowing Druid to distribute segment sizes more evenly, and to prune on more dimensions.
///
/// Range partitioning is not possible on multi-value dimensions. If one of the provided partitionDimensions is multi-value, your ingestion job will report an error.
public struct RangePartitionSpec: Codable, Hashable, Equatable, Sendable {
    public init(
        partitionDimensions: [String],
        targetRowsPerSegment: Int? = nil,
        maxRowsPerSegment: Int? = nil,
        assumeGrouped: Bool? = nil
    ) {
        self.partitionDimensions = partitionDimensions
        self.targetRowsPerSegment = targetRowsPerSegment
        self.maxRowsPerSegment = maxRowsPerSegment
        self.assumeGrouped = assumeGrouped
    }

    /// An array of dimensions to partition on. Order the dimensions from most frequently queried to least frequently queried. For best results, limit your number of dimensions to between three and five dimensions.
    public let partitionDimensions: [String]

    /// Target number of rows to include in a partition, should be a number that targets segments of 500MB~1GB.
    public let targetRowsPerSegment: Int?

    /// Soft max for the number of rows to include in a partition.
    public let maxRowsPerSegment: Int?

    /// Assume that input data has already been grouped on time and dimensions. Ingestion will run faster, but may choose sub-optimal partitions if this assumption is violated.
    public let assumeGrouped: Bool?
}
