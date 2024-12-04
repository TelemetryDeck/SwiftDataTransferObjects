@testable import DataTransferObjects
import XCTest

final class InputFormatTests: XCTestCase {
    let docsValueString = """
    {
        "type": "json"
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = InputFormat(type: .json, keepNullColumns: nil)

    let tdValueString = """
    {
        "keepNullColumns": false,
        "type": "json"
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = InputFormat(type: .json, keepNullColumns: false)

    let testedType = InputFormat.self

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
