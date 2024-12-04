public struct ValueFormatter: Codable, Hashable, Equatable {
    public let locale: String?
    public let options: ValueFormatterOptions?
}

/// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat#currencydisplay
public struct ValueFormatterOptions: Codable, Hashable, Equatable {
    public let style: ValueFormatterStyle?

    public let currency: String?
    public let currencyDisplay: ValueFormatterCurrencyDisplay?
    public let currencySign: ValueFormatterCurrencySign?

    public let unit: String?
    public let unitDisplay: ValueFormatterUnitDisplay?

    public let minimumIntegerDigits: Int?
    public let minimumFractionDigits: Int?
    public let maximumFractionDigits: Int?
    public let minimumSignificantDigits: Int?
    public let maximumSignificantDigits: Int?
    public let roundingPriority: ValueFormatterRoundingPriority?
    public let roundingIncrement: Int?
    public let roundingMode: ValueFormatterRoundingMode?
    public let trailingZeroDisplay: ValueFormatterTrailingZeroDisplay?

    public let notation: ValueFormatterNotation?
    public let compactDisplay: ValueFormatterCompactDisplay?
    public let useGrouping: ValueFormatterUseGrouping?
    public let signDisplay: ValueFormatterSignDisplay?
}

public enum ValueFormatterStyle: String, Codable, Hashable, Equatable {
    case decimal
    case currency
    case percent
    case unit
}

public enum ValueFormatterCurrencyDisplay: String, Codable, Hashable, Equatable {
    case code
    case symbol
    case narrowSymbol
    case name
}

public enum ValueFormatterCurrencySign: String, Codable, Hashable, Equatable {
    case standard
    case accounting
}

public enum ValueFormatterUnitDisplay: String, Codable, Hashable, Equatable {
    case short
    case narrow
    case long
}

public enum ValueFormatterRoundingPriority: String, Codable, Hashable, Equatable {
    case auto
    case morePrecision
    case lessPrecision
}

public enum ValueFormatterRoundingMode: Codable, Hashable, Equatable {
    case ceil
    case floor
    case expand
    case trunc
    case halfCeil
    case halfFloor
    case halfExpand
    case halfTrunc
    case halfEven
}

public enum ValueFormatterTrailingZeroDisplay: String, Codable, Hashable, Equatable {
    case auto
    case stripIfInteger
}

public enum ValueFormatterNotation: String, Codable, Hashable, Equatable {
    case standard
    case scientific
    case engineering
    case compact
}

public enum ValueFormatterCompactDisplay: String, Codable, Hashable, Equatable {
    case short
    case long
}

public enum ValueFormatterUseGrouping: String, Codable, Hashable, Equatable {
    case always
    case auto
    case min2
    case `true`
    case `false`
}

public enum ValueFormatterSignDisplay: String, Codable, Hashable, Equatable {
    case auto
    case always
    case exceptZero
    case negative
    case never
}
