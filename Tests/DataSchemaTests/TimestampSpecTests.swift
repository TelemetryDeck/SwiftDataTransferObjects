@testable import DataTransferObjects
import XCTest

final class TimestampSpecTests: XCTestCase {
    let docsValueString = """
    {
      "column": "timestamp",
      "format": "auto"
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = TimestampSpec(column: "timestamp", format: .auto, missingValue: nil)

    let tdValueString = """
    {
        "column": "receivedAt",
        "format": "iso",
        "missingValue": "blob"
      }
    """
    .filter { !$0.isWhitespace }

    let tdValue = TimestampSpec(column: "receivedAt", format: .iso, missingValue: "blob")

    let testedType = TimestampSpec.self

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
