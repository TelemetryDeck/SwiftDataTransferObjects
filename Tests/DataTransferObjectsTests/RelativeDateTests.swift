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

    func testDateFromRelativeQuarter() throws {
        // Jan 12, 2026 is in Q1 2026
        // -1 quarter = -3 months → Oct 12, 2025 (Q4 2025)
        // Beginning of Q4 2025 = Oct 1, 2025
        let beginningOfLastQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: -1)
        let beginningOfLastQuarterAbsolute = Date(iso8601String: "2025-10-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfLastQuarterAbsolute, Date.from(relativeDate: beginningOfLastQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }

    func testDateFromRelativeQuarterOverYear() throws {
        // Jan 12, 2026 is in Q1 2026
        // -2 quarters = -6 months → Jul 12, 2025 (Q3 2025)
        // Beginning of Q3 2025 = Jul 1, 2025
        let beginningOfLastQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: -2)
        let beginningOfLastQuarterAbsolute = Date(iso8601String: "2025-07-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfLastQuarterAbsolute, Date.from(relativeDate: beginningOfLastQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }


    func testWeekBeginsOnMonday() throws {
        let beginningOfNextWeekRelative = RelativeDate(.beginning, of: .week, adding: 1)
        let beginningOfNextWeekAbsolute = Date.from(relativeDate: beginningOfNextWeekRelative)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: beginningOfNextWeekAbsolute)

        XCTAssertEqual("Monday", weekDay)
    }

    // MARK: - Comprehensive Quarter Tests

    func testQuarterEndCalculation() throws {
        // Jan 12, 2026 is in Q1 2026
        // End of current quarter (Q1 2026) = Mar 31, 2026 23:59:59
        let endOfCurrentQuarterRelative = RelativeDate(.end, of: .quarter, adding: 0)
        let endOfCurrentQuarterAbsolute = Date.from(relativeDate: endOfCurrentQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!)

        // Use UTC calendar for timezone-safe comparison
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: endOfCurrentQuarterAbsolute)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 31)
    }

    func testQuarterAddingPositiveOffset() throws {
        // Jan 12, 2026 is in Q1 2026
        // +1 quarter = +3 months → Apr 12, 2026 (Q2 2026)
        // Beginning of Q2 2026 = Apr 1, 2026
        let beginningOfNextQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: 1)
        let beginningOfNextQuarterAbsolute = Date(iso8601String: "2026-04-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfNextQuarterAbsolute, Date.from(relativeDate: beginningOfNextQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }

    func testQuarterAddingMultiplePositiveOffsets() throws {
        // Jan 12, 2026 is in Q1 2026
        // +4 quarters = +12 months → Jan 12, 2027 (Q1 2027)
        // Beginning of Q1 2027 = Jan 1, 2027
        let beginningOfFourQuartersAheadRelative = RelativeDate(.beginning, of: .quarter, adding: 4)
        let beginningOfFourQuartersAheadAbsolute = Date(iso8601String: "2027-01-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfFourQuartersAheadAbsolute, Date.from(relativeDate: beginningOfFourQuartersAheadRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }

    func testQuarterCurrentQuarter() throws {
        // Jan 12, 2026 is in Q1 2026
        // 0 quarters offset = stay in Q1 2026
        // Beginning of Q1 2026 = Jan 1, 2026
        let beginningOfCurrentQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: 0)
        let beginningOfCurrentQuarterAbsolute = Date(iso8601String: "2026-01-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfCurrentQuarterAbsolute, Date.from(relativeDate: beginningOfCurrentQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }

    func testQuarterFromMiddleOfQuarter() throws {
        // May 15, 2026 is in Q2 2026
        // -1 quarter = -3 months → Feb 15, 2026 (Q1 2026)
        // Beginning of Q1 2026 = Jan 1, 2026
        let beginningOfPreviousQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: -1)
        let beginningOfPreviousQuarterAbsolute = Date(iso8601String: "2026-01-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfPreviousQuarterAbsolute, Date.from(relativeDate: beginningOfPreviousQuarterRelative, originDate: Date(iso8601String: "2026-05-15T00:00:00.000Z")!))
    }

    func testQuarterFromEndOfQuarter() throws {
        // Mar 31, 2026 is in Q1 2026
        // -1 quarter = -3 months → Dec 31, 2025 (Q4 2025)
        // Beginning of Q4 2025 = Oct 1, 2025
        let beginningOfPreviousQuarterRelative = RelativeDate(.beginning, of: .quarter, adding: -1)
        let beginningOfPreviousQuarterAbsolute = Date(iso8601String: "2025-10-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfPreviousQuarterAbsolute, Date.from(relativeDate: beginningOfPreviousQuarterRelative, originDate: Date(iso8601String: "2026-03-31T00:00:00.000Z")!))
    }

    func testQuarterCrossingMultipleYears() throws {
        // Jan 12, 2026 is in Q1 2026
        // -5 quarters = -15 months → Oct 12, 2024 (Q4 2024)
        // Beginning of Q4 2024 = Oct 1, 2024
        let beginningOfFiveQuartersBackRelative = RelativeDate(.beginning, of: .quarter, adding: -5)
        let beginningOfFiveQuartersBackAbsolute = Date(iso8601String: "2024-10-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfFiveQuartersBackAbsolute, Date.from(relativeDate: beginningOfFiveQuartersBackRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!))
    }

    func testQuarterEndCrossingYear() throws {
        // Jan 12, 2026 is in Q1 2026
        // -1 quarter = -3 months → Oct 12, 2025 (Q4 2025)
        // End of Q4 2025 = Dec 31, 2025 23:59:59
        let endOfPreviousQuarterRelative = RelativeDate(.end, of: .quarter, adding: -1)
        let endOfPreviousQuarterAbsolute = Date.from(relativeDate: endOfPreviousQuarterRelative, originDate: Date(iso8601String: "2026-01-12T00:00:00.000Z")!)

        // Use UTC calendar for timezone-safe comparison
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: endOfPreviousQuarterAbsolute)
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 31)
    }

    func testQuarterFromQ3() throws {
        // Aug 15, 2025 is in Q3 2025
        // -2 quarters = -6 months → Feb 15, 2025 (Q1 2025)
        // Beginning of Q1 2025 = Jan 1, 2025
        let beginningOfTwoQuartersBackRelative = RelativeDate(.beginning, of: .quarter, adding: -2)
        let beginningOfTwoQuartersBackAbsolute = Date(iso8601String: "2025-01-01T00:00:00.000Z")!

        XCTAssertEqual(beginningOfTwoQuartersBackAbsolute, Date.from(relativeDate: beginningOfTwoQuartersBackRelative, originDate: Date(iso8601String: "2025-08-15T00:00:00.000Z")!))
    }
}
