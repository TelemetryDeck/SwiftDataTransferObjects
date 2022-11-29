//
//  FilterTests.swift
//
//
//  Created by Daniel Jilg on 22.12.21.
//

import DataTransferObjects
import XCTest

class FilterTests: XCTestCase {
    func testEncoding() throws {
        let exampleFilter = Filter.not(FilterNot(field: Filter.selector(FilterSelector(dimension: "test", value: "abc"))))
        _ = try JSONEncoder.telemetryEncoder.encode(exampleFilter)
    }
    
    func testFilterInterval() throws {
        let exampleFilterIntervalString = """
        {
            "dimension" : "__time",
            "intervals" : [
              "2014-10-01T00:00:00.000Z/2014-10-07T00:00:00.000Z"
            ],
            "type" : "interval"
        }
        """
        .filter { !$0.isWhitespace }
        
        let beginDate: Date = Formatter.iso8601.date(from: "2014-10-01T00:00:00.000Z")!
        let endDate: Date = Formatter.iso8601.date(from: "2014-10-07T00:00:00.000Z")!
        
        let exampleFilterInterval = Filter.interval(FilterInterval(
            dimension: "__time",
            intervals: [.init(beginningDate: beginDate, endDate: endDate)]
        ))
        
        let decodedFilterInterval = try JSONDecoder.telemetryDecoder.decode(
            Filter.self,
            from: exampleFilterIntervalString.data(using: .utf8)!
        )
        
        let encodedFilterInterval = try JSONEncoder.telemetryEncoder.encode(exampleFilterInterval)
        
        XCTAssertEqual(exampleFilterInterval, decodedFilterInterval)
        XCTAssertEqual(exampleFilterIntervalString, String(data: encodedFilterInterval, encoding: .utf8))
    }
}

