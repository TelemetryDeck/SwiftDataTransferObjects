@testable import DataTransferObjects
import XCTest

final class IdleConfigTests: XCTestCase {
    let tdValueString = """
    {
        "enabled": true,
        "inactiveAfterMillis": 10000
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = IdleConfig(enabled: true, inactiveAfterMillis: 10000)

    let testedType = IdleConfig.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
