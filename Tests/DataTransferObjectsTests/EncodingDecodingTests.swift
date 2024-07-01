@testable import DataTransferObjects
import XCTest

final class EncodingDecodingTests: XCTestCase {
    func testAppSettingsEncoding() throws {
        let input = DTOv2.AppSettings(displayMode: .app)

        let output = try JSONEncoder.telemetryEncoder.encode(input)

        let expectedOutput = """
        {
            "displayMode": "app",
            "showExampleData": false,
            "startOfWeek": "sunday"
        }
        """
        .filter { !$0.isWhitespace }

        XCTAssertEqual(expectedOutput, String(data: output, encoding: .utf8)!)
    }

    func testAppSettingsDecoding() throws {
        let input = """
        {
            "displayMode": "website"
        }
        """
        .filter { !$0.isWhitespace }

        let output = try JSONDecoder.telemetryDecoder.decode(DTOv2.AppSettings.self, from: input.data(using: .utf8)!)

        XCTAssertEqual(output.displayMode, .website)
    }

    func testAppSettingsDecodingMore() throws {
        let input = """
        {
            "displayMode": "website",
            "showExampleData": false
        }
        """
        .filter { !$0.isWhitespace }

        let output = try JSONDecoder.telemetryDecoder.decode(DTOv2.AppSettings.self, from: input.data(using: .utf8)!)

        XCTAssertEqual(output.displayMode, .website)
    }

    func testAppSettingsDecodingMoreMore() throws {
        let input = """
        {
            "displayMode": "website",
            "showExampleData": false,
            "colorScheme": "#f00 #0f0 #00f"
        }
        """
        .filter { !$0.isWhitespace }

        let output = try JSONDecoder.telemetryDecoder.decode(DTOv2.AppSettings.self, from: input.data(using: .utf8)!)

        XCTAssertEqual(output.displayMode, .website)
    }
}
