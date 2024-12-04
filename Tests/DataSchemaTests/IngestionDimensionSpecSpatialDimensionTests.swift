@testable import DataTransferObjects
import XCTest

final class IngestionDimensionSpecSpatialDimensionTests: XCTestCase {
    let docsValueString = """
    {
      "dimName": "coordinates",
      "dims": [
        "x",
        "y"
      ]
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = IngestionDimensionSpecSpatialDimension(dimName: "coordinates", dims: ["x", "y"])

    let testedType = IngestionDimensionSpecSpatialDimension.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: docsValueString.data(using: .utf8)!)
        XCTAssertEqual(docsValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(docsValue)
        XCTAssertEqual(docsValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
