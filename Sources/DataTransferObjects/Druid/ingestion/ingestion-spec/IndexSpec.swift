/// Defines segment storage format options to use at indexing time
///
/// https://druid.apache.org/docs/latest/ingestion/ingestion-spec/#indexspec
public struct IndexSpec: Codable, Hashable, Equatable, Sendable {
    public init(
        bitmap: IndexSpecBitmap? = nil,
        dimensionCompression: IndexSpec.CompressionType? = nil,
        stringDictionaryEncoding: StringDictionaryEncoding? = nil,
        metricCompression: IndexSpec.CompressionType? = nil,
        longEncoding: IndexSpec.LongEncodingType? = nil,
        complexMetricCompression: IndexSpec.CompressionType? = nil,
        jsonCompression: IndexSpec.CompressionType? = nil
    ) {
        self.bitmap = bitmap
        self.dimensionCompression = dimensionCompression
        self.stringDictionaryEncoding = stringDictionaryEncoding
        self.metricCompression = metricCompression
        self.longEncoding = longEncoding
        self.complexMetricCompression = complexMetricCompression
        self.jsonCompression = jsonCompression
    }

    public enum CompressionType: String, Codable, CaseIterable, Sendable {
        case lz4
        case lzf
        case zstd
        case uncompressed
        case none
    }

    public enum LongEncodingType: String, Codable, CaseIterable, Sendable {
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

public struct IndexSpecBitmap: Codable, Hashable, Equatable, Sendable {
    public init(type: IndexSpecBitmap.IndexSpecBitmapType) {
        self.type = type
    }

    public enum IndexSpecBitmapType: String, Codable, CaseIterable, Sendable {
        case roaring
        case concise
    }

    public let type: IndexSpecBitmapType
}

public struct StringDictionaryEncoding: Codable, Hashable, Equatable, Sendable {
    public init(
        type: StringDictionaryEncoding.StringDictionaryEncodingType,
        bucketSize: Int? = nil,
        formatVersion: Int? = nil
    ) {
        self.type = type
        self.bucketSize = bucketSize
        self.formatVersion = formatVersion
    }

    public enum StringDictionaryEncodingType: String, Codable, CaseIterable, Sendable {
        case utf8
        case frontCoded
    }

    public let type: StringDictionaryEncodingType
    public let bucketSize: Int?
    public let formatVersion: Int?
}
