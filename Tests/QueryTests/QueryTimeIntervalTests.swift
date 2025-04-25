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

    func testTimeSegmentsWithGranularity() throws {
        let timeInterval = QueryTimeInterval(
            beginningDate: Date(iso8601String: "2022-07-28T17:21:00.000Z")!,
            endDate: Date(iso8601String: "2022-08-03T11:30:00.000Z")!
        )
        let granularity = QueryGranularity.day
        let segments = try timeInterval.timeSegments(with: granularity)
        XCTAssertEqual(
            segments,
            [
                .init(beginningDate: .init(iso8601String: "2022-07-28T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-29T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-30T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-31T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-01T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-02T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-03T00:00:00.000Z")!, duration: .day),
            ]
        )
    }

    func testQueryTimeIntervalsContainerTimeSegments() throws {
        let timeIntervalContainer = QueryTimeIntervalsContainer(type: .intervals, intervals: [
            QueryTimeInterval(
                beginningDate: Date(iso8601String: "2022-07-28T17:21:00.000Z")!,
                endDate: Date(iso8601String: "2022-08-01T11:30:00.000Z")!
            ),
            QueryTimeInterval(
                beginningDate: Date(iso8601String: "2022-07-29T17:21:00.000Z")!,
                endDate: Date(iso8601String: "2022-08-03T11:30:00.000Z")!
            ),
        ])

        let granularity = QueryGranularity.day
        let segments = try timeIntervalContainer.timeSegments(with: granularity)
        XCTAssertEqual(
            segments,
            [
                .init(beginningDate: .init(iso8601String: "2022-07-28T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-29T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-30T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-07-31T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-01T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-02T00:00:00.000Z")!, duration: .day),
                .init(beginningDate: .init(iso8601String: "2022-08-03T00:00:00.000Z")!, duration: .day),
            ]
        )
    }

    func testQueryTimeIntervalsContainerInitWithTimeSegments() throws {
        let timeIntervalContainer = try QueryTimeIntervalsContainer(type: .intervals, timeSegments: [
            .init(beginningDate: .init(iso8601String: "2022-07-28T00:00:00.000Z")!, duration: .day),
            .init(beginningDate: .init(iso8601String: "2022-07-29T00:00:00.000Z")!, duration: .day),
            // missing a day on purpose
            .init(beginningDate: .init(iso8601String: "2022-07-31T00:00:00.000Z")!, duration: .day),
            .init(beginningDate: .init(iso8601String: "2022-08-01T00:00:00.000Z")!, duration: .day),
            .init(beginningDate: .init(iso8601String: "2022-08-02T00:00:00.000Z")!, duration: .day),
            .init(beginningDate: .init(iso8601String: "2022-08-03T00:00:00.000Z")!, duration: .day),
        ])

        XCTAssertEqual(
            timeIntervalContainer.intervals,
            [
                // Intervals' beginnings are inclusive, and the endings are exclusive
                .init(
                    beginningDate: .init(iso8601String: "2022-07-28T00:00:00.000Z")!,
                    endDate: .init(iso8601String: "2022-07-30T00:00:00.000Z")!
                ),

                .init(
                    beginningDate: .init(iso8601String: "2022-07-31T00:00:00.000Z")!,
                    endDate: .init(iso8601String: "2022-08-04T00:00:00.000Z")!
                ),
            ]
        )
    }
}
