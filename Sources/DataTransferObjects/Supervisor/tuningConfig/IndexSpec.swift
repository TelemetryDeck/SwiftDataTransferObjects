/// Defines segment storage format options to use at indexing time
///
/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#indexspec
public struct IndexSpec: Codable, Hashable, Equatable {
    public enum CompressionType: String, Codable, CaseIterable {
        case lz4
        case lzf
        case zstd
        case uncompressed
        case none
    }

    public enum LongEncodingType: String, Codable, CaseIterable {
        case longs
        case auto
    }

    public let bitmap: IndexSpecBitmap?
    public let dimensionCompression: CompressionType?
    public let stringDictionaryEncoding: StringDictionaryEncoding?
    public let metricCompression: CompressionType?
    public let longEncoding: LongEncodingType?
    public let complexMetricCompression: CompressionType?
    public let jsonCompression: CompressionType?
}

public struct IndexSpecBitmap: Codable, Hashable, Equatable {
    public enum IndexSpecBitmapType: String, Codable, CaseIterable {
        case roaring
        case concise
    }

    public let type: IndexSpecBitmapType
}

public struct StringDictionaryEncoding: Codable, Hashable, Equatable {
    public enum StringDictionaryEncodingType: String, Codable, CaseIterable {
        case utf8
        case frontCoded
    }

    public let type: StringDictionaryEncodingType
    public let bucketSize: Int?
    public let formatVersion: Int?
}
