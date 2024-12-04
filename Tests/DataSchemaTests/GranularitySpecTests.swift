@testable import DataTransferObjects
import XCTest

final class GranularitySpecTests: XCTestCase {
    let docsValueString = """
    {
      "intervals": [
        "2013-08-31/2013-09-01"
      ],
      "queryGranularity": "none",
      "rollup": true,
      "segmentGranularity": "day"
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = GranularitySpec(
        type: nil,
        segmentGranularity: .day,
        queryGranularity: QueryGranularity.none,
        rollup: true,
        intervals: ["2013-08-31/2013-09-01"]
    )

    let tdValueString = """
    {
        "intervals": [],
        "queryGranularity": "hour",
        "rollup": true,
        "segmentGranularity": "day",
        "type": "uniform"
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = GranularitySpec(type: .uniform, segmentGranularity: .day, queryGranularity: .hour, rollup: true, intervals: [])

    let testedType = GranularitySpec.self

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
