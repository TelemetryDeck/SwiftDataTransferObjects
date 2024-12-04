@testable import DataTransferObjects
import XCTest

final class TransformSpecTests: XCTestCase {
    let docsValueString = """
    {
      "filter": {
        "dimension": "country",
        "type": "selector",
        "value": "SanSeriffe"
      },
      "transforms": [
        {  "expression": "upper(country)", "name": "countryUpper", "type": "expression" }
      ]
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = TransformSpec(
        transforms: [
            .init(type: "expression", name: "countryUpper", expression: "upper(country)")
        ],
        filter: .selector(.init(dimension: "country", value: "SanSeriffe"))
    )

    let tdValueString = """
    {
        "transforms": []
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = TransformSpec(transforms: [], filter: nil)

    let testedType = TransformSpec.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: docsValueString.data(using: .utf8)!)
        XCTAssertEqual(docsValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(docsValue)
        XCTAssertEqual(docsValueString, String(data: encodedValue, encoding: .utf8)!)
    }

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
