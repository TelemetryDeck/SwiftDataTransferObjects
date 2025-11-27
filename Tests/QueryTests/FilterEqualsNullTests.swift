import DataTransferObjects
import XCTest

class FilterEqualsNullTests: XCTestCase {
    func testFilterEqualsStringValue() throws {
        let filterJSON = """
        {
            "column": "name",
            "matchValue": "John",
            "matchValueType": "STRING",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "name",
                matchValueType: .string,
                matchValue: .string("John")
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterEqualsIntValue() throws {
        let filterJSON = """
        {
            "column": "age",
            "matchValue": 42,
            "matchValueType": "LONG",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "age",
                matchValueType: .long,
                matchValue: .int(42)
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterEqualsDoubleValue() throws {
        let filterJSON = """
        {
            "column": "score",
            "matchValue": 3.14,
            "matchValueType": "DOUBLE",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "score",
                matchValueType: .double,
                matchValue: .double(3.14)
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterEqualsArrayStringValue() throws {
        let filterJSON = """
        {
            "column": "tags",
            "matchValue": ["swift", "ios", "macos"],
            "matchValueType": "ARRAY<STRING>",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "tags",
                matchValueType: .arrayString,
                matchValue: .arrayString(["swift", "ios", "macos"])
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterEqualsArrayIntValue() throws {
        let filterJSON = """
        {
            "column": "numbers",
            "matchValue": [1, 2, 3],
            "matchValueType": "ARRAY<LONG>",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "numbers",
                matchValueType: .arrayLong,
                matchValue: .arrayInt([1, 2, 3])
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterEqualsArrayDoubleValue() throws {
        let filterJSON = """
        {
            "column": "values",
            "matchValue": [1.1, 2.2, 3.3],
            "matchValueType": "ARRAY<DOUBLE>",
            "type": "equals"
        }
        """
        .filter { !$0.isWhitespace }

        let filterEquals = Filter.equals(
            FilterEquals(
                column: "values",
                matchValueType: .arrayDouble,
                matchValue: .arrayDouble([1.1, 2.2, 3.3])
            )
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterEquals)

        XCTAssertEqual(filterEquals, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }

    func testFilterNull() throws {
        let filterJSON = """
        {
            "column": "description",
            "type": "null"
        }
        """
        .filter { !$0.isWhitespace }

        let filterNull = Filter.null(
            FilterNull(column: "description")
        )

        let decodedFilter = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: filterJSON.data(using: .utf8)!
        )

        let encodedFilter = try JSONEncoder.telemetryEncoder.encode(filterNull)

        XCTAssertEqual(filterNull, decodedFilter)
        XCTAssertEqual(filterJSON, String(data: encodedFilter, encoding: .utf8))
    }
}
