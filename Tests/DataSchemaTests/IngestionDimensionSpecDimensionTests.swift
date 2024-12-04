@testable import DataTransferObjects
import XCTest

final class IngestionDimensionSpecDimensionTests: XCTestCase {
    let docsValueString = """
    { "name": "userId", "type": "long" }
    """
    .filter { !$0.isWhitespace }

    let docsValue = IngestionDimensionSpecDimension(type: .long, name: "userId", createBitmapIndex: nil, multiValueHandling: nil)

    let tdValueString = """
    {
        "createBitmapIndex": true,
        "multiValueHandling": "sorted_array",
        "name": "TelemetryDeck.Device.modelName",
        "type": "string"

    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = IngestionDimensionSpecDimension(
        type: .string,
        name: "TelemetryDeck.Device.modelName",
        createBitmapIndex: true,
        multiValueHandling: .sorted_array
    )

    let testedType = IngestionDimensionSpecDimension.self

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

