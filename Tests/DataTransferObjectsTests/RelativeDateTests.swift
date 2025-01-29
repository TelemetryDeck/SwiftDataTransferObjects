@testable import DataTransferObjects
import XCTest

final class RelativeDateTests: XCTestCase {
    func testParseRelativeDate() throws {
        let beginningOfLastMonth = try decoded(json: """
        {
            "component": "month",
            "offset": -1,
            "position": "beginning"
        }
        """)

        XCTAssertEqual(beginningOfLastMonth.component, .month)
        XCTAssertEqual(beginningOfLastMonth.offset, -1)
        XCTAssertEqual(beginningOfLastMonth.position, .beginning)

        let endOfThisMonth = try decoded(json: """
        {
            "component": "month",
            "offset": 0,
            "position": "end"
        }
        """)

        XCTAssertEqual(endOfThisMonth.component, .month)
        XCTAssertEqual(endOfThisMonth.offset, 0)
        XCTAssertEqual(endOfThisMonth.position, .end)

        let beginningOfNextWeek = try decoded(json: """
        {
            "component": "week",
            "offset": 1,
            "position": "beginning"
        }
        """)

        XCTAssertEqual(beginningOfNextWeek.component, .week)
        XCTAssertEqual(beginningOfNextWeek.offset, 1)
        XCTAssertEqual(beginningOfNextWeek.position, .beginning)

        let endOfToday = try decoded(json: """
        {
            "component": "day",
            "offset": 0,
            "position": "end"
        }
        """)

        XCTAssertEqual(endOfToday.component, .day)
        XCTAssertEqual(endOfToday.offset, 0)
        XCTAssertEqual(endOfToday.position, .end)

        let in30Hours = try decoded(json: """
        {
            "component": "hour",
            "offset": 30,
            "position": "beginning"
        }
        """)

        XCTAssertEqual(in30Hours.component, .hour)
        XCTAssertEqual(in30Hours.offset, 30)
        XCTAssertEqual(in30Hours.position, .beginning)
    }

    private func decoded(json: String) throws -> RelativeDate {
        let data = json
            .filter { !$0.isWhitespace }
            .data(using: .utf8)!
        return try JSONDecoder.telemetryDecoder.decode(RelativeDate.self, from: data)
    }

    func testParseRelativeTimeInterval() throws {
        let relativeTimeIntervals = """
        [
            {
                "beginningDate": {
                    "component": "month",
                    "offset": -1,
                    "position": "beginning"
                },
                "endDate": {
                    "component": "month",
                    "offset": 0,
                    "position": "end"
                }
            }
        ]
        """
        .filter { !$0.isWhitespace }
        .data(using: .utf8)!

        let decodedIntervals = try JSONDecoder.telemetryDecoder.decode([RelativeTimeInterval].self, from: relativeTimeIntervals)

        XCTAssertEqual(decodedIntervals.count, 1)
        XCTAssertEqual(decodedIntervals.first?.beginningDate.component, .month)
        XCTAssertEqual(decodedIntervals.first?.endDate.position, .end)
    }

    func testEncodeRelativeTimeIntervals() throws {
        let relativeTimeIntervals = [
            RelativeTimeInterval(
                beginningDate: RelativeDate(.beginning, of: .month, adding: -1),
                endDate: RelativeDate(.end, of: .month, adding: 0)
            ),
        ]

        let expectedOutput = """
        [
            {
                "beginningDate": {
                    "component": "month",
                    "offset": -1,
                    "position": "beginning"
                },
                "endDate": {
                    "component": "month",
                    "offset": 0,
                    "position": "end"
                }
            }
        ]
        """
        .filter { !$0.isWhitespace }

        let encodedIntervals = try JSONEncoder.telemetryEncoder.encode(relativeTimeIntervals)
        let encodedIntervalsString = String(data: encodedIntervals, encoding: .utf8)

        XCTAssertEqual(encodedIntervalsString, expectedOutput)
    }

    func testDateFromRelativeDate() throws {
        let beginningOfLastMonthRelative = RelativeDate(.beginning, of: .month, adding: -1)
        let beginningOfLastMonthAbsolute = Date().calendar.date(byAdding: .month, value: -1, to: Date())!.beginning(of: .month)

        XCTAssertEqual(beginningOfLastMonthAbsolute, Date.from(relativeDate: beginningOfLastMonthRelative))

        let endOfThisMonthRelative = RelativeDate(.end, of: .month, adding: 0)
        let endOfThisMonthAbsolute = Date().end(of: .month)

        XCTAssertEqual(endOfThisMonthAbsolute, Date.from(relativeDate: endOfThisMonthRelative))

        let beginningOfNextWeekRelative = RelativeDate(.beginning, of: .week, adding: 1)
        let beginningOfNextWeekAbsolute = Date().calendar.date(byAdding: .weekOfYear, value: 1, to: Date())!.beginning(of: .weekOfYear)!

        XCTAssertEqual(beginningOfNextWeekAbsolute, Date.from(relativeDate: beginningOfNextWeekRelative))

        let endOfTodayRelative = RelativeDate(.end, of: .day, adding: 0)
        let endOfTodayAbsolute = Date().end(of: .day)

        XCTAssertEqual(endOfTodayAbsolute, Date.from(relativeDate: endOfTodayRelative))

        let in30HoursRelative = RelativeDate(.beginning, of: .hour, adding: 30)
        let in30HoursAbsolute = Date().startOfHour.adding(.hour, value: 30).startOfHour

        XCTAssertEqual(in30HoursAbsolute, Date.from(relativeDate: in30HoursRelative))
    }

    func testWeekBeginsOnMonday() throws {
        let beginningOfNextWeekRelative = RelativeDate(.beginning, of: .week, adding: 1)
        let beginningOfNextWeekAbsolute = Date.from(relativeDate: beginningOfNextWeekRelative)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: beginningOfNextWeekAbsolute)

        XCTAssertEqual("Monday", weekDay)
    }
}
