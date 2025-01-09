//
//  HavingTests.swift
//  DataTransferObjects
//
//  Created by Daniel Jilg on 09.01.25.
//

import DataTransferObjects
import XCTest

class HavingTests: XCTestCase {
    func testCustomQuery() throws {
        let customQuery = CustomQuery(
            queryType: .groupBy,
            dataSource: "sample_datasource",
            having: .equalTo(.init(aggregation: "test", value: 12))
        )

        let encodedCustomQuery = """
        {
            "dataSource": "sample_datasource",
            "having": {
                "aggregation": "test",
                "type": "equalTo",
                "value": 12
            },
            "queryType": "groupBy"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(customQuery)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedCustomQuery)

        let decoded = try JSONDecoder.telemetryDecoder.decode(CustomQuery.self, from: encoded)
        XCTAssertEqual(customQuery, decoded)
    }

    func testQueryFilter() throws {
        let havingSpec = HavingSpec.filter(.init(filter: .selector(.init(dimension: "test", value: "true"))))

        let encodedHavingSpec = """
        {
            "filter": {
                "dimension": "test",
                "type": "selector",
                "value": "true"
            },
            "type": "filter"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testEqualTo() throws {
        let havingSpec = HavingSpec.equalTo(.init(aggregation: "test", value: 12))

        let encodedHavingSpec = """
        {
            "aggregation": "test",
            "type": "equalTo",
            "value": 12
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testGreaterThan() throws {
        let havingSpec = HavingSpec.greaterThan(.init(aggregation: "test", value: 12))

        let encodedHavingSpec = """
        {
            "aggregation": "test",
            "type": "greaterThan",
            "value": 12
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testLessThan() throws {
        let havingSpec = HavingSpec.lessThan(.init(aggregation: "test", value: 12))

        let encodedHavingSpec = """
        {
            "aggregation": "test",
            "type": "lessThan",
            "value": 12
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testDimensionSelector() throws {
        let havingSpec = HavingSpec.dimensionSelector(.init(dimension: "test", value: "itsATest"))

        let encodedHavingSpec = """
        {
            "dimension": "test",
            "type": "dimSelector",
            "value": "itsATest"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testAnd() throws {
        let havingSpec = HavingSpec.and(.init(havingSpecs: [
            .equalTo(.init(aggregation: "test", value: 12)),
            .dimensionSelector(.init(dimension: "test", value: "itsATest"))
        ]))

        let encodedHavingSpec = """
        {
            "havingSpecs": [
                {
                    "aggregation": "test",
                    "type": "equalTo",
                    "value": 12
                },
                {
                    "dimension": "test",
                    "type": "dimSelector",
                    "value": "itsATest"
                }
            ],
            "type": "and"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testOr() throws {
        let havingSpec = HavingSpec.or(.init(havingSpecs: [
            .equalTo(.init(aggregation: "test", value: 12)),
            .dimensionSelector(.init(dimension: "test", value: "itsATest"))
        ]))

        let encodedHavingSpec = """
        {
            "havingSpecs": [
                {
                    "aggregation": "test",
                    "type": "equalTo",
                    "value": 12
                },
                {
                    "dimension": "test",
                    "type": "dimSelector",
                    "value": "itsATest"
                }
            ],
            "type": "or"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }

    func testNot() throws {
        let havingSpec = HavingSpec.not(.init(havingSpec: .equalTo(.init(aggregation: "test", value: 12))))

        let encodedHavingSpec = """
        {
            "havingSpec": {
                "aggregation": "test",
                "type": "equalTo",
                "value": 12
            },
            "type": "not"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(havingSpec)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedHavingSpec)

        let decoded = try JSONDecoder.telemetryDecoder.decode(HavingSpec.self, from: encoded)
        XCTAssertEqual(havingSpec, decoded)
    }
}
