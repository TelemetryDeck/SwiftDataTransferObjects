import Foundation

public enum StringComparators: String, Codable, Equatable, Hashable {
    /// Sorts values by converting Strings to their UTF-8 byte array representations and comparing lexicographically, byte-by-byte.
    case lexicographic

    /// Suitable for strings with both numeric and non-numeric content, e.g.: "file12 sorts after file2"
    case alphanumeric

    /// Sorts values as numbers, supports integers and floating point values. Negative values are supported.
    case numeric

    /// Sorts values by their string lengths. When there is a tie, this comparator falls back to using the String compareTo method.
    case strlen

    /// Sorts values as versions, e.g.: "10.0 sorts after 9.0", "1.0.0-SNAPSHOT sorts after 1.0.0".
    case version
}
