@testable import DataTransferObjects
import XCTest

final class ChartDefinitionTests: XCTestCase {
    func testDataSectionDecoding() {
        let exampleData = """
        {
            "x":"x",
            "columns": [
                ["x","2013-01-01", "2013-01-02", "2013-01-03", "2013-01-04", "2013-01-05", "2013-01-06"],
                ["data1","30", "200", "100", "400", "150", "250"],
            ]
        }
        """
        .data(using: .utf8)!

        XCTAssertNoThrow(try JSONDecoder.telemetryDecoder.decode(ChartDefinitionDTO.DataSection.self, from: exampleData))
    }

    func testDataSectionEncoding() throws {
        let exampleDataSection = ChartDefinitionDTO.DataSection(x: "x", xFormat: nil, columns: [])

        let expectedResult = """
        {"columns":[],"x":"x"}
        """

        XCTAssertEqual(String(data: try JSONEncoder.telemetryEncoder.encode(exampleDataSection), encoding: .utf8)!, expectedResult)
    }

    func testColumnEncoding() throws {
        let exampleColumn = ChartDefinitionDTO.DataSection.Column(label: "data1", data: ["12", "31", nil, "42"])

        let expectedResult = """
        ["data1","12","31",null,"42"]
        """

        XCTAssertEqual(String(data: try JSONEncoder.telemetryEncoder.encode(exampleColumn), encoding: .utf8)!, expectedResult)
    }

    func testColumnDecoding() throws {
        let expectedResult = ChartDefinitionDTO.DataSection.Column(label: "data1", data: ["12", "31", nil, "42"])

        let testData = """
        ["data1", "12", "31", null, "42"]
        """
        .data(using: .utf8)!

        XCTAssertEqual(try JSONDecoder.telemetryDecoder.decode(ChartDefinitionDTO.DataSection.Column.self, from: testData), expectedResult)
    }
}
