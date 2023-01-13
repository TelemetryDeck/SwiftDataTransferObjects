@testable import DataTransferObjects
import XCTest

final class QueryTimeIntervalTests: XCTestCase {
    let exampleData = """
    {
      "type": "intervals",
      "intervals": [
        "-146136543-09-08T08:23:32.096Z/146140482-04-24T15:36:27.903Z"
      ]
    }
    """
    
    .filter { !$0.isWhitespace }
    .data(using: .utf8)!
    

    func testDecodingQueryTimeInterval() throws {
        _ = try JSONDecoder.telemetryDecoder.decode(QueryTimeIntervalsContainer.self, from: exampleData)
    }
}
