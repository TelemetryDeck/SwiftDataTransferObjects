@testable import DataTransferObjects
import XCTest

final class SupervisorTests: XCTestCase {
    let tdValueString = """
    {
      "type": "kinesis",
      "context": null,
      "suspended": false
    }
    """
    .filter { !$0.isWhitespace }

    let testedType = Supervisor.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(decodedValue.suspended, false)
    }
}
