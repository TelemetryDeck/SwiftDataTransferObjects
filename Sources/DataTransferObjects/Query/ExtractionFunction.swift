import Foundation

/// Extraction functions define the transformation applied to each dimension value.
public indirect enum ExtractionFunction: Codable, Equatable, Hashable, Sendable {
    case regex(RegularExpressionExtractionFunction)
    case inlineLookup(InlineLookupExtractionFunction)
    case registeredLookup(RegisteredLookupExtractionFunction)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "regex":
            self = try .regex(RegularExpressionExtractionFunction(from: decoder))
        case "lookup":
            self = try .inlineLookup(InlineLookupExtractionFunction(from: decoder))
        case "registeredLookup":
            self = try .registeredLookup(RegisteredLookupExtractionFunction(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .regex(regexFunction):
            try container.encode("regex", forKey: .type)
            try regexFunction.encode(to: encoder)
        case let .inlineLookup(inlineLookupFunction):
            try container.encode("lookup", forKey: .type)
            try inlineLookupFunction.encode(to: encoder)
        case let .registeredLookup(registeredLookupFunction):
            try container.encode("registeredLookup", forKey: .type)
            try registeredLookupFunction.encode(to: encoder)
        }
    }
}

/// Returns the first matching group for the given regular expression. If there is no match,
/// it returns the dimension value as is.
public struct RegularExpressionExtractionFunction: Codable, Equatable, Hashable, Sendable {
    public init(expr: String, index: Int = 1, replaceMissingValue: Bool = false, replaceMissingValueWith: String? = nil) {
        self.expr = expr
        self.index = index
        self.replaceMissingValue = replaceMissingValue
        self.replaceMissingValueWith = replaceMissingValueWith
    }

    /// The regular expression to match.
    ///
    /// For example, using `(\\w\\w\\w).*` will transform 'Monday', 'Tuesday', 'Wednesday' into 'Mon', 'Tue', 'Wed'.
    public let expr: String

    /// The group to extract, default 1
    public let index: Int

    /// If the replaceMissingValue property is true, the extraction function will transform dimension values that do not match the regex pattern to a user-specified String. Default value is false.
    public let replaceMissingValue: Bool

    /// Sets the String that unmatched dimension values will be replaced with.
    ///
    /// The replaceMissingValueWith property sets the String that unmatched dimension values will
    /// be replaced with, if replaceMissingValue is true. If replaceMissingValueWith is not
    /// specified, unmatched dimension values will be replaced with nulls.
    public let replaceMissingValueWith: String?
}

/// Allows you to specify an inline lookup map where dimension values are (optionally) replaced with new values.
///
/// A property of retainMissingValue and replaceMissingValueWith can be specified at query time to hint how to
/// handle missing values. Setting replaceMissingValueWith to "" has the same effect as setting it to null or
/// omitting the property. Setting retainMissingValue to true will use the dimension's original value if it is
/// not found in the lookup. The default values are replaceMissingValueWith = null and
/// retainMissingValue = false which causes missing values to be treated as missing.
///
/// It is illegal to set retainMissingValue = true and also specify a replaceMissingValueWith.
public struct InlineLookupExtractionFunction: Codable, Equatable, Hashable, Sendable {
    public init(lookupMap: [String: String], retainMissingValue: Bool = true, injective: Bool = true, replaceMissingValueWith: String? = nil) {
        lookup = Lookup(map: lookupMap)
        self.retainMissingValue = retainMissingValue
        self.injective = injective
        self.replaceMissingValueWith = replaceMissingValueWith
    }

    public struct Lookup: Codable, Equatable, Hashable, Sendable {
        public init(type: String = "map", map: [String: String]) {
            self.type = type
            self.map = map
        }

        public let type: String
        public let map: [String: String]
    }

    public let lookup: Lookup
    public let retainMissingValue: Bool
    public let injective: Bool
    public let replaceMissingValueWith: String?
}

/// The "registeredLookup" extraction function lets you refer to a lookup that has been registered in the cluster-wide configuration.
public struct RegisteredLookupExtractionFunction: Codable, Equatable, Hashable, Sendable {
    public init(lookup: String, retainMissingValue: Bool) {
        self.lookup = lookup
        self.retainMissingValue = retainMissingValue
    }

    public let lookup: String
    public let retainMissingValue: Bool
}
